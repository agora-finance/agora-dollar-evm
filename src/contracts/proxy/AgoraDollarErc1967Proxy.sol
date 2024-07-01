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
// ===================== AgoraDollarErc1967Proxy ======================
// ====================================================================

import { Proxy } from "@openzeppelin/contracts/proxy/Proxy.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeCastLib } from "solady/src/utils/SafeCastLib.sol";

import { AgoraDollar } from "../AgoraDollar.sol";
import { AgoraDollarCore } from "../AgoraDollarCore.sol";
import { Eip3009, Eip712 } from "../Eip3009.sol";
import { AgoraProxyAdmin } from "./AgoraProxyAdmin.sol";

import { StorageLib } from "./StorageLib.sol";

import { ITransparentUpgradeableProxy } from "../interfaces/ITransparentUpgradeableProxy.sol";

struct ConstructorParams {
    address newImplementation;
    address proxyAdminOwnerAddress;
    string eip712Name;
    string eip712Version;
}

contract AgoraDollarErc1967Proxy is Eip3009, Proxy {
    using SafeCastLib for uint256;
    using StorageLib for uint256;

    address private immutable PROXY_ADMIN_ADDRESS;

    constructor(ConstructorParams memory _params) payable Eip712(_params.eip712Name, _params.eip712Version) {
        // Effects: Set the proxy admin address
        PROXY_ADMIN_ADDRESS = address(new AgoraProxyAdmin({ _initialOwner: _params.proxyAdminOwnerAddress }));
        StorageLib.getPointerToAgoraDollarErc1967ProxyAdminStorage().proxyAdminAddress = PROXY_ADMIN_ADDRESS;

        // Emit event
        emit AdminChanged({ previousAdmin: address(0), newAdmin: PROXY_ADMIN_ADDRESS });

        // Generate calldata for initialization
        AgoraDollar.InitializeParams memory _initializeParams = AgoraDollarCore.InitializeParams({
            initialAdminAddress: _params.proxyAdminOwnerAddress
        });
        bytes memory _initializeCalldata = abi.encodeWithSelector(
            AgoraDollarCore.initialize.selector,
            _initializeParams
        );

        _upgradeToAndCall({ _newImplementation: _params.newImplementation, _callData: _initializeCalldata });
    }

    fallback() external payable override {
        _fallback();
    }

    //==============================================================================
    // Proxy Functions
    //==============================================================================

    function _implementation() internal view override returns (address _implementationAddress) {
        _implementationAddress = StorageLib.sloadImplementationSlotDataAsUint256().implementation();
    }

    function _fallback() internal override {
        if (msg.sender == PROXY_ADMIN_ADDRESS) {
            if (msg.sig != ITransparentUpgradeableProxy.upgradeToAndCall.selector) {
                revert ProxyDeniedAdminAccess();
            } else {
                (address _newImplementation, bytes memory _callData) = abi.decode(msg.data[4:], (address, bytes));
                _upgradeToAndCall({ _newImplementation: _newImplementation, _callData: _callData });
            }
        } else {
            super._fallback();
        }
    }

    /// @notice The ```_upgradeToAndCall``` function is an internal implementation which sets the new implementation address and calls the new implementation with the given data.
    /// @param _newImplementation The address of the new implementation.
    /// @param _callData The call data using the new implementation as a target.
    function _upgradeToAndCall(address _newImplementation, bytes memory _callData) internal {
        // Checks: Ensure the new implementation is a contract
        if (_newImplementation.code.length == 0) revert ImplementationTargetNotAContract();

        // Effects: Write the storage value for new implementation
        StorageLib.AgoraDollarErc1967ProxyContractStorage storage contractData = StorageLib
            .getPointerToAgoraDollarErc1967ProxyContractStorage();
        contractData.implementationAddress = _newImplementation;

        // Emit event
        emit Upgraded({ implementation: _newImplementation });

        // Execute calldata for new implementation
        if (_callData.length > 0) Address.functionDelegateCall({ target: _newImplementation, data: _callData });
        else if (msg.value > 0) revert AgoraDollarErc1967NonPayable();
    }

    //==============================================================================
    // Erc20 Functions
    //==============================================================================

    function transfer(address _to, uint256 _transferValue) external returns (bool) {
        // Get data from implementation slot as a uint256
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();

        bool _isTransferUpgraded = _contractData.isTransferUpgraded();
        if (_isTransferUpgraded) {
            // new implementation address is stored in the least significant 160 bits of the contract data
            address _newImplementation = address(uint160(_contractData));
            _delegate({ implementation: _newImplementation });
        } else {
            // Checks: contract-wide access control
            if (_contractData.isTransferPaused()) revert StorageLib.TransferPaused();

            // Effects: Transfer the tokens
            _transfer({ _from: msg.sender, _to: _to, _transferValue: _transferValue.toUint248() });
            return true;
        }
    }

    function transferFrom(address _from, address _to, uint256 _transferValue) external returns (bool) {
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();
        bool _isTransferFromUpgraded = _contractData.isTransferFromUpgraded();
        if (_isTransferFromUpgraded) {
            // new implementation address is stored in the least significant 160 bits of the contract data
            address _newImplementation = address(uint160(_contractData));
            _delegate({ implementation: _newImplementation });
        } else {
            // Reading account data for sender adds gas so we should only do it if set true
            bool _isMsgSenderFrozenCheckEnabled = _contractData.isMsgSenderFrozenCheckEnabled();
            if (
                _isMsgSenderFrozenCheckEnabled &&
                StorageLib.getPointerToErc20CoreStorage().accountData[msg.sender].isFrozen
            ) revert AccountIsFrozen({ frozenAccount: msg.sender });

            // Checks: contract-wide access control
            if (_contractData.isTransferPaused()) revert StorageLib.TransferPaused();

            // Effects: Decrease the allowance of the spender
            _spendAllowance({ _owner: _from, _spender: msg.sender, _value: _transferValue });

            // Effects: Transfer the tokens
            _transfer({ _from: _from, _to: _to, _transferValue: _transferValue.toUint248() });
            return true;
        }
    }

    //==============================================================================
    // Eip-3009 Overriden Functions
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
        // Packs signature pieces into bytes
        transferWithAuthorization({
            _from: _from,
            _to: _to,
            _value: _value,
            _validAfter: _validAfter,
            _validBefore: _validBefore,
            _nonce: _nonce,
            _signature: abi.encodePacked(_r, _s, _v)
        });
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
        // Get data from implementation slot as a uint256
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();

        bool _isTransferWithAuthorizationUpgraded = _contractData.isTransferWithAuthorizationUpgraded();
        if (_isTransferWithAuthorizationUpgraded) {
            // new implementation address is stored in the least significant 160 bits of the contract data
            address _newImplementation = address(uint160(_contractData));
            _delegate({ implementation: _newImplementation });
        } else {
            // Reading account data for sender adds gas so we should only do it if set true
            bool _isMsgSenderFrozenCheckEnabled = _contractData.isMsgSenderFrozenCheckEnabled();
            if (
                _isMsgSenderFrozenCheckEnabled &&
                StorageLib.getPointerToErc20CoreStorage().accountData[msg.sender].isFrozen
            ) revert AccountIsFrozen({ frozenAccount: msg.sender });

            // Checks: contract-wide access control
            if (_contractData.isTransferPaused()) revert StorageLib.TransferPaused();
            if (_contractData.isSignatureVerificationPaused()) revert StorageLib.SignatureVerificationPaused();

            // Effects: transfer the tokens
            _transferWithAuthorization({
                _from: _from,
                _to: _to,
                _value: _value,
                _validAfter: _validAfter,
                _validBefore: _validBefore,
                _nonce: _nonce,
                _signature: _signature
            });
        }
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
        // Packs signature pieces into bytes
        receiveWithAuthorization({
            _from: _from,
            _to: _to,
            _value: _value,
            _validAfter: _validAfter,
            _validBefore: _validBefore,
            _nonce: _nonce,
            _signature: abi.encodePacked(_r, _s, _v)
        });
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
        // Get data from implementation slot as a uint256
        uint256 _contractData = StorageLib.sloadImplementationSlotDataAsUint256();

        bool _isReceiveWithAuthorizationUpgraded = _contractData.isReceiveWithAuthorizationUpgraded();
        if (_isReceiveWithAuthorizationUpgraded) {
            // new implementation address is stored in the least significant 160 bits of the contract data
            address _newImplementation = address(uint160(_contractData));
            _delegate({ implementation: _newImplementation });
        } else {
            // Checks: contract-wide access control
            if (_contractData.isTransferPaused()) revert StorageLib.TransferPaused();
            if (_contractData.isSignatureVerificationPaused()) revert StorageLib.SignatureVerificationPaused();

            // Effects: transfer the tokens
            _receiveWithAuthorization({
                _from: _from,
                _to: _to,
                _value: _value,
                _validAfter: _validAfter,
                _validBefore: _validBefore,
                _nonce: _nonce,
                _signature: _signature
            });
        }
    }

    //==============================================================================
    // Events
    //==============================================================================

    /// @dev Emitted when the implementation is upgraded.
    event Upgraded(address indexed implementation);

    /// @dev Emitted when the admin account has changed.
    event AdminChanged(address previousAdmin, address newAdmin);

    //==============================================================================
    // Errors
    //==============================================================================

    /// @dev Emitted when trying to send ether to a non-payable contract
    error AgoraDollarErc1967NonPayable();

    /// @dev The proxy caller is the current admin, and can't fallback to the proxy target.
    error ProxyDeniedAdminAccess();

    /// @dev The target of the proxy is not a contract.
    error ImplementationTargetNotAContract();
}
