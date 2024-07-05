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
// ============================= Erc2612 ==============================
// ====================================================================

import { SignatureCheckerLib } from "solady/src/utils/SignatureCheckerLib.sol";

import { Eip712 } from "./Eip712.sol";
import { Erc20Core } from "./Erc20Core.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

abstract contract Erc2612 is Eip712, Erc20Core {
    using StorageLib for uint256;

    /// @notice The ```PERMIT_TYPEHASH``` stores keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    //==============================================================================
    // External Procedural Functions
    //==============================================================================

    /// @notice The ```permit``` function sets an allowance with a signature
    /// @param _owner The account that signed the message
    /// @param _spender The account that is allowed to spend the funds
    /// @param _value The amount of funds that can be spent
    /// @param _deadline The time by which the transaction must be completed
    /// @param _v The v of the ECDSA signature
    /// @param _r The r of the ECDSA signature
    /// @param _s The s of the ECDSA signature
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        permit({
            _owner: _owner,
            _spender: _spender,
            _value: _value,
            _deadline: _deadline,
            _signature: abi.encodePacked(_r, _s, _v)
        });
    }
    /// @notice The ```permit``` function sets an allowance with a signature
    /// @param _owner The account that signed the message
    /// @param _spender The account that is allowed to spend the funds
    /// @param _value The amount of funds that can be spent
    /// @param _deadline The time by which the transaction must be completed
    /// @param _signature The signature of the message

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        bytes memory _signature
    ) public {
        // Checks: contract-wide access control
        bool _isSignatureVerificationPaused = StorageLib
            .sloadImplementationSlotDataAsUint256()
            .isSignatureVerificationPaused();
        if (_isSignatureVerificationPaused) revert StorageLib.SignatureVerificationPaused();

        // Checks: deadline
        if (block.timestamp > _deadline) revert Erc2612ExpiredSignature({ deadline: _deadline });

        // Effects: increment nonce
        uint256 _nextNonce;
        unchecked {
            _nextNonce = StorageLib.getPointerToErc2612Storage().nonces[_owner]++;
        }
        bytes32 _structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, _nextNonce, _deadline));

        bytes32 _hash = _hashTypedDataV4({ structHash: _structHash });

        // Checks: is valid eoa or eip1271 signature
        bool _isValidSignature = SignatureCheckerLib.isValidSignatureNow({
            signer: _owner,
            hash: _hash,
            signature: _signature
        });
        if (!_isValidSignature) revert Erc2612InvalidSignature();

        // Effects: update bookkeeping
        _approve({ _owner: _owner, _spender: _spender, _value: _value });
    }

    /// @notice The ```DOMAIN_SEPARATOR``` function returns the configured domain separator
    /// @return _domainSeparator The domain separator
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32 _domainSeparator) {
        _domainSeparator = _domainSeparatorV4();
    }

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice The ```Erc2612ExpiredSignature``` error is emitted when the signature is expired
    /// @param deadline the time by which the transaction must be completed
    error Erc2612ExpiredSignature(uint256 deadline);

    /// @notice The ```Erc2612InvalidSignature``` error is emitted when the signature is invalid
    error Erc2612InvalidSignature();
}
