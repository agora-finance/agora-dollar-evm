# 💵 Agora Dollar (AUSD) Studio & StableSwap Suite

An institutional-grade development studio, **Proof of Reserve (PoR) Oracle**, and **Zero-Slippage StableSwap Engine** for **Agora Dollar (AUSD)**.

---

## 🌟 Key Features

- 🏦 **Real-Time Proof of Reserve**: Track audited 100.5% collateralization backed by short-term US Treasury Bills and cash.
- 🔄 **Zero-Slippage StableSwap**: Fixed 1:1 swaps between USDC, USDT, and AUSD with institutional fee tiers.
- 🌐 **Interactive Web Studio**: Institutional finance dashboard with live reserve charts and swap terminal on `http://localhost:3413`.
- ⌨️ **Universal CLI (`ausd-cli`)**: Terminal utility for inspecting reserves and executing swaps.

---

## 🚀 Quickstart

```bash
# Launch AUSD Studio
npm start
# Open http://localhost:3413

# Or run via CLI
node bin/ausd-cli.js reserves
node bin/ausd-cli.js swap USDC AUSD 5000
```
