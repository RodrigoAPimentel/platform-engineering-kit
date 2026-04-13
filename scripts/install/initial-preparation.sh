#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

TIMEZONE="America/Recife"
INSTALL_NODEJS_HELPER=false
REBOOT_AFTER=false

usage() {
	cat <<'EOF'
Usage: sudo ./initial-preparation.sh [options]

Options:
  --timezone <IANA_TZ>   Set system timezone (default: America/Recife)
  --with-nodejs-helper   Run applications/nodejs.sh if present
  --reboot               Reboot host after provisioning
  -h, --help             Show this help

Notes:
  - Run as root (sudo). Legacy sudo password argument is not required.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--timezone)
			TIMEZONE="${2:-}"
			shift 2
			;;
		--with-nodejs-helper)
			INSTALL_NODEJS_HELPER=true
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

_script_start "Initial preparation"
__verify_root
__detect_package_manager
__update_system
__install_prerequisite_packages

if [[ "${INSTALL_NODEJS_HELPER}" == true ]]; then
	node_helper="${SCRIPT_DIR}/applications/nodejs.sh"
	if [[ -x "${node_helper}" ]]; then
		_step "Running optional Node.js helper"
		"${node_helper}"
	elif [[ -f "${node_helper}" ]]; then
		_step "Running optional Node.js helper"
		bash "${node_helper}"
	else
		_step_result_suggestion "Node.js helper not found at ${node_helper}. Skipping."
	fi
fi

_step "Enabling qemu-guest-agent service when available"
if systemctl list-unit-files | grep -q '^qemu-guest-agent.service'; then
	systemctl enable --now qemu-guest-agent
	_step_result_success "qemu-guest-agent enabled"
else
	_step_result_suggestion "qemu-guest-agent service not found"
fi

_step "Applying timezone"
if command -v timedatectl >/dev/null 2>&1; then
	timedatectl set-timezone "${TIMEZONE}"
	_step_result_success "Timezone set to ${TIMEZONE}"
else
	_step_result_suggestion "timedatectl not available"
fi

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
	_step "Rebooting system"
	reboot
else
	_step_result_suggestion "Reboot skipped. Use --reboot to reboot automatically."
fi