// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import { IAgoraDollarErc1967Proxy } from "./IAgoraDollarErc1967Proxy.sol";
import { ITransparentUpgradeableProxy } from "./ITransparentUpgradeableProxy.sol";

interface IAgoraDollar is IAgoraDollarErc1967Proxy, ITransparentUpgradeableProxy {
    struct AgoraDollarAccessControlRoleData {
        address pendingRoleAddress;
        address currentRoleAddress;
    }

    struct BatchBurnFromParam {
        address burnFromAddress;
        uint256 value;
    }

    struct BatchMintParam {
        address receiverAddress;
        uint256 value;
    }

    struct ConstructorParams {
        string name;
        string symbol;
        string eip712Name;
        string eip712Version;
    }

    struct Erc20AccountData {
        bool isFrozen;
        uint248 balance;
    }

    struct InitializeParams {
        address initialAdminAddress;
    }

    error AccountIsFrozen(address frozenAccount);
    error AddressIsNotPendingRole(bytes32 role);
    error AddressIsNotRole(bytes32 role);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidSpender(address spender);
    error Erc2612ExpiredSignature(uint256 deadline);
    error Erc2612InvalidSignature();
    error ExpiredAuthorization();
    error FreezingPaused();
    error InvalidAuthorization();
    error InvalidInitialization();
    error InvalidPayee(address caller, address payee);
    error InvalidShortString();
    error InvalidSignature();
    error MintPaused();
    error NotInitializing();
    error SignatureVerificationPaused();
    error StringTooLong(string str);
    error UsedOrCanceledAuthorization();

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event Burned(address indexed burnFrom, uint256 value);
    event Initialized(uint64 version);
    event Minted(address indexed receiver, uint256 value);
    event RoleTransferStarted(bytes32 role, address indexed previousAddress, address indexed newAddress);
    event RoleTransferred(bytes32 role, address indexed previousAddress, address indexed newAddress);
    event SetIsFreezingPaused(bool isPaused);
    event SetIsMintPaused(bool isPaused);
    event SetIsMsgSenderCheckEnabled(bool isEnabled);
    event SetIsReceiveWithAuthorizationUpgraded(bool isUpgraded);
    event SetIsSignatureVerificationPaused(bool isPaused);
    event SetIsTransferFromUpgraded(bool isUpgraded);
    event SetIsTransferPaused(bool isPaused);
    event SetIsTransferUpgraded(bool isUpgraded);
    event SetIsTransferWithAuthorizationUpgraded(bool isUpgraded);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function ADMIN_ROLE() external view returns (bytes32);
    function BURNER_ROLE() external view returns (bytes32);
    function CANCEL_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32 _domainSeparator);
    function ERC20_CORE_STORAGE_SLOT() external pure returns (bytes32);
    function ERC2612_STORAGE_SLOT() external pure returns (bytes32);
    function FREEZER_ROLE() external view returns (bytes32);
    function IS_FREEZING_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_MINT_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION() external pure returns (uint256);
    function IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_FROM_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function MINTER_ROLE() external view returns (bytes32);
    function PAUSER_ROLE() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function acceptTransferRole(bytes32 _role) external;
    function accountData(address _account) external view returns (Erc20AccountData memory);
    function adminAddress() external view returns (address);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function authorizationState(address _authorizer, bytes32 _nonce) external view returns (bool _isNonceUsed);
    function balanceOf(address _account) external view returns (uint256);
    function batchBurnFrom(BatchBurnFromParam[] memory _burns) external;
    function batchMint(BatchMintParam[] memory _mints) external;
    function burnerAddress() external view returns (address);
    function cancelAuthorization(address _authorizer, bytes32 _nonce, uint8 _v, bytes32 _r, bytes32 _s) external;
    function cancelAuthorization(address _authorizer, bytes32 _nonce, bytes memory _signature) external;
    function decimals() external view returns (uint8);
    function domainSeparatorV4() external view returns (bytes32);
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
        );
    function freeze(address _account) external;
    function freezerAddress() external view returns (address);
    function getRoleData(bytes32 _roleId) external view returns (AgoraDollarAccessControlRoleData memory);
    function hashTypedDataV4(bytes32 _structHash) external view returns (bytes32);
    function implementation() external view returns (address);
    function initialize(InitializeParams memory _initializeParams) external;
    function isAccountFrozen(address _account) external view returns (bool);
    function isFreezingPaused() external view returns (bool);
    function isMintPaused() external view returns (bool);
    function isMsgSenderFrozenCheckEnabled() external view returns (bool);
    function isSignatureVerificationPaused() external view returns (bool);
    function isTransferFromUpgraded() external view returns (bool);
    function isTransferPaused() external view returns (bool);
    function isTransferUpgraded() external view returns (bool);
    function isTransferWithAuthorizationUpgraded() external view returns (bool);
    function minterAddress() external view returns (address);
    function name() external view returns (string memory);
    function nonces(address _account) external view returns (uint256 _nonce);
    function pauserAddress() external view returns (address);
    function pendingAdminAddress() external view returns (address);
    function pendingBurnerAddress() external view returns (address);
    function pendingFreezerAddress() external view returns (address);
    function pendingMinterAddress() external view returns (address);
    function pendingPauserAddress() external view returns (address);
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        bytes memory _signature
    ) external;
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;
    function proxyAdminAddress() external view returns (address);
    function receiveWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) external;
    function receiveWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;
    function setIsFreezingPaused(bool _isPaused) external;
    function setIsMintPaused(bool _isPaused) external;
    function setIsMsgSenderCheckEnabled(bool _isEnabled) external;
    function setIsReceiveWithAuthorizationUpgraded(bool _isUpgraded) external;
    function setIsSignatureVerificationPaused(bool _isPaused) external;
    function setIsTransferFromUpgraded(bool _isUpgraded) external;
    function setIsTransferPaused(bool _isPaused) external;
    function setIsTransferUpgraded(bool _isUpgraded) external;
    function setIsTransferWithAuthorizationUpgraded(bool _isUpgraded) external;
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function transferRole(bytes32 _role, address _newAddress) external;
    function transferWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) external;
    function transferWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;
    function unfreeze(address _account) external;
}
