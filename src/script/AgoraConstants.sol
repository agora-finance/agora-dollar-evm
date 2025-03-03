// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

library AgoraConstants {
    // These Address must be fetched from the explorer afaict.
    // address internal constant AUSD_PROXY_ADMIN = 0xeA00181163ADC29F5f1582cF9B4fD732103aCFbA;
    address internal constant AUSD_PROXY_ADMIN = 0x5F5258986684b5Bd551085445E011930C3fF2A13;
    // These are our expected deployment addresses based on the salt.
    address internal constant AUSD_PROXY = 0x8B52c234C4064Ef31c90f3e42B0Aa8C75d42A5Ad;
    address internal constant AUSD_IMPL = 0x8Ff5804bC9EB717aA4594eac9a69a79D148d8429;

    // Wallets
    address internal constant PROXY_ADMIN_OWNER = 0x99B0E95Fa8F5C3b86e4d78ED715B475cFCcf6E97;
    address internal constant AUSD_PROXY_DEPLOYER = 0xb53DE4376284C74Ed70Edcb9DaF7256942153FBc;
    address internal constant CREATEX_ADDRESS = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;
}
