#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

INSTALL_OPENSSH_HELPER=true
SHUTDOWN_AFTER=true

usage() {
    cat <<'EOF'
Usage: sudo ./proxmox-prepare-vm-template-ubuntu.sh [options]

Options:
  --skip-openssh-helper   Do not copy openssh installer helper to root home
  --no-shutdown           Skip poweroff at the end
  -h, --help              Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-openssh-helper)
            INSTALL_OPENSSH_HELPER=false
            shift
            ;;
        --no-shutdown)
            SHUTDOWN_AFTER=false
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

_script_start "Prepare Ubuntu VM for Proxmox template"
__verify_root
__detect_package_manager

if [[ "${PACKAGE_MANAGER}" != "apt" ]]; then
    _step_result_failed "This script currently supports apt-based systems only"
    exit 1
fi

_step "Updating system and installing template dependencies"
apt-get update -y
apt-get upgrade -y
apt-get install -y cloud-init qemu-guest-agent openssh-server

_step "Enabling qemu-guest-agent"
systemctl enable --now qemu-guest-agent

_step "Resetting machine identity and SSH host keys"
truncate -s 0 /etc/machine-id
rm -f /etc/ssh/ssh_host_*

_step "Cleaning cloud-init and apt caches"
cloud-init clean --logs
apt-get autoremove -y
apt-get clean

if [[ "${INSTALL_OPENSSH_HELPER}" == true ]]; then
    helper_source="${SCRIPT_DIR}/../install/install-openssh-server-ubuntu.sh"
    helper_target="/root/install-openssh-server-ubuntu.sh"
    if [[ -f "${helper_source}" ]]; then
        cp -f "${helper_source}" "${helper_target}"
        chmod 0755 "${helper_target}"
        _step_result_success "Copied OpenSSH helper to ${helper_target}"
    else
        _step_result_suggestion "OpenSSH helper not found at ${helper_source}"
    fi
fi

_step_result_suggestion "In Proxmox UI, add Cloud-Init drive before converting this VM to template."

_finish_information

if [[ "${SHUTDOWN_AFTER}" == true ]]; then
    _step "Shutting down machine"
    shutdown -h now
fi