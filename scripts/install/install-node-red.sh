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

usage() {
    cat <<'EOF'
Usage: sudo ./install-node-red.sh [options]

Options:
  --user <username>        User that will run Node-RED (default: current sudo user)
  --skip-system-update     Skip apt update/upgrade
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

run_as_target() {
    runuser -u "${TARGET_USER}" -- bash -lc "$*"
}

_script_start "Install Node-RED"
__verify_root
__detect_package_manager

if [[ "${PACKAGE_MANAGER}" != "apt" ]]; then
    _step_result_failed "This script currently supports apt-based systems only"
    exit 1
fi

if [[ -z "${TARGET_USER}" ]] || ! id "${TARGET_USER}" >/dev/null 2>&1; then
    _step_result_failed "Target user is invalid: ${TARGET_USER}"
    exit 1
fi

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
fi

_step "Installing prerequisite packages"
apt-get install -y curl ca-certificates build-essential nodejs npm

_step "Installing PM2 and Node-RED"
npm install -g --unsafe-perm pm2 node-red

_step "Configuring Node-RED process on PM2"
run_as_target "pm2 describe node-red >/dev/null 2>&1 || pm2 start \$(command -v node-red) --name node-red -- -v"
run_as_target "pm2 save"

_step "Configuring PM2 startup for user ${TARGET_USER}"
pm2 startup systemd -u "${TARGET_USER}" --hp "$(eval echo "~${TARGET_USER}")" >/tmp/pm2-startup.cmd
if grep -q '^sudo ' /tmp/pm2-startup.cmd; then
    startup_cmd="$(grep '^sudo ' /tmp/pm2-startup.cmd | sed 's/^sudo //')"
    bash -lc "${startup_cmd}"
fi
rm -f /tmp/pm2-startup.cmd

host_ip="$(hostname -I | awk '{print $1}')"
_step_result_success "Node-RED installed and managed by PM2"
_step_result_suggestion "Access Node-RED at: http://${host_ip}:1880"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi