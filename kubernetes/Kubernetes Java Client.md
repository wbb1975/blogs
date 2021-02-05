# Kubernetes Java Client
[Kubenretes Java Client](https://github.com/kubernetes-client/java) 是一个 Java 库用于通过访问 Kubernetes API 来操作 Kubernetes 集群。
## 1. 安装
### 1.1 安装
为了安装Java客户端库到你的本地 Maven 仓库，仅需执行：
```
git clone --recursive https://github.com/kubernetes-client/java
cd java
mvn install
```
参考[官方文档](https://maven.apache.org/plugins/maven-deploy-plugin/usage.html)以获取更多信息。
### 1.2 Maven 用户
把下面的依赖添加进你的项目POM：
```
<dependency>
    <groupId>io.kubernetes</groupId>
    <artifactId>client-java</artifactId>
    <version>10.0.0</version>
</dependency>
```
### 1.3 Gradle 用户
```
compile 'io.kubernetes:client-java:10.0.0'
```
### 1.4 其它
首先执行下面的命令产生 Jar：
```
git clone --recursive https://github.com/kubernetes-client/java
cd java/kubernetes
mvn package
```
然后手动安装下面的 Jar：
- target/client-java-api-10.0.1-SNAPSHOT.jar
- target/lib/*.jar
## 2. 版本和兼容性
### 2.1 客户端版本
Java 客户使用语义版本。无论何时当我们为一个新的 Kubernetes 发布版本（见下面的表格）重新产生客户端时，我们将递增主版本号；无论何时当我们这么做时，意味着在生成的Kubernetes API Stubs中有新的 API 加入或者有破坏性的修改。无论何时当你升级一个主要版本时，应改为潜在的破坏性修改做准备。
### 2.2 兼容性
client version|1.13|1.14|1.15|1.16|1.17|1.18
--------|--------|--------|--------|--------|--------|--------
5.0.0|✓|-|-|x|x|x
6.0.1|+|✓|-|-|x|x
7.0.0|+|+|✓|-|-|x
8.0.2|+|+|+|✓|-|-
9.0.2|+|+|+|+|✓|-
10.0.0|+|+|+|+|+|✓

**关键点**
- `✓` Java 客户端和 Kubernetes 版本拥有完全一致的 特性 / API 对象。
- `+` Java 客户端拥有Kubernetes 集群不拥有的 特性 / API 对象，但它们共有的可以工作。
` `-` Kubernetes 集群拥有Java 客户端不能使用的特性（额外的 API 对象，等）。
- `x` Kubernetes 集群不保证支持该版本的Java 客户端，因为它只支持 n-2版本。它没有测试过，使用废弃或将会在未来版本中移除的 API 版本进行操作不保证能正确工作。

参阅[修改记录](https://github.com/kubernetes-client/java/wiki/CHANGELOG.md)来查看Java客户端版本间的差异。
## 3. 代码示例
下面是一些代码片段展示如何使用库来访问 Kubernetes 集群。

**列出所有 Pod**：
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

**监听命名空间对象**：
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
更多实例可以在[examples](https://github.com/kubernetes-client/java/wiki/examples)目录下找到。为了运行实例，运行下面的命令：
```
mvn exec:java -Dexec.mainClass="io.kubernetes.client.examples.Example"
```
我们另外准备了一些公共用例如下：
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
- 高级（注意：下面的例子需要 client-java-extended 模块）
  + [(5.0.0+) InformerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/InformerExample.java): Build an informer which list-watches resources and reflects the notifications to a local cache.
  + [(5.0.0+) PagerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/PagerExample.java): Support Pagination (only for the list request) to ease server-side loads/network congestion.
  + [(6.0.0+) ControllerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/ControllerExample.java): Build a controller reconciling the state of world by list-watching one or multiple resources.
  + [(6.0.0+) LeaderElectionExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/LeaderElectionExample.java): Leader election utilities to help implement HA controllers.
  + [(9.0.0+) SpringIntegrationControllerExample](https://github.com/kubernetes-client/java/blob/master/examples/src/main/java/io/kubernetes/client/examples/SpringControllerExample.java): Building a kubernetes controller based on spring framework's bean injection.
  + [(9.0.0+) GenericKubernetesClientExample](https://github.com/kubernetes-client/java/blob/master/extended/src/main/java/io/kubernetes/client/extended/generic/GenericKubernetesApi.java): Construct a generic client interface for any kubernetes types, including CRDs. 
## 4. 开发和贡献
### 4.1 开发
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
接下来为了克隆 gen 仓库，你可以运行：
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
### 4.2 贡献
参见[CONTRIBUTING.md](https://github.com/kubernetes-client/java/blob/master/CONTRIBUTING.md)来获取给项目做贡献的指令。
### 4.1 行为准则
参与Kubernetes社区活动必须遵循[云原生社区行为准则](https://github.com/cncf/foundation/blob/master/code-of-conduct.md)。
## 5. 产生 Java 用户定义资源（CustomResourceDefinition）模板
项目还提供了从一些常用开源项目产生的模板类来用作单独的 Maven 依赖。请参考下面的链接来查看它们各自文档：
- [cert-manager](https://github.com/kubernetes-client/java/wiki/client-java-contrib/cert-manager)
- [prometheus operator](https://github.com/kubernetes-client/java/wiki/client-java-contrib/prometheus-operator)

我们也建议阅读下面的[文档](https://github.com/kubernetes-client/java/blob/master/docs/generate-model-from-third-party-resources.md)来了解更多关于自动产生自定义模板来适配本库的细节。另外，你也可以手动撰写模型，例如，微弹一资源类型实现 `io.kubernetes.client.common.KubernetesObject`，为列表类型实现 `io.kubernetes.client.common.KubernetesListObject`。
```
public class Foo implements io.kubernetes.client.common.KubernetesObject {
    ...
}


public class FooList implements io.kubernetes.client.common.KubernetesListObject {
    ...
}
```
## 6. 已知问题（还未解决）
1. 删除自愿时抛出异常："java.lang.IllegalStateException: Expected a string but was BEGIN_OBJECT..."
   这个异常发生主要因为来自 kubernetes 上游的 openapi 模式与其实现不匹配，这是 openapi v2 模式表达式 [#86](https://github.com/kubernetes-client/java/issues/86)的限制导致的。可以考虑或者捕获并忽略 JsonSyntaxException，或者采用下面的形式删除：
   + 使用kubectl对等体，如这个[示例](https://github.com/kubernetes-client/java/blob/6fa3525189d9e50d9b07016155642ddf59990905/e2e/src/test/groovy/io/kubernetes/client/e2e/kubectl/KubectlNamespaceTest.groovy#L69-L72)
   + 使用一般kubernetes API，示例[见此](https://github.com/kubernetes-client/java/blob/6fa3525189d9e50d9b07016155642ddf59990905/examples/src/main/java/io/kubernetes/client/examples/GenericClientExample.java#L56)
## 7. 常见问题
### ApiException: 在集群中运行代码时被禁止（Forbidden while running code in cluster）
很可能你的 Pod 没有正确的 RBAC 权限。默认地大部分 Pods 仅能相当有限地访问 Kubernetes API server。你需要确保 Pod 的 ServiceAccount 有正确的 RBAC 权限。

更多细节，请查看[服务账号权限](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions)

## Reference
- [Kubernetes Java Client](https://github.com/kubernetes-client/java)
- [kubectl-equivalence-in-java.md](https://github.com/kubernetes-client/java/blob/master/docs/kubectl-equivalence-in-java.md)
- [Fabric8 和官方 Kubernetes Java 客户端的区别](https://itnext.io/difference-between-fabric8-and-official-kubernetes-java-client-3e0a994fd4af)
- [Client Libraries](https://kubernetes.io/docs/reference/using-api/client-libraries/)