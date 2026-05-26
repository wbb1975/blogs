## Leases

分布式系统通常需要租约（Lease）；租约提供了一种机制来锁定共享资源并协调集合成员之间的活动。 在 Kubernetes 中，租约概念表示为 `coordination.k8s.io API` 组中的 [Lease](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/lease-v1/) 对象，常用于类似节点心跳和组件级领导者选举等系统核心能力。

### 节点心跳

Kubernetes 使用 Lease API 将 kubelet 节点心跳传递到 Kubernetes API 服务器。对于每个 `Node`，在 `kube-node-lease` 名字空间中都有一个具有匹配名称的 `Lease` 对象。在此基础上，每个 `kubelet` 心跳都是对该 Lease 对象的 **update** 请求，更新该 Lease 的 `spec.renewTime` 字段。Kubernetes 控制平面使用此字段的时间戳来确定此 `Node` 的可用性。

更多细节请参阅 [Node Lease 对象](https://kubernetes.io/zh-cn/docs/concepts/architecture/nodes/#node-heartbeats) 对象。

### 领导者选举

Kubernetes 也使用租约确保在任何给定时间某个组件只有一个实例在运行。在高可用配置中`kube-controller-manager` 和 `kube-scheduler` 等控制平面组件使用了这种机制，这些组件只应有一个实例激活运行，而其它实例则待机。

参阅[协调领导者选举](https://kubernetes.io/zh-cn/docs/concepts/cluster-administration/coordinated-leader-election)以了解 Kubernetes 如何基于 Lease API 来选择哪个组件实例充当领导者。

#### Kube 控制器管理器在退出时释放锁定

> 特性状态： Kubernetes v1.36 [alpha]（默认禁用）

启用 `ControllerManagerReleaseLeaderElectionLockOnExit` 特性门后， `kube-controller-manager` 会在领导者切换期间主动释放其领导者选举锁，而不是等待锁的 TTL 过期。这使得新领导者能够更快地被选出，从而降低领导者切换延迟。

### API 服务器身份

> 特性状态： Kubernetes v1.26 [beta]（默认启用）

从 Kubernetes v1.26 开始，每个 `kube-apiserver` 都使用 `Lease API` 将其身份发布到系统中的其他位置。 虽然它本身并不是特别有用，但为客户端提供了一种机制来发现有多少个 `kube-apiserver` 实例正在操作 Kubernetes 控制平面。`kube-apiserver` 租约的存在使得未来可以在各个 `kube-apiserver` 之间协调新的能力。

你可以检查 kube-system 名字空间中名为 `apiserver-<sha256-hash>` 的 Lease 对象来查看每个 kube-apiserver 拥有的租约。你还可以使用标签选择算符 `apiserver.kubernetes.io/identity=kube-apiserver`：

```
kubectl -n kube-system get lease -l apiserver.kubernetes.io/identity=kube-apiserver

NAME                                        HOLDER                                                                           AGE
apiserver-07a5ea9b9b072c4a5f3d1c3702        apiserver-07a5ea9b9b072c4a5f3d1c3702_0c8914f7-0f35-440e-8676-7844977d3a05        5m33s
apiserver-7be9e061c59d368b3ddaf1376e        apiserver-7be9e061c59d368b3ddaf1376e_84f2a85d-37c1-4b14-b6b9-603e62e4896f        4m23s
apiserver-1dfef752bcb36637d2763d1868        apiserver-1dfef752bcb36637d2763d1868_c5ffa286-8a9a-45d4-91e7-61118ed58d2e        4m43s
```

租约名称中使用的 SHA256 哈希基于 API 服务器所看到的操作系统主机名生成。 每个 kube-apiserver 都应该被配置为使用集群中唯一的主机名。 使用相同主机名的 kube-apiserver 新实例将使用新的持有者身份接管现有 Lease，而不是实例化新的 Lease 对象。 你可以通过检查 `kubernetes.io/hostname` 标签的值来查看 kube-apiserver 所使用的主机名：

```
kubectl -n kube-system get lease apiserver-07a5ea9b9b072c4a5f3d1c3702 -o yaml

apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
  creationTimestamp: "2023-07-02T13:16:48Z"
  labels:
    apiserver.kubernetes.io/identity: kube-apiserver
    kubernetes.io/hostname: master-1
  name: apiserver-07a5ea9b9b072c4a5f3d1c3702
  namespace: kube-system
  resourceVersion: "334899"
  uid: 90870ab5-1ba9-4523-b215-e4d4e662acb1
spec:
  holderIdentity: apiserver-07a5ea9b9b072c4a5f3d1c3702_0c8914f7-0f35-440e-8676-7844977d3a05
  leaseDurationSeconds: 3600
  renewTime: "2023-07-04T21:58:48.065888Z"
```

kube-apiserver 中不再存续的已到期租约将在到期 1 小时后被新的 kube-apiserver 作为垃圾收集。

你可以通过禁用 `APIServerIdentity` [特性门控](https://kubernetes.io/zh-cn/docs/reference/command-line-tools-reference/feature-gates/)来禁用 API 服务器身份租约。

### 工作负载

你自己的工作负载可以定义自己使用的 Lease。例如， 你可以运行自定义的控制器， 让主要成员或领导者成员在其中执行其对等方未执行的操作。 你定义一个 Lease，以便控制器副本可以使用 Kubernetes API 进行协调以选择或选举一个领导者。 如果你使用 Lease，良好的做法是为明显关联到产品或组件的 Lease 定义一个名称。 例如，如果你有一个名为 Example Foo 的组件，可以使用名为`example-foo` 的 Lease。

如果集群操作员或其他终端用户可以部署一个组件的多个实例， 则选择名称前缀并挑选一种机制（例如 Deployment 名称的哈希）以避免 Lease 的名称冲突。

你可以使用另一种方式来达到相同的效果：不同的软件产品不相互冲突。

## Lease API

Lease 定义了一个租约的概念。

`apiVersion: coordination.k8s.io/v1`

`import "k8s.io/api/coordination/v1"`

### Lease

Lease 定义了一个租约的概念。

字段|描述
--------|--------
apiVersion string|APIVersion 定义了对象表示形式的版本化模式。服务器应将已识别的模式转换为最新的内部值，并可能拒绝无法识别的值。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
kind string|Kind 是一个字符串值，表示此对象所代表的 REST 资源。服务器可以根据客户端提交请求的端点推断此值。不可更新。采用驼峰命名法。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
metadata [ObjectMeta](https://kubernetes.io/docs/reference/kubernetes-api/definitions/object-meta-v1-meta/#ObjectMeta)|更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
spec [LeaseSpec](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#LeaseSpec)|spec 包含租约的规范。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

### LeaseSpec

LeaseSpec 是租约的规范。

字段|描述
--------|--------
acquireTime [MicroTime](https://kubernetes.io/docs/reference/kubernetes-api/definitions/micro-time-v1-meta/#MicroTime)|acquireTime 指的是当前租约的取得时间。
holderIdentity string|holderIdentity 包含当前租约持有者的身份信息。如果使用协调领导者选举，则持有者身份必须与当选的 `LeaseCandidate.metadata.name` 字段的值相同。
leaseDurationSeconds integer|leaseDurationSeconds 是租约候选人需要等待才能强制获得租约的时长。该时长是相对于上次观察到的 renewTime 时间计算的。 
leaseTransitions integer|leaseTransitions 是租约在不同持有人之间转换的次数。
preferredHolder string|PreferredHolder 向承租人发出信号，表明该承租权已有更合适的承租人，应放弃该承租权。只有在同时设置了 Strategy 字段后，才能设置此字段。
renewTime [MicroTime](https://kubernetes.io/docs/reference/kubernetes-api/definitions/micro-time-v1-meta/#MicroTime)|renewTime 是当前租约持有人上次更新租约的时间。
strategy string|策略字段指示用于选择协调领导者选举领导者的策略。如果未指定此字段，则此租约不进行任何协调。（Alpha）使用此字段需要启用“协调领导者选举”特性门。

### LeaseList

LeaseList 是租约对象列表。

字段|描述
--------|--------
apiVersion string|APIVersion 定义了对象表示形式的版本化模式。服务器应将已识别的模式转换为最新的内部值，并可能拒绝无法识别的值。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
items *[Lease array](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)|items 是模式对象列表。
kind string|Kind 是一个字符串值，表示此对象所代表的 REST 资源。服务器可以根据客户端提交请求的端点推断此值。不可更新。采用驼峰命名法。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
metadata [ListMeta](https://kubernetes.io/docs/reference/kubernetes-api/definitions/list-meta-v1-meta/#ListMeta)|标准列表元数据。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata。

### Operations
#### post Create

##### HTTP Request

`POST /apis/coordination.k8s.io/v1/namespaces/{namespace}/leases`

##### 路径参数

名字|类型|描述
--------|--------|--------
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。
dryRun|string|如果存在，则表示不应保存修改。无效或无法识别的 dryRun 指令将导致错误响应，并且不会进一步处理请求。有效值包括：- All：将处理所有 dryRun 阶段。
fieldManager|string|fieldManager 是与进行这些更改的参与者或实体关联的名称。该值长度必须小于 128 个字符，并且只能包含可打印字符，如 https://golang.org/pkg/unicode/#IsPrint 所定义。
fieldValidation|string|fieldValidation 指示服务器如何处理请求（POST/PUT/PATCH）中包含未知字段或重复字段的对象。有效值包括：`- Ignore`：此选项将忽略对象中静默丢弃的任何未知字段，并忽略解码器遇到的所有重复字段，但保留最后一个。这是 `v1.23` 之前的默认行为。`- Warn`：此选项将通过标准警告响应头发送警告，警告信息针对对象中丢弃的每个未知字段以及遇到的每个重复字段。如果没有其它错误，请求仍将成功，并且只会保留最后一个重复字段。这是 `v1.23` 及更高版本的默认行为。`- Strict`：此选项将使请求失败，并返回 BadRequest 错误，前提是对象中存在任何未知字段或重复字段。服务器返回的错误信息将包含所有遇到的未知字段和重复字段。

##### Body 参数

名字|类型|描述
--------|--------|--------
body|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)|


##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)
201|Created|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)
202|Accepted|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)

#### patch Patch

##### HTTP Request

`PATCH /apis/coordination.k8s.io/v1/namespaces/{namespace}/leases/{name}`

##### 路径参数

名字|类型|描述
--------|--------|--------
name|string|租约名
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。
dryRun|string|如果存在，则表示不应保存修改。无效或无法识别的 dryRun 指令将导致错误响应，并且不会进一步处理请求。有效值包括：- All：将处理所有 dryRun 阶段。
fieldManager|string|fieldManager 是与进行这些更改的参与者或实体关联的名称。该值长度必须小于 128 个字符，并且只能包含可打印字符，如 https://golang.org/pkg/unicode/#IsPrint 所定义。
fieldValidation|string|fieldValidation 指示服务器如何处理请求（POST/PUT/PATCH）中包含未知字段或重复字段的对象。有效值包括：`- Ignore`：此选项将忽略对象中静默丢弃的任何未知字段，并忽略解码器遇到的所有重复字段，但保留最后一个。这是 `v1.23` 之前的默认行为。`- Warn`：此选项将通过标准警告响应头发送警告，警告信息针对对象中丢弃的每个未知字段以及遇到的每个重复字段。如果没有其它错误，请求仍将成功，并且只会保留最后一个重复字段。这是 `v1.23` 及更高版本的默认行为。`- Strict`：此选项将使请求失败，并返回 BadRequest 错误，前提是对象中存在任何未知字段或重复字段。服务器返回的错误信息将包含所有遇到的未知字段和重复字段。
force|boolean|force 标志会强制执行应用请求。这意味着用户将重新获取其他用户拥有的冲突字段。对于非应用型补丁请求，必须取消设置 force 标志。

##### Body 参数

名字|类型|描述
--------|--------|--------
body|[Patch](https://kubernetes.io/docs/reference/kubernetes-api/definitions/patch-v1-meta/#Patch)|


##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)
201|Created|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)

#### put Replace

##### HTTP Request

`PUT /apis/coordination.k8s.io/v1/namespaces/{namespace}/leases/{name}`

##### 路径参数

名字|类型|描述
--------|--------|--------
name|string|租约名
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。
dryRun|string|如果存在，则表示不应保存修改。无效或无法识别的 dryRun 指令将导致错误响应，并且不会进一步处理请求。有效值包括：- All：将处理所有 dryRun 阶段。
fieldManager|string|fieldManager 是与进行这些更改的参与者或实体关联的名称。该值长度必须小于 128 个字符，并且只能包含可打印字符，如 https://golang.org/pkg/unicode/#IsPrint 所定义。
fieldValidation|string|fieldValidation 指示服务器如何处理请求（POST/PUT/PATCH）中包含未知字段或重复字段的对象。有效值包括：`- Ignore`：此选项将忽略对象中静默丢弃的任何未知字段，并忽略解码器遇到的所有重复字段，但保留最后一个。这是 `v1.23` 之前的默认行为。`- Warn`：此选项将通过标准警告响应头发送警告，警告信息针对对象中丢弃的每个未知字段以及遇到的每个重复字段。如果没有其它错误，请求仍将成功，并且只会保留最后一个重复字段。这是 `v1.23` 及更高版本的默认行为。`- Strict`：此选项将使请求失败，并返回 BadRequest 错误，前提是对象中存在任何未知字段或重复字段。服务器返回的错误信息将包含所有遇到的未知字段和重复字段。

##### Body 参数

名字|类型|描述
--------|--------|--------
body|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)|


##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)
201|Created|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)

#### delete Delete

##### HTTP Request

`DELETE /apis/coordination.k8s.io/v1/namespaces/{namespace}/leases/{name}`

##### 路径参数

名字|类型|描述
--------|--------|--------
name|string|租约名
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。
dryRun|string|如果存在，则表示不应保存修改。无效或无法识别的 dryRun 指令将导致错误响应，并且不会进一步处理请求。有效值包括：- All：将处理所有 dryRun 阶段。
gracePeriodSeconds|integer|对象删除前的等待时间（以秒为单位）。该值必须为非负整数。值为零表示立即删除。如果此值为 nil，则将使用指定类型的默认宽限期。如果未​​指定，则默认为每个对象设置一个值。零表示立即删除。
ignoreStoreReadErrorWithClusterBreakingPotential|boolean|如果设置为 true，则在正常删除流程因对象损坏错误而失败时，将触发资源的非安全删除。如果资源无法从底层存储中成功检索，则该资源被视为已损坏，原因可能是：a) 其数据无法转换（例如解密失败），或 b) 无法解码为对象。注意：非安全删除会忽略终结器约束，跳过前提条件检查，并从存储中移除对象。警告：如果与被非安全删除的资源关联的工作负载依赖于正常删除流程，则此操作可能会导致集群崩溃。仅在您真正了解自己在做什么的情况下才使用此功能。默认值为 false，用户必须选择启用此功能。
orphanDependents|boolean|已弃用：请使用 PropagationPolicy，此字段将在 1.7 版本中弃用。是否将依赖对象设为孤立对象。如果设置为 true/false，则会将“孤立”终结器添加到对象的终结器列表中，或从中移除该终结器。此字段和 PropagationPolicy 只能设置其中之一。
propagationPolicy|string|垃圾回收是否执行以及如何执行。此字段或 OrphanDependents 可以设置，但不能同时设置两者。默认策略由 metadata.finalizers 中设置的现有终结器以及资源特定的默认策略决定。可接受的值包括：'Orphan' - 将依赖项设为孤立；'Background' - 允许垃圾回收器在后台删除依赖项；'Foreground' - 级联策略，在前台删除所有依赖项。

##### Body 参数

名字|类型|描述
--------|--------|--------
body|[DeleteOptions](https://kubernetes.io/docs/reference/kubernetes-api/definitions/delete-options-v1-meta/#DeleteOptions)|

##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[Status](https://kubernetes.io/docs/reference/kubernetes-api/definitions/status-v1-meta/#Status)
202|Accepted|[Status](https://kubernetes.io/docs/reference/kubernetes-api/definitions/status-v1-meta/#Status)

#### delete Delete Collection

#### get Read

##### HTTP Request

`GET /apis/coordination.k8s.io/v1/namespaces/{namespace}/leases/{name}`

##### 路径参数

名字|类型|描述
--------|--------|--------
name|string|租约名
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。

##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[Lease](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/#Lease)

#### get List
#### get List All Namespaces

#### get Watch

##### HTTP Request

`GET /apis/coordination.k8s.io/v1/watch/namespaces/{namespace}/leases/{name}`

##### 路径参数

名字|类型|描述
--------|--------|--------
name|string|Lease 名字
namespace|string|对象名称和授权范围，例如团队和项目

##### 查询参数

名字|类型|描述
--------|--------|--------
allowWatchBookmarks|boolean|`allowWatchBookmarks` 请求监视类型为“BOOKMARK”的事件。未实现书签功能的服务器可能会忽略此标志，书签是否发送由服务器自行决定。客户端不应假定书签会按特定时间间隔返回，也不应假定服务器会在会话期间发送任何 BOOKMARK 事件。如果这不是监听请求，则此字段将被忽略。
continue|string|从服务器检索更多结果时，应设置 continue 选项。由于此值由服务器定义，客户端只能使用先前查询结果中具有相同查询参数（除了 continue 值之外）的 continue 值，并且服务器可能会拒绝它无法识别的 continue 值。如果指定的 continue 值不再有效（无论是由于过期（通常为 5 到 15 分钟）还是由于服务器配置更改），服务器将返回 410 ResourceExpired 错误以及一个 continue 令牌。如果客户端需要一致的列表，则必须重新开始列表请求，并且不包含 continue 字段。否则，客户端可以使用 410 错误中收到的令牌发送另一个列表请求，服务器将返回一个从下一个键开始的列表，但该列表基于最新的快照，这与之前的列表结果不一致——在第一次列表请求之后创建、修改或删除的对象，只要它们的键在“下一个键”之后，都将包含在响应中。当 watch 设置为 true 时，不支持此字段。客户端可以从服务器返回的最后一个 resourceVersion 值开始监视，这样就不会错过任何修改。
fieldSelector|string|用于按字段限制返回对象列表的选择器。默认值为所有字段。
labelSelector|string|用于按标签限制返回对象列表的选择器。默认值为所有字段。
limit|integer|`limit` 参数用于指定列表调用返回的最大响应数量。如果存在更多项目，服务器会将列表元数据中的 `continue` 字段设置为一个值，该值可用于相同的初始查询以检索下一组结果。如果所有请求的对象都被过滤掉，设置 `limit` 参数可能会返回少于请求的项目数量（最多为零个），客户端应仅使用 `continue` 字段的存在来判断是否有更多结果可用。服务器可以选择不支持 `limit` 参数，并返回所有可用结果。如果指定了 `limit` 参数且 `continue` 字段为空，则客户端可以假定没有更多结果可用。如果 `watch` 设置为 true，则不支持此字段。服务器保证，使用 `continue` 参数返回的对象与不使用 `limit` 参数发出单个列表调用时返回的对象完全相同——也就是说，在发出第一个请求之后创建、修改或删除的任何对象都不会包含在任何后续的 `continue` 请求中。这有时被称为一致性快照，它确保使用 `limit` 参数接收大量结果中较小块的客户端能够看到所有可能的对象。如果在分块列表过程中更新了对象，则返回计算第一个列表结果时存在的对象版本。
pretty|string|如果为“true”，则输出将以美观的方式打印。默认为“false”，除非用户代理指示的是浏览器或命令行HTTP工具（curl和wget）。
resourceVersion|string|resourceVersion 设置请求可以从哪些资源版本提供服务的限制。详情请参阅 https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions。默认值为 unset。
resourceVersionMatch|string|resourceVersionMatch 决定了 resourceVersion 如何应用于列表调用。强烈建议在设置了 `resourceVersion` 的列表调用中设置 resourceVersionMatch。详情请参阅 https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions。默认值为 unset。
sendInitialEvents|boolean|`sendInitialEvents=true` 可以与 `watch=true` 同时设置。在这种情况下，监视流会先发送合成事件来生成集合中对象的当前状态。所有此类事件发送完毕后，会发送一个合成的“书签”事件。该书签事件会报告与对象集对应的资源版本 (RV)，并带有 `"k8s.io/initial-events-end": "true"` 注解。之后，监视流会照常运行，发送与被监视对象（在资源版本之后）的更改相对应的监视事件。设置 `sendInitialEvents` 选项时，必须同时设置 `resourceVersionMatch` 选项。监视请求的语义如下：- `resourceVersionMatch` = NotOlderThan 表示“数据至少与提供的 `resourceVersion` 一样新”，当状态同步到至少与 ListOptions 提供的 `resourceVersion` 一样新的版本时，将发送书签事件。如果未设置 `resourceVersion`，则表示“一致性读取”，当状态同步到至少请求开始处理的时刻时，将发送书签事件。- `resourceVersionMatch` 设置为任何其他值或未设置时，将返回无效错误。如果 `resourceVersion=""` 或 `resourceVersion="0"`（出于向后兼容性考虑），则默认为 true，否则为 false。
shardSelector|string|shardSelector 使用基于 CEL 的分片选择器表达式来限制返回的对象列表。该格式使用 shardRange() 函数结合 ||（逻辑或）来指定一个或多个哈希范围：shardRange(object.metadata.uid, '0x0', '0x8000000000000000') shardRange(object.metadata.uid, '0x0', '0x8000000000000000') || `shardRange(object.metadata.uid, '0x8000000000000000', '0x10000000000000000')` 字段路径使用 CEL 风格的对象根语法（例如“object.metadata.uid”），而不是 fieldSelector 格式（“metadata.uid”）。当前支持的路径：- object.metadata.uid - object.metadata.namespace。`hexStart` 和 `hexEnd` 是带有“0x”前缀的单引号 CEL 字符串字面量，定义了 64 位 FNV-1a 哈希空间的包含下限和不包含上限。完整范围为 [0x0, 0x10000000000000000)，其中不包含上限等于 2^64。示例：2 分片拆分：分片 0：shardRange(object.metadata.uid, '0x0000000000000000', '0x8000000000000000') 分片 1：shardRange(object.metadata.uid, '0x8000000000000000', '0x10000000000000000') 4 分片拆分：分片 0：shardRange(object.metadata.uid, '0x0000000000000000', '0x4000000000000000') 分片 1：shardRange(object.metadata.uid,分片 2：shardRange(object.metadata.uid, '0x4000000000000000', '0x8000000000000000') 分片 3：shardRange(object.metadata.uid, '0x8000000000000000', '0xc000000000000000') 分片 3：shardRange(object.metadata.uid, '0xc000000000000000', '0x10000000000000000') 这是一个 alpha 字段，需要启用 ShardedListAndWatch 功能门。
timeoutSeconds|integer|列表/监视通话超时设置。此设置限制通话持续时间，无论通话期间是否有任何活动。
watch|boolean|监视所述资源的变更，并以添加、更新和删除通知流的形式返回这些变更。指定 resourceVersion。

##### 回复

名字|类型|描述
--------|--------|--------
200|OK|[WatchEvent](https://kubernetes.io/docs/reference/kubernetes-api/definitions/watch-event-v1-meta/#WatchEvent)

#### get Watch List
#### get Watch List All Namespaces


## 定义

### MicroTime
MicroTime 是具有毫秒级精度的时间版本. 

`apiVersion: meta/v1`

`import "k8s.io/apimachinery/pkg/apis/meta/v1"`


### WatchEvent
WatchEvent 代表被监视资源发生的单一事件。

`apiVersion: meta/v1`

`import "k8s.io/apimachinery/pkg/apis/meta/v1"`

字段|描述
--------|--------
object *|对象状态：* 如果类型为“已添加”或“已修改”：对象的最新状态。* 如果类型为“已删除”：对象删除前的状态。* 如果类型为“错误”：*建议使用状态；其他类型可能因上下文而异。
type *string|

### Patch

提供 Patch 参数是为了给 Kubernetes PATCH 请求体指定一个具体的名称和类型。

`apiVersion: meta/v1`

`import "k8s.io/apimachinery/pkg/apis/meta/v1"`

### Status
状态是那些不返回其它对象的调用的返回值。。

`apiVersion: meta/v1`

`import "k8s.io/apimachinery/pkg/apis/meta/v1"`

字段|描述
--------|--------
apiVersion string|APIVersion 定义了对象表示形式的版本化模式。服务器应将已识别的模式转换为最新的内部值，并可能拒绝无法识别的值。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources。
details [StatusDetails](https://kubernetes.io/docs/reference/kubernetes-api/definitions/status-details-v1-meta/#StatusDetails)|与原因相关的扩展数据。每个原因都可以定义自己的扩展详细信息。此字段为可选字段，返回的数据不保证符合除原因类型定义的模式之外的任何其它模式。
kind string|Kind 是一个字符串值，表示此对象所代表的 REST 资源。服务器可以根据客户端提交请求的端点推断此值。不可更新。采用驼峰命名法。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds。
message string|对该操作状态的通俗易懂的描述。
metadata [ListMeta](https://kubernetes.io/docs/reference/kubernetes-api/definitions/list-meta-v1-meta/#ListMeta)|标准列表元数据。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds。
reason string|描述此操作为何处于“失败”状态的机器可读信息。如果此值为空，则表示没有可用信息。原因信息用于解释 HTTP 状态代码，但不会覆盖该状态代码。
status string|操作状态。结果为：“成功”或“失败”。更多信息：https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status。

### Reference

- [Leases](https://kubernetes.io/docs/concepts/architecture/leases/)
- [Lease Object](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/lease-v1/)
- [Node Lease 对象](https://kubernetes.io/zh-cn/docs/concepts/architecture/nodes/#node-heartbeats)
- [Leasse API](https://kubernetes.io/docs/reference/kubernetes-api/coordination/lease-v1/)
- [Coordinated Leader Election](https://kubernetes.io/docs/concepts/cluster-administration/coordinated-leader-election/)
