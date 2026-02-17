# 🛠️ Guia para Desenvolvedores (Windows)

## Pré-requisitos Windows

### Instalar Helm

```powershell
# Via Chocolatey
choco install kubernetes-helm

# OU via Scoop
scoop install helm

# OU baixar: https://github.com/helm/helm/releases
```

### Instalar Git

```powershell
# Via Chocolatey
choco install git

# OU baixar: https://git-scm.com/download/win
```

## Workflow de Desenvolvimento

### 1. Clone do Repositório

```powershell
git clone https://github.com/SEU_USUARIO/wazuh-helm-charts.git
cd wazuh-helm-charts
code .  # Abre VS Code
```

### 2. Fazer Mudanças

Edite os arquivos no VS Code:
- `charts/wazuh/values.yaml` - Configurações
- `charts/wazuh/templates/` - Templates Kubernetes
- `charts/wazuh/Chart.yaml` - Metadados

### 3. Testar Build Localmente

```powershell
.\build-local.ps1
```

### 4. Commit e Push

```powershell
git add .
git commit -m "Descrição das mudanças"
git push origin main
```

### 5. Criar Release

```powershell
# Atualizar versão no Chart.yaml primeiro
# Depois criar tag
git tag v1.0.3
git push origin v1.0.3
```

### 6. GitHub Actions Roda Automaticamente

- Build do chart
- Download de dependências
- Empacotamento
- Publicação no GitHub Pages
- Criação de Release

### 7. Instalar no Rancher

Rancher detecta automaticamente a nova versão!

## Comandos Úteis

```powershell
# Validar chart
helm lint charts/wazuh

# Ver dependências
helm dependency list charts/wazuh

# Fazer dry-run
helm install wazuh charts/wazuh --dry-run --debug

# Testar templates
helm template wazuh charts/wazuh
```

## Troubleshooting

### Helm não encontrado

```powershell
# Verificar instalação
Get-Command helm

# Adicionar ao PATH se necessário
$env:Path += ";C:\path\to\helm"
```

### Erro de dependências

```powershell
# Limpar cache
helm repo update
Remove-Item charts/wazuh/charts/* -Recurse -Force
Remove-Item charts/wazuh/Chart.lock -Force

# Rebuild
cd charts/wazuh
helm dependency build
```