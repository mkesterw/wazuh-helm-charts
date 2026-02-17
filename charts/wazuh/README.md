# Wazuh Helm Chart

![Version: 1.0.2](https://img.shields.io/badge/Version-1.0.2-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 4.9.1](https://img.shields.io/badge/AppVersion-4.9.1-informational?style=flat-square)

Helm chart para implantação completa do Wazuh (SIEM/XDR) no Kubernetes.

## Componentes

- **Wazuh Manager**: Servidor central de gerenciamento
- **Wazuh Indexer**: OpenSearch para armazenamento de eventos
- **Wazuh Dashboard**: Interface web
- **cert-manager**: Geração automática de certificados TLS

## Pré-requisitos

- Kubernetes 1.19+
- Helm 3.2.0+
- 8GB+ de RAM
- 50GB+ de storage

## Instalação via Rancher

1. **Adicione o repositório do chart no Rancher**
2. **Instale o chart com as configurações desejadas**
3. O cert-manager será instalado automaticamente se habilitado

## Instalação via Helm CLI

```bash
# Adicionar repositório
helm repo add wazuh https://seu-repo.example.com
helm repo update

# Instalar
helm install wazuh wazuh/wazuh \
  --namespace wazuh \
  --create-namespace \
  --set cert-manager.enabled=true
```

## Configuração

### Habilitar cert-manager automático

```yaml
cert-manager:
  enabled: true
  installCRDs: true
```

### Configurar réplicas

```yaml
wazuhIndexer:
  replicaCount: 3

wazuhManager:
  worker:
    enabled: true
    replicaCount: 2
```

### Configurar storage

```yaml
wazuhIndexer:
  persistence:
    size: 100Gi
    storageClass: "fast-ssd"
```

### Configurar senhas

```yaml
secrets:
  indexer:
    password: "MinhaSenhaSegura123!"
  dashboard:
    password: "DashboardPassword!"
  wazuhApi:
    password: "APIPassword!"
```

## Acesso ao Dashboard

Após a instalação:

```bash
# Ver a porta do NodePort
kubectl get svc -n wazuh wazuh-dashboard

# Ou usar port-forward
kubectl port-forward -n wazuh svc/wazuh-dashboard 5601:443
```

Acesse: `https://localhost:5601`

**Credenciais padrão:**
- Username: `admin`
- Password: `SecurePassword123!`

## Troubleshooting

### Pods do Indexer não iniciam

Verifique o `vm.max_map_count`:

```bash
# No host do Kubernetes
sudo sysctl -w vm.max_map_count=262144
```

### Certificados não são gerados

Verifique o cert-manager:

```bash
kubectl get pods -n cert-manager
kubectl get certificates -n wazuh
```

### Dashboard não conecta ao Indexer

```bash
# Ver logs
kubectl logs -n wazuh -l app=wazuh-dashboard

# Testar conectividade
kubectl exec -n wazuh -it deploy/wazuh-dashboard -- curl -k https://wazuh-indexer:9200
```

## Valores

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert-manager.enabled | bool | `true` | Instalar cert-manager automaticamente |
| certificates.enabled | bool | `true` | Gerar certificados TLS |
| wazuhIndexer.enabled | bool | `true` | Habilitar Wazuh Indexer |
| wazuhIndexer.replicaCount | int | `1` | Número de réplicas |
| wazuhDashboard.enabled | bool | `true` | Habilitar Dashboard |
| wazuhManager.master.enabled | bool | `true` | Habilitar Manager Master |

## Suporte

- [Documentação Wazuh](https://documentation.wazuh.com)
- [GitHub Issues](https://github.com/seu-usuario/wazuh-helm-charts/issues)