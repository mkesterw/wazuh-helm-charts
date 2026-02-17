#!/bin/bash

set -e

echo "🔧 Corrigindo instalação do Wazuh..."
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Deletar arquivos obsoletos
echo "🗑️  Removendo arquivos obsoletos de certificados..."
rm -f charts/wazuh/templates/secrets/tls-certs-secret.yaml
rm -f charts/wazuh/templates/secrets/indexer-certs-secret.yaml
rm -f charts/wazuh/templates/secrets/dashboard-certs-secret.yaml
rm -f charts/wazuh/templates/secrets/tls-*.yaml
echo -e "${GREEN}✅ Arquivos obsoletos removidos${NC}"
echo ""

# 2. Verificar cert-manager
echo "🔍 Verificando cert-manager..."
if ! kubectl get namespace cert-manager &> /dev/null; then
    echo -e "${YELLOW}📥 Instalando cert-manager...${NC}"
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
fi

echo "⏳ Aguardando cert-manager estar completamente pronto..."
sleep 10

# Aguardar TODOS os pods do cert-manager
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=cert-manager \
  -n cert-manager \
  --timeout=300s || echo -e "${YELLOW}⚠️  Timeout aguardando cert-manager${NC}"

# Verificar se os pods estão realmente rodando
CERT_MANAGER_PODS=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | grep -c "Running" || echo "0")
echo "Pods do cert-manager rodando: $CERT_MANAGER_PODS"

if [ "$CERT_MANAGER_PODS" -lt 3 ]; then
    echo -e "${RED}❌ cert-manager não está completamente pronto${NC}"
    echo "Pods atuais:"
    kubectl get pods -n cert-manager
    echo ""
    echo "Aguarde mais um momento e tente novamente"
    exit 1
fi

echo -e "${GREEN}✅ cert-manager está pronto${NC}"
echo ""

# 3. Configurar vm.max_map_count
echo "⚙️  Configurando vm.max_map_count..."
sudo sysctl -w vm.max_map_count=262144
echo -e "${GREEN}✅ vm.max_map_count configurado${NC}"
echo ""

# 4. Limpar instalação anterior
NAMESPACE="ngsoc-model"
if helm list -n $NAMESPACE 2>/dev/null | grep -q "wazuh"; then
    echo "🗑️  Removendo instalação anterior..."
    helm uninstall wazuh -n $NAMESPACE
    sleep 5
fi

# 5. Validar chart
echo "🔍 Validando chart..."
if ! helm lint charts/wazuh; then
    echo -e "${RED}❌ Erro de validação no chart${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Chart válido${NC}"
echo ""

# 6. Reempacotar
echo "📦 Reempacotando chart..."
helm package charts/wazuh -d /tmp/
CHART_FILE=$(ls -t /tmp/wazuh-*.tgz | head -1)
echo "Chart criado: $CHART_FILE"

# 7. Copiar para Rancher (se necessário)
if [ -d "/home/shell/helm" ]; then
    cp $CHART_FILE /home/shell/helm/
    echo "Chart copiado para Rancher"
fi
echo ""

# 8. Instalar
echo "🚀 Instalando Wazuh..."
helm install wazuh $CHART_FILE \
    --namespace $NAMESPACE \
    --create-namespace \
    --set certificates.enabled=true \
    --timeout 10m \
    --wait

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
    echo ""
    echo "📊 Status dos pods:"
    kubectl get pods -n $NAMESPACE
    echo ""
    echo "🔐 Certificados:"
    kubectl get certificates -n $NAMESPACE
else
    echo ""
    echo -e "${RED}❌ Erro na instalação${NC}"
    echo ""
    echo "Verificar logs:"
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl logs -n $NAMESPACE -l app=wazuh-indexer"
    exit 1
fi