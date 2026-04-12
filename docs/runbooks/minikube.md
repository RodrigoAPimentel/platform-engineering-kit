# **Minikube**

## **Instalação em centos8**

## **Utilização**

### **_docker driver_**

`minikube start --driver=docker --addons=metrics-server --addons=dashboard --addons=ingress --addons=ingress-dns --force`

### **_Acessar o Minikube com kubeconfig_**

https://faun.pub/accessing-a-remote-minikube-from-a-local-computer-fd6180dd66dd

script para nginx: https://github.com/RodrigoAPimentel/scripts/blob/main/external_access_minikube.sh

### **_Minikube dashboard_**

#### **Acessar de external host:**

1.  _SSH Tunnel:_

    ```
    http://localhost:8081/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
    ```

    - Executar o Comando: `minikube dashboard --url --port 40505` e deixar ele rodando
      ![](minikube_images/image4.png)
    - No Prompt de comando usar: `ssh -L <local host port>:localhost:<minikube dashboad port> <minikube host user>@<minikube host ip>` - Ex.: `ssh -L 8081:localhost:40505 root@192.168.99.11`
    - Criando o SSH Tunnel com MobaXterm:
      ![](minikube_images/image.png)
      ![](minikube_images/image-1.png)

2.  _kubectl proxy:_

    ```
    http://<minikube host ip>:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/
    ```

    - Executar o Comando: `kubectl proxy --address='0.0.0.0' --disable-filter=true` e deixar ele rodando
      ![](minikube_images/image3.png)
      - Para CentOs ou sistemas que seja necessário abrir a porta 8001:
        ```
        sudo firewall-cmd --zone=public --add-port=8001/tcp --permanent
        sudo firewall-cmd --reload
        ```

    - Referência: https://stackoverflow.com/a/54960906
