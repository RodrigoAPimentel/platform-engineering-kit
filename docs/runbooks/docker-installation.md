# Docker Installation

Runbook for installing Docker Engine and Docker Compose on apt, dnf, and yum distributions.

## Related script

- scripts/install/install-docker.sh

## Prerequisites

- Root access via sudo.
- Existing target user on the system.

## Quick usage

```bash
sudo bash scripts/install/install-docker.sh
```

## Main options

```bash
--user <username>
--skip-system-update
--compose-fallback <version>
--reboot
```

## Examples

```bash
sudo bash scripts/install/install-docker.sh --user devops
sudo bash scripts/install/install-docker.sh --compose-fallback v2.29.7
sudo bash scripts/install/install-docker.sh --reboot
```

## Expected result

- Docker installed and service enabled.
- Target user added to the docker group.
- Docker Compose plugin active or standalone fallback installed.

## Validation

```bash
docker --version
docker compose version || docker-compose --version
id "$USER" | grep docker
```

## Troubleshooting

- Compose plugin not available:
  - The script installs standalone fallback automatically.
- Permission denied when using docker without sudo:
  - Re-login to the target user session.
