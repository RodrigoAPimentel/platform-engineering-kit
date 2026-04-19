#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

RUN_SYSTEM_UPDATE=true
INSTALL_OPENSSH=true
CONFIGURE_FIREWALL=true
LOCALE_VALUE="en_US.UTF-8"
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./initial-machine-preparation.sh [options]

Options:
  --skip-system-update   Skip package index update and upgrade
  --skip-openssh         Do not install/enable OpenSSH service
  --skip-firewall        Do not configure firewall for SSH
  --locale <value>       Locale to export in current session (default: en_US.UTF-8)
  --reboot               Reboot host after preparation
  -h, --help             Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-system-update)
            RUN_SYSTEM_UPDATE=false
            shift
            ;;
        --skip-openssh)
            INSTALL_OPENSSH=false
            shift
            ;;
        --skip-firewall)
            CONFIGURE_FIREWALL=false
            shift
            ;;
        --locale)
            LOCALE_VALUE="${2:-}"
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

_script_start "Initial Machine Preparation"
__verify_root
__detect_package_manager

_step "Setting locale variables for current session"
export LANG="${LOCALE_VALUE}"
export LANGUAGE="${LOCALE_VALUE}"
export LC_COLLATE=C
export LC_CTYPE="${LOCALE_VALUE}"

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
fi

if [[ "${PACKAGE_MANAGER}" == "dnf" || "${PACKAGE_MANAGER}" == "yum" ]]; then
    _step "Ensuring EPEL repository availability when needed"
    ${PACKAGE_MANAGER} install -y epel-release || _step_result_suggestion "epel-release not available for this distro"
fi

if [[ "${INSTALL_OPENSSH}" == true ]]; then
    _step "Installing and enabling OpenSSH server"
    case "${PACKAGE_MANAGER}" in
        apt)
            apt-get install -y openssh-server
            systemctl enable --now ssh
            ;;
        dnf|yum)
            ${PACKAGE_MANAGER} install -y openssh-server
            systemctl enable --now sshd
            ;;
    esac
fi

if [[ "${CONFIGURE_FIREWALL}" == true && "${INSTALL_OPENSSH}" == true ]]; then
    _step "Configuring firewall for SSH when firewalld is available"
    if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active firewalld >/dev/null 2>&1; then
        firewall-cmd --zone=public --permanent --add-service=ssh || firewall-cmd --zone=public --permanent --add-service=sshd || true
        firewall-cmd --reload || true
    else
        _step_result_suggestion "firewalld not active; skipping firewall configuration"
    fi
fi

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting machine"
    reboot
fi