#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

ARGOCD_VERSION="${ARGOCD_VERSION:-stable}"
ARGOCD_DASHBOARD_DOMAIN="${ARGOCD_DASHBOARD_DOMAIN:-argocd-gui}"
ARGOCD_DASHBOARD_PORT="${ARGOCD_DASHBOARD_PORT:-88}"
CONFIGURE_IPTABLES=true

_run_minikube() {
    local minikube_user=""

    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        minikube_user="${SUDO_USER}"
    elif [[ -n "${KUBECONFIG:-}" && -f "${KUBECONFIG}" ]]; then
        minikube_user="$(stat -c '%U' "${KUBECONFIG}" 2>/dev/null || true)"
        if [[ "${minikube_user}" == "root" ]]; then
            minikube_user=""
        fi
    fi

    if [[ -n "${minikube_user}" ]]; then
        if [[ -n "${KUBECONFIG:-}" ]]; then
            sudo -u "${minikube_user}" -H env KUBECONFIG="${KUBECONFIG}" minikube "$@"
            return
        fi

        sudo -u "${minikube_user}" -H minikube "$@"
        return
    fi

    minikube "$@"
}

_configure_kube_access() {
    if [[ -n "${KUBECONFIG:-}" ]]; then
        _step_result_suggestion "Using KUBECONFIG from environment: ${KUBECONFIG}"
        return
    fi

    if [[ -n "${SUDO_USER:-}" ]]; then
        local sudo_home
        sudo_home="$(getent passwd "${SUDO_USER}" | cut -d: -f6)"

        if [[ -n "${sudo_home}" && -f "${sudo_home}/.kube/config" ]]; then
            export KUBECONFIG="${sudo_home}/.kube/config"
            _step_result_success "Using kubeconfig from sudo user: ${KUBECONFIG}"
            return
        fi
    fi

    _step_result_suggestion "No explicit kubeconfig found; kubectl default resolution will be used"
}

_verify_kubernetes_connectivity() {
    _step "Validating Minikube and Kubernetes API connectivity"

    if ! _run_minikube status >/dev/null 2>&1; then
        _step_result_suggestion "Unable to read Minikube status with current context. Continuing with Kubernetes API checks"
    else
        _step_result_success "Minikube status is reachable"
    fi

    if ! kubectl cluster-info >/dev/null 2>&1; then
        local current_context
        current_context="$(kubectl config current-context 2>/dev/null || true)"

        if [[ -z "${current_context}" ]]; then
            _step_result_failed "kubectl has no current context. If running with sudo, ensure your user kubeconfig is accessible or export KUBECONFIG before running this script"
        else
            _step_result_failed "Unable to connect to Kubernetes API using context '${current_context}'. Check cluster status and kubeconfig"
        fi

        exit 1
    fi

    _step_result_success "Kubernetes API is reachable"
}

usage() {
    cat <<'EOF'
Usage: sudo ./install-argocd-minikube.sh [options]

Options:
  --version <tag|stable>     Argo CD release to install (default: stable)
  --dashboard-domain <host>  Dashboard host (default: argocd-gui)
  --dashboard-port <port>    External dashboard port (default: 88)
  --skip-iptables            Skip iptables configuration
  -h, --help                 Show this help

Notes:
  - Requires Minikube and kubectl already installed and configured.
  - Run as root (sudo). Legacy sudo password argument is not required.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            ARGOCD_VERSION="${2:-}"
            shift 2
            ;;
        --dashboard-domain)
            ARGOCD_DASHBOARD_DOMAIN="${2:-}"
            shift 2
            ;;
        --dashboard-port)
            ARGOCD_DASHBOARD_PORT="${2:-}"
            shift 2
            ;;
        --skip-iptables)
            CONFIGURE_IPTABLES=false
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

_script_start "Install Argo CD on Minikube"
__verify_root

_step "Validating required binaries"
for binary in minikube kubectl curl; do
    __verify_packages_installed "${binary}"
done

_configure_kube_access
_verify_kubernetes_connectivity

_step "Ensuring argocd namespace exists"
if kubectl get namespace argocd >/dev/null 2>&1; then
    _step_result_suggestion "Namespace argocd already exists"
else
    kubectl create namespace argocd
    _step_result_success "Namespace argocd created"
fi

_step "Installing Argo CD (${ARGOCD_VERSION})"
kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

_step "Waiting for argocd-server deployment to become available"
kubectl -n argocd wait --for=condition=Available deployment/argocd-server --timeout=10m

_step "Installing argocd CLI"
tmp_argocd_bin="$(mktemp)"
curl -fsSL -o "${tmp_argocd_bin}" "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
install -m 0555 "${tmp_argocd_bin}" /usr/local/bin/argocd
rm -f "${tmp_argocd_bin}"
_step_result_success "argocd CLI installed at /usr/local/bin/argocd"

if [[ "${CONFIGURE_IPTABLES}" == true ]]; then
    _step "Configuring iptables for external dashboard access"
    running_minikube_ip="$(_run_minikube ip)"

    if iptables -t nat -C PREROUTING -p tcp --dport "${ARGOCD_DASHBOARD_PORT}" -j DNAT --to-destination "${running_minikube_ip}:80" 2>/dev/null; then
        _step_result_suggestion "NAT PREROUTING rule already exists"
    else
        iptables -t nat -A PREROUTING -p tcp --dport "${ARGOCD_DASHBOARD_PORT}" -j DNAT --to-destination "${running_minikube_ip}:80"
        _step_result_success "NAT PREROUTING rule created"
    fi

    if iptables -C FORWARD -p tcp -d "${running_minikube_ip}" --dport 80 -j ACCEPT 2>/dev/null; then
        _step_result_suggestion "FORWARD rule already exists"
    else
        iptables -A FORWARD -p tcp -d "${running_minikube_ip}" --dport 80 -j ACCEPT
        _step_result_success "FORWARD rule created"
    fi

    if [[ -d /etc/iptables ]] && command -v iptables-save >/dev/null 2>&1 && command -v ip6tables-save >/dev/null 2>&1; then
        iptables-save > /etc/iptables/rules.v4
        ip6tables-save > /etc/iptables/rules.v6
        _step_result_success "iptables rules persisted"
    else
        _step_result_suggestion "iptables persistence not configured (missing /etc/iptables or save commands)"
    fi
else
    _step_result_suggestion "Skipping iptables configuration (--skip-iptables)"
fi

_step "Creating Argo CD ingress"
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - host: ${ARGOCD_DASHBOARD_DOMAIN}
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              name: http
EOF
_step_result_success "Ingress configured"

_step "Configuring argocd-server to run with --insecure"
if kubectl -n argocd get deployment argocd-server -o jsonpath='{.spec.template.spec.containers[0].command}' | grep -q -- '--insecure'; then
    _step_result_suggestion "argocd-server already contains --insecure"
else
    kubectl -n argocd patch deployment argocd-server --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/command/-","value":"--insecure"}]'
    _step_result_success "argocd-server updated with --insecure"
fi

_step "Enabling SSL passthrough in ingress-nginx controller when available"
if kubectl -n ingress-nginx get deployment ingress-nginx-controller >/dev/null 2>&1; then
    if kubectl -n ingress-nginx get deployment ingress-nginx-controller -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--enable-ssl-passthrough'; then
        _step_result_suggestion "ingress-nginx already contains --enable-ssl-passthrough"
    else
        kubectl -n ingress-nginx patch deployment ingress-nginx-controller --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-ssl-passthrough"}]'
        _step_result_success "ingress-nginx updated with --enable-ssl-passthrough"
    fi
else
    _step_result_suggestion "ingress-nginx controller not found; skipping SSL passthrough patch"
fi

_step "Collecting access information"
host_ip="$(hostname -I | awk '{print $1}')"
if kubectl -n argocd get secret argocd-initial-admin-secret >/dev/null 2>&1; then
    argocd_initial_pass="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
    _step_result_success "Argo CD admin credentials: admin|${argocd_initial_pass}"
else
    _step_result_suggestion "Initial admin secret not found yet. Check again with: kubectl -n argocd get secret argocd-initial-admin-secret"
fi

_step_result_success "Add to /etc/hosts: ${host_ip} ${ARGOCD_DASHBOARD_DOMAIN}"
_step_result_success "Access URL: http://${ARGOCD_DASHBOARD_DOMAIN}:${ARGOCD_DASHBOARD_PORT}"

_finish_information
