# 我如何公开在 Amazon EKS 集群上运行的 Kubernetes 服务？
## 简短描述
以下解决方案向您显示如何创建示例应用程序，然后将以下 Kubernetes [ServiceTypes](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) 应用至您的示例应用程序：ClusterIP、NodePort 和 LoadBalancer。

请记住以下内容：
- ClusterIP 在集群内部 IP 地址上公开服务。
- NodePort 在每个节点的 IP 地址静态端口上公开服务。
- LoadBalancer 使用负载均衡器在外部公开服务。

注意：Amazon EKS 通过 LoadBalancer 为运行在 Amazon Elastic Compute Cloud (Amazon EC2) 实例工作线程节点上的 pod 提供网络负载均衡器和 传统负载均衡器支持。Amazon EKS 不为 AWS Fargate 上运行的 pod 提供网络负载均衡器和 Classic Load Balancer 支持。对于 Fargate 入口，最佳做法是在 [Amazon EKS 上使用用于 Kubernetes 的 AWS Application Load Balancer (ALB) 入口控制器（最低版本 1.1.4）](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)。
## 解决方法
### 创建示例应用程序：
1. 要创建示例 NGINX 部署，请运行以下命令：
   `kubectl run nginx  --replicas=2 --labels='app=nginx' --image=nginx --port=80`
2. 要验证您的 pod 正在运行且拥有自己的内部 IP 地址，请运行以下命令：
   `kubectl get pods -l 'app=nginx' -o wide | awk {'print $1" " $3 " " $6'} | column -t`
   
   输出与以下类似：
   ```
   NAME                   STATUS   IP
   nginx-ab1cdef23-45ghi  Running  10.1.3.202
   nginx-ab1cdef23-45ghi  Running  10.1.3.150
   ```
### 创建 ClusterIP 服务
1. 创建名为 clusterip.yaml 的文件，然后将类型设置为 ClusterIP。请参阅以下示例：
   ```
    cat <<EOF > clusterip.yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: nginx-service
    spec:
    type: ClusterIP
    selector:
        app: nginx
    ports:
        - protocol: TCP
        port: 80
        targetPort: 80
    EOF
   ```
2. 使用声明式或命令式命令在 Kubernetes 中创建 ClusterIP 对象。
   要创建对象并应用 clusterip.yaml 文件，请运行以下声明式命令：`kubectl create -f clusterip.yaml`

   您将收到以下输出：
   `service/nginx-service created`

   **或者**

   要公开 ClusterIP 类型的部署，请运行以下命令式命令：
   `kubectl expose deployment nginx  --type=ClusterIP  --name=nginx-service`

   您将收到以下输出：
   `service "nginx-service" exposed`

   > **注意**：exposed 命令将创建一项服务，而不是创建 YAML 文件。然而，kubectl 会将您的命令式命令转换为声明式 Kubernetes 部署对象。
3. 要访问应用程序并获取 ClusterIP 编号，请运行以下命令：
   `kubectl get service nginx-service`

   您将收到以下输出：
   ```
   NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   nginx-service   ClusterIP   172.20.65.130   <none>        80/TCP    15s
   ```
### 创建 NodePort 服务
1. 要创建 NodePort 服务，请创建一个名为 nodeport.yaml 的文件，然后将类型设置为 NodePort。请参阅以下示例：
   ```
    cat <<EOF > nodeport.yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: nginx-service
    spec:
    type: NodePort
    selector:
        app: nginx
    ports:
        - protocol: TCP
        port: 80
        targetPort: 80
    EOF
   ```
2. 要删除 ClusterIP 服务并使用相同服务名称 (nginx-service) 创建一个 NodePort 服务，请运行以下命令：
    `kubectl delete service nginx-service`

    您将收到以下输出：`service "nginx-service" deleted`
3. 使用声明式或命令式命令在 Kubernetes 中创建 NodePort 对象。
   `kubectl create -f nodeport.yaml`

   **或者**

   要公开 NodePort 类型的部署，请运行以下命令式命令：
   `kubectl expose deployment nginx  --type=NodePort  --name=nginx-serviceservice "nginx-service" exposed`
   
   您将收到以下输出：`service/nginx-service created`
4. 要获取有关 nginx-service 的信息，请运行以下命令：
   `kubectl get service/nginx-service`

   您将收到以下输出：
   ```
   NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
   nginx-service   NodePort   172.20.36.247   <none>        80:30648/TCP   11s
   ```
   > **注**：ServiceType 为 NodePort。ClusterIP 自动创建产生，并从 NodePort 获取路由。NodePort 服务在端口 30648 上通过外部公开在可用工作线程节点上。
5. 要检查节点的公有 IP 地址，请运行以下命令：
   `kubectl get nodes -o wide |  awk {'print $1" " $2 " " $7'} | column -t`

   您将收到以下输出：
   ```
   NAME                                      STATUS  EXTERNAL-IP
   ip-10-0-3-226.eu-west-1.compute.internal  Ready   1.1.1.1
   ip-10-1-3-107.eu-west-1.compute.internal  Ready   2.2.2.2
   ```

   > **重要提示**：从外部集群中访问 NodeIP:NodePort 之前，您必须启用节点的安全组以允许通过端口 30648 的传入流量。
### 创建 LoadBalancer 服务
1. 要创建 LoadBalancer 服务，请创建一个名为 loadbalancer.yaml 的文件，然后将类型设置为 LoadBalancer。请参阅以下示例：
   ```
    cat <<EOF > loadbalancer.yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: nginx-service
    spec:
    type: LoadBalancer
    selector:
        app: nginx
    ports:
        - protocol: TCP
        port: 80
        targetPort: 80
    EOF
   ```
2. 要删除 ClusterIP 服务并使用相同的服务名称 (nginx-service) 创建 LoadBalancer 服务，请运行以下命令：
   `kubectl delete service nginx-service`

   您将收到以下输出：`service "nginx-service" deleted`
3. 要应用 loadbalancer.yaml 文件，请运行以下命令：
   `kubectl create -f loadbalancer.yaml`

   您将收到以下输出：`service/nginx-service created`

   **或者**

   要公开 LoadBalancer 类型的部署，请运行以下命令式命令：
   `kubectl expose deployment nginx  --type=LoadBalancer  --name=nginx-service`

   您将收到以下输出：`service "nginx-service" exposed`
4. 要获取有关 nginx-service 的信息，请运行以下命令：
   `kubectl get service/nginx-service |  awk {'print $1" " $2 " " $4 " " $5'} | column -t`

   您将收到以下输出：
   ```
   NAME           TYPE          EXTERNAL-IP                        PORT(S)
   nginx-service  LoadBalancer  *****.eu-west-1.elb.amazonaws.com  80:30039/TCP
   ```
5. 要验证您可以在外部访问负载均衡器，请运行以下命令：
   `curl -silent *****.eu-west-1.elb.amazonaws.com:80 | grep title`

   您应收到以下输出：<title>欢迎使用 nginx！</title>

## Reference
- [我如何公开在 Amazon EKS 集群上运行的 Kubernetes 服务？](https://aws.amazon.com/cn/premiumsupport/knowledge-center/eks-kubernetes-services-cluster/)
- [Using Kubernetes LoadBalancer Services on AWS](https://www.giantswarm.io/blog/load-balancer-service-use-cases-on-aws)