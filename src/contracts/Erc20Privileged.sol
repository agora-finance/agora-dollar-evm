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
            _mint({ _account: _mints[i].receiverAddress, _amount: _mints[i].value });
        }
    }

    /// @notice The ```mint``` function mints tokens to an account. It is part of IMintableBurnable
    /// @dev This function must be called by an address with `MINTER_ROLE` or `BRIDGE_MINTER_ROLE`
    /// @dev Reverts on failure
    /// @param _to An address to mint to
    /// @param _amount The amount of tokens to mint
    /// @dev Note, this allows minting to frozen accounts. This is to allow bridge contracts to mint to frozen accounts if needed.
    function mint(address _to, uint256 _amount) external returns (bool) {
        // Checks: sender must be `BRIDGE_MINTER_ROLE` or `MINTER_ROLE`
        if (
            !_isRole({ _role: BRIDGE_MINTER_ROLE, _member: msg.sender }) &&
            !_isRole({ _role: MINTER_ROLE, _member: msg.sender })
        ) revert AddressIsNotMinterRole();

        // Checks: minting must not be paused
        if (StorageLib.sloadImplementationSlotDataAsUint256().isMintPaused()) revert StorageLib.MintPaused();

        // Checks: bridging must not be paused
        if (
            _isRole({ _role: BRIDGE_MINTER_ROLE, _member: msg.sender }) &&
            StorageLib.sloadImplementationSlotDataAsUint256().isBridgingPaused()
        ) revert StorageLib.BridgingPaused();

        _mint({ _account: _to, _amount: _amount });

        return true;
    }

    function _mint(address _account, uint256 _amount) internal {
        // Checks: account cannot be 0 address
        if (_account == address(0)) revert ERC20InvalidReceiver({ receiver: address(0) });

        uint248 _value248 = _amount.toUint248();

        // Checks: amount cannot be zero
        if (_value248 == 0) revert ZeroAmount();

        // Effects: add to totalSupply and account balance
        StorageLib.getPointerToErc20CoreStorage().totalSupply += _value248;
        StorageLib.getPointerToErc20CoreStorage().accountData[_account].balance += _value248;

        // Emit event
        emit Transfer({ from: address(0), to: _account, value: _amount });
        emit Minted({ receiver: _account, value: _amount });
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
            _burn({ _account: _burns[i].burnFromAddress, _amount: _burns[i].value });
        }
    }

    /// @notice The ```burn``` function burns tokens from an account. It is part of IMintableBurnable
    /// @dev This function must be called by an address with `BURNER_ROLE` or `BRIDGE_BURNER_ROLE`
    /// @dev Reverts on failure
    /// @param _from An address to burn from
    /// @param _amount Amount of tokens to burn
    function burn(address _from, uint256 _amount) external returns (bool) {
        // Checks: sender must be `BRIDGE_BURNER_ROLE` or `BURNER_ROLE`
        if (
            !_isRole({ _role: BRIDGE_BURNER_ROLE, _member: msg.sender }) &&
            !_isRole({ _role: BURNER_ROLE, _member: msg.sender })
        ) revert AddressIsNotBurnerRole();

        // Checks: burnFrom must not be paused
        if (StorageLib.sloadImplementationSlotDataAsUint256().isBurnFromPaused()) revert StorageLib.BurnFromPaused();

        if (_isRole({ _role: BRIDGE_BURNER_ROLE, _member: msg.sender })) {
            // Checks: bridging must not be paused
            if (StorageLib.sloadImplementationSlotDataAsUint256().isBridgingPaused())
                revert StorageLib.BridgingPaused();
            // Checks: _from account must not be frozen
            StorageLib.Erc20AccountData memory _accountDataFrom = StorageLib.getPointerToErc20CoreStorage().accountData[
                _from
            ];
            if (_accountDataFrom.isFrozen) revert AccountIsFrozen({ frozenAccount: _from });
        }

        _burn({ _account: _from, _amount: _amount });

        return true;
    }

    function _burn(address _account, uint256 _amount) internal {
        uint248 _value248 = _amount.toUint248();

        // Checks: amount cannot be zero
        if (_value248 == 0) revert ZeroAmount();

        // Checks: ensure _account has enough balance
        StorageLib.Erc20AccountData memory _accountDataFrom = StorageLib.getPointerToErc20CoreStorage().accountData[
            _account
        ];
        if (_accountDataFrom.balance < _value248)
            revert ERC20InsufficientBalance({ sender: _account, balance: _accountDataFrom.balance, needed: _value248 });

        // Effects: subtract from totalSupply and account balance
        StorageLib.getPointerToErc20CoreStorage().totalSupply -= _value248;
        StorageLib.getPointerToErc20CoreStorage().accountData[_account].balance -= _value248;

        // emit event (include Burned event to prevent spoofing of Transfer event as we don't check for 0 address in transfer)
        emit Transfer({ from: _account, to: address(0), value: _amount });
        emit Burned({ burnFrom: _account, value: _amount });
    }

    //==============================================================================
    // Freeze Functions
    //==============================================================================

    /// @notice The ```batchFreeze``` function freezes a set of accounts so that it cannot transfer tokens
    /// @param _addresses The addresses of the accounts getting frozen
    function batchFreeze(address[] memory _addresses) external {
        // Checks: Only the FREEZER_ROLE can freeze addresses
        _requireSenderIsRole({ _role: FREEZER_ROLE });
        if (StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused()) revert StorageLib.FreezingPaused();

        for (uint256 _i = 0; _i < _addresses.length; _i++) {
            // Effects: freeze the addresses
            StorageLib.getPointerToErc20CoreStorage().accountData[_addresses[_i]].isFrozen = true;
            emit AccountFrozen({ account: _addresses[_i] });
        }
    }

    /// @notice The ```batchUnfreeze``` function unfreezes a set of accounts so that it can transfer tokens again
    /// @param _addresses The addresses of the accounts getting unfrozen
    function batchUnfreeze(address[] memory _addresses) external {
        // Checks: Only the FREEZER_ROLE can unfreeze addresses
        _requireSenderIsRole({ _role: FREEZER_ROLE });
        if (StorageLib.sloadImplementationSlotDataAsUint256().isFreezingPaused()) revert StorageLib.FreezingPaused();

        for (uint256 _i = 0; _i < _addresses.length; _i++) {
            // Effects: unfreeze the addresses
            StorageLib.getPointerToErc20CoreStorage().accountData[_addresses[_i]].isFrozen = false;
            emit AccountUnfrozen({ account: _addresses[_i] });
        }
    }

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice Error when an amount is unexpectedly zero.
    error ZeroAmount();

    /// @notice Emitted when the caller of `burn()` does not have the necessary role.
    error AddressIsNotBurnerRole();

    /// @notice Emitted when the caller of `mint()` does not have the necessary role.
    error AddressIsNotMinterRole();

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
