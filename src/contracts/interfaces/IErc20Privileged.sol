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

interface IErc20Privileged {
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
    error FreezingPaused();
    error MintPaused();
    error RateLimitExceeded();
    error RoleDoesNotExist(string role);
    error RoleNameTooLong();
    error ZeroAmount();

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burned(address indexed sender, address indexed burnFrom, uint256 value);
    event MintRateLimitChanged(AgoraDollarMintRateLimit.MintRateLimitConfig rateLimitConfig);
    event Minted(address indexed sender, address indexed receiver, uint256 value);
    event RoleAssigned(string indexed role, address indexed member);
    event RoleRevoked(string indexed role, address indexed member);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function ACCESS_CONTROL_MANAGER_ROLE() external view returns (string memory);
    function AGORA_ACCESS_CONTROL_STORAGE_SLOT() external view returns (bytes32);
    function BRIDGE_BURNER_ROLE() external view returns (string memory);
    function BRIDGE_MINTER_ROLE() external view returns (string memory);
    function BURNER_ROLE() external view returns (string memory);
    function FREEZER_ROLE() external view returns (string memory);
    function MINTER_ROLE() external view returns (string memory);
    function PAUSER_ROLE() external view returns (string memory);
    function RATE_LIMIT_MANAGER_ROLE() external view returns (string memory);
    function batchBurnFrom(Erc20Privileged.BatchBurnFromParam[] memory _burns) external;
    function batchFreeze(address[] memory _addresses) external;
    function batchMint(Erc20Privileged.BatchMintParam[] memory _mints) external;
    function batchUnfreeze(address[] memory _addresses) external;
    function burn(address _from, uint256 _amount) external returns (bool);
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
    function mint(address _to, uint256 _amount) external returns (bool);
    function revokeAccessControlManagerRole(address _member) external;
    function revokeBridgeBurnerRole(address _member) external;
    function revokeBridgeMinterRole(address _member) external;
    function revokeBurnerRole(address _member) external;
    function revokeFreezerRole(address _member) external;
    function revokeMinterRole(address _member) external;
    function revokePauserRole(address _member) external;
    function revokeRateLimitManagerRole(address _member) external;
    function setMintRateLimit(AgoraDollarMintRateLimit.MintRateLimitConfig memory _rateLimitConfig) external;
}
