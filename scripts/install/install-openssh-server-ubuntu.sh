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
ENABLE_SERVICE=true
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./install-openssh-server-ubuntu.sh [options]

Options:
  --skip-system-update   Skip apt update/upgrade
  --disable-service      Install package but do not enable/start ssh service
  --reboot               Reboot host after install
  -h, --help             Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-system-update)
            RUN_SYSTEM_UPDATE=false
            shift
            ;;
        --disable-service)
            ENABLE_SERVICE=false
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

_script_start "Install OpenSSH Server (Ubuntu/Debian)"
__verify_root
__detect_package_manager

if [[ "${PACKAGE_MANAGER}" != "apt" ]]; then
    _step_result_failed "This script currently supports apt-based systems only"
    exit 1
fi

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
fi

_step "Installing openssh-server"
apt-get install -y openssh-server

if [[ "${ENABLE_SERVICE}" == true ]]; then
    _step "Enabling and starting ssh service"
    systemctl enable --now ssh
fi

_step "Validating ssh service"
systemctl is-active ssh >/dev/null 2>&1 && _step_result_success "ssh service is active"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi


