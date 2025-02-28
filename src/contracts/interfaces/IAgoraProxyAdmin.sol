// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IAgoraProxyAdmin {
    error OwnableInvalidOwner(address owner);
    error OwnableUnauthorizedAccount(address account);

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function UPGRADE_INTERFACE_VERSION() external view returns (string memory);
    function acceptOwnership() external;
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function renounceOwnership() external;
    function transferOwnership(address _newOwner) external;
    function upgradeAndCall(address proxy, address implementation, bytes memory data) external payable;
}
