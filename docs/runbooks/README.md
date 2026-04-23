# 📘 Runbooks

This directory contains operational procedures.

## Contents

- [Ansible AWX Installation & Operation](ansible-awx-installation.md) - Installation and operation of AWX across multi-distro setups.
- [Docker Installation](docker-installation.md) - Unified Docker and Compose installation on apt/dnf/yum.
- [Initial Machine Preparation](initial-machine-preparation.md) - Initial Linux host preparation baseline.
- [Minikube Installation (Ubuntu/Debian)](minikube-installation-ubuntu.md) - Operational installation flow for Minikube script.
- [Minikube guide](minikube.md) - Complementary usage and remote access guide.
- [Node-RED Installation](node-red-installation.md) - Installation with PM2 and automatic startup.
- [Node.js Standalone Installation](nodejs-standalone-installation.md) - Node.js runtime installation via NVM for a target user.  
  ↳ Script: [scripts/install/standalone/install-nodejs-standalone.sh](../../scripts/install/standalone/install-nodejs-standalone.sh)
- [PM2 Standalone Installation](pm2-standalone-installation.md) - PM2 installation with systemd startup for a target user.  
  ↳ Script: [scripts/install/standalone/install-pm2-standalone.sh](../../scripts/install/standalone/install-pm2-standalone.sh)
- [DevOps Tools Stack Standalone Installation](devops-tools-stack-standalone-installation.md) - Standalone Docker-based provisioning for Jenkins, Keycloak, Portainer, and NGINX, including current limitations and validation steps.  
  ↳ Script: [scripts/install/standalone/install-devops-tools-stack-standalone.sh](../../scripts/install/standalone/install-devops-tools-stack-standalone.sh)
- [OpenSSH Server Installation (Ubuntu/Debian)](openssh-server-ubuntu-installation.md) - OpenSSH installation and service enablement.
- [Argo CD on Minikube](argocd-minikube-installation.md) - Argo CD deployment with ingress and external access.
- [Oh My Zsh Installation (Ubuntu/Debian)](oh-my-zsh-ubuntu-installation.md) - Shell customization for target user.
- [Proxmox Template Preparation (Ubuntu)](proxmox-prepare-vm-template-ubuntu.md) - VM preparation before template conversion.
- [Proxmox Post-Clone Configuration (Ubuntu)](proxmox-config-vm-from-template-ubuntu.md) - Post-clone VM configuration.

## Security

⚠️ **Warning:** Some scripts and procedures require `sudo` and/or handle secrets/passwords. Always review commands before execution and avoid exposing credentials in command-line arguments, shell history, or logs. See [security/secrets/README.md](../../security/secrets/README.md) for best practices.

## Purpose

Provide clear instructions for operating and maintaining the platform.
