#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

TARGET_USER="${SUDO_USER:-${USER}}"
RUN_SYSTEM_UPDATE=true
REBOOT_AFTER=false
COMPOSE_FALLBACK_VERSION="v2.29.7"

usage() {
    cat <<'EOF'
Usage: sudo ./install-docker.sh [options]

Options:
  --user <username>        User to add to docker group (default: current sudo user)
  --skip-system-update     Skip apt/dnf/yum update and upgrade
  --compose-fallback <v>   Docker Compose standalone fallback version (default: v2.29.7)
  --reboot                 Reboot host after install
  -h, --help               Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)
            TARGET_USER="${2:-}"
            shift 2
            ;;
        --skip-system-update)
            RUN_SYSTEM_UPDATE=false
            shift
            ;;
        --compose-fallback)
            COMPOSE_FALLBACK_VERSION="${2:-}"
            shift 2
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

_script_start "Install Docker Engine and Compose Plugin"
__verify_root
__detect_package_manager

arch="$(uname -m)"
case "${arch}" in
    x86_64) compose_arch="x86_64" ;;
    aarch64|arm64) compose_arch="aarch64" ;;
    *)
        _step_result_failed "Unsupported architecture for compose fallback: ${arch}"
        exit 1
        ;;
esac

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
else
    _step_result_suggestion "Skipping system update as requested"
fi

if [[ -z "${TARGET_USER}" ]] || ! id "${TARGET_USER}" >/dev/null 2>&1; then
    _step_result_failed "Target user is invalid: ${TARGET_USER}"
    exit 1
fi

_step "Configuring Docker repository and dependencies"
case "${PACKAGE_MANAGER}" in
    apt)
        apt-get install -y ca-certificates curl gnupg lsb-release
        install -m 0755 -d /etc/apt/keyrings
        distro_family="${OS}"
        case "${OS}" in
            ubuntu|debian) ;;
            *)
                _step_result_failed "Unsupported apt-based distro for Docker repo: ${OS}"
                exit 1
                ;;
        esac

        curl -fsSL "https://download.docker.com/linux/${distro_family}/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        codename="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"
        if [[ -z "${codename}" ]]; then
            _step_result_failed "Could not detect codename for apt-based distro"
            exit 1
        fi

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${distro_family} ${codename} stable" > /etc/apt/sources.list.d/docker.list
        apt-get update -y
        ;;
    dnf)
        dnf install -y dnf-plugins-core
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        ;;
    yum)
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        ;;
esac

_step "Installing Docker packages"
case "${PACKAGE_MANAGER}" in
    apt)
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ;;
    dnf)
        dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || \
            dnf install -y docker-ce docker-ce-cli containerd.io
        ;;
    yum)
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || \
            yum install -y docker-ce docker-ce-cli containerd.io
        ;;
esac

_step "Enabling and starting Docker service"
systemctl enable --now docker

_step "Adding user to docker group"
usermod -aG docker "${TARGET_USER}"

_step "Validating installation"
__verify_packages_installed docker
if docker compose version >/dev/null 2>&1; then
    _step_result_success "docker compose plugin is available"
else
    _step_result_suggestion "docker compose plugin not available; installing standalone fallback"
    curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_FALLBACK_VERSION}/docker-compose-linux-${compose_arch}" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    if command -v docker-compose >/dev/null 2>&1; then
        _step_result_success "docker-compose standalone installed"
    else
        _step_result_failed "docker-compose fallback installation failed"
        exit 1
    fi
fi

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
else
    _step_result_suggestion "Reboot skipped. You may need to re-login user ${TARGET_USER} to use docker group permissions."
fi