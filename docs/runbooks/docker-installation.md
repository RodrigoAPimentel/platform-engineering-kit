# Docker Installation

Runbook para instalação do Docker Engine e Docker Compose em distros apt, dnf e yum.

## Script relacionado

- scripts/install/install-docker.sh

## Pré-requisitos

- Acesso root via sudo.
- Usuário alvo existente no sistema.

## Uso rápido

```bash
sudo bash scripts/install/install-docker.sh
```

## Opções principais

```bash
--user <usuario>
--skip-system-update
--compose-fallback <versao>
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/install-docker.sh --user devops
sudo bash scripts/install/install-docker.sh --compose-fallback v2.29.7
sudo bash scripts/install/install-docker.sh --reboot
```

## Resultado esperado

- Docker instalado e serviço habilitado.
- Usuário adicionado ao grupo docker.
- Docker Compose plugin ativo ou fallback standalone instalado.

## Validação

```bash
docker --version
docker compose version || docker-compose --version
id "$USER" | grep docker
```

## Troubleshooting

- Plugin compose não disponível:
  - O script instala fallback standalone automaticamente.
- Permissão negada ao usar docker sem sudo:
  - Efetue novo login da sessão do usuário alvo.
