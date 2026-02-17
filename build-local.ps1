# Script para testar build localmente no Windows
Write-Host "🔧 Building Wazuh Helm Chart locally..." -ForegroundColor Cyan

# Verificar se Helm está instalado
if (!(Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Helm não encontrado! Instale: https://helm.sh/docs/intro/install/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Helm encontrado: $(helm version --short)" -ForegroundColor Green

# Adicionar repos
Write-Host "`n📥 Adicionando repositórios Helm..." -ForegroundColor Cyan
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Build dependencies
Write-Host "`n📦 Baixando dependências..." -ForegroundColor Cyan
Push-Location charts/wazuh
helm dependency build

# Verificar
if (Test-Path "charts/cert-manager-v1.14.4.tgz") {
    Write-Host "✅ cert-manager baixado" -ForegroundColor Green
    Get-ChildItem charts/*.tgz | ForEach-Object { 
        Write-Host "   - $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ cert-manager NÃO foi baixado!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# Validar
Write-Host "`n✅ Validando chart..." -ForegroundColor Cyan
helm lint charts/wazuh

# Empacotar
Write-Host "`n📦 Empacotando chart..." -ForegroundColor Cyan
helm package charts/wazuh

# Verificar conteúdo
$chartFile = Get-ChildItem wazuh-*.tgz | Select-Object -First 1
Write-Host "`n🔍 Verificando conteúdo do pacote..." -ForegroundColor Cyan
Write-Host "   Arquivo: $($chartFile.Name) ($([math]::Round($chartFile.Length/1KB, 2)) KB)" -ForegroundColor Gray

# Usar 7zip ou tar (se disponível)
if (Get-Command tar -ErrorAction SilentlyContinue) {
    $certManagerFiles = tar -tzf $chartFile.Name | Select-String "cert-manager"
    if ($certManagerFiles) {
        Write-Host "✅ cert-manager encontrado no pacote ($($certManagerFiles.Count) arquivos)" -ForegroundColor Green
    } else {
        Write-Host "❌ cert-manager NÃO encontrado no pacote!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "`n📦 Chart pronto: $($chartFile.FullName)" -ForegroundColor Cyan
Write-Host "`n🚀 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Commit e push: git add . && git commit -m 'Build chart' && git push" -ForegroundColor Gray
Write-Host "   2. Criar tag: git tag v1.0.2 && git push origin v1.0.2" -ForegroundColor Gray
Write-Host "   3. GitHub Actions vai buildar automaticamente" -ForegroundColor Gray
Write-Host "   4. Instalar no Rancher usando GitHub Pages" -ForegroundColor Gray