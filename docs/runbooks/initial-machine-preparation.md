# Initial Machine Preparation

Runbook for initial Linux host preparation with apt, dnf, and yum support.

## Related script

- scripts/install/initial-machine-preparation.sh

## Prerequisites

- Root access via sudo.
- Host with network connectivity to repositories.

## Quick usage

```bash
sudo bash scripts/install/initial-machine-preparation.sh
```

## Main options

```bash
--skip-system-update
--skip-openssh
--skip-firewall
--locale <value>
--reboot
```

## Examples

```bash
sudo bash scripts/install/initial-machine-preparation.sh --locale pt_BR.UTF-8
sudo bash scripts/install/initial-machine-preparation.sh --skip-firewall
sudo bash scripts/install/initial-machine-preparation.sh --reboot
```

## Expected result

- Session locale configured.
- System packages updated (unless skipped).
- OpenSSH installed and enabled (unless skipped).
- SSH firewall rules configured when firewalld is active.

## Validation

```bash
systemctl is-active ssh || systemctl is-active sshd
locale
```

## Troubleshooting

- EPEL unavailable for a specific distro:
  - The script continues with a warning; validate local repositories.
- firewalld inactive:
  - The script skips firewall configuration and logs a suggestion.
