# Argo CD on Minikube

Runbook para instalação do Argo CD em cluster Minikube já existente.

## Script relacionado

- scripts/install/install-argocd-minikube.sh

## Pré-requisitos

- Minikube em execução.
- kubectl funcional com contexto válido.
- Permissão root via sudo.

## Uso rápido

```bash
sudo bash scripts/install/install-argocd-minikube.sh
```

## Opções principais

```bash
--version <tag|stable>
--dashboard-domain <host>
--dashboard-port <porta>
--skip-iptables
```

## Exemplos

```bash
sudo bash scripts/install/install-argocd-minikube.sh --version stable
sudo bash scripts/install/install-argocd-minikube.sh --dashboard-domain argocd.local --dashboard-port 8088
sudo bash scripts/install/install-argocd-minikube.sh --skip-iptables
```

## Resultado esperado

- Namespace argocd criado.
- Manifestos oficiais aplicados.
- CLI argocd instalada em /usr/local/bin/argocd.
- Ingress configurado com domínio definido.
- Regras iptables aplicadas, exceto quando desabilitado.

## Validação

```bash
kubectl -n argocd get pods
kubectl -n argocd get ingress
argocd version --client
```

## Troubleshooting

- Minikube indisponível:
  - Inicie o cluster antes da instalação.
- Sem acesso ao dashboard:
  - Verifique /etc/hosts, porta externa e regras NAT/FORWARD.
