## Submitting Applications

在 Spark `bin` 目录下的 `spark-submit` 脚本用于在一本集群上启动一个应用。通过一个统一的接口，它能够使用 Spark 支持的所有[集群管理器](https://spark.apache.org/docs/latest/cluster-overview.html#cluster-manager-types)，因此你不需要为每一个集群管理器特别配置你的应用。

### 打包你的应用依赖

如果你的代码依赖于其它的项目，为了把你的代码分发到一个 Spark 集群上你需要把它们与你的应用打包在一起。为了实现这个，创建一个 assembly jar (或 “uber” jar) 以包含你代码及其依赖。[sbt](https://github.com/sbt/sbt-assembly) 和 [Maven](http://maven.apache.org/plugins/maven-shade-plugin/)都拥有装配插件。当创建 assembly jars 时，将 Spark 和 Hadoop 列为 `provided` 依赖；它们不需被打包进来，原因在于它们由集群管理器在运行时提供。一旦你已经拥有了一个 assembly jar，你可以调用 `bin/spark-submit` 脚本如下所示并传递 jars 文件。

对于 Python，你可以使用 `spark-submit` 的 `--py-files` 参数添加 `.py`, `.zip` 或 `.egg` 文件以随你的应用分发。如果你依赖多个 Python 文件，我们建议将其打包为一个 `.zip` 或 `.egg`。对第三方 Python 依赖，请参见 [Python Package Management](https://spark.apache.org/docs/latest/api/python/user_guide/python_packaging.html)。

### 使用 spark-submit 启动应用

一旦一个用户应用打包完成，它就能够通过 `bin/spark-submit` 启动。这个脚本帮助设置带 Spark 及其依赖的类路径，能够支持 Spark 支持的不同的集群管理器和部署模式。

```
./bin/spark-submit \
  --class <main-class> \
  --master <master-url> \
  --deploy-mode <deploy-mode> \
  --conf <key>=<value> \
  ... # other options
  <application-jar> \
  [application-arguments]
```

一些常见选项包括：

- --class：你的应用的入口点（例如 `org.apache.spark.examples.SparkPi`）
- --master： 集群 master URL (例如 `spark://23.195.26.187:7077`)
- --deploy-mode：将你的驱动器部署到工作节点 (cluster) 或者本地作为一个外部客户 (client) (默认: client)
- --conf：任意 Spark 配置属性，格式为 `key=value`。对任意包含空格的值，用引号包围如 “key=value”。多个配置可以以独立参数提供（例如 `--conf <key>=<value>` `--conf <key2>=<value2>`）
- application-jar：包括你的应用及其依赖的 `bundled jar` 的路径。该 URL 必须在集群范围内全局可见，例如，一个 `hdfs://` 路径或一个 `file://`，对所有节点可见。
- application-arguments：传递给你的主类的 `main` 方法的参数。

一个常见的部署策略是从一个网关机器上提交你的应用，它物理上与你的工作节点在一起（例如位于一个单独 EC2 集群中的 Master 节点）。在这种设置下，`client` 模式是合适的。在 `client` 模式下，启动器直接在 `spark-submit` 进程里启动以充当一个集群客户端。应用的输入输出被附在终端上。因此，这种模式尤其适用于涉及到 `REPL` 的应用（例如 `Spark shell`）。

另外，如哦你的应用从一个远离你的工作节点的机器（例如，从你的本地 Laptop）提交，`cluster` 模式常被选用以最小化驱动器即执行器之间的网络延迟。当前，独立模式不支持 Python 应用的集群模式。

对于 Python 应用，仅仅传递一个 `.py` 以代替 `<application-jar>`，并利用 `--py-files` 将 Python `.zip`, `.egg` 或 `.py` 文件添加到搜索路径。

有一些选项是特定于所选用的[集群管理器](https://spark.apache.org/docs/latest/cluster-overview.html#cluster-manager-types)。例如，对于 [Spark standalone cluster](https://spark.apache.org/docs/latest/spark-standalone.html) 的集群部署模式，你也可指定 `--supervise` 来确保如果驱动器失败并以非零值退出，那么它将自动重启。为了列出 `spark-submit` 所有可用的选项，以 `--help` 选项运行它。下面是常用选项的一些例子：

```
# Run application locally on 8 cores
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master local[8] \
  /path/to/examples.jar \
  100

# Run on a Spark standalone cluster in client deploy mode
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://207.184.161.138:7077 \
  --executor-memory 20G \
  --total-executor-cores 100 \
  /path/to/examples.jar \
  1000

# Run on a Spark standalone cluster in cluster deploy mode with supervise
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://207.184.161.138:7077 \
  --deploy-mode cluster \
  --supervise \
  --executor-memory 20G \
  --total-executor-cores 100 \
  /path/to/examples.jar \
  1000

# Run on a YARN cluster in cluster deploy mode
export HADOOP_CONF_DIR=XXX
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master yarn \
  --deploy-mode cluster \
  --executor-memory 20G \
  --num-executors 50 \
  /path/to/examples.jar \
  1000

# Run a Python application on a Spark standalone cluster
./bin/spark-submit \
  --master spark://207.184.161.138:7077 \
  examples/src/main/python/pi.py \
  1000

# Run on a Mesos cluster in cluster deploy mode with supervise
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master mesos://207.184.161.138:7077 \
  --deploy-mode cluster \
  --supervise \
  --executor-memory 20G \
  --total-executor-cores 100 \
  http://path/to/examples.jar \
  1000

# Run on a Kubernetes cluster in cluster deploy mode
./bin/spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master k8s://xx.yy.zz.ww:443 \
  --deploy-mode cluster \
  --executor-memory 20G \
  --num-executors 50 \
  http://path/to/examples.jar \
  1000
```

### Master URLs

传递给 Spark 的 master URL 可以是下列格式中的一个：

Master URL|Meaning
--------|--------
local|在本地以一个工作线程运行 Spark (例如，完成没有并行)。
local[K]|在本地以 K 个工作线程运行 Spark (理想情况下，将其设置为你的机器上的核数)。
local[K,F]|在本地以 K 个工作线程运行 Spark，最大失败数 F。(参见 [spark.task.maxFailures](https://spark.apache.org/docs/latest/configuration.html#scheduling) 以获取对这个变量的解释)
local[*]|在本地以运行 Spark，其工作线程数等于你的机器的逻辑核数。
local[*,F]|在本地以运行 Spark，其工作线程数等于你的机器的逻辑核数，最大失败数 F。
local-cluster[N,C,M]|Local-cluster 仅用于单元测试。它在一个拥有 N 个工作线程，每个工作者 C 个核和 M 兆内存 的 JVM 内模拟一个分布式集群。
spark://HOST:PORT|连接到给定的[Spark standalone cluster](https://spark.apache.org/docs/latest/spark-standalone.html)。端口号必须是你的 master 配置好可用的，默认为 7077。
spark://HOST1:PORT1,HOST2:PORT2|连接到给定的 [Spark standalone cluster with standby masters with Zookeeper](https://spark.apache.org/docs/latest/spark-standalone.html#standby-masters-with-zookeeper)。该列表必须包含通过 `ZooKeeper` 建立起来的高可用集群包含的所有 `master` 机器。端口号必须是你的 master 配置好可用的，默认为 `7077`。
mesos://HOST:PORT|连接到一个给定的 [Mesos](https://spark.apache.org/docs/latest/running-on-mesos.html) 集群。端口号必须是你的 master 配置好可用的，默认为 `5050`。或者，对于一个使用 ZooKeeper 的 Mesos 集群, 使用 `mesos://zk://...`。 为了以 `--deploy-mode cluster` 提交，`HOST:PORT` 应配置好以连接到 [MesosClusterDispatcher](https://spark.apache.org/docs/latest/running-on-mesos.html#cluster-mode)。
yarn|依赖 `--deploy-mode` 的值以 client 或 cluster 模式连接到一个 [YARN](https://spark.apache.org/docs/latest/running-on-yarn.html) 集群。该集群位置能够基于 `HADOOP_CONF_DIR` 或 `YARN_CONF_DIR` 变量找到。
k8s://HOST:PORT|依赖 `--deploy-mode` 的值以 client 或 cluster 模式连接到一个 [Kubernetes](https://spark.apache.org/docs/latest/running-on-kubernetes.html) 集群。主机和端口指向 [Kubernetes API Server](https://kubernetes.io/docs/reference/generated/kube-apiserver/)，默认情况下它使用 TLS 连接。 为了强迫它使用非加密连接，你可以使用 `k8s://http://HOST:PORT`。

### 从一个文件里加载配置

spark-submit 脚本从一个属性文件加载默认 [Spark configuration values](https://spark.apache.org/docs/latest/configuration.html) 并将它们传递给你的应用。默认地，它将从 Spark 目录中的 `conf/spark-defaults.conf` 读取选项。更多细节，请参看 [loading default configurations](https://spark.apache.org/docs/latest/configuration.html#loading-default-configurations) 一节。

通过这种方式加载默认 Spark 配置可以免除传递选项给 `spark-submit` 的需要。例如，如果 `spark.master` 属性已经设置，你就可以从 `spark-submit` 忽略 `--master` 参数。基本上，在一个 `SparkConf` 中设置的配置值拥有最大优先级，然后是传递给 `spark-submit` 的标记，再然后是默认文件中的值。

如果你曾经不清楚配置选项来自哪里，你可以通过运行 `spark-submit` 带 `--verbose` 选项以打印细粒度的调试信息。

### 高级依赖管理

当使用 `spark-submit` 时，应用 jar 文件以及通过 `--jars` 选项包进来的 jar 文件将会被自动传送至集群上。在 `--jars` 之后提供的 URLs 必须以逗号分隔。这个列表在驱动器以及执行器的类路径上被包含。路径扩展不适用于 `--jars`。

Spark 使用下面的 URL 规则来允许不同的 jar 传布策略。

- **file**: - 绝对路径和 file:/ URIs 由驱动器的 HTTP 文件服务器提供服务；每个执行器从 驱动器的 HTTP 服务器上拉取文件。
- **hdfs:, http:, https:, ftp**: - 这些如期待的那样从 URI 拉取文件和 JARs。
- **local**: - 一个以 `local:/` 开头的 URI 期待在每一个工作节点以本地文件的形式存在。这意味着没有网络 IO，当有大文件/JARs 需要被上传到每个工作其，或通过 NFS, GlusterFS 共享时， 它可以工作得很好。

注意对执行节点上的每一个 `SparkContext JARs` 和 `files` 都被拷贝到工作目录，随时间流逝，这可能会导致大量空间被用尽，故需要清理。使用 YARN 时，清理被自动处理；但对于  Spark 独立集群，自动清理可以通过 `spark.worker.cleanup.appDataTtl` 属性配置。

用户也可能包含通过  `--packages` 提供的一套逗号分隔的 Maven 依赖列表。所有传递性的依赖在四用这个命令时会被处理。额外的仓库（比如在 SBT 中解析）可被 `--repositories` 标记以逗号分隔的列表形式添加。（注意需要密码保护的仓库的凭证可以通过某些场景下的仓库 URI 提供，例如 `https://user:password@host/...`。注意当以这种方式提供凭证时要小心）。这些命令可被用于包在 Spark 包里的 `pyspark`, `spark-shell`, 以及 `spark-submit`。

对于 Python，对等的 `--py-files` 选项能被用于分发 `.egg`, `.zip` 和 `.py` 库至执行器。 

### 更多信息

一旦你部署了你的应用，[cluster mode overview](https://spark.apache.org/docs/latest/cluster-overview.html) 描述了设计分布式执行的组件，以及如何监控及调试应用。

### Reference

- [Submitting Applications](https://spark.apache.org/docs/latest/submitting-applications.html)
- [Cluster Mode Overview](https://spark.apache.org/docs/latest/cluster-overview.html)