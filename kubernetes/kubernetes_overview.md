# 概述
## 4. 使用Kubernetes对象
Kubernetes 对象是 Kubernetes 系统中的持久性实体。Kubernetes 使用这些实体表示您的集群状态。了解 Kubernetes 对象模型以及如何使用这些对象。
### 4.1 理解 Kubernetes 对象（Understanding Kubernetes Objects）
本页说明了 Kubernetes 对象在 Kubernetes API 中是如何表示的，以及如何在 .yaml 格式的文件中表示。

在 Kubernetes 系统中，Kubernetes 对象 是持久化的实体。 Kubernetes 使用这些实体去表示整个集群的状态。特别地，它们描述了如下信息：
- 哪些容器化应用在运行（以及在哪些节点上）
- 可以被应用使用的资源
- 关于应用运行时表现的策略，比如重启策略、升级策略，以及容错策略

Kubernetes 对象是 “目标性记录” —— 一旦创建对象，Kubernetes 系统将持续工作以确保对象存在。 通过创建对象，本质上是在告知 Kubernetes 系统，所需要的集群工作负载看起来是什么样子的， 这就是 Kubernetes 集群的 期望状态（Desired State）。

操作 Kubernetes 对象 —— 无论是创建、修改，或者删除 —— 需要使用 [Kubernetes API](https://kubernetes.io/zh/docs/concepts/overview/kubernetes-api)。 比如，当使用`kubectl` 命令行接口时，CLI 会执行必要的 Kubernetes API 调用， 也可以在程序中使用[客户端库](https://kubernetes.io/zh/docs/reference/using-api/client-libraries/)直接调用 Kubernetes API。
#### 4.1.1 对象规约（Spec）与状态（Status）
几乎每个 Kubernetes 对象包含两个嵌套的对象字段，它们负责管理对象的配置： 对象 spec（规约） 和 对象 status（状态）。 对于具有 spec 的对象，你必须在创建对象时设置其内容，描述你希望对象所具有的特征： 期望状态（Desired State）。

status 描述了对象的当前状态（Current State），它是由 Kubernetes 系统和组件 设置并更新的。在任何时刻，Kubernetes 控制面 都一直积极地管理着对象的实际状态，以使之与期望状态相匹配。

例如，Kubernetes 中的 Deployment 对象能够表示运行在集群中的应用。 当创建 Deployment 时，可能需要设置 Deployment 的 `spec`，以指定该应用需要有 3 个副本运行。 Kubernetes 系统读取 Deployment 规约，并启动我们所期望的应用的 3 个实例 —— 更新状态以与规约相匹配。 如果这些实例中有的失败了（一种状态变更），Kubernetes 系统通过执行修正操作 来响应规约和状态间的不一致 —— 在这里意味着它会启动一个新的实例来替换。

关于对象 spec、status 和 metadata 的更多信息，可参阅 [Kubernetes API 约定](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md)。
#### 4.1.2 描述 Kubernetes 对象
创建 Kubernetes 对象时，必须提供对象的规约，用来描述该对象的期望状态， 以及关于对象的一些基本信息（例如名称）。 当使用 Kubernetes API 创建对象时（或者直接创建，或者基于kubectl）， API 请求必须在请求体中包含 JSON 格式的信息。```大多数情况下，需要在 .yaml 文件中为 kubectl 提供这些信息。 kubectl 在发起 API 请求时，将这些信息转换成 JSON 格式```。

这里有一个 .yaml 示例文件，展示了 Kubernetes Deployment 的必需字段和对象规约：
> application/deployment.yaml
```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
使用类似于上面的 .yaml 文件来创建 Deployment的一种方式是使用 kubectl 命令行接口（CLI）中的 kubectl apply 命令， 将 .yaml 文件作为参数。下面是一个示例：
`kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record`

输出类似如下这样：
`deployment.apps/nginx-deployment created`
#### 4.1.3 必需字段
在想要创建的 Kubernetes 对象对应的 .yaml 文件中，需要配置如下的字段：
- apiVersion - 创建该对象所使用的 Kubernetes API 的版本
- kind - 想要创建的对象的类别
- metadata - 帮助唯一性标识对象的一些数据，包括一个 name 字符串、UID 和可选的 namespace

你也需要提供对象的 spec 字段。 对象 spec 的精确格式对每个 Kubernetes 对象来说是不同的，包含了特定于该对象的嵌套字段。 [Kubernetes API 参考](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)能够帮助我们找到任何我们想创建的对象的 spec 格式。 例如，可以从 [core/v1 PodSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podspec-v1-core) 查看 `Pod` 的 `spec` 格式， 并且可以从 [apps/v1 DeploymentSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#deploymentspec-v1-apps) 查看 `Deployment` 的 `spec` 格式。
### 4.2 Kubernetes 对象管理（Kubernetes Object Management）
`kubectl` 命令行工具支持多种不同的方式来创建和管理 Kubernetes 对象。本文档概述了不同的方法。阅读 [Kubectl book](https://kubectl.docs.kubernetes.io/) 来了解 kubectl 管理对象的详细信息。
#### 4.2.1 管理技巧
> `警告`：应该只使用一种技术来管理 Kubernetes 对象。混合和匹配技术作用在同一对象上将导致未定义行为。

Management technique|Operates on|Recommended environment|Supported writers|Learning curve
--------|--------|--------|--------|--------
Imperative commands|Live objects|Development projects|1+|Lowest
Imperative object configuration|Individual files|Production projects|1|Moderate
Declarative object configuration|Directories of files|Production projects|1+|Highest
#### 4.2.2 命令式命令
使用命令式命令时，用户可以在集群中的活动对象上进行操作。用户将操作传给 kubectl 命令作为参数或标志。

这是开始或者在集群中运行一次性任务的最简单方法。因为这个技术直接在活动对象上操作，所以它不提供以前配置的历史记录。
##### 例子
通过创建 Deployment 对象来运行 nginx 容器的实例：
`kubectl run nginx --image nginx`

使用不同的语法来达到同样的上面的效果：
`kubectl create deployment nginx --image nginx`
##### 权衡
与对象配置相比的优点：
- 命令简单，易学且易于记忆。
- 命令仅需一步即可对集群进行更改。

与对象配置相比的缺点：
- 命令不与变更审查流程集成。
- 命令不提供与更改关联的审核跟踪。
- 除了实时内容外，命令不提供记录源。
- 命令不提供用于创建新对象的模板。
#### 4.2.3 命令式对象配置
在命令式对象配置中，kubectl 命令指定操作（创建，替换等），可选标志和至少一个文件名。指定的文件必须包含 YAML 或 JSON 格式的对象的完整定义。

有关对象定义的详细信息，请查看 [API 参考](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/)。
> ***警告***：replace 命令式命令将现有规范替换为新提供的规范，并删除对配置文件中缺少的对象的所有更改。此方法不应与规范独立于配置文件进行更新的资源类型一起使用。比如类型为 LoadBalancer 的服务，它的 externalIPs 字段就是独立于集群配置进行更新。

##### 例子
创建配置文件中定义的对象：
`kubectl create -f nginx.yaml`

删除两个配置文件中定义的对象：
`kubectl delete -f nginx.yaml -f redis.yaml`

通过覆盖活动配置来更新配置文件中定义的对象：
`kubectl replace -f nginx.yaml`
##### 权衡
与命令式命令相比的优点：
- 对象配置可以存储在源控制系统中，比如 Git。
- 对象配置可以与流程集成，例如在推送和审计之前检查更新。
- 对象配置提供了用于创建新对象的模板。
  
与命令式命令相比的缺点：
- 对象配置需要对对象架构有基本的了解。
- 对象配置需要额外的步骤来编写 YAML 文件。

与声明式对象配置相比的优点：
- 命令式对象配置行为更加简单易懂。
- 从 Kubernetes 1.5 版本开始，命令式对象配置更加成熟。

与声明式对象配置相比的缺点：
- 命令式对象配置更适合文件，而非目录。
- 对活动对象的更新必须反映在配置文件中，否则会在下一次替换时丢失。
#### 4.2.4 声明式对象配置
使用声明式对象配置时，用户对本地存储的对象配置文件进行操作，但是用户未定义要对该文件执行的操作。kubectl 会自动检测每个文件的创建、更新和删除操作。这使得配置可以在目录上工作，根据目录中配置文件对不同的对象执行不同的操作。

> ***说明***：声明式对象配置保留其他编写者所做的修改，即使这些更改并未合并到对象配置文件中。可以通过使用 patch API 操作仅写入观察到的差异，而不是使用 replace API 操作来替换整个对象配置来实现。
##### 例子
处理 configs 目录中的所有对象配置文件，创建并更新活动对象。可以首先使用 diff 子命令查看将要进行的更改，然后在进行应用：
```
kubectl diff -f configs/
kubectl apply -f configs/
```

递归处理目录：
```
kubectl diff -R -f configs/
kubectl apply -R -f configs/
```
##### 权衡
与命令式对象配置相比的优点：
- 对活动对象所做的更改即使未合并到配置文件中，也会被保留下来。
- 声明性对象配置更好地支持对目录进行操作并自动检测每个文件的操作类型（创建，修补，删除）。

与命令式对象配置相比的缺点：
- 声明式对象配置难于调试并且出现异常时结果难以理解。
- 使用 diff 产生的部分更新会创建复杂的合并和补丁操作。
### 4.3 对象名称和IDs（Object Names and IDs）
集群中的每一个对象都一个[名称](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names/#names)来标识在同类资源中的唯一性。

每个 Kubernetes 对象也有一个[UID](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names/#uids)来标识在整个集群中的唯一性。

比如，在同一个名字空间 中有一个名为 myapp-1234 的 Pod, 但是可以命名一个 Pod 和一个 Deployment 同为 myapp-1234.

对于用户提供的非唯一性的属性，Kubernetes 提供了[标签（Labels）](https://kubernetes.io/zh/docs/concepts/working-with-objects/labels)和[注解（Annotation）](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/annotations/)机制。
#### 4.3.1 名称
客户端提供的字符串，引用资源 url 中的对象，如/api/v1/pods/some name。

一次只能有一个给定类型的对象具有给定的名称。但是，如果删除对象，则可以创建同名的新对象。

以下是比较常见的三种资源命名约束：
##### DNS 子域名
很多资源类型需要可以用作 DNS 子域名的名称。 DNS 子域名的定义可参见[RFC 1123](https://tools.ietf.org/html/rfc1123)。 这一要求意味着名称必须满足如下规则：
- 不能超过253个字符
- 只能包含字母数字，以及'-' 和 '.'
- 须以字母数字开头
- 须以字母数字结尾
##### DNS 标签名
某些资源类型需要其名称遵循 [RFC 1123](https://tools.ietf.org/html/rfc1123) 所定义的 DNS 标签标准。也就是命名必须满足如下规则：
- 最多63个字符
- 只能包含字母数字，以及'-'
- 须以字母数字开头
- 须以字母数字结尾
##### 路径分段名称
某些资源类型要求名称能被安全地用作路径中的片段。 换句话说，其名称不能是 .、..，也不可以包含 / 或 % 这些字符。

下面是一个名为nginx-demo的 Pod 的配置清单：
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

> ***说明***： 某些资源类型可能具有额外的命名约束。
#### 4.3.2 UIDs
Kubernetes 系统生成的字符串，唯一标识对象。

在 Kubernetes 集群的整个生命周期中创建的每个对象都有一个不同的 uid，它旨在区分类似实体的历史事件。

Kubernetes UIDs 是全局唯一标识符（也叫 UUIDs）。 UUIDs 是标准化的，见 ISO/IEC 9834-8 和 ITU-T X.667.
### 4.4 命名空间（Namespaces）
### 4.5 标签和选择器（Labels and Selectors）
### 4.6 注解（Annotations）
### 4.7 字段选择器（Field Selectors）
### 4.8 推荐使用的标签（Recommended Labels）

## Reference
-- [使用Kubernetes对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/)
-- [Working with Kubernetes Objects](Working with Kubernetes Objects)