#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../utils/lib"

# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/system-functions.sh"

AWX_VERSION="17.1.0"
AWX_ADMIN_USER="root"
AWX_ADMIN_PASSWORD="toor"
AWX_SECRET_KEY=""
DOCKER_COMPOSE_VERSION="2.13.0"
SKIP_SYSTEM_UPDATE=false
REBOOT_AFTER=false
ANSIBLE_PYTHON_INTERPRETER_BIN="$(command -v python3 || echo /usr/bin/python3)"
INSTALL_METHOD="auto"
AWX_OPERATOR_VERSION="2.19.1"
AWX_NAMESPACE="awx"
AWX_INSTANCE_NAME="awx"
KUBE_RBAC_PROXY_IMAGE="quay.io/brancz/kube-rbac-proxy:v0.15.0"
SELECTED_INSTALL_METHOD=""
UNINSTALL_MODE=false
REMOVE_OPERATOR_ON_UNINSTALL=false
DESTRUCTIVE_UNINSTALL=false

update_npm_if_compatible() {
    if ! command -v npm >/dev/null 2>&1; then
        return 0
    fi

    # Newer npm releases require newer Node.js. Do not fail AWX install if npm self-update is unsupported.
    if npm install --global npm >/tmp/npm-self-update.log 2>&1; then
        _step_result_success "npm updated to latest version"
    else
        _step_result_suggestion "Skipping npm self-update due to Node.js compatibility constraints (details: /tmp/npm-self-update.log)"
    fi
}

is_docker_installed() {
    command -v docker >/dev/null 2>&1
}

is_docker_compose_installed() {
    if command -v docker-compose >/dev/null 2>&1; then
        return 0
    fi

    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

run_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        docker-compose "$@"
        return
    fi

    docker compose "$@"
}

ensure_ansible_compose_python_module() {
    _step "Ensuring Python docker-compose module for Ansible"

    if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
        _step_result_success "Python docker-compose module already available"
        return
    fi

    # Prefer distro packages first to avoid externally-managed Python issues (PEP 668).
    case "${PACKAGE_MANAGER}" in
        apt)
            if apt-get install -y docker-compose >/tmp/awx-compose-package.log 2>&1; then
                if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                    _step_result_success "Python docker-compose module installed via apt package"
                    return
                fi
            fi
            ;;
        dnf)
            dnf install -y docker-compose >/tmp/awx-compose-package.log 2>&1 || true
            if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                _step_result_success "Python docker-compose module installed via dnf package"
                return
            fi
            ;;
        yum)
            yum install -y docker-compose >/tmp/awx-compose-package.log 2>&1 || true
            if "${ANSIBLE_PYTHON_INTERPRETER_BIN}" -c 'import compose' >/dev/null 2>&1; then
                _step_result_success "Python docker-compose module installed via yum package"
                return
            fi
            ;;
    esac

    # Fallback: isolated venv for Ansible runtime.
    local awx_venv_dir="/opt/awx-installer-venv"

    if ! python3 -m venv "${awx_venv_dir}" >/tmp/awx-compose-venv.log 2>&1; then
        if [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
            apt-get install -y python3-venv >/tmp/awx-compose-venv.log 2>&1
            python3 -m venv "${awx_venv_dir}" >/tmp/awx-compose-venv.log 2>&1
        else
            _step_result_failed "Failed to create Python venv for AWX installer (details: /tmp/awx-compose-venv.log)"
            exit 1
        fi
    fi

    if "${awx_venv_dir}/bin/pip" install --upgrade pip >/tmp/pip-docker-compose.log 2>&1 \
        && "${awx_venv_dir}/bin/pip" install docker-compose==1.29.2 >/tmp/pip-docker-compose.log 2>&1 \
        && "${awx_venv_dir}/bin/python" -c 'import compose' >/dev/null 2>&1; then
        ANSIBLE_PYTHON_INTERPRETER_BIN="${awx_venv_dir}/bin/python"
        _step_result_success "Python docker-compose module installed in venv (${awx_venv_dir})"
    else
        _step_result_failed "Failed to install Python docker-compose module (details: /tmp/pip-docker-compose.log)"
        exit 1
    fi
}

is_known_awx_compose_containerconfig_error() {
    local playbook_log_file="${1:-}"

    if [[ -z "${playbook_log_file}" || ! -f "${playbook_log_file}" ]]; then
        return 1
    fi

    grep -q "Error starting project 'ContainerConfig'" "${playbook_log_file}"
}

install_awx_with_operator() {
    _step "Installing AWX via AWX Operator (namespace: ${AWX_NAMESPACE})"
    local minikube_running=false
    local sudo_user_home=""
    local sudo_user_kubeconfig=""

    if ! command -v kubectl >/dev/null 2>&1; then
        _step_result_failed "AWX ${AWX_VERSION} requires Kubernetes (operator mode), but kubectl is not installed"
        _step_result_suggestion "Install kubectl and ensure a Kubernetes cluster or Minikube is running"
        exit 1
    fi

    # When running with sudo, prefer the original user's kubeconfig to avoid false negatives.
    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        sudo_user_home="$(getent passwd "${SUDO_USER}" | cut -d: -f6 || true)"
        sudo_user_kubeconfig="${sudo_user_home}/.kube/config"

        if [[ -n "${sudo_user_home}" && -f "${sudo_user_kubeconfig}" ]]; then
            export KUBECONFIG="${sudo_user_kubeconfig}"
            _step_result_suggestion "Using kubeconfig from sudo user (${SUDO_USER})"
        fi
    fi

    if command -v minikube >/dev/null 2>&1; then
        if minikube status >/tmp/awx-minikube-status.log 2>&1; then
            minikube_running=true
        elif [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
            if runuser -u "${SUDO_USER}" -- minikube status >/tmp/awx-minikube-status.log 2>&1; then
                minikube_running=true
            fi
        fi
    fi

    if ! kubectl cluster-info >/tmp/awx-k8s-cluster-info.log 2>&1; then
        if command -v minikube >/dev/null 2>&1; then
            if [[ "${minikube_running}" == true ]]; then
                _step_result_failed "Kubernetes API is not reachable by kubectl (details: /tmp/awx-k8s-cluster-info.log)"
                _step_result_suggestion "Check kubectl context and cluster connectivity"
                _step_result_suggestion "If needed, run: kubectl config use-context minikube"
            else
                _step_result_failed "AWX ${AWX_VERSION} requires Kubernetes, but Minikube is not running"
                _step_result_suggestion "Start Minikube first (example: minikube start)"
                _step_result_suggestion "Details: /tmp/awx-minikube-status.log"
            fi
        else
            _step_result_failed "AWX ${AWX_VERSION} requires Kubernetes, but no reachable cluster was found"
            _step_result_suggestion "Start a Kubernetes cluster or install/start Minikube before running this script"
            _step_result_suggestion "Details: /tmp/awx-k8s-cluster-info.log"
        fi
        exit 1
    fi

    if ! kubectl get namespace "${AWX_NAMESPACE}" >/dev/null 2>&1; then
        kubectl create namespace "${AWX_NAMESPACE}" >/dev/null
    fi

    if kubectl apply -k "github.com/ansible/awx-operator/config/default?ref=${AWX_OPERATOR_VERSION}" >/tmp/awx-operator-apply.log 2>&1; then
        _step_result_success "AWX Operator manifests applied"
    else
        _step_result_failed "Failed to apply AWX Operator manifests (details: /tmp/awx-operator-apply.log)"
        exit 1
    fi

    # Some operator manifests still reference unavailable gcr kube-rbac-proxy tags.
    _step "Checking operator proxy image compatibility"
    if kubectl -n "${AWX_NAMESPACE}" get deployment awx-operator-controller-manager >/dev/null 2>&1; then
        operator_containers="$(kubectl -n "${AWX_NAMESPACE}" get deployment awx-operator-controller-manager -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"="}{.image}{"\n"}{end}' 2>/tmp/awx-operator-images.log || true)"
        patched_proxy=false

        while IFS='=' read -r container_name container_image; do
            if [[ -n "${container_name}" && "${container_image}" == gcr.io/kubebuilder/kube-rbac-proxy:* ]]; then
                if kubectl -n "${AWX_NAMESPACE}" set image deployment/awx-operator-controller-manager "${container_name}=${KUBE_RBAC_PROXY_IMAGE}" >/tmp/awx-operator-proxy-patch.log 2>&1; then
                    patched_proxy=true
                fi
            fi
        done <<< "${operator_containers}"

        if [[ "${patched_proxy}" == true ]]; then
            _step_result_success "Patched operator proxy image to ${KUBE_RBAC_PROXY_IMAGE}"
        else
            _step_result_suggestion "No proxy image patch needed for operator deployment"
        fi
    else
        _step_result_suggestion "Operator deployment not found yet for proxy image check"
    fi

    if kubectl -n "${AWX_NAMESPACE}" wait --for=condition=Available deployment/awx-operator-controller-manager --timeout=600s >/tmp/awx-operator-wait.log 2>&1; then
        _step_result_success "AWX Operator controller is ready"
    else
        _step_result_failed "AWX Operator controller did not become ready (details: /tmp/awx-operator-wait.log)"
        exit 1
    fi

    kubectl -n "${AWX_NAMESPACE}" apply -f - <<EOF >/tmp/awx-operator-secret.log 2>&1
apiVersion: v1
kind: Secret
metadata:
  name: awx-admin-password
type: Opaque
stringData:
  password: "${AWX_ADMIN_PASSWORD}"
EOF

            if kubectl -n "${AWX_NAMESPACE}" apply -f - <<EOF >/tmp/awx-operator-awx.log 2>&1
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
        name: ${AWX_INSTANCE_NAME}
spec:
        admin_user: "${AWX_ADMIN_USER}"
        admin_password_secret: awx-admin-password
        service_type: NodePort
EOF
    then
        _step_result_success "AWX custom resource applied"
    else
        _step_result_failed "Failed to apply AWX custom resource (details: /tmp/awx-operator-awx.log)"
        exit 1
    fi

    _step_result_suggestion "Operator deployment started. Monitor with: kubectl -n ${AWX_NAMESPACE} get pods"
    _step_result_suggestion "Retrieve admin password secret with: kubectl -n ${AWX_NAMESPACE} get secret awx-admin-password -o jsonpath='{.data.password}' | base64 -d"
}

uninstall_awx() {
    _step "Uninstalling AWX"
    local sudo_user_home=""

    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        sudo_user_home="$(getent passwd "${SUDO_USER}" | cut -d: -f6 || true)"
        if [[ -n "${sudo_user_home}" && -f "${sudo_user_home}/.kube/config" ]]; then
            export KUBECONFIG="${sudo_user_home}/.kube/config"
            _step_result_suggestion "Using kubeconfig from sudo user (${SUDO_USER})"
        fi
    fi

    removed_any=false

    # Operator-based uninstall, following AWX Operator docs: delete AWX custom resource.
    if command -v kubectl >/dev/null 2>&1 && kubectl api-resources --api-group=awx.ansible.com -o name 2>/dev/null | grep -q '^awxs$'; then
        if kubectl -n "${AWX_NAMESPACE}" get awx "${AWX_INSTANCE_NAME}" >/dev/null 2>&1; then
            kubectl -n "${AWX_NAMESPACE}" delete awx "${AWX_INSTANCE_NAME}" >/tmp/awx-uninstall-awx.log 2>&1
            _step_result_success "AWX custom resource deleted: ${AWX_INSTANCE_NAME}"
            _step_result_suggestion "Persistent volumes and secrets may remain by design"
            removed_any=true
        else
            _step_result_suggestion "No AWX custom resource named ${AWX_INSTANCE_NAME} found in namespace ${AWX_NAMESPACE}"
        fi

        if [[ "${REMOVE_OPERATOR_ON_UNINSTALL}" == true ]]; then
            kubectl delete -k "github.com/ansible/awx-operator/config/default?ref=${AWX_OPERATOR_VERSION}" >/tmp/awx-uninstall-operator.log 2>&1 || true
            kubectl -n "${AWX_NAMESPACE}" delete deployment awx-operator-controller-manager --ignore-not-found >/dev/null 2>&1 || true
            _step_result_success "AWX Operator removal attempted"
            removed_any=true
        fi
    else
        _step_result_suggestion "AWX Operator CRD not found; skipping Kubernetes uninstall"
    fi

    # Legacy Docker-based uninstall.
    if [[ -f /root/.awx/awxcompose/docker-compose.yml ]]; then
        _step "Stopping legacy AWX containers"
        run_docker_compose -f /root/.awx/awxcompose/docker-compose.yml down || true
        _step_result_success "Legacy AWX containers stop requested"
        removed_any=true
    fi

    if [[ "${DESTRUCTIVE_UNINSTALL}" == true ]]; then
        _step "Running destructive uninstall cleanup"
        _step_result_suggestion "Destructive mode enabled: removing namespace/PVC/secrets/PV and legacy local artifacts"

        if command -v kubectl >/dev/null 2>&1; then
            if kubectl get namespace "${AWX_NAMESPACE}" >/dev/null 2>&1; then
                kubectl -n "${AWX_NAMESPACE}" delete awx --all --ignore-not-found >/tmp/awx-destructive-delete-awx.log 2>&1 || true
                kubectl -n "${AWX_NAMESPACE}" delete pvc --all --ignore-not-found >/tmp/awx-destructive-delete-pvc.log 2>&1 || true
                kubectl -n "${AWX_NAMESPACE}" delete secret --all --ignore-not-found >/tmp/awx-destructive-delete-secret.log 2>&1 || true

                bound_pvs="$(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="'"${AWX_NAMESPACE}"'")]}{.metadata.name}{"\n"}{end}' 2>/tmp/awx-destructive-list-pv.log || true)"
                while IFS= read -r pv_name; do
                    [[ -z "${pv_name}" ]] && continue
                    kubectl delete pv "${pv_name}" --ignore-not-found >/tmp/awx-destructive-delete-pv.log 2>&1 || true
                done <<< "${bound_pvs}"

                kubectl delete namespace "${AWX_NAMESPACE}" --ignore-not-found >/tmp/awx-destructive-delete-namespace.log 2>&1 || true
                kubectl wait --for=delete namespace/"${AWX_NAMESPACE}" --timeout=300s >/tmp/awx-destructive-wait-namespace.log 2>&1 || true
                _step_result_success "Kubernetes destructive cleanup requested for namespace ${AWX_NAMESPACE}"
                removed_any=true
            else
                _step_result_suggestion "Namespace ${AWX_NAMESPACE} not found for destructive Kubernetes cleanup"
            fi
        fi

        if command -v docker >/dev/null 2>&1; then
            awx_volumes="$(docker volume ls --format '{{.Name}}' | grep -E 'awx' || true)"
            while IFS= read -r volume_name; do
                [[ -z "${volume_name}" ]] && continue
                docker volume rm "${volume_name}" >/tmp/awx-destructive-docker-volume.log 2>&1 || true
            done <<< "${awx_volumes}"

            awx_networks="$(docker network ls --format '{{.Name}}' | grep -E 'awx' || true)"
            while IFS= read -r network_name; do
                [[ -z "${network_name}" ]] && continue
                docker network rm "${network_name}" >/tmp/awx-destructive-docker-network.log 2>&1 || true
            done <<< "${awx_networks}"
        fi

        rm -rf /root/.awx || true
        if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
            sudo_user_home="$(getent passwd "${SUDO_USER}" | cut -d: -f6 || true)"
            if [[ -n "${sudo_user_home}" ]]; then
                rm -rf "${sudo_user_home}/.awx" || true
            fi
        fi
        _step_result_success "Legacy local artifacts cleanup requested"
    fi

    if [[ "${removed_any}" != true ]]; then
        _step_result_suggestion "No AWX resources found to uninstall"
    fi
}

usage() {
    cat <<'EOF'
Usage: sudo ./install-ansible-awx.sh [options]

Installs Ansible AWX with Docker on multiple distros (CentOS 7+, RHEL 8+, Ubuntu/Debian 20+).

Options:
  --awx-version <version>      AWX version to install (default: 17.1.0)
  --admin-user <username>      AWX admin username (default: root)
  --admin-password <password>  AWX admin password (default: toor)
  --docker-compose <version>   Docker Compose version (default: 2.13.0)
  --install-method <mode>      Installation mode: auto|legacy|operator (default: auto)
  --operator-version <version> AWX Operator version (default: 2.19.1)
  --namespace <name>           Kubernetes namespace for operator mode (default: awx)
    --awx-name <name>            AWX instance name for operator mode (default: awx)
    --kube-rbac-proxy-image <i>  Override proxy image for operator deployment workaround
    --uninstall                  Uninstall AWX (operator CR and/or legacy docker compose)
    --remove-operator            With --uninstall, also remove AWX Operator manifests
    --destructive-uninstall      With --uninstall, remove namespace/PVC/secrets/PV and local Docker artifacts
  --skip-system-update         Skip package update and upgrade
  --reboot                     Reboot host after installation
  -h, --help                   Show this help message

Examples:
  sudo ./install-ansible-awx.sh --awx-version 21.11.0
  sudo ./install-ansible-awx.sh --awx-version 17.1.0 --admin-user admin --reboot
  sudo ./install-ansible-awx.sh --awx-version 24.6.1 --install-method operator --namespace awx
    sudo ./install-ansible-awx.sh --uninstall --install-method operator --namespace awx --awx-name awx
    sudo ./install-ansible-awx.sh --uninstall --destructive-uninstall --remove-operator --namespace awx --awx-name awx
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --awx-version)
            AWX_VERSION="${2:-}"
            shift 2
            ;;
        --admin-user)
            AWX_ADMIN_USER="${2:-}"
            shift 2
            ;;
        --admin-password)
            AWX_ADMIN_PASSWORD="${2:-}"
            shift 2
            ;;
        --docker-compose)
            DOCKER_COMPOSE_VERSION="${2:-}"
            shift 2
            ;;
        --install-method)
            INSTALL_METHOD="${2:-}"
            shift 2
            ;;
        --operator-version)
            AWX_OPERATOR_VERSION="${2:-}"
            shift 2
            ;;
        --namespace)
            AWX_NAMESPACE="${2:-}"
            shift 2
            ;;
        --awx-name)
            AWX_INSTANCE_NAME="${2:-}"
            shift 2
            ;;
        --kube-rbac-proxy-image)
            KUBE_RBAC_PROXY_IMAGE="${2:-}"
            shift 2
            ;;
        --uninstall)
            UNINSTALL_MODE=true
            shift
            ;;
        --remove-operator)
            REMOVE_OPERATOR_ON_UNINSTALL=true
            shift
            ;;
        --destructive-uninstall)
            DESTRUCTIVE_UNINSTALL=true
            shift
            ;;
        --skip-system-update)
            SKIP_SYSTEM_UPDATE=true
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

_script_start "Ansible AWX Installation (v${AWX_VERSION})"
__verify_root
__detect_package_manager

if [[ "${DESTRUCTIVE_UNINSTALL}" == true && "${UNINSTALL_MODE}" != true ]]; then
    _step_result_failed "--destructive-uninstall requires --uninstall"
    exit 1
fi

if [[ "${UNINSTALL_MODE}" == true ]]; then
    uninstall_awx
    _finish_information
    exit 0
fi

# System update
if [[ "${SKIP_SYSTEM_UPDATE}" != true ]]; then
    __update_system
else
    _step_result_suggestion "Skipping system update/upgrade as requested (--skip-system-update)"
fi

# Install prerequisites
_step "Installing AWX prerequisites"
case "${PACKAGE_MANAGER}" in
    apt)
        apt-get install -y \
            git \
            build-essential \
            nodejs \
            npm \
            python3-pip \
            ansible \
            pwgen \
            wget \
            unzip \
            python3-docker
        update_npm_if_compatible
        ;;
    dnf)
        dnf install -y \
            git \
            gcc \
            gcc-c++ \
            nodejs \
            gettext \
            device-mapper-persistent-data \
            lvm2 \
            bzip2 \
            python3-pip \
            ansible \
            dnf-plugins-core \
            pwgen \
            wget \
            npm \
            unzip \
            python3-docker
        update_npm_if_compatible
        ;;
    yum)
        yum install -y \
            git \
            gcc \
            gcc-c++ \
            nodejs \
            gettext \
            device-mapper-persistent-data \
            lvm2 \
            bzip2 \
            python3-pip \
            ansible \
            pwgen \
            wget \
            npm \
            unzip \
            python3-docker
        update_npm_if_compatible
        ;;
esac
_step_result_success "AWX prerequisites installed"

# Install Docker/Docker Compose only when missing
if is_docker_installed && is_docker_compose_installed; then
    _step "Verifying Docker Engine and Docker Compose"
    _step_result_success "Docker and Docker Compose already installed, skipping installation"
else
    _step "Installing Docker Engine and Docker Compose"
    case "${PACKAGE_MANAGER}" in
        apt)
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 2>/dev/null || true
            add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" || true
            if [[ "${SKIP_SYSTEM_UPDATE}" != true ]]; then
                apt-get update
            else
                _step_result_suggestion "Skipping apt metadata refresh for Docker repo (--skip-system-update)"
            fi

            if ! is_docker_installed; then
                apt-get install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                apt-get install -y docker-compose-plugin
            fi
            ;;
        dnf)
            dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

            if ! is_docker_installed; then
                dnf install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                dnf install -y docker-compose-plugin
            fi
            ;;
        yum)
            yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

            if ! is_docker_installed; then
                yum install -y docker-ce docker-ce-cli containerd.io
            fi
            if ! is_docker_compose_installed; then
                yum install -y docker-compose-plugin
            fi
            ;;
    esac
fi

# Start Docker service
_step "Enabling and starting Docker service"
systemctl enable --now docker
_step_result_success "Docker service started"

# Set Python3 as default (RHEL/CentOS specific)
if [[ "${PACKAGE_MANAGER}" == "dnf" || "${PACKAGE_MANAGER}" == "yum" ]]; then
    _step "Setting Python 3 as default"
    alternatives --install /usr/bin/python python /usr/bin/python3 1 || true
    _step_result_success "Python 3 set as default"
fi

# Install Docker Compose standalone if needed
_step "Verifying Docker Compose installation"
arch="$(uname -m)"
case "${arch}" in
    x86_64)
        compose_arch="x86_64"
        ;;
    aarch64|arm64)
        compose_arch="aarch64"
        ;;
    *)
        compose_arch="x86_64"
        _step_result_suggestion "Unsupported architecture ${arch}, using x86_64 fallback"
        ;;
esac

if ! is_docker_compose_installed; then
    _step "Installing Docker Compose v${DOCKER_COMPOSE_VERSION} standalone"
    curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${compose_arch}" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    _step_result_success "Docker Compose installed"
else
    _step_result_success "Docker Compose already installed"
fi

# Download and prepare AWX
_step "Downloading Ansible AWX v${AWX_VERSION}"
cd /tmp || exit 1
if ! wget -q -O "${AWX_VERSION}.zip" "https://github.com/ansible/awx/archive/${AWX_VERSION}.zip"; then
    _step_result_failed "Failed to download AWX archive for version ${AWX_VERSION}"
    exit 1
fi

AWX_ARCHIVE_ROOT="$(unzip -Z -1 "${AWX_VERSION}.zip" 2>/dev/null | head -n1 | cut -d'/' -f1 || true)"
if [[ -z "${AWX_ARCHIVE_ROOT}" ]]; then
    AWX_ARCHIVE_ROOT="awx-${AWX_VERSION}"
fi

if ! unzip -q -o "${AWX_VERSION}.zip"; then
    _step_result_failed "Failed to extract AWX archive ${AWX_VERSION}.zip"
    exit 1
fi

AWX_INSTALLER_DIR=""
if [[ -d "/tmp/${AWX_ARCHIVE_ROOT}/installer" && -f "/tmp/${AWX_ARCHIVE_ROOT}/installer/install.yml" && -f "/tmp/${AWX_ARCHIVE_ROOT}/installer/inventory" ]]; then
    AWX_INSTALLER_DIR="/tmp/${AWX_ARCHIVE_ROOT}/installer"
else
    AWX_INSTALLER_DIR="$(find "/tmp/${AWX_ARCHIVE_ROOT}" -maxdepth 6 -type f -name install.yml -printf '%h\n' 2>/dev/null | while IFS= read -r candidate; do
        if [[ -f "${candidate}/inventory" ]]; then
            printf '%s\n' "${candidate}"
            break
        fi
    done)"
fi

case "${INSTALL_METHOD}" in
    auto)
        if [[ -n "${AWX_INSTALLER_DIR}" ]]; then
            SELECTED_INSTALL_METHOD="legacy"
        else
            SELECTED_INSTALL_METHOD="operator"
        fi
        ;;
    legacy|operator)
        SELECTED_INSTALL_METHOD="${INSTALL_METHOD}"
        ;;
    *)
        _step_result_failed "Invalid --install-method '${INSTALL_METHOD}'. Use: auto, legacy, or operator."
        exit 1
        ;;
esac

if [[ "${SELECTED_INSTALL_METHOD}" == "legacy" && -z "${AWX_INSTALLER_DIR}" ]]; then
    _step_result_failed "AWX v${AWX_VERSION} does not include the legacy installer layout (install.yml + inventory)."
    _step_result_suggestion "Use --install-method operator for newer AWX versions."
    exit 1
fi

if [[ "${SELECTED_INSTALL_METHOD}" == "legacy" ]]; then
    cd "${AWX_INSTALLER_DIR}" || exit 1
    _step_result_success "AWX source downloaded (legacy installer mode)"

    ensure_ansible_compose_python_module

    # Generate secure secret key if not provided
    if [[ -z "${AWX_SECRET_KEY}" ]]; then
        AWX_SECRET_KEY="$(pwgen -N 1 -s 40)"
    fi

    # Configure inventory
    _step "Configuring AWX inventory"
    sed -i "s|^admin_user=.*|admin_user=${AWX_ADMIN_USER}|g" inventory
    sed -i -E "s|^#([[:space:]]?)admin_password=password|admin_password=${AWX_ADMIN_PASSWORD}|g" inventory
    sed -i "s|^secret_key=.*|secret_key=${AWX_SECRET_KEY}|g" inventory
    _step_result_success "Inventory configured"

    # Run AWX installer
    _step "Running Ansible AWX installation playbook"
    PLAYBOOK_LOG_FILE="/tmp/awx-install-playbook.log"
    if ansible-playbook -i inventory -e "ansible_python_interpreter=${ANSIBLE_PYTHON_INTERPRETER_BIN}" install.yml 2>&1 | tee "${PLAYBOOK_LOG_FILE}"; then
        _step_result_success "AWX playbook executed successfully"
    else
        if is_known_awx_compose_containerconfig_error "${PLAYBOOK_LOG_FILE}"; then
            _step_result_suggestion "Known docker-compose v1 ContainerConfig issue detected during AWX installer"
            _step_result_suggestion "Proceeding with manual container restart via Compose"
        else
            _step_result_failed "AWX playbook execution failed (details: ${PLAYBOOK_LOG_FILE})"
            exit 1
        fi
    fi

    # Restart AWX containers
    _step "Restarting AWX services"
    cd ~/.awx/awxcompose || exit 1
    run_docker_compose down || true
    sleep 5
    run_docker_compose up -d
    _step_result_success "AWX services restarted"
else
    _step_result_success "AWX source downloaded (operator mode)"
    install_awx_with_operator
fi

# Final information
_finish_information

_step "AWX Installation Summary"
echo "  Install Method: ${SELECTED_INSTALL_METHOD}"
echo "  Admin User: ${AWX_ADMIN_USER}"
echo "  Version: ${AWX_VERSION}"
echo "  Docker Compose: ${DOCKER_COMPOSE_VERSION}"
echo ""
if [[ "${SELECTED_INSTALL_METHOD}" == "legacy" ]]; then
    echo "  Access AWX at: http://localhost (or your machine IP)"
else
    echo "  Access AWX via Kubernetes service in namespace: ${AWX_NAMESPACE}"
fi
echo "  Credentials: ${AWX_ADMIN_USER} / ${AWX_ADMIN_PASSWORD}"

if [[ "${REBOOT_AFTER}" == true ]]; then
    _step "Rebooting system"
    reboot
fi
