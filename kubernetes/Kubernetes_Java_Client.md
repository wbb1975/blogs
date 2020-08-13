# Kubernetes Java Client
## 客户端版本控制（Client versioning）
Java客户端使用语义版本控制。无论何时当为一个新的Kubernetes 发布版本（参见下面表）产生客户端时，我们将增加其大版本号。无论何时当我们这样做时，产生的Kubernetes API存根会有破坏性的变更（breaking changes）。无论何时当你升级一个主要的版本时，需要为那些破坏性的便跟做准备。
## 安装
为了向你的本地Maven仓库安装Java客户端库，只需简单执行：
```
git clone --recursive https://github.com/kubernetes-client/java
cd java
mvn install
```
请参阅[官方文档](https://maven.apache.org/plugins/maven-deploy-plugin/usage.html)获取更多细节。
### Maven 用户
将下面的依赖加入你的项目POM：
```
<dependency>
    <groupId>io.kubernetes</groupId>
    <artifactId>client-java</artifactId>
    <version>9.0.0</version>
</dependency>
```
### Gradle users
`compile 'io.kubernetes:client-java:9.0.0'`
### 其它
首先执行下面的命令产生JAR：
```
git clone --recursive https://github.com/kubernetes-client/java
cd java/kubernetes
mvn package
```
安后手动安装下面的JARs:
- target/client-java-api-10.0.0-SNAPSHOT.jar
- target/lib/*.jar
## 示例
我们准备了一下常见用例的示例，如下所示：
- 配置
  + [InClusterClientExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/InClusterClientExample.java): 配置一个在Kubernetes集群里面运行的客户端
  + [KubeConfigFileClientExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/KubeConfigFileClientExample.java): 配置一个客户端从外部访问Kubernetes集群
- 基础
  + [SimpleExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/Example.java): 最简单示例关于如何使用客户端
  + [ProtoExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/ProtoExample.java): 请求或接收利用protobuf序列化协议的载荷
  + [(5.0.0+) PatchExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/PatchExample.java): 用各种各样支持的patch格式对资源对象打Patch，和kubectl patch一样
  + [FluentExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/FluentExample.java): 用fluent builder风格构建任意对象
  + [YamlExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/YamlExample.java): 推荐的以yaml格式加载或转储资源的方法
- 流（Streaming）
  + [WatchExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/WatchExample.java): Subscribe watch events from certain resources, equal to kubectl get <resource> -w.
  + [LogsExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/LogsExample.java): Fetch logs from running containers, equal to kubectl logs.
  + [ExecExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/ExecExample.java): Establish an "exec" session with running containers, equal to kubectl exec.
  + [PortForwardExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/PortForwardExample.java): Maps local port to a port on the pod, equal to kubectl port-forward.
  + [AttachExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/AttachExample.java): Attach to a process that is already running inside an existing container, equal to kubectl attach.
  + [CopyExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/CopyExample.java): Copy files and directories to and from containers, equal to kubectl cp.
  + [WebSocketsExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/WebSocketsExample.java): Establish an arbitrary web-socket session to certain resources.
- 高级（注意：下面的例子需要client-java-extended模块）
  + [(5.0.0+) InformerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/InformerExample.java): Build an informer which list-watches resources and reflects the notifications to a local cache.
  + [(5.0.0+) PagerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/PagerExample.java): Support Pagination (only for the list request) to ease server-side loads/network congestion.
  + [(6.0.0+) ControllerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/ControllerExample.java): Build a controller reconciling the state of world by list-watching one or multiple resources.
  + [(6.0.0+) LeaderElectionExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/LeaderElectionExample.java): Leader election utilities to help implement HA controllers.
  + [(9.0.0+) SpringIntegrationControllerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/SpringControllerExample.java): Building a kubernetes controller based on spring framework's bean injection.
  + [(9.0.0+) GenericKubernetesClientExample](https://github.com/kubernetes-client/java/blob/master/extended/src/main/java/io/kubernetes/client/extended/generic/GenericKubernetesApi.java): Construct a generic client interface for any kubernetes types, including CRDs.
### 列出所有pods：


## Reference
- [Kubernetes Java Client](https://github.com/kubernetes-client/java)