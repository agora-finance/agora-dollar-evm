// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

library AgoraConstants {
    // These Address must be fetched from the explorer afaict.
    address internal constant AUSD_PROXY_ADMIN = 0x2fFb5584C3C8AD18B3fc8872B91AA49a2aC8d169;
    // These are our expected deployment addresses based on the salt.
    address internal constant AUSD_PROXY = 0xa9012a055bd4e0eDfF8Ce09f960291C09D5322dC;
    address internal constant AUSD_IMPL = 0x487478A4E9653e82e0e44DCA5F5202F928eBFD77;

    // Wallets
    address internal constant PROXY_ADMIN_OWNER = 0x99B0E95Fa8F5C3b86e4d78ED715B475cFCcf6E97;
    address internal constant AUSD_PROXY_DEPLOYER = 0xb53DE4376284C74Ed70Edcb9DaF7256942153FBc;
    address internal constant CREATEX_ADDRESS = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;
}
