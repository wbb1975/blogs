# Fabric8 和官方 Kubernetes Java 客户端的区别
## 1. 历史
Fabric8 Kubernetes 客户端由[Ioannis Cannelos](https://github.com/iocanel) 和 [Jimmy Dyson](https://github.com/jimmidyson)在 Kubernetes 早期的2015年发起用作一个与 Kubernetes 交互的Java框架。在那个时候，Fabric8 项目期待成为一个运行在 Kubernetes 上的云原生微服务的 PaaS 平台。Fabric8 Kubernete 客户端库在 Fabric8 生态中扮演的关键角色，因为它通过 Kubernetes REST API 提供了一个抽象。

官方 Kubernetes Java 客户端由 [Brendan Burns](https://github.com/brendandburns)（他也是 Kubernetes 的创建者）在 2017 年开创，同时还有免想起他几个语言的库，如 PERL, Javascript, Python 等。所有的客户端看起来都是从一个 [OpenAPI generator](https://github.com/OpenAPITools/openapi-generator)脚本生成：[kubernetes-client/gen](https://github.com/kubernetes-client/gen)，Java客户端以同样的方式生成。因此它的使用方式与其它客户端很像，毕竟它们由同一个脚本生成。
## 2. 官方和 Fabric8 Java 客户端提供的包

![包比较](images/fabric8_vs_official_packages.png)
## 3. 用户数量
当我查看使用两个库的用户数量时，Fabric8 远远走在前头。我汇聚了所有报的使用统计，以下是基于 Github insights 的 Github 上的依赖数：
- Fabric8 Kubernetes 客户端（所有包）：8152 Github 仓库
- 官方 Kubernetes 客户端（所有包）：672 Github 仓库
## 4. 使用差异
现在让我们看看两种客户端用法上的差异。我们将查看用户使用 Kubernetes 客户端与 Kubernetes API 交互的公共用例。
### 列出名字空间里的所有 Pods( kubectl get pods ):
下面是列出一个特定名字空间里的所有 Pod 的例子，基本上与 `kubectl get pods` 命令等同。

[官方 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/kubernetes/TestingPodList.java)：

![Listing Pods with Official Kubernetes Client, see code in TestingPodList.java](images/list_pod_with_official_client.png)

[Fabric8 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/fabric8/PodListTest.java)：

![Listing Pods with Fabric8 Kubernetes Client, see code in PodListTest.java](images/list_pod_with_fabric8.png)
### 创建特定服务（kubectl create -f service.yml）
让我们看看一个例子，我们已经有了一个 Yaml 清单文件，我们将它作为一个 Java POJO（kubernetes Java model）加载，并应用于 Kubernetes 服务器。

[官方 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/kubernetes/LoadAndCreateService.java)：
```
ApiClient client = Config.defaultClient();
Configuration.setDefaultApiClient(client);

File file = new File(LoadAndCreateService.class.getResource("/test-svc.yaml").getPath());
V1Service yamlSvc = (V1Service) Yaml.load(file);

CoreV1Api api = new CoreV1Api();
V1Service createResult = api.createNamespacedService("rokumar", yamlSvc, null, null, null);
```
[Fabric8 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/fabric8/LoadAndCreateService.java)：
```
try (KubernetesClient client = new DefaultKubernetesClient()) {
    Service svc = client.services()
            .load(LoadAndCreateService.class.getResourceAsStream("/test-svc.yaml"))
            .get();

    client.services().inNamespace("rokumar").createOrReplace(svc);
}
```
### 监视 Pod（kubectl get pods -w）
因为监视涉及到简单 HTTP 调用，使用官方客户端监视 Pod 稍有不同。另一方面，Fabric8 Kubernetes 客户端使用 Web-sockets 监视资源。

[官方 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/kubernetes/WatchPods.java)：
```
ApiClient client = Config.defaultClient();
Configuration.setDefaultApiClient(client);
CoreV1Api api = new CoreV1Api();
Watch<V1Pod> watch =
        Watch.createWatch(
                client,
                api.listNamespacedPodCall("rokumar", null, null, null, null, null, 5, null, null, 5, Boolean.TRUE, null),
                new TypeToken<Watch.Response<V1Pod>>() {}.getType());
try {
    for (Watch.Response<V1Pod> item : watch) {
        System.out.printf("%s : %s%n", item.type, item.object.getMetadata().getName());
    }
} finally {
    watch.close();
}
```
[Fabric8 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/fabric8/PodWatchTest.java)：
```
try (KubernetesClient client = new DefaultKubernetesClient()) {
    Watch watch = client.pods().inNamespace("default").watch(new Watcher<Pod>() {
        @Override
        public void eventReceived(Action action, Pod pod) {
            System.out.printf("%s : %s%n", action.name(), pod.getMetadata().getName());
        }

        @Override
        public void onClose(WatcherException e) {
            System.out.printf("onClose : %s\n", e.getMessage());
        }

    });

    // Watch till 10 seconds
    Thread.sleep(10 * 1000);

    // Close Watch
    watch.close();
} catch (InterruptedException e) {
    e.printStackTrace();
}
```
### 使用构建器创建部署（kubectl create deploy）
你能够使用 Fabric8 Kubernetes 客户端构建器快速创建部署，它们基于[sundrio library](https://github.com/sundrio/sundrio)，也被移植进官方 Kubernetes 客户端库。你会注意到这些构建器在动态创建 Kubernetes 资源时很有用。

[官方 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/kubernetes/DeploymentDemo.java)：

![Creating a simple nginx Deployment using Official Kubernetes Client, see code in DeploymentDemo.java](images/creating_a_deployment_with_official.png)

[Fabric8 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/fabric8/SimpleDeploymentCreate.java)：

![Creating a simple nginx Deployment using Fabric8 Kubernetes Client, see code in SimpleDeploymentCreate.java](images/creating_a_deployment_with_fabric8.png)
### 创建自定义资源
当撰写 Kubernetes operators 时会被用刀，因此控制自定义资源是一项很重要的特性。Fabric8 和官方客户端都有自己的支持自定义资源的方式。

官方 Kubernetes 客户端并没有在主要的 `client-java` jar中提供 Kubernetes 自定义资源的支持。为了能够使用 `CustomResources` 你必须添加额外的依赖。

然而，Fabric8 Kubernetes 客户端库却不需要任何额外的依赖。下面是利用 Fabric8 和官方客户端控制名为 `Dummy` 的 `CustomResources` 的简单例子。

[官方 Kubernetes 客户端](https://github.com/rohanKanojia/fabric8-official-java-client-comparison/blob/master/src/main/java/io/kubernetes/CustomResourceDemo.java)：

为了能够在官方 Kubernetes 客户端中使用 CustomResources，你需要在你的代码中天津爱额外的依赖：
```
<dependency>
   <groupId>io.kubernetes</groupId>
   <artifactId>client-java-extended</artifactId>
   <version>${client-java.version}</version>
</dependency>
```
一旦这个依赖被安装，你就可以使用 `GenericKubernetesApi`，它是一个带两个参数的泛型类：资源类型和资源列表类型。你需要为你的自定义资源提供 POJOs。下面是一个如何使用它的例子：

![Creating a simple CustomResource using Official Kubernetes Client, see code in CustomResourceDemo.java](images/creating_a_customer_resource_with_official.png)

Fabric8 Kubernetes 客户端：

由于他的支持集成进了 Fabric8 API。你不需要任何额外的依赖即可使用 `CustomResources`。利用 Fabric8 Kubernetes 客户端你可以有两种方式使用`CustomResources`。
- [Typed API](https://github.com/fabric8io/kubernetes-client/blob/master/doc/CHEATSHEET.md#customresource-typed-api) (required POJOs)
- [Typeless API](https://github.com/fabric8io/kubernetes-client/blob/master/doc/CHEATSHEET.md#customresource-typeless-api) (doesn’t require any POJOs)

![Creating a Dummy Custom Resource using Fabric8 Typed API, see code in CustomResourceCreateDemo.java](images/creating_a_customer_resource_with_fabric8_typed.png)

![Creating a Dummy Custom Resource using Fabric8 Typeless API, see code in CustomResourceCreateTypeless.java](images/creating_a_customer_resource_with_fabric8_typeless.png)
## 5. 官方 Kubernetes 客户端独有特性
+ 能够通过不同的 apiVersions 提供对 Kubernetes 资源的支持。这在 Fabric8 中也开始支持，那被废所有的资源。但官方客户端为一个Deployment资源产生不同的类 [AppsV1Beta1Deployment](https://github.com/kubernetes-client/java/blob/master/kubernetes/src/main/java/io/kubernetes/client/models/AppsV1beta1Deployment.java), [V1Beta2Deployment](https://github.com/kubernetes-client/java/blob/master/kubernetes/src/main/java/io/kubernetes/client/models/V1beta2Deployment.java), 和 [V1Deployment](https://github.com/kubernetes-client/java/blob/master/kubernetes/src/main/java/io/kubernetes/client/models/V1Deployment.java)。
+ 支持 Azure 认证
+ 使用 Swagger 模式用于 Kubernetes 资源的生成
+ 不同 API 组有不同的入口。例如，使用 `ore/v1` 的包会使用 [CoreV1Api](https://github.com/kubernetes-client/java/blob/master/kubernetes/src/main/java/io/kubernetes/client/openapi/apis/CoreV1Api.java)，在 `apps/v1` 包里的所有资源使用 [AppsV1Api](https://github.com/kubernetes-client/java/blob/master/kubernetes/src/main/java/io/kubernetes/client/openapi/apis/AppsV1Api.java)
## 6. Fabric8  Kubernetes 客户端独有特性
+ 与 Kubernetes API 交互的丰富的 DSL（Domain Specific Language）。例如你可以赢一行代码 `client.pods().inAnyNamespace().list()` 实现一个简单的 `kubectl` 操作如 `kubectl get pods`。
+ 监控连接管理：Fabric8 Kubernetes 客户端使用 WebSockets，其底层支持监视和重连特性，这提供了监视 Kubernetes 资源的可靠的支持。
+ 等待直至条件支持集成进 DSL
+ 有许多用户工具来实现一些 Kubernetes 资源的简单任务
+ 通过系统属性，环境变量，~/.kube/config，ServiceAccount 令牌以及挂在的 CA 证书来实现集群连接配置。基本上，那意味着当从你的系统或从一个Pod内部使用客户端时你不需要做任何种类的配置。
+ 对 CustomResources 的原始支持，不需要提供任何类型或POJO。
+ 支持 Deployment 回滚：restart() , undo(), updateImage() 等都已经被集成进 DSL。
+ 支持客户端认证命令如 aws-iam-authenticator
+ 支持 OAuthToken 认证
+ 使用 Kubernetes Sources直接生成 Kuberneted 模板代码
+ 为了满足你的需求客户可以基于 KubernetesClient 实现扩展钩子。现在 Fabric8 Kubernetes 客户端已经有如下扩展：[Knative](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/knative), [Tekton](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/tekton), [Istio](https://github.com/snowdrop/istio-java-api), [ServiceCatalog](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/service-catalog) 和 [Kudo(当前处于WIP状态)](https://github.com/fabric8io/kubernetes-client/pull/2197)
## 7. 结论
到了这里我应该结束这篇博文，但等等，我还没有回答一个问题，“那个客户端是根号使用的那个？”。我使用 Fabric8 工作过，因此我通常会建议使用Fabric8，因为我认为他在提供 Java 开发体验上更好。因此，我把这留给用户，你可以根据自己的需求选择合适的那个。

你可以在 [Github仓库里](https://github.com/rohanKanojia/fabric8-official-java-client-comparison) 找到本博问礼的所有源代码。

我希望这篇博文能够帮助你找到适合你的需求的客户端，谢谢！
## 8. Appendix A: Kubernetes & OpenShift Java Client
### 8.1 用法
#### 8.1.1 创建一个客户
创建一个客户最简单的方法是：
```
KubernetesClient client = new DefaultKubernetesClient();
```
`DefaultOpenShiftClient` 实现了 `KubernetesClient` 和 `OpenShiftClient` 接口，因此如果你需要 `OpenShift` 扩展，比如 `Builds` 等，仅需如下代码：
```
OpenShiftClient osClient = new DefaultOpenShiftClient();
```
#### 8.1.2 配置客户
这将按照优先级顺序使用不同来源的设置：
- 系统属性
- 环境变量
- Kube 配置文件
- 服务账号令牌及挂载的 CA 证书

倾向于使用系统属性而非环境变量。下列系统属性和环境变量可用于配置：
属性 / 环境变量|描述|默认值
--------|--------|--------
kubernetes.disable.autoConfig / KUBERNETES_DISABLE_AUTOCONFIG|禁止自动配置|false
kubernetes.master / KUBERNETES_MASTER|Kubernetes master URL|https://kubernetes.default.svc
kubernetes.api.version / KUBERNETES_API_VERSION|API 版本|v1
openshift.url / OPENSHIFT_URL|OpenShift master URL|Kubernetes master URL 值
kubernetes.oapi.version / KUBERNETES_OAPI_VERSION|OpenShift API 版本|v1
kubernetes.trust.certificates / KUBERNETES_TRUST_CERTIFICATES|信任所有证书|false
kubernetes.disable.hostname.verification / KUBERNETES_DISABLE_HOSTNAME_VERIFICATION||false
kubernetes.certs.ca.file / KUBERNETES_CERTS_CA_FILE||
kubernetes.certs.ca.data / KUBERNETES_CERTS_CA_DATA||
kubernetes.certs.client.file / KUBERNETES_CERTS_CLIENT_FILE|
kubernetes.certs.client.data / KUBERNETES_CERTS_CLIENT_DATA||
kubernetes.certs.client.key.file / KUBERNETES_CERTS_CLIENT_KEY_FILE||
kubernetes.certs.client.key.data / KUBERNETES_CERTS_CLIENT_KEY_DATA||
kubernetes.certs.client.key.algo / KUBERNETES_CERTS_CLIENT_KEY_ALGO|客户端密钥加密算法|RSA
kubernetes.certs.client.key.passphrase / KUBERNETES_CERTS_CLIENT_KEY_PASSPHRASE||
kubernetes.auth.basic.username / KUBERNETES_AUTH_BASIC_USERNAME||
kubernetes.auth.basic.password / KUBERNETES_AUTH_BASIC_PASSWORD||
kubernetes.auth.tryKubeConfig / KUBERNETES_AUTH_TRYKUBECONFIG|配置客户端使用 Kubernetes 配置|true
kubeconfig / KUBECONFIG|读取的 kubernetes配置文件名|~/.kube/config
kubernetes.auth.tryServiceAccount / KUBERNETES_AUTH_TRYSERVICEACCOUNT|从服务账号配置客户端|true
kubernetes.tryNamespacePath / KUBERNETES_TRYNAMESPACEPATH|从 Kubernete 服务账号名字空间路径配置客户端命名空间|true
kubernetes.auth.token / KUBERNETES_AUTH_TOKEN||
kubernetes.watch.reconnectInterval / KUBERNETES_WATCH_RECONNECTINTERVAL|监视器重连间隔，单位为毫秒|1000
kubernetes.watch.reconnectLimit / KUBERNETES_WATCH_RECONNECTLIMIT|重连尝试次数(-1意为无线)|-1
kubernetes.connection.timeout / KUBERNETES_CONNECTION_TIMEOUT|毫秒计数的连接超时 (0 意为没有超时)|10000
kubernetes.request.timeout / KUBERNETES_REQUEST_TIMEOUT|以毫秒计数的读超时|10000
kubernetes.rolling.timeout / KUBERNETES_ROLLING_TIMEOUT|以毫秒计数的Roll超时|900000
kubernetes.logging.interval / KUBERNETES_LOGGING_INTERVAL|以毫秒计数的日志间隔|20000
kubernetes.scale.timeout / KUBERNETES_SCALE_TIMEOUT|以毫秒计数的缩放超时|600000
kubernetes.websocket.timeout / KUBERNETES_WEBSOCKET_TIMEOUT|以毫秒计数的Websocket超时|5000
kubernetes.websocket.ping.interval / kubernetes_websocket_ping_interval|以毫秒计数的Websocket Ping间隔|30000
kubernetes.max.concurrent.requests / KUBERNETES_MAX_CONCURRENT_REQUESTS||64
kubernetes.max.concurrent.requests.per.host / KUBERNETES_MAX_CONCURRENT_REQUESTS_PER_HOST|5
kubernetes.impersonate.username / KUBERNETES_IMPERSONATE_USERNAME|Impersonate-User HTTP header 值|
kubernetes.impersonate.group / KUBERNETES_IMPERSONATE_GROUP|Impersonate-Group HTTP header 值|
kubernetes.tls.versions / KUBERNETES_TLS_VERSIONS|,分割的TLS版本|TLSv1.2
kubernetes.truststore.file / KUBERNETES_TRUSTSTORE_FILE||
kubernetes.truststore.passphrase / KUBERNETES_TRUSTSTORE_PASSPHRASE||
kubernetes.keystore.file / KUBERNETES_KEYSTORE_FILE||
kubernetes.keystore.passphrase / KUBERNETES_KEYSTORE_PASSPHRASE||

另外，你可以使用 `ConfigBuilder` 为 Kubernetes 客户端创建一个配置对象：
```
Config config = new ConfigBuilder().withMasterUrl("https://mymaster.com").build();
KubernetesClient client = new DefaultKubernetesClient(config);
```
读所有资源使用 DSL 是一样的。

列出资源：
```
NamespaceList myNs = client.namespaces().list();

ServiceList myServices = client.services().list();

ServiceList myNsServices = client.services().inNamespace("default").list();
```
得到一个资源：
```
Namespace myns = client.namespaces().withName("myns").get();

Service myservice = client.services().inNamespace("default").withName("myservice").get();
```
删除：
```
Namespace myns = client.namespaces().withName("myns").delete();

Service myservice = client.services().inNamespace("default").withName("myservice").delete();
```
使用从 Kubernetes Model 来的内联构建器来编辑资源：
```
Namespace myns = client.namespaces().withName("myns").edit(n -> new NamespaceBuilder(n)
                   .editMetadata()
                     .addToLabels("a", "label")
                   .endMetadata()
                   .build());

Service myservice = client.services().inNamespace("default").withName("myservice").edit(s -> new ServiceBuilder(s)
                     .editMetadata()
                       .addToLabels("another", "label")
                     .endMetadata()
                     .build());
```
同样的思路下你可以内联创建：
```
Namespace myns = client.namespaces().create(new NamespaceBuilder()
                   .withNewMetadata()
                     .withName("myns")
                     .addToLabels("a", "label")
                   .endMetadata()
                   .build());

Service myservice = client.services().inNamespace("default").create(new ServiceBuilder()
                     .withNewMetadata()
                       .withName("myservice")
                       .addToLabels("another", "label")
                     .endMetadata()
                     .build());
```
为了 SecurityContextConstraints 你可以设置资源的 apiVersion：
```
SecurityContextConstraints scc = new SecurityContextConstraintsBuilder()
		.withApiVersion("v1")
		.withNewMetadata().withName("scc").endMetadata()
		.withAllowPrivilegedContainer(true)
		.withNewRunAsUser()
		.withType("RunAsAny")
		.endRunAsUser()
		.build();
```
**跟随事件**

把 io.fabric8.kubernetes.api.model.Event 用作监视器的 T：
```
client.events().inAnyNamespace().watch(new Watcher<Event>() {

  @Override
  public void eventReceived(Action action, Event resource) {
    System.out.println("event " + action.name() + " " + resource.toString());
  }

  @Override
  public void onClose(KubernetesClientException cause) {
    System.out.println("Watcher close due to " + cause);
  }

});
```
**用扩展工作**

kubernetes API 定义了一套扩展如 daemonSets, jobs, ingresses 等，它们在 extensions() DSL 中是有用的：比如列出所有的工作（jobs）
```
jobs = client.batch().jobs().list();
```
#### 8.1.3 从外部源加载资源
某些情况下你需要从外部源头读入资源，而不是使用客户端 DSL。对这些情况客户端允许你从下面（这些源头）加载资源：
- 一个文件（支持 java.io.File 和 java.lang.String）
- 一个 URL
- 一个输入流

一旦资源已经加载，就可以像你自己创建的一样随意处理它。例如，让我们从一个 yaml 文件读一个Pod并处理它：
```
Pod refreshed = client.load('/path/to/a/pod.yml').fromServer().get();
Boolean deleted = client.load('/workspace/pod.yml').delete();
LogWatch handle = client.load('/workspace/pod.yml').watchLog(System.out);
```
#### 8.1.4 传递一个资源引用给客户
同样的思路，你可以使用从外部源创建的对象（或者是一个引用或其字符串表达）。例如：
```
Pod pod = someThirdPartyCodeThatCreatesAPod();
Boolean deleted = client.resource(pod).delete();
```
#### 8.1.5 适配一个客户
客户端支持可插拔的适配器。一个示例适配器是[OpenShrift适配器](https://github.com/fabric8io/kubernetes-client/blob/master/openshift-client/src/main/java/io/fabric8/openshift/client/OpenShiftExtensionAdapter.java)，它允许将一个已经存在的 [KubernetesClient](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-client/src/main/java/io/fabric8/kubernetes/client/KubernetesClient.java) 适配成一个 [OpenShiftClient](https://github.com/fabric8io/kubernetes-client/blob/master/openshift-client/src/main/java/io/fabric8/openshift/client/OpenShiftClient.java)。例如：
```
KubernetesClient client = new DefaultKubernetesClient();

OpenShiftClient oClient = client.adapt(OpenShiftClient.class);
```
客户端支持 isAdaptable() 方法来检测是否可以适配，如果可以返回 true。
```
KubernetesClient client = new DefaultKubernetesClient();
if (client.isAdaptable(OpenShiftClient.class)) {
    OpenShiftClient oClient = client.adapt(OpenShiftClient.class);
} else {
    throw new Exception("Adapting to OpenShiftClient not support. Check if adapter is present, and that env provides /oapi root path.");
}
```
**适配和关闭**

注意使用 adapt() 时适配方和目标都共ian个同一资源（底层 http 客户端， 线程池等）。这意味着 close() 并不要求在通过适配创建的每一个实例上调用。在任一适配管理的对象上或原始对象上调用 close() 都会干净地清理掉所有的资源，然后任一对象都不应该再被使用。
### 8.2 模拟 Kubernetes
### 8.3 谁在使用 Fabric8 Kubernetes 客户端库?
- 扩展（Extensions）：
  + [lstio API](https://github.com/snowdrop/istio-java-api)
  + [Service Catalog API](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/service-catalog)
  + [Knative](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/knative)
  + [Tekton](https://github.com/fabric8io/kubernetes-client/tree/master/extensions/tekton)
- 框架/库/工具（Frameworks/Libraries/Tools）：
  + [Arquillian Cube}(http://arquillian.org/arquillian-cube/)
  + [Apache Camel](https://github.com/apache/camel/blob/master/README.md)
  + [Apache Spark](https://github.com/apache/spark/tree/master/resource-managers/kubernetes)
  + [Jaeger Kubernetes](https://github.com/jaegertracing/jaeger-kubernetes)
  + [Loom](https://github.com/datawire/loom)
  + [Microsoft Azure Libraries for Java](https://github.com/Azure/azure-libraries-for-java)
  + [Spinnaker Halyard](https://github.com/spinnaker/halyard)
  + [Spring Cloud Connectors for Kubernetes](https://github.com/spring-cloud/spring-cloud-kubernetes-connector)
  + [Spring Cloud Kubernetes](https://github.com/fabric8io/spring-cloud-kubernetes)
- 持续集成插件（CI Plugins）:
  + [Deployment Pipeline Plugin (Jenkins)](https://github.com/pearsontechnology/deployment-pipeline-jenkins-plugin)
  + [Kubernetes Eleastic Agent (GoCD)](https://github.com/gocd/kubernetes-elastic-agents)
  + [Kubernetes Plugin (Jenkins)](https://github.com/jenkinsci/kubernetes-plugin)
  + [Kubernetes Pipeline Plugin (Jenkins)](https://github.com/jenkinsci/kubernetes-pipeline-plugin)
  + [OpenShift Sync Plugin (Jenkins)](https://github.com/openshift/jenkins-sync-plugin)
  + [Kubernetes Plugin (Teamcity from Jetbrains)](https://github.com/JetBrains/teamcity-kubernetes-plugin)
  + [Kubernetes Agents for Bamboo (WindTunnel Technologies)](https://marketplace.atlassian.com/apps/1222674/kubernetes-agents-for-bamboo)
- [构建工具](Build Tools)：
  + [Fabric8 Maven Plugin](https://github.com/fabric8io/fabric8-maven-plugin)
  + [Eclipse JKube](https://github.com/eclipse/jkube)
  + [Gradle Kubernetes Plugin](https://github.com/bmuschko/gradle-kubernetes-plugin)
- [平台]（Platforms）：
  + [Apache Openwhisk](https://github.com/apache/incubator-openwhisk)
  + [Eclipse che](https://www.eclipse.org/che/)
  + [EnMasse](https://enmasse.io/)
  + [Openshift.io (Launcher service)](https://github.com/fabric8-launcher)
  + [Spotify Styx](https://github.com/spotify/styx)
  + [Strimzi](https://github.com/strimzi/)
  + [Syndesis](https://syndesis.io/)
- 专有平台:
  + [vCommander](https://www.embotics.com/hybrid-cloud-management-platform)
### 8.4 [Kubernetes Operators in Java Written using Fabric8 Kubernetes Client](https://github.com/fabric8io/kubernetes-client/blob/master/doc/KubernetesOperatorsInJavaWrittenUsingFabric8.md)
### 8.5 Kubernetes and Red Hat OpenShift Compatibility Matrix
### 8.6 [Kubernetes 客户端备忘单](https://github.com/fabric8io/kubernetes-client/blob/master/doc/CHEATSHEET.md)
### 8.7 Kubectl Java 对等工具
下面的表格提供了 `kubectl` 和 Kubernetes Java 客户端的映射。大多数映射很直接且线性操作。但是，某些可能需要稍微多一点的代码来去的同样的结果。

kubectl|Fabric8 Kubernetes Client
--------|--------
kubectl config view|[ConfigViewEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigViewEquivalent.java)
kubectl config get-contexts|[ConfigGetContextsEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigGetCurrentContextEquivalent.java)
kubectl config current-context|[ConfigGetCurrentContextEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigGetCurrentContextEquivalent.java)
kubectl config use-context minikube|[ConfigUseContext.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigUseContext.java)
kubectl config view -o jsonpath='{.users[*].name}'|[ConfigGetCurrentContextEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigGetCurrentContextEquivalent.java)
kubectl get pods --all-namespaces|[PodListGlobalEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodListGlobalEquivalent.java)
kubectl get pods|[PodListEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodListEquivalent.java)
kubectl get pods -w|[PodWatchEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodWatchEquivalent.java)
kubectl get pods --sort-by='.metadata.creationTimestamp'|[PodListGlobalEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodListGlobalEquivalent.java)
kubectl run|[PodRunEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodRunEquivalent.java)
kubectl create -f test-pod.yaml|[PodCreateYamlEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodCreateYamlEquivalent.java)
kubectl exec my-pod -- ls /|[PodExecEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodExecEquivalent.java)
kubectl delete pod my-pod|[PodDelete.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodDelete.java)
kubectl delete -f test-pod.yaml|[PodDeleteViaYaml.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodDeleteViaYaml.java)
kubectl cp /foo_dir my-pod:/bar_dir|[UploadDirectoryToPod.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/UploadDirectoryToPod.java)
kubectl cp my-pod:/tmp/foo /tmp/bar|[DownloadFileFromPod.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/DownloadFileFromPod.java)
kubectl cp my-pod:/tmp/foo -c c1 /tmp/bar|[DownloadFileFromMultiContainerPod.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/DownloadFileFromMultiContainerPod.java)
kubectl cp /foo_dir my-pod:/tmp/bar_dir|[UploadFileToPod.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/UploadFileToPod.java)
kubectl logs pod/my-pod|[PodLogsEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodLogsEquivalent.java)
kubectl logs pod/my-pod -f|[PodLogsFollowEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodLogsFollowEquivalent.java)
kubectl logs pod/my-pod -c c1|[PodLogsMultiContainerEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodLogsMultiContainerEquivalent.java)
kubectl port-forward my-pod 8080:80|[PortForwardEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PortForwardEquivalent.java)
kubectl get pods --selector=version=v1 -o jsonpath='{.items[*].metadata.name}'|[PodListFilterByLabel.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodListFilterByLabel.java)
kubectl get pods --field-selector=status.phase=Running|[PodListFilterFieldSelector.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodListFilterFieldSelector.java)
kubectl get pods --show-labels|[PodShowLabels.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodShowLabels.java)
kubectl label pods my-pod new-label=awesome|[PodAddLabel.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodAddLabel.java)
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq|[PodAddAnnotation.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/PodAddAnnotation.java)
kubectl get configmap cm1 -o jsonpath='{.data.database}'|[ConfigMapJsonPathEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ConfigMapJsonPathEquivalent.java)
kubectl create -f test-svc.yaml|[LoadAndCreateService.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/LoadAndCreateService.java)
kubectl create -f test-deploy.yaml|[LoadAndCreateDeployment.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/LoadAndCreateDeployment.java)
kubectl set image deploy/d1 nginx=nginx:v2|[RolloutSetImageEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/RolloutSetImageEquivalent.java)
kubectl scale --replicas=4 deploy/nginx-deployment|[ScaleEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/ScaleEquivalent.java)
kubectl rollout restart deploy/d1|[RolloutRestartEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/RolloutRestartEquivalent.java)
kubectl rollout pause deploy/d1|[RolloutPauseEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/RolloutPauseEquivalent.java)
kubectl rollout resume deploy/d1|[RolloutResumeEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/RolloutResumeEquivalent.java)
kubectl rollout undo deploy/d1|[RolloutUndoEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/RolloutUndoEquivalent.java)
kubectl create -f test-crd.yaml|[LoadAndCreateCustomResourceDefinition.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/LoadAndCreateCustomResourceDefinition.java)
kubectl create -f customresource.yaml|[CustomResourceCreateDemo.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/CustomResourceCreateDemo.java)
kubectl create -f customresource.yaml|[CustomResourceCreateDemoTypeless.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/CustomResourceCreateDemoTypeless.java)
kubectl get ns|[NamespaceListEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/NamespaceListEquivalent.java)
kubectl apply -f test-resource-list.yml|[CreateOrReplaceResourceList.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/CreateOrReplaceResourceList.java)
kubectl get events|[EventsGetEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/EventsGetEquivalent.java)
kubectl top nodes|[TopEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/TopEquivalent.java)
kubectl auth can-i create deployment.apps|[CanIEquivalent.java](https://github.com/fabric8io/kubernetes-client/blob/master/kubernetes-examples/src/main/java/io/fabric8/kubernetes/examples/kubectl/equivalents/CanIEquivalent.java)

## Reference
- [Fabric8 和官方 Kubernetes Java 客户端的区别](https://itnext.io/difference-between-fabric8-and-official-kubernetes-java-client-3e0a994fd4af?gi=2835455667bd)
- [Client Libraries](https://kubernetes.io/docs/reference/using-api/client-libraries/)
- [fabric8io/kubernetes-client](https://github.com/fabric8io/kubernetes-client)
- [Kubenretes Java Client](https://github.com/kubernetes-client/java)
- [fabric8/kubernetes-client JavaDoc](https://www.javadoc.io/doc/io.fabric8/kubernetes-client)
- [Fabric8 Kubernetes Java Client Cheat Sheet](https://github.com/fabric8io/kubernetes-client/blob/master/doc/CHEATSHEET.md)
