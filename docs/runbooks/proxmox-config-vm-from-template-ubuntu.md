# Proxmox Post-Clone Configuration (Ubuntu)

Runbook para configurar hostname, rede estática e layout de teclado em VMs clonadas de template.

## Script relacionado

- scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh

## Pré-requisitos

- Ubuntu clonado de template Proxmox.
- Acesso root via sudo.
- Valores de hostname, IP CIDR e gateway definidos.

## Uso rápido

```bash
sudo bash scripts/maintenance/proxmox-config-vm-from-template-ubuntu.sh \
  --hostname app-01 \
  --ip-cidr 192.168.10.50/24 \
  --gateway 192.168.10.1
```

## Opções principais

```bash
--hostname <nome>
--ip-cidr <ip/mask>
--gateway <ip>
--iface <nome>
--dns <csv>
--keyboard <layout>
--reboot
```

## Exemplos

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

## Resultado esperado

- openssh-server instalado.
- hostname aplicado via hostnamectl.
- netplan configurado com IP estático.
- layout de teclado ajustado.

## Validação

```bash
hostnamectl
ip -4 addr show <iface>
ip route
```

## Troubleshooting

- Sem rede após aplicar netplan:
  - Revise interface e CIDR informados.
- Gateway inválido:
  - Ajuste rota padrão e reaplique netplan.
