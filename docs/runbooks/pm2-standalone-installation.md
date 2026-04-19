# PM2 Standalone Installation

⚠️ **Warning:** This procedure requires root privileges (`sudo`) and may handle secrets/passwords. Review commands before execution and avoid exposing credentials in command line, shell history, or logs. See [security/secrets/README.md](../security/secrets/README.md) for best practices.

Runbook for installing PM2 as a standalone process manager for a target user.

## Related script

- scripts/install/standalone/install-pm2-standalone.sh

## Prerequisites

- Root access via sudo.
- Existing target user.
- npm available for the target user (or allow Node.js helper auto-install).

## Quick usage

```bash
sudo bash scripts/install/standalone/install-pm2-standalone.sh
```

## Main options

```bash
--user <username>
--skip-system-update
--skip-nodejs-install
--reboot
```

## Examples

```bash
sudo bash scripts/install/standalone/install-pm2-standalone.sh --user automation
sudo bash scripts/install/standalone/install-pm2-standalone.sh --skip-nodejs-install
```

## Expected result

- PM2 installed globally for target user.
- PM2 systemd startup configured.
- PM2 snapshot saved with pm2 save.

## Validation

```bash
sudo -u <username> pm2 --version
sudo -u <username> pm2 list
systemctl status pm2-<username> --no-pager || true
```

## Troubleshooting

- npm missing:
  - Run without --skip-nodejs-install to auto-install Node.js helper.
- PM2 does not start at boot:
  - Re-run startup configuration and validate systemd unit.
