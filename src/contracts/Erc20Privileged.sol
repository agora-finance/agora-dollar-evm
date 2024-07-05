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
// ========================= Erc20Privileged ==========================
// ====================================================================

import { SafeCastLib } from "solady/src/utils/SafeCastLib.sol";

import { AgoraDollarAccessControl } from "./AgoraDollarAccessControl.sol";
import { Erc20Core } from "./Erc20Core.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @notice The ```Erc20Privileged``` contract extends the ```Erc20Core``` contract with privileged actions (mint, burn, freeze)
abstract contract Erc20Privileged is Erc20Core, AgoraDollarAccessControl {
    using SafeCastLib for uint256;
    using StorageLib for uint256;

    //==============================================================================
    // Mint Functions
    //==============================================================================

    /// @notice Parameters for a single mint operation
    /// @param receiverAddress The address to mint tokens to
    /// @param value The amount of tokens to mint
    struct BatchMintParam {
        address receiverAddress;
        uint256 value;
    }

    /// @notice The ```batchMint``` function mints tokens to multiple accounts in a single transaction
    /// @dev This function must be called by an address to which the MINTER_ROLE is granted
    /// @dev Reverts on failure
    /// @param _mints An array of ```BatchMintParam``` structs
    function batchMint(BatchMintParam[] memory _mints) external {
        // Checks: sender must be minter
        _requireSenderIsRole({ _role: MINTER_ROLE });

        // Checks: minting must not be paused
        if (StorageLib.sloadImplementationSlotDataAsUint256().isMintPaused()) revert StorageLib.MintPaused();

        // Effects: add to totalSupply and account balances
        for (uint256 i = 0; i < _mints.length; i++) {
            // Checks: account cannot be 0 address
            if (_mints[i].receiverAddress == address(0)) revert ERC20InvalidReceiver({ receiver: address(0) });

            // Effects: add to totalSupply and account balance
            uint248 _value248 = _mints[i].value.toUint248();
            StorageLib.getPointerToErc20CoreStorage().totalSupply += _value248;
            StorageLib.getPointerToErc20CoreStorage().accountData[_mints[i].receiverAddress].balance += _value248;

            // Emit event
            emit Transfer({ from: address(0), to: _mints[i].receiverAddress, value: _mints[i].value });
            emit Minted({ receiver: _mints[i].receiverAddress, value: _mints[i].value });
        }
    }

    //==============================================================================
    // Burn Functions
    //==============================================================================

    /// @notice Parameters for a single burn operation
    /// @param burnFromAddress The address to burn tokens from
    /// @param value The amount of tokens to burn
    struct BatchBurnFromParam {
        address burnFromAddress;
        uint256 value;
    }

    /// @notice The ```batchBurnFrom``` function burns tokens from multiple accounts in a single transaction
    /// @dev This function must be called by an address to which the BURNER_ROLE is granted
    /// @dev Reverts on failure
    /// @param _burns An array of ```BatchBurnFromParam``` structs
    function batchBurnFrom(BatchBurnFromParam[] memory _burns) external {
        // Checks: sender must be burner
        _requireSenderIsRole({ _role: BURNER_ROLE });

        // Checks: burnFrom must not be paused
        if (StorageLib.sloadImplementationSlotDataAsUint256().isBurnFromPaused()) revert StorageLib.BurnFromPaused();

        for (uint256 i = 0; i < _burns.length; i++) {
            // Effects: subtract from totalSupply and account balance
            uint248 _value248 = _burns[i].value.toUint248();
            StorageLib.getPointerToErc20CoreStorage().totalSupply -= _value248;
            StorageLib.getPointerToErc20CoreStorage().accountData[_burns[i].burnFromAddress].balance -= _value248;

            // emit event (include Burned event to prevent spoofing of Transfer event as we don't check for 0 address in transfer)
            emit Transfer({ from: _burns[i].burnFromAddress, to: address(0), value: _burns[i].value });
            emit Burned({ burnFrom: _burns[i].burnFromAddress, value: _burns[i].value });
        }
    }

    //==============================================================================
    // Freeze Functions
    //==============================================================================

    /// @notice The ```freeze``` function freezes an account so that it cannot transfer tokens
    /// @param _account The account to freeze
    function freeze(address _account) external {
        _requireSenderIsRole({ _role: FREEZER_ROLE });
        if (StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused()) revert StorageLib.FreezingPaused();

        StorageLib.getPointerToErc20CoreStorage().accountData[_account].isFrozen = true;
        emit AccountFrozen({ account: _account });
    }

    /// @notice The ```unfreeze``` function unfreezes an account so that it can transfer tokens again
    /// @param _account The account to unfreeze
    function unfreeze(address _account) external {
        _requireSenderIsRole({ _role: FREEZER_ROLE });
        if (StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused()) revert StorageLib.FreezingPaused();

        StorageLib.getPointerToErc20CoreStorage().accountData[_account].isFrozen = false;
        emit AccountUnfrozen({ account: _account });
    }

    //==============================================================================
    // Events
    //==============================================================================

    /// @notice The ```AccountUnfrozen``` event is emitted when an account is unfrozen
    /// @param account The account that was unfrozen
    event AccountUnfrozen(address indexed account);

    /// @notice The ```AccountFrozen``` event is emitted when an account is frozen
    /// @param account The account that was frozen
    event AccountFrozen(address indexed account);

    /// @notice The ```Minted``` event is emitted when tokens are minted
    /// @param receiver The account that received the minted tokens
    /// @param value The amount of tokens minted
    event Minted(address indexed receiver, uint256 value);

    /// @notice The ```Burned``` event is emitted when tokens are burned
    /// @param burnFrom The account that burned the tokens
    /// @param value The amount of tokens burned
    event Burned(address indexed burnFrom, uint256 value);
}
