// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

// ====================================================================
//             _        ______     ___   _______          _
//            / \     .' ___  |  .'   `.|_   __ \        / \
//           / _ \   / .'   \_| /  .-.  \ | |__) |      / _ \
//          / ___ \  | |   ____ | |   | | |  __ /      / ___ \
//        _/ /   \ \_\ `.___]  |\  `-'  /_| |  \ \_  _/ /   \ \_
//       |____| |____|`._____.'  `.___.'|____| |___||____| |____|
// ====================================================================
// ===================== AgoraDollarAccessControl =====================
// ====================================================================

import { AgoraAccessControl } from "agora-contracts/access-control/AgoraAccessControl.sol";

/// @title AgoraDollarAccessControl
/// @notice An abstract contract that manages access control for the AgoraDollar contract
/// @author Agora
abstract contract AgoraDollarAccessControl is AgoraAccessControl {
    /// @notice The MINTER_ROLE identifier
    string public constant MINTER_ROLE = "MINTER_ROLE";

    /// @notice The BURNER_ROLE identifier
    string public constant BURNER_ROLE = "BURNER_ROLE";

    /// @notice The PAUSER_ROLE identifier
    string public constant PAUSER_ROLE = "PAUSER_ROLE";

    /// @notice The FREEZER_ROLE identifier
    string public constant FREEZER_ROLE = "FREEZER_ROLE";

    /// @notice The BRIDGE_MINTER_ROLE identifier
    string public constant BRIDGE_MINTER_ROLE = "BRIDGE_MINTER_ROLE";

    /// @notice The BRIDGE_BURNER_ROLE identifier
    string public constant BRIDGE_BURNER_ROLE = "BRIDGE_BURNER_ROLE";

    /// @notice The ```_initializeAgoraDollarAccessControl``` function initializes the AgoraDollarAccessControl contract
    /// @dev This function adds the default roles that are required by the AgoraDollar contract
    /// @param _initialAdminAddress The address of the initial `ACCESS_CONTROL_MANAGER_ROLE` holder
    /// @param _initialMinter The address of the initial `MINTER_ROLE` holder
    /// @param _initialBurner The address of the initial `BURNER_ROLE` holder
    /// @param _initialPauser The address of the initial `PAUSER_ROLE` holder
    /// @param _initialFreezer The address of the initial `FREEZER_ROLE` holder
    function _initializeAgoraDollarAccessControl(
        address _initialAdminAddress,
        address _initialMinter,
        address _initialBurner,
        address _initialPauser,
        address _initialFreezer
    ) internal {
        _initializeAgoraAccessControl({ _initialAdminAddress: _initialAdminAddress });

        // setup the minter role
        _addRoleToSet({ _role: MINTER_ROLE });
        _assignRole({ _role: MINTER_ROLE, _member: _initialMinter, _addRole: true });

        // setup the burner role
        _addRoleToSet({ _role: BURNER_ROLE });
        _assignRole({ _role: BURNER_ROLE, _member: _initialBurner, _addRole: true });

        // setup the pauser role
        _addRoleToSet({ _role: PAUSER_ROLE });
        _assignRole({ _role: PAUSER_ROLE, _member: _initialPauser, _addRole: true });

        // setup the freezer role
        _addRoleToSet({ _role: FREEZER_ROLE });
        _assignRole({ _role: FREEZER_ROLE, _member: _initialFreezer, _addRole: true });

        // setup the bridge minter role
        _addRoleToSet({ _role: BRIDGE_MINTER_ROLE });

        // setup the bridge burner role
        _addRoleToSet({ _role: BRIDGE_BURNER_ROLE });
    }

    // ============================================================================================
    // External Procedural Functions
    // ============================================================================================

    /// @notice The ```grantMinterRole``` function grants `MINTER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantMinterRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: MINTER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokeMinterRole``` function revokes `MINTER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokeMinterRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: MINTER_ROLE, _member: _member, _addRole: false });
    }

    /// @notice The ```grantBurnerRole``` function grants `BURNER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantBurnerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BURNER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokeBurnerRole``` function revokes `BURNER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokeBurnerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BURNER_ROLE, _member: _member, _addRole: false });
    }

    /// @notice The ```grantPauserRole``` function grants `PAUSER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantPauserRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: PAUSER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokePauserRole``` function revokes `PAUSER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokePauserRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: PAUSER_ROLE, _member: _member, _addRole: false });
    }

    /// @notice The ```grantFreezerRole``` function grants `FREEZER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantFreezerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: FREEZER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokeFreezerRole``` function revokes `FREEZER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokeFreezerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: FREEZER_ROLE, _member: _member, _addRole: false });
    }

    /// @notice The ```grantBridgeMinterRole``` function grants `BRIDGE_MINTER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantBridgeMinterRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BRIDGE_MINTER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokeBridgeMinterRole``` function revokes `BRIDGE_MINTER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokeBridgeMinterRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BRIDGE_MINTER_ROLE, _member: _member, _addRole: false });
    }

    /// @notice The ```grantBridgeBurnerRole``` function grants `BRIDGE_BURNER_ROLE` to an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function grantBridgeBurnerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BRIDGE_BURNER_ROLE, _member: _member, _addRole: true });
    }

    /// @notice The ```revokeBridgeBurnerRole``` function revokes `BRIDGE_BURNER_ROLE` from an address
    /// @dev Must be called by an address holding `ACCESS_CONTROL_MANAGER_ROLE`
    /// @param _member The address to be assigned the role
    function revokeBridgeBurnerRole(address _member) external {
        // Checks: Only Admin can transfer role
        _requireSenderIsRole({ _role: ACCESS_CONTROL_MANAGER_ROLE });

        _assignRole({ _role: BRIDGE_BURNER_ROLE, _member: _member, _addRole: false });
    }
}
