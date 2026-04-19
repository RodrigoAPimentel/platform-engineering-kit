# Minikube Operations Guide

Complementary operations guide for Minikube usage, remote access, and troubleshooting.

## Related script

- scripts/install/install-minikube-ubuntu.sh

## Main installation runbook

- docs/runbooks/minikube-installation-ubuntu.md

## Prerequisites

- Minikube and kubectl installed.
- Cluster started and healthy.
- Access to the host where the cluster is running.

## Basic operation

### Start with Docker driver

```bash
minikube start \
  --driver=docker \
  --addons=metrics-server,dashboard,ingress,ingress-dns \
  --force
```

### Cluster health validation

```bash
minikube status
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

## Remote cluster access with kubeconfig

Reference:

- https://faun.pub/accessing-a-remote-minikube-from-a-local-computer-fd6180dd66dd

### Guidelines

1. The Minikube kube-apiserver endpoint is not directly exposed externally by default.
2. For remote access, use a reverse proxy (NGINX) in front of API Server.
3. Protect the proxy with basic authentication and TLS.
4. Forward requests to https://\<minikube-ip\>:8443.
5. Use a dedicated kubeconfig on the client.

### Recommended flow

1. Start an NGINX proxy on the remote host.
2. Validate the exposed proxy endpoint.
3. Create a dedicated kubeconfig for that access.
4. Adjust server field in kubeconfig to point to proxy endpoint.
5. Test connectivity:

```bash
kubectl --kubeconfig <file> cluster-info
kubectl --kubeconfig <file> get ns
```

### Security

- Do not include plaintext credentials in kubeconfig server URL.
- Prefer end-to-end TLS and credentials outside URL.
- Restrict origin by IP on NGINX when publicly exposed.

Proxy reference script:

- https://github.com/RodrigoAPimentel/scripts/blob/main/external_access_minikube.sh

## Dashboard access from external host

### Option 1: SSH Tunnel

Local client access URL:

```text
http://localhost:8081/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

Steps:

1. On Minikube host, run:

```bash
minikube dashboard --url --port 40505
```

2. On client, create SSH tunnel:

```bash
ssh -L <local-port>:localhost:<dashboard-port> <user>@<minikube-host-ip>
```

Example:

```bash
ssh -L 8081:localhost:40505 root@192.168.99.11
```

Supporting screenshots:

![](minikube_images/image4.png)
![](minikube_images/image.png)
![](minikube_images/image-1.png)

### Option 2: kubectl proxy

Access URL:

```text
http://\<minikube-host-ip\>:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/
```

Command:

```bash
kubectl proxy --address='0.0.0.0' --disable-filter=true
```

Supporting screenshot:

![](minikube_images/image3.png)

If needed, open port 8001 in firewalld:

```bash
sudo firewall-cmd --zone=public --add-port=8001/tcp --permanent
sudo firewall-cmd --reload
```

Reference:

- https://stackoverflow.com/a/54960906

## Quick troubleshooting

- Dashboard not reachable externally:
  - Validate tunnel/proxy and firewall.
- kubectl cannot access cluster:
  - Validate current context and KUBECONFIG variable.
- Minikube startup errors:
  - Validate Docker driver and user permissions in docker group.
