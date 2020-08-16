# 监控、日志和排错
## 1. Auditing
## 2. StackDriver 中的事件
## 3. 使用 crictl 对 Kubernetes 节点进行调试
## 4. 使用 ElasticSearch 和 Kibana 进行日志管理
## 5. 使用 Falco 审计
## 6. 在本地开发和调试服务
## 7. 应用故障排查
## 8. 应用自测与调试
## 9. 排错
## 10. 确定 Pod 失败的原因
## 11. 节点健康监测
## 12. 获取正在运行容器的 Shell
## 13. 调试 Init 容器
## 14. 调试 Pods 和 Replication Controllers
## 15. 调试 Service
对于新安装的 Kubernetes，经常出现的问题是 Service 无法正常运行。 您已经通过 Deployment（或其他工作负载控制器）运行了 Pod，并创建 Service ，但是 当您尝试访问它时，没有任何响应。此文档有望对您有所帮助并找出问题所在。
### 15.1 在 pod 中运行命令
对于这里的许多步骤，您可能希望知道运行在集群中的 Pod 看起来是什么样的。最简单的方法是运行一个交互式的 alpine Pod：
`$ kubectl run -it --rm --restart=Never alpine --image=alpine sh`
> **说明**： 如果你没有看到命令提示符，请尝试按 Enter 键。

如果您已经有了您想使用的正在运行的 Pod，则可以运行以下命令去进入：
`kubectl exec <POD-NAME> -c <CONTAINER-NAME> -- <COMMAND>`
### 15.2 设置
为了完成本次实践的任务，我们先运行几个 Pod。由于您可能正在调试自己的 Service，所以，您可以使用自己的信息进行替换，或者，您也可以跟随并开始下面的步骤来获得第二个数据点。
```
$ kubectl  create deployment hostnames --image=k8s.gcr.io/serve_hostname 
deployment.apps/hostnames created
```
kubectl 命令将打印创建或变更的资源的类型和名称，它们可以在后续命令中使用。 让我们将这个 deployment 的副本数扩至 3。
```
$kubectl scale deployment hostnames --replicas=3
deployment.apps/hostnames scaled
```

请注意这与您使用以下 YAML 方式启动 Deployment 类似：
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hostnames
  name: hostnames
spec:
  selector:
    matchLabels:
      app: hostnames
  replicas: 3
  template:
    metadata:
      labels:
        app: hostnames
    spec:
      containers:
      - name: hostnames
        image: k8s.gcr.io/serve_hostname
```
"app" 标签是 kubectl create deployment 根据 Deployment 名称自动设置的。

确认您的 Pods 是运行状态:
```
$kubectl get pods -l app=hostnames
NAME                        READY     STATUS    RESTARTS   AGE
hostnames-632524106-bbpiw   1/1       Running   0          2m
hostnames-632524106-ly40y   1/1       Running   0          2m
hostnames-632524106-tlaok   1/1       Running   0          2m
```
您还可以确认您的 Pod 是否正在运行。您可以获取 Pod IP 地址列表并直接对其进行测试。
```
$kubectl get pods -l app=hostnames \
    -o go-template='{{range .items}}{{.status.podIP}}{{"\n"}}{{end}}'
10.244.0.5
10.244.0.6
10.244.0.7
```
用于本教程的示例容器仅通过 HTTP 在端口 9376 上提供其自己的主机名，但是如果要调试自己的应用程序，则需要使用您的 Pod 正在侦听的端口号。

在 pod 内运行：
```
$for ep in 10.244.0.5:9376 10.244.0.6:9376 10.244.0.7:9376; do
    wget -qO- $ep
done
hostnames-632524106-bbpiw
hostnames-632524106-ly40y
hostnames-632524106-tlaok
```
如果此时您没有收到期望的响应，则您的 Pod 状态可能不健康，或者可能没有在您认为正确的端口上进行监听。 您可能会发现 kubectl logs 命令对于查看正在发生的事情很有用，或者您可能需要通过kubectl exec 直接进入 Pod 中并从那里进行调试。

假设到目前为止一切都已按计划进行，那么您可以开始调查为何您的 Service 无法正常工作。
### 15.3 Service 是否存在？
### 15.4 Service 是否可通过 DNS 名字访问？
### 15.5 Service 的配置是否正确？
### 15.6 Service 有 Endpoint 吗？
### 15.7 Pod 正常工作吗？
### 15.8 kube-proxy 正常工作吗？
## 16. 调试StatefulSet
## 17. 资源指标管道
## 18. 资源监控工具
## 19. 集群故障排查


## Reference
- [监控、日志和排错](https://kubernetes.io/zh/docs/tasks/debug-application-cluster/)