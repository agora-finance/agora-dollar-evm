// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

interface ITransparentUpgradeableProxy {
    function upgradeToAndCall(address, bytes calldata) external payable;
}
