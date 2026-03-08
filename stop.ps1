# Stop gateway and auto-commit config changes
docker compose down

$dataDir = (Get-Content .env | Where-Object { $_ -match '^OPENCLAW_CONFIG_DIR=' }) -replace 'OPENCLAW_CONFIG_DIR=', ''
$dataRoot = Split-Path $dataDir -Parent

if (Test-Path "$dataRoot\.git") {
    Push-Location $dataRoot
    $changes = git status --porcelain
    if ($changes) {
        Write-Host "[sync] Config changes detected, committing..." -ForegroundColor Cyan
        git add -A
        git commit -m "auto: sync config $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push
        Write-Host "[sync] Pushed to remote." -ForegroundColor Green
    } else {
        Write-Host "[sync] No config changes." -ForegroundColor Gray
    }
    Pop-Location
}

Write-Host "[done] Gateway stopped." -ForegroundColor Green
