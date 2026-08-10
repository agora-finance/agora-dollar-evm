/**
 * Agora Dollar (AUSD) Configuration & Reserve Feeds
 */

export const AGORA_CONFIG = {
  token: {
    name: 'Agora Dollar',
    symbol: 'AUSD',
    decimals: 6,
    peggedAsset: 'USD (1:1 Fiat & Treasury Backed)',
  },
  deployments: [
    {
      network: 'Ethereum Mainnet',
      chainId: 1,
      contractAddress: '0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a',
      explorerUrl: 'https://etherscan.io',
    },
    {
      network: 'Avalanche C-Chain',
      chainId: 43114,
      contractAddress: '0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a',
      explorerUrl: 'https://snowtrace.io',
    },
    {
      network: 'Arbitrum One',
      chainId: 42161,
      contractAddress: '0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a',
      explorerUrl: 'https://arbiscan.io',
    },
    {
      network: 'Base',
      chainId: 8453,
      contractAddress: '0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a',
      explorerUrl: 'https://basescan.org',
    },
  ],
  reserveBreakdown: {
    totalCirculatingSupply: 245000000, // 245M AUSD
    totalReserveValue: 246225000, // 246.2M USD (100.5% Collateralization)
    assets: [
      { name: 'Short-Term US Treasury Bills (< 90 days)', percentage: 78.5, custodian: 'State Street / BNY Mellon' },
      { name: 'Overnight Repurchase Agreements (Repo)', percentage: 15.0, custodian: 'Tier 1 US Banks' },
      { name: 'Cash & USD Deposits', percentage: 6.5, custodian: 'Insured Depository Institutions' },
    ],
  },
};
