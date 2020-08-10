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
Kubernetes 支持多个虚拟集群，它们底层依赖于同一个物理集群。 这些虚拟集群被称为名字空间。
#### 4.4.1 何时使用多个名字空间
名字空间适用于存在很多跨多个团队或项目的用户的场景。对于只有几到几十个用户的集群，根本不需要创建或考虑名字空间。当需要名称空间提供的功能时，请开始使用它们。

名字空间为名称提供了一个范围。资源的名称需要在名字空间内是唯一的，但不能跨名字空间。 名字空间不能相互嵌套，每个 Kubernetes 资源只能在一个名字空间中。

名字空间是在多个用户之间划分集群资源的一种方法（通过[资源配额](https://kubernetes.io/zh/docs/concepts/policy/resource-quotas/)）。 在 Kubernetes 未来版本中，相同名字空间中的对象默认将具有相同的访问控制策略。

不需要使用多个名字空间来分隔轻微不同的资源，例如同一软件的不同版本：使用[标签](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/labels)来区分同一名字空间中的不同资源。
#### 4.4.2 使用名字空间
名字空间的创建和删除在[名字空间的管理指南](https://kubernetes.io/zh/docs/tasks/administer-cluster/namespaces/)文档描述。
> ***说明***： 避免使用前缀 kube- 创建名字空间，因为它是为 Kubernetes 系统名字空间保留的。
##### 查看名字空间
你可以使用以下命令列出集群中现存的名字空间：
```
kubectl get namespace

NAME          STATUS    AGE
default       Active    1d
kube-node-lease   Active   1d
kube-system   Active    1d
kube-public   Active    1d
```
Kubernetes 会创建三个初始名字空间：
- default 没有指明使用其它名字空间的对象所使用的默认名字空间
- kube-system Kubernetes 系统创建对象所使用的名字空间
- kube-public 这个名字空间是自动创建的，所有用户（包括未经过身份验证的用户）都可以读取它。 这个名字空间主要用于集群使用，以防某些资源在整个集群中应该是可见和可读的。 这个名字空间的公共方面只是一种约定，而不是要求。
- kube-node-lease 此名字空间用于与哥哥节点相关的租期（Lease）对象； 此对象的设计使得集群规模很大时节点心跳检测性能得到提升。
##### 为请求设置名字空间
要为当前请求设置名字空间，请使用 --namespace 参数。

例如：
```
kubectl run nginx --image=nginx --namespace=<名字空间名称>
kubectl get pods --namespace=<名字空间名称>
```
##### 设置名字空间偏好
你可以永久保存名字空间，以用于对应上下文中所有后续 kubectl 命令。
```
kubectl config set-context --current --namespace=<名字空间名称>
# 验证之
kubectl config view | grep namespace:
```
#### 4.4.3 名字空间和 DNS
当你创建一个[服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/)时， Kubernetes 会创建一个相应的 DNS 条目。

该条目的形式是 <服务名称>.<名字空间名称>.svc.cluster.local，这意味着如果容器只使用 <服务名称>，它将被解析到本地名字空间的服务。这对于跨多个名字空间（如开发、分级和生产） 使用相同的配置非常有用。如果你希望跨名字空间访问，则需要使用完全限定域名（FQDN）。
#### 4.4.4 并非所有对象都在名字空间中
大多数 kubernetes 资源（例如 Pod、Service、副本控制器等）都位于某些名字空间中。 但是名字空间资源本身并不在名字空间中。而且底层资源，例如 节点 和持久化卷不属于任何名字空间。

查看哪些 Kubernetes 资源在名字空间中，哪些不在名字空间中：
```
# 位于名字空间中的资源
kubectl api-resources --namespaced=true

# 不在名字空间中的资源
kubectl api-resources --namespaced=false
```
### 4.5 标签和选择器（Labels and Selectors）
标签（Labels） 是附加到 Kubernetes 对象（比如 Pods）上的键值对。 标签旨在用于指定对用户有意义且相关的对象的标识属性，但不直接对核心系统有语义含义。 标签可以用于组织和选择对象的子集。标签可以在创建时附加到对象，随后可以随时添加和修改。 每个对象都可以定义一组键/值标签。每个键对于给定对象必须是唯一的。
```
"metadata": {
  "labels": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```
标签能够支持高效的查询和监听操作，对于用户界面和命令行是很理想的。 应使用[注解](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/annotations/)记录非识别信息。
#### 4.5.1 动机
标签使用户能够以松散耦合的方式将他们自己的组织结构映射到系统对象，而无需客户端存储这些映射。

服务部署和批处理流水线通常是多维实体（例如，多个分区或部署、多个发行序列、多个层，每层多个微服务）。 管理通常需要交叉操作，这打破了严格的层次表示的封装，特别是由基础设施而不是用户确定的严格的层次结构。

示例标签：
- "release" : "stable", "release" : "canary"
- "environment" : "dev", "environment" : "qa", "environment" : "production"
- "tier" : "frontend", "tier" : "backend", "tier" : "cache"
- "partition" : "customerA", "partition" : "customerB"
- "track" : "daily", "track" : "weekly"

这些只是常用标签的例子; 你可以任意制定自己的约定。请记住，对于给定对象标签的键必须是唯一的。
#### 4.5.2 语法和字符集
标签 是键值对。有效的标签键有两个段：可选的前缀和名称，用斜杠（/）分隔。 名称段是必需的，必须小于等于 63 个字符，以字母数字字符（[a-z0-9A-Z]）开头和结尾， 带有破折号（-），下划线（_），点（ .）和之间的字母数字。 前缀是可选的。如果指定，前缀必须是 DNS 子域：由点（.）分隔的一系列 DNS 标签，总共不超过 253 个字符， 后跟斜杠（/）。

如果省略前缀，则假定标签键对用户是私有的。 向最终用户对象添加标签的自动系统组件（例如 kube-scheduler、kube-controller-manager、 kube-apiserver、kubectl 或其他第三方自动化工具）必须指定前缀。

kubernetes.io/ 前缀是为 Kubernetes 核心组件保留的。

有效标签值必须为 63 个字符或更少，并且必须为空或以字母数字字符（[a-z0-9A-Z]）开头和结尾， 中间可以包含破折号（-）、下划线（_）、点（.）和字母或数字。
#### 4.5.3 标签选择算符
与名称和 UID 不同， 标签不支持唯一性。通常，我们希望许多对象携带相同的标签。

通过 标签选择算符，客户端/用户可以识别一组对象。标签选择算符是 Kubernetes 中的核心分组原语。

API 目前支持两种类型的选择算符：基于等值的和基于集合的。 标签选择算符可以由逗号分隔的多个需求组成。 在多个需求的情况下，必须满足所有要求，因此逗号分隔符充当逻辑 与（&&）运算符。

空标签选择算符或者未指定的选择算符的语义取决于上下文， 支持使用选择算符的 API 类别应该将算符的合法性和含义用文档记录下来。

> **说明**： 对于某些 API 类别（例如 ReplicaSet）而言，两个实例的标签选择算符不得在命名空间内重叠， 否则它们的控制器将互相冲突，无法确定应该存在的副本个数。

> `注意`： 对于基于等值的和基于集合的条件而言，不存在逻辑或（||）操作符。 你要确保你的过滤语句按合适的方式组织。
##### 基于等值的需求
基于等值 或 基于不等值 的需求允许按标签键和值进行过滤。 匹配对象必须满足所有指定的标签约束，尽管它们也可能具有其他标签。 可接受的运算符有=、== 和 ！= 三种。 前两个表示 相等（并且只是同义词），而后者表示 不相等。例如：
```
environment = production
tier != frontend
```
前者选择所有资源，其键名等于 environment，值等于 production。 后者选择所有资源，其键名等于 tier，值不同于 frontend，所有资源都没有带有 tier 键的标签。 可以使用逗号运算符来过滤 production 环境中的非 frontend 层资源：`environment=production,tier!=frontend`。

基于等值的标签要求的一种使用场景是 Pod 要指定节点选择标准。 例如，下面的示例 Pod 选择带有标签 "accelerator=nvidia-tesla-p100"。
```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:
    accelerator: nvidia-tesla-p100
```
##### 基于集合的需求
基于集合 的标签需求允许你通过一组值来过滤键。 支持三种操作符：in、notin 和 exists (只可以用在键标识符上)。例如：
```
environment in (production, qa)
tier notin (frontend, backend)
partition
!partition
```
第一个示例选择了所有键等于 environment 并且值等于 production 或者 qa 的资源。 第二个示例选择了所有键等于 tier 并且值不等于 frontend 或者 backend 的资源，以及所有没有 tier 键标签的资源。 第三个示例选择了所有包含了有 partition 标签的资源；没有校验它的值。 第四个示例选择了所有没有 partition 标签的资源；没有校验它的值。 类似地，逗号分隔符充当 与 运算符。因此，使用 partition 键（无论为何值）和 environment 不同于 qa 来过滤资源可以使用 `partition, environment notin（qa)` 来实现。

基于集合 的标签选择算符是相等标签选择算符的一般形式，因为 environment=production 等同于 environment in（production；!= 和 notin 也是类似的。

基于集合 的要求可以与基于 相等 的要求混合使用。例如：partition in (customerA, customerB),environment!=qa。
#### 4.5.4 API
##### LIST 和 WATCH 过滤
LIST and WATCH 操作可以使用查询参数指定标签选择算符过滤一组对象。 两种需求都是允许的。（这里显示的是它们出现在 URL 查询字符串中）
- 基于等值的需求: `?labelSelector=environment%3Dproduction,tier%3Dfrontend`
- 基于集合的需求: `?labelSelector=environment+in+%28production%2Cqa%29%2Ctier+in+%28frontend%29`

两种标签选择算符都可以通过 REST 客户端用于 list 或者 watch 资源。 例如，使用 kubectl 定位 apiserver，可以使用 基于等值 的标签选择算符可以这么写：
```
kubectl get pods -l environment=production,tier=frontend
```

或者使用 基于集合的 需求：
```
kubectl get pods -l 'environment in (production),tier in (frontend)'
```

正如刚才提到的，基于集合 的需求更具有表达力。例如，它们可以实现值的 或 操作：
```
kubectl get pods -l 'environment in (production, qa)'
```

或者通过 exists 运算符限制不匹配：
```
kubectl get pods -l 'environment,environment notin (frontend)'
```
##### 在 API 对象上设置引用
一些 Kubernetes 对象，例如 `services` 和 `replicationcontrollers` ， 也使用了标签选择算符去指定了其他资源的集合，例如 [pods](https://kubernetes.io/zh/docs/concepts/workloads/pods/)。
###### Service 和 ReplicationController
一个 Service 指向的一组 pods 是由标签选择算符定义的。同样，一个 ReplicationController 应该管理的 pods 的数量也是由标签选择算符定义的。

两个对象的标签选择算符都是在 json 或者 yaml 文件中使用映射定义的，并且只支持 基于等值 需求的选择算符：
```
"selector": {
    "component" : "redis",
}
```
或者
```
selector:
    component: redis
```
这个选择算符(分别在 json 或者 yaml 格式中) 等价于 component=redis 或 component in (redis) 。
###### 支持基于集合需求的资源
比较新的资源，例如 `Job`、 `Deployment`、 `Replica Set` 和 `DaemonSet` ， 也支持 基于集合的需求。
```
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```
matchLabels 是由 {key,value} 对组成的映射。 matchLabels 映射中的单个 {key,value } 等同于 matchExpressions 的元素， 其 key 字段为 "key"，operator 为 "In"，而 values 数组仅包含 "value"。 matchExpressions 是 Pod 选择算符需求的列表。 有效的运算符包括 In、NotIn、Exists 和 DoesNotExist。 在 In 和 NotIn 的情况下，设置的值必须是非空的。 来自 matchLabels 和 matchExpressions 的所有要求都按逻辑与的关系组合到一起 -- 它们必须都满足才能匹配。
###### 选择节点集
通过标签进行选择的一个用例是确定节点集，方便 Pod 调度。 有关更多信息，请参阅[选择节点](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/assign-pod-node/)文档。
### 4.6 注解（Annotations）
你可以使用 Kubernetes 注解为对象附加任意的非标识的元数据。客户端程序（例如工具和库）能够获取这些元数据信息。
#### 4.6.1 为对象附加元数据
你可以使用标签或注解将元数据附加到 Kubernetes 对象。 标签可以用来选择对象和查找满足某些条件的对象集合。 相反，注解不用于标识和选择对象。 注解中的元数据，可以很小，也可以很大，可以是结构化的，也可以是非结构化的，能够包含标签不允许的字符。

注解和标签一样，是键/值对:
```
"metadata": {
  "annotations": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```
以下是一些例子，用来说明哪些信息可以使用注解来记录:
- 由声明性配置所管理的字段。 将这些字段附加为注解，能够将它们与客户端或服务端设置的默认值、 自动生成的字段以及通过自动调整大小或自动伸缩系统设置的字段区分开来。
- 构建、发布或镜像信息（如时间戳、发布 ID、Git 分支、PR 数量、镜像哈希、仓库地址）。
- 指向日志记录、监控、分析或审计仓库的指针。
- 可用于调试目的的客户端库或工具信息：例如，名称、版本和构建信息。
- 用户或者工具/系统的来源信息，例如来自其他生态系统组件的相关对象的 URL。
- 轻量级上线工具的元数据信息：例如，配置或检查点。
- 负责人员的电话或呼机号码，或指定在何处可以找到该信息的目录条目，如团队网站。
- 从用户到最终运行的指令，以修改行为或使用非标准功能。

你可以将这类信息存储在外部数据库或目录中而不使用注解， 但这样做就使得开发人员很难生成用于部署、管理、自检的客户端共享库和工具。
#### 4.6.2 语法和字符集
注解（Annotations） 存储的形式是键/值对。有效的注解键分为两部分： 可选的前缀和名称，以斜杠（/）分隔。 名称段是必需项，并且必须在63个字符以内，以字母数字字符（[a-z0-9A-Z]）开头和结尾， 并允许使用破折号（-），下划线（_），点（.）和字母数字。 前缀是可选的。如果指定，则前缀必须是DNS子域：一系列由点（.）分隔的DNS标签， 总计不超过253个字符，后跟斜杠（/）。 如果省略前缀，则假定注释键对用户是私有的。 由系统组件添加的注释 （例如，`kube-scheduler`，`kube-controller-manager`，`kube-apiserver`，`kubectl` 或其他第三方组件），必须为终端用户添加注释前缀。

`kubernetes.io/` 和 `k8s.io/` 前缀是为Kubernetes核心组件保留的。

例如，这是一个Pod的配置文件，其注解为 `imageregistry: https://hub.docker.com/`：
```
apiVersion: v1
kind: Pod
metadata:
  name: annotations-demo
  annotations:
    imageregistry: "https://hub.docker.com/"
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
```
### 4.7 字段选择器（Field Selectors）
字段选择器（Field selectors）允许你根据一个或多个资源字段的值 筛选 Kubernetes 资源。 下面是一些使用字段选择器查询的例子：
- metadata.name=my-service
- metadata.namespace!=default
- status.phase=Pending
下面这个 kubectl 命令将筛选出 status.phase 字段值为 Running 的所有 Pod：
```
kubectl get pods --field-selector status.phase=Running
```
> **说明**：字段选择器本质上是资源过滤器（Filters）。默认情况下，字段选择器/过滤器是未被应用的， 这意味着指定类型的所有资源都会被筛选出来。 这使得以下的两个 kubectl 查询是等价的：
> 
> `kubectl get pods`
> `kubectl get pods --field-selector ""`
#### 4.7.1 支持的字段
不同的 Kubernetes 资源类型支持不同的字段选择器。 所有资源类型都支持 metadata.name 和 metadata.namespace 字段。 使用不被支持的字段选择器会产生错误。例如：
```
kubectl get ingress --field-selector foo.bar=baz
```

```
Error from server (BadRequest): Unable to find "ingresses" that match label selector "", field selector "foo.bar=baz": "foo.bar" is not a known field selector: only "metadata.name", "metadata.namespace"
```
#### 4.7.2 支持的操作符
你可在字段选择器中使用 =、==和 != （= 和 == 的意义是相同的）操作符。 例如，下面这个 kubectl 命令将筛选所有不属于 default 命名空间的 Kubernetes 服务：
```
kubectl get services  --all-namespaces --field-selector metadata.namespace!=default
```
#### 4.7.3 链式选择器
同标签和其他选择器一样， 字段选择器可以通过使用逗号分隔的列表组成一个选择链。 下面这个 kubectl 命令将筛选 status.phase 字段不等于 Running 同时 spec.restartPolicy 字段等于 Always 的所有 Pod：
```
kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always
```
#### 4.7.4 多种资源类型
你能够跨多种资源类型来使用字段选择器。 下面这个 kubectl 命令将筛选出所有不在 default 命名空间中的 StatefulSet 和 Service：
```
kubectl get statefulsets,services --all-namespaces --field-selector metadata.namespace!=default
```
### 4.8 推荐使用的标签（Recommended Labels）
除了 kubectl 和 dashboard 之外，您可以使用其他工具来可视化和管理 Kubernetes 对象。一组通用的标签可以让多个工具之间相互操作，用所有工具都能理解的通用方式描述对象。

除了支持工具外，推荐的标签还以一种可以查询的方式描述了应用程序。

元数据围绕 应用（application） 的概念进行组织。Kubernetes 不是 平台即服务（PaaS），没有或强制执行正式的应用程序概念。 相反，应用程序是非正式的，并使用元数据进行描述。应用程序包含的定义是松散的。
> **说明**：这些是推荐的标签。它们使管理应用程序变得更容易但不是任何核心工具所必需的。

共享标签和注解都使用同一个前缀：app.kubernetes.io。没有前缀的标签是用户私有的。共享前缀可以确保共享标签不会干扰用户自定义的标签。
#### 4.8.1 标签
为了充分利用这些标签，应该在每个资源对象上都使用它们。

键|描述|示例|类型
--------|--------|--------|--------
app.kubernetes.io/name|应用程序的名称|mysql|字符串
app.kubernetes.io/instance|用于唯一确定应用实例的名称|mysql-abcxzy|字符串
app.kubernetes.io/version|应用程序的当前版本（例如，语义版本，修订版哈希等）|5.7.21|字符串
app.kubernetes.io/component|架构中的组件|database|字符串
app.kubernetes.io/part-of|此级别的更高级别应用程序的名称|wordpress|字符串
app.kubernetes.io/managed-by|用于管理应用程序的工具|helm|字符串

为说明这些标签的实际使用情况，请看下面的 StatefulSet 对象：
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-abcxzy
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/managed-by: helm
```
#### 4.8.2 应用和应用实例
应用可以在 Kubernetes 集群中安装一次或多次。在某些情况下，可以安装在同一命名空间中。例如，可以不止一次地为不同的站点安装不同的 wordpress。

应用的名称和实例的名称是分别记录的。例如，某 `WordPress` 实例的 `app.kubernetes.io/name` 为 `wordpress`，而其实例名称表现为 `app.kubernetes.io/instance` 的属性值 `wordpress-abcxzy`。这使应用程序和应用程序的实例成为可能是可识别的。应用程序的每个实例都必须具有唯一的名称。
#### 4.8.3 示例
为了说明使用这些标签的不同方式，以下示例具有不同的复杂性。
##### 一个简单的无状态服务
考虑使用 `Deployment` 和 `Service` 对象部署的简单无状态服务的情况。以下两个代码段表示如何以最简单的形式使用标签。

下面的 `Deployment` 用于监督运行应用本身的 pods。
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: myservice
    app.kubernetes.io/instance: myservice-abcxzy
...
```

下面的 Service 用于暴露应用。
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: myservice
    app.kubernetes.io/instance: myservice-abcxzy
...
```
##### 带有一个数据库的 Web 应用程序
考虑一个稍微复杂的应用：一个使用 Helm 安装的 Web 应用（WordPress），其中 使用了数据库（MySQL）。以下代码片段说明用于部署此应用程序的对象的开始。

以下 Deployment 的开头用于 WordPress：
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
...
```

这个 Service 用于暴露 WordPress：
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
...
```

MySQL 作为一个 StatefulSet 暴露，包含它和它所属的较大应用程序的元数据：
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-abcxzy
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
...
```

Service 用于将 MySQL 作为 WordPress 的一部分暴露：
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-abcxzy
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
...
```
使用 MySQL StatefulSet 和 Service，您会注意到有关 MySQL 和 Wordpress 的信息，包括更广泛的应用程序。

## Reference
-- [使用Kubernetes对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/)
-- [Working with Kubernetes Objects](Working with Kubernetes Objects)