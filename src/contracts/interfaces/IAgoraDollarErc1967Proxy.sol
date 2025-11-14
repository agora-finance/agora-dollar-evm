// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IAgoraDollarErc1967Proxy {
    struct ConstructorParams {
        address proxyAdminOwnerAddress;
        string eip712Name;
        string eip712Version;
    }

    error AccountIsFrozen(address frozenAccount);
    error AddressEmptyCode(address target);
    error AgoraDollarErc1967NonPayable();
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidSpender(address spender);
    error ExpiredAuthorization();
    error FailedInnerCall();
    error ImplementationTargetNotAContract();
    error InvalidAuthorization();
    error InvalidPayee(address caller, address payee);
    error InvalidSignature();
    error ProxyDeniedAdminAccess();
    error SignatureVerificationPaused();
    error StringTooLong(string str);
    error TransferPaused();
    error UsedOrCanceledAuthorization();

    event AdminChanged(address previousAdmin, address newAdmin);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Upgraded(address indexed implementation);

    fallback() external payable;

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
    function transfer(address _to, uint256 _transferValue) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _transferValue) external returns (bool);
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
