# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2024-01-XX

### Adicionado
- Helm Chart inicial para Wazuh 5.0.0
- StatefulSet para Wazuh Manager (Master e Workers)
- StatefulSet para Wazuh Indexer
- Deployment para Wazuh Dashboard
- Suporte para múltiplos ambientes (local, EKS)
- Network Policies opcionais
- Configuração de RBAC
- Secrets para credenciais e certificados TLS
- Ingress configurável para Dashboard
- Health checks (liveness e readiness probes)
- Documentação completa
- Valores padrão para desenvolvimento e produção
- Suporte para customização via values.yaml
- Anti-affinity para Workers
- Init containers para configuração inicial
- Persistent Volume Claims para dados

### Configurações Disponíveis
- Replicação configurável para todos os componentes
- Recursos (CPU/Memory) ajustáveis
- StorageClass configurável
- Imagens customizáveis
- Node selectors, tolerations e affinity
- Annotations e labels customizáveis

## [Unreleased]

### Planejado
- [ ] Suporte para backup automático
- [ ] Integração com Prometheus/Grafana
- [ ] Suporte para múltiplos clusters
- [ ] Auto-scaling (HPA)
- [ ] Suporte para Service Mesh
- [ ] Certificados automáticos via cert-manager
- [ ] Exemplos de configuração avançada
- [ ] Testes automatizados