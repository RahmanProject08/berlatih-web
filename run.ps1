# ==============================================================================
# RUNNER UTAMA: RUN.PS1 (KONTROLER STEP 1, 2, 3, 4)
# ==============================================================================
param (
    [Parameter(Position=0)]
    [string]$Step
)

function Show-Menu {
    Clear-Host
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "      PENGEMBANGAN OPERASI SIBER 2026 - MODULAR STEP RUNNER      " -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " [1] LANGKAH 1: CI/CD Pipeline & Injeksi Environment Variables"
    Write-Host " [2] LANGKAH 2: Asynchronous AI Chaining (FastAPI Concurrency)"
    Write-Host " [3] LANGKAH 3: HMAC Secure Webhook & Telegram Bot Alert"
    Write-Host " [4] LANGKAH 4: Advanced UI Reconstruction (Security Dashboard)"
    Write-Host " [Q] Keluar"
    Write-Host "=================================================================" -ForegroundColor Cyan
}

if (-not $Step) {
    Show-Menu
    $Step = Read-Host "Pilih nomor langkah yang ingin dijalankan (1/2/3/4)"
}

switch ($Step) {
    "1" {
        & ".\starter_pack\step_1_cicd.ps1"
    }
    "2" {
        & ".\starter_pack\step_2_async_ai.ps1"
    }
    "3" {
        & ".\starter_pack\step_3_hmac_webhook.ps1"
    }
    "4" {
        & ".\starter_pack\step_4_ui_dashboard.ps1"
    }
    default {
        Write-Host "Pilihan tidak valid. Silakan jalankan: .\run.ps1 1 (atau 2 / 3 / 4)" -ForegroundColor Red
    }
}
