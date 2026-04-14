# 📥 Install Scripts

Scripts for installing tools and dependencies.

## Contents

- `initial-preparation.sh` -> Baseline host preparation (system update, prerequisite packages, timezone, optional reboot).
- `install-docker.sh` -> Installs Docker Engine, Docker Compose plugin, enables service, and adds a user to docker group.
- `install-argocd-minikube.sh` -> Installs Argo CD in Minikube, configures ingress, optionally configures iptables forwarding, and prints dashboard access details.
- `install-oh-my-zsh-ubuntu.sh` -> Installs and configures Oh My Zsh for Ubuntu/Debian users with plugins and theme setup, using `scripts/install/resources/p10k-zsh-plugin-configuration.txt` by default.

## Purpose

Automate tool installation and environment setup.
