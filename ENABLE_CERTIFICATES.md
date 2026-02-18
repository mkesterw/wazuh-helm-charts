# Como Habilitar Certificados TLS no Wazuh Helm Chart

Por padrão, o chart funciona **sem segurança TLS** para facilitar a instalação inicial. Para habilitar certificados TLS em produção, siga os passos abaixo:

## Pré-requisitos

O cert-manager deve estar instalado no cluster Kubernetes.

## Passo 1: Instalar o cert-manager

Execute no servidor Kubernetes:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
```

Aguarde todos os pods ficarem prontos:

```bash
kubectl wait --for=condition=Available --timeout=300s \
  deployment/cert-manager -n cert-manager

kubectl wait --for=condition=Available --timeout=300s \
  deployment/cert-manager-webhook -n cert-manager

kubectl wait --for=condition=Available --timeout=300s \
  deployment/cert-manager-cainjector -n cert-manager
```

Verifique:

```bash
kubectl get pods -n cert-manager
```

Todos os pods devem estar `Running`.

## Passo 2: Habilitar Certificados no Wazuh

Edite o arquivo `values.yaml`:

```yaml
certificates:
  enabled: true  # ← Mudar de false para true
  duration: 2160h
  renewBefore: 360h
```

E ajuste as configurações do dashboard:

```yaml
wazuhDashboard:
  env:
    opensearchHosts: "https://wazuh-indexer:9200"  # ← Mudar de http:// para https://
    serverSslEnabled: "true"  # ← Mudar de "false" para "true"
```

## Passo 3: Atualizar o Wazuh

Se já estiver instalado:

```bash
helm upgrade wazuh ./charts/wazuh -n ngsoc-model
```

Ou no Rancher, clique em **Upgrade** e aplique as mudanças no values.yaml.

## Passo 4: Verificar Certificados

```bash
# Ver certificados criados
kubectl get certificates -n ngsoc-model

# Ver secrets de certificados
kubectl get secrets -n ngsoc-model | grep certs

# Ver detalhes de um certificado
kubectl describe certificate wazuh-ca -n ngsoc-model
```

## Troubleshooting

### Certificados não são criados

```bash
# Ver logs do cert-manager
kubectl logs -n cert-manager deployment/cert-manager

# Ver events
kubectl get events -n ngsoc-model --sort-by='.lastTimestamp'
```

### Pod do indexer não inicia

```bash
# Ver logs
kubectl logs -n ngsoc-model wazuh-indexer-0

# Verificar init containers
kubectl logs -n ngsoc-model wazuh-indexer-0 -c fix-cert-permissions
```

### Dashboard não conecta ao indexer

Verifique se a URL está correta em `opensearchHosts` e se os certificados estão montados:

```bash
kubectl exec -n ngsoc-model wazuh-dashboard-xxx -- ls -la /usr/share/wazuh-dashboard/certs/
```

## Segurança Adicional

Após habilitar certificados, considere:

1. **Network Policies**: Habilitar no values.yaml
2. **RBAC**: Já habilitado por padrão
3. **Pod Security Policies**: Configurar conforme necessidade
4. **Autenticação forte**: Alterar senhas padrão no values.yaml

## Voltar para Modo Sem Segurança

Se precisar desabilitar temporariamente:

```yaml
certificates:
  enabled: false

wazuhDashboard:
  env:
    opensearchHosts: "http://wazuh-indexer:9200"
    serverSslEnabled: "false"
```

E faça upgrade novamente.
