// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

// solhint-disable func-name-mixedcase
// ====================================================================
//             _        ______     ___   _______          _
//            / \     .' ___  |  .'   `.|_   __ \        / \
//           / _ \   / .'   \_| /  .-.  \ | |__) |      / _ \
//          / ___ \  | |   ____ | |   | | |  __ /      / ___ \
//        _/ /   \ \_\ `.___]  |\  `-'  /_| |  \ \_  _/ /   \ \_
//       |____| |____|`._____.'  `.___.'|____| |___||____| |____|
// ====================================================================
// ========================= AgoraDollarCore ==========================
// ====================================================================

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ShortString, ShortStrings } from "@openzeppelin/contracts/utils/ShortStrings.sol";

import { Eip3009 } from "./Eip3009.sol";
import { Eip712 } from "./Eip712.sol";
import { Erc20Privileged } from "./Erc20Privileged.sol";
import { Erc2612 } from "./Erc2612.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

struct ConstructorParams {
    string name;
    string symbol;
    string eip712Name;
    string eip712Version;
}

contract AgoraDollarCore is Initializable, Eip3009, Erc2612, Erc20Privileged {
    using StorageLib for uint256;
    using ShortStrings for *;

    ShortString internal immutable _name;

    ShortString internal immutable _symbol;

    uint8 public immutable decimals = 6;

    constructor(ConstructorParams memory _params) Eip712(_params.eip712Name, _params.eip712Version) {
        _name = _params.name.toShortString();
        _symbol = _params.symbol.toShortString();

        // Prevent implementation from being initialized
        _disableInitializers();
    }

    struct InitializeParams {
        address initialAdminAddress;
    }

    function initialize(InitializeParams memory _initializeParams) external reinitializer(1) {
        _initializeAgoraDollarAccessControl({ _initialAdminAddress: _initializeParams.initialAdminAddress });
    }

    //==============================================================================
    // External stateful Functions: Erc20
    //==============================================================================

    function approve(address _spender, uint256 _value) external returns (bool) {
        _approve({ _owner: msg.sender, _spender: _spender, _value: _value });
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

    //==============================================================================
    // External Stateful Functions: Erc3009
    //==============================================================================

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
    ) external {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

    function transferWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) public {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

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
    ) external {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

    function receiveWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) public {
        // NOTE: implemented in proxy, here to check for signature collisions
    }

    function cancelAuthorization(address _authorizer, bytes32 _nonce, uint8 _v, bytes32 _r, bytes32 _s) external {
        cancelAuthorization({ _authorizer: _authorizer, _nonce: _nonce, _signature: abi.encodePacked(_r, _s, _v) });
    }

    function cancelAuthorization(address _authorizer, bytes32 _nonce, bytes memory _signature) public {
        // Effects: mark the signature as used
        _cancelAuthorization({ _authorizer: _authorizer, _nonce: _nonce, _signature: _signature });
    }

    //==============================================================================
    // ContractDataSetters Functions
    //==============================================================================

    function setIsMsgSenderCheckEnabled(bool _isEnabled) external {
        _requireSenderIsRole({ _role: ADMIN_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_,
            _setBitToOne: _isEnabled
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsMsgSenderCheckEnabled({ isEnabled: _isEnabled });
    }

    function setIsMintPaused(bool _isPaused) external {
        _requireSenderIsRole({ _role: PAUSER_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_MINT_PAUSED_BIT_POSITION_,
            _setBitToOne: _isPaused
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsMintPaused({ isPaused: _isPaused });
    }

    function setIsBurnFromPaused(bool _isPaused) external {
        _requireSenderIsRole({ _role: PAUSER_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_BURN_FROM_PAUSED_BIT_POSITION_,
            _setBitToOne: _isPaused
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsBurnFromPaused({ isPaused: _isPaused });
    }

    function setIsFreezingPaused(bool _isPaused) external {
        _requireSenderIsRole({ _role: PAUSER_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_FREEZING_PAUSED_BIT_POSITION_,
            _setBitToOne: _isPaused
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsFreezingPaused({ isPaused: _isPaused });
    }

    function setIsTransferPaused(bool _isPaused) external {
        _requireSenderIsRole({ _role: PAUSER_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_TRANSFER_PAUSED_BIT_POSITION_,
            _setBitToOne: _isPaused
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsTransferPaused({ isPaused: _isPaused });
    }

    function setIsSignatureVerificationPaused(bool _isPaused) external {
        _requireSenderIsRole({ _role: PAUSER_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION_,
            _setBitToOne: _isPaused
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsSignatureVerificationPaused({ isPaused: _isPaused });
    }

    function setIsTransferUpgraded(bool _isUpgraded) external {
        _requireSenderIsRole({ _role: ADMIN_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_TRANSFER_UPGRADED_BIT_POSITION_,
            _setBitToOne: _isUpgraded
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsTransferUpgraded({ isUpgraded: _isUpgraded });
    }

    function setIsTransferFromUpgraded(bool _isUpgraded) external {
        _requireSenderIsRole({ _role: ADMIN_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_,
            _setBitToOne: _isUpgraded
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsTransferFromUpgraded({ isUpgraded: _isUpgraded });
    }

    function setIsTransferWithAuthorizationUpgraded(bool _isUpgraded) external {
        _requireSenderIsRole({ _role: ADMIN_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_,
            _setBitToOne: _isUpgraded
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsTransferWithAuthorizationUpgraded({ isUpgraded: _isUpgraded });
    }

    function setIsReceiveWithAuthorizationUpgraded(bool _isUpgraded) external {
        _requireSenderIsRole({ _role: ADMIN_ROLE });
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        uint256 _newContractData = _contractData.setBitWithMask({
            _bitToSet: StorageLib.IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_,
            _setBitToOne: _isUpgraded
        });
        _newContractData.sstoreImplementationSlotDataAsUint256();
        emit SetIsReceiveWithAuthorizationUpgraded({ isUpgraded: _isUpgraded });
    }

    //==============================================================================
    // Events
    //==============================================================================
    /// @notice The ```SetIsMsgSenderCheckEnabled``` event is emitted when the isMsgSenderCheckEnabled state variable is updated
    /// @param isEnabled The new value of the isMsgSenderCheckEnabled state variable
    event SetIsMsgSenderCheckEnabled(bool isEnabled);

    /// @notice The ```SetIsMintPaused``` event is emitted when the isMintPaused state variable is updated
    /// @param isPaused The new value of the isMintPaused state variable
    event SetIsMintPaused(bool isPaused);

    /// @notice The ```SetIsBurnFromPaused``` event is emitted when the isBurnFromPaused state variable is updated
    /// @param isPaused The new value of the isBurnFromPaused state variable
    event SetIsBurnFromPaused(bool isPaused);

    /// @notice The ```SetIsFreezingPaused``` event is emitted when the isFreezingPaused state variable is updated
    /// @param isPaused The new value of the isFreezingPaused state variable
    event SetIsFreezingPaused(bool isPaused);

    /// @notice The ```SetIsTransferPaused``` event is emitted when the isTransferPaused state variable is updated
    /// @param isPaused The new value of the isTransferPaused state variable
    event SetIsTransferPaused(bool isPaused);

    /// @notice The ```SetIsSignatureVerificationPaused``` event is emitted when the isSignatureVerificationPaused state variable is updated
    /// @param isPaused The new value of the isSignatureVerificationPaused state variable
    event SetIsSignatureVerificationPaused(bool isPaused);

    /// @notice The ```SetIsTransferUpgraded``` event is emitted when the isTransferUpgraded state variable is updated
    /// @param isUpgraded The new value of the isTransferUpgraded state variable
    event SetIsTransferUpgraded(bool isUpgraded);

    /// @notice The ```SetIsTransferFromUpgraded``` event is emitted when the isTransferFromUpgraded state variable is updated
    /// @param isUpgraded The new value of the isTransferFromUpgraded state variable
    event SetIsTransferFromUpgraded(bool isUpgraded);

    /// @notice The ```SetIsTransferWithAuthorizationUpgraded``` event is emitted when the isTransferWithAuthorizationUpgraded state variable is updated
    /// @param isUpgraded The new value of the isTransferWithAuthorizationUpgraded state variable
    event SetIsTransferWithAuthorizationUpgraded(bool isUpgraded);

    /// @notice The ```SetIsReceiveWithAuthorizationUpgraded``` event is emitted when the isReceiveWithAuthorizationUpgraded state variable is updated
    /// @param isUpgraded The new value of the isReceiveWithAuthorizationUpgraded state variable
    event SetIsReceiveWithAuthorizationUpgraded(bool isUpgraded);
}
