# Minikube Operations Guide

Guia operacional complementar para uso, acesso remoto e troubleshooting do Minikube.

## Script relacionado

- scripts/install/install-minikube-ubuntu.sh

## Runbook principal de instalacao

- docs/runbooks/minikube-installation-ubuntu.md

## Pre-requisitos

- Minikube e kubectl instalados.
- Cluster iniciado e funcional.
- Acesso ao host onde o cluster esta executando.

## Operacao basica

### Inicializacao com Docker driver

```bash
minikube start \
  --driver=docker \
  --addons=metrics-server,dashboard,ingress,ingress-dns \
  --force
```

### Validacao de saude do cluster

```bash
minikube status
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

## Acesso remoto ao cluster com kubeconfig

Referencia consultada:

- https://faun.pub/accessing-a-remote-minikube-from-a-local-computer-fd6180dd66dd

### Diretrizes

1. O endpoint do kube-apiserver do Minikube nao e exposto para acesso externo direto por padrao.
2. Para acesso remoto, utilize proxy reverso (NGINX) na frente do API Server.
3. Proteja o proxy com autenticacao basica e TLS.
4. Encaminhe requisicoes para https://<minikube-ip>:8443.
5. Use um kubeconfig dedicado no cliente.

### Fluxo recomendado

1. Subir proxy NGINX no host remoto.
2. Validar endpoint exposto do proxy.
3. Criar kubeconfig dedicado para esse acesso.
4. Ajustar campo server no kubeconfig para o endpoint do proxy.
5. Testar conectividade:

```bash
kubectl --kubeconfig <arquivo> cluster-info
kubectl --kubeconfig <arquivo> get ns
```

### Seguranca

- Nao inclua credenciais em texto puro na URL do server no kubeconfig.
- Prefira TLS ponta a ponta e credenciais fora da URL.
- Restrinja origem por IP no NGINX quando houver exposicao publica.

Script de referencia para proxy:

- https://github.com/RodrigoAPimentel/scripts/blob/main/external_access_minikube.sh

## Acesso ao dashboard em host externo

### Opcao 1: SSH Tunnel

URL de acesso no cliente local:

```text
http://localhost:8081/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

Passos:

1. No host do Minikube, execute:

```bash
minikube dashboard --url --port 40505
```

2. No cliente, crie o tunnel SSH:

```bash
ssh -L <porta-local>:localhost:<porta-dashboard> <usuario>@<ip-host-minikube>
```

Exemplo:

```bash
ssh -L 8081:localhost:40505 root@192.168.99.11
```

Capturas de apoio:

![](minikube_images/image4.png)
![](minikube_images/image.png)
![](minikube_images/image-1.png)

### Opcao 2: kubectl proxy

URL de acesso:

```text
http://<minikube-host-ip>:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/
```

Comando:

```bash
kubectl proxy --address='0.0.0.0' --disable-filter=true
```

Captura de apoio:

![](minikube_images/image3.png)

Se necessario, libere porta 8001 no firewalld:

```bash
sudo firewall-cmd --zone=public --add-port=8001/tcp --permanent
sudo firewall-cmd --reload
```

Referencia:

- https://stackoverflow.com/a/54960906

## Troubleshooting rapido

- Dashboard nao abre externamente:
  - Validar tunnel/proxy e firewall.
- kubectl sem acesso ao cluster:
  - Validar contexto atual e variavel KUBECONFIG.
- Erro ao iniciar minikube:
  - Validar driver Docker e permissao de usuario no grupo docker.
