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
ADDONS="metrics-server,dashboard,ingress,ingress-dns"
ADDONS_FLAGS=""
DRIVER="docker"
CONFIGURE_INGRESS=true
CONFIGURE_IPTABLES=true
DASHBOARD_DOMAIN="minikube-dashboard"
DASHBOARD_PORT=88
REBOOT_AFTER=false
MINIKUBE_INSTALL_ROOT_FOLDER=""
MINIKUBE_FOLDER=""
NGINX_FOLDER=""
KUBECONFIG_EXTERNAL=""
PROXY_CONTAINER_NAME="nginx-minikube-proxy"

usage() {
    cat <<'EOF'
Usage: sudo ./install-minikube-ubuntu.sh [options]

Options:
  --user <username>          User owner of minikube profile (default: current sudo user)
    --addons <csv>             Minikube addons list (default: metrics-server,dashboard,ingress,ingress-dns)
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

_build_addons_flags() {
    local addons_csv="$1"
    local addon=""
    local trimmed=""
    local addons_flags=()

    IFS=',' read -r -a addons_array <<< "${addons_csv}"
    for addon in "${addons_array[@]}"; do
        trimmed="${addon#"${addon%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        [[ -z "${trimmed}" ]] && continue
        addons_flags+=("--addons=${trimmed}")
    done

    if [[ ${#addons_flags[@]} -eq 0 ]]; then
        _step_result_failed "Addons list cannot be empty"
        exit 1
    fi

    ADDONS_FLAGS="${addons_flags[*]}"
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

_build_addons_flags "${ADDONS}"

TARGET_HOME="$(eval echo "~${TARGET_USER}")"
MINIKUBE_INSTALL_ROOT_FOLDER="${TARGET_HOME}/minikube-install"
MINIKUBE_FOLDER="${MINIKUBE_INSTALL_ROOT_FOLDER}/minikube"
NGINX_FOLDER="${MINIKUBE_INSTALL_ROOT_FOLDER}/nginx"
KUBECONFIG_EXTERNAL="${MINIKUBE_FOLDER}/kubeconfig"

_step "Validating Docker dependency"
if ! command -v docker >/dev/null 2>&1; then
    _step_result_failed "Docker is required. Run install-docker.sh before this script."
    exit 1
fi

_step "Installing prerequisite packages"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates conntrack iptables-persistent apache2-utils yq openssl

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
run_as_target "minikube start --driver='${DRIVER}' ${ADDONS_FLAGS} --force"
run_as_target "minikube status"

_step "Creating systemd service for minikube"
cat > /etc/systemd/system/minikube.service <<EOF
[Unit]
Description=Minikube Cluster Service
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
User=${TARGET_USER}
WorkingDirectory=${TARGET_HOME}
Environment=HOME=${TARGET_HOME}
Environment=MINIKUBE_HOME=${TARGET_HOME}/.minikube
Environment=KUBECONFIG=${TARGET_HOME}/.kube/config
ExecStartPre=/bin/sh -c 'until /usr/bin/docker info >/dev/null 2>&1; do sleep 2; done'
ExecStart=/usr/local/bin/minikube start --driver=${DRIVER} ${ADDONS_FLAGS} --force
ExecStop=/usr/local/bin/minikube stop
TimeoutStartSec=900
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable minikube.service

_section "Configure NGINX Proxy and External Access"

_step "Preparing directories and Minikube certificates"
install -d -m 0755 "${MINIKUBE_FOLDER}" "${NGINX_FOLDER}"
cp -f "${TARGET_HOME}/.minikube/profiles/minikube/client.crt" "${MINIKUBE_FOLDER}/client.crt"
cp -f "${TARGET_HOME}/.minikube/profiles/minikube/client.key" "${MINIKUBE_FOLDER}/client.key"
cp -f "${TARGET_HOME}/.minikube/ca.crt" "${MINIKUBE_FOLDER}/ca.crt"

_step "Generating NGINX basic auth"
proxy_password="$(openssl rand -base64 24 | tr -d '\n' | tr '/+' 'ab')"
htpasswd -cb "${NGINX_FOLDER}/.htpasswd" "${TARGET_USER}" "${proxy_password}" >/dev/null
chmod 0600 "${NGINX_FOLDER}/.htpasswd"
printf 'username=%s\npassword=%s\n' "${TARGET_USER}" "${proxy_password}" > "${NGINX_FOLDER}/proxy-credentials.txt"
chmod 0600 "${NGINX_FOLDER}/proxy-credentials.txt"

_step "Creating nginx.conf"
cat > "${NGINX_FOLDER}/nginx.conf" <<EOF
events {
        worker_connections 1024;
}
http {
    server_tokens off;
    auth_basic "Minikube Proxy";
    auth_basic_user_file /etc/nginx/.htpasswd;

    server {
        listen 443;
        server_name _;

        location / {
            proxy_set_header X-Forwarded-For \$remote_addr;
            proxy_set_header Host \$http_host;
            proxy_pass https://minikube:8443;
            proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
            proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
        }
    }
}
EOF

_step "Creating Dockerfile for nginx proxy"
cat > "${NGINX_FOLDER}/Dockerfile" <<EOF
FROM nginx:latest

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/.htpasswd /etc/nginx/.htpasswd
COPY minikube/client.key /etc/nginx/certs/minikube-client.key
COPY minikube/client.crt /etc/nginx/certs/minikube-client.crt
EOF

_step "Building nginx proxy image"
docker build -t "${PROXY_CONTAINER_NAME}" -f "${NGINX_FOLDER}/Dockerfile" "${MINIKUBE_INSTALL_ROOT_FOLDER}"

_step "Running nginx proxy container"
network_name="minikube"
if ! docker network inspect "${network_name}" >/dev/null 2>&1; then
        _step_result_suggestion "Docker network 'minikube' not found. Falling back to 'bridge'."
        network_name="bridge"
fi
docker rm -f "${PROXY_CONTAINER_NAME}" >/dev/null 2>&1 || true
docker run -d \
        --name "${PROXY_CONTAINER_NAME}" \
        --memory "500m" \
        --memory-reservation "256m" \
        --cpus "0.25" \
        --restart always \
        -p 443:443 \
        -p 80:80 \
        --network "${network_name}" \
        "${PROXY_CONTAINER_NAME}" >/dev/null

_step "Generating external kubeconfig"
run_as_target "cp -f ~/.kube/config '${KUBECONFIG_EXTERNAL}'"
host_ip="$(hostname -I | awk '{print $1}')"
if command -v yq >/dev/null 2>&1; then
        yq -i ".clusters[0].cluster.server = \"https://${TARGET_USER}:${proxy_password}@${host_ip}:443\"" "${KUBECONFIG_EXTERNAL}"
        yq -i '.clusters[0].cluster."certificate-authority" = "ca.crt"' "${KUBECONFIG_EXTERNAL}"
        yq -i '.users[0].user."client-certificate" = "client.crt"' "${KUBECONFIG_EXTERNAL}"
        yq -i '.users[0].user."client-key" = "client.key"' "${KUBECONFIG_EXTERNAL}"
fi
chown -R "${TARGET_USER}:${TARGET_USER}" "${MINIKUBE_INSTALL_ROOT_FOLDER}"

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
_step_result_success "Minikube status:"
run_as_target "minikube status"
_step_result_success "Dashboard URL: http://${DASHBOARD_DOMAIN}:${DASHBOARD_PORT}"
_step_result_suggestion "Add to your hosts file: ${host_ip} ${DASHBOARD_DOMAIN}"
_step_result_suggestion "If needed, copy kubeconfig from ~${TARGET_USER}/.kube/config"
_step_result_suggestion "External access bundle: ${MINIKUBE_INSTALL_ROOT_FOLDER}"
_step_result_suggestion "NGINX proxy credentials file: ${NGINX_FOLDER}/proxy-credentials.txt"
_step_result_suggestion "External kubeconfig: ${KUBECONFIG_EXTERNAL}"

_finish_information

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
else
    _step_result_suggestion "Reboot skipped. Open a new shell session before running kubectl/minikube as ${TARGET_USER}."
fi
