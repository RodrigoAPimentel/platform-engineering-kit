# OpenSSH Server Installation (Ubuntu/Debian)

Runbook para instalação e habilitação do OpenSSH Server em sistemas apt.

## Script relacionado

- scripts/install/install-openssh-server-ubuntu.sh

## Pré-requisitos

- Ubuntu/Debian.
- Acesso root via sudo.

## Uso rápido

```bash
sudo bash scripts/install/install-openssh-server-ubuntu.sh
```

## Opções principais

```bash
--skip-system-update
--disable-service
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/install-openssh-server-ubuntu.sh --skip-system-update
sudo bash scripts/install/install-openssh-server-ubuntu.sh --disable-service
```

## Resultado esperado

- Pacote openssh-server instalado.
- Serviço ssh ativo, exceto quando desabilitado por opção.

## Validação

```bash
systemctl status ssh --no-pager
ss -tulpen | grep ':22'
```

## Troubleshooting

- Serviço não inicia:
  - Verifique conflitos de porta e arquivo de configuração do sshd.
- Acesso remoto falha:
  - Confirme regras de firewall e rota de rede.
