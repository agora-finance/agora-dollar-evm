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
// =========================== AgoraDollar ============================
// ====================================================================

import { AgoraDollarCore, ConstructorParams, ShortStrings } from "./AgoraDollarCore.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @title AgoraDollar
/// @notice AgoraDollar is a digital dollar implementation
/// @author Agora
contract AgoraDollar is AgoraDollarCore {
    using StorageLib for uint256;
    using ShortStrings for *;

    /// @notice The AgoraDollar Constructor, invoked upon deployment
    /// @param _params The constructor params for AgoraDollar
    constructor(ConstructorParams memory _params) AgoraDollarCore(_params) {}

    //==============================================================================
    // External View Functions: Erc3009
    //==============================================================================

    // solhint-disable func-name-mixedcase
    /// @notice The ```TRANSFER_WITH_AUTHORIZATION_TYPEHASH``` function returns the typehash for the transfer with authorization
    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return TRANSFER_WITH_AUTHORIZATION_TYPEHASH_;
    }

    /// @notice The ```RECEIVE_WITH_AUTHORIZATION_TYPEHASH``` function returns the typehash for the receive with authorization
    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return RECEIVE_WITH_AUTHORIZATION_TYPEHASH_;
    }

    /// @notice The ```CANCEL_AUTHORIZATION_TYPEHASH``` function returns the typehash for the cancel authorization
    function CANCEL_AUTHORIZATION_TYPEHASH() external pure returns (bytes32) {
        return CANCEL_AUTHORIZATION_TYPEHASH_;
    }

    /// @notice The ```authorizationState``` function returns the state of the authorization nonce for a given authorizer
    /// @param _authorizer The account which is providing the authorization
    /// @param _nonce The unique nonce for the authorization
    /// @return _isNonceUsed The state of the authorization
    function authorizationState(address _authorizer, bytes32 _nonce) external view returns (bool _isNonceUsed) {
        _isNonceUsed = StorageLib.getPointerToEip3009Storage().isAuthorizationUsed[_authorizer][_nonce];
    }

    //==============================================================================
    //  External View Functions: Eip712
    //==============================================================================

    /// @notice The ```hashTypedDataV4``` function hashes the typed data according to Eip712
    /// @param _structHash The hash of the struct
    function hashTypedDataV4(bytes32 _structHash) external view returns (bytes32) {
        return _hashTypedDataV4({ structHash: _structHash });
    }

    /// @notice The ```domainSeparatorV4``` function returns the domain separator for Eip712
    function domainSeparatorV4() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    //==============================================================================
    // External View Functions: Erc2612
    //==============================================================================

    /// @notice The ```ERC2612_STORAGE_SLOT``` function returns the storage slot for Erc2612 storage
    function ERC2612_STORAGE_SLOT() external pure returns (bytes32) {
        return StorageLib.ERC2612_STORAGE_SLOT_;
    }

    /// @notice The ```nonces``` function returns the nonce for a given account according to Erc2612
    function nonces(address _account) external view returns (uint256 _nonce) {
        _nonce = StorageLib.getPointerToErc2612Storage().nonces[_account];
    }

    //==============================================================================
    // External View Functions: Erc20
    //==============================================================================

    /// @notice The ```name``` function returns the name of the token
    function name() external view returns (string memory) {
        return _name.toString();
    }

    /// @notice The ```symbol``` function returns the symbol of the token
    function symbol() external view returns (string memory) {
        return _symbol.toString();
    }

    /// @notice The ```balanceOf``` function returns the token balance of a given account
    /// @param _account The account to check the balance of
    /// @return The balance of the account
    function balanceOf(address _account) external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account].balance;
    }

    /// @notice The ```allowance``` function returns the allowance a given owner has given to the spender
    /// @param _owner The account which is giving the allowance
    /// @param _spender The account which is being given the allowance
    /// @return The allowance the owner has given to the spender
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().accountAllowances[_owner][_spender];
    }

    /// @notice The ```totalSupply``` function returns the total supply of the token
    /// @return The total supply of the token
    function totalSupply() external view returns (uint256) {
        return StorageLib.getPointerToErc20CoreStorage().totalSupply;
    }

    /// @notice The ```isAccountFrozen``` function returns a boolean indicating if an account is frozen
    /// @param _account The account whose frozen status to check
    function isAccountFrozen(address _account) external view returns (bool) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account].isFrozen;
    }

    /// @notice The ```accountData``` function returns Erc20 information about a given account
    /// @param _account The account to get the Erc20 information for
    /// @return The Erc20 information for the account (balance, isFrozenStatus)
    function accountData(address _account) external view returns (StorageLib.Erc20AccountData memory) {
        return StorageLib.getPointerToErc20CoreStorage().accountData[_account];
    }

    /// @notice The ```ERC20_CORE_STORAGE_SLOT``` function returns the storage slot for Erc20 storage
    function ERC20_CORE_STORAGE_SLOT() external pure returns (bytes32) {
        return StorageLib.ERC20_CORE_STORAGE_SLOT_;
    }

    //==============================================================================
    // External View Functions: AgoraDollarAccessControl
    //==============================================================================

    /// @notice The ```getMinterRoleMembers``` function returns the addresses holding `MINTER_ROLE`
    /// @return The array of addresses holding `MINTER_ROLE`
    function getMinterRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(MINTER_ROLE);
    }

    /// @notice The ```getBurnerRoleMembers``` function returns the addresses holding `BURNER_ROLE`
    /// @return The array of addresses holding `BURNER_ROLE`
    function getBurnerRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(BURNER_ROLE);
    }

    /// @notice The ```getPauserRoleMembers``` function returns the addresses holding `PAUSER_ROLE`
    /// @return The array of addresses holding `PAUSER_ROLE`
    function getPauserRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(PAUSER_ROLE);
    }

    /// @notice The ```getFreezerRoleMembers``` function returns the addresses holding `FREEZER_ROLE`
    /// @return The array of addresses holding `FREEZER_ROLE`
    function getFreezerRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(FREEZER_ROLE);
    }

    /// @notice The ```getBridgeMinterRoleMembers``` function returns the addresses holding `BRIDGE_MINTER_ROLE`
    /// @return The array of addresses holding `BRIDGE_MINTER_ROLE`
    function getBridgeMinterRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(BRIDGE_MINTER_ROLE);
    }

    /// @notice The ```getBridgeBurnerRoleMembers``` function returns the addresses holding `BRIDGE_BURNER_ROLE`
    /// @return The array of addresses holding `BRIDGE_BURNER_ROLE`
    function getBridgeBurnerRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(BRIDGE_BURNER_ROLE);
    }

    /// @notice The ```getRateLimitManagerRoleMembers``` function returns the addresses holding `RATE_LIMIT_MANAGER_ROLE`
    /// @return The array of addresses holding `RATE_LIMIT_MANAGER_ROLE`
    function getRateLimitManagerRoleMembers() external view returns (address[] memory) {
        return getRoleMembers(RATE_LIMIT_MANAGER_ROLE);
    }

    //==============================================================================
    // External View Functions: Eip712
    //==============================================================================

    /// @notice The ```eip712Domain``` function returns the Eip712 domain data
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
    // External View Functions: AgoraDollarErc1967Proxy
    //==============================================================================

    /// @notice The ```proxyAdminAddress``` function returns the address of the proxy admin
    /// @return The address of the proxy admin
    function proxyAdminAddress() external view returns (address) {
        return StorageLib.getPointerToAgoraDollarErc1967ProxyAdminStorage().proxyAdminAddress;
    }

    /// @notice The ```isMsgSenderFrozenCheckEnabled``` function returns a boolean indicating if the msg.sender frozen check is turned on
    /// @return A boolean indicating if the msg sender frozen check is true
    function isMsgSenderFrozenCheckEnabled() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isMsgSenderFrozenCheckEnabled();
    }

    /// @notice The ```isTransferPaused``` function returns a boolean indicating if transfers are paused
    /// @return A boolean indicating if transfers are paused
    function isTransferPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferPaused();
    }

    /// @notice The ```isSignatureVerificationPaused``` function returns a boolean indicating if signature verification is paused
    /// @return A boolean indicating if signature verification is paused
    function isSignatureVerificationPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isSignatureVerificationPaused();
    }

    /// @notice The ```isMintPaused``` function returns a boolean indicating if minting is paused
    /// @return A boolean indicating if minting is paused
    function isMintPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isMintPaused();
    }

    /// @notice The ```isBurnFromPaused``` function returns a boolean indicating if burnFrom is paused
    /// @return A boolean indicating if burnFrom is paused
    function isBurnFromPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isBurnFromPaused();
    }

    /// @notice The ```isFreezingPaused``` function returns a boolean indicating if freezing is paused
    /// @return A boolean indicating if freezing is paused
    function isFreezingPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused();
    }

    /// @notice The ```isTransferUpgraded``` function returns a boolean indicating if the transfer function is upgraded
    /// @return A boolean indicating if the transfer function is upgraded
    function isTransferUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferUpgraded();
    }

    /// @notice The ```isTransferFromUpgraded``` function returns a boolean indicating if the transferFrom function is upgraded
    /// @return A boolean indicating if the transferFrom function is upgraded
    function isTransferFromUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferFromUpgraded();
    }

    /// @notice The ```isTransferWithAuthorizationUpgraded``` function returns a boolean indicating if the transferWithAuthorization function is upgraded
    /// @return A boolean indicating if the transferWithAuthorization function is upgraded
    function isTransferWithAuthorizationUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isTransferWithAuthorizationUpgraded();
    }

    /// @notice The ```isReceiveWithAuthorizationUpgraded``` function returns a boolean indicating if the receiveWithAuthorization function is upgraded
    /// @return A boolean indicating if the receiveWithAuthorization function is upgraded
    function isReceiveWithAuthorizationUpgraded() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isReceiveWithAuthorizationUpgraded();
    }

    /// @notice The ```isBridgingPaused``` function returns a boolean indicating if bridging is paused
    /// @return A boolean indicating if bridging is paused
    function isBridgingPaused() external view returns (bool) {
        return StorageLib.sloadImplementationSlotDataAsUint256().isBridgingPaused();
    }

    /// @notice The ```implementation``` function returns the address of the implementation contract
    /// @return The address of the implementation contract
    function implementation() external view returns (address) {
        return StorageLib.sloadImplementationSlotDataAsUint256().implementation();
    }

    //==============================================================================
    // External View Functions: StorageLib Proxy Storage Bitmasks
    //==============================================================================

    /// @notice The ```IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_;
    }

    /// @notice The ```IS_TRANSFER_PAUSED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_MINT_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_MINT_PAUSED_BIT_POSITION_;
    }

    /// @notice The ```IS_BURN_FROM_PAUSED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_BURN_FROM_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_BURN_FROM_PAUSED_BIT_POSITION_;
    }

    /// @notice The ```IS_FREEZING_PAUSED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_FREEZING_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_FREEZING_PAUSED_BIT_POSITION_;
    }

    /// @notice The ```IS_TRANSFER_PAUSED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_TRANSFER_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_PAUSED_BIT_POSITION_;
    }

    /// @notice The ```IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION_;
    }

    /// @notice The ```IS_MINT_UPGRADED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_TRANSFER_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_UPGRADED_BIT_POSITION_;
    }

    /// @notice The ```IS_TRANSFER_FROM_UPGRADED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_TRANSFER_FROM_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_;
    }

    /// @notice The ```IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_;
    }

    /// @notice The ```IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION``` function returns a uint256 with a single bit flipped which indicates the bit position
    /// @return A uint256 with a single bit flipped to 1
    function IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256) {
        return StorageLib.IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_;
    }

    //==============================================================================
    // Version Functions
    //==============================================================================

    /// @notice The ```Version``` struct is used to represent the version of the AgoraDollar
    /// @param major The major version number
    /// @param minor The minor version number
    /// @param patch The patch version number
    struct Version {
        uint256 major;
        uint256 minor;
        uint256 patch;
    }

    /// @notice The ```version``` function returns the version of the AgoraDollar
    /// @return _version The version of the AgoraDollar
    function version() public pure returns (Version memory _version) {
        _version = Version({ major: 2, minor: 1, patch: 0 });
    }
}
