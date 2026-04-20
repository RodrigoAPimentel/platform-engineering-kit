# DevOps Tools Stack Resources

Static resources consumed by `scripts/install/standalone/install-devops-tools-stack-standalone.sh`.

## Contents

- `jenkins/` -> Jenkins image and compose assets:
  - `Dockerfile`, `.env`, `config/` (configuration files like `casc.yaml`, `seedjob.groovy`).
- `keycloak/` -> Keycloak standalone compose definition:
  - `docker-compose.yml`, `config/` (Keycloak configuration files).
- `portainer/` -> Portainer standalone compose definition.
- `nginx/` -> NGINX proxy compose definition:
  - `templates/` (e.g., `nginx.conf.template`), `config/sites-enabled/` (virtual hosts), `config/error_pages/` (error pages).

## Purpose

Version templates and compose assets close to the installer that orchestrates these standalone tools.
