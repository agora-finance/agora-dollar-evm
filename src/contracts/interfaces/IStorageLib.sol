// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

interface IStorageLib {
    error BridgingPaused();
    error BurnFromPaused();
    error FreezingPaused();
    error MintPaused();
    error SignatureVerificationPaused();
    error TransferPaused();
}
