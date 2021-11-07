## 自定义 DNS 服务
本页说明如何配置 DNS Pod(s)，以及定制集群中 DNS 解析过程。
### 1. 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/tasks/tools/#minikube) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [玩转 Kubernetes](http://labs.play-with-k8s.com/)

您的 Kubernetes 服务器版本必须不低于版本 v1.12. 要获知版本信息，请输入 `kubectl version`。

你的集群必须运行 CoreDNS 插件。 文档[迁移到 CoreDNS](https://kubernetes.io/zh/docs/tasks/administer-cluster/coredns/#migrating-to-coredns) 解释了如何使用 `kubeadm` 从 `kube-dns` 迁移到 CoreDNS。
### 2. 介绍
DNS 是使用[集群插件](https://releases.k8s.io/main/cluster/addons/README.md)管理器自动启动的内置的 Kubernetes 服务。

从 Kubernetes v1.12 开始，CoreDNS 是推荐的 DNS 服务器，取代了 `kube-dns`。如果你的集群原来使用 `kube-dns`，你可能部署的仍然是 `kube-dns` 而不是 CoreDNS。
> **说明**： CoreDNS 和 kube-dns 的 Service 都在其 `metadata.name` 字段使用名字 `kube-dns`。 这是为了能够与依靠传统 kube-dns 服务名称来解析集群内部地址的工作负载具有更好的互操作性。 使用 kube-dns 作为服务名称可以抽离共有名称之后运行的是哪个 DNS 提供程序这一实现细节。

如果你在使用 Deployment 运行 CoreDNS，则该 Deployment 通常会向外暴露为一个具有静态 IP 地址 Kubernetes 服务。 kubelet 使用 `--cluster-dns=<DNS 服务 IP>` 标志将 DNS 解析器的信息传递给每个容器。

DNS 名称也需要域名。 你可在 kubelet 中使用 `--cluster-domain=<默认本地域名>` 标志配置本地域名。

DNS 服务器支持正向查找（A 和 AAAA 记录）、端口发现（SRV 记录）、反向 IP 地址发现（PTR 记录）等。更多信息，请参见[Pod 和 服务的 DNS](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)。

如果 Pod 的 `dnsPolicy` 设置为 "default"，则它将从 Pod 运行所在节点继承名称解析配置。 Pod 的 DNS 解析行为应该与节点相同。 但请参阅[已知问题](https://kubernetes.io/zh/docs/tasks/administer-cluster/dns-debugging-resolution/#known-issues)。

如果你不想这样做，或者想要为 Pod 使用其他 DNS 配置，则可以 使用 kubelet 的 `--resolv-conf` 标志。将此标志设置为 "" 可以避免 Pod 继承 DNS。 将其设置为有别于 `/etc/resolv.conf` 的有效文件路径可以设定 DNS 继承不同的配置。
### 3. CoreDNS
CoreDNS 是通用的权威 DNS 服务器，可以用作集群 DNS，符合 [DNS 规范](https://github.com/kubernetes/dns/blob/master/docs/specification.md)。
#### CoreDNS ConfigMap 选项
CoreDNS 是模块化且可插拔的 DNS 服务器，每个插件都为 CoreDNS 添加了新功能。 可以通过维护 [Corefile](https://coredns.io/2017/07/23/corefile-explained/)，即 CoreDNS 配置文件， 来定制其行为。 集群管理员可以修改 CoreDNS Corefile 的 ConfigMap，以更改服务发现的工作方式。

在 Kubernetes 中，CoreDNS 安装时使用如下默认 Corefile 配置。
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }    
```
Corefile 配置包括以下 CoreDNS [插件](https://coredns.io/plugins/)：
- [errors](https://coredns.io/plugins/errors/)：错误记录到标准输出。
- [health](https://coredns.io/plugins/health/)：在 http://localhost:8080/health 处提供 CoreDNS 的健康报告。
- [ready](https://coredns.io/plugins/ready/)：在端口 `8181` 上提供的一个 HTTP 末端，当所有能够 表达自身就绪的插件都已就绪时，在此末端返回 200 OK。
- [kubernetes](https://coredns.io/plugins/kubernetes/)：CoreDNS 将基于 Kubernetes 的服务和 Pod 的 IP 答复 DNS 查询。你可以在 CoreDNS 网站阅读[更多细节](https://coredns.io/plugins/kubernetes/)。你可以使用 ttl 来定制响应的 TTL。默认值是 5 秒钟。TTL 的最小值可以是 0 秒钟， 最大值为 3600 秒。将 TTL 设置为 0 可以禁止对 DNS 记录进行缓存。

  `pods insecure` 选项是为了与 `kube-dns` 向后兼容。你可以使用 `pods verified` 选项，该选项使得仅在相同名称空间中存在具有匹配 IP 的 Pod 时才返回 A 记录。如果你不使用 Pod 记录，则可以使用 `pods disabled` 选项。
- [prometheus](https://coredns.io/plugins/prometheus/)：CoreDNS 的度量指标值以 [Prometheus](https://prometheus.io/) 格式在 http://localhost:9153/metrics 上提供。
- [forward](https://coredns.io/plugins/forward/): 不在 Kubernetes 集群域内的任何查询都将转发到 预定义的解析器 (/etc/resolv.conf).
- [cache](https://coredns.io/plugins/cache/)：启用前端缓存。
- [loop](https://coredns.io/plugins/loop/)：检测到简单的转发环，如果发现死循环，则中止 CoreDNS 进程。
- [reload](https://coredns.io/plugins/reload)：允许自动重新加载已更改的 Corefile。 编辑 ConfigMap 配置后，请等待两分钟，以使更改生效。
- [loadbalance](https://coredns.io/plugins/loadbalance)：这是一个轮转式 DNS 负载均衡器， 它在应答中随机分配 A、AAAA 和 MX 记录的顺序。

你可以通过修改 ConfigMap 来更改默认的 CoreDNS 行为。
#### 使用 CoreDNS 配置存根域和上游域名服务器
CoreDNS 能够使用 [forward 插件](https://coredns.io/plugins/forward/)配置存根域和上游域名服务器。
#### 示例
如果集群操作员在 10.150.0.1 处运行了 [Consul 域服务器](https://www.consul.io/)， 且所有 Consul 名称都带有后缀 `.consul.local`。要在 CoreDNS 中对其进行配置， 集群管理员可以在 CoreDNS 的 ConfigMap 中创建加入以下字段。
```
consul.local:53 {
        errors
        cache 30
        forward . 10.150.0.1
    }
```
要显式强制所有非集群 DNS 查找通过特定的域名服务器（位于 `172.16.0.1`），可将 forward 指向该域名服务器，而不是 `/etc/resolv.conf`。
```
forward .  172.16.0.1
```
最终的包含默认的 Corefile 配置的 ConfigMap 如下所示：
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . 172.16.0.1
        cache 30
        loop
        reload
        loadbalance
    }
    consul.local:53 {
        errors
        cache 30
        forward . 10.150.0.1
    }
```
工具 kubeadm 支持将 kube-dns ConfigMap 自动转换为 CoreDNS ConfigMap。
> **说明**： 尽管 `kube-dns` 接受 FQDN（例如：ns.foo.com）作为存根域和名字服务器，`CoreDNS` 不支持此功能。 转换期间，CoreDNS 配置中将忽略所有的 FQDN 域名服务器。
### 4. CoreDNS 配置等同于 kube-dns
CoreDNS 不仅仅提供 kube-dns 的功能。 为 kube-dns 创建的 ConfigMap 支持 StubDomains 和 upstreamNameservers 转换为 CoreDNS 中的 forward 插件。 同样，kube-dns 中的 Federations 插件会转换为 CoreDNS 中的 federation 插件。
#### 示例
用于 kube-dns 的此示例 ConfigMap 描述了 federations、stubdomains and upstreamnameservers：
```
apiVersion: v1
data:
  federations: |
        {"foo" : "foo.feddomain.com"}
  stubDomains: |
        {"abc.com" : ["1.2.3.4"], "my.cluster.local" : ["2.3.4.5"]}
  upstreamNameservers: |
        ["8.8.8.8", "8.8.4.4"]
kind: ConfigMap
```
CoreDNS 中的等效配置将创建一个 Corefile：
- 针对 federations:
  ```
  federation cluster.local {
    foo foo.feddomain.com
  }
  ```
- 针对 stubDomains:
  ```
  abc.com:53 {
     errors
     cache 30
     proxy . 1.2.3.4
  }
  my.cluster.local:53 {
     errors
     cache 30
     proxy . 2.3.4.5
  }
  ```

带有默认插件的完整 Corefile：
```
.:53 {
    errors
    health
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
    }
    federation cluster.local {
       foo foo.feddomain.com
    }
    prometheus :9153
    forward .  8.8.8.8 8.8.4.4
    cache 30
}
abc.com:53 {
    errors
    cache 30
    forward . 1.2.3.4
}
my.cluster.local:53 {
    errors
    cache 30
    forward . 2.3.4.5
}
```
### 5. 迁移到 CoreDNS
要从 kube-dns 迁移到 CoreDNS，此[博客](https://coredns.io/2018/05/21/migration-from-kube-dns-to-coredns/)提供了帮助用户将 kube-dns 替换为 CoreDNS。集群管理员还可以使用[部署脚本](https://github.com/coredns/deployment/blob/master/kubernetes/deploy.sh)进行迁移。
### 6. 接下来
- 阅读[调试 DNS 解析](https://kubernetes.io/zh/docs/tasks/administer-cluster/dns-debugging-resolution/)

## Reference
- [Customizing DNS Service](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)