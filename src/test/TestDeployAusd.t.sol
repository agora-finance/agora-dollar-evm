// SPDX-License-Identifier: ISC
pragma solidity ^0.8.21;

import { VmHelper } from "agora-std/VmHelper.sol";
import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";

import { IAgoraDollar } from "contracts/interfaces/IAgoraDollar.sol";

import { IAgoraDollarErc1967Proxy } from "contracts/interfaces/IAgoraDollarErc1967Proxy.sol";
import { IAgoraProxyAdmin } from "contracts/interfaces/IAgoraProxyAdmin.sol";

import { AgoraConstants } from "../script/AgoraConstants.sol";

/* solhint-disable func-name-mixedcase */
contract AusdDeploymentTest is Test, VmHelper {
    address public proxyAdminOwnerAddress = labelAndDeal("proxyAdminOwnerAddress");
    address public bob = labelAndDeal("bob");
    address public alice = labelAndDeal("alice");
    // address public constant PROXY_ADMIN_DEPLOYER = 0xa52baa992099D8630495659bF966856521bF7AFd;
    address private constant AUSD_PROXY_DEPLOYER = AgoraConstants.AUSD_PROXY_DEPLOYER;
    address public constant PROXY_ADMIN_OWNER = AgoraConstants.PROXY_ADMIN_OWNER;

    // These are addresses where I (Jordi) deployed a token for testing
    address public constant PROXY_ADMIN_ADDRESS = AgoraConstants.AUSD_PROXY_ADMIN;
    IAgoraProxyAdmin public _ausdProxyAdmin = IAgoraProxyAdmin(PROXY_ADMIN_ADDRESS);
    address public constant PROXY_ADDRESS = AgoraConstants.AUSD_PROXY;
    IAgoraDollarErc1967Proxy public _ausdProxy = IAgoraDollarErc1967Proxy(PROXY_ADDRESS);
    address public constant IMPLEMENTATION_ADDRESS = AgoraConstants.AUSD_IMPL;
    IAgoraDollar public _ausdImplementation = IAgoraDollar(IMPLEMENTATION_ADDRESS);

    function setUp() public {
        vm.createSelectFork("eth_testnet", 7_791_278);
        // vm.createSelectFork("eth_testnet", 7_792_346);

        console2.log("deployed admin owner: ", _ausdProxyAdmin.owner());
        // testAusdInitializes();
        // vm.stopBroadcast();
    }

    function testAusdInitializesAndTransfersRoles() public {
        vm.startPrank(PROXY_ADMIN_OWNER);

        /// GIVEN: Ausd-like contract has already been deployed
        assertTrue({
            err: "/// GIVEN: The proxyAdminOwner is the owner of the Admin contract",
            data: _ausdProxyAdmin.owner() == PROXY_ADMIN_OWNER
        });

        /// WHEN: Calling `initialize` with the `ProxyAdminOwner` as `address`
        bytes memory _ausdInitData = abi.encodeWithSignature("initialize(address)", PROXY_ADMIN_OWNER);

        /// THEN: The call succeeds and the ausd-like proxy is updated
        _ausdProxyAdmin.upgradeAndCall({
            proxy: PROXY_ADDRESS,
            implementation: IMPLEMENTATION_ADDRESS,
            data: _ausdInitData
        });

        /// GIVEN: The proxy has been configured properly for the ausd-like implementation
        IAgoraDollar _ausd = IAgoraDollar(PROXY_ADDRESS);

        assertTrue({
            err: "/// THEN: The `ProxyAdminOwner` has the `ADMIN_ROLE`",
            data: _ausd.getRoleData(_ausd.ADMIN_ROLE()).currentRoleAddress == PROXY_ADMIN_OWNER
        });

        /// WHEN: The roles are set to the `ProxyAdminOwner`
        bytes32[4] memory rolesToTransfer = [
            _ausd.MINTER_ROLE(),
            _ausd.BURNER_ROLE(),
            _ausd.FREEZER_ROLE(),
            _ausd.PAUSER_ROLE()
        ];

        for (uint256 i = 0; i < rolesToTransfer.length; i++) {
            bytes32 _roleToTransfer = rolesToTransfer[i];
            assertTrue({
                err: "/// GIVEN: The `zeroAddress` has the `roleToTransfer`",
                data: _ausd.getRoleData(_roleToTransfer).currentRoleAddress == address(0)
            });

            /// WHEN: The `ProxyAdminOwner` transfers the role to itself
            _ausd.transferRole(_roleToTransfer, PROXY_ADMIN_OWNER);
            _ausd.acceptTransferRole(_roleToTransfer);

            assertTrue({
                err: "/// THEN: The `ProxyAdminOwner` has the transfered role",
                data: _ausd.getRoleData(_roleToTransfer).currentRoleAddress == PROXY_ADMIN_OWNER
            });
        }
    }
}
