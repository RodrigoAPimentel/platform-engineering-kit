# OpenSSH Server Installation (Ubuntu/Debian)

Runbook for installing and enabling OpenSSH Server on apt-based systems.

## Related script

- scripts/install/install-openssh-server-ubuntu.sh

## Prerequisites

- Ubuntu/Debian.
- Root access via sudo.

## Quick usage

```bash
sudo bash scripts/install/install-openssh-server-ubuntu.sh
```

## Main options

```bash
--skip-system-update
--disable-service
--reboot
```

## Examples

```bash
sudo bash scripts/install/install-openssh-server-ubuntu.sh --skip-system-update
sudo bash scripts/install/install-openssh-server-ubuntu.sh --disable-service
```

## Expected result

- openssh-server package installed.
- ssh service active, except when disabled by option.

## Validation

```bash
systemctl status ssh --no-pager
ss -tulpen | grep ':22'
```

## Troubleshooting

- Service does not start:
  - Check port conflicts and sshd configuration file.
- Remote access fails:
  - Confirm firewall rules and network routing.
