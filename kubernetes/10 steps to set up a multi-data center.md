# 10 steps to set up a multi-data center Cassandra cluster on a Kubernetes platform
Apache Cassandra是一款对当前应用拥有被证明过的容错特性，及可扩展的去中心化的 NoSQL 数据库。你可以在 `Docker` 容器上部署`Cassandra`，或者通过`Kubernetes`管理`Cassandra`。

在本教程中，你将学会如何使用Kubernetes跨多个数据中心（地理上相隔几英里）建立一个Cassandra集群，数据中心可以位于不同的国家或地区，使用这种设置的原因如下：
- 执行灾备（live backups）：写到一个数据中心的数据被异步拷贝到另一个数据中心
- 在一个地区的用户（比如美国）可以就近连接数据中心，在另一个地区的用户（比如说印度）同样就近连接数据中心以确保更快的性能
- 如果一个数据中心停止了，你任可用别的数据中心提供Cassandra 数据服务
- 如果一个数据中心的一些节点停止了，Cassandra数据任可用，服务不会中断

开源Kubernetes平台管理的Docker容器是这一切成为可能。
## 创建（Setup）
为了完成本教程中的步骤，你需要利用到Kubernetes 中的一些概念如[pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/), [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/), [headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services), 和[PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)等。下面是你所需要的：
- 一个Kubernetes 集群，带有分别位于两个数据中心的节点。确保Kubernetes 版本是V1.8.x或更高
- 每个数据中心至少有3个节点，Kubernetes 将在其上部署pods

图1显示了每个数据中心有5个节点，每个Kubernetes 节点部署一个Cassandra pod代表一个Cassandra 节点。应用程序pods部署于每个数据中心，它们利用无头服务访问本地（数据中心的）Cassandra 节点。写到一个数据中心的任何节点上的数据被异步拷贝到另一个数据中心。

图1：一个跨两个数据中心（每数据中心5节点）的Cassandra 集群
![Cassandra 集群](images/two_data_center_cassandra_cluster.png)
## 主意（The idea）
创建两个StatefulSets，一个数据中心一个。StatefulSet将管理一套pods的部署和缩放（scaling ），并保证这些pods的顺序和唯一性。StatefulSet 定义了节点亲缘性，如此一个StatefulSet 的pods仅仅部署在一个数据中心。这是通过在每个节点上设置标签实现的。给第一个数据中心的所有节点打上标签 `dc=DC1` ，给第而个数据中心的所有节点打上标签 `dc=DC2` 。这些将会是Cassandra 两个数据中心的种子节点，但如果你有5个节点，推荐设立两个种子节点。给Kubernetes 节点加上合适的标签.

**按数据中心给节点加标签**
```
kubectl label nodes nodea1 dc=DC1
kubectl label nodes nodea2 dc=DC1
kubectl label nodes nodea3 dc=DC1
kubectl label nodes nodeb1 dc=DC2
kubectl label nodes nodeb2 dc=DC2
kubectl label nodes nodeb3 dc=DC2
```
## 行动（The action）
本教程中的所有代码可在 [GitHub](https://github.com/ideagw/multi-dc-c7a-k8s) 上找到，克隆该仓库并从那里拷贝YAML 文件。
### 1. 创建名字空间
首先，创建一个名字空间，在哪里你将从事你所有的工作：
`kubectl create namespace c7a`
### 2. 创建无头服务
```
kubectl ‑n c7a create ‑f service.yaml
```
无头服务允许应用pods通过服务名连接到Cassandra pods。拥有两个无头服务，一个无头服务服务于一个数据中心的Cassandra Pods，另一个无头服务服务于另一个数据中心的Cassandra Pods。部署于每个数据中心的应用Pods可以利用环境变量来选择连接本地数据中心的Cassandra服务。
### 3. 创建持久卷（persistent volumes）
Cassandra 节点将数据存储到持久卷上，因为Cassandra 倾向于每个节点本地存储，你可以预先规划存储。总共有6个节点。首先，在每个节点上创建目录以存储Cassandra 数据，例如 `/data/cass/`。确保每个节点上该目录至少有10 GB空间可用。在每个数据中心的3个节点上创建该目录.

然后用GitHub上提供的YAML文件创建所有6个 `PersistentVolumes`，你可以根据需要调整目录的大小和位置：
```
kubectl ‑n c7a create ‑f local_pvs.yaml
```
### 4. 创建StatefulSets
在StatefulSet中定义的PVC将消费PV。创建两个StatefulSets（一个数据中心一个）。记住，第一个数据中心的每个节点带有 `dc=DC1` 标签，第二个数据中心的每个节点带有 `dc=DC2` 标签。StatefulSet 中的节点亲缘性spec被命名为`cassandra-a`确保pods 仅仅被调度到 `DC1` 数据中心，类似地，`cassandra-b StatefulSet`具有到 `DC2` 的亲缘性。所有使用那个StatefulSet 的pods 都被仅仅部署到DC2数据中心。
```
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        ‑ matchExpressions:
          ‑ key: dc
            operator: In
            values:
            ‑ DC1
```
StatefulSet 是Kubernetes中功能强大的构造设施。为了理解Pods如何部署和网络如何工作，你需要理解一些核心惯例：
#### 4.1 Pod 名字
StatefulSet 中Pod是顺序创建的，以第一个Pod的名字开始，以0结束。Pod名遵循下面的语义：`<statefulset name>-<ordinal index>`。本教程中，`DC1` 的Pod被命名为`cassandra-a-0`, `cassandra-a-1`, 和 `cassandra-a-2`；`DC2` 的Pod被命名为`cassandra-b-0`等等。
#### 4.2 网络地址
一个StatefulSet 可以利用无头服务来控制器Pods的域名。服务管理的域名形如 `$(service name).$(namespace).svc.cluster.local`，这里 `cluster.local` 是集群域名。当每个Pod被创建时，它得到其匹配的DNS 子域名，形如 `$(podname).$(service name).$(namespace).svc.cluster.local`。在本教程中，`DC1`中的pod拥有名字 `cassandra-a-0.cassandra-a.c7a.svc.cluster.local`，别的pod都遵循该命名规则。
#### 4.3 PVC
在StatefulSet 中PVC模板被命名为 `cassandra-data`。最终由该StatefulSet 生成的PVC将会被命名为格式 `$(volumeClaimTemplate name)-$(pod name)`。对于这些，StatefulSet 的部署将会创建VC，例如 `cassandra-data-cassandra-a-0` 和 `cassandra-data-cassandra-b-0`。VC匹配对应的Pod。由于使用静态规划，VC选择了它们期待的卷。
#### 4.4 Cassandra 配置
### 5. 创建名字空间
### 6. 创建名字空间
### 7. 创建名字空间
### 8. 创建名字空间
### 9. 创建名字空间
### 10. 创建名字空间
## 结论
## 可下载的资源
## 相关主题

## Reference
- [10 steps to set up a multi-data center Cassandra cluster on a Kubernetes platform](https://developer.ibm.com/tutorials/ba-multi-data-center-cassandra-cluster-kubernetes-platform/)
- [multi-dc-c7a-k8s](https://github.com/ideagw/multi-dc-c7a-k8s)