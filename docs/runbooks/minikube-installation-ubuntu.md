# Minikube Installation (Ubuntu/Debian)

Runbook for installing Minikube with dashboard, ingress, external access, and remote kubeconfig support.

## Related script

- scripts/install/install-minikube-ubuntu.sh

## Prerequisites

- Ubuntu/Debian with working Docker.
- Root access via sudo.
- Target user to operate the cluster.

## Quick usage

```bash
sudo bash scripts/install/install-minikube-ubuntu.sh
```

## Main options

```bash
--user <username>
--addons <csv>
--driver <docker|kvm2|none>
--dashboard-domain <host>
--dashboard-port <port>
--skip-ingress
--skip-iptables
--reboot
```

## Examples

```bash
sudo bash scripts/install/install-minikube-ubuntu.sh --user devops
sudo bash scripts/install/install-minikube-ubuntu.sh --driver docker --addons metrics-server,dashboard,ingress
sudo bash scripts/install/install-minikube-ubuntu.sh --dashboard-domain minikube-gui --dashboard-port 8443
```

## Expected result

- minikube, kubectl, and required utilities installed.
- Cluster started with selected addons.
- NGINX proxy for API server configured.
- External kubeconfig generated for remote access.

## Validation

```bash
minikube status
kubectl get nodes
kubectl get pods -A
```

## Troubleshooting

- Cluster does not start on boot:
  - Check minikube systemd unit and target user permissions.
- Dashboard not externally reachable:
  - Validate iptables, DNS/hosts, and exposed ports.
