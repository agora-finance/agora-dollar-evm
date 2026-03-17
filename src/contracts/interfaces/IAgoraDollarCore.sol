// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

library AgoraDollarMintRateLimit {
    struct MintRateLimitConfig {
        address minter;
        uint256 limit;
        uint256 window;
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
    struct RateLimit {
        uint256 amountInFlight;
        uint256 lastUpdated;
        uint256 limit;
        uint256 window;
    }
}

interface IAgoraDollarCore {
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
        address initialRateLimitManagerAddress;
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
    error InvalidSignature();
    error MintPaused();
    error NotInitializing();
    error RateLimitExceeded();
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
    event Burned(address indexed sender, address indexed burnFrom, uint256 value);
    event Initialized(uint64 version);
    event MintRateLimitChanged(AgoraDollarMintRateLimit.MintRateLimitConfig rateLimitConfig);
    event Minted(address indexed sender, address indexed receiver, uint256 value);
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
    function DOMAIN_SEPARATOR() external view returns (bytes32 _domainSeparator);
    function FREEZER_ROLE() external view returns (string memory);
    function MINTER_ROLE() external view returns (string memory);
    function PAUSER_ROLE() external view returns (string memory);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function RATE_LIMIT_MANAGER_ROLE() external view returns (string memory);
    function approve(address _spender, uint256 _value) external returns (bool);
    function batchBurnFrom(Erc20Privileged.BatchBurnFromParam[] memory _burns) external;
    function batchFreeze(address[] memory _addresses) external;
    function batchMint(Erc20Privileged.BatchMintParam[] memory _mints) external;
    function batchUnfreeze(address[] memory _addresses) external;
    function burn(address _from, uint256 _amount) external returns (bool);
    function cancelAuthorization(address _authorizer, bytes32 _nonce, uint8 _v, bytes32 _r, bytes32 _s) external;
    function cancelAuthorization(address _authorizer, bytes32 _nonce, bytes memory _signature) external;
    function decimals() external view returns (uint8);
    function getAccessControlManagerRoleMembers() external view returns (address[] memory);
    function getAllRoles() external view returns (string[] memory _roles);
    function getAmountCanBeMinted(
        address _minter
    ) external view returns (uint256 currentAmountInFlight, uint256 amountCanBeMinted);
    function getMintRateLimit(address _minter) external view returns (StorageLib.RateLimit memory);
    function getRoleMembers(string memory _role) external view returns (address[] memory);
    function grantAccessControlManagerRole(address _member) external;
    function grantBridgeBurnerRole(address _member) external;
    function grantBridgeMinterRole(address _member) external;
    function grantBurnerRole(address _member) external;
    function grantFreezerRole(address _member) external;
    function grantMinterRole(address _member) external;
    function grantPauserRole(address _member) external;
    function grantRateLimitManagerRole(address _member) external;
    function hasRole(string memory _role, address _member) external view returns (bool);
    function initialize(InitializeParams memory _params) external;
    function mint(address _to, uint256 _amount) external returns (bool);
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
    function revokeRateLimitManagerRole(address _member) external;
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
    function setMintRateLimit(AgoraDollarMintRateLimit.MintRateLimitConfig memory _rateLimitConfig) external;
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
}
