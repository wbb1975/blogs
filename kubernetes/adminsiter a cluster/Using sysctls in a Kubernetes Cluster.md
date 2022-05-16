## Using sysctls in a Kubernetes Cluster

本文档介绍如何通过 `sysctl` 接口在 Kubernetes 集群中配置和使用内核参数。
> 从 Kubernetes 1.23 版本开始，kubelet 支持使用 / 或 . 作为 sysctl 参数的分隔符。 例如，你可以使用点或者斜线作为分隔符表示相同的 sysctl 参数，以点作为分隔符表示为：kernel.shm_rmid_forced，或者以斜线作为分隔符表示为：kernel/shm_rmid_forced。更多 sysctl 参数转换方法详情请参考 [Linux man-pages sysctl.d(5)](https://man7.org/linux/man-pages/man5/sysctl.d.5.html) 。设置 Pod 的 sysctl 参数和 `PodSecurityPolicy` 功能尚不支持设置包含斜线的 sysctl 参数。

### 开始之前

你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 建议在至少有两个节点的集群上运行本教程，且这些节点不作为控制平面主机。 如果你还没有集群，你可以通过 Minikube 构建一个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：

- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [玩转 Kubernetes](http://labs.play-with-k8s.com/)

对一些步骤，你需要能够重新配置在你的集群里运行的 kubelet 命令行的选项。

### 获取 Sysctl 的参数列表

在 Linux 中，管理员可以通过 sysctl 接口修改内核运行时的参数。在 `/proc/sys/` 虚拟文件系统下存放许多内核参数。这些参数涉及了多个内核子系统，如：

- 内核子系统（通常前缀为: kernel.）
- 网络子系统（通常前缀为: net.）
- 虚拟内存子系统（通常前缀为: vm.）
- MDADM 子系统（通常前缀为: dev.）
- 更多子系统请参见[内核文档](https://www.kernel.org/doc/Documentation/sysctl/README)。

若要获取完整的参数列表，请执行以下命令: 
```
sudo sysctl -a
```

### 启用非安全的 Sysctl 参数

sysctl 参数分为 **安全**和**非安全**的。 安全 sysctl 参数除了需要设置恰当的命名空间外，在同一 node 上的不同 Pod 之间也必须是相互隔离的。这意味着在 Pod 上设置安全 sysctl 参数: 

- 必须不能影响到节点上的其他 Pod
- 必须不能损害节点的健康
- 必须不允许使用超出 Pod 的资源限制的 CPU 或内存资源。

至今为止，大多数有命名空间的 sysctl 参数不一定被认为是**安全**的。 以下几种 sysctl 参数是安全的：

- kernel.shm_rmid_forced
- net.ipv4.ip_local_port_range
- net.ipv4.tcp_syncookies
- net.ipv4.ping_group_range （从 Kubernetes 1.18 开始）
- net.ipv4.ip_unprivileged_port_start （从 Kubernetes 1.22 开始）。

> 示例中的 net.ipv4.tcp_syncookies 在Linux 内核 4.4 或更低的版本中是无命名空间的。

在未来的 Kubernetes 版本中，若 kubelet 支持更好的隔离机制，则上述列表中将会 列出更多**安全**的 sysctl 参数。

所有 安全的 sysctl 参数都默认启用。

所有 非安全的 sysctl 参数都默认禁用，且必须由集群管理员在每个节点上手动开启。那些设置了不安全 sysctl 参数的 Pod 仍会被调度，但无法正常启动。

参考上述警告，集群管理员只有在一些非常特殊的情况下（如：高可用或实时应用调整），才可以启用特定的 **非安全**的 sysctl 参数。 如需启用非安全的 sysctl 参数，请你在每个节点上分别设置 kubelet 命令行参数，例如：

```
kubelet --allowed-unsafe-sysctls  'kernel.msg*,net.core.somaxconn' ...
```

如果你使用 Minikube，可以通过 extra-config 参数来配置：
```
minikube start --extra-config="kubelet.allowed-unsafe-sysctls=kernel.msg*,net.core.somaxconn"...
```

只有 有命名空间的 `sysctl` 参数可以通过该方式启用。

### 设置 Pod 的 Sysctl 参数

目前，在 Linux 内核中，有许多的 sysctl 参数都是**有命名空间的**。 这就意味着可以为节点上的每个 Pod 分别去设置它们的 sysctl 参数。 在 Kubernetes 中，只有那些有命名空间的 sysctl 参数可以通过 Pod 的 `securityContext` 对其进行配置。

以下列出有命名空间的 sysctl 参数，在未来的 Linux 内核版本中，此列表可能会发生变化：

- kernel.shm*,
- kernel.msg*,
- kernel.sem,
- fs.mqueue.*,
- net.*（内核中可以在容器命名空间里被更改的网络配置项相关参数）。然而也有一些特例 （例如，`net.netfilter.nf_conntrack_max` 和 `net.netfilter.nf_conntrack_expect_max` 可以在容器命名空间里被更改，但它们是非命名空间的）。

没有命名空间的 sysctl 参数称为 **节点级别**的 sysctl 参数。 如果需要对其进行设置，则必须在每个节点的操作系统上手动地去配置它们，或者通过在 `DaemonSet` 中运行特权模式容器来配置。

可使用 Pod 的 `securityContext` 来配置**有命名空间**的 sysctl 参数，`securityContext` 应用于同一个 Pod 中的所有容器。

此示例中，使用 `Pod SecurityContext` 来对一个安全的 sysctl 参数 `kernel.shm_rmid_forced` 以及两个非安全的 sysctl 参数 `net.core.somaxconn` 和 `kernel.msgmax` 进行设置。 在 Pod 规约中对**安全的**和**非安全的** sysctl 参数不做区分。

> 警告: 为了避免破坏操作系统的稳定性，请你在了解变更后果之后再修改 sysctl 参数。

```
apiVersion: v1
kind: Pod
metadata:
  name: sysctl-example
spec:
  securityContext:
    sysctls:
    - name: kernel.shm_rmid_forced
      value: "0"
    - name: net.core.somaxconn
      value: "1024"
    - name: kernel.msgmax
      value: "65536"
  ...
```

> 警告: 由于 **非安全的** sysctl 参数其本身具有不稳定性，在使用**非安全的** sysctl 参数 时可能会导致一些严重问题，如容器的错误行为、机器资源不足或节点被完全破坏，用户需自行承担风险。

最佳实践方案是将集群中具有特殊 sysctl 设置的节点视为**有污点的**，并且只调度需要使用到特殊 sysctl 设置的 Pod 到这些节点上。建议使用 Kubernetes 的[污点和容忍度特性](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#taint)来实现它。

设置了 非安全的 sysctl 参数的 Pod 在禁用了这两种**非安全的** sysctl 参数配置的节点上启动都会失败。与**节点级别的** sysctl 一样，建议开启[污点和容忍度特性](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#taint) 或 [为节点配置污点](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/taint-and-toleration/) 以便将 Pod 调度到正确的节点之上。

### PodSecurityPolicy

你可以通过在 PodSecurityPolicy 的 `forbiddenSysctls` 和/或 `allowedUnsafeSysctls` 字段中，指定 sysctl 或填写 sysctl 匹配模式来进一步为 Pod 设置 sysctl 参数。 sysctl 参数匹配模式以 `*` 字符结尾，如 `kernel.*`。 单独的 `*` 字符匹配所有 sysctl 参数。

所有 安全的 sysctl 参数都默认启用。

`forbiddenSysctls` 和 `allowedUnsafeSysctls` 的值都是字符串列表类型， 可以添加 sysctl 参数名称，也可以添加 sysctl 参数匹配模式（以 `*` 结尾）。 只填写 `*` 则匹配所有的 sysctl 参数。

如果要在 `allowedUnsafeSysctls` 字段中指定一个非安全的 sysctl 参数， 并且它在 `forbiddenSysctls` 字段中未被禁用，则可以在 Pod 中通过 PodSecurityPolicy 启用该 sysctl 参数。 若要在 PodSecurityPolicy 中开启所有非安全的 sysctl 参数， 请设 `allowedUnsafeSysctls` 字段值为 `*`。

`allowedUnsafeSysctls` 与 `forbiddenSysctls` 两字段的配置不能重叠， 否则这就意味着存在某个 sysctl 参数既被启用又被禁用。

> 警告: 如果你通过 PodSecurityPolicy 中的 `allowedUnsafeSysctls` 字段将非安全的 sysctl 参数列入白名单，但该 sysctl 参数未通过 kubelet 命令行参数 `--allowed-unsafe-sysctls` 在节点上将其列入白名单，则设置了这个 sysctl 参数的 Pod 将会启动失败。

以下示例设置启用了以 `kernel.msg` 为前缀的非安全的 sysctl 参数，同时禁用了 sysctl 参数 `kernel.shm_rmid_forced`：

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: sysctl-psp
spec:
  allowedUnsafeSysctls:
  - kernel.msg*
  forbiddenSysctls:
  - kernel.shm_rmid_forced
 ...
```

### Reference
- [Using sysctls in a Kubernetes Cluster](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/)