# 📖 Guia de Instalação Completo

## Via Rancher (Recomendado)

### 1. Adicionar Repositório

```bash
# Via kubectl
cat <<EOF | kubectl apply -f -
apiVersion: catalog.cattle.io/v1
kind: ClusterRepo
metadata:
  name: wazuh
spec:
  url: https://SEU_USUARIO.github.io/wazuh-helm-charts/packages
EOF
```

Ou via UI:
- **Apps** → **Repositories** → **Create**
- **Name**: `wazuh`
- **Index URL**: `https://SEU_USUARIO.github.io/wazuh-helm-charts/packages`

### 2. Instalar via UI

1. **Apps** → **Charts** → Procurar "wazuh"
2. **Install**
3. Configurar:
   - **Namespace**: `wazuh` (criar novo)
   - **cert-manager enabled**: ✅ true
   - **Senhas**: Alterar senhas padrão
4. **Install**
5. Aguardar (5-10 minutos)

## Via Helm CLI

```bash
# 1. Adicionar repo
helm repo add wazuh https://SEU_USUARIO.github.io/wazuh-helm-charts/packages
helm repo update

# 2. Instalar cert-manager (se não tiver)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

# 3. Configurar vm.max_map_count
sudo sysctl -w vm.max_map_count=262144

# 4. Instalar Wazuh
helm install wazuh wazuh/wazuh \
  --namespace wazuh \
  --create-namespace \
  --set certificates.enabled=true \
  --timeout 15m

# 5. Acompanhar
kubectl get pods -n wazuh -w
```

## Acessar Dashboard

```bash
# Ver NodePort
kubectl get svc -n wazuh wazuh-dashboard

# Port-forward
kubectl port-forward -n wazuh svc/wazuh-dashboard 5601:443

# Acesse: https://localhost:5601
```

**Credenciais:**
- Username: `admin`
- Password: `SecurePassword123!`

## Troubleshooting

### Pods não iniciam

```bash
# Verificar vm.max_map_count
sysctl vm.max_map_count  # Deve ser >= 262144

# Configurar se necessário
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Certificados não gerados

```bash
# Verificar cert-manager
kubectl get pods -n cert-manager

# Ver certificados
kubectl get certificates -n wazuh
kubectl describe certificate -n wazuh
```

## Desinstalar

```bash
helm uninstall wazuh -n wazuh
kubectl delete namespace wazuh
```