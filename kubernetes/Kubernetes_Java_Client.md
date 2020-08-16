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
```
import io.kubernetes.client.openapi.ApiClient;
import io.kubernetes.client.openapi.ApiException;
import io.kubernetes.client.openapi.Configuration;
import io.kubernetes.client.openapi.apis.CoreV1Api;
import io.kubernetes.client.openapi.models.V1Pod;
import io.kubernetes.client.openapi.models.V1PodList;
import io.kubernetes.client.util.Config;

import java.io.IOException;

public class Example {
    public static void main(String[] args) throws IOException, ApiException{
        ApiClient client = Config.defaultClient();
        Configuration.setDefaultApiClient(client);

        CoreV1Api api = new CoreV1Api();
        V1PodList list = api.listPodForAllNamespaces(null, null, null, null, null, null, null, null, null);
        for (V1Pod item : list.getItems()) {
            System.out.println(item.getMetadata().getName());
        }
    }
}
```
### 监听名字空间对象:
```
import com.google.gson.reflect.TypeToken;
import io.kubernetes.client.openapi.ApiClient;
import io.kubernetes.client.openapi.ApiException;
import io.kubernetes.client.openapi.Configuration;
import io.kubernetes.client.openapi.apis.CoreV1Api;
import io.kubernetes.client.openapi.models.V1Namespace;
import io.kubernetes.client.util.Config;
import io.kubernetes.client.util.Watch;

import java.io.IOException;

public class WatchExample {
    public static void main(String[] args) throws IOException, ApiException{
        ApiClient client = Config.defaultClient();
        Configuration.setDefaultApiClient(client);

        CoreV1Api api = new CoreV1Api();

        Watch<V1Namespace> watch = Watch.createWatch(
                client,
                api.listNamespaceCall(null, null, null, null, null, 5, null, null, Boolean.TRUE, null, null),
                new TypeToken<Watch.Response<V1Namespace>>(){}.getType());

        for (Watch.Response<V1Namespace> item : watch) {
            System.out.printf("%s : %s%n", item.type, item.object.getMetadata().getName());
        }
    }
}
```
更多例子可以在[examples](https://github.com/kubernetes-client/java/blob/master/examples)目录下找到。为了运行这些例子，执行下买你的方法：
`mvn exec:java -Dexec.mainClass="io.kubernetes.client.examples.Example"`
## 文档
所有API和模块的文档可在[产生的客户端文档](https://github.com/kubernetes-client/java/tree/master/kubernetes/docs)找到。
## 兼容性
客户端版本|1.12|1.13|1.14|1.15|1.16|1.17
--------|--------|--------|--------|--------|--------|--------
4.0.0|✓|-|-|-|-|-
5.0.0|+|✓|-|-|-|-
6.0.1|+|+|✓|-|-|-
7.0.0|+|+|+|✓|-|-
8.0.2v|+|+|+|+|✓|-
9.0.0|+|+|+|+|+|✓

关键点：
+ `✓` Java客户端与Kubernetes版本之间精确匹配特性与API对象。
+ `+` Java客户端中的一些特性与API对象不在Kubernetes集群中，但它们的共有部分可以很好工作。
+ `-` Kubernetes集群拥有一些Java客户端不能使用的特性（额外的API对象等）。
参见[变化日志](https://github.com/kubernetes-client/java/blob/master/CHANGELOG.md)来了解不同Java客户端版本变化的详细描述。
## 贡献
参见[CONTRIBUTING.md](https://github.com/kubernetes-client/java/blob/master/CONTRIBUTING.md)来获取给项目做贡献的指令。
## 行为准则
参与Kubernetes社区活动必须遵循[云原生社区行为准则](https://github.com/cncf/foundation/blob/master/code-of-conduct.md)。
## 开发
**更新产生的代码**。

代码由[openapi-generator project](https://github.com/OpenAPITools/openapi-generator)生成。

我们已经构建了通用跨语言代码生成工具，它驻留在[kubernetes-client/gen](https://github.com/kubernetes-client/gen)项目中。

为了开始，在一个根目录而非你的java客户端目录中，例如，你的目录布局可能如下：
```
${HOME}/
        src/
             gen/
             java/
...
```
接下来clone gen创酷，你可以运行：
```
cd ${HOME}/src
git clone https://github.com/kubernetes-client/gen
export GEN_ROOT=${PWD}
```
然后为了更新客户端并运行格式化器：
```
cd ${HOME}/src/java
${GEN_ROOT}/gen/openapi/java.sh kubernetes ./settings
./mvnw spotless:apply
```
这将运行一个较长的构建过程，涉及`docker`，最终导致一套位于kubernetes下的新产生的代码.

## Reference
- [Kubernetes Java Client](https://github.com/kubernetes-client/java)