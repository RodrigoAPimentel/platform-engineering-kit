# 📘 Runbooks

This directory contains operational procedures.

## Contents

- [Ansible AWX Installation & Operation](ansible-awx-installation.md) - Instalação e operação do AWX multi-distro.
- [Docker Installation](docker-installation.md) - Instalação unificada de Docker e Compose em apt/dnf/yum.
- [Initial Machine Preparation](initial-machine-preparation.md) - Baseline de preparação inicial de hosts Linux.
- [Minikube Installation (Ubuntu/Debian)](minikube-installation-ubuntu.md) - Instalação operacional do script de Minikube.
- [Minikube guide](minikube.md) - Guia complementar de uso e acesso remoto.
- [Node-RED Installation](node-red-installation.md) - Instalação com PM2 e startup automático.
- [Node.js Standalone Installation](nodejs-standalone-installation.md) - Instalação do runtime Node.js via NVM para usuário alvo.  
  ↳ Script: [scripts/install/standalone/install-nodejs-standalone.sh](../../scripts/install/standalone/install-nodejs-standalone.sh)
- [PM2 Standalone Installation](pm2-standalone-installation.md) - Instalação do PM2 com startup systemd para usuário alvo.  
  ↳ Script: [scripts/install/standalone/install-pm2-standalone.sh](../../scripts/install/standalone/install-pm2-standalone.sh)
- [OpenSSH Server Installation (Ubuntu/Debian)](openssh-server-ubuntu-installation.md) - Instalação e habilitação do SSH.
- [Argo CD on Minikube](argocd-minikube-installation.md) - Deploy de Argo CD com ingress e acesso externo.
- [Oh My Zsh Installation (Ubuntu/Debian)](oh-my-zsh-ubuntu-installation.md) - Customização shell para usuário alvo.
- [Proxmox Template Preparation (Ubuntu)](proxmox-prepare-vm-template-ubuntu.md) - Preparação de VM para template.
- [Proxmox Post-Clone Configuration (Ubuntu)](proxmox-config-vm-from-template-ubuntu.md) - Configuração pós-clone de VM.

## Segurança

⚠️ **Atenção:** Alguns scripts e procedimentos exigem uso de `sudo` e/ou manipulam secrets/senhas. Sempre revise comandos antes de executar e evite expor credenciais em linha de comando, histórico de shell ou logs. Consulte [security/secrets/README.md](../../security/secrets/README.md) para boas práticas.

## Purpose

Provide clear instructions for operating and maintaining the platform.
