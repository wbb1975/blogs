# Access Applications in a Cluster (访问集群中的应用程序)
- [Deploy and Access the Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/): Deploy the web UI (Kubernetes Dashboard) and access it.
- [Accessing Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/)
- [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
- [Use Port Forwarding to Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)
- [Use a Service to Access an Application in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/)
- [Connect a Frontend to a Backend Using Services](https://kubernetes.io/docs/tasks/access-application-cluster/connecting-frontend-backend/)
- [Create an External Load Balancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/)
- [List All Container Images Running in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/)
- [Set up Ingress on Minikube with the NGINX Ingress Controller](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)
- [Communicate Between Containers in the Same Pod Using a Shared Volume](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/)
- [Configure DNS for a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/configure-dns-cluster/)
## 一. 部署和访问Kubernetes仪表板
Dashboard 是基于网页的 Kubernetes 用户界面。 你可以使用 Dashboard 将容器应用部署到 Kubernetes 集群中，也可以对容器应用排错，还能管理集群资源。 你可以使用 Dashboard 获取运行在集群中的应用的概览信息，也可以创建或者修改 Kubernetes 资源 （如 Deployment，Job，DaemonSet 等等）。 例如，你可以对 Deployment 实现弹性伸缩、发起滚动升级、重启 Pod 或者使用向导创建新的应用。

Dashboard 同时展示了 Kubernetes 集群中的资源状态信息和所有错误信息。

![Kubernetes Dashboard](images/ui-dashboard.png)
### 部署 Dashboard UI
默认情况下不会部署 Dashboard。可以通过以下命令部署：
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```
### 访问 Dashboard UI
为了保护你的集群数据，默认情况下，`Dashboard` 会使用最少的 RBAC 配置进行部署。 当前，`Dashboard` 仅支持使用 `Bearer` 令牌登录。 要为此样本演示创建令牌，你可以按照 创建示例用户 上的指南进行操作。
> 警告： 在教程中创建的样本用户将具有管理特权，并且仅用于教育目的。
#### 命令行代理
你可以使用 kubectl 命令行工具访问 Dashboard，命令如下：
```
kubectl proxy
```
kubectl 会使得 Dashboard 可以通过 http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ 访问。

UI 只能 通过执行这条命令的机器进行访问。更多选项参见 kubectl proxy --help。
> 说明： Kubeconfig 身份验证方法不支持外部身份提供程序或基于 x509 证书的身份验证。
### 欢迎界面
当访问空集群的 Dashboard 时，你会看到欢迎界面。 页面包含一个指向此文档的链接，以及一个用于部署第一个应用程序的按钮。 此外，你可以看到在默认情况下有哪些默认系统应用运行在 kube-system 名字空间 中，比如 Dashboard 自己。

![欢迎界面](images/ui-dashboard-zerostate.png)
### 部署容器化应用
通过一个简单的部署向导，你可以使用 Dashboard 将容器化应用作为一个 Deployment 和可选的 Service 进行创建和部署。可以手工指定应用的详细配置，或者上传一个包含应用配置的 YAML 或 JSON 文件。

点击任何页面右上角的 CREATE 按钮以开始。
#### 指定应用的详细配置
部署向导需要你提供以下信息：
- 应用名称（必填）：应用的名称。内容为应用名称的[标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) 会被添加到任何将被部署的 Deployment 和 Service。

  在选定的 [Kubernetes 名字空间](https://kubernetes.io/zh/docs/tasks/administer-cluster/namespaces/) 中，应用名称必须唯一。必须由小写字母开头，以数字或者小写字母结尾，并且只含有小写字母、数字和中划线（-）。小于等于24个字符。开头和结尾的空格会被忽略。
- 容器镜像（必填）：公共镜像仓库上的 [Docker 容器镜像](https://kubernetes.io/zh/docs/concepts/containers/images/) 或者私有镜像仓库 （通常是 Google Container Registry 或者 Docker Hub）的 URL。容器镜像参数说明必须以冒号结尾。
- Pod 的数量（必填）：你希望应用程序部署的 Pod 的数量。值必须为正整数。

  系统会创建一个 [Deployment](https://kubernetes.io/zh/docs/concepts/workloads/controllers/deployment/) 以保证集群中运行期望的 Pod 数量。
- 服务（可选）：对于部分应用（比如前端），你可能想对外暴露一个 [Service](https://kubernetes.io/zh/docs/concepts/services-networking/service/) ，这个 Service 可能用的是集群之外的公网 IP 地址（外部 Service）。

  > 说明： 对于外部服务，你可能需要开放一个或多个端口才行。
  其它只能对集群内部可见的 Service 称为内部 Service。

  不管哪种 Service 类型，如果你选择创建一个 Service，而且容器在一个端口上开启了监听（入向的）， 那么你需要定义两个端口。创建的 Service 会把（入向的）端口映射到容器可见的目标端口。 该 Service 会把流量路由到你部署的 Pod。支持 TCP 协议和 UDP 协议。 这个 Service 的内部 DNS 解析名就是之前你定义的应用名称的值。

如果需要，你可以打开 `Advanced Options` 部分，这里你可以定义更多设置：
- 描述：这里你输入的文本会作为一个 [注解](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/annotations/) 添加到 Deployment，并显示在应用的详细信息中。
- 标签：应用默认使用的[标签](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/labels/)是应用名称和版本。 你可以为 Deployment、Service（如果有）定义额外的标签，比如 release（版本）、 environment（环境）、tier（层级）、partition（分区） 和 release track（版本跟踪）。

  例子：
  ```
  release=1.0
  tier=frontend
  environment=pod
  track=stable
  ```
- 名字空间：Kubernetes 支持多个虚拟集群依附于同一个物理集群。 这些虚拟集群被称为[名字空间](https://kubernetes.io/zh/docs/tasks/administer-cluster/namespaces/)， 可以让你将资源划分为逻辑命名的组。

  Dashboard 通过下拉菜单提供所有可用的名字空间，并允许你创建新的名字空间。 名字空间的名称最长可以包含 63 个字母或数字和中横线（-），但是不能包含大写字母。

  名字空间的名称不能只包含数字。如果名字被设置成一个数字，比如 10，pod 就在名字空间创建成功的情况下，默认会使用新创建的名字空间。如果创建失败，那么第一个名字空间会被选中。
- 镜像拉取 Secret：如果要使用私有的 Docker 容器镜像，需要拉取 [Secret]((https://kubernetes.io/zh/docs/concepts/configuration/secret/)) 凭证。

  Dashboard 通过下拉菜单提供所有可用的 Secret，并允许你创建新的 Secret。 Secret 名称必须遵循 DNS 域名语法，比如 `new.image-pull.secret`。 Secret 的内容必须是 base64 编码的，并且在一个 .dockercfg 文件中声明。Secret 名称最大可以包含 253 个字符。

  在镜像拉取 Secret 创建成功的情况下，默认会使用新创建的 Secret。 如果创建失败，则不会使用任何 Secret。
- CPU 需求（核数）和内存需求（MiB）：你可以为容器定义最小的[资源限制](https://kubernetes.io/zh/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/)。 默认情况下，Pod 没有 CPU 和内存限制。
- 运行命令和运行命令参数：默认情况下，你的容器会运行 Docker 镜像的默认[入口命令](https://kubernetes.io/zh/docs/tasks/inject-data-application/define-command-argument-container/)。 你可以使用 command 选项覆盖默认值。
- 以特权模式运行：这个设置决定了在[特权容器](https://kubernetes.io/zh/docs/concepts/workloads/pods/#privileged-mode-for-containers)中运行的进程是否像主机中使用 root 运行的进程一样。 特权容器可以使用诸如操纵网络堆栈和访问设备的功能。
- 环境变量：Kubernetes 通过[环境变量](https://kubernetes.io/zh/docs/tasks/inject-data-application/environment-variable-expose-pod-information/)暴露 Service。你可以构建环境变量，或者将环境变量的值作为参数传递给你的命令。 它们可以被应用用于查找 Service。值可以通过 `$(VAR_NAME)` 语法关联其它变量。
#### 上传 YAML 或者 JSON 文件
Kubernetes 支持声明式配置。所有的配置都存储在遵循 Kubernetes API 规范的 YAML 或者 JSON 配置文件中。

作为一种替代在部署向导中指定应用详情的方式，你可以在 YAML 或者 JSON 文件中定义应用，并且使用 Dashboard 上传文件。
### 使用 Dashboard
以下各节描述了 Kubernetes Dashboard UI 视图；包括它们提供的内容，以及怎么使用它们。
#### 导航
当在集群中定义 Kubernetes 对象时，Dashboard 会在初始视图中显示它们。 默认情况下只会显示 默认 名字空间中的对象，可以通过更改导航栏菜单中的名字空间筛选器进行改变。

Dashboard 展示大部分 Kubernetes 对象，并将它们分组放在几个菜单类别中。
#### 管理概述
对集群和名字空间管理员, Dashboard 会列出节点、名字空间和持久卷，并且有它们的详细视图。 节点列表视图包含从所有节点聚合的 CPU 和内存使用的度量值。详细信息视图显示了一个节点的度量值，它的规格、状态、分配的资源、事件和这个节点上运行的 Pod。
#### 负载
显示选中的名字空间中所有运行的应用。 视图按照负载类型（如 Deployment、ReplicaSet、StatefulSet 等）罗列应用，并且每种负载都可以单独查看。列表总结了关于负载的可执行信息，比如一个 ReplicaSet 的准备状态的 Pod 数量，或者目前一个 Pod 的内存使用量。

工作负载的详情视图展示了对象的状态、详细信息和相互关系。 例如，ReplicaSet 所控制的 Pod，或者 Deployment 关联的 新 ReplicaSet 和 Pod 水平扩展控制器。
#### 服务
展示允许暴露给外网服务和允许集群内部发现的 Kubernetes 资源。 因此，Service 和 Ingress 视图展示他们关联的 Pod、给集群连接使用的内部端点和给外部用户使用的外部端点。
#### 存储
存储视图展示持久卷申领（PVC）资源，这些资源被应用程序用来存储数据。
#### ConfigMap 和 Secret
展示的所有 Kubernetes 资源是在集群中运行的应用程序的实时配置。 通过这个视图可以编辑和管理配置对象，并显示那些默认隐藏的 secret。
#### 日志查看器
Pod 列表和详细信息页面可以链接到 Dashboard 内置的日志查看器。查看器可以钻取属于同一个 Pod 的不同容器的日志。

![日志查看器](images/ui-dashboard-logs-view.png)
## 二. 访问集群
## 三. 配置对多集群的访问
## 四. 使用端口转发来访问集群中的应用
## 五. 使用服务来访问集群中的应用
## 六. 使用 Service 把前端连接到后端
## 七. 创建外部负载均衡器
本文展示如何创建一个外部负载均衡器。
> 说明： 此功能仅适用于支持外部负载均衡器的云提供商或环境。
创建服务时，你可以选择自动创建云网络负载均衡器。这提供了一个外部可访问的 IP 地址，可将流量分配到集群节点上的正确端口上 （ 假设集群在支持的环境中运行，并配置了正确的云负载平衡器提供商包）。

有关如何配置和使用 Ingress 资源为服务提供外部可访问的 URL、负载均衡流量、终止 SSL 等功能，请查看 [Ingress](https://kubernetes.io/zh/docs/concepts/services-networking/ingress/) 文档。
### 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/tasks/tools/#minikube) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [玩转 Kubernetes](http://labs.play-with-k8s.com/)

要获知版本信息，请输入 `kubectl version`。
### 配置文件
要创建外部负载均衡器，请将以下内容添加到[服务配置文件](https://kubernetes.io/zh/docs/concepts/services-networking/service/#loadbalancer)：`type: LoadBalancer`

你的配置文件可能会如下所示：
```
apiVersion: v1
kind: Service
metadata:
  name: example-service
spec:
  selector:
    app: example
  ports:
    - port: 8765
      targetPort: 9376
  type: LoadBalancer
```
### 使用 kubectl
你也可以使用 `kubectl expose` 命令及其 `--type=LoadBalancer` 参数创建服务：
```
kubectl expose rc example --port=8765 --target-port=9376 --name=example-service --type=LoadBalancer
```
此命令通过使用与引用资源（在上面的示例的情况下，名为 example 的 replication controller）相同的选择器来创建一个新的服务。

更多信息（包括更多的可选参数），请参阅 [kubectl expose 指南](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#expose)。
### 找到你的 IP 地址
你可以通过 kubectl 获取服务信息，找到为你的服务创建的 IP 地址：
```
kubectl describe services example-service
```
这将获得如下输出：
```
    Name:                   example-service
    Namespace:              default
    Labels:                 <none>
    Annotations:            <none>
    Selector:               app=example
    Type:                   LoadBalancer
    IP:                     10.67.252.103
    LoadBalancer Ingress:   192.0.2.89
    Port:                   <unnamed> 80/TCP
    NodePort:               <unnamed> 32445/TCP
    Endpoints:              10.64.0.4:80,10.64.1.5:80,10.64.2.4:80
    Session Affinity:       None
    Events:                 <none>
```
IP 地址列在 `LoadBalancer Ingress` 旁边。

> 说明：如果你在 Minikube 上运行服务，你可以通过以下命令找到分配的 IP 地址和端口：`minikube service example-service --url`
### 保留客户端源 IP
默认地，目标容器中看到的源 IP 将 不是客户端的原始源 IP。要启用保留客户端 IP，可以在服务的 spec 中配置以下字段（支持 GCE/Google Kubernetes Engine 环境）：
- `service.spec.externalTrafficPolicy` - 表示此服务是否希望将外部流量路由到节点本地或集群范围的端点。 有两个可用选项：`Cluster（默认）`和 `Local`。 `Cluster` 隐藏了客户端源 IP，可能导致第二跳到另一个节点，但具有良好的整体负载分布。 `Local` 保留客户端源 IP 并避免 `LoadBalancer` 和 `NodePort` 类型服务的第二跳， 但存在潜在的不均衡流量传播风险。
- `service.spec.healthCheckNodePort` - 指定服务的 `healthcheck nodePort`（数字端口号）。 如果未指定 `healthCheckNodePort`，服务控制器从集群的 `NodePort` 范围内分配一个端口。 你可以通过设置 API 服务器的命令行选项 `--service-node-port-range` 来配置上述范围。 它将会使用用户指定的 `healthCheckNodePort` 值（如果被客户端指定）。 仅当 `type` 设置为 `LoadBalancer` 并且 `externalTrafficPolicy` 设置为 `Local` 时才生效。

可以通过在服务的配置文件中将 `externalTrafficPolicy` 设置为 `Local` 来激活此功能。
#### 保留客户端源 IP 的警告和限制
一些云提供商的负载均衡服务不能让你配置不同目标的权重。

当每个目标权重均等，即流量被平均分配到节点时，外部流量在不同 Pods 间是不均衡的。外部负载均衡器对作为目标运行的节点上有多少个 Pod 并不清楚。

当 `NumServicePods` << `_NumNodes` 或 `NumServicePods` >> `NumNodes`，即使没有权重也可以获得一个相对均衡的分配。

内部 Pod 间的流量行为如同 ClusterIP 服务，经可能保持平均。
### 回收负载均衡器（Garbage collecting load balancers）
在通常情况下，应在删除 LoadBalancer 类型服务后立即清除云提供商中的相关负载均衡器资源。 但是，众所周知，在删除关联的服务后，云资源被孤立的情况很多。引入了针对服务负载均衡器的终结器保护，以防止这种情况发生。 通过使用终结器，在删除相关的负载均衡器资源之前，也不会删除服务资源。

具体来说，如果服务具有 type LoadBalancer，则服务控制器将附加一个名为 service.kubernetes.io/load-balancer-cleanup 的终结器。 仅在清除负载均衡器资源后才能删除终结器。 即使在诸如服务控制器崩溃之类的极端情况下，这也可以防止负载均衡器资源悬空。
### 外部负载均衡器提供商
请务必注意，此功能的数据路径由 Kubernetes 集群外部的负载均衡器提供。

当服务 type 设置为 LoadBalancer 时，Kubernetes 向集群中的 Pod 提供的功能等同于 type 等于 ClusterIP，并通过对相关Kubernetes pod的节点条目对负载均衡器（从外部到 Kubernetes） 进行编程来扩展它。 Kubernetes 服务控制器自动创建外部负载均衡器、健康检查（如果需要）、防火墙规则（如果需要）， 并获取云提供商分配的外部 IP 并将其填充到服务对象中。
## 八. 列出集群中所有运行容器的镜像
## 九. 在 Minikube 环境中使用 NGINX Ingress 控制器配置 Ingress
## 十. 同 Pod 内的容器使用共享卷通信
## 十一. 为集群配置 DNS

## Reference
- [Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/)
- [K8s loadbalancer externalTrafficPolicy "Local" or "Cluster"](https://medium.com/pablo-perez/k8s-externaltrafficpolicy-local-or-cluster-40b259a19404)