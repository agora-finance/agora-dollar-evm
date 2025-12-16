// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

library AgoraDollar {
    struct Version {
        uint256 major;
        uint256 minor;
        uint256 patch;
    }
}

library Erc20Privileged {
    struct BatchBurnFromParam {
        address burnFromAddress;
        uint256 value;
    }

    struct BatchMintParam {
        address receiverAddress;
        uint256 value;
    }
}

library StorageLib {
    struct Erc20AccountData {
        bool isFrozen;
        uint248 balance;
    }
}

interface IAgoraDollar {
    struct ConstructorParams {
        string name;
        string symbol;
        string eip712Name;
        string eip712Version;
        address proxyAddress;
    }

    struct InitializeParams {
        address initialAdminAddress;
        address initialMinterAddress;
        address initialBurnerAddress;
        address initialPauserAddress;
        address initialFreezerAddress;
    }

    error AccountIsFrozen(address frozenAccount);
    error AddressIsNotBurnerRole();
    error AddressIsNotMinterRole();
    error AddressIsNotRole(string role);
    error BridgingPaused();
    error BurnFromPaused();
    error CannotRemoveRoleWithMembers(string role);
    error CannotRevokeSelf();
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
    error RoleDoesNotExist(string role);
    error RoleNameTooLong();
    error SignatureVerificationPaused();
    error StringTooLong(string str);
    error UsedOrCanceledAuthorization();
    error ZeroAmount();

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event Burned(address indexed burnFrom, uint256 value);
    event Initialized(uint64 version);
    event Minted(address indexed receiver, uint256 value);
    event RoleAssigned(string indexed role, address indexed member);
    event RoleRevoked(string indexed role, address indexed member);
    event SetIsBridgingPaused(bool isPaused);
    event SetIsBurnFromPaused(bool isPaused);
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

    function ACCESS_CONTROL_MANAGER_ROLE() external view returns (string memory);
    function AGORA_ACCESS_CONTROL_STORAGE_SLOT() external view returns (bytes32);
    function BRIDGE_BURNER_ROLE() external view returns (string memory);
    function BRIDGE_MINTER_ROLE() external view returns (string memory);
    function BURNER_ROLE() external view returns (string memory);
    function CANCEL_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32 _domainSeparator);
    function ERC20_CORE_STORAGE_SLOT() external pure returns (bytes32);
    function ERC2612_STORAGE_SLOT() external pure returns (bytes32);
    function FREEZER_ROLE() external view returns (string memory);
    function IS_BURN_FROM_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_FREEZING_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_MINT_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION() external pure returns (uint256);
    function IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_FROM_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_PAUSED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION() external pure returns (uint256);
    function MINTER_ROLE() external view returns (string memory);
    function PAUSER_ROLE() external view returns (string memory);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external pure returns (bytes32);
    function accountData(address _account) external view returns (StorageLib.Erc20AccountData memory);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function authorizationState(address _authorizer, bytes32 _nonce) external view returns (bool _isNonceUsed);
    function balanceOf(address _account) external view returns (uint256);
    function batchBurnFrom(Erc20Privileged.BatchBurnFromParam[] memory _burns) external;
    function batchFreeze(address[] memory _addresses) external;
    function batchMint(Erc20Privileged.BatchMintParam[] memory _mints) external;
    function batchUnfreeze(address[] memory _addresses) external;
    function burn(address _from, uint256 _amount) external returns (bool);
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
    function getAccessControlManagerRoleMembers() external view returns (address[] memory);
    function getAllRoles() external view returns (string[] memory _roles);
    function getBridgeBurnerRoleMembers() external view returns (address[] memory);
    function getBridgeMinterRoleMembers() external view returns (address[] memory);
    function getBurnerRoleMembers() external view returns (address[] memory);
    function getFreezerRoleMembers() external view returns (address[] memory);
    function getMinterRoleMembers() external view returns (address[] memory);
    function getPauserRoleMembers() external view returns (address[] memory);
    function getRoleMembers(string memory _role) external view returns (address[] memory);
    function grantAccessControlManagerRole(address _member) external;
    function grantBridgeBurnerRole(address _member) external;
    function grantBridgeMinterRole(address _member) external;
    function grantBurnerRole(address _member) external;
    function grantFreezerRole(address _member) external;
    function grantMinterRole(address _member) external;
    function grantPauserRole(address _member) external;
    function hasRole(string memory _role, address _member) external view returns (bool);
    function hashTypedDataV4(bytes32 _structHash) external view returns (bytes32);
    function implementation() external view returns (address);
    function initialize(InitializeParams memory _params) external;
    function isAccountFrozen(address _account) external view returns (bool);
    function isBridgingPaused() external view returns (bool);
    function isBurnFromPaused() external view returns (bool);
    function isFreezingPaused() external view returns (bool);
    function isMintPaused() external view returns (bool);
    function isMsgSenderFrozenCheckEnabled() external view returns (bool);
    function isReceiveWithAuthorizationUpgraded() external view returns (bool);
    function isSignatureVerificationPaused() external view returns (bool);
    function isTransferFromUpgraded() external view returns (bool);
    function isTransferPaused() external view returns (bool);
    function isTransferUpgraded() external view returns (bool);
    function isTransferWithAuthorizationUpgraded() external view returns (bool);
    function mint(address _to, uint256 _amount) external returns (bool);
    function name() external view returns (string memory);
    function nonces(address _account) external view returns (uint256 _nonce);
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
    function revokeAccessControlManagerRole(address _member) external;
    function revokeBridgeBurnerRole(address _member) external;
    function revokeBridgeMinterRole(address _member) external;
    function revokeBurnerRole(address _member) external;
    function revokeFreezerRole(address _member) external;
    function revokeMinterRole(address _member) external;
    function revokePauserRole(address _member) external;
    function setIsBridgingPaused(bool _isPaused) external;
    function setIsBurnFromPaused(bool _isPaused) external;
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
    function version() external pure returns (AgoraDollar.Version memory _version);
}
