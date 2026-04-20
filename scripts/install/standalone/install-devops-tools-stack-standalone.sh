RESOURCE_DIR="${SCRIPT_DIR}/../../tools/docker"

copy_service_assets() {
    local service="$1"
    install -d -m 0755 "${TARGET_ROOT}/${service}"
    cp -a "${RESOURCE_DIR}/${service}/." "${TARGET_ROOT}/${service}/"

    if [[ "${service}" == "nginx" ]]; then
        AWX_HOST="${AWX_HOST}" envsubst '${AWX_HOST}' < "${TARGET_ROOT}/nginx/templates/nginx.conf.template" > "${TARGET_ROOT}/nginx/config/nginx.conf"
    fi
}