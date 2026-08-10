/**
 * Agora AUSD Studio Client Logic
 */

document.addEventListener('DOMContentLoaded', () => {
  initTabs();
  loadReserves();
  loadSwaps();
  initFormListeners();
});

function initTabs() {
  const tabs = document.querySelectorAll('.nav-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.nav-tab').forEach(t => t.classList.toggle('active', t === tab));
      document.querySelectorAll('.tab-pane').forEach(p => p.classList.toggle('active', p.id === `tab-${tab.dataset.tab}`));
    });
  });
}

async function loadReserves() {
  try {
    const res = await fetch('/api/reserves');
    const data = await res.json();
    const por = data.proofOfReserve;

    document.getElementById('res-supply').textContent = `${por.circulatingSupply.toLocaleString()} AUSD`;
    document.getElementById('res-total').textContent = `$${por.reserveValue.toLocaleString()}`;
    document.getElementById('res-ratio').textContent = por.collateralRatio;

    const container = document.getElementById('assets-container');
    container.innerHTML = '';

    por.assets.forEach(asset => {
      const row = document.createElement('div');
      row.className = 'asset-row';
      row.innerHTML = `
        <div>
          <div style="font-weight: 700; color: #fff;">${asset.name}</div>
          <div class="text-muted" style="font-size: 0.78rem;">Custodian: ${asset.custodian}</div>
        </div>
        <div style="text-align: right;">
          <div style="font-weight: 800; color: #f59e0b; font-size: 1.1rem;">${asset.percentage}%</div>
          <span class="backed-tag">Audited Reserve</span>
        </div>
      `;
      container.appendChild(row);
    });
  } catch (e) {
    console.error(e);
  }
}

async function loadSwaps() {
  try {
    const res = await fetch('/api/swaps');
    const swaps = await res.json();
    const list = document.getElementById('swaps-list-container');

    if (!swaps || swaps.length === 0) return;
    list.innerHTML = '';

    swaps.forEach(s => {
      const row = document.createElement('div');
      row.className = 'ledger-row';
      row.innerHTML = `
        <div>
          <div style="font-weight: 600;">${s.inputAmount} → <span style="color: #34d399;">${s.outputAmount}</span></div>
          <div class="mono text-muted" style="font-size: 0.72rem;">${s.txHash.slice(0, 16)}...</div>
        </div>
        <div style="text-align: right;">
          <div style="color: #34d399; font-weight: 700; font-size: 0.8rem;">0% Slippage</div>
          <div class="text-muted" style="font-size: 0.75rem;">${new Date(s.timestamp).toLocaleTimeString()}</div>
        </div>
      `;
      list.appendChild(row);
    });
  } catch (e) {
    console.warn(e);
  }
}

function initFormListeners() {
  document.getElementById('swap-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn-exec-swap');
    const resultBox = document.getElementById('swap-result-box');

    const fromToken = document.getElementById('swap-from-token').value;
    const toToken = document.getElementById('swap-to-token').value;
    const amount = document.getElementById('swap-amount').value;

    btn.disabled = true;
    btn.textContent = '⏳ Executing 1:1 StableSwap...';

    try {
      const res = await fetch('/api/swap', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fromToken, toToken, amount }),
      });
      const data = await res.json();

      if (data.success) {
        resultBox.innerHTML = `
          <div class="card" style="border-color: #10b981; background: rgba(16, 185, 129, 0.08);">
            <strong style="color: #34d399;">✅ Zero-Slippage StableSwap Settled!</strong>
            <p class="mt-2" style="font-size: 0.9rem;">Swapped <strong>${data.log.inputAmount}</strong> for <strong style="color: #34d399;">${data.log.outputAmount}</strong></p>
            <div class="mono text-muted mt-1" style="font-size: 0.75rem;">TX: ${data.log.txHash}</div>
          </div>
        `;
        loadSwaps();
      }
    } catch (err) {
      resultBox.innerHTML = `<div class="badge red">Swap error: ${err.message}</div>`;
    } finally {
      btn.disabled = false;
      btn.textContent = '⚡ Execute Zero-Slippage Swap';
    }
  });
}
