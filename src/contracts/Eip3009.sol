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
// ============================= Eip3009 ==============================
// ====================================================================

import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { SafeCastLib } from "solady/src/utils/SafeCastLib.sol";
import { SignatureCheckerLib } from "solady/src/utils/SignatureCheckerLib.sol";

import { Eip712 } from "./Eip712.sol";
import { Erc20Core } from "./Erc20Core.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @title Eip3009
/// @notice Eip3009 provides internal implementations for gas-abstracted transfers under Eip3009 guidelines
/// @author Agora, inspired by Circle's Eip3009 implementation
abstract contract Eip3009 is Eip712, Erc20Core {
    using SafeCastLib for uint256;
    using StorageLib for uint256;

    /// @notice keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32 internal constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH_ =
        0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    /// @notice keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32 internal constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH_ =
        0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

    /// @notice keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")
    bytes32 internal constant CANCEL_AUTHORIZATION_TYPEHASH_ =
        0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

    //==============================================================================
    // Internal Procedural Functions
    //==============================================================================

    /// @notice The ```_transferWithAuthorization``` function executes a transfer with a signed authorization
    /// @dev EOA wallet signatures should be packed in the order of r, s, v
    /// @param _from Payer's address (Authorizer)
    /// @param _to Payee's address
    /// @param _value Amount to be transferred
    /// @param _validAfter The time after which this is valid (unix time)
    /// @param _validBefore The time before which this is valid (unix time)
    /// @param _nonce Unique nonce
    /// @param _signature Signature byte array produced by an EOA wallet or a contract wallet
    function _transferWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) internal {
        // Checks: authorization validity
        if (block.timestamp <= _validAfter) revert InvalidAuthorization();
        if (block.timestamp >= _validBefore) revert ExpiredAuthorization();
        _requireUnusedAuthorization({ _authorizer: _from, _nonce: _nonce });

        // Checks: valid signature
        _requireIsValidSignatureNow({
            _signer: _from,
            _dataHash: keccak256(
                abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH_, _from, _to, _value, _validAfter, _validBefore, _nonce)
            ),
            _signature: _signature
        });

        // Effects: mark authorization as used and transfer
        _markAuthorizationAsUsed({ _authorizer: _from, _nonce: _nonce });
        _transfer({ _from: _from, _to: _to, _transferValue: _value.toUint248() });
    }

    /// @notice The ```_receiveWithAuthorization``` function receives a transfer with a signed authorization from the payer
    /// @dev This has an additional check to ensure that the payee's address matches the caller of this function to prevent front-running attacks
    /// @dev EOA wallet signatures should be packed in the order of r, s, v
    /// @param _from Payer's address (Authorizer)
    /// @param _to Payee's address
    /// @param _value Amount to be transferred
    /// @param _validAfter The block.timestamp after which the authorization is valid
    /// @param _validBefore The block.timestamp before which the authorization is valid
    /// @param _nonce Unique nonce
    /// @param _signature Signature byte array produced by an EOA wallet or a contract wallet
    function _receiveWithAuthorization(
        address _from,
        address _to,
        uint256 _value,
        uint256 _validAfter,
        uint256 _validBefore,
        bytes32 _nonce,
        bytes memory _signature
    ) internal {
        // Checks: authorization validity
        if (_to != msg.sender) revert InvalidPayee({ caller: msg.sender, payee: _to });
        if (block.timestamp <= _validAfter) revert InvalidAuthorization();
        if (block.timestamp >= _validBefore) revert ExpiredAuthorization();
        _requireUnusedAuthorization({ _authorizer: _from, _nonce: _nonce });

        // Checks: valid signature
        _requireIsValidSignatureNow({
            _signer: _from,
            _dataHash: keccak256(
                abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH_, _from, _to, _value, _validAfter, _validBefore, _nonce)
            ),
            _signature: _signature
        });

        // Effects: mark authorization as used and transfer
        _markAuthorizationAsUsed({ _authorizer: _from, _nonce: _nonce });
        _transfer({ _from: _from, _to: _to, _transferValue: _value.toUint248() });
    }

    /// @notice The ```_cancelAuthorization``` function cancels an authorization
    /// @dev EOA wallet signatures should be packed in the order of r, s, v
    /// @param _authorizer Authorizer's address
    /// @param _nonce Nonce of the authorization
    /// @param _signature Signature byte array produced by an EOA wallet or a contract wallet
    function _cancelAuthorization(address _authorizer, bytes32 _nonce, bytes memory _signature) internal {
        _requireUnusedAuthorization({ _authorizer: _authorizer, _nonce: _nonce });
        _requireIsValidSignatureNow({
            _signer: _authorizer,
            _dataHash: keccak256(abi.encode(CANCEL_AUTHORIZATION_TYPEHASH_, _authorizer, _nonce)),
            _signature: _signature
        });

        StorageLib.getPointerToEip3009Storage().isAuthorizationUsed[_authorizer][_nonce] = true;
        emit AuthorizationCanceled({ authorizer: _authorizer, nonce: _nonce });
    }

    //==============================================================================
    // Internal Checks Functions
    //==============================================================================

    /// @notice The ```_requireIsValidSignatureNow``` function validates that signature against input data struct
    /// @param _signer Signer's address
    /// @param _dataHash Hash of encoded data struct
    /// @param _signature Signature byte array produced by an EOA wallet or a contract wallet
    function _requireIsValidSignatureNow(address _signer, bytes32 _dataHash, bytes memory _signature) private view {
        if (
            !SignatureCheckerLib.isValidSignatureNow({
                signer: _signer,
                hash: MessageHashUtils.toTypedDataHash({
                    domainSeparator: _domainSeparatorV4(),
                    structHash: _dataHash
                }),
                signature: _signature
            })
        ) revert InvalidSignature();
    }

    /// @notice The ```_requireUnusedAuthorization``` checks that an authorization nonce is unused
    /// @param _authorizer    Authorizer's address
    /// @param _nonce         Nonce of the authorization
    function _requireUnusedAuthorization(address _authorizer, bytes32 _nonce) private view {
        if (StorageLib.getPointerToEip3009Storage().isAuthorizationUsed[_authorizer][_nonce])
            revert UsedOrCanceledAuthorization();
    }

    //==============================================================================
    // Internal Effects Functions
    //==============================================================================

    /// @notice The ```_markAuthorizationAsUsed``` function marks an authorization nonce as used
    /// @param _authorizer    Authorizer's address
    /// @param _nonce         Nonce of the authorization
    function _markAuthorizationAsUsed(address _authorizer, bytes32 _nonce) private {
        StorageLib.getPointerToEip3009Storage().isAuthorizationUsed[_authorizer][_nonce] = true;
        emit AuthorizationUsed({ authorizer: _authorizer, nonce: _nonce });
    }

    //==============================================================================
    // Events
    //==============================================================================

    /// @notice ```AuthorizationUsed``` event is emitted when an authorization is used
    /// @param authorizer Authorizer's address
    /// @param nonce Nonce of the authorization
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

    /// @notice ```AuthorizationCanceled``` event is emitted when an authorization is canceled
    /// @param authorizer Authorizer's address
    /// @param nonce Nonce of the authorization
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice The ```InvalidPayee``` error is emitted when the payee does not match sender in receiveWithAuthorization
    /// @param caller The caller of the function
    /// @param payee The expected payee in the function
    error InvalidPayee(address caller, address payee);

    /// @notice The ```InvalidAuthorization``` error is emitted when the authorization is invalid because its too early
    error InvalidAuthorization();

    /// @notice The ```ExpiredAuthorization``` error is emitted when the authorization is expired
    error ExpiredAuthorization();

    /// @notice The ```InvalidSignature``` error is emitted when the signature is invalid
    error InvalidSignature();

    /// @notice The ```UsedOrCanceledAuthorization``` error is emitted when the authorization nonce is already used or canceled
    error UsedOrCanceledAuthorization();
}
