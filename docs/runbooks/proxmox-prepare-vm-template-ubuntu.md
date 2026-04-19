# Proxmox Template Preparation (Ubuntu)

Runbook for preparing an Ubuntu VM before converting it to a Proxmox template.

## Related script

- scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh

## Prerequisites

- Ubuntu VM running on Proxmox.
- Root access via sudo.

## Quick usage

```bash
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh
```

## Main options

```bash
--skip-openssh-helper
--no-shutdown
```

## Examples

```bash
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh --no-shutdown
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh --skip-openssh-helper
```

## Expected result

- cloud-init, qemu-guest-agent, and openssh-server installed.
- machine-id and SSH host keys reset.
- cloud-init cache and state cleaned.
- automatic shutdown at the end unless disabled.

## Validation

```bash
systemctl is-enabled qemu-guest-agent
ls -la /etc/ssh/ssh_host_* || true
```

## Troubleshooting

- Template conversion fails:
  - Confirm Cloud-Init disk was added in Proxmox UI.
- Clone with duplicate identity:
  - Revalidate machine-id cleanup before conversion.
