# Proxmox Template Preparation (Ubuntu)

Runbook para preparar uma VM Ubuntu antes da conversão para template no Proxmox.

## Script relacionado

- scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh

## Pré-requisitos

- Ubuntu em VM no Proxmox.
- Acesso root via sudo.

## Uso rápido

```bash
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh
```

## Opções principais

```bash
--skip-openssh-helper
--no-shutdown
```

## Exemplos

```bash
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh --no-shutdown
sudo bash scripts/maintenance/proxmox-prepare-vm-template-ubuntu.sh --skip-openssh-helper
```

## Resultado esperado

- cloud-init, qemu-guest-agent e openssh-server instalados.
- machine-id e chaves de host SSH resetados.
- cache e estado do cloud-init limpos.
- shutdown automático no final, salvo opção contrária.

## Validação

```bash
systemctl is-enabled qemu-guest-agent
ls -la /etc/ssh/ssh_host_* || true
```

## Troubleshooting

- Conversão para template falha:
  - Confirme adição de disco Cloud-Init no Proxmox UI.
- Clone com identidade duplicada:
  - Revalide limpeza do machine-id antes da conversão.
