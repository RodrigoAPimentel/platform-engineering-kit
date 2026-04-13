#!/usr/bin/env bash

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/basic-packages.sh"

OS=""
VERSION=""
PACKAGE_MANAGER=""

__verify_root_pass() {
    if [[ -n "${1:-}" ]]; then
        _step_result_suggestion "Legacy sudo password argument detected and ignored. Run script with sudo/root instead."
    fi
}

__verify_root() {
    _step "Checking if script runs as root"
    if [[ "${EUID}" -ne 0 ]]; then
        _step_result_failed "This script must be run as root. Example: sudo ./initial-preparation.sh"
        exit 1
    fi
    _step_result_success "Root execution confirmed"
}

__detect_system() {
    _step "Detecting operating system"
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        OS="${ID:-unknown}"
        VERSION="${VERSION_ID:-unknown}"
    else
        _step_result_failed "Unable to identify operating system"
        exit 1
    fi

    export OS VERSION
    _step_result_success "Detected: ${OS} ${VERSION}"
}

__detect_package_manager() {
    __detect_system
    _step "Detecting package manager"

    if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
    elif command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
    else
        _step_result_failed "No supported package manager found (apt, dnf, yum)"
        exit 1
    fi

    export PACKAGE_MANAGER
    _step_result_success "Package manager: ${PACKAGE_MANAGER}"
}

__update_system() {
    _step "Updating package metadata and upgrading system"

    case "${PACKAGE_MANAGER}" in
        apt)
            apt-get update -y
            apt-get upgrade -y
            apt-get dist-upgrade -y
            ;;
        dnf)
            dnf makecache -y
            dnf upgrade -y
            ;;
        yum)
            yum makecache -y
            yum update -y
            ;;
        *)
            _step_result_failed "Unsupported package manager: ${PACKAGE_MANAGER}"
            exit 1
            ;;
    esac

    _step_result_success "System update finished"
}

__package_installed() {
    local package="$1"

    if command -v dpkg-query >/dev/null 2>&1; then
        dpkg-query -W -f='${Status}' "${package}" 2>/dev/null | grep -q "ok installed"
        return
    fi

    if command -v rpm >/dev/null 2>&1; then
        rpm -q "${package}" >/dev/null 2>&1
        return
    fi

    return 1
}

__install_prerequisite_packages() {
    local packages="${1:-${BASIC_PACKAGES[*]}}"
    local package
    local failed_packages=()

    _step "Installing prerequisite packages: ${packages}"
    for package in ${packages}; do
        case "${PACKAGE_MANAGER}" in
            apt)
                apt-get install -y "${package}" || failed_packages+=("${package}")
                ;;
            dnf)
                dnf install -y "${package}" || failed_packages+=("${package}")
                ;;
            yum)
                yum install -y "${package}" || failed_packages+=("${package}")
                ;;
        esac
    done

    _step "Verifying installed packages"
    for package in ${packages}; do
        if __package_installed "${package}"; then
            _step_result_success "${package} is installed"
        else
            _step_result_suggestion "${package} was not verified (can be package alias by distro)"
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        _step_result_suggestion "Some packages failed during installation: ${failed_packages[*]}"
    fi
}

__verify_packages_installed() {
    local binary="$1"

    _step "Verifying binary installation: ${binary}"
    if command -v "${binary}" >/dev/null 2>&1; then
        _step_result_success "${binary} is installed"
    else
        _step_result_failed "${binary} is not installed"
        exit 1
    fi
}