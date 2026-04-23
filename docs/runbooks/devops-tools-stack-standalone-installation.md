# DevOps Tools Stack Standalone Installation

⚠️ **Warning:** This procedure requires root privileges (`sudo`) and may handle secrets/passwords. Review commands before execution and avoid exposing credentials in command line, shell history, or logs. See [security/secrets/README.md](../../security/secrets/README.md) for best practices.

Runbook for provisioning a standalone DevOps tools stack based on Docker resources.

## Related script

- scripts/install/standalone/install-devops-tools-stack-standalone.sh

## Related resources

- scripts/install/resources/standalone/devops-tools-stack/

## Scope

This installer targets a standalone stack composed of:

- Jenkins
- Keycloak
- Portainer
- NGINX

## Current implementation status

At the time of writing, the installer script appears incomplete and may not be executable end-to-end in its current form.

Use this runbook to:

1. Verify script readiness before production use.
2. Validate resource directories and expected service assets.
3. Apply an incremental fallback rollout using existing Docker application assets when needed.

## Prerequisites

- Root access via sudo.
- Docker and Docker Compose installed and working.
- Required ports available on target host.
- Internet connectivity to pull container images.

## Preflight validation

Run these checks from repository root:

```bash
bash -n scripts/install/standalone/install-devops-tools-stack-standalone.sh
ls -la scripts/install/resources/standalone/devops-tools-stack
```

Expected result:

- Shell syntax check passes.
- Resource folder includes service directories for Jenkins, Keycloak, Portainer, and NGINX.

## Script execution (when script is complete)

```bash
sudo bash scripts/install/standalone/install-devops-tools-stack-standalone.sh
```

If the script does not execute successfully, use fallback deployment by service and open a fix task for the standalone installer.

## Fallback deployment (service-by-service)

When the standalone orchestrator is not ready, deploy services independently using the Docker applications under tools:

- tools/docker/applications/jenkins/
- tools/docker/applications/nginx/
- tools/docker/applications/portainer/

Example validation for one service:

```bash
docker compose --file tools/docker/applications/nginx/docker-compose.yml config
```

## Post-install validation

- Validate container status:

```bash
docker ps
```

- Validate compose configuration for each deployed service:

```bash
docker compose --file tools/docker/applications/jenkins/docker-compose.yml config
docker compose --file tools/docker/applications/nginx/docker-compose.yml config
docker compose --file tools/docker/applications/portainer/docker-compose.yml config
```

## Troubleshooting

- Syntax check fails for standalone installer:
  - Treat as a blocker and fix script completeness before production rollout.
- Missing resource directory or files:
  - Verify repository sync and review scripts/install/resources/standalone/devops-tools-stack/.
- Container startup failures:
  - Review `docker logs <container>` and verify host ports/volumes.

## Governance notes

- Keep this runbook synchronized with script behavior.
- Any standalone installer update must also update:
  - scripts/install/standalone/README.md
  - scripts/install/resources/README.md
  - docs/runbooks/README.md
