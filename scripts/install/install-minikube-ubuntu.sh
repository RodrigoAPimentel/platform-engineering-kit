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
ADDONS="ingress,ingress-dns,dashboard"
DRIVER="docker"
CONFIGURE_INGRESS=true
CONFIGURE_IPTABLES=true
DASHBOARD_DOMAIN="minikube-dashboard"
DASHBOARD_PORT=88
REBOOT_AFTER=false

usage() {
    cat <<'EOF'
Usage: sudo ./install-minikube-ubuntu.sh [options]

Options:
  --user <username>          User owner of minikube profile (default: current sudo user)
  --addons <csv>             Minikube addons list (default: ingress,ingress-dns,dashboard)
  --driver <name>            Minikube driver (default: docker)
  --dashboard-domain <host>  Dashboard host for ingress (default: minikube-dashboard)
  --dashboard-port <port>    External forwarded port (default: 88)
  --skip-ingress             Skip kubernetes-dashboard ingress creation
  --skip-iptables            Skip iptables forwarding rules
  --reboot                   Reboot host at the end
  -h, --help                 Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)
            TARGET_USER="${2:-}"
            shift 2
            ;;
        --addons)
            ADDONS="${2:-}"
            shift 2
            ;;
        --driver)
            DRIVER="${2:-}"
            shift 2
            ;;
        --dashboard-domain)
            DASHBOARD_DOMAIN="${2:-}"
            shift 2
            ;;
        --dashboard-port)
            DASHBOARD_PORT="${2:-}"
            shift 2
            ;;
        --skip-ingress)
            CONFIGURE_INGRESS=false
            shift
            ;;
        --skip-iptables)
            CONFIGURE_IPTABLES=false
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

_script_start "Install Minikube (Ubuntu/Debian)"
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

_step "Validating Docker dependency"
if ! command -v docker >/dev/null 2>&1; then
    _step_result_failed "Docker is required. Run install-docker.sh before this script."
    exit 1
fi

_step "Installing prerequisite packages"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates conntrack iptables-persistent

_step "Installing Minikube binary"
curl -fsSL -o /tmp/minikube-linux-amd64 https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
install -m 0755 /tmp/minikube-linux-amd64 /usr/local/bin/minikube
rm -f /tmp/minikube-linux-amd64
__verify_packages_installed minikube

_step "Installing kubectl binary"
kubectl_version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl"
curl -fsSL -o /tmp/kubectl.sha256 "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl.sha256"
(cd /tmp && echo "$(cat /tmp/kubectl.sha256)  kubectl" | sha256sum --check)
install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm -f /tmp/kubectl /tmp/kubectl.sha256
__verify_packages_installed kubectl

_step "Configuring minikube driver"
run_as_target "minikube config set driver '${DRIVER}'"

_step "Starting minikube cluster"
run_as_target "minikube start --driver='${DRIVER}' --addons='${ADDONS}' --force"
run_as_target "minikube status"

_step "Creating systemd service for minikube"
cat > /etc/systemd/system/minikube.service <<EOF
[Unit]
Description=Minikube Cluster Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
User=${TARGET_USER}
ExecStart=/usr/local/bin/minikube start --driver=${DRIVER} --addons=${ADDONS} --force
ExecStop=/usr/local/bin/minikube stop

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable minikube.service

if [[ "${CONFIGURE_INGRESS}" == true ]]; then
    _step "Configuring Kubernetes Dashboard ingress"
    cat > /tmp/ingress-kubernetes-dashboard.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  namespace: kubernetes-dashboard
spec:
  rules:
    - host: ${DASHBOARD_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kubernetes-dashboard
                port:
                  number: 80
EOF

    run_as_target "kubectl apply -f /tmp/ingress-kubernetes-dashboard.yaml"
    rm -f /tmp/ingress-kubernetes-dashboard.yaml
fi

if [[ "${CONFIGURE_IPTABLES}" == true ]]; then
    _step "Configuring iptables forwarding for dashboard"
    minikube_ip="$(run_as_target 'minikube ip')"
    iptables -t nat -C PREROUTING -p tcp --dport "${DASHBOARD_PORT}" -j DNAT --to-destination "${minikube_ip}:80" 2>/dev/null || \
        iptables -t nat -A PREROUTING -p tcp --dport "${DASHBOARD_PORT}" -j DNAT --to-destination "${minikube_ip}:80"
    iptables -C FORWARD -p tcp -d "${minikube_ip}" --dport 80 -j ACCEPT 2>/dev/null || \
        iptables -A FORWARD -p tcp -d "${minikube_ip}" --dport 80 -j ACCEPT
    sh -c 'iptables-save > /etc/iptables/rules.v4'
fi

_step "Summary"
host_ip="$(hostname -I | awk '{print $1}')"
_step_result_success "Minikube status:"
run_as_target "minikube status"
_step_result_success "Dashboard URL: http://${DASHBOARD_DOMAIN}:${DASHBOARD_PORT}"
_step_result_suggestion "Add to your hosts file: ${host_ip} ${DASHBOARD_DOMAIN}"
_step_result_suggestion "If needed, copy kubeconfig from ~${TARGET_USER}/.kube/config"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
else
    _step_result_suggestion "Reboot skipped. Open a new shell session before running kubectl/minikube as ${TARGET_USER}."
fi
