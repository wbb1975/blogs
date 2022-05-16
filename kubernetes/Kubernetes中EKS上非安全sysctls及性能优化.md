## Kubernetes 中 EKS 上非安全　sysctls 及性能优化

### 什么是非安全的 sysctl 参数

在运行容器化负载的编排环境如 Kubernetes 中内核参数（运行 `sudo sysctl -a` 已查看其完整列表）可被分为安全的和非安全的。

一个安全的　sysctl 参数仅仅意味着该内核参数是“有命名空间的”，在一个内核命名空间（容器）的值并不反映一个内核命名空间（容器）的值，因此在底层容器运行时并不相互交互。一个安全的　sysctl 参数的例子是本地端口范围：`net.ipv4.ip_local_port_range`

相反，非安全的 sysctl 参数是“未命名空间的”，如果从　Pod　或容器内布修改，则可能潜在地引起问题。基于这个原因，默认情况下在一个　Kubernetes　集群中非安全的 sysctl 参数都是禁用的。

### 为什么启用非安全的 sysctl 参数

好问题！问题仅仅在于并非所有非安全的 sysctl 参数都是“非安全”的。实际上，随着新的内核版本和堆命名空间的新的支持的发布，越来愈多的　sysctl 参数会从“非安全”移到“安全”部分。某些仍处于“非安全”部分的内核参数可被调整以提高整体应用性能，尤其在以一个整体的历史观点仔细调优后。

一个自立，以我个人经验，是内核参数 `net.ipv4.tcp_tw_reuse`。这个参数允许内核复用处于 `TIME-WAIT`　状态的　sockets。默认情况下复用此类　sockets　是禁止的。对于一个服务于巨大流量的　Web　服务器来说，在任意时间找到大量处于此类状态的　sockets　并不罕见：

```
$ ss -alnpt | grep TIME-WAIT
...
...
TIME-WAIT   0        0               127.0.0.1:45448           127.0.0.1:7142                                                                                   
TIME-WAIT   0        0               127.0.0.1:42242           127.0.0.1:7142                                                                                   
TIME-WAIT   0        0               127.0.0.1:42554           127.0.0.1:7142                                                                                   
TIME-WAIT   0        0               127.0.0.1:44324           127.0.0.1:7142                                                                                   
TIME-WAIT   0        0               127.0.0.1:41880           127.0.0.1:7142                                                                                   
TIME-WAIT   0        0               127.0.0.1:43522           127.0.0.1:7142                                                                                   
...
...
```

对　Web　服务器来说不复用这些　sockets　可能导致慢连接以及性能下降。一个更值得说到的事情是如果从内核的　dmesg　输出中看到如下消息，就意味着你可能已经有了性能问题：

```
[250516.270111] TCP: request_sock_TCP: Possible SYN flooding on port 7142. Sending cookies.  Check SNMP counters.
```

### 在 EKS 上如何开启非安全的 sysctl 参数

虽然有 kubernetes官方的 [Using sysctls in a Kubernetes Cluster](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/#enabling-unsafe-sysctls)，当我在 EKS 上尝试开启它们时还是遇到了一些不同（也因此有了这篇博客）。

第一步是在一个　EKS　集群上对一个特定节点组（或者所有节点组）开启非安全的 sysctl 参数的一个子集。因为这些设置在 kubelet 中进行，所以这一步需要在节点组创建时进行。并且，如果你使用[受控　EKS　节点组](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)，没有直接的方式来实现这个。因此我不得不在 EKS 中创建一个非受控节点组。使用　[eksctl](https://eksctl.io/)来管理集群超级容易，我所有要做的事就是在新的[nodegroup section of the yaml](https://eksctl.io/usage/customizing-the-kubelet/)中包括下面的[配置](https://eksctl.io/usage/schema/)：

```
kubeletExtraConfig:
  allowedUnsafeSysctls:
    - "net.ipv4.tcp_tw_reuse"
```

随后，下一步是在 [pod security policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) 的 spec 中开启非安全的 sysctl 参数。

```
spec:
  allowedUnsafeSysctls:
  - net.ipv4.*
```

> 注意这里的通配符。这里它们是被允许的，但仅仅处于演示目的。在现实中，我们应该限制它于一个必须的最小 sysctls 中。

一旦上面两步做完，你可以自由地在 Pod 里面调整内核参数。仅仅设置你的　`deployment.spec.template.spec.securityContext` （或者如果你在直接使用　Pod，那么就是 `pod.spec.securityContext`）为：

```
sysctls:
  - name: net.ipv4.tcp_tw_reuse
    value: "1"
```

如果你在使用　[helm](https://helm.sh/) 来部署应用，你启动应用的默认　`helm chart` 应该在 `values.yaml` 中有一节　`podSecurityContext`，在其中你可以加入同样的代码段。

最后，一旦你的应用已经部署成功且带有以上调整，你可以使用 `sudo sysctl -a`　以验证以上参数是否已经生效。

### Reference
- [Of Kubernetes unsafe sysctls & performance optimization on EKS](https://itnext.io/of-kubernetes-unsafe-sysctls-performance-optimization-on-eks-d36cc0e3e894)ｓ