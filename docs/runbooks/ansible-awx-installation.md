# Ansible AWX Installation & Operation

Runbook oficial para instalar, operar e desinstalar AWX usando o script consolidado do repositório.

## Script relacionado

- scripts/install/install-ansible-awx.sh

## Modos de instalação suportados

- auto: seleciona legacy ou operator de acordo com a estrutura da versão AWX baixada.
- legacy: fluxo baseado em installer + Docker Compose.
- operator: fluxo Kubernetes com AWX Operator.

## Pré-requisitos

- Acesso root via sudo.
- Conectividade com internet para baixar AWX e dependências.
- Para modo operator: kubectl configurado e cluster Kubernetes acessível.

## Uso rápido

```bash
sudo bash scripts/install/install-ansible-awx.sh
```

## Opções principais

```bash
--awx-version <version>
--admin-user <username>
--admin-password <password>
--docker-compose <version>
--install-method <auto|legacy|operator>
--operator-version <version>
--namespace <name>
--awx-name <name>
--kube-rbac-proxy-image <image>
--skip-system-update
--reboot
```

## Exemplos de instalação

### Auto (recomendado)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 24.6.1 \
  --admin-user admin
```

### Legacy (Docker Compose)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 17.1.0 \
  --install-method legacy
```

### Operator (Kubernetes)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 24.6.1 \
  --install-method operator \
  --namespace awx \
  --awx-name awx
```

## Resultado esperado

### Legacy

- Stack AWX criada com Docker Compose.
- Credenciais aplicadas no inventory durante instalação.
- Serviço acessível via host local/rede.

### Operator

- Namespace Kubernetes criado (se não existir).
- AWX Operator aplicado e deployment pronto.
- Custom Resource AWX aplicada com admin_user/admin_password_secret.

## Validação

### Legacy

```bash
docker ps | grep -i awx || true
cd ~/.awx/awxcompose && (docker compose ps || docker-compose ps)
```

### Operator

```bash
kubectl -n awx get pods
kubectl -n awx get awx
kubectl -n awx get svc
```

## Desinstalação

O script suporta desinstalação de recursos operator e legado.

### Desinstalação padrão

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --namespace awx \
  --awx-name awx
```

### Remover também o operator

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --remove-operator \
  --namespace awx \
  --awx-name awx
```

### Modo destrutivo

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --destructive-uninstall \
  --remove-operator \
  --namespace awx \
  --awx-name awx
```

Atenção: modo destrutivo remove namespace/PVC/secrets/PV e artefatos locais legados.

## Troubleshooting

- kubectl não acessa cluster no modo operator:
  - Verifique contexto com kubectl config current-context.
  - Valide acesso ao cluster com kubectl cluster-info.
- Minikube não está rodando:
  - Inicie com minikube start antes de usar operator.
- Erro em docker-compose no modo legacy:
  - O script trata fallback compose plugin/standalone e tenta recuperação de erro conhecido ContainerConfig.
- Permissões após instalação Docker:
  - Faça novo login da sessão para aplicar grupo docker.

## Comandos úteis

```bash
# Senha admin (operator)
kubectl -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 -d && echo

# Estado do operator
kubectl -n awx get deployment awx-operator-controller-manager

# Logs do operator
kubectl -n awx logs deployment/awx-operator-controller-manager
```

## Referências

- Script: scripts/install/install-ansible-awx.sh
- Runbooks relacionados:
  - docs/runbooks/docker-installation.md
  - docs/runbooks/minikube-installation-ubuntu.md
