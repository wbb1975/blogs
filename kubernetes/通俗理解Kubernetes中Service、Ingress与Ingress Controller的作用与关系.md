# 通俗理解Kubernetes中Service、Ingress与Ingress Controller的作用与关系
通俗的讲:
- Service 是后端真实服务的抽象，一个 Service 可以代表多个相同的后端服务
- Ingress 是反向代理规则，用来规定 HTTP/S 请求应该被转发到哪个 Service 上，比如根据请求中不同的 Host 和 url 路径让请求落到不同的 Service 上
- Ingress Controller 就是一个反向代理程序，它负责解析 Ingress 的反向代理规则，如果 Ingress 有增删改的变动，所有的 Ingress Controller 都会及时更新自己相应的转发规则，当 Ingress Controller 收到请求后就会根据这些规则将请求转发到对应的 Service。

Kubernetes 并没有自带 Ingress Controller，它只是一种标准，具体实现有多种，需要自己单独安装，常用的是 Nginx Ingress Controller 和 Traefik Ingress Controller。 所以 Ingress 是一种转发规则的抽象，Ingress Controller 的实现需要根据这些 Ingress 规则来将请求转发到对应的 Service，我画了个图方便大家理解：

![Service、Ingress与Ingress Controller的作用与关系](images/87iev7yx4t.png)

从图中可以看出，Ingress Controller 收到请求，匹配 Ingress 转发规则，匹配到了就转发到后端 Service，而 Service 可能代表的后端 Pod 有多个，选出一个转发到那个 Pod，最终由那个 Pod 处理请求。

有同学可能会问，既然 Ingress Controller 要接受外面的请求，而 Ingress Controller 是部署在集群中的，怎么让 Ingress Controller 本身能够被外面访问到呢，有几种方式：
- Ingress Controller 用 Deployment 方式部署，给它添加一个 Service，类型为 LoadBalancer，这样会自动生成一个 IP 地址，通过这个 IP 就能访问到了，并且一般这个 IP 是高可用的（前提是集群支持 LoadBalancer，通常云服务提供商才支持，自建集群一般没有）
- 使用集群内部的某个或某些节点作为边缘节点，给 node 添加 label 来标识，Ingress Controller 用 DaemonSet 方式部署，使用 nodeSelector 绑定到边缘节点，保证每个边缘节点启动一个 Ingress Controller 实例，用 hostPort 直接在这些边缘节点宿主机暴露端口，然后我们可以访问边缘节点中 Ingress Controller 暴露的端口，这样外部就可以访问到 Ingress Controller 了
- Ingress Controller 用 Deployment 方式部署，给它添加一个 Service，类型为 NodePort，部署完成后查看会给出一个端口，通过 kubectl get svc 我们可以查看到这个端口，这个端口在集群的每个节点都可以访问，通过访问集群节点的这个端口就可以访问 Ingress Controller 了。但是集群节点这么多，而且端口又不是 80和443，太不爽了，一般我们会在前面自己搭个负载均衡器，比如用 Nginx，将请求转发到集群各个节点的那个端口上，这样我们访问 Nginx 就相当于访问到 Ingress Controller 了。

一般比较推荐的是前面两种方式。
## Reference
- [通俗理解Kubernetes中Service、Ingress与Ingress Controller的作用与关系](https://www.dazhuanlan.com/thegreatblueyon/topics/1224111)
- [通俗理解Kubernetes中Service、Ingress与Ingress Controller的作用与关系](https://cloud.tencent.com/developer/article/1167282)