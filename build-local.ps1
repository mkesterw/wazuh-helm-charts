# Script para testar build localmente no Windows
Write-Host "Building Wazuh Helm Chart locally..." -ForegroundColor Cyan

# Verificar se Helm esta instalado
if (!(Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Helm not found! Install from: https://helm.sh/docs/intro/install/" -ForegroundColor Red
    exit 1
}

Write-Host "OK: Helm found: $(helm version --short)" -ForegroundColor Green

# Adicionar repos
Write-Host "`nAdding Helm repositories..." -ForegroundColor Cyan
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Build dependencies
Write-Host "`nDownloading dependencies..." -ForegroundColor Cyan
Push-Location charts/wazuh
helm dependency build

# Verificar
if (Test-Path "charts/cert-manager-v1.14.4.tgz") {
    Write-Host "OK: cert-manager downloaded" -ForegroundColor Green
    Get-ChildItem charts/*.tgz | ForEach-Object { 
        $sizeKB = [math]::Round($_.Length/1KB, 2)
        Write-Host "   - $($_.Name) ($sizeKB KB)" -ForegroundColor Gray
    }
} else {
    Write-Host "ERROR: cert-manager was NOT downloaded!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# Validar
Write-Host "`nValidating chart..." -ForegroundColor Cyan
helm lint charts/wazuh

# Empacotar
Write-Host "`nPackaging chart..." -ForegroundColor Cyan
helm package charts/wazuh

# Verificar conteudo
$chartFile = Get-ChildItem wazuh-*.tgz | Select-Object -First 1
Write-Host "`nVerifying package contents..." -ForegroundColor Cyan
$sizeKB = [math]::Round($chartFile.Length/1KB, 2)
Write-Host "   File: $($chartFile.Name) ($sizeKB KB)" -ForegroundColor Gray

# Usar tar (se disponivel)
if (Get-Command tar -ErrorAction SilentlyContinue) {
    $certManagerFiles = tar -tzf $chartFile.Name | Select-String "cert-manager"
    if ($certManagerFiles) {
        $count = ($certManagerFiles | Measure-Object).Count
        Write-Host "OK: cert-manager found in package ($count files)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: cert-manager NOT found in package!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "WARNING: tar command not found, skipping package verification" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SUCCESS: Build completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nChart ready: $($chartFile.FullName)" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "   1. Commit and push: git add . && git commit -m 'Build chart' && git push" -ForegroundColor Gray
Write-Host "   2. Create tag: git tag v1.0.2 && git push origin v1.0.2" -ForegroundColor Gray
Write-Host "   3. GitHub Actions will build automatically" -ForegroundColor Gray
Write-Host "   4. Install on Rancher using GitHub Pages" -ForegroundColor Gray