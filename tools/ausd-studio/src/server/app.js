/**
 * Agora Dollar (AUSD) Web Studio Server
 */

import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import { AGORA_CONFIG } from '../config.js';
import { defaultReserveOracle } from '../core/reserve-oracle.js';
import { defaultStableSwap } from '../core/stableswap-engine.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const WEB_ROOT = path.join(__dirname, '../../web');

const app = express();
const PORT = process.env.PORT || 3413;

app.use(cors());
app.use(express.json());
app.use(express.static(WEB_ROOT));

// 1. Get Proof of Reserve & Config
app.get('/api/reserves', (req, res) => {
  res.json({
    token: AGORA_CONFIG.token,
    deployments: AGORA_CONFIG.deployments,
    proofOfReserve: defaultReserveOracle.getProofOfReserve(),
  });
});

// 2. Mint AUSD
app.post('/api/mint', (req, res) => {
  try {
    const result = defaultReserveOracle.mintAusd(req.body);
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 3. StableSwap Zero Slippage
app.post('/api/swap', (req, res) => {
  try {
    const result = defaultStableSwap.executeSwap(req.body);
    res.json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// 4. Swap History
app.get('/api/swaps', (req, res) => {
  res.json(defaultStableSwap.getSwapHistory());
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`\n======================================================`);
    console.log(`💵 Agora Dollar (AUSD) Reserve & StableSwap Studio Running!`);
    console.log(`🌐 Web Dashboard: http://localhost:${PORT}`);
    console.log(`🏦 Collateral: 100% US Treasuries & Cash Backed`);
    console.log(`======================================================\n`);
  });
}

export default app;
