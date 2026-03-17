// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IEip3009 {
    error AccountIsFrozen(address frozenAccount);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidSpender(address spender);
    error ExpiredAuthorization();
    error InvalidAuthorization();
    error InvalidPayee(address caller, address payee);
    error InvalidSignature();
    error StringTooLong(string str);
    error UsedOrCanceledAuthorization();

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
