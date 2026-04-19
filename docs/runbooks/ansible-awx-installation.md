# Ansible AWX Installation & Operation

Official runbook to install, operate, and uninstall AWX using the consolidated repository script.

## Related script

- scripts/install/install-ansible-awx.sh

## Supported installation modes

- auto: chooses legacy or operator based on the downloaded AWX version layout.
- legacy: installer + Docker Compose flow.
- operator: Kubernetes flow with AWX Operator.

## Prerequisites

- Root access via sudo.
- Internet connectivity to download AWX and dependencies.
- For operator mode: kubectl configured and reachable Kubernetes cluster.

## Quick usage

```bash
sudo bash scripts/install/install-ansible-awx.sh
```

## Main options

```bash
--awx-version <version>
--admin-user <username>
--admin-password <password>
--docker-compose <version>
--install-method <auto|legacy|operator>
--operator-version <version>
--namespace <name>
--awx-name <name>
--kube-rbac-proxy-image <image>
--skip-system-update
--reboot
```

## Installation examples

### Auto (recommended)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 24.6.1 \
  --admin-user admin
```

### Legacy (Docker Compose)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 17.1.0 \
  --install-method legacy
```

### Operator (Kubernetes)

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 24.6.1 \
  --install-method operator \
  --namespace awx \
  --awx-name awx
```

## Expected result

### Legacy

- AWX stack created with Docker Compose.
- Credentials applied to inventory during installation.
- Service reachable from local/network host.

### Operator

- Kubernetes namespace created (if missing).
- AWX Operator applied and deployment ready.
- AWX Custom Resource applied with admin_user/admin_password_secret.

## Validation

### Legacy

```bash
docker ps | grep -i awx || true
cd ~/.awx/awxcompose && (docker compose ps || docker-compose ps)
```

### Operator

```bash
kubectl -n awx get pods
kubectl -n awx get awx
kubectl -n awx get svc
```

## Uninstallation

The script supports uninstallation of operator and legacy resources.

### Standard uninstall

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --namespace awx \
  --awx-name awx
```

### Remove operator too

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --remove-operator \
  --namespace awx \
  --awx-name awx
```

### Destructive mode

```bash
sudo bash scripts/install/install-ansible-awx.sh \
  --uninstall \
  --destructive-uninstall \
  --remove-operator \
  --namespace awx \
  --awx-name awx
```

Warning: destructive mode removes namespace/PVC/secrets/PV and legacy local artifacts.

## Troubleshooting

- kubectl cannot access cluster in operator mode:
  - Check context with kubectl config current-context.
  - Validate cluster access with kubectl cluster-info.
- Minikube is not running:
  - Start it with minikube start before operator mode.
- docker-compose error in legacy mode:
  - The script handles compose plugin/standalone fallback and known ContainerConfig recovery.
- Permissions after Docker installation:
  - Re-login the session to apply docker group membership.

## Useful commands

```bash
# Admin password (operator)
kubectl -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 -d && echo

# Operator status
kubectl -n awx get deployment awx-operator-controller-manager

# Operator logs
kubectl -n awx logs deployment/awx-operator-controller-manager
```

## References

- Script: scripts/install/install-ansible-awx.sh
- Related runbooks:
  - docs/runbooks/docker-installation.md
  - docs/runbooks/minikube-installation-ubuntu.md
