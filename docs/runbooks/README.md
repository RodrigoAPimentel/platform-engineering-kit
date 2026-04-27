# 📘 Runbooks

This directory contains operational procedures.

## Contents

### Install Scripts (`scripts/install/`)

- [Initial Machine Preparation](initial-machine-preparation.md) - Initial Linux host preparation baseline.
  ↳ Script: [scripts/install/initial-machine-preparation.sh](../../scripts/install/initial-machine-preparation.sh)
- [Docker Installation](docker-installation.md) - Unified Docker and Compose installation on apt/dnf/yum.
  ↳ Script: [scripts/install/install-docker.sh](../../scripts/install/install-docker.sh)
- [Ansible AWX Installation & Operation](ansible-awx-installation.md) - Installation and operation of AWX across multi-distro setups.
  ↳ Script: [scripts/install/install-ansible-awx.sh](../../scripts/install/install-ansible-awx.sh)
- [Minikube Installation (Ubuntu/Debian)](minikube-installation-ubuntu.md) - Operational installation flow for Minikube script.
  ↳ Script: [scripts/install/install-minikube-ubuntu.sh](../../scripts/install/install-minikube-ubuntu.sh)
- [Node-RED Installation](node-red-installation.md) - Installation with PM2 and automatic startup.
  ↳ Script: [scripts/install/install-node-red.sh](../../scripts/install/install-node-red.sh)
- [OpenSSH Server Installation (Ubuntu/Debian)](openssh-server-ubuntu-installation.md) - OpenSSH installation and service enablement.
  ↳ Script: [scripts/install/install-openssh-server-ubuntu.sh](../../scripts/install/install-openssh-server-ubuntu.sh)
- [Argo CD on Minikube](argocd-minikube-installation.md) - Argo CD deployment with ingress and external access.
  ↳ Script: [scripts/install/install-argocd-minikube.sh](../../scripts/install/install-argocd-minikube.sh)
- [Oh My Zsh Installation (Ubuntu/Debian)](oh-my-zsh-ubuntu-installation.md) - Shell customization for target user.
  ↳ Script: [scripts/install/install-oh-my-zsh-ubuntu.sh](../../scripts/install/install-oh-my-zsh-ubuntu.sh)

### Standalone Installers (`scripts/install/standalone/`)

- [Node.js Standalone Installation](nodejs-standalone-installation.md) - Node.js runtime installation via NVM for a target user.
  ↳ Script: [scripts/install/standalone/install-nodejs-standalone.sh](../../scripts/install/standalone/install-nodejs-standalone.sh)
- [PM2 Standalone Installation](pm2-standalone-installation.md) - PM2 installation with systemd startup for a target user.
  ↳ Script: [scripts/install/standalone/install-pm2-standalone.sh](../../scripts/install/standalone/install-pm2-standalone.sh)
- [DevOps Tools Stack Standalone Installation](devops-tools-stack-standalone-installation.md) - Standalone Docker-based provisioning for Jenkins, Keycloak, Portainer, and NGINX, including current limitations and validation steps.
  ↳ Script: [scripts/install/standalone/install-devops-tools-stack-standalone.sh](../../scripts/install/standalone/install-devops-tools-stack-standalone.sh)

### Maintenance Scripts (`scripts/maintenance/`)

- [Proxmox Template Preparation (Ubuntu)](proxmox-prepare-vm-template-ubuntu.md) - VM preparation before template conversion.
  ↳ Script: [scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh](../../scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh)
- [Proxmox Post-Clone Configuration (Ubuntu)](proxmox-config-vm-from-template-ubuntu.md) - Post-clone VM configuration.
  ↳ Script: [scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh](../../scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh)

### Additional Guides

- [Minikube guide](minikube.md) - Complementary usage and remote access guide.

## Security

⚠️ **Warning:** Some scripts and procedures require `sudo` and/or handle secrets/passwords. Always review commands before execution and avoid exposing credentials in command-line arguments, shell history, or logs. See [security/secrets/README.md](../../security/secrets/README.md) for best practices.

## Purpose

Provide clear instructions for operating and maintaining the platform.
