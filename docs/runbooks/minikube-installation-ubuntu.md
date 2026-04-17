# Minikube Installation (Ubuntu/Debian)

Runbook para instalação de Minikube com dashboard, ingress, acesso externo e kubeconfig remoto.

## Script relacionado

- scripts/install/install-minikube-ubuntu.sh

## Pré-requisitos

- Ubuntu/Debian com Docker funcional.
- Acesso root via sudo.
- Usuário alvo para operar o cluster.

## Uso rápido

```bash
sudo bash scripts/install/install-minikube-ubuntu.sh
```

## Opções principais

```bash
--user <usuario>
--addons <csv>
--driver <docker|kvm2|none>
--dashboard-domain <host>
--dashboard-port <porta>
--skip-ingress
--skip-iptables
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/install-minikube-ubuntu.sh --user devops
sudo bash scripts/install/install-minikube-ubuntu.sh --driver docker --addons metrics-server,dashboard,ingress
sudo bash scripts/install/install-minikube-ubuntu.sh --dashboard-domain minikube-gui --dashboard-port 8443
```

## Resultado esperado

- minikube, kubectl e utilitários instalados.
- Cluster iniciado com addons definidos.
- Proxy NGINX para API server configurado.
- kubeconfig externo gerado para acesso remoto.

## Validação

```bash
minikube status
kubectl get nodes
kubectl get pods -A
```

## Troubleshooting

- Cluster não sobe no boot:
  - Verifique unit systemd do minikube e permissões do usuário alvo.
- Dashboard inacessível externamente:
  - Valide iptables, DNS/hosts e portas liberadas.
