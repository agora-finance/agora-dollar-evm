#!/usr/bin/env node

/**
 * Agora Dollar (AUSD) Universal CLI
 */

import { defaultReserveOracle } from '../src/core/reserve-oracle.js';
import { defaultStableSwap } from '../src/core/stableswap-engine.js';

const args = process.argv.slice(2);
const command = args[0] || 'help';

async function main() {
  switch (command.toLowerCase()) {
    case 'reserves': {
      console.log('\n🏦 Agora Dollar (AUSD) Proof of Reserve:');
      const por = defaultReserveOracle.getProofOfReserve();
      console.log(`  Circulating Supply:  ${por.circulatingSupply.toLocaleString()} AUSD`);
      console.log(`  Total Reserve Value: $${por.reserveValue.toLocaleString()} USD`);
      console.log(`  Collateral Ratio:    ${por.collateralRatio} (Fully Backed: ${por.isFullyBacked})`);
      console.log(`  Auditor:             ${por.auditor}\n`);
      break;
    }

    case 'swap': {
      const from = args[1] || 'USDC';
      const to = args[2] || 'AUSD';
      const amount = args[3] || '1000';

      console.log(`\n🔄 Executing Zero-Slippage StableSwap (${amount} ${from} -> ${to})...`);
      const res = defaultStableSwap.executeSwap({ fromToken: from, toToken: to, amount });
      console.log(`  Received:   ${res.log.outputAmount}`);
      console.log(`  Slippage:   ${res.log.slippage}`);
      console.log(`  Fee:        ${res.log.feePaid}`);
      console.log(`  TX Hash:    ${res.log.txHash}\n`);
      break;
    }

    case 'studio': {
      console.log('\n🌐 Launching AUSD Studio on :3413...');
      await import('../src/server/app.js');
      break;
    }

    default: {
      console.log(`
╔══════════════════════════════════════════════════════════════════╗
║               💵 AGORA DOLLAR (AUSD) STUDIO CLI                  ║
║      Proof of Reserve & Zero-Slippage StableSwap Toolkit         ║
╚══════════════════════════════════════════════════════════════════╝

Commands:
  ausd-cli reserves                      View real-time Proof of Reserve metrics
  ausd-cli swap [from] [to] [amount]     Simulate zero-slippage stablecoin swap
  ausd-cli studio                        Launch Interactive Web Studio on :3413
      `);
      break;
    }
  }
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
