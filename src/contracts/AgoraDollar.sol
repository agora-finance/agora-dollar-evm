// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

// solhint-disable func-name-mixedcase
// ====================================================================
//             _        ______     ___   _______          _
//            / \     .' ___  |  .'   `.|_   __ \        / \
//           / _ \   / .'   \_| /  .-.  \ | |__) |      / _ \
//          / ___ \  | |   ____ | |   | | |  __ /      / ___ \
//        _/ /   \ \_\ `.___]  |\  `-'  /_| |  \ \_  _/ /   \ \_
//       |____| |____|`._____.'  `.___.'|____| |___||____| |____|
// ====================================================================
// =========================== AgoraDollar ============================
// ====================================================================

import { AgoraDollarCore, ConstructorParams, ShortStrings } from "./AgoraDollarCore.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @title AgoraDollar
contract AgoraDollar is AgoraDollarCore {
    using StorageLib for uint256;
    using ShortStrings for *;

    constructor(ConstructorParams memory _params) AgoraDollarCore(_params) {}

    //==============================================================================
    // External View Functions: Erc3009
    //==============================================================================

    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return TRANSFER_WITH_AUTHORIZATION_TYPEHASH_;
    }

    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return RECEIVE_WITH_AUTHORIZATION_TYPEHASH_;
    }

    function CANCEL_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return CANCEL_AUTHORIZATION_TYPEHASH_;
    }

    /// @notice The ```authorizationState;``` maps the following:
    /// @notice Key: ```_authorizer``` the account which is providing the authorization
    /// @notice Key: ```_nonce``` the unique nonce for the authorization
    /// @return _isNonceUsed the state of the authorization
    function authorizationState(address _authorizer, bytes32 _nonce) external view returns (bool _isNonceUsed) {
        _isNonceUsed = StorageLib.getPointerToEip3009Storage().isAuthorizationUsed[_authorizer][_nonce];
    }

    //==============================================================================
    //  Eip712 Functions
    //==============================================================================

    function hashTypedDataV4(bytes32 _structHash) external view returns (bytes32) {
        return _hashTypedDataV4({ structHash: _structHash });
    }

    function domainSeparatorV4() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    //==============================================================================
    // External View Functions: Erc2612
    //==============================================================================

    function ERC2612_STORAGE_SLOT() external pure returns (bytes32) {
        return StorageLib.ERC2612_STORAGE_SLOT_;
    }

    function nonces(address _account) external view returns (uint256 _nonce) {
        _nonce = StorageLib.getPointerToErc2612Storage().nonces[_account];
    }

    //==============================================================================
    // External View Functions: Erc20
    //==============================================================================

    function name() external view returns (string memory) {
        return _name.toString();
    }

    function symbol() external view returns (string memory) {
        return _symbol.toString();
    }

    function balanceOf(address _account) external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account].balance;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().accountAllowances[_owner][_spender];
    }

    function totalSupply() external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().totalSupply;
    }

    function isAccountFrozen(address _account) external view returns (bool) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account].isFrozen;
    }

    function accountData(address _account) external view returns (StorageLib.Erc20AccountData memory) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account];
    }

    function ERC20_CORE_STORAGE_SLOT() external pure returns (bytes32) {
        return StorageLib.ERC20_CORE_STORAGE_SLOT_;
    }

    //==============================================================================
    // External View Functions: AccessControlMetadata
    //==============================================================================

    function getRoleData(bytes32 _roleId) external view returns (StorageLib.AgoraDollarAccessControlRoleData memory) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[_roleId];
    }

    function adminAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[ADMIN_ROLE].currentRoleAddress;
    }

    function pendingAdminAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[ADMIN_ROLE].pendingRoleAddress;
    }

    function minterAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[MINTER_ROLE].currentRoleAddress;
    }

    function pendingMinterAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[MINTER_ROLE].pendingRoleAddress;
    }

    function burnerAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[BURNER_ROLE].currentRoleAddress;
    }

    function pendingBurnerAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[BURNER_ROLE].pendingRoleAddress;
    }

    function pauserAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[PAUSER_ROLE].currentRoleAddress;
    }

    function pendingPauserAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[PAUSER_ROLE].pendingRoleAddress;
    }

    function freezerAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[FREEZER_ROLE].currentRoleAddress;
    }

    function pendingFreezerAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarAccessControlStorage().roleData[FREEZER_ROLE].pendingRoleAddress;
    }

    //==============================================================================
    // External View Functions: Eip712
    //==============================================================================

    function eip712Domain()
        external
        view
        returns (
            bytes1 _fields,
            string memory _name,
            string memory _version,
            uint256 _chainId,
            address _verifyingContract,
            bytes32 _salt,
            uint256[] memory _extensions
        )
    {
        return (
            hex"0f", // 01111
            _Eip712Name(),
            _Eip712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    //==============================================================================
    // External View Functions: AgoraDollarErc1967 Proxy State
    //==============================================================================

    function proxyAdminAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarErc1967ProxyAdminStorage().proxyAdminAddress;
    }

    function isMsgSenderFrozenCheckEnabled() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isMsgSenderFrozenCheckEnabled();
    }

    function isTransferPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferPaused();
    }

    function isSignatureVerificationPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isSignatureVerificationPaused();
    }

    function isMintPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isMintPaused();
    }

    function isFreezingPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused();
    }

    function isTransferUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferUpgraded();
    }

    function isTransferFromUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferFromUpgraded();
    }

    function isTransferWithAuthorizationUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferWithAuthorizationUpgraded();
    }

    function implementation() external view returns (address) {
        return StorageLib.sloadImplementationSlotDataAsUint256().implementation();
    }

    //==============================================================================
    // Proxy Utils BitMasks
    //==============================================================================

    function IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_;
    }

    function IS_MINT_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_MINT_PAUSED_BIT_POSITION_;
    }

    function IS_FREEZING_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_FREEZING_PAUSED_BIT_POSITION_;
    }

    function IS_TRANSFER_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_PAUSED_BIT_POSITION_;
    }

    function IS_TRANSFER_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_UPGRADED_BIT_POSITION_;
    }

    function IS_TRANSFER_FROM_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_;
    }

    function IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_;
    }

    function IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_;
    }
}
