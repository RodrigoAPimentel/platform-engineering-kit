# Standalone Application Installers

Scripts for independent, self-hosted application/runtime installers.

These scripts are intended for decoupled runtimes and process tooling that can be provisioned independently from full platform bundles.

## Contents

- [install-nodejs-standalone.sh](install-nodejs-standalone.sh) -> Installs Node.js via NVM for a target user (apt/dnf/yum).
  ↳ Runbook: [docs/runbooks/nodejs-standalone-installation.md](../../../docs/runbooks/nodejs-standalone-installation.md)
- [install-pm2-standalone.sh](install-pm2-standalone.sh) -> Installs PM2 for a target user and configures PM2 as a systemd service.
  ↳ Runbook: [docs/runbooks/pm2-standalone-installation.md](../../../docs/runbooks/pm2-standalone-installation.md)
- [install-devops-tools-stack-standalone.sh](install-devops-tools-stack-standalone.sh) -> Installs a standalone DevOps tools stack with Docker-based services (Jenkins, Keycloak, Portainer, and NGINX).
  ↳ Runbook: [docs/runbooks/devops-tools-stack-standalone-installation.md](../../../docs/runbooks/devops-tools-stack-standalone-installation.md)

## Security

⚠️ **Warning:** These scripts require root privileges (`sudo`) and may handle secrets/passwords. Review commands before execution and avoid exposing credentials in command-line arguments, shell history, or logs. See [security/secrets/README.md](../../../security/secrets/README.md) for best practices.

## Purpose

Provide reusable installers for standalone runtimes and process managers decoupled from platform bundles.
