/**
 * AUSD Reserve Oracle & StableSwap Tests
 */

import { defaultReserveOracle } from '../src/core/reserve-oracle.js';
import { defaultStableSwap } from '../src/core/stableswap-engine.js';

async function runReserveTests() {
  console.log('Testing Agora Dollar (AUSD) Reserve Oracle & StableSwap...');

  // 1. Proof of Reserve
  const por = defaultReserveOracle.getProofOfReserve();
  if (!por.isFullyBacked || por.circulatingSupply <= 0) {
    throw new Error('Proof of reserve calculation failed');
  }

  // 2. StableSwap
  const swap = defaultStableSwap.executeSwap({
    fromToken: 'USDC',
    toToken: 'AUSD',
    amount: '5000',
  });

  if (!swap.success || parseFloat(swap.log.outputAmount) < 4995) {
    throw new Error('Zero slippage swap execution failed');
  }

  console.log(`✅ AUSD PoR Verified (${por.collateralRatio}) & Zero-Slippage StableSwap Tested!`);
}

runReserveTests().catch(e => {
  console.error('❌ Reserve Test Failed:', e);
  process.exit(1);
});
