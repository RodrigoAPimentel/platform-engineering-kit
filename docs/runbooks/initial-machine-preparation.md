# Initial Machine Preparation

Runbook para preparação inicial de hosts Linux com suporte a apt, dnf e yum.

## Script relacionado

- scripts/install/initial-machine-preparation.sh

## Pré-requisitos

- Acesso root via sudo.
- Host com conectividade de rede para repositórios.

## Uso rápido

```bash
sudo bash scripts/install/initial-machine-preparation.sh
```

## Opções principais

```bash
--skip-system-update
--skip-openssh
--skip-firewall
--locale <valor>
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/initial-machine-preparation.sh --locale pt_BR.UTF-8
sudo bash scripts/install/initial-machine-preparation.sh --skip-firewall
sudo bash scripts/install/initial-machine-preparation.sh --reboot
```

## Resultado esperado

- Locale da sessão ajustado.
- Pacotes do sistema atualizados (quando não ignorado).
- OpenSSH instalado e habilitado (quando não ignorado).
- Firewall liberado para SSH se firewalld estiver ativo.

## Validação

```bash
systemctl is-active ssh || systemctl is-active sshd
locale
```

## Troubleshooting

- EPEL indisponível em distro específica:
  - O script continua com aviso; valide repositórios locais.
- firewalld inativo:
  - O script pula a etapa de firewall e registra sugestão.
