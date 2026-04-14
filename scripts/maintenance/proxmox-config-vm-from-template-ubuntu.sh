#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

HOSTNAME_VALUE=""
IP_CIDR=""
GATEWAY_IP=""
NETPLAN_IFACE="ens18"
DNS_SERVERS="1.1.1.1,8.8.8.8"
KEYBOARD_LAYOUT="br"
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./proxmox-config-vm-from-template-ubuntu.sh --hostname <name> --ip-cidr <ip/mask> --gateway <ip> [options]

Options:
  --hostname <name>       Hostname to set
  --ip-cidr <ip/mask>     Static address in CIDR notation (example: 192.168.10.50/24)
  --gateway <ip>          Default gateway
  --iface <name>          Netplan interface name (default: ens18)
  --dns <csv>             Comma-separated DNS list (default: 1.1.1.1,8.8.8.8)
  --keyboard <layout>     Keyboard layout in /etc/default/keyboard (default: br)
  --reboot                Reboot host after configuration
  -h, --help              Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --hostname)
            HOSTNAME_VALUE="${2:-}"
            shift 2
            ;;
        --ip-cidr)
            IP_CIDR="${2:-}"
            shift 2
            ;;
        --gateway)
            GATEWAY_IP="${2:-}"
            shift 2
            ;;
        --iface)
            NETPLAN_IFACE="${2:-}"
            shift 2
            ;;
        --dns)
            DNS_SERVERS="${2:-}"
            shift 2
            ;;
        --keyboard)
            KEYBOARD_LAYOUT="${2:-}"
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

_script_start "Proxmox VM post-clone configuration (Ubuntu)"
__verify_root
__detect_package_manager

if [[ "${PACKAGE_MANAGER}" != "apt" ]]; then
    _step_result_failed "This script currently supports apt-based systems only"
    exit 1
fi

if [[ -z "${HOSTNAME_VALUE}" || -z "${IP_CIDR}" || -z "${GATEWAY_IP}" ]]; then
    _step_result_failed "Missing required arguments: --hostname, --ip-cidr, --gateway"
    usage
    exit 1
fi

_step "Installing openssh-server"
apt-get install -y openssh-server

_step "Setting hostname"
hostnamectl set-hostname "${HOSTNAME_VALUE}"

_step "Configuring netplan"
cat > /etc/netplan/50-cloud-init.yaml <<EOF
network:
  version: 2
  ethernets:
    ${NETPLAN_IFACE}:
      dhcp4: false
      addresses:
        - ${IP_CIDR}
      gateway4: ${GATEWAY_IP}
      nameservers:
        addresses: [${DNS_SERVERS}]
      optional: true
EOF
netplan generate
netplan apply

_step "Configuring keyboard layout"
if [[ -f /etc/default/keyboard ]]; then
    sed -i "s|^XKBLAYOUT=.*|XKBLAYOUT=\"${KEYBOARD_LAYOUT}\"|g" /etc/default/keyboard
fi

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
else
    _step_result_suggestion "Reboot skipped. Validate connectivity and hostname manually."
fi


