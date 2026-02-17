#!/bin/bash

# Script para criar estrutura completa do Helm Chart Wazuh
# Execute: bash setup-helm-chart.sh

set -e

echo "🚀 Criando estrutura do Helm Chart Wazuh..."

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Criar estrutura de diretórios
echo -e "${BLUE}📁 Criando diretórios...${NC}"
mkdir -p charts/wazuh/templates/{wazuh-manager,wazuh-indexer,wazuh-dashboard,secrets,networkpolicies}
mkdir -p .github/workflows
mkdir -p scripts
mkdir -p docs

echo -e "${GREEN}✓ Estrutura de diretórios criada${NC}"

# Agora você precisa:
echo ""
echo "======================================================================"
echo "📝 PRÓXIMOS PASSOS:"
echo "======================================================================"
echo ""
echo "Os arquivos precisam ser copiados manualmente desta conversa."
echo ""
echo "Abra esta conversa no navegador e copie cada arquivo para:"
echo ""
echo "1. Chart.yaml → charts/wazuh/Chart.yaml"
echo "2. values.yaml → charts/wazuh/values.yaml"
echo "3. values-eks.yaml → charts/wazuh/values-eks.yaml"
echo "4. values-local.yaml → charts/wazuh/values-local.yaml"
echo "5. README.md (do chart) → charts/wazuh/README.md"
echo "6. INSTALL.md → charts/wazuh/INSTALL.md"
echo "7. .helmignore → charts/wazuh/.helmignore"
echo ""
echo "Templates em charts/wazuh/templates/:"
echo "  - NOTES.txt"
echo "  - _helpers.tpl"
echo "  - serviceaccount.yaml"
echo "  - rbac.yaml"
echo ""
echo "Templates do Manager em charts/wazuh/templates/wazuh-manager/:"
echo "  - master-statefulset.yaml"
echo "  - worker-statefulset.yaml"
echo "  - services.yaml"
echo ""
echo "Templates do Indexer em charts/wazuh/templates/wazuh-indexer/:"
echo "  - statefulset.yaml"
echo "  - service.yaml"
echo ""
echo "Templates do Dashboard em charts/wazuh/templates/wazuh-dashboard/:"
echo "  - deployment.yaml"
echo "  - service.yaml"
echo "  - ingress.yaml"
echo ""
echo "Secrets em charts/wazuh/templates/secrets/:"
echo "  - indexer-cred-secret.yaml"
echo "  - dashboard-cred-secret.yaml"
echo "  - wazuh-api-cred-secret.yaml"
echo "  - authd-pass-secret.yaml"
echo "  - tls-certs-secret.yaml"
echo ""
echo "Network Policies em charts/wazuh/templates/networkpolicies/:"
echo "  - indexer-networkpolicy.yaml"
echo "  - dashboard-networkpolicy.yaml"
echo ""
echo "Arquivos raiz:"
echo "  - README.md (principal)"
echo "  - CHANGELOG.md"
echo "  - GITHUB_SETUP.md"
echo "  - .gitignore"
echo "  - artifacthub-repo.yml"
echo ""
echo "Workflows em .github/workflows/:"
echo "  - release.yaml"
echo ""
echo "======================================================================"