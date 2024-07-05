// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

interface ITransparentUpgradeableProxy {
    function upgradeToAndCall(address, bytes calldata) external payable;
}
