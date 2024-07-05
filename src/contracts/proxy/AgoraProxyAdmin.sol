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
// ======================== AgoraProxyAdmin ===========================
// ====================================================================

import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

/// @title AgoraProxyAdmin
/// @notice A proxy admin contract that extends the OpenZeppelin ProxyAdmin contract and adds a two-step ownership transfer mechanism
/// @author Agora
contract AgoraProxyAdmin is ProxyAdmin, Ownable2Step {
    /// @notice Initializes the contract with the initial owner
    /// @param _initialOwner The address that will be set as the initial owner of the contract
    constructor(address _initialOwner) ProxyAdmin(_initialOwner) {}

    /// @notice Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one
    /// @dev Can only be called by the current owner
    /// @param _newOwner The address to which ownership of the contract will be transferred
    function transferOwnership(address _newOwner) public override(Ownable, Ownable2Step) onlyOwner {
        // NOTE: Order of inheritance/override is important to ensure we are calling Ownable2Step version of transferOwnership
        super.transferOwnership({ newOwner: _newOwner });
    }

    /// @notice Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner
    /// @dev Internal function without access restriction
    /// @param _newOwner The address to which ownership of the contract will be transferred
    function _transferOwnership(address _newOwner) internal override(Ownable, Ownable2Step) {
        // NOTE: Order of inheritance/override is important to ensure we are calling Ownable2Step version of _transferOwnership
        super._transferOwnership({ newOwner: _newOwner });
    }
}
