#!/usr/bin/env bash

# ⚠️ Warning: This script requires root privileges (sudo) and may handle secrets/passwords.
# Review commands before execution and avoid exposing credentials in command-line arguments, shell history, or logs.
# See ../../../../security/secrets/README.md for best practices.

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

TARGET_USER="${SUDO_USER:-${USER}}"
NODE_VERSION="lts/*"
RUN_SYSTEM_UPDATE=true
REBOOT_AFTER=false
NVM_VERSION="v0.40.3"

usage() {
    cat <<'EOF'
Usage: sudo ./install-nodejs-standalone.sh [options]

Options:
  --user <username>         User that will own Node.js/NVM installation (default: current sudo user)
  --node-version <version>  Node.js version for NVM (default: lts/*)
  --skip-system-update      Skip apt/dnf/yum update and upgrade
  --reboot                  Reboot host after install
  -h, --help                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)
            TARGET_USER="${2:-}"
            shift 2
            ;;
        --node-version)
            NODE_VERSION="${2:-}"
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

_script_start "Install Node.js (Standalone via NVM)"
__verify_root
__detect_package_manager

if [[ -z "${TARGET_USER}" ]] || ! id "${TARGET_USER}" >/dev/null 2>&1; then
    _step_result_failed "Target user is invalid: ${TARGET_USER}"
    exit 1
fi

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
fi

_step "Installing prerequisite packages"
case "${PACKAGE_MANAGER}" in
    apt)
        apt-get install -y ca-certificates curl build-essential
        ;;
    dnf)
        dnf install -y ca-certificates curl gcc gcc-c++ make
        ;;
    yum)
        yum install -y ca-certificates curl gcc gcc-c++ make
        ;;
esac

_step "Installing NVM for user ${TARGET_USER}"
run_as_target "if [[ ! -s ~/.nvm/nvm.sh ]]; then curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash; fi"

_step "Installing Node.js ${NODE_VERSION} with NVM"
run_as_target "export NVM_DIR=\"\$HOME/.nvm\" && source \"\$NVM_DIR/nvm.sh\" && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && nvm use ${NODE_VERSION}"

_step "Validating Node.js and npm"
node_version="$(run_as_target 'export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && node --version')"
npm_version="$(run_as_target 'export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && npm --version')"
_step_result_success "Node.js installed: ${node_version}"
_step_result_success "npm installed: ${npm_version}"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi
