# 📥 Install Scripts

Scripts for installing tools and dependencies.

## Contents

- `initial-machine-preparation.sh` -> Baseline machine preparation (locale/session, package update, OpenSSH enablement, optional firewall and reboot) across apt/dnf/yum systems.
- `install-docker.sh` -> Unified Docker installer for Ubuntu/Debian/RHEL/CentOS/Fedora with OS detection, Compose plugin, and standalone Compose fallback.
- `install-ansible-awx.sh` -> Installs Ansible AWX in `legacy` (Docker Compose) or `operator` (Kubernetes) mode, with `auto` selection by AWX version layout. Includes uninstall options (`--uninstall`, `--remove-operator`, `--destructive-uninstall`).
- `install-minikube-ubuntu.sh` -> Installs Minikube and kubectl on Ubuntu/Debian, configures dashboard ingress/iptables, and provisions NGINX proxy with external kubeconfig bundle by default.
- `install-node-red.sh` -> Installs Node-RED with PM2 process management and startup integration for Ubuntu/Debian.
- `install-openssh-server-ubuntu.sh` -> Installs and enables OpenSSH Server on Ubuntu/Debian hosts.
- `install-argocd-minikube.sh` -> Installs Argo CD in Minikube, configures ingress, optionally configures iptables forwarding, and prints dashboard access details.
- `install-oh-my-zsh-ubuntu.sh` -> Installs and configures Oh My Zsh for Ubuntu/Debian users with plugins and theme setup, using `scripts/install/resources/p10k-zsh-plugin-configuration.txt` by default.

## Standalone Applications

- `standalone/install-nodejs-standalone.sh` -> Installs Node.js via NVM for a target user across apt/dnf/yum systems.
- `standalone/install-pm2-standalone.sh` -> Installs PM2 and configures systemd startup for a target user.

See also: `scripts/install/standalone/README.md`

## Purpose

Automate tool installation and environment setup.
