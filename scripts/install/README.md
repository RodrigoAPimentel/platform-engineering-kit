# 📥 Install Scripts

Scripts for installing tools and dependencies.

## Contents

- `initial-machine-preparation.sh` -> Baseline machine preparation (locale/session, package update, OpenSSH enablement, optional firewall and reboot) across apt/dnf/yum systems.
- `initial-preparation.sh` -> Baseline host preparation (system update, prerequisite packages, timezone, optional reboot).
- `install-docker.sh` -> Unified Docker installer for Ubuntu/Debian/RHEL/CentOS/Fedora with OS detection, Compose plugin, and standalone Compose fallback.
- `install-minikube-ubuntu.sh` -> Installs Minikube and kubectl on Ubuntu/Debian, configures dashboard ingress/iptables, and provisions NGINX proxy with external kubeconfig bundle by default.
- `install-node-red.sh` -> Installs Node-RED with PM2 process management and startup integration for Ubuntu/Debian.
- `install-openssh-server-ubuntu.sh` -> Installs and enables OpenSSH Server on Ubuntu/Debian hosts.
- `install-argocd-minikube.sh` -> Installs Argo CD in Minikube, configures ingress, optionally configures iptables forwarding, and prints dashboard access details.
- `install-oh-my-zsh-ubuntu.sh` -> Installs and configures Oh My Zsh for Ubuntu/Debian users with plugins and theme setup, using `scripts/install/resources/p10k-zsh-plugin-configuration.txt` by default.

## Purpose

Automate tool installation and environment setup.
