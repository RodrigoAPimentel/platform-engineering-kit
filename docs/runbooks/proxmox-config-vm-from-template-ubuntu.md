# Proxmox Post-Clone Configuration (Ubuntu)

Runbook to configure hostname, static networking, and keyboard layout on template-cloned VMs.

## Related script

- scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh

## Prerequisites

- Ubuntu VM cloned from Proxmox template.
- Root access via sudo.
- Defined hostname, IP CIDR, and gateway values.

## Quick usage

```bash
sudo bash scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh \
  --hostname app-01 \
  --ip-cidr 192.168.10.50/24 \
  --gateway 192.168.10.1
```

## Main options

```bash
--hostname <name>
--ip-cidr <ip/mask>
--gateway <ip>
--iface <name>
--dns <csv>
--keyboard <layout>
--reboot
```

## Examples

```bash
sudo bash scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh \
  --hostname db-01 \
  --ip-cidr 10.10.20.30/24 \
  --gateway 10.10.20.1 \
  --iface ens18 \
  --dns 1.1.1.1,8.8.8.8 \
  --keyboard br \
  --reboot
```

## Expected result

- openssh-server installed.
- hostname applied via hostnamectl.
- netplan configured with static IP.
- keyboard layout updated.

## Validation

```bash
hostnamectl
ip -4 addr show <iface>
ip route
```

## Troubleshooting

- No network after netplan apply:
  - Review provided interface and CIDR values.
- Invalid gateway:
  - Adjust default route and reapply netplan.
