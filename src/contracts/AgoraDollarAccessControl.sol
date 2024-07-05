// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

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

import { StorageLib } from "./proxy/StorageLib.sol";

/// @title AgoraDollarAccessControl
/// @dev Inspired by Frax Finance's Timelock2Step contract which was inspired by OpenZeppelin's Ownable2Step contract
/// @notice An abstract contract which contains 2-step transfer and renounce logic for a privileged roles
abstract contract AgoraDollarAccessControl {
    /// @notice The ADMIN_ROLE identifier
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice The MINTER_ROLE identifier
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice The BURNER_ROLE identifier
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice The PAUSER_ROLE identifier
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice The FREEZER_ROLE identifier
    bytes32 public constant FREEZER_ROLE = keccak256("FREEZER_ROLE");

    /// @notice The RoleData struct
    /// @param pendingRoleAddress The address of the nominated (pending) role
    /// @param currentRoleAddress The address of the current role
    struct RoleData {
        address pendingRoleAddress;
        address currentRoleAddress;
    }

    function _initializeAgoraDollarAccessControl(address _initialAdminAddress) internal {
        StorageLib
            .getPointerToAgoraDollarAccessControlStorage()
            .roleData[ADMIN_ROLE]
            .currentRoleAddress = _initialAdminAddress;
    }

    // ============================================================================================
    // External Procedural Functions
    // ============================================================================================

    /// @notice The ```transferRole``` function initiates the role transfer
    /// @dev Must be called by the current role or the Admin
    /// @param _newAddress The address of the nominated (pending) role
    function transferRole(bytes32 _role, address _newAddress) external virtual {
        // Checks: Only current role or Admin can transfer role
        if (!(_isRole({ _role: _role, _address: msg.sender }) || _isRole({ _role: ADMIN_ROLE, _address: msg.sender })))
            revert AddressIsNotRole({ role: _role });

        // Effects: update pendingRole
        _setPendingRoleAddress({ _role: _role, _newAddress: _newAddress });
    }

    /// @notice The ```acceptTransferRole``` function completes the role transfer
    /// @dev Must be called by the pending role
    function acceptTransferRole(bytes32 _role) external virtual {
        // Checks
        _requireSenderIsPendingRole({ _role: _role });

        // Effects update role address
        _acceptTransferRole({ _role: _role });
    }

    // ============================================================================================
    // Internal Effects Functions
    // ============================================================================================

    /// @notice The ```_transferRole``` function initiates the role transfer
    /// @dev This function is to be implemented by a public function
    /// @param _role The role to transfer
    /// @param _newAddress The address of the nominated (pending) role
    function _setPendingRoleAddress(bytes32 _role, address _newAddress) internal {
        StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_role].pendingRoleAddress = _newAddress;
        emit RoleTransferStarted({
            role: _role,
            previousAddress: StorageLib
                .getPointerToAgoraDollarAccessControlStorage()
                .roleData[_role]
                .currentRoleAddress,
            newAddress: _newAddress
        });
    }

    /// @notice The ```_acceptTransferRole``` function completes the role transfer
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to transfer
    function _acceptTransferRole(bytes32 _role) internal {
        StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_role].pendingRoleAddress = address(0);
        _setCurrentRoleAddress({ _role: _role, _newAddress: msg.sender });
    }

    /// @notice The ```_setRole``` function sets the role address
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to transfer
    /// @param _newAddress The address of the new role
    function _setCurrentRoleAddress(bytes32 _role, address _newAddress) internal {
        emit RoleTransferred({
            role: _role,
            previousAddress: StorageLib
                .getPointerToAgoraDollarAccessControlStorage()
                .roleData[_role]
                .currentRoleAddress,
            newAddress: _newAddress
        });
        StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_role].currentRoleAddress = _newAddress;
    }

    // ============================================================================================
    // Internal Checks Functions
    // ============================================================================================

    /// @notice The ```_isRole``` function checks if _address is current role address
    /// @param _role The role identifier to check
    /// @param _address The address to check against the role
    /// @return Whether or not msg.sender is current role address
    function _isRole(bytes32 _role, address _address) internal view returns (bool) {
        return _address == StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_role].currentRoleAddress;
    }

    /// @notice The ```_requireIsRole``` function reverts if _address is not current role address
    /// @param _role The role identifier to check
    /// @param _address The address to check against the role
    function _requireIsRole(bytes32 _role, address _address) internal view {
        if (!_isRole({ _role: _role, _address: _address })) revert AddressIsNotRole({ role: _role });
    }

    /// @notice The ```_requireSenderIsRole``` function reverts if msg.sender is not current role address
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to check
    function _requireSenderIsRole(bytes32 _role) internal view {
        _requireIsRole({ _role: _role, _address: msg.sender });
    }

    /// @notice The ```_isPendingRole``` function checks if the _address is pending role address
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to check
    /// @param _address The address to check against the pending role
    /// @return Whether or not _address is pending role address
    function _isPendingRole(bytes32 _role, address _address) internal view returns (bool) {
        return _address == StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_role].pendingRoleAddress;
    }

    /// @notice The ```_requireIsPendingRole``` function reverts if the _address is not pending role address
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to check
    /// @param _address The address to check against the pending role
    function _requireIsPendingRole(bytes32 _role, address _address) internal view {
        if (!_isPendingRole({ _role: _role, _address: _address })) revert AddressIsNotPendingRole({ role: _role });
    }

    /// @notice The ```_requirePendingRole``` function reverts if msg.sender is not pending role address
    /// @dev This function is to be implemented by a public function
    /// @param _role The role identifier to check
    function _requireSenderIsPendingRole(bytes32 _role) internal view {
        _requireIsPendingRole({ _role: _role, _address: msg.sender });
    }

    // ============================================================================================
    // Events
    // ============================================================================================

    /// @notice The ```RoleTransferStarted``` event is emitted when the role transfer is initiated
    /// @param role The bytes32 identifier of the role that is being transferred
    /// @param previousAddress The address of the previous role
    /// @param newAddress The address of the new role
    event RoleTransferStarted(bytes32 role, address indexed previousAddress, address indexed newAddress);

    /// @notice The ```RoleTransferred``` event is emitted when the role transfer is completed
    /// @param role The bytes32 identifier of the role that was transferred
    /// @param previousAddress The address of the previous role
    /// @param newAddress The address of the new role
    event RoleTransferred(bytes32 role, address indexed previousAddress, address indexed newAddress);

    // ============================================================================================
    // Errors
    // ============================================================================================

    /// @notice Emitted when role is transferred
    /// @param role The role identifier
    error AddressIsNotRole(bytes32 role);

    /// @notice Emitted when pending role is transferred
    /// @param role The role identifier
    error AddressIsNotPendingRole(bytes32 role);
}
