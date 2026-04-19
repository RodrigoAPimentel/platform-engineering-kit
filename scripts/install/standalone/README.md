# Standalone Application Installers

Scripts for independent, self-hosted application/runtime installers.

These scripts are intended for decoupled runtimes and process tooling that can be provisioned independently from full platform bundles.

## Contents

- [install-nodejs-standalone.sh](install-nodejs-standalone.sh) → Instala Node.js via NVM para um usuário alvo (apt/dnf/yum).
  ↳ Runbook: [docs/runbooks/nodejs-standalone-installation.md](../../../docs/runbooks/nodejs-standalone-installation.md)
- [install-pm2-standalone.sh](install-pm2-standalone.sh) → Instala PM2 para um usuário alvo e configura PM2 como serviço systemd.
  ↳ Runbook: [docs/runbooks/pm2-standalone-installation.md](../../../docs/runbooks/pm2-standalone-installation.md)

## Segurança

⚠️ **Atenção:** Estes scripts exigem privilégios de root (`sudo`) e podem manipular secrets/senhas. Revise comandos antes de executar e evite expor credenciais em linha de comando, histórico de shell ou logs. Veja [security/secrets/README.md](../../../security/secrets/README.md) para boas práticas.

## Purpose

Provide reusable installers for standalone runtimes and process managers decoupled from platform bundles.
