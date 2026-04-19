#!/usr/bin/env bash

# ⚠️ Atenção: Este script exige privilégios de root (sudo) e pode manipular secrets/senhas.
# Revise comandos antes de executar e evite expor credenciais em linha de comando, histórico de shell ou logs.
# Veja ../../../../security/secrets/README.md para boas práticas.

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../../utils/lib"
NODEJS_HELPER_SCRIPT="${SCRIPT_DIR}/install-nodejs-standalone.sh"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

TARGET_USER="${SUDO_USER:-${USER}}"
RUN_SYSTEM_UPDATE=true
INSTALL_NODEJS_IF_MISSING=true
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./install-pm2-standalone.sh [options]

Options:
  --user <username>         User that will own PM2 setup (default: current sudo user)
  --skip-system-update      Skip apt/dnf/yum update and upgrade
  --skip-nodejs-install     Fail if npm is missing instead of auto-installing Node.js helper
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
        --skip-system-update)
            RUN_SYSTEM_UPDATE=false
            shift
            ;;
        --skip-nodejs-install)
            INSTALL_NODEJS_IF_MISSING=false
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

_script_start "Install PM2 (Standalone)"
__verify_root
__detect_package_manager

if [[ -z "${TARGET_USER}" ]] || ! id "${TARGET_USER}" >/dev/null 2>&1; then
    _step_result_failed "Target user is invalid: ${TARGET_USER}"
    exit 1
fi

if [[ "${RUN_SYSTEM_UPDATE}" == true ]]; then
    __update_system
fi

_step "Ensuring npm is available"
if ! run_as_target 'command -v npm >/dev/null 2>&1'; then
    if [[ "${INSTALL_NODEJS_IF_MISSING}" == true ]]; then
        _step_result_suggestion "npm not found for target user. Running Node.js helper script"
        if [[ ! -x "${NODEJS_HELPER_SCRIPT}" ]]; then
            chmod +x "${NODEJS_HELPER_SCRIPT}"
        fi
        "${NODEJS_HELPER_SCRIPT}" --user "${TARGET_USER}" --skip-system-update
    else
        _step_result_failed "npm is required but not installed. Re-run without --skip-nodejs-install"
        exit 1
    fi
fi

_step "Installing PM2 globally for user ${TARGET_USER}"
run_as_target 'if command -v npm >/dev/null 2>&1; then npm install -g pm2; fi'

_step "Configuring PM2 startup"
startup_output="$(run_as_target 'pm2 startup systemd -u "${USER}" --hp "$HOME"' 2>/dev/null || true)"
if [[ -n "${startup_output}" ]] && grep -q '^sudo ' <<<"${startup_output}"; then
    startup_cmd="$(grep '^sudo ' <<<"${startup_output}" | sed 's/^sudo //')"
    bash -lc "${startup_cmd}"
fi
run_as_target 'pm2 save'

_step "Validating PM2 installation"
pm2_version="$(run_as_target 'pm2 --version')"
_step_result_success "PM2 installed: ${pm2_version}"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi
