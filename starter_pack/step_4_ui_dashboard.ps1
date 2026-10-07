# ==============================================================================
# SCRIPT OTOMASI LANGKAH 4: ADVANCED UI RECONSTRUCTION (SECURITY DASHBOARD)
# ==============================================================================
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LANGKAH 4] MERANCANG ANTARMUKA DASHBOARD CYBER SECURITY..." -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Pastikan folder public ada
New-Item -ItemType Directory -Force -Path "public" | Out-Null

# 2. Salin aset frontend dari starter_pack/ui ke public dan root
if (Test-Path "starter_pack\ui\index.html") {
    Copy-Item "starter_pack\ui\index.html" "index.html" -Force
    Copy-Item "starter_pack\ui\style.css" "style.css" -Force
    Copy-Item "starter_pack\ui\app.js" "app.js" -Force
    
    Copy-Item "starter_pack\ui\index.html" "public\index.html" -Force
    Copy-Item "starter_pack\ui\style.css" "public\style.css" -Force
    Copy-Item "starter_pack\ui\app.js" "public\app.js" -Force
}

# 3. Git Commit
git add index.html style.css app.js public\index.html public\style.css public\app.js
git commit -m "feat(step-4): reconstruct advanced dark glassmorphism security dashboard with Web Crypto API"

Write-Host "`n>>> [LANGKAH 4 SELESAI] Dashboard antarmuka premium, Web Crypto API, dan log console telah aktif!" -ForegroundColor Green
Write-Host ">>> Seluruh 4 langkah implementasi proyek telah lengkap dan siap di-deploy!" -ForegroundColor Green
