# Node.js Standalone Installation

⚠️ **Atenção:** Este procedimento exige privilégios de root (`sudo`) e pode manipular secrets/senhas. Revise comandos antes de executar e evite expor credenciais em linha de comando, histórico de shell ou logs. Veja [security/secrets/README.md](../security/secrets/README.md) para boas práticas.

Runbook para instalacao de Node.js (via NVM) como runtime independente para um usuario alvo.

## Script relacionado

- scripts/install/standalone/install-nodejs-standalone.sh

## Pre-requisitos

- Acesso root via sudo.
- Usuario alvo existente.
- Conectividade com internet para baixar NVM/Node.js.

## Uso rapido

```bash
sudo bash scripts/install/standalone/install-nodejs-standalone.sh
```

## Opcoes principais

```bash
--user <usuario>
--node-version <versao>
--skip-system-update
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/standalone/install-nodejs-standalone.sh --user devops
sudo bash scripts/install/standalone/install-nodejs-standalone.sh --node-version 20
```

## Resultado esperado

- NVM instalado no home do usuario alvo.
- Node.js e npm instalados e configurados como default no NVM.

## Validacao

```bash
sudo -u <usuario> bash -lc 'export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && node --version && npm --version'
```

## Troubleshooting

- node nao encontrado na sessao:
  - Abra nova sessao do usuario ou carregue nvm.sh manualmente.
- erro de download do NVM:
  - Verifique conectividade de rede e certificados CA.
