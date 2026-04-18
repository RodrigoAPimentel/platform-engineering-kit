# Standalone Application Installers

Scripts for independent, self-hosted application/runtime installers.

These scripts are intended for decoupled runtimes and process tooling that can be provisioned independently from full platform bundles.

## Contents

- install-nodejs-standalone.sh -> Installs Node.js via NVM for a target user across apt/dnf/yum systems.
- install-pm2-standalone.sh -> Installs PM2 for a target user and configures PM2 startup service.

## Related Runbooks

- docs/runbooks/nodejs-standalone-installation.md
- docs/runbooks/pm2-standalone-installation.md

## Purpose

Provide reusable installers for standalone runtimes and process managers decoupled from platform bundles.
