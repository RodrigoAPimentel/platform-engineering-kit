# 🐳 Docker

Containerization setup.

## Purpose

Standardize container usage with secure and reusable patterns.

## Contents

- `jenkins/` -> legacy Jenkins Docker assets.
- `keycloak/` -> legacy Keycloak Docker assets.
- `nginx/` -> legacy NGINX Docker assets.
- `portainer/` -> legacy Portainer Docker assets.
- `jenkins_v2/` -> modernized Jenkins Docker assets.
- `keycloak_v2/` -> modernized Keycloak Docker assets.
- `nginx_v2/` -> modernized NGINX Docker assets.
- `portainer_v2/` -> modernized Portainer Docker assets.
- `templates/` -> reusable Docker templates for new implementations.

## Template Usage

Use `templates/Dockerfile.template` as the default baseline for new services.
Use `templates/docker-compose.template.yml` as the default baseline for new stacks.
Use `templates/.env.template` as the unified environment baseline with inline profile blocks.

Recommended workflow:

1. Copy the template into a service folder as `Dockerfile`.
2. Copy `templates/docker-compose.template.yml` as `docker-compose.yml`.
3. Copy `templates/.env.template` to `.env`.
4. Replace image/build, labels, ports, healthcheck endpoint, and startup command.
5. Add a local `.dockerignore` in the same build context.
6. Validate with `docker compose config`, Docker build, and lint in CI.

Unified template model:

- `templates/Dockerfile.template` -> single Dockerfile baseline with inline development/production build profile guidance.
- `templates/docker-compose.template.yml` -> single compose baseline with inline development/production runtime guidance.
- `templates/.env.template` -> single env baseline using service block sections and inline development/production override examples.

## Standards

- Use non-root runtime users whenever possible.
- Keep images minimal and pin versions.
- Prefer explicit `COPY` and small build contexts.
- Add `HEALTHCHECK` for service readiness.
- Keep metadata labels for traceability.
- Prefer `env_file` + variable interpolation over hardcoded values.
- Use healthchecks and dedicated networks in compose stacks.
- Keep separate runtime profiles for development and production.
- Prefer single-source templates with inline profile documentation to reduce drift.

## References

- Docker build best practices:
  - https://docs.docker.com/build/building/best-practices/
- Dockerfile reference:
  - https://docs.docker.com/reference/dockerfile/
- Dockerignore reference:
  - https://docs.docker.com/build/concepts/context/#dockerignore-files
- Compose file reference:
  - https://docs.docker.com/reference/compose-file/
- Compose variable interpolation:
  - https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/
- Hadolint:
  - https://github.com/hadolint/hadolint
