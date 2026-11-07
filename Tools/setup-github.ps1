# Jednorázové založení Gitu a GitHubu pro VandalSimulator (kroky 0.2 a 0.5 z ROADMAP.md).

$ErrorActionPreference = 'Continue'
Set-Location (Split-Path $PSScriptRoot -Parent)

$repo = 'sickofideas/VandalSimulator'

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  3D Vandal Simulator - Spojení projektu s GitHubem" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# --- 1. Nastavení Git identity, pokud chybí ---
Write-Host "`n[1/5] Kontrola Git identity..." -ForegroundColor Yellow
$userName = git config user.name
$userEmail = git config user.email

if (-not $userName) {
    git config user.name "sickofideas"
    Write-Host "Nastaveno user.name = sickofideas" -ForegroundColor Green
}
if (-not $userEmail) {
    git config user.email "sickofideas@users.noreply.github.com"
    Write-Host "Nastaveno user.email = sickofideas@users.noreply.github.com" -ForegroundColor Green
}

git lfs install

# --- 2. Kontrola repozitáře a commitu ---
Write-Host "`n[2/5] Priprava souboru k odeslani..." -ForegroundColor Yellow
if (-not (Test-Path .git)) {
    git init -b main
}

Write-Host "Pridavam soubory do gitu (git add)..." -ForegroundColor Yellow
git add -A

Write-Host "Stav gitu:" -ForegroundColor Gray
git status -s

Write-Host "`nVytvarim commit..." -ForegroundColor Yellow
git commit -m "0.2-0.5: zaklad projektu, AGENTS.md, WebGL build na GitHub Pages"

git branch -M main

# --- 3. Nastavení vzdáleného repozitáře (remote origin) ---
Write-Host "`n[3/5] Kontrola remote origin..." -ForegroundColor Yellow
$remotes = git remote
if ($remotes -contains 'origin') {
    git remote set-url origin "https://github.com/$repo.git"
} else {
    git remote add origin "https://github.com/$repo.git"
}
Write-Host "Remote origin nastaven na: https://github.com/$repo.git" -ForegroundColor Green

# --- 4. Nastavení GitHub Pages na GitHub Actions ---
Write-Host "`n[4/5] Kontrola GitHub Pages..." -ForegroundColor Yellow
gh api -X POST "repos/$repo/pages" -f build_type=workflow 2>$null | Out-Null

# --- 5. Odeslání na GitHub (Push) ---
Write-Host "`n[5/5] Odesilam projekt na GitHub (git push)..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nNormalni push neprosel, zkousim force push do vetve main..." -ForegroundColor Yellow
    git push -u origin main --force
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "  SKVELE! Projekt byl uspesne odeslan na GitHub!" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "GitHub repozitar: https://github.com/$repo" -ForegroundColor White
    Write-Host "Prubeh buildu:    https://github.com/$repo/actions" -ForegroundColor White
    Write-Host "Adresa hry:       https://sickofideas.github.io/VandalSimulator" -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "`nOdeslani stale selhalo. Zkontroluj prosim chybovou hlasku vyse." -ForegroundColor Red
}
