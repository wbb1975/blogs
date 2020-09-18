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
#### v1.18.0
[文档](https://docs.k8s.io/)
#### Downloads for v1.18.0
filename|sha512 hash
--------|--------
[kubernetes.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes.tar.gz)|cd5b86a3947a4f2cea6d857743ab2009be127d782b6f2eb4d37d88918a5e433ad2c7ba34221c34089ba5ba13701f58b657f0711401e51c86f4007cb78744dee7
[kubernetes-src.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-src.tar.gz)|fb42cf133355ef18f67c8c4bb555aa1f284906c06e21fa41646e086d34ece774e9d547773f201799c0c703ce48d4d0e62c6ba5b2a4d081e12a339a423e111e52
##### Client Binaries
filename|sha512 hash
--------|--------
[kubernetes-client-darwin-386.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-darwin-386.tar.gz)|26df342ef65745df12fa52931358e7f744111b6fe1e0bddb8c3c6598faf73af997c00c8f9c509efcd7cd7e82a0341a718c08fbd96044bfb58e80d997a6ebd3c2
[kubernetes-client-darwin-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-darwin-amd64.tar.gz)|803a0fed122ef6b85f7a120b5485723eaade765b7bc8306d0c0da03bd3df15d800699d15ea2270bb7797fa9ce6a81da90e730dc793ea4ed8c0149b63d26eca30
[kubernetes-client-linux-386.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-386.tar.gz)|110844511b70f9f3ebb92c15105e6680a05a562cd83f79ce2d2e25c2dd70f0dbd91cae34433f61364ae1ce4bd573b635f2f632d52de8f72b54acdbc95a15e3f0
[kubernetes-client-linux-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-amd64.tar.gz)|594ca3eadc7974ec4d9e4168453e36ca434812167ef8359086cd64d048df525b7bd46424e7cc9c41e65c72bda3117326ba1662d1c9d739567f10f5684fd85bee
[kubernetes-client-linux-arm.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-arm.tar.gz)|d3627b763606557a6c9a5766c34198ec00b3a3cd72a55bc2cb47731060d31c4af93543fb53f53791062bb5ace2f15cbaa8592ac29009641e41bd656b0983a079
[kubernetes-client-linux-arm64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-arm64.tar.gz)|ba9056eff1452cbdaef699efbf88f74f5309b3f7808d372ebf6918442d0c9fea1653c00b9db3b7626399a460eef9b1fa9e29b827b7784f34561cbc380554e2ea
[kubernetes-client-linux-ppc64le.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-ppc64le.tar.gz)|f80fb3769358cb20820ff1a1ce9994de5ed194aabe6c73fb8b8048bffc394d1b926de82c204f0e565d53ffe7562faa87778e97a3ccaaaf770034a992015e3a86
[kubernetes-client-linux-s390x.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-linux-s390x.tar.gz)|a9b658108b6803d60fa3cd4e76d9e58bf75201017164fe54054b7ccadbb68c4ad7ba7800746940bc518d90475e6c0a96965a26fa50882f4f0e56df404f4ae586
[kubernetes-client-windows-386.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-windows-386.tar.gz)|18adffab5d1be146906fd8531f4eae7153576aac235150ce2da05aee5ae161f6bd527e8dec34ae6131396cd4b3771e0d54ce770c065244ad3175a1afa63c89e1
[kubernetes-client-windows-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-client-windows-amd64.tar.gz)|162396256429cef07154f817de2a6b67635c770311f414e38b1e2db25961443f05d7b8eb1f8da46dec8e31c5d1d2cd45f0c95dad1bc0e12a0a7278a62a0b9a6b
##### Server Binaries
filename|sha512 hash
--------|--------
[kubernetes-server-linux-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-server-linux-amd64.tar.gz)|a92f8d201973d5dfa44a398e95fcf6a7b4feeb1ef879ab3fee1c54370e21f59f725f27a9c09ace8c42c96ac202e297fd458e486c489e05f127a5cade53b8d7c4
[kubernetes-server-linux-arm.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-server-linux-arm.tar.gz)|62fbff3256bc0a83f70244b09149a8d7870d19c2c4b6dee8ca2714fc7388da340876a0f540d2ae9bbd8b81fdedaf4b692c72d2840674db632ba2431d1df1a37d
[kubernetes-server-linux-arm64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-server-linux-arm64.tar.gz)|842910a7013f61a60d670079716b207705750d55a9e4f1f93696d19d39e191644488170ac94d8740f8e3aa3f7f28f61a4347f69d7e93d149c69ac0efcf3688fe
[kubernetes-server-linux-ppc64le.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-server-linux-ppc64le.tar.gz)|95c5b952ac1c4127a5c3b519b664972ee1fb5e8e902551ce71c04e26ad44b39da727909e025614ac1158c258dc60f504b9a354c5ab7583c2ad769717b30b3836
[kubernetes-server-linux-s390x.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-server-linux-s390x.tar.gz)|a46522d2119a0fd58074564c1fa95dd8a929a79006b82ba3c4245611da8d2db9fd785c482e1b61a9aa361c5c9a6d73387b0e15e6a7a3d84fffb3f65db3b9deeb
##### Node Binaries
filename|sha512 hash
--------|--------
[kubernetes-node-linux-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-linux-amd64.tar.gz)|f714f80feecb0756410f27efb4cf4a1b5232be0444fbecec9f25cb85a7ccccdcb5be588cddee935294f460046c0726b90f7acc52b20eeb0c46a7200cf10e351a
[kubernetes-node-linux-arm.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-linux-arm.tar.gz)|806000b5f6d723e24e2f12d19d1b9b3d16c74b855f51c7063284adf1fcc57a96554a3384f8c05a952c6f6b929a05ed12b69151b1e620c958f74c9600f3db0fcb
[kubernetes-node-linux-arm64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-linux-arm64.tar.gz)|c207e9ab60587d135897b5366af79efe9d2833f33401e469b2a4e0d74ecd2cf6bb7d1e5bc18d80737acbe37555707f63dd581ccc6304091c1d98dafdd30130b7
[kubernetes-node-linux-ppc64le.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-linux-ppc64le.tar.gz)|a542ed5ed02722af44ef12d1602f363fcd4e93cf704da2ea5d99446382485679626835a40ae2ba47a4a26dce87089516faa54479a1cfdee2229e8e35aa1c17d7
[kubernetes-node-linux-s390x.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-linux-s390x.tar.gz)|651e0db73ee67869b2ae93cb0574168e4bd7918290fc5662a6b12b708fa628282e3f64be2b816690f5a2d0f4ff8078570f8187e65dee499a876580a7a63d1d19
[kubernetes-node-windows-amd64.tar.gz](https://dl.k8s.io/v1.18.0/kubernetes-node-windows-amd64.tar.gz)|d726ed904f9f7fe7e8831df621dc9094b87e767410a129aa675ee08417b662ddec314e165f29ecb777110fbfec0dc2893962b6c71950897ba72baaa7eb6371ed
#### Changelog since v1.17.0
A complete changelog for the release notes is now hosted in a customizable format at https://relnotes.k8s.io. Check it out and please give us your feedback!
#### What’s New (Major Themes) 
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
Minikube 是一种可以让你在本地轻松运行 Kubernetes 的工具。 Minikube 在笔记本电脑上的虚拟机（VM）中运行单节点 Kubernetes 集群， 供那些希望尝试 Kubernetes 或进行日常开发的用户使用。
#### 2.1.1 Minikube 功能
Minikube 支持以下 Kubernetes 功能：
- DNS
- NodePorts
- ConfigMaps 和 Secrets
- Dashboards
- 容器运行时: Docker、[CRI-O](https://github.com/kubernetes-incubator/cri-o) 以及 [containerd](https://github.com/containerd/containerd)
- 启用 CNI （容器网络接口）
- Ingress
#### 2.1.2 安装
请参阅[安装 Minikube](https://kubernetes.io/zh/docs/tasks/tools/install-minikube/)
#### 2.1.3 快速开始
这个简短的演示将指导你如何在本地启动、使用和删除 Minikube。请按照以下步骤开始探索 Minikube。

#### 2.1.4 管理你的集群
#### 2.1.5 与集群交互
#### 2.1.6 网络
#### 2.1.7 持久卷（PersistentVolume）
#### 2.1.8 挂载宿主机文件夹
#### 2.1.9 私有容器镜像仓库 
#### 2.1.10 附加组件
#### 2.1.11 基于 HTTP 代理使用 Minikube
#### 2.1.12 已知的问题 
#### 2.1.13 设计
#### 2.1.14 其他链接
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