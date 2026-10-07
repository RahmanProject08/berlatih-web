# ==============================================================================
# SCRIPT OTOMASI LANGKAH 2: ASYNCHRONOUS AI CHAINING (NVIDIA NIM CONCURRENCY)
# ==============================================================================
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LANGKAH 2] MEMBANGUN ENDPOINT ASYNC AI & PENGUJIAN KONKURENSI..." -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Pastikan direktori api ada
New-Item -ItemType Directory -Force -Path "api" | Out-Null

# 2. Buat file api/proses_ai.py (FastAPI Dual AI Paralel)
@"
import asyncio
import time
from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Async AI Chaining API", description="NVIDIA NIM Dual AI Chaining Simulation")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def simulate_model_rf(text: str):
    await asyncio.sleep(0.3)
    bad_keywords = ["attack", "sqli", "xss", "payload", "drop", "malware", "threat", "bahaya", "critical"]
    is_threat = any(k in text.lower() for k in bad_keywords)
    return {
        "model": "Random Forest (RF)",
        "prediction": "BAHAYA" if is_threat else "AMAN",
        "confidence": 0.94 if is_threat else 0.98
    }

async def simulate_model_svm(text: str):
    await asyncio.sleep(0.5)
    bad_keywords = ["attack", "sqli", "xss", "payload", "drop", "malware", "threat", "bahaya", "critical"]
    is_threat = any(k in text.lower() for k in bad_keywords)
    return {
        "model": "Support Vector Machine (SVM)",
        "prediction": "BAHAYA" if is_threat else "AMAN",
        "confidence": 0.91 if is_threat else 0.96
    }

@app.get("/api/proses_ai")
async def proses_ai(input: str = Query("normal traffic", description="Data teks untuk analisis ancaman")):
    start_time = time.time()
    res_rf, res_svm = await asyncio.gather(
        simulate_model_rf(input),
        simulate_model_svm(input)
    )
    end_time = time.time()
    duration = round(end_time - start_time, 4)
    return {
        "status": "success",
        "duration_seconds": duration,
        "input": input,
        "results": {
            "model_rf": res_rf,
            "model_svm": res_svm
        }
    }
"@ | Set-Content -Path "api\proses_ai.py" -Encoding UTF8

# 3. Buat script pengujian benchmark lokal test_async_ai.py
@"
import asyncio
import time
from api.proses_ai import simulate_model_rf, simulate_model_svm

async def run_benchmark():
    test_input = "SELECT * FROM users WHERE admin = 1"
    print("=" * 60)
    print("BENCHMARK PENGUJIAN ASYNCHRONOUS AI CHAINING (NVIDIA NIM)")
    print("=" * 60)
    print(f"Input Data: '{test_input}'")
    print("Memanggil Model RF (delay 0.3s) dan Model SVM (delay 0.5s) secara PARALEL...")
    print("-" * 60)

    start_time = time.time()
    res_rf, res_svm = await asyncio.gather(
        simulate_model_rf(test_input),
        simulate_model_svm(test_input)
    )
    end_time = time.time()
    total_duration = end_time - start_time

    print("\n[HASIL PREDIKSI]")
    print(f"1. Model RF  : {res_rf['model']} -> Prediksi: {res_rf['prediction']} (Confidence: {res_rf['confidence']})")
    print(f"2. Model SVM : {res_svm['model']} -> Prediksi: {res_svm['prediction']} (Confidence: {res_svm['confidence']})")
    print("-" * 60)
    print(f"Total Waktu Eksekusi : {total_duration:.4f} detik")
    print(f"Waktu Model RF (A)   : ~0.3 detik")
    print(f"Waktu Model SVM (B)  : ~0.5 detik")
    print(f"Ekspektasi Sekuensial: 0.3s + 0.5s = 0.8 detik")
    print(f"Ekspektasi Paralel   : max(0.3s, 0.5s) ~ 0.5 detik")
    print("-" * 60)

    if total_duration <= 0.6:
        print("STATUS PENGUJIAN: [PASSED] Waktu total <= 0.6 detik. Konkurensi asyncio.gather TERBUKTI!")
    else:
        print("STATUS PENGUJIAN: [WARNING] Waktu melebihi ambang batas 0.6 detik!")
    print("=" * 60)

if __name__ == "__main__":
    asyncio.run(run_benchmark())
"@ | Set-Content -Path "test_async_ai.py" -Encoding UTF8

# 4. Jalankan pengujian langsung di terminal
Write-Host "`n>>> Menjalankan pengujian konkurensi (test_async_ai.py)..." -ForegroundColor Cyan
python test_async_ai.py

# 5. Git Commit
git add api\proses_ai.py test_async_ai.py
git commit -m "feat(step-2): implement parallel dual AI chaining with asyncio.gather"

Write-Host "`n>>> [LANGKAH 2 SELESAI] Endpoint async AI dan benchmark konkurensi selesai dieksekusi!" -ForegroundColor Green
