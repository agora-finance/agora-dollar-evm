// SPDX-License-Identifier: ISC
pragma solidity ^0.8.21;

import { Script } from "node_modules/forge-std/src/Script.sol";

import { console2 } from "forge-std/console2.sol";

import { IAgoraDollar } from "contracts/interfaces/IAgoraDollar.sol";

import { IAgoraDollarErc1967Proxy } from "contracts/interfaces/IAgoraDollarErc1967Proxy.sol";
import { IAgoraProxyAdmin } from "contracts/interfaces/IAgoraProxyAdmin.sol";

import { AusdConstants } from "../../src/script/AusdConstants.sol";

/// @title UpgradeAusd
/// @notice A contract for setting up AUSD to its desired initial state
/// @author Agora
contract UpgradeAusd is Script {
    // * IMPORTANT: `PROXY_ADMIN_ADDRESS` needs to be fetched from the AUSD-Proxy tx on the explorer
    IAgoraProxyAdmin public _ausdProxyAdmin = IAgoraProxyAdmin(AusdConstants.AUSD_PROXY_ADMIN);

    /// @notice Initializes AUSD and transfers all roles to the ``PROXY_ADMIN_OWNER`` EOA
    function run() public {
        vm.startBroadcast(AusdConstants.PROXY_ADMIN_OWNER);

        // Calls `initialize` with the `ProxyAdminOwner` as `address`
        // bytes memory _ausdInitData = abi.encodeWithSignature("initialize(address)", AusdConstants.PROXY_ADMIN_OWNER);

        // // Updates the proxy to the ausd implementation
        // _ausdProxyAdmin.upgradeAndCall({
        //     proxy: AusdConstants.AUSD_PROXY,
        //     implementation: AusdConstants.AUSD_IMPL,
        //     data: _ausdInitData
        // });

        IAgoraDollar _ausd = IAgoraDollar(AusdConstants.AUSD_PROXY);

        // Defining the roles to be transfered to the `ProxyAdminOwner`
        bytes32[4] memory rolesToTransfer = [
            _ausd.MINTER_ROLE(),
            _ausd.BURNER_ROLE(),
            _ausd.FREEZER_ROLE(),
            _ausd.PAUSER_ROLE()
        ];

        for (uint256 i = 0; i < rolesToTransfer.length; i++) {
            bytes32 _roleToTransfer = rolesToTransfer[i];
            // Transfer the role from `address(0)` to `ProxyAdminOwner`
            _ausd.transferRole(_roleToTransfer, AusdConstants.PROXY_ADMIN_OWNER);

            // Accept the transfer of the role
            _ausd.acceptTransferRole(_roleToTransfer);
        }

        vm.stopBroadcast();
    }
}
