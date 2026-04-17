# Node-RED Installation

Runbook para instalação de Node-RED com PM2 em sistemas baseados em apt.

## Script relacionado

- scripts/install/install-node-red.sh

## Pré-requisitos

- Ubuntu/Debian.
- Acesso root via sudo.
- Usuário alvo existente.

## Uso rápido

```bash
sudo bash scripts/install/install-node-red.sh
```

## Opções principais

```bash
--user <usuario>
--skip-system-update
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/install-node-red.sh --user automacao
sudo bash scripts/install/install-node-red.sh --skip-system-update
```

## Resultado esperado

- Node.js, npm, PM2 e Node-RED instalados.
- Processo node-red gerenciado pelo PM2.
- Startup do PM2 configurado para reinício automático.

## Validação

```bash
sudo -u <usuario> pm2 list
curl -I http://127.0.0.1:1880
```

## Troubleshooting

- Porta 1880 indisponível:
  - Verifique firewall local e bind do serviço.
- PM2 não sobe após reboot:
  - Reexecute configuração de startup do PM2 para o usuário alvo.
