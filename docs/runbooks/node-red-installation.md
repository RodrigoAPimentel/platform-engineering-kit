# Node-RED Installation

Runbook for installing Node-RED with PM2 on apt-based systems.

## Related script

- scripts/install/install-node-red.sh

## Prerequisites

- Ubuntu/Debian.
- Root access via sudo.
- Existing target user.

## Quick usage

```bash
sudo bash scripts/install/install-node-red.sh
```

## Main options

```bash
--user <username>
--skip-system-update
--reboot
```

## Examples

```bash
sudo bash scripts/install/install-node-red.sh --user automation
sudo bash scripts/install/install-node-red.sh --skip-system-update
```

## Expected result

- Node.js, npm, PM2, and Node-RED installed.
- node-red process managed by PM2.
- PM2 startup configured for automatic restart.

## Validation

```bash
sudo -u <username> pm2 list
curl -I http://127.0.0.1:1880
```

## Troubleshooting

- Port 1880 unavailable:
  - Check local firewall and service bind settings.
- PM2 does not start after reboot:
  - Re-run PM2 startup configuration for the target user.
