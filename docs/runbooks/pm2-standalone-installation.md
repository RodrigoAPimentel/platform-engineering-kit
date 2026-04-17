# PM2 Standalone Installation

Runbook para instalacao do PM2 como gerenciador de processos independente para um usuario alvo.

## Script relacionado

- scripts/install/standalone/install-pm2-standalone.sh

## Pre-requisitos

- Acesso root via sudo.
- Usuario alvo existente.
- npm disponivel para o usuario alvo (ou permitir auto-instalacao do helper Node.js).

## Uso rapido

```bash
sudo bash scripts/install/standalone/install-pm2-standalone.sh
```

## Opcoes principais

```bash
--user <usuario>
--skip-system-update
--skip-nodejs-install
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/standalone/install-pm2-standalone.sh --user automacao
sudo bash scripts/install/standalone/install-pm2-standalone.sh --skip-nodejs-install
```

## Resultado esperado

- PM2 instalado globalmente para o usuario alvo.
- Startup systemd do PM2 configurado.
- Snapshot PM2 salvo com pm2 save.

## Validacao

```bash
sudo -u <usuario> pm2 --version
sudo -u <usuario> pm2 list
systemctl status pm2-<usuario> --no-pager || true
```

## Troubleshooting

- npm ausente:
  - Rode sem --skip-nodejs-install para auto-instalar Node.js helper.
- PM2 nao inicia no boot:
  - Reexecutar configuracao de startup e validar unit systemd.
