#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

AWX_VERSION="17.1.0"
AWX_ADMIN_USER="root"
AWX_ADMIN_PASSWORD="toor"
AWX_SECRET_KEY=""
DOCKER_COMPOSE_VERSION="2.13.0"
SKIP_SYSTEM_UPDATE=false
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./install-ansible-awx.sh [options]

Installs Ansible AWX with Docker on multiple distros (CentOS 7+, RHEL 8+, Ubuntu/Debian 20+).

Options:
  --awx-version <version>      AWX version to install (default: 17.1.0)
  --admin-user <username>      AWX admin username (default: root)
  --admin-password <password>  AWX admin password (default: toor)
  --docker-compose <version>   Docker Compose version (default: 2.13.0)
  --skip-system-update         Skip package update and upgrade
  --reboot                     Reboot host after installation
  -h, --help                   Show this help message

Examples:
  sudo ./install-ansible-awx.sh --awx-version 21.11.0
  sudo ./install-ansible-awx.sh --awx-version 17.1.0 --admin-user admin --reboot
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --awx-version)
            AWX_VERSION="${2:-}"
            shift 2
            ;;
        --admin-user)
            AWX_ADMIN_USER="${2:-}"
            shift 2
            ;;
        --admin-password)
            AWX_ADMIN_PASSWORD="${2:-}"
            shift 2
            ;;
        --docker-compose)
            DOCKER_COMPOSE_VERSION="${2:-}"
            shift 2
            ;;
        --skip-system-update)
            SKIP_SYSTEM_UPDATE=true
            shift
            ;;
        --reboot)
            REBOOT_AFTER=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            __verify_root_pass "$1"
            shift
            ;;
    esac
done

_script_start "Ansible AWX Installation (v${AWX_VERSION})"
__verify_root
__detect_package_manager

# System update
if [[ "${SKIP_SYSTEM_UPDATE}" != true ]]; then
    __update_system
fi

# Install prerequisites
_step "Installing AWX prerequisites"
case "${PACKAGE_MANAGER}" in
    apt)
        apt-get install -y \
            git \
            build-essential \
            nodejs \
            npm \
            python3-pip \
            ansible \
            pwgen \
            wget \
            unzip \
            python3-docker
        npm install --global npm
        ;;
    dnf)
        dnf install -y \
            git \
            gcc \
            gcc-c++ \
            nodejs \
            gettext \
            device-mapper-persistent-data \
            lvm2 \
            bzip2 \
            python3-pip \
            ansible \
            dnf-plugins-core \
            pwgen \
            wget \
            npm \
            unzip \
            python3-docker
        npm install --global npm
        ;;
    yum)
        yum install -y \
            git \
            gcc \
            gcc-c++ \
            nodejs \
            gettext \
            device-mapper-persistent-data \
            lvm2 \
            bzip2 \
            python3-pip \
            ansible \
            pwgen \
            wget \
            npm \
            unzip \
            python3-docker
        npm install --global npm
        ;;
esac
_step_result_success "AWX prerequisites installed"

# Install Docker
_step "Installing Docker Engine and Docker Compose"
case "${PACKAGE_MANAGER}" in
    apt)
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 2>/dev/null || true
        add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || true
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ;;
    dnf)
        dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ;;
    yum)
        yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        ;;
esac

# Start Docker service
_step "Enabling and starting Docker service"
systemctl enable --now docker
_step_result_success "Docker service started"

# Set Python3 as default (RHEL/CentOS specific)
if [[ "${PACKAGE_MANAGER}" == "dnf" || "${PACKAGE_MANAGER}" == "yum" ]]; then
    _step "Setting Python 3 as default"
    alternatives --install /usr/bin/python python /usr/bin/python3 1 || true
    _step_result_success "Python 3 set as default"
fi

# Install Docker Compose standalone if needed
_step "Verifying Docker Compose installation"
arch="$(uname -m)"
case "${arch}" in
    x86_64)
        compose_arch="x86_64"
        ;;
    aarch64|arm64)
        compose_arch="aarch64"
        ;;
    *)
        compose_arch="x86_64"
        _step_result_suggestion "Unsupported architecture ${arch}, using x86_64 fallback"
        ;;
esac

if ! command -v docker-compose >/dev/null 2>&1; then
    _step "Installing Docker Compose v${DOCKER_COMPOSE_VERSION} standalone"
    curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${compose_arch}" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    _step_result_success "Docker Compose installed"
else
    _step_result_success "Docker Compose already installed"
fi

# Download and prepare AWX
_step "Downloading Ansible AWX v${AWX_VERSION}"
cd /tmp || exit 1
wget -q "https://github.com/ansible/awx/archive/${AWX_VERSION}.zip"
unzip -q "${AWX_VERSION}.zip"
cd "awx-${AWX_VERSION}/installer" || exit 1
_step_result_success "AWX source downloaded"

# Generate secure secret key if not provided
if [[ -z "${AWX_SECRET_KEY}" ]]; then
    AWX_SECRET_KEY="$(pwgen -N 1 -s 40)"
fi

# Configure inventory
_step "Configuring AWX inventory"
sed -i "s|^admin_user=.*|admin_user=${AWX_ADMIN_USER}|g" inventory
sed -i -E "s|^#([[:space:]]?)admin_password=password|admin_password=${AWX_ADMIN_PASSWORD}|g" inventory
sed -i "s|^secret_key=.*|secret_key=${AWX_SECRET_KEY}|g" inventory
_step_result_success "Inventory configured"

# Run AWX installer
_step "Running Ansible AWX installation playbook"
if ansible-playbook -i inventory install.yml; then
    _step_result_success "AWX playbook executed successfully"
else
    _step_result_error "AWX playbook execution failed"
    exit 1
fi

# Restart AWX containers
_step "Restarting AWX services"
cd ~/.awx/awxcompose || exit 1
docker-compose down || true
sleep 5
docker-compose up -d
_step_result_success "AWX services restarted"

# Final information
_finish_information

_step "AWX Installation Summary"
echo "  Admin User: ${AWX_ADMIN_USER}"
echo "  Version: ${AWX_VERSION}"
echo "  Docker Compose: ${DOCKER_COMPOSE_VERSION}"
echo ""
echo "  Access AWX at: http://localhost (or your machine IP)"
echo "  Credentials: ${AWX_ADMIN_USER} / ${AWX_ADMIN_PASSWORD}"

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi
