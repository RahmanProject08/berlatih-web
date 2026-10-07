# Script Helper untuk Menyiapkan .env Lokal
param (
    [string]$VercelToken,
    [string]$SupabaseUrl,
    [string]$SupabaseAnonKey,
    [string]$TelegramBotToken,
    [string]$TelegramChatId,
    [string]$HmacSecret = "default_hmac_secret_key_2026"
)

if (-not $VercelToken) {
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host " SETUP KREDENSIAL RAHASIA (ENVIRONMENT VARIABLES)" -ForegroundColor Yellow
    Write-Host "==============================================================" -ForegroundColor Cyan
    $VercelToken = Read-Host "1. Masukkan VERCEL_TOKEN"
    $SupabaseUrl = Read-Host "2. Masukkan SUPABASE_URL"
    $SupabaseAnonKey = Read-Host "3. Masukkan SUPABASE_ANON_KEY"
    $TelegramBotToken = Read-Host "4. Masukkan TELEGRAM_BOT_TOKEN"
    $TelegramChatId = Read-Host "5. Masukkan TELEGRAM_CHAT_ID"
    $HmacInput = Read-Host "6. Masukkan HMAC_SECRET (Tekan Enter untuk default)"
    if ($HmacInput) { $HmacSecret = $HmacInput }
}

$envContent = @"
VERCEL_TOKEN=$VercelToken
SUPABASE_URL=$SupabaseUrl
SUPABASE_ANON_KEY=$SupabaseAnonKey
TELEGRAM_BOT_TOKEN=$TelegramBotToken
TELEGRAM_CHAT_ID=$TelegramChatId
HMAC_SECRET=$HmacSecret
"@

Set-Content -Path ".env" -Value $envContent -Encoding UTF8
Write-Host "`n>>> [BERHASIL] File .env lokal telah dibuat dan diamankan oleh .gitignore!" -ForegroundColor Green
Write-Host ">>> Gunakan nilai-nilai ini untuk didaftarkan ke GitHub Secrets & Vercel Settings." -ForegroundColor Green
