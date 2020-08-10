# 入门
本节介绍了设置和运行 Kubernetes 环境的不同选项。

不同的 Kubernetes 解决方案满足不同的要求：易于维护、安全性、可控制性、可用资源以及操作和管理 Kubernetes 集群所需的专业知识。

可以在本地机器、云、本地数据中心上部署 Kubernetes 集群，或选择一个托管的 Kubernetes 集群。还可以跨各种云提供商或裸机环境创建自定义解决方案。

更简单地说，可以在学习和生产环境中创建一个 Kubernetes 集群。

**学习环境**

如果正打算学习 Kubernetes，请使用基于 Docker 的解决方案：Docker 是 Kubernetes 社区支持或生态系统中用来在本地计算机上设置 Kubernetes 集群的一种工具。

**生产环境**

在评估生产环境的解决方案时，请考虑要管理自己 Kubernetes 集群（抽象层面）的哪些方面或将其转移给提供商。

[Kubernetes 合作伙伴](https://kubernetes.io/partners/#conformance)包括一个[已认证的 Kubernetes](https://github.com/cncf/k8s-conformance/#certified-kubernetes)提供商列表。
## 1. Kubernetes 发行说明和版本偏差
### 1.1 v1.18 发布说明
### 1.2 Kubernetes 版本及版本倾斜支持策略
本文描述 Kubernetes 各组件之间版本倾斜支持策略。 特定的集群部署工具可能会有额外的限制。
#### 1.2.1 版本支持策略
Kubernetes 版本号格式为 x.y.z，其中 x 为大版本号，y 为小版本号，z 为补丁版本号。 版本号格式遵循 [Semantic Versioning](http://semver.org/) 规则。 更多信息，请参阅 [Kubernetes Release Versioning](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/release/versioning.md#kubernetes-release-versioning)。

Kubernetes 项目会维护最近的三个小版本分支。

一些 bug 修复，包括安全修复，根据其安全性和可用性，有可能会回合到这些分支。 补丁版本会定期或根据需要从这些分支中发布。 最终是否发布是由[patch release team](https://github.com/kubernetes/sig-release/blob/master/release-engineering/role-handbooks/patch-release-manager.md#release-timing)来决定的。Patch release team同时也是[release managers](https://github.com/kubernetes/sig-release/blob/master/release-managers.md). 如需了解更多信息，请查看[Kubernetes Patch releases](https://github.com/kubernetes/sig-release/blob/master/releases/patch-releases.md).

小版本大约每3个月发布一个，所以每个小版本分支会维护9个月。
#### 1.2.2 版本倾斜策略
##### kube-apiserver
在[高可用（HA）集群](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)中， 多个 kube-apiserver 实例小版本号最多差1。

例如：
- 最新的 kube-apiserver 版本号如果是 1.13
- 其他 kube-apiserver 版本号只能是 1.13 或 1.12
##### kubelet
kubelet 版本号不能高于 kube-apiserver，最多可以比 kube-apiserver 低两个小版本。

例如：
- kube-apiserver 版本号如果是 1.13
- kubelet 只能是 1.13 、 1.12 和 1.11

> **说明**： 如果HA集群中多个 kube-apiserver 实例版本号不一致，相应的 kubelet 版本号可选范围也要减小。

例如：
- 如果 kube-apiserver 的多个实例同时存在 1.13 和 1.12
- kubelet 只能是 1.12 或 1.11（1.13 不再支持，因为它比1.12版本的 kube-apiserver 更新）
##### kube-controller-manager、 kube-scheduler 和 cloud-controller-manager
kube-controller-manager、kube-scheduler 和 cloud-controller-manager 版本不能高于 kube-apiserver 版本号。 最好它们的版本号与 kube-apiserver 保持一致，但允许比 kube-apiserver 低一个小版本（为了支持在线升级）。

例如：
- 如果 kube-apiserver 版本号为 1.13
- kube-controller-manager、kube-scheduler 和 cloud-controller-manager 版本支持 1.13 和 1.12

> **说明**： 如果在 HA 集群中，多个 `kube-apiserver` 实例版本号不一致，他们也可以跟任意一个 `kube-apiserver` 实例通信（例如，通过 load balancer），
但 kube-controller-manager、kube-scheduler 和 cloud-controller-manager 版本可用范围会相应的减小。

例如：
- kube-apiserver 实例同时存在 1.13 和 1.12 版本
- kube-controller-manager、kube-scheduler 和 cloud-controller-manager 可以通过 load balancer 与所有的 kube-apiserver 通信
- kube-controller-manager、kube-scheduler 和 cloud-controller-manager 可选版本为 1.12（1.13 不再支持，因为它比 1.12 版本的 kube-apiserver 更新）
##### kubectl
kubectl 可以比 kube-apiserver 高一个小版本，也可以低一个小版本。

例如：
- 如果 kube-apiserver 当前是 1.13 版本
- kubectl 则支持 1.14 、1.13 和 1.12

> **说明**：如果 HA 集群中的多个 kube-apiserver 实例版本号不一致，相应的 kubectl 可用版本范围也会减小。

例如：
- kube-apiserver 多个实例同时存在 1.13 和 1.12
- kubectl 可选的版本为 1.13 和 1.12（其他版本不再支持，因为它会比其中某个 kube-apiserver 实例高或低一个小版本）
#### 1.2.3 支持的组件升级次序
组件之间支持的版本倾斜会影响组件升级的顺序。 本节描述组件从版本 1.n 到 1.(n+1) 的升级次序。
##### kube-apiserver
前提条件：
- 单实例集群时，kube-apiserver 实例版本号须是 1.n
- HA 集群时，所有的 kube-apiserver 实例版本号必须是 1.n 或 1.(n+1)（确保满足最新和最旧的实例小版本号相差不大于1）
- kube-controller-manager、kube-scheduler 和 cloud-controller-manager 版本号必须为 1.n（确保不高于 API server 的版本，且版本号相差不大于1）
- kubelet 实例版本号必须是 1.n 或 1.(n-1)（确保版本号不高于 API server，且版本号相差不大于2）
- 注册的 admission 插件必须能够处理新的 kube-apiserver 实例发送过来的数据：
  + ValidatingWebhookConfiguration 和 MutatingWebhookConfiguration 对象必须升级到可以处理 1.(n+1) 版本新加的 REST 资源(或使用1.15版本提供的 matchPolicy: Equivalent 选项)
  + 插件可以处理任何 1.(n+1) 版本新的 REST 资源数据和新加的字段

升级 kube-apiserver 到 1.(n+1)

> **说明**： 跟据 [API deprecation](/docs/reference/using-api/deprecation-policy/) 和 [API change guidelines](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md) 规则，kube-apiserver 不能跳过小版本号升级，即使是单实例集群也不可以。
##### kube-controller-manager、 kube-scheduler 和 cloud-controller-manager
前提条件：
- kube-apiserver 实例必须为 1.(n+1) （HA 集群中，所有的kube-apiserver 实例必须在组件升级前完成升级）

升级 kube-controller-manager、kube-scheduler 和 cloud-controller-manager 到 1.(n+1)
##### kubelet
前提条件：
- kube-apiserver 实例必须为 1.(n+1) 版本

kubelet 可以升级到 1.(n+1)（或者停留在 1.n 或 1.(n-1)）

> **警告**： 集群中 `kubelet` 版本号不建议比 `kube-apiserver` 低两个版本号：
> - 他们必须升级到与 kube-apiserver 相差不超过1个小版本，才可以升级其他控制面组件
> - 有可能使用低于3个在维护的小版本
## 2. 学习环境
### 2.1 使用 Minikube 安装 Kubernetes
## 3. 使用 kubeadm 创建一个单主集群
## 4. 生产环境
### 4.1 容器运行时
### 4.2 Turnkey 云解决方案
### 4.3 使用部署工具安装 Kubernetes
### 4.4 本地 VMs
### 4.5 Windows Kubernetes
## 5. 最佳实践
### 5.1 创建大型集群
### 5.2 校验节点设置
### 5.3 PKI 证书和要求

## Reference
- [入门](https://kubernetes.io/zh/docs/setup/)
- [Getting started](https://kubernetes.io/docs/setup/)