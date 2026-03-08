# Pull latest config before starting gateway
$dataDir = (Get-Content .env | Where-Object { $_ -match '^OPENCLAW_CONFIG_DIR=' }) -replace 'OPENCLAW_CONFIG_DIR=', ''
$dataRoot = Split-Path $dataDir -Parent

if (Test-Path "$dataRoot\.git") {
    Write-Host "[sync] Pulling latest openclaw-data..." -ForegroundColor Cyan
    Push-Location $dataRoot
    git pull --rebase --autostash
    Pop-Location
}

docker compose up -d openclaw-gateway
Write-Host "[done] Gateway started." -ForegroundColor Green
