#!/bin/bash

set -e

echo "🚀 Instalação do Wazuh com Certificados Válidos"
echo "================================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
NAMESPACE="wazuh"
RELEASE_NAME="wazuh"
CHART_PATH="./charts/wazuh"

# Função para verificar comandos
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 não encontrado. Por favor, instale $1${NC}"
        exit 1
    fi
}

# Verificar dependências
echo "📋 Verificando dependências..."
check_command kubectl
check_command helm
echo -e "${GREEN}✅ Dependências OK${NC}"
echo ""

# Verificar se cert-manager está instalado
echo "🔍 Verificando cert-manager..."
if kubectl get namespace cert-manager &> /dev/null; then
    echo -e "${GREEN}✅ cert-manager já está instalado${NC}"
else
    echo -e "${YELLOW}⚠️  cert-manager não encontrado. Instalando...${NC}"
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
    
    echo "⏳ Aguardando cert-manager estar pronto..."
    kubectl wait --for=condition=ready pod \
        -l app.kubernetes.io/instance=cert-manager \
        -n cert-manager \
        --timeout=300s
    
    echo -e "${GREEN}✅ cert-manager instalado com sucesso${NC}"
fi
echo ""

# Configurar vm.max_map_count
echo "⚙️  Configurando vm.max_map_count no host..."
CURRENT_VALUE=$(sysctl -n vm.max_map_count)
if [ "$CURRENT_VALUE" -lt 262144 ]; then
    echo "Valor atual: $CURRENT_VALUE (muito baixo)"
    echo "Configurando para 262144..."
    sudo sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    echo -e "${GREEN}✅ vm.max_map_count configurado${NC}"
else
    echo -e "${GREEN}✅ vm.max_map_count já está correto ($CURRENT_VALUE)${NC}"
fi
echo ""

# Limpar instalação anterior (se existir)
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "🗑️  Removendo instalação anterior..."
    helm uninstall $RELEASE_NAME -n $NAMESPACE
    echo "⏳ Aguardando pods serem removidos..."
    sleep 10
fi

# Limpar namespace (se existir)
if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "🗑️  Removendo namespace anterior..."
    kubectl delete namespace $NAMESPACE --timeout=60s
    sleep 5
fi

# Criar namespace
echo "📦 Criando namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE
echo -e "${GREEN}✅ Namespace criado${NC}"
echo ""

# Validar chart
echo "🔍 Validando Helm chart..."
helm lint $CHART_PATH
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Chart válido${NC}"
else
    echo -e "${RED}❌ Chart inválido${NC}"
    exit 1
fi
echo ""

# Instalar Wazuh
echo "🚀 Instalando Wazuh..."
helm install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    --set certificates.enabled=true \
    --timeout 15m \
    --debug

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Wazuh instalado com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro na instalação${NC}"
    exit 1
fi
echo ""

# Aguardar pods
echo "⏳ Aguardando pods estarem prontos..."
echo "Isso pode levar alguns minutos..."
echo ""

# Monitorar pods
kubectl get pods -n $NAMESPACE -w &
WATCH_PID=$!

# Aguardar até que todos os pods estejam rodando
MAX_WAIT=600  # 10 minutos
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    TOTAL_PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
    RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    
    if [ "$TOTAL_PODS" -gt 0 ] && [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
        kill $WATCH_PID 2>/dev/null
        echo -e "${GREEN}✅ Todos os pods estão rodando!${NC}"
        break
    fi
    
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    kill $WATCH_PID 2>/dev/null
    echo -e "${YELLOW}⚠️  Timeout aguardando pods. Verifique manualmente.${NC}"
fi
echo ""

# Mostrar status
echo "📊 Status dos Pods:"
kubectl get pods -n $NAMESPACE
echo ""

echo "📊 Status dos Services:"
kubectl get svc -n $NAMESPACE
echo ""

echo "🔐 Certificados gerados:"
kubectl get certificates -n $NAMESPACE
echo ""

# Obter NodePort do Dashboard
DASHBOARD_PORT=$(kubectl get svc -n $NAMESPACE ${RELEASE_NAME}-dashboard -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)

echo "================================================"
echo -e "${GREEN}✅ Instalação Concluída!${NC}"
echo "================================================"
echo ""
echo "📌 Informações de Acesso:"
echo ""
if [ ! -z "$DASHBOARD_PORT" ] && [ ! -z "$NODE_IP" ]; then
    echo "🌐 Dashboard: https://$NODE_IP:$DASHBOARD_PORT"
else
    echo "🌐 Dashboard: Execute 'kubectl get svc -n $NAMESPACE' para ver a porta"
fi
echo ""
echo "👤 Credenciais padrão:"
echo "   Username: admin"
echo "   Password: SecurePassword123!"
echo ""
echo "📝 Comandos úteis:"
echo "   Ver pods: kubectl get pods -n $NAMESPACE"
echo "   Ver logs do indexer: kubectl logs -n $NAMESPACE -l app=wazuh-indexer"
echo "   Ver logs do dashboard: kubectl logs -n $NAMESPACE -l app=wazuh-dashboard"
echo "   Port-forward dashboard: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-dashboard 5601:443"
echo ""
echo "🔧 Para desinstalar:"
echo "   helm uninstall $RELEASE_NAME -n $NAMESPACE"
echo "   kubectl delete namespace $NAMESPACE"
echo ""