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
ANSIBLE_PYTHON_INTERPRETER_BIN="$(command -v python3 || echo /usr/bin/python3)"

update_npm_if_compatible() {
    if ! command -v npm >/dev/null 2>&1; then
        return 0
    fi

    # Newer npm releases require newer Node.js. Do not fail AWX install if npm self-update is unsupported.
    if npm install --global npm >/tmp/npm-self-update.log 2>&1; then
        _step_result_success "npm updated to latest version"
    else
        _step_result_suggestion "Skipping npm self-update due to Node.js compatibility constraints (details: /tmp/npm-self-update.log)"
    fi
}

is_docker_installed() {
    command -v docker >/dev/null 2>&1
}

is_docker_compose_installed() {
    if command -v docker-compose >/dev/null 2>&1; then
        return 0
    fi

    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

run_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose "$@"
        return
    fi

    docker compose "$@"
}

ensure_ansible_compose_python_module() {
    _step "Ensuring Python docker-compose module for Ansible"

    if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
        _step_result_success "Python docker-compose module already available"
        return
    fi

    # Prefer distro packages first to avoid externally-managed Python issues (PEP 668).
    case "${PACKAGE_MANAGER}" in
        apt)
            if apt-get install -y docker-compose >/tmp/awx-compose-package.log 2>&1; then
                if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                    _step_result_success "Python docker-compose module installed via apt package"
                    return
                fi
            fi
            ;;
        dnf)
            dnf install -y docker-compose >/tmp/awx-compose-package.log 2>&1 || true
            if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                _step_result_success "Python docker-compose module installed via dnf package"
                return
            fi
            ;;
        yum)
            yum install -y docker-compose >/tmp/awx-compose-package.log 2>&1 || true
            if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                _step_result_success "Python docker-compose module installed via yum package"
                return
            fi
            ;;
    esac

    # Fallback: isolated venv for Ansible runtime.
    local awx_venv_dir="/opt/awx-installer-venv"

    if ! python3 -m venv "${awx_venv_dir}" >/tmp/awx-compose-venv.log 2>&1; then
        if [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
            apt-get install -y python3-venv >/tmp/awx-compose-venv.log 2>&1
            python3 -m venv "${awx_venv_dir}" >/tmp/awx-compose-venv.log 2>&1
        else
            _step_result_failed "Failed to create Python venv for AWX installer (details: /tmp/awx-compose-venv.log)"
            exit 1
        fi
    fi

    if "${awx_venv_dir}/bin/pip" install --upgrade pip >/tmp/pip-docker-compose.log 2>&1 \
        && "${awx_venv_dir}/bin/pip" install docker-compose==1.29.2 >/tmp/pip-docker-compose.log 2>&1 \
        && "${awx_venv_dir}/bin/python" -c 'import compose' >/dev/null 2>&1; then
        ANSIBLE_PYTHON_INTERPRETER_BIN="${awx_venv_dir}/bin/python"
        _step_result_success "Python docker-compose module installed in venv (${awx_venv_dir})"
    else
        _step_result_failed "Failed to install Python docker-compose module (details: /tmp/pip-docker-compose.log)"
        exit 1
    fi
}

is_known_awx_compose_containerconfig_error() {
    local playbook_log_file="${1:-}"

    if [[ -z "${playbook_log_file}" || ! -f "${playbook_log_file}" ]]; then
        return 1
    fi

    grep -q "Error starting project 'ContainerConfig'" "${playbook_log_file}"
}

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
        update_npm_if_compatible
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
        update_npm_if_compatible
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
        update_npm_if_compatible
        ;;
esac
_step_result_success "AWX prerequisites installed"

# Install Docker/Docker Compose only when missing
if is_docker_installed && is_docker_compose_installed; then
    _step "Verifying Docker Engine and Docker Compose"
    _step_result_success "Docker and Docker Compose already installed, skipping installation"
else
    _step "Installing Docker Engine and Docker Compose"
    case "${PACKAGE_MANAGER}" in
        apt)
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 2>/dev/null || true
            add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || true
            apt-get update

            if ! is_docker_installed; then
                apt-get install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                apt-get install -y docker-compose-plugin
            fi
            ;;
        dnf)
            dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

            if ! is_docker_installed; then
                dnf install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                dnf install -y docker-compose-plugin
            fi
            ;;
        yum)
            yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

            if ! is_docker_installed; then
                yum install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                yum install -y docker-compose-plugin
            fi
            ;;
    esac
fi

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

if ! is_docker_compose_installed; then
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
if ! wget -q -O "${AWX_VERSION}.zip" "https://github.com/ansible/awx/archive/${AWX_VERSION}.zip"; then
    _step_result_failed "Failed to download AWX archive for version ${AWX_VERSION}"
    exit 1
fi

AWX_ARCHIVE_ROOT="$(unzip -Z -1 "${AWX_VERSION}.zip" 2>/dev/null | head -n1 | cut -d'/' -f1 || true)"
if [[ -z "${AWX_ARCHIVE_ROOT}" ]]; then
    AWX_ARCHIVE_ROOT="awx-${AWX_VERSION}"
fi

if ! unzip -q -o "${AWX_VERSION}.zip"; then
    _step_result_failed "Failed to extract AWX archive ${AWX_VERSION}.zip"
    exit 1
fi

AWX_INSTALLER_DIR=""
if [[ -d "/tmp/${AWX_ARCHIVE_ROOT}/installer" && -f "/tmp/${AWX_ARCHIVE_ROOT}/installer/install.yml" && -f "/tmp/${AWX_ARCHIVE_ROOT}/installer/inventory" ]]; then
    AWX_INSTALLER_DIR="/tmp/${AWX_ARCHIVE_ROOT}/installer"
else
    AWX_INSTALLER_DIR="$(find "/tmp/${AWX_ARCHIVE_ROOT}" -maxdepth 6 -type f -name install.yml -printf '%h\n' 2>/dev/null | while IFS= read -r candidate; do
        if [[ -f "${candidate}/inventory" ]]; then
            printf '%s\n' "${candidate}"
            break
        fi
    done)"
fi

if [[ -z "${AWX_INSTALLER_DIR}" ]]; then
    _step_result_failed "AWX v${AWX_VERSION} does not include the legacy installer layout (install.yml + inventory)."
    _step_result_suggestion "Use a legacy version with installer support (example: 17.1.0) or migrate to AWX Operator workflow for newer versions."
    exit 1
fi

cd "${AWX_INSTALLER_DIR}" || exit 1
_step_result_success "AWX source downloaded"

ensure_ansible_compose_python_module

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
PLAYBOOK_LOG_FILE="/tmp/awx-install-playbook.log"
if ansible-playbook -i inventory -e "ansible_python_interpreter=${ANSIBLE_PYTHON_INTERPRETER_BIN}" install.yml 2>&1 | tee "${PLAYBOOK_LOG_FILE}"; then
    _step_result_success "AWX playbook executed successfully"
else
    if is_known_awx_compose_containerconfig_error "${PLAYBOOK_LOG_FILE}"; then
        _step_result_suggestion "Known docker-compose v1 ContainerConfig issue detected during AWX installer"
        _step_result_suggestion "Proceeding with manual container restart via Compose"
    else
        _step_result_failed "AWX playbook execution failed (details: ${PLAYBOOK_LOG_FILE})"
        exit 1
    fi
fi

# Restart AWX containers
_step "Restarting AWX services"
cd ~/.awx/awxcompose || exit 1
run_docker_compose down || true
sleep 5
run_docker_compose up -d
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
