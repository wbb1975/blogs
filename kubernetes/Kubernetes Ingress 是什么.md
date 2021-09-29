# Kubernetes Ingress 是什么？
**Kubernetes Ingress 是一个 API 对象，它提供路由规则来管理外部用户对 Kubernetes 集群内的服务的访问**。

在本文中，我们就爱你改查看为什么以及如何暴露一个应用到你的Kubernetes集群之外，有哪些可选的方法，以及在哪些场景下Kubernetes Ingress 是最合适的。

本文假设你对 Kubernetes 由基本的了解，但如果你需要更多的信息，可以试试下面的资源：
[What is Kubernetes?](https://www.ibm.com/cloud/learn/kubernetes)
[Kubernetes Clusters: Architecture for Rapid, Controlled Cloud App Delivery](https://www.ibm.com/cloud/blog/kubernetes-clusters-architecture-for-rapid-controlled-cloud-app-delivery)
[Kubernetes Explained: Watch the video](https://www.youtube.com/embed/aSrqRSk43lY)
## 暴露部署在 Kubernetes 中的应用的选项
有几种方式可将你的应用暴露到Kubernetes集群之外，你会基于你的特殊用例选择一个合适的。

本文中我们讲将比较四种方式：**ClusterIP, NodePort, LoadBalancer, 和 Ingress**。每一种都提供了暴露服务的方式，适用于不同的情况。一个服务本质是你的应用的前端，它自动将流量平均路由到可用的 Pod 上。服务作为一个网络服务，是一种将运行于一系列 Pod 上的应用导出的一种抽象方式。Pod 是不可变的，这意味着当它们死亡时，它们并不会复活。一旦一个 Pod 死亡，Kubernetes集群将会在同一个节点或一个新结点上创建一个新的 Pod。

就像  pods 和 deployments一样，services 也是 Kubernetes 的资源。一个服务提供了从 Kubernetes 集群外部的一个单点访问，允许你动态访问一组副本 Pod。

对一个 Kubernetes 集群内部的内部应用访问，**ClusterIP** 是更好的选择。它是 Kubernetes 的默认设置，并使用一个内部 IP 地址来访问服务。 

要暴露服务给外部网络访问，odePort, LoadBalancer, 和 Ingress 是可能的选项。我们将首先查看 Ingress，本文稍后我们将比较服务。
## 什么是 Kubernetes Ingress， 为什么它有用？
Kubernetes Ingress 是一个 API 对象，它提供路由规则来管理外部用户对 Kubernetes 集群内的服务的访问，典型地通过 HTTPS/HTTP。利用 Ingress，你可以很容易地制定流量路由规则，而不需要创建一大堆负载均衡器或在节点上暴露每一个服务。这使它成为产品环境使用的最佳选择。

在产品环境中，通常你需要基于内容的路由，支持多种协议及认证。Ingress 允许你在进群内配置和管理这些能力。

Ingress 由一个 Ingress API 对象以及一个 Ingress Controller（控制器）构成。正如我们谈到过的，Kubernetes Ingress 是一个 API 对象，它描述了导出到 Kubernetes 集群外部的服务的期待状态。一个 Ingress 控制器是非常关键的，因为它是 Ingress API 的实际实现。一个 Ingress 控制器读取并处理 Ingress 资源信息，通常在 Kubernetes 集群内以 Pod 的形式运行。

一个 Ingress 提供了下面这些：
- 对部署于 Kubernetes 集群内的应用的外部可访问 URL
- 基于命名的虚拟主机和基于地址（URI）的路由支持
- 负载均衡规则和流量，以及 SSL 终止

对 Kubernetes Ingress 的一个快速可视化概览，参考下面的视频：[视频](https://www.youtube.com/embed/NPFbYpb0I7w)
## 什么是 Ingress Controller？
如果Kubernetes Ingress 是一个 API 对象，它提供路由规则来管理外部用户对服务的访问，那么 Ingress控制器就是 Ingress API 的实际实现。Ingress控制器通常是一个路由外部流量到你的Kubernetes 集群的一个负载均衡器，用于负责 L4-L7 网络服务。


## Ingress vs. ClusterIP vs. NodePort vs. LoadBalancer 
## 总结

## Reference
- [What is Kubernetes Ingress?](https://www.ibm.com/cloud/blog/kubernetes-ingress)