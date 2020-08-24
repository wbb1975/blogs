# 如何解决 Amazon EKS 的服务负载均衡器问题
## 简短描述
要解决服务负载均衡器entity，请确认您具备以下条件：
- Amazon Virtual Private Cloud (Amazon VPC) 子网的正确标签
- 集群 IAM 角色所需的 AWS Identity and Access Management (IAM) 权限
- 有效的 Kubernetes 服务定义
- 保持在账户限制之内的负载均衡器
- 子网上拥有足够的免费 IP 地址

如果您在确认具备所有先决条件后仍存在问题，请按照故障排除部分的步骤操作。
## 解决方案
注意：以下步骤适用于 Classic Load Balancer 和网络负载均衡器。对于 Application Load Balancer，请参阅[Amazon EKS 上的 ALB 入口控制器](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)。
### 适用于 Amazon VPC 子网的正确标签：
1. 打开 [AWS VPC 控制台](https://console.aws.amazon.com/vpc/)。
2. 在导航窗格中，选择子网。
3. 选择每个子网的标签选项卡，然后确认存在标签。请参阅以下示例：
   ```
   Key: kubernetes.io/cluster/yourEKSClusterName
   Value: shared
   ```
4. 对于公有子网，请确认存在以下标签：
   ```
   Key: kubernetes.io/role/elb
   Value: 1
   ```
   注意：若要查看子网是否为公有子网，请查看与该子网关联的路由表。公有子网拥有指向互联网网关的路由 (igw-xxxxxxxxxxx)。私有子网拥有通过 NAT 网关或 NAT 实例指向互联网的路由，或者完全没有指向互联网的路由。

   > **重要提示**：您必须拥有第 4 步中的标签才能创建面向互联网的负载均衡器服务。
5. 对于私有子网，请确认以下标签存在：
   ```
   Key: kubernetes.io/role/internal-elb
   Value: 1
   ```

   > **重要提示**：您必须拥有第 5 步中的标签才能创建面向内部的负载均衡器服务。
### 集群 IAM 角色所需的 IAM 权限
1. 打开 [AWS VPC 控制台](https://console.aws.amazon.com/vpc/)。
2. 在导航窗格中，选择集群。
3. 选择您的集群，然后记下您的集群 IAM 角色 ARN。
4. 打开 [IAM 控制台](https://console.aws.amazon.com/iam/)。
5. 在导航窗格中，选择角色。
6. 选择您在第 3 步中确定的与集群 IAM 角色 ARN 匹配的角色。
7. 确认已为您的角色附加 AWS 托管策略 AmazonEKSClusterPolicy。

> **注意**：Amazon EKS 控制平面假定使用上面的 IAM 角色为您的服务创建负载均衡器。
### 有效的 Kubernetes 服务定义
1. 在 Kubernetes 服务的 YAML 文件中，确认已将 spec.type 设置为 LoadBalancer。

   以下是由负载均衡器提供支持的 Kubernetes 服务示例：
   ```
    apiVersion: v1
    kind: Service
    metadata:
    annotations:
        # This annotation is only required if you are creating an internal facing ELB. Remove this annotation to create public facing ELB.
        service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    name: nginx-elb
    labels:
        app: nginx
    spec:
    type: LoadBalancer
    ports:
    - name: "http"
        port: 80
        targetPort: 80
    selector:
        app: nginx
   ```

   > **注意**：若要使用不同的注释自定义您的服务，请参阅[内部负载均衡器](https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer)和[AWS 上的 TLS 支持](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws)。
2. 保持在账户限制之内的负载均衡器
   默认情况下，在每个 AWS 区域，一个 AWS 账户最多拥有 20 个负载均衡器。

   若要查看您拥有的负载均衡器数量，请打开 [Amazon EC2 控制台](https://console.aws.amazon.com/ec2/)，然后从导航窗格中选择负载均衡器。

   如果已达到最大负载均衡器数量，则您可以申请增加[服务配额](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html)。
3. 子网上拥有足够的免费 IP 地址
   若要创建负载均衡器，则该负载均衡器的每个子网均必须至少拥有八个免费 IP 地址。这对于 Classic Load Balancer 和网络负载均衡器来说是必需的。
### 故障排除
若要查看 Kubernetes 服务中是否存在可帮助您解决问题的错误消息，请运行以下命令：
`$ kubectl describe service my-elb-service`

如果已成功创建服务，则输出将与以下类似：
```
...
...
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  47s   service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   44s   service-controller  Ensured load balancer
```

如果未成功创建服务，则您将会收到错误消息。

若要获取与错误消息相关的更多信息，您可以执行以下操作：
- 使用 [Amazon EKS 控制平面日志](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
- 了解与 [Kubernetes 负载均衡器服务](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)相关的更多信息
- 检查[云控制器源代码](https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/legacy-cloud-providers/aws/aws.go)

## Reference
- [如何解决 Amazon EKS 的服务负载均衡器问题](https://aws.amazon.com/cn/premiumsupport/knowledge-center/eks-load-balancers-troubleshooting/)
- [负载均衡](https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html)
- [VPC 中负载均衡器使用的子网没有足够的 IP 地址](https://aws.amazon.com/premiumsupport/knowledge-center/subnet-insufficient-ips/)