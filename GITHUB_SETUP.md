# 🚀 Configuração do GitHub Pages para Helm Charts

Siga estes passos para configurar o repositório e publicar os Helm Charts:

## 1️⃣ Criar o Repositório

1. Acesse https://github.com/new
2. Nome sugerido: `wazuh-helm-charts`
3. Descrição: "Helm Charts para implantação do Wazuh no Kubernetes"
4. Marque como **Public**
5. Adicione um README
6. Escolha licença: **GPL-2.0**
7. Clique em **Create repository**

## 2️⃣ Clonar e Configurar Localmente

```bash
# Clonar o repositório
git clone https://github.com/SEU-USUARIO/wazuh-helm-charts.git
cd wazuh-helm-charts

# Criar estrutura de diretórios
mkdir -p charts/wazuh/templates/{wazuh-manager,wazuh-indexer,wazuh-dashboard,secrets,networkpolicies}
mkdir -p .github/workflows
mkdir -p docs
mkdir -p scripts

# Copiar todos os arquivos que criamos
# (cole todos os arquivos nas pastas correspondentes)
```

## 3️⃣ Configurar GitHub Pages

### Via Interface Web:

1. Vá para **Settings** do repositório
2. No menu lateral, clique em **Pages**
3. Em **Source**, selecione:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Clique em **Save**

### Via GitHub CLI (alternativa):

```bash
gh repo edit --enable-pages --pages-branch gh-pages
```

## 4️⃣ Configurar Secrets (se necessário)

Se você precisar de secrets adicionais:

1. Vá para **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**
3. Adicione os secrets necessários

**Nota**: O `GITHUB_TOKEN` já está disponível automaticamente.

## 5️⃣ Fazer o Primeiro Commit

```bash
# Adicionar todos os arquivos
git add .

# Commit
git commit -m "🎉 Initial commit: Wazuh Helm Chart v1.0.0"

# Push
git push origin main
```

## 6️⃣ Criar uma Tag para Release

```bash
# Criar tag
git tag -a v1.0.0 -m "Release v1.0.0 - Initial release"

# Push da tag
git push origin v1.0.0
```

## 7️⃣ Verificar o Workflow

1. Vá para **Actions** no GitHub
2. Você verá o workflow "Release Helm Charts" executando
3. Aguarde a conclusão (leva ~2-3 minutos)

## 8️⃣ Verificar GitHub Pages

Após o workflow completar:

1. Acesse: `https://SEU-USUARIO.github.io/wazuh-helm-charts/`
2. Você deve ver o arquivo `index.yaml` disponível

## 9️⃣ Testar a Instalação

```bash
# Adicionar o repositório
helm repo add wazuh https://SEU-USUARIO.github.io/wazuh-helm-charts

# Atualizar
helm repo update

# Buscar o chart
helm search repo wazuh

# Instalar (dry-run primeiro)
helm install wazuh wazuh/wazuh --dry-run --debug -n wazuh
```

## 🎊 Pronto!

Seu Helm Chart está publicado e disponível para uso!

### URLs Importantes:

- **Repositório**: `https://github.com/SEU-USUARIO/wazuh-helm-charts`
- **GitHub Pages**: `https://SEU-USUARIO.github.io/wazuh-helm-charts/`
- **Helm Repo**: `https://SEU-USUARIO.github.io/wazuh-helm-charts/`
- **Releases**: `https://github.com/SEU-USUARIO/wazuh-helm-charts/releases`

## 🔄 Atualizações Futuras

Para publicar uma nova versão:

```bash
# 1. Atualizar a versão no Chart.yaml
vim charts/wazuh/Chart.yaml
# version: 1.1.0

# 2. Atualizar CHANGELOG.md
vim CHANGELOG.md

# 3. Commit
git add .
git commit -m "🔖 Bump version to 1.1.0"
git push

# 4. Criar nova tag
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0
```

O GitHub Actions automaticamente:
- Empacotará o chart
- Atualizará o index.yaml
- Publicará no GitHub Pages
- Criará uma release no GitHub

## 🐛 Troubleshooting

### Workflow falha

Verifique os logs em **Actions** → **Release Helm Charts** → clique no job falhado

### GitHub Pages não atualiza

1. Vá em **Settings** → **Pages**
2. Verifique se a branch `gh-pages` existe
3. Force um rebuild: faça um commit vazio e push

```bash
git commit --allow-empty -m "Trigger rebuild"
git push
```

### Chart não aparece no `helm search`

```bash
# Limpar cache local
helm repo remove wazuh
helm repo add wazuh https://SEU-USUARIO.github.io/wazuh-helm-charts
helm repo update

# Verificar se o index.yaml está acessível
curl https://SEU-USUARIO.github.io/wazuh-helm-charts/index.yaml
```