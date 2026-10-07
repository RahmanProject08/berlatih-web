# ==============================================================================
# SCRIPT OTOMASI LANGKAH 1: DEVSECOPS CI/CD PIPELINE & INJEKSI ENVIRONMENT VARIABLES
# ==============================================================================
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LANGKAH 1] MENJALANKAN INISIALISASI CI/CD & ENVS..." -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Pastikan folder .github/workflows dibuat
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
New-Item -ItemType Directory -Force -Path "api" | Out-Null
New-Item -ItemType Directory -Force -Path "public" | Out-Null

# 2. Buat file .github/workflows/deploy.yml menggunakan string verbatim (single quote here-string)
@'
name: Deploy Security Dashboard to Vercel

on:
  push:
    branches:
      - main
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install Vercel CLI
        run: npm install -g vercel

      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}

      - name: Build Project Artifacts
        run: vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}

      - name: Deploy Project Artifacts to Vercel
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
          HMAC_SECRET: ${{ secrets.HMAC_SECRET }}
          TELEGRAM_BOT_TOKEN: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          TELEGRAM_CHAT_ID: ${{ secrets.TELEGRAM_CHAT_ID }}
        run: vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
'@ | Set-Content -Path ".github\workflows\deploy.yml" -Encoding UTF8

# 3. Buat file .gitignore
@'
# Environment & Secrets
.env
__pycache__/
*.pyc
venv/
node_modules/
.vercel/
'@ | Set-Content -Path ".gitignore" -Encoding UTF8

# 4. Buat package.json & requirements.txt dasar
@'
{
  "name": "berlatih-web",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "test:flows": "node scripts/test_flows.js"
  }
}
'@ | Set-Content -Path "package.json" -Encoding UTF8

@'
fastapi>=0.115.0
uvicorn>=0.30.0
pydantic>=2.0.0
'@ | Set-Content -Path "requirements.txt" -Encoding UTF8

# 5. Buat pyproject.toml untuk kompatibilitas Vercel CLI 62+
@'
[project]
name = "berlatih-web"
version = "0.1.0"
description = "Integrated Web Security Operations Center"
readme = "README.md"
requires-python = ">=3.9"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn>=0.30.0",
    "pydantic>=2.0.0"
]

[tool.vercel]
entrypoint = "api.proses_ai:app"
'@ | Set-Content -Path "pyproject.toml" -Encoding UTF8

@'
# Berlatih Web - Security Operations Center
Pipeline otomatis GitHub Actions ke Vercel dengan injeksi Environment Variables.
'@ | Set-Content -Path "README.md" -Encoding UTF8

# 6. Buat vercel.json
@'
{
  "cleanUrls": true,
  "rewrites": [
    {
      "source": "/api/proses_ai",
      "destination": "/api/proses_ai.py"
    },
    {
      "source": "/api/webhook",
      "destination": "/api/webhook.js"
    }
  ]
}
'@ | Set-Content -Path "vercel.json" -Encoding UTF8

# 7. Git Inisialisasi & Commit
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

git add .
git commit -m "feat(step-1): initialize CI/CD pipeline and environment injection config"

Write-Host "`n>>> [LANGKAH 1 SELESAI] Pipeline CI/CD, vercel.json, dan konfigurasi env telah siap!" -ForegroundColor Green
Write-Host ">>> Lanjutkan dengan git push ke repositori GitHub Anda." -ForegroundColor Green
