# 监控一个Spring Boot应用
## 1. 基础
### 1.1 需求
在我们趟进任何特定技术细节之前，理解我们期望从一个监控系统得到什么事非常重要的。对我来说，监控是一切能让我知晓什么时候我的应用出了问题，能给我足够星系了解系统运行状态的东西。它应该包括：
- 从应用内部暴露重要指标
- 随时间汇集指标
- 提供某种方式配置针对指标的规则
- 当规则被打破时通过配置渠道发送警告
- 提供可视化和图形化指标的能力

日志方案不在本文讨论范围里。

让我们来看看上面的每一个需求并添加一些细节。在本系列的下一篇文章中，我们将详细讨论每一个，告诉你如何实现它。
### 1.2 从一个Spring Boot 应用到出指标
清楚地讲，但我谈论指标时我是指从应用内部一个值的度量。下面是一些例子：
- 当前内存使用
- HTTP请求数
- HTTP请求处理时长（延迟）
- 使用线程数

这些都是系要知道的有用指标，而且幸运的是Spring Boot 2.0 已经通过某些简单配置就免费暴露了它们：
- 添加 [micrometer-registry-prometheus](https://mvnrepository.com/artifact/io.micrometer/micrometer-registry-prometheus) 依赖到你的项目
- 添加 [spring-boot-starter-actuator](https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-actuator) 依赖到你的项目
- 添加`management.endpoints.web.exposure.include=prometheus`到你的`application.properties`。

一旦这些已经被添加，你可以导航到 `/actuator/prometheus`，从而能看到默认情况下你的Spring Boot应用可以导出的所有指标。

如果你不想自己设置这些，你可以使用我自己制作的[Docker镜像](https://cloud.docker.com/u/tkgregory/repository/docker/tkgregory/sample-metrics-application)，它在Docker Hub上可得：
```
docker run -p 8080:8080 tkgregory/sample-metrics-application:latest
```
然后你可以代开链接 `http://localhost:8080/actuator/prometheus`，从而看到这些指标：
![Spring Boot Default Metrics](images/springboot_default_metrics.png)

你看到的指标都是键值对，仅仅是简单的指标名字和值。它们代表指标的当前值。为了随时间汇集指标，从而是我们看到趋势，我们需要一个不同的工具。
### 1.3 随时间汇集指标
现在我们已经有应用暴露出来的指标，我们需要一种方式去拉取它们，并保留其历史，为了这些：
- 我们可以看到历史数据
- 我们可以看到随时间的数据从而得到一些测量如速率
- 我们可以以更容易的方式看到数据

幸运的是已经有这样的工具，[Prometheus](https://prometheus.io/)，下图是该服务如何工作的一个高度概括的架构图：
![Prometheus](images/Prometheus-overview-1.png)

你能看到，它不间断地从配置的应用哪里拉取数据。如此，它就包含了我们配置的时间放微里所有应用的历史数据。

我们可以查询Prometheus， 搜索书籍并将它们以一种适合我们需求的方式返回。不仅如此，别的应用也可查询Prometheus。例如，图形应用可能想查询随时间的请求数，并以一种可视化的方式展示：
![Prometheus Query](images/prometheus-metrics-query.png)
### 1.4 对指标配置规则
持续不断地监控指标以应对应用问题是没有意义的，如此有神恶魔乐趣可言呢？

作为替代，可以在指标上制定规则，如果被打破，就把问题向我们告警。这里是一些示例：
- 内存使用率超过`95%`
- 所有请求中返回`404`数超过`10%`
- 平均回复返回时长超过`500 ms`

Prometheus 给了我们一种很容易的方式来配置规则，当其被打破时可通过另一个工具[AlertManager](https://prometheus.io/docs/alerting/alertmanager/)告警。
### 1.5 通过配置通道发送警报
当一个规则被打破时，它需要某种方式通知到合适的人。这有点微妙，并非所有的警告是一个“在半夜叫醒我”的那种，并且并非所有警告应该发送至同一人。

幸运地，AlertManager 允许你配置你如何期望警告精确地“浮现”。当一条规则在Prometheus 中被配置时，你可以配置它为一个标签，该标签可被AlertManager 用于决定它应该被精确地送往何处。例如，你可能有一个标签`application`，它用于决定警告应该被送往那个团队。

默认地，AlertManager 可以发送警告到不同地渠道，例如email, Slack, 和 webhooks。
### 1.6 可视化和图形化能力
当你半夜收到一个警告，需要一个简单的方式来快速理解应用发生了什么。某些种类的预配置仪表盘，能够让我们以可视化的方式看到某些重要指标，讲师非常理想的。毕竟，可视化的数据是让我们理解情况并制定下一步计划最快速（有效）的。

[Grafana](https://grafana.com/)就是这样的一个工具，他可以与Prometheus直接集成。并允许我们为我们的应用构建有用的仪表板。这些会自动刷新，并提供了某一段时间缩放值最小的能力。

而且，一旦你构建了一个仪表板，你可以为其它的应用复用它。因此，如果你有一套相似的Spring Boot应用，只要他们暴露相似的指标，你就可以复用仪表板。

![Grafana Dashboard](images/grafana_dashboard.png)
### 1.7 结论
用用监控绝对非常重要，应该在应用开发过程中就被考虑到而非之后。当前可用的工具如Spring Boot, Prometheus, AlertManager, 何 Grafana，使得我们为我们的应用创建一个监控方案相当直截了当。
### 1.8 资源
如果你倾向于射频格式学习，从[Tom Gregory Tech](https://www.youtube.com/channel/UCxOVEOhPNXcJuyfVLhm_BfQ) YouTube频道看看本文的伴生视频。
## 2. Prometheus
### 2.1 概貌
Prometheus是一个服务，它通过轮询一套配置的目标应用来获取它们的指标数据值。在Prometheus 的术语中，轮询被称为刮（scraping）。

高级概览如下图：
![Prometheus](images/Prometheus-overview-1.png)

Prometheus 可被配置为从任意多的应用刮取指标。一旦Prometheus 获取到这些数据，Prometheus 将以某种方式存储它们并建立索引，然后我们可以以欧中有意义的方式查询数据。
### 2.2 指标语法
一个应用必须在端口上以一种特殊格式向Prometheus 暴露指标。在Spring Boot中如果你遵从上个Post的步骤，你就会自动获得该功能。在Spring Boot中为Prometheus刮取 暴露的端口位于`/actuator/prometheus`。

一个实例指标如下所示：
```
http_server_requests_seconds_count{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/doit",} 6.0
```
起个事遵从：
```
metric_name{labe1Name="label1Value",label2Name="label2Value",...}
```
- `http_server_requests_seconds_count`是一个持有HTTP 请求数量的指标（不用担心其名字中包含单词`seconds`）。了解更多默认指标，请参考文章[Spring Boot默认指标](https://tomgregory.com/spring-boot-default-metrics/)。
- `exception, method, outcome, status, 和 uri`是将ian个死指标组合在一起的有用的标签。例如，任何对 `/doit` 的GET请求的成功返回（200)都会导致指标递增。
### 2.3 查询语法
如果一个像上面提到的指标已经被Prometheus的刮取过程消费（默认每15秒钟一次），那我们就可以查询它了。
#### 基本查询
在这种基本形式下，查询语法与指标语法非常相似。例如，为了得到http_server_requests_seconds_count metric指标的所有值，我晕行下买你的查询：
```
http_server_requests_seconds_count
```
它将给我们返回下面的数据：
```
http_server_requests_seconds_count{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/**/favicon.ico"} 9

http_server_requests_seconds_count{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/actuator/prometheus"} 1

http_server_requests_seconds_count{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/doit"} 10
```
这代表已经静茹应用的所有请求，包括：
- 一个前面谈到的对`/doit`请求的指标
- 一个 `/actuator/prometheus` 请求的指标，它是Prometheus 什么时候在向应用刮取数据的指标。
- 一个对`facicon.ico`的请求，Chrome 默认会请求它。
#### 带标签查询
我们可以通过添加标签而获得更特定的查询，例如：
```
http_server_requests_seconds_count{uri="/doit"}
```
仅仅返回一个与/doit关联的简单指标：
```
ttp_server_requests_seconds_count{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/doit"} 15 
```
使用同样的语法，我们就可以运行一个查询以获取 来自/doit的非200回复：
```
http_server_requests_seconds_count{uri="/doit",status!="200"}
```
#### 带函数查询
Prometheus 提供[函数](https://prometheus.io/docs/prometheus/latest/querying/functions/)以运行更优雅的查询。这是rate函数的例子，它计算每秒的速度，在以指定的时间范围内算出平均值：
```
rate(http_server_requests_seconds_count{uri="/doit"}[5m])
```
> 注意：本实例中的[5m]被称为`范围向量选择器`(range vector selector)，我们告诉Prometheus 使用最近5分钟的指标来计算我们的平均值。

查询返回一个单独的行如下，显式速度为每秒0.15个请求。并非一个很时髦的API：
```
{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/doit"}  0.15 
```
另一个有用的函数是sum。如果我们仅仅对整体请求速度干兴趣，且并不局限于/doit，我们可以宇星一个类似下面的查询：
```
sum(rate(http_server_requests_seconds_count[5m]))
```
它返回：
```
{} 0.3416666666666667 
```
sum 函数把不同速率的返回解雇相加，如果我们不包括sum，我们将得到每个 http_server_requests_seconds_count 指标的速度数据（/doit, /actuator/prometheus 等）。
### 2.4 一个可工作的例子实例
现在你已经了解了更多的Prometheus，让我们把它运行起来并从一个Spring Boot应用刮取数据。如果你想按照下面的步骤操作，你需要安装Docker.

我们将使用`Docker Compose`，这是使得对个Docker容器启动并运行且能互相通讯的非常简单的方法。

我们将使用2个Docker镜像：
- tkgregory/sample-metrics-application:latest 这是一个示例Spring Boot应用，在标准路径http://localhost:8080/actuator/metrics上暴露指标
- prom/prometheus:latest 官方Prometheus Docker镜像
#### 运行Spring Boot应用
常见一个`docker-compose.yml`文件，并填充下面的内容：
```
version: "3"
services:
  application:
    image: tkgregory/sample-metrics-application:latest
    ports:
      - 8080:8080
```
它指定了我们需要一个使用`tkgregory/sample-metrics-application:latest`镜像名为`application`的容器，暴露端口8080。我们可以将它运行起来：
```
docker-compose up
```
导航到 http://localhost:8080/actuator/prometheus，你就爱你刚看到像下面的图：
![SpringBoot Appication DEfault Metrics](images/springboot_default_metrics.png)

你也可以点击http://localhost:8080/doit，如果你想得到`http_server_requests_seconds_count`指标，你将看到它在不断增长。
#### 运行Prometheus
首先，在与`docker-compose.yml`同一目录下创建`prometheus.yml`。这个文件将包含Prometheus的配置，尤其是`scrape_configs`，它定义了Prometheus 将从哪里刮取指标：
```
scrape_configs:
  - job_name: 'application'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['application:8080']
```
> 注意：Prometheus将会轮询http://application:8080/actuator/prometheus以获取指标。注意默认情况下Docker 使得容器名成为hostname，以此来允许不同容器间的通讯。

到目前为止的所有内容，将下面的小姐添加进`docker-compose.yml`：
```
prometheus:
  image: prom/prometheus:latest
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml
  ports:
    - "9090:9090"
```
> 注意：这里我们配置prometheus 在端口9090运行，将本地prometheus.yml配置文件挂载进容器Prometheus期待的默认位置。

再次运行`docker-compose up`以启动Prometheus，你现在可以导航到http://localhost:9090以访问Prometheus。
#### 运行一些查询
现在你可以执行一些我们早先谈到的查询。例如，试试下面的查询过去5分钟每个请求路径的HTTP 请求速率：
```
rate(http_server_requests_seconds_count[5m])
```
在标为Expression 的文本输入框中输入上面的查询，并点击绿色的Execute 按钮：
![Prometheus查询界面](images/prometheus_query_interface.png)

你将看到如下的差序你饿过：
```
{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/**/favicon.ico"} 0

{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/actuator/prometheus"}  0.016666666666666666 

{exception="None",instance="application:8080",job="application",method="GET",outcome="SUCCESS",status="200",uri="/doit"} 0
```
如果你看到这个，/doit 的速度为0，你可以另起页面http://localhost:8080/doit并请求多次。在运行查询观察更新的结果。注意Prometheus 每15秒运行一次，因此其值是不是立刻更新的。
#### 图
如果一旦你已经运行了一个查询，你可以点击Graph ，从而可以以可视化的格式观察数据：
![Prometheus Graph](images/prometheus_graph.png)

这向你显示了你的历史查询选定时间的结果，这是可视化数据的一种快速方式，但并未提供完整的仪表板功能。在以后的博文中我们将讨论Grafana。
### 2.5 结论
你已经看到Prometheus 如何收集指标，并且是它们存储的中心。有比较容易的方式来运行针对这些指标的查询，甚至可以看到可视化的输出。
### 2.6 资源
1. 本文讨论的示例：[GitHub](https://github.com/tkgregory/monitoring-example)
2. [Prometheus](https://prometheus.io/)
## 3. Rules & Alerting
## 4. Visualisation & Graphing

## Reference
- [Monitoring A Spring Boot Application, Part 1: Fundamentals](https://tomgregory.com/monitoring-a-spring-boot-application-part-1-fundamentals/)
- [Monitoring A Spring Boot Application, Part 2: Prometheus](https://tomgregory.com/monitoring-a-spring-boot-application-part-2-prometheus/)
- [Monitoring A Spring Boot Application, Part 3: Rules & Alerting](https://tomgregory.com/monitoring-a-spring-boot-application-part-3-rules-and-alerting/)
- [Monitoring A Spring Boot Application, Part 4: Visualisation & Graphing](https://tomgregory.com/monitoring-a-spring-boot-application-part-4-visualisation-and-graphing/)
- [Spring Boot default metrics](https://tomgregory.com/spring-boot-default-metrics/)
- [Spring Metrics](https://docs.spring.io/spring-metrics/docs/current/public/prometheus)
- [Prometheus](https://prometheus.io/)