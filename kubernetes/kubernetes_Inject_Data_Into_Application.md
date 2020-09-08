# 给应用注入数据
## 1. 为容器设置启动时要执行的命令和参数
### 1.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 1.2 创建 Pod 时设置命令及参数
创建 Pod 时，可以为其下的容器设置启动时要执行的命令及其参数。如果要设置命令，就填写在配置文件的 command 字段下，如果要设置命令的参数，就填写在配置文件的 args 字段下。一旦 Pod 创建完成，该命令及其参数就无法再进行更改了。

如果在配置文件中设置了容器启动时要执行的命令及其参数，那么容器镜像中自带的命令与参数将会被覆盖而不再执行。如果配置文件中只是设置了参数，却没有设置其对应的命令，那么容器镜像中自带的命令会使用该新参数作为其执行时的参数。

> **说明**： 在有些容器运行时中，command 字段对应 entrypoint，请参阅下面的[说明事项](https://kubernetes.io/zh/docs/tasks/inject-data-application/define-command-argument-container/#notes)。

本示例中，将创建一个只包含单个容器的 Pod。在 Pod 配置文件中设置了一个命令与两个参数：
```
apiVersion: v1
kind: Pod
metadata:
  name: command-demo
  labels:
    purpose: demonstrate-command
spec:
  containers:
  - name: command-demo-container
    image: debian
    command: ["printenv"]
    args: ["HOSTNAME", "KUBERNETES_PORT"]
  restartPolicy: OnFailure
```

1. 基于 YAML 文件创建一个 Pod：   
   `kubectl apply -f https://k8s.io/examples/pods/commands.yaml`
2. 获取正在运行的 Pods：
   `kubectl get pods`   
   查询结果显示在 command-demo 这个 Pod 下运行的容器已经启动完成。
3. 如果要获取容器启动时执行命令的输出结果，可以通过 Pod 的日志进行查看：
   `kubectl logs command-demo`   
   日志中显示了 HOSTNAME 与 KUBERNETES_PORT 这两个环境变量的值：
   ```
   command-demo
   tcp://10.3.240.1:443
   ```
### 1.3 使用环境变量来设置参数
在上面的示例中，我们直接将一串字符作为命令的参数。除此之外，我们还可以将环境变量作为命令的参数。
```
env:
- name: MESSAGE
  value: "hello world"
command: ["/bin/echo"]
args: ["$(MESSAGE)"]
```
这意味着你可以将那些用来设置环境变量的方法应用于设置命令的参数，其中包括了 [ConfigMaps](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-pod-configmap/) 与 [Secrets](https://kubernetes.io/zh/docs/concepts/configuration/secret/)。

> **说明**： 环境变量需要加上括号，类似于 "$(VAR)"。这是在 command 或 args 字段使用变量的格式要求。
### 1.4 在 Shell 来执行命令
有时候，你需要在 Shell 脚本中运行命令。 例如，你要执行的命令可能由多个命令组合而成，或者它就是一个 Shell 脚本。 这时，就可以通过如下方式在 Shell 中执行命令：
```
command: ["/bin/sh"]
args: ["-c", "while true; do echo hello; sleep 10;done"]
```
### 1.5 说明事项
下表给出了 Docker 与 Kubernetes 中对应的字段名称。
描述|Docker 字段名称|Kubernetes 字段名称
--------|--------|--------
容器执行的命令|Entrypoint|command
传给命令的参数|Cmd|args

如果要覆盖默认的 Entrypoint 与 Cmd，需要遵循如下规则：
- 如果在容器配置中没有设置 command 或者 args，那么将使用 Docker 镜像自带的命令及其参数。
- 如果在容器配置中只设置了 command 但是没有设置 args，那么容器启动时只会执行该命令， Docker 镜像中自带的命令及其参数会被忽略。
- 如果在容器配置中只设置了 args，那么 Docker 镜像中自带的命令会使用该新参数作为其执行时的参数。
- 如果在容器配置中同时设置了 command 与 args，那么 Docker 镜像中自带的命令及其参数会被忽略。 容器启动时只会执行配置中设置的命令，并使用配置中设置的参数作为命令的参数。

下面是一些例子：
镜像 Entrypoint|镜像 Cmd|容器 command|容器 args|命令执行
--------|--------|--------|--------|--------
[/ep-1]|[foo bar]|not set|not set|[ep-1 foo bar]
[/ep-1]|[foo bar]|[/ep-2]|not set|[ep-2]
[/ep-1]|[foo bar]|not set|[zoo boo]|[ep-1 zoo boo]
[/ep-1]|[foo bar]|[/ep-2]|[zoo boo]|[ep-2 zoo boo]
## 2. 定义依赖的环境变量
### 2.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 2.2 为容器设置一个依赖的环境变量
创建 Pod 时，可以为其下的容器设置依赖的环境变量。通过配置文件的 env 或者 envFrom 字段来设置环境变量。为了设置依赖的环境变量，你可以在配置文件的 `env` 段的 `value` 部分使用$(VAR_NAME)。

本示例中，将创建一个只包含单个容器的 Pod。Pod 的配置文件中设置依赖环境变量，并演示了普遍用法。下面是 Pod 的配置文件内容：
```
apiVersion: v1
kind: Pod
metadata:
  name: dependent-envars-demo
spec:
  containers:
    - name: dependent-envars-demo
      args:
        - while true; do echo -en '\n'; printf UNCHANGED_REFERENCE=$UNCHANGED_REFERENCE'\n'; printf SERVICE_ADDRESS=$SERVICE_ADDRESS'\n';printf ESCAPED_REFERENCE=$ESCAPED_REFERENCE'\n'; sleep 30; done;
      command:
        - sh
        - -c
      image: busybox
      env:
        - name: SERVICE_PORT
          value: "80"
        - name: SERVICE_IP
          value: "172.17.0.1"
        - name: UNCHANGED_REFERENCE
          value: "$(PROTOCOL)://$(SERVICE_IP):$(SERVICE_PORT)"
        - name: PROTOCOL
          value: "https"
        - name: SERVICE_ADDRESS
          value: "$(PROTOCOL)://$(SERVICE_IP):$(SERVICE_PORT)"
        - name: ESCAPED_REFERENCE
          value: "$$(PROTOCOL)://$(SERVICE_IP):$(SERVICE_PORT)"
```
1. 基于 YAML 文件创建一个 Pod：
   ```
   ubectl apply -f https://k8s.io/examples/pods/inject/dependent-envars.yaml

   pod/dependent-envars-demo created
   ```
2. 获取一下当前正在运行的 Pods 信息：
   `kubectl get pods dependent-envars-demo`
   查询结果应为：
   ```
   NAME                      READY     STATUS    RESTARTS   AGE
   dependent-envars-demo     1/1       Running   0          9s
   ```
3. 检查你的Pod下运行的容器的日志：
   ```
   kubectl logs pod/dependent-envars-demo

   UNCHANGED_REFERENCE=$(PROTOCOL)://172.17.0.1:80
   SERVICE_ADDRESS=https://172.17.0.1:80
   ESCAPED_REFERENCE=$(PROTOCOL)://172.17.0.1:80
   ```
正如上面显示的，你已经定义了包含正确依赖引用的SERVICE_ADDRESS，坏的依赖引用的UNCHANGED_REFERENCE，以及跳过依赖的ESCAPED_REFERENCE。

当一个环境变量被引用时如果已经定义，该因用就能被正确解析，逼图SERVICE_ADDRESS 的例子。

如果一个环境变量未定义，或者包含某些变量，未定义环境变量将被当作正常字符串处理，比如UNCHANGED_REFERENCE。注意通常不能正常解析的环境变量并不能阻止容器启动运行。

一个`$(VAR_NAME)`语法可被转义，比如`$$(VAR_NAME)`。转义的引用永远不会展开，不管该引用是否已经定义。上面的 `ESCAPED_REFERENCE` 就属于这种例子。
## 3. 为容器设置环境变量
### 3.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 3.2 为容器设置一个环境变量
创建 Pod 时，可以为其下的容器设置环境变量。通过配置文件的 env 或者 envFrom 字段来设置环境变量。

本示例中，将创建一个只包含单个容器的 Pod。Pod 的配置文件中设置环境变量的名称为 `DEMO_GREETING`， 其值为 `"Hello from the environment"`。下面是 Pod 的配置文件内容：
```
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    env:
    - name: DEMO_GREETING
      value: "Hello from the environment"
    - name: DEMO_FAREWELL
      value: "Such a sweet sorrow"
```
1. 基于 YAML 文件创建一个 Pod：
   `kubectl apply -f https://k8s.io/examples/pods/inject/envars.yaml`
2. 获取一下当前正在运行的 Pods 信息：
   `kubectl get pods -l purpose=demonstrate-envars`
   查询结果应为：
   ```
   NAME            READY     STATUS    RESTARTS   AGE
   envar-demo      1/1       Running   0          9s
   ```
3. 进入该 Pod 下的容器并打开一个命令终端：
   `kubectl exec -it envar-demo -- /bin/bash`
4. 在命令终端中通过执行 printenv 打印出环境变量。
   `root@envar-demo:/# printenv`
   打印结果应为：
   ```
   NODE_VERSION=4.4.2
   EXAMPLE_SERVICE_PORT_8080_TCP_ADDR=10.3.245.237
   HOSTNAME=envar-demo
   ...
   DEMO_GREETING=Hello from the environment
   DEMO_FAREWELL=Such a sweet sorrow
   ```
5. 通过键入 exit 退出命令终端。

> **说明**： 通过 env 或 envFrom 字段设置的环境变量将覆盖容器镜像中指定的所有环境变量。

> **说明**： 环境变量之间可能出现互相依赖或者循环引用的情况，使用之前需注意引用顺序
### 3.3 在配置中使用环境变量
您在 Pod 的配置中定义的环境变量可以在配置的其他地方使用，例如可用在为 Pod 的容器设置的命令和参数中。在下面的示例配置中，环境变量 `GREETING`，`HONORIFIC` 和 `NAME` 分别设置为 `Warm greetings to`，`The Most Honorable 和 Kubernetes`。然后这些环境变量在传递给容器 `env-print-demo` 的 CLI 参数中使用。
```
apiVersion: v1
kind: Pod
metadata:
  name: print-greeting
spec:
  containers:
  - name: env-print-demo
    image: bash
    env:
    - name: GREETING
      value: "Warm greetings to"
    - name: HONORIFIC
      value: "The Most Honorable"
    - name: NAME
      value: "Kubernetes"
    command: ["echo"]
    args: ["$(GREETING) $(HONORIFIC) $(NAME)"]
```
创建后，命令 `echo Warm greetings to The Most Honorable Kubernetes` 将在容器中运行。
## 4. 通过环境变量将 Pod 信息呈现给容器
### 4.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 4.2 Downward API
有两种方式可以将 Pod 和 Container 字段呈现给运行中的容器：
- 环境变量
- [卷文件](https://kubernetes.io/docs/resources-reference/v1.18/#downwardapivolumefile-v1-core)
这两种呈现 Pod 和 Container 字段的方式统称为 Downward API。
### 4.3 用 Pod 字段作为环境变量的值
在这个练习中，你将创建一个包含一个容器的 Pod。这是该 Pod 的配置文件：
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-envars-fieldref
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_NODE_NAME MY_POD_NAME MY_POD_NAMESPACE;
          printenv MY_POD_IP MY_POD_SERVICE_ACCOUNT;
          sleep 10;
        done;
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
  restartPolicy: Never
```
这个配置文件中，你可以看到五个环境变量。env 字段是一个 [EnvVars](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#envvar-v1-core). 对象的数组。 数组中第一个元素指定 `MY_NODE_NAME` 这个环境变量从 Pod 的 `spec.nodeName` 字段获取变量值。 同样，其它环境变量也是从 Pod 的字段获取它们的变量值。
> **说明**： 本示例中的字段是 Pod 字段，不是 Pod 中 Container 的字段。

创建Pod：
`kubectl apply -f https://k8s.io/examples/pods/inject/dapi-envars-pod.yaml`

验证 Pod 中的容器运行正常：
```
kubectl get pods
```

查看容器日志：
`kubectl logs dapi-envars-fieldref`

输出信息显示了所选择的环境变量的值：
```
minikube
dapi-envars-fieldref
default
172.17.0.4
default
```

要了解为什么这些值在日志中，请查看配置文件中的command 和 args字段。 当容器启动时，它将五个环境变量的值写入 stdout。每十秒重复执行一次。

接下来，通过打开一个 Shell 进入 Pod 中运行的容器：
`kubectl exec -it dapi-envars-fieldref -- sh`

在 Shell 中，查看环境变量：
`/# printenv`

输出信息显示环境变量已经设置为 Pod 字段的值。
```
MY_POD_SERVICE_ACCOUNT=default
...
MY_POD_NAMESPACE=default
MY_POD_IP=172.17.0.4
...
MY_NODE_NAME=minikube
...
MY_POD_NAME=dapi-envars-fieldref
```
### 4.4 用 Container 字段作为环境变量的值
前面的练习中，你将 Pod 字段作为环境变量的值。 接下来这个练习中，你将用 Container 字段作为环境变量的值。这里是包含一个容器的 Pod 的配置文件：
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-envars-resourcefieldref
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox:1.24
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_CPU_REQUEST MY_CPU_LIMIT;
          printenv MY_MEM_REQUEST MY_MEM_LIMIT;
          sleep 10;
        done;
      resources:
        requests:
          memory: "32Mi"
          cpu: "125m"
        limits:
          memory: "64Mi"
          cpu: "250m"
      env:
        - name: MY_CPU_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.cpu
        - name: MY_CPU_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.cpu
        - name: MY_MEM_REQUEST
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: requests.memory
        - name: MY_MEM_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: test-container
              resource: limits.memory
  restartPolicy: Never
```
这个配置文件中，你可以看到四个环境变量。env 字段是一个 [EnvVars](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#envvar-v1-core). 对象的数组。数组中第一个元素指定 `MY_CPU_REQUEST` 这个环境变量从 `Container` 的 `requests.cpu` 字段获取变量值。同样，其它环境变量也是从 `Container` 的字段获取它们的变量值。

> **说明**： 本例中使用的是 Container 的字段而不是 Pod 的字段。

创建Pod：
`kubectl apply -f https://k8s.io/examples/pods/inject/dapi-envars-container.yaml`

验证 Pod 中的容器运行正常：
`kubectl get pods`

查看容器日志：
`kubectl logs dapi-envars-resourcefieldref`

输出信息显示了所选择的环境变量的值：
```
1
1
33554432
67108864
```
## 5. 通过文件将 Pod 信息呈现给容器
### 5.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 5.2 Downward API
有两种方式可以将 Pod 和 Container 字段呈现给运行中的容器：
- [环境变量](https://kubernetes.io/docs/tasks/configure-pod-container/environment-variable-expose-pod-information/)
- [卷文件](https://kubernetes.io/docs/resources-reference/v1.18/#downwardapivolumefile-v1-core)
这两种呈现 Pod 和 Container 字段的方式统称为 Downward API。
### 5.3 存储 Pod 字段
在这个练习中，你将创建一个包含一个容器的 Pod。Pod 的配置文件如下：
```
apiVersion: v1
kind: Pod
metadata:
  name: kubernetes-downwardapi-volume-example
  labels:
    zone: us-est-coast
    cluster: test-cluster1
    rack: rack-22
  annotations:
    build: two
    builder: john-doe
spec:
  containers:
    - name: client-container
      image: k8s.gcr.io/busybox
      command: ["sh", "-c"]
      args:
      - while true; do
          if [[ -e /etc/podinfo/labels ]]; then
            echo -en '\n\n'; cat /etc/podinfo/labels; fi;
          if [[ -e /etc/podinfo/annotations ]]; then
            echo -en '\n\n'; cat /etc/podinfo/annotations; fi;
          sleep 5;
        done;
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
          - path: "annotations"
            fieldRef:
              fieldPath: metadata.annotations
```
在配置文件中，你可以看到 Pod 有一个 `downwardAPI` 类型的卷，并且挂载到容器中的 `/etc` 目录。

查看 `downwardAPI` 下面的 `items` 数组。 每个数组元素都是一个 [DownwardAPIVolumeFile](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#downwardapivolumefile-v1-core) 对象。 第一个元素指示 Pod 的 `metadata.labels` 字段的值保存在名为 `labels` 的文件中。 第二个元素指示 Pod 的 `annotations` 字段的值保存在名为 `annotations` 的文件中。
> **说明**： 本示例中的字段是Pod字段，不是Pod中容器的字段。

创建 Pod：
`kubectl apply -f https://k8s.io/examples/pods/inject/dapi-volume.yaml`

验证Pod中的容器运行正常：
`kubectl get pods`

查看容器的日志：
```
kubectl logs kubernetes-downwardapi-volume-example
```

输出显示 labels 和 annotations 文件的内容：
```
cluster="test-cluster1"
rack="rack-22"
zone="us-est-coast"

build="two"
builder="john-doe"
```

进入 Pod 中运行的容器，打开一个 Shell：
`kubectl exec -it kubernetes-downwardapi-volume-example -- sh`

在该 Shell中，查看 labels 文件：
`/# cat /etc/labels`

输出显示 Pod 的所有标签都已写入 labels 文件。
```
cluster="test-cluster1"
rack="rack-22"
zone="us-est-coast"
```

同样，查看annotations文件：
```
/# cat /etc/annotations
```

查看/etc/podinfo目录下的文件：
```
/# ls -laR /etc/podinfo
```

在输出中可以看到，labels 和 annotations 文件都在一个临时子目录中。 在这个例子，..2982_06_02_21_47_53.299460680。 在 /etc/podinfo 目录中，..data 是一个指向临时子目录 的符号链接。/etc/podinfo 目录中，labels 和 annotations 也是符号链接。
```
drwxr-xr-x  ... Feb 6 21:47 ..2982_06_02_21_47_53.299460680
lrwxrwxrwx  ... Feb 6 21:47 ..data -> ..2982_06_02_21_47_53.299460680
lrwxrwxrwx  ... Feb 6 21:47 annotations -> ..data/annotations
lrwxrwxrwx  ... Feb 6 21:47 labels -> ..data/labels

/etc/..2982_06_02_21_47_53.299460680:
total 8
-rw-r--r--  ... Feb  6 21:47 annotations
-rw-r--r--  ... Feb  6 21:47 labels
```
用符号链接可实现元数据的动态原子性刷新；更新将写入一个新的临时目录， 然后通过使用[rename(2)](http://man7.org/linux/man-pages/man2/rename.2.html) 完成 ..data 符号链接的原子性更新。
> **说明**： 如果容器以[subPath](https://kubernetes.io/zh/docs/concepts/storage/volumes/#using-subpath)卷挂载方式来使用 Downward API，则该容器无法收到更新事件。

退出 Shell：`/# exit`
### 5.4 存储容器字段
前面的练习中，你将 Pod 字段保存到 DownwardAPIVolumeFile 中。 接下来这个练习，你将存储 Container 字段。这里是包含一个容器的 Pod 的配置文件：
```
apiVersion: v1
kind: Pod
metadata:
  name: kubernetes-downwardapi-volume-example-2
spec:
  containers:
    - name: client-container
      image: k8s.gcr.io/busybox:1.24
      command: ["sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          if [[ -e /etc/podinfo/cpu_limit ]]; then
            echo -en '\n'; cat /etc/podinfo/cpu_limit; fi;
          if [[ -e /etc/podinfo/cpu_request ]]; then
            echo -en '\n'; cat /etc/podinfo/cpu_request; fi;
          if [[ -e /etc/podinfo/mem_limit ]]; then
            echo -en '\n'; cat /etc/podinfo/mem_limit; fi;
          if [[ -e /etc/podinfo/mem_request ]]; then
            echo -en '\n'; cat /etc/podinfo/mem_request; fi;
          sleep 5;
        done;
      resources:
        requests:
          memory: "32Mi"
          cpu: "125m"
        limits:
          memory: "64Mi"
          cpu: "250m"
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "cpu_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.cpu
              divisor: 1m
          - path: "cpu_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.cpu
              divisor: 1m
          - path: "mem_limit"
            resourceFieldRef:
              containerName: client-container
              resource: limits.memory
              divisor: 1Mi
          - path: "mem_request"
            resourceFieldRef:
              containerName: client-container
              resource: requests.memory
              divisor: 1Mi
```
在这个配置文件中，你可以看到 Pod 有一个 `downwardAPI` 类型的卷，并且挂载到容器的 `/etc/podinfo` 目录。

查看 `downwardAPI` 下面的 `items` 数组。每个数组元素都是一个 `DownwardAPIVolumeFile`。

第一个元素指定名为 `client-container` 的容器中 `limits.cpu` 字段的值应保存在名为 `cpu_limit` 的文件中。

创建Pod：`kubectl apply -f https://k8s.io/examples/pods/inject/dapi-volume-resources.yaml`

打开一个 Shell，进入 Pod 中运行的容器：
`kubectl exec -it kubernetes-downwardapi-volume-example-2 -- sh`

在 Shell 中，查看 cpu_limit 文件：
`/# cat /etc/cpu_limit`

你可以使用同样的命令查看 `cpu_request`、`mem_limit` 和 `mem_request` 文件.
### 5.5 Downward API 的能力
下面这些信息可以通过环境变量和 `downwardAPI` 卷提供给容器：
- 能通过 `fieldRef` 获得的：
  + `metadata.name` - Pod 名称
  + `metadata.namespace` - Pod 名字空间
  + `metadata.uid` - Pod的UID, 版本要求 v1.8.0-alpha.2
  + `metadata.labels['<KEY>']` - Pod 标签 `<KEY>` 的值 (例如, `metadata.labels['mylabel']`）； 版本要求 Kubernetes 1.9+
  + `metadata.annotations['<KEY>']` - Pod 的注解 `<KEY>` 的值（例如, `metadata.annotations['myannotation']`）； 版本要求 Kubernetes 1.9+
- 能通过 `resourceFieldRef` 获得的：
  + 容器的 CPU 约束值
  + 容器的 CPU 请求值
  + 容器的内存约束值
  + 容器的内存请求值
  + 容器的临时存储约束值, 版本要求 v1.8.0-beta.0
  + 容器的临时存储请求值, 版本要求 v1.8.0-beta.0

此外，以下信息可通过 `downwardAPI` 卷从 `fieldRef` 获得：
- `metadata.labels` - Pod 的所有标签，以 `label-key="escaped-label-value"` 格式显示，每行显示一个标签
- `metadata.annotations` - Pod 的所有注解，以 `annotation-key="escaped-annotation-value"` 格式显示，每行显示一个标签

以下信息可通过环境变量获得：
- `status.podIP` - Pod IP
- `spec.serviceAccountName` - Pod 服务帐号名称, 版本要求 v1.4.0-alpha.3
- `spec.nodeName` - 节点名称, 版本要求 v1.4.0-alpha.3
- `status.hostIP` - 节点 IP, 版本要求 v1.7.0-alpha.1

> **说明**： 如果容器未指定 CPU 和内存限制，则 Downward API 默认将节点可分配值 视为容器的 CPU 和内存限制。
### 5.6 投射键名到指定路径并且指定文件权限
你可以将键名投射到指定路径并且指定每个文件的访问权限。 更多信息，请参阅[Secrets](https://kubernetes.io/zh/docs/concepts/configuration/secret/).
### 5.7 Downward API的动机
对于容器来说，有时候拥有自己的信息是很有用的，可避免与 Kubernetes 过度耦合。 Downward API 使得容器使用自己或者集群的信息，而不必通过 Kubernetes 客户端或 API 服务器来获得。

一个例子是有一个现有的应用假定要用一个非常熟悉的环境变量来保存一个唯一标识。 一种可能是给应用增加处理层，但这样是冗余和易出错的，而且它违反了低耦合的目标。 更好的选择是使用 Pod 名称作为标识，把 Pod 名称注入这个环境变量中。
## 6. 使用 PodPreset 将信息注入 Pod
### 6.1 准备开始
### 6.2 使用 PodPreset 来注入环境变量和卷 
### 6.3 删除PodPreset
## 7. 使用 Secret 安全地分发凭证
### 7.1 准备开始
你必须拥有一个 Kubernetes 的集群，同时你的 Kubernetes 集群必须带有 kubectl 命令行工具。 如果你还没有集群，你可以通过 [Minikube](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/) 构建一 个你自己的集群，或者你可以使用下面任意一个 Kubernetes 工具构建：
- [Katacoda](https://www.katacoda.com/courses/kubernetes/playground)
- [Play with Kubernetes](http://labs.play-with-k8s.com/)
要获知版本信息，请输入 kubectl version.
### 7.2 将 secret 数据转换为 base-64 形式
### 7.3 创建 Secret
### 7.4 创建可以通过卷访问 secret 数据的 Pod
### 7.5 创建通过环境变量访问 secret 数据的 Pod

## Reference
- [给应用注入数据](https://kubernetes.io/zh/docs/tasks/inject-data-application/)
- [Inject Data Into Applications](https://kubernetes.io/docs/tasks/inject-data-application/)