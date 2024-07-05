// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { BaseScript } from "../BaseScript.sol";
import { AgoraDollar, ConstructorParams as AgoraDollarParams } from "contracts/AgoraDollar.sol";
import { AgoraDollarErc1967Proxy, ConstructorParams as AgoraDollarErc1967ProxyParams } from "contracts/proxy/AgoraDollarErc1967Proxy.sol";

// Written as a free function to be consumed in testing and deployment scripts
function deployAgoraDollarImplementationWithArgs(
    string memory _name,
    string memory _symbol,
    string memory _eip712Name,
    string memory _eip712Version,
    address _proxyAddress
) returns (BaseScript.DeployReturn memory _return) {
    AgoraDollarParams memory _params = AgoraDollarParams({
        name: _name,
        symbol: _symbol,
        eip712Name: _eip712Name,
        eip712Version: _eip712Version,
        proxyAddress: _proxyAddress
    });

    AgoraDollar _agoraDollar = new AgoraDollar(_params);
    _return = BaseScript.DeployReturn({
        contractAddress: address(_agoraDollar),
        constructorParams: abi.encode(_params),
        contractName: "AgoraDollar"
    });
}

// Written as a free function to be consumed in testing and deployment scripts
function deployAgoraDollarErc1967ProxyWithArgs(
    address _proxyAdminOwnerAddress,
    string memory _eip712Name,
    string memory _eip712Version
) returns (BaseScript.DeployReturn memory _return) {
    AgoraDollarErc1967ProxyParams memory _params = AgoraDollarErc1967ProxyParams({
        proxyAdminOwnerAddress: _proxyAdminOwnerAddress,
        eip712Name: _eip712Name,
        eip712Version: _eip712Version
    });

    AgoraDollarErc1967Proxy _proxy = new AgoraDollarErc1967Proxy(_params);
    _return = BaseScript.DeployReturn({
        contractAddress: address(_proxy),
        constructorParams: abi.encode(_params),
        contractName: "AgoraDollarErc1967Proxy"
    });
}

struct DeployAgoraDollarContractsReturn {
    BaseScript.DeployReturn agoraDollarImplementation;
    BaseScript.DeployReturn agoraDollarErc1967Proxy;
}

function deployAgoraDollarContracts() returns (DeployAgoraDollarContractsReturn memory _return) {
    address INITIAL_ADMIN_ADDRESS = address(uint160(uint256(keccak256(bytes("ProxyAdminOwner")))));

    // deploy Agora Dollar Erc1967 Proxy contract
    BaseScript.DeployReturn memory _agoraDollarErc1967ProxyReturn = deployAgoraDollarErc1967ProxyWithArgs({
        _proxyAdminOwnerAddress: INITIAL_ADMIN_ADDRESS,
        _eip712Name: "AgoraDollar",
        _eip712Version: "1"
    });

    // deploy Agora Dollar implementation contract
    BaseScript.DeployReturn memory _agoraDollarImplementationReturn = deployAgoraDollarImplementationWithArgs({
        _name: "AgoraDollar",
        _symbol: "AUSD",
        _eip712Name: "AgoraDollar",
        _eip712Version: "1",
        _proxyAddress: _agoraDollarErc1967ProxyReturn.contractAddress
    });

    _return = DeployAgoraDollarContractsReturn({
        agoraDollarImplementation: _agoraDollarImplementationReturn,
        agoraDollarErc1967Proxy: _agoraDollarErc1967ProxyReturn
    });
}

// NOTE: This is the script which will be used to deploy the AgoraDollarErc1967Proxy and associated contracts
contract DeployProxy is BaseScript {
    function run() public broadcaster returns (DeployAgoraDollarContractsReturn memory) {
        return deployAgoraDollarContracts();
    }
}
