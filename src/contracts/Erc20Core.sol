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
// ============================ Erc20Core =============================
// ====================================================================

import { IERC20Errors as IErc20Errors } from "@openzeppelin/contracts/interfaces/draft-IErc6093.sol";
import { SafeCastLib } from "solady/src/utils/SafeCastLib.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @notice The ```Erc20Core``` contract is a base contract for the Erc20 standard
/// @title Erc20Core
/// @author Agora
abstract contract Erc20Core is IErc20Errors {
    using StorageLib for uint256;
    using SafeCastLib for uint256;

    //==============================================================================
    // Internal Procedural Functions
    //==============================================================================

    /// The ```_approve``` function is used to approve a spender to spend a certain amount of tokens on behalf of the caller
    /// @dev This function reverts on failure
    /// @param _spender The address of the spender
    /// @param _value The amount of tokens to approve for spending
    function _approve(address _owner, address _spender, uint256 _value) internal {
        StorageLib.getPointerToErc20CoreStorage().accountAllowances[_owner][_spender] = _value;
        emit Approval({ owner: _owner, spender: _spender, value: _value });
    }

    /// @notice The ```_transfer``` function transfers tokens which belong to the caller
    /// @dev This function reverts on failure
    /// @param _to The address of the recipient
    /// @param _transferValue The amount of tokens to transfer
    function _transfer(address _from, address _to, uint248 _transferValue) internal {
        // Checks: Ensure _from address is not frozen
        StorageLib.Erc20AccountData memory _accountDataFrom = StorageLib.getPointerToErc20CoreStorage().accountData[
            _from
        ];
        if (_accountDataFrom.isFrozen) revert AccountIsFrozen({ frozenAccount: _from });

        // Checks: Ensure _from has enough balance
        if (_accountDataFrom.balance < _transferValue)
            revert ERC20InsufficientBalance({
                sender: _from,
                balance: _accountDataFrom.balance,
                needed: _transferValue
            });

        // Effects: update balances on the _from account
        unchecked {
            // Underflow not possible: _transferValue <= fromBalance asserted above
            StorageLib.getPointerToErc20CoreStorage().accountData[_from].balance =
                _accountDataFrom.balance -
                _transferValue;
        }

        // NOTE: typically checks are done before effects, but in this case we need to handle the case where _to == _from and so we want to read the latest values
        // Checks: Ensure _to address is not frozen
        StorageLib.Erc20AccountData memory _accountDataTo = StorageLib.getPointerToErc20CoreStorage().accountData[_to];
        if (_accountDataTo.isFrozen) revert AccountIsFrozen({ frozenAccount: _to });

        // Effects: update balances on the _to account
        unchecked {
            // Overflow not possible: _transferValue + toBalance <= (2^248 -1) x 10^-6 [more money than atoms in the galaxy]
            StorageLib.getPointerToErc20CoreStorage().accountData[_to].balance =
                _accountDataTo.balance +
                _transferValue;
        }

        emit Transfer({ from: _from, to: _to, value: _transferValue });
    }

    /// @notice The ```_spendAllowance``` function decrements a spenders allowance
    /// @dev Treats type(uint256).max as infinite allowance and does not update balance
    /// @param _owner The address of the owner
    /// @param _spender The address of the spender
    /// @param _value The amount of allowance to decrement
    function _spendAllowance(address _owner, address _spender, uint256 _value) internal {
        uint256 _currentAllowance = StorageLib.getPointerToErc20CoreStorage().accountAllowances[_owner][_spender];

        // We treat uint256.max as infinite allowance, so we don't need to read/write storage in that case
        if (_currentAllowance != type(uint256).max) {
            if (_currentAllowance < _value)
                revert ERC20InsufficientAllowance({ spender: _spender, allowance: _currentAllowance, needed: _value });
            unchecked {
                StorageLib.getPointerToErc20CoreStorage().accountAllowances[_owner][_spender] =
                    _currentAllowance -
                    _value;
            }
        }
    }

    //==============================================================================
    // Events
    //==============================================================================

    /// @notice The ```Transfer``` event is emitted when tokens are transferred from one account to another
    /// @param from The account that is transferring tokens
    /// @param to The account that is receiving tokens
    /// @param value The amount of tokens being transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice ```Approval``` emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}
    /// @param owner The account that is allowing the spender to spend
    /// @param spender The account that is allowed to spend
    /// @param value The amount of funds that the spender is allowed to spend
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice ```AccountIsFrozen``` error is emitted when an account is frozen and a transfer is attempted
    /// @param frozenAccount The account that is frozen
    error AccountIsFrozen(address frozenAccount);
}
