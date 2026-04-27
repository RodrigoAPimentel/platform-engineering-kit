# 📥 Install Scripts

Scripts for installing tools and dependencies.

## Contents

- `initial-machine-preparation.sh` -> Baseline machine preparation (locale/session, package update, OpenSSH enablement, optional firewall and reboot) across apt/dnf/yum systems.
  ↳ Runbook: [`docs/runbooks/initial-machine-preparation.md`](../../docs/runbooks/initial-machine-preparation.md)
- `install-docker.sh` -> Unified Docker installer for Ubuntu/Debian/RHEL/CentOS/Fedora with OS detection, Compose plugin, and standalone Compose fallback.
  ↳ Runbook: [`docs/runbooks/docker-installation.md`](../../docs/runbooks/docker-installation.md)
- `install-ansible-awx.sh` -> Installs Ansible AWX in `legacy` (Docker Compose) or `operator` (Kubernetes) mode, with `auto` selection by AWX version layout. Includes uninstall options (`--uninstall`, `--remove-operator`, `--destructive-uninstall`).
  ↳ Runbook: [`docs/runbooks/ansible-awx-installation.md`](../../docs/runbooks/ansible-awx-installation.md)
- `install-minikube-ubuntu.sh` -> Installs Minikube and kubectl on Ubuntu/Debian, configures dashboard ingress/iptables, and provisions NGINX proxy with external kubeconfig bundle by default.
  ↳ Runbook: [`docs/runbooks/minikube-installation-ubuntu.md`](../../docs/runbooks/minikube-installation-ubuntu.md)
- `install-node-red.sh` -> Installs Node-RED with PM2 process management and startup integration for Ubuntu/Debian.
  ↳ Runbook: [`docs/runbooks/node-red-installation.md`](../../docs/runbooks/node-red-installation.md)
- `install-openssh-server-ubuntu.sh` -> Installs and enables OpenSSH Server on Ubuntu/Debian hosts.
  ↳ Runbook: [`docs/runbooks/openssh-server-ubuntu-installation.md`](../../docs/runbooks/openssh-server-ubuntu-installation.md)
- `install-argocd-minikube.sh` -> Installs Argo CD in Minikube, configures ingress, optionally configures iptables forwarding, and prints dashboard access details.
  ↳ Runbook: [`docs/runbooks/argocd-minikube-installation.md`](../../docs/runbooks/argocd-minikube-installation.md)
- `install-oh-my-zsh-ubuntu.sh` -> Installs and configures Oh My Zsh for Ubuntu/Debian users with plugins and theme setup, using `scripts/install/resources/p10k-zsh-plugin-configuration.txt` by default.
  ↳ Runbook: [`docs/runbooks/oh-my-zsh-ubuntu-installation.md`](../../docs/runbooks/oh-my-zsh-ubuntu-installation.md)

## Standalone Applications

- `standalone/install-nodejs-standalone.sh` -> Installs Node.js via NVM for a target user across apt/dnf/yum systems.
  ↳ Runbook: [`docs/runbooks/nodejs-standalone-installation.md`](../../docs/runbooks/nodejs-standalone-installation.md)
- `standalone/install-pm2-standalone.sh` -> Installs PM2 and configures systemd startup for a target user.
  ↳ Runbook: [`docs/runbooks/pm2-standalone-installation.md`](../../docs/runbooks/pm2-standalone-installation.md)
- `standalone/install-devops-tools-stack-standalone.sh` -> Installs a standalone Docker-based DevOps stack (Jenkins, Keycloak, Portainer, NGINX).
  ↳ Runbook: [`docs/runbooks/devops-tools-stack-standalone-installation.md`](../../docs/runbooks/devops-tools-stack-standalone-installation.md)

See also: `scripts/install/standalone/README.md`

## Purpose

Automate tool installation and environment setup.
