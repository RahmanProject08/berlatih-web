// DOM Elements
const mainMetricCard = document.getElementById("mainMetricCard");
const metricBadge = document.getElementById("metricBadge");
const metricStatusText = document.getElementById("metricStatusText");
const metricSubText = document.getElementById("metricSubText");
const hmacIndicator = document.getElementById("hmacIndicator");
const lastEventTimestamp = document.getElementById("lastEventTimestamp");

const webhookForm = document.getElementById("webhookForm");
const eventStatusSelect = document.getElementById("eventStatus");
const threatLevelSelect = document.getElementById("threatLevel");
const reportMessageInput = document.getElementById("reportMessage");
const hmacSecretInput = document.getElementById("hmacSecret");
const simulateTamperCheckbox = document.getElementById("simulateTamper");
const hmacPreview = document.getElementById("hmacPreview");
const submitWebhookBtn = document.getElementById("submitWebhookBtn");

const runAiBtn = document.getElementById("runAiBtn");
const aiInputText = document.getElementById("aiInputText");
const aiDurationText = document.getElementById("aiDurationText");
const cardModelRf = document.getElementById("cardModelRf");
const rfPrediction = document.getElementById("rfPrediction");
const rfConfidence = document.getElementById("rfConfidence");
const cardModelSvm = document.getElementById("cardModelSvm");
const svmPrediction = document.getElementById("svmPrediction");
const svmConfidence = document.getElementById("svmConfidence");

const consoleLogArea = document.getElementById("consoleLogArea");
const clearLogBtn = document.getElementById("clearLogBtn");

// Helper: Logging to Virtual Console (9.5)
function appendLog(message, type = "info") {
  const now = new Date();
  const timeStr = `[${now.toTimeString().split(" ")[0]}.${String(now.getMilliseconds()).padStart(3, "0")}]`;
  
  const entry = document.createElement("div");
  entry.className = `log-entry ${type}`;
  entry.innerHTML = `<span class="log-time">${timeStr}</span><span class="log-msg">${escapeHtml(message)}</span>`;
  
  consoleLogArea.appendChild(entry);
  consoleLogArea.scrollTop = consoleLogArea.scrollHeight;
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.innerText = text;
  return div.innerHTML;
}

// [9.2] Metric Card Dynamic State Transition
function setMetricCardState(state, level = null) {
  if (state === "AMAN") {
    mainMetricCard.className = "metric-card state-safe";
    metricBadge.textContent = "AMAN";
    metricStatusText.textContent = "SYSTEM SECURED";
    metricSubText.textContent = "Semua parameter database dan webhook traffic dalam batas normal dan terautentikasi.";
    hmacIndicator.className = "val-safe";
    hmacIndicator.textContent = "VERIFIED (SHA-256)";
  } else if (state === "BAHAYA") {
    mainMetricCard.className = "metric-card state-danger";
    metricBadge.textContent = "BAHAYA";
    metricStatusText.textContent = level !== null ? `LEVEL ALERT: CRITICAL (L${level})` : "LEVEL ALERT: CRITICAL";
    metricSubText.textContent = "Ancaman database atau serangan tampering terdeteksi! Webhook alert diaktifkan.";
    hmacIndicator.className = "val-danger";
    hmacIndicator.textContent = "ALERT DISPATCHED";
  }
  lastEventTimestamp.textContent = new Date().toLocaleTimeString();
}

// [9.3.f] Hitung HMAC-SHA256 Client-Side menggunakan Web Crypto API (window.crypto.subtle)
async function computeHmacSha256(secretText, messageText) {
  const enc = new TextEncoder();
  const keyData = enc.encode(secretText);
  const msgData = enc.encode(messageText);

  // Import raw key
  const cryptoKey = await window.crypto.subtle.importKey(
    "raw",
    keyData,
    { name: "HMAC", hash: { name: "SHA-256" } },
    false,
    ["sign"]
  );

  // Sign message
  const signatureBuffer = await window.crypto.subtle.sign(
    "HMAC",
    cryptoKey,
    msgData
  );

  // Convert buffer to hex string
  const hashArray = Array.from(new Uint8Array(signatureBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, "0")).join("");
}

// Update HMAC preview real-time
async function updateSignaturePreview() {
  try {
    const payload = {
      status: eventStatusSelect.value,
      threat_level: parseInt(threatLevelSelect.value, 10),
      message: reportMessageInput.value
    };
    const bodyStr = JSON.stringify(payload);
    const secret = hmacSecretInput.value || "default_hmac_secret_key_2026";
    
    let signature = await computeHmacSha256(secret, bodyStr);
    if (simulateTamperCheckbox.checked) {
      signature = "deadbeef_tampered_" + signature.substring(18);
    }
    hmacPreview.textContent = signature;
    return { bodyStr, signature };
  } catch (err) {
    hmacPreview.textContent = "Error menghitung HMAC: " + err.message;
    return null;
  }
}

// Event Listeners for inputs to update preview
[eventStatusSelect, threatLevelSelect, reportMessageInput, hmacSecretInput, simulateTamperCheckbox].forEach(el => {
  el.addEventListener("input", updateSignaturePreview);
  el.addEventListener("change", updateSignaturePreview);
});

// [9.3] Form Submit Simulator Webhook
webhookForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  
  const calc = await updateSignaturePreview();
  if (!calc) return;

  const { bodyStr, signature } = calc;
  const isTampered = simulateTamperCheckbox.checked;

  appendLog(`[HMAC SIM] Menyiapkan transmisi webhook. Tamper simulation: ${isTampered ? "AKTIF" : "NONAKTIF"}`, "info");
  appendLog(`[HMAC SIM] Generated Header: x-signature = ${signature.substring(0, 24)}...`, "system");

  submitWebhookBtn.disabled = true;
  submitWebhookBtn.innerHTML = `<span>Memproses Webhook...</span>`;

  try {
    const response = await fetch("/api/webhook", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-signature": signature
      },
      body: bodyStr
    });

    const data = await response.json();

    if (response.status === 200) {
      appendLog(`[HMAC VALID] Webhook 200 OK: ${data.message} | Telegram Sent: ${data.telegram_alert_sent}`, "success");
      // Update UI metric card sesuai status yang dikirim
      setMetricCardState(eventStatusSelect.value, threatLevelSelect.value);
    } else if (response.status === 401) {
      appendLog(`[HMAC REJECTED] Webhook 401 Unauthorized: ${data.message}`, "error");
      // Tampilkan state bahaya karena ada upaya manipulasi/tampering
      setMetricCardState("BAHAYA", "TAMPER-ALERT");
    } else {
      appendLog(`[HMAC ERROR] Status ${response.status}: ${data.message || "Unknown error"}`, "warning");
    }
  } catch (err) {
    appendLog(`[NETWORK ERROR] Gagal menghubungi endpoint /api/webhook: ${err.message}`, "error");
  } finally {
    submitWebhookBtn.disabled = false;
    submitWebhookBtn.innerHTML = `
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="22" y1="2" x2="11" y2="13"></line>
        <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
      </svg>
      <span>Kirim Webhook Terproteksi HMAC</span>
    `;
  }
});

// [9.4] Panel Benchmark AI Asynchronous (FastAPI)
runAiBtn.addEventListener("click", async () => {
  const inputText = aiInputText.value.trim() || "Normal safe SQL query";
  
  appendLog(`[AI CHAIN] Mengirim request ke /api/proses_ai?input=${encodeURIComponent(inputText)}`, "info");
  appendLog(`[AI CHAIN] Memicu asyncio.gather() untuk Model RF (0.3s) dan Model SVM (0.5s)...`, "system");

  runAiBtn.disabled = true;
  runAiBtn.innerHTML = `<span>Mengeksekusi AI Paralel...</span>`;

  try {
    const startTime = performance.now();
    const res = await fetch(`/api/proses_ai?input=${encodeURIComponent(inputText)}`);
    const data = await res.json();
    const clientDuration = ((performance.now() - startTime) / 1000).toFixed(4);

    if (data.status === "success") {
      const serverDuration = data.duration_seconds;
      aiDurationText.textContent = `${serverDuration} detik`;
      appendLog(`[AI SUCCESS] AI Chaining selesai dalam ${serverDuration}s (Client latency: ${clientDuration}s)`, "success");

      // Update RF Card
      const rf = data.results.model_rf;
      rfPrediction.textContent = rf.prediction;
      rfConfidence.textContent = `${(rf.confidence * 100).toFixed(1)}%`;
      cardModelRf.className = `model-result-card ${rf.prediction === "AMAN" ? "safe" : "danger"}`;

      // Update SVM Card
      const svm = data.results.model_svm;
      svmPrediction.textContent = svm.prediction;
      svmConfidence.textContent = `${(svm.confidence * 100).toFixed(1)}%`;
      cardModelSvm.className = `model-result-card ${svm.prediction === "AMAN" ? "safe" : "danger"}`;

      appendLog(`[AI PREDICT] RF: ${rf.prediction} (${rf.confidence}) | SVM: ${svm.prediction} (${svm.confidence})`, "info");
    } else {
      appendLog(`[AI ERROR] Endpoint mengembalikan status gagal: ${JSON.stringify(data)}`, "error");
    }
  } catch (err) {
    appendLog(`[AI ERROR] Gagal menghubungi /api/proses_ai: ${err.message}`, "error");
  } finally {
    runAiBtn.disabled = false;
    runAiBtn.innerHTML = `
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <polygon points="5 3 19 12 5 21 5 3"></polygon>
      </svg>
      <span>Jalankan Rantai AI (Paralel)</span>
    `;
  }
});

// Clear console
clearLogBtn.addEventListener("click", () => {
  consoleLogArea.innerHTML = `
    <div class="log-entry system">
      <span class="log-time">[CLEARED]</span>
      <span class="log-msg">Log console telah dibersihkan oleh operator.</span>
    </div>
  `;
});

// Initialize on page load
updateSignaturePreview();
setMetricCardState("AMAN");
appendLog("Security Dashboard aktif. HMAC Web Crypto siap digunakan.", "success");
