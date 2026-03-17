// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IErc2612 {
    error AccountIsFrozen(address frozenAccount);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidSpender(address spender);
    error Erc2612ExpiredSignature(uint256 deadline);
    error Erc2612InvalidSignature();
    error SignatureVerificationPaused();
    error StringTooLong(string str);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function DOMAIN_SEPARATOR() external view returns (bytes32 _domainSeparator);
    function PERMIT_TYPEHASH() external view returns (bytes32);
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
}
