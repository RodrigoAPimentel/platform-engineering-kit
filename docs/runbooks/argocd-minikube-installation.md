# Argo CD on Minikube

Runbook for installing Argo CD on an existing Minikube cluster.

## Related script

- scripts/install/install-argocd-minikube.sh

## Prerequisites

- Minikube running.
- kubectl working with a valid context.
- Root permission via sudo.

## Quick usage

```bash
sudo bash scripts/install/install-argocd-minikube.sh
```

## Main options

```bash
--version <tag|stable>
--dashboard-domain <host>
--dashboard-port <port>
--skip-iptables
```

## Examples

```bash
sudo bash scripts/install/install-argocd-minikube.sh --version stable
sudo bash scripts/install/install-argocd-minikube.sh --dashboard-domain argocd.local --dashboard-port 8088
sudo bash scripts/install/install-argocd-minikube.sh --skip-iptables
```

## Expected result

- argocd namespace created.
- Official manifests applied.
- argocd CLI installed at /usr/local/bin/argocd.
- Ingress configured with the chosen domain.
- iptables rules applied unless disabled.

## Validation

```bash
kubectl -n argocd get pods
kubectl -n argocd get ingress
argocd version --client
```

## Troubleshooting

- Minikube unavailable:
  - Start the cluster before installation.
- No dashboard access:
  - Check /etc/hosts, external port, and NAT/FORWARD rules.
