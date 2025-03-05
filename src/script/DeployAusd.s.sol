// SPDX-License-Identifier: ISC
pragma solidity ^0.8.21;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

import { AgoraDollar, ConstructorParams as AgoraDollarParams } from "contracts/AgoraDollar.sol";
import { AgoraDollarErc1967Proxy, ConstructorParams as AgoraDollarErc1967ProxyParams } from "contracts/proxy/AgoraDollarErc1967Proxy.sol";
import { ICreateX } from "node_modules/createx/src/ICreateX.sol";

import { AgoraConstants } from "./AgoraConstants.sol";

/* solhint-disable no-console, reason-string*/
contract DeployAusd is Script {
    // address private constant AUSD_TOKEN = 0xa9012a055bd4e0eDfF8Ce09f960291C09D5322dC;
    uint256 private constant DEPLOYMENT_VERSION = 3;

    function _computeSalt(bytes memory _identifier, uint256 version) internal pure returns (bytes32) {
        uint256 saltBase = (uint256(keccak256(_identifier)) - 1) & 0xffffffff0000;
        uint256 saltCombined = saltBase + version;
        bytes32 _salt = bytes32(
            abi.encodePacked(
                AgoraConstants.PROXY_ADMIN_OWNER,
                hex"00", // no cross-chain redeploy protection
                bytes11(uint88(saltCombined)) // this is associated with the number of contracts we've deployed
            )
        );
        return _salt;
    }

    function _deployAusdProxy(bytes memory _constructorArgs) private returns (address _ausdProxyAddress) {
        // Gets the creation code
        bytes memory _creationCode = abi.encodePacked(type(AgoraDollarErc1967Proxy).creationCode, _constructorArgs);

        // bytes32 _saltAusdProxy = _computeSalt("TEST_AgoraDollarProxy", DEPLOYMENT_VERSION);

        // Deploys the AUSD proxy at the expected address
        _ausdProxyAddress = ICreateX(AgoraConstants.CREATEX_ADDRESS).deployCreate2({
            salt: 0xb53de4376284c74ed70edcb9daf7256942153fbc00d30bc9da6e697c02b4cf97, // predefined salt to get the ausd address
            // salt: _saltAusdProxy,
            initCode: _creationCode
        });

        console2.log("Deployment: AUSD Proxy - ", _ausdProxyAddress);
        console2.log("--constructor-args");
        console2.logBytes(_constructorArgs);
    }

    function _deployAusdImplementation(bytes memory _constructorArgs) private {
        // Gets the creation code
        bytes memory _ausdCreationCode = abi.encodePacked(type(AgoraDollar).creationCode, _constructorArgs);

        // Gets a new salt
        bytes32 _saltAusdImplementation = _computeSalt("AgoraDollar", DEPLOYMENT_VERSION);

        // Deploys the AUSD token implementation
        address _ausdImplementationAddress = ICreateX(AgoraConstants.CREATEX_ADDRESS).deployCreate2({
            salt: _saltAusdImplementation,
            initCode: _ausdCreationCode
        });

        console2.log("Deployment: AUSD Implementation - ", _ausdImplementationAddress);
        console2.log("--constructor-args");
        console2.logBytes(_constructorArgs);
    }

    function run() public broadcaster {
        require(
            AgoraConstants.AUSD_PROXY_DEPLOYER == msg.sender,
            "Deploy: Only the deployer can deploy the proxy admin, add the `--sender` flag to the command"
        );

        // AUSD proxy Params
        bytes memory _proxyConstructorParams = abi.encode(
            AgoraDollarErc1967ProxyParams({
                proxyAdminOwnerAddress: AgoraConstants.PROXY_ADMIN_OWNER,
                eip712Name: "Agora Dollar",
                // eip712Name: "Test Dollar",
                eip712Version: "1"
            })
        );

        // Deploy AUSD Proxy
        address _ausdProxyAddress = _deployAusdProxy(_proxyConstructorParams);

        // AUSD implementation Params
        bytes memory _implementationConstructorParams = abi.encode(
            AgoraDollarParams({
                // name: "TST",
                // symbol: "TST",
                // eip712Name: "Dirmes Dollar",
                name: "AUSD",
                symbol: "AUSD",
                eip712Name: "Agora Dollar",
                eip712Version: "1",
                proxyAddress: _ausdProxyAddress
            })
        );

        // Deploy AUSD Implementation
        _deployAusdImplementation(_implementationConstructorParams);
    }

    modifier broadcaster() {
        vm.startBroadcast(AgoraConstants.AUSD_PROXY_DEPLOYER);
        _;
        vm.stopBroadcast();
    }
}
