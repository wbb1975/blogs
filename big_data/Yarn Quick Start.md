## Quick Start

本文档描述如何在 YARN 上使用 YARN 服务框架来部署服务。

### 1. 配置并启动 HDFS 和 YARN 组件

为 HDFS 和 YARN 和平常一样启动所有 hadoop 的组件。为了开启 YARN 服务框架，添加这个属性到 `yarn-site.xml`，重启资源管理器或在资源管理器启动之前设置这个属性。无论 `CLI` 或 `REST API` 使用 YARN 服务框架这个属性就是必须的。

```
 <property>
    <description>
      Enable services rest api on ResourceManager.
    </description>
    <name>yarn.webapp.api-service.enable</name>
    <value>true</value>
  </property>
```

### 2. 示例服务

下面是一个简单的服务定义，通过写一个简单的 `spec` 文件，无需编写任何代码，我们能够在 YARN 上启动一个 `sleep` 容器。

```
{
  "name": "sleeper-service",
  "version": "1.0",
  "components" : 
    [
      {
        "name": "sleeper",
        "number_of_containers": 1,
        "launch_command": "sleep 900000",
        "resource": {
          "cpus": 1, 
          "memory": "256"
       }
      }
    ]
}
```

用户可以使用下面的命令在 YARN 上简单运行我们的预定义示例服务。

```
yarn app -launch <service-name> <example-name>
```

例如，下面的命令在 YARN 上启动了名为 `my-sleeper` 的 `sleeper` 服务。

```
yarn app -launch my-sleeper sleeper
```

关于使用 YARN 服务框架启动基于 `docker` 的服务，请参见 [API 文档](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/yarn-service/YarnServiceAPI.html)。

### 3. 在 YARN 上通过 CLI 管理服务

下面的步骤带你在 YARN 上使用 `CLI` 部署一个服务。参考 [Yarn Commands](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YarnCommands.html) 以获取命令和选项的完整列表。

#### 3.1 部署一个服务

```
yarn app -launch ${SERVICE_NAME} ${PATH_TO_SERVICE_DEF_FILE}
```

参数：

- SERVICE_NAME：服务名。注意它需要在当前用户名下跨运行服务保证唯一。
- PATH_TO_SERVICE_DEF：JSON 格式的服务定义文件路径。

例如：

```
yarn app -launch sleeper-service /path/to/local/sleeper.json
```

#### 3.2 调整一个服务中的一个组件

增减一个组件的容器数目：

```
yarn app -flex ${SERVICE_NAME} -component ${COMPONENT_NAME} ${NUMBER_OF_CONTAINERS}
```

例如，对于名为 `sleeper-service` 的服务，设置 `sleeper` 组件至 `2` 个容器（绝对数量）：

```
yarn app -flex sleeper-service -component sleeper 2
```

`flex` 命令也支持 `${NUMBER_OF_CONTAINERS}` 的想对变化，例如 `+2` 或 `-2`。

#### 3.3 停止一个服务

停止一个服务将停止服务的所有容器以及 `ApplicationMaster`，但并没有删除服务的状态，比如服务在 `hdfs` 上的根目录。

```
yarn app -stop ${SERVICE_NAME}
```

#### 3.4 重启一个停止的服务

启动一个停止的服务很容易--直接调用 `start` 命令选项。

```
yarn app -start ${SERVICE_NAME}
```

#### 3.5 销毁一个服务

除了停止一个服务，它也删除服务在 `hdfs` 上的根目录以及在 YARN 服务注册里的记录。

```
yarn app -destroy ${SERVICE_NAME}
```

### 4. 在 YARN 上通过 REST API 管理服务

当 `yarn.webapp.api-service.enable` 设置为 `true` 时，`YARN API Server REST API` 被作为资源管理器的一部分被激活。

服务可以通过资源管理器 Web 端点被部署到 YARN 上。

参考 [API 文档](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/yarn-service/YarnServiceAPI.html) 以了解详细的 API 规范。

#### 4.1 部署一个服务

POST 前面的示例服务定义至资源管理器 `api-server` 端点：

```
POST  http://localhost:8088/app/v1/services
```

#### 4.2 得到服务状态

```
GET  http://localhost:8088/app/v1/services/${SERVICE_NAME}
```

#### 4.3 调整一个服务中的一个组件

```
PUT  http://localhost:8088/app/v1/services/${SERVICE_NAME}/components/${COMPONENT_NAME}
```

PUT 请求体：

```
{
    "name": "${COMPONENT_NAME}",
    "number_of_containers": ${COUNT}
}
```

例如：

```
{
    "name": "sleeper",
    "number_of_containers": 2
}
```

#### 4.4 停止一个服务

停止一个服务将停止服务的所有容器以及 `ApplicationMaster`，但并没有删除服务的状态，比如服务在 `hdfs` 上的根目录。

```
PUT  http://localhost:8088/app/v1/services/${SERVICE_NAME}
```

PUT 请求体：

```
{
  "name": "${SERVICE_NAME}",
  "state": "STOPPED"
}
```

#### 4.5 重启一个停止的服务

```
PUT  http://localhost:8088/app/v1/services/${SERVICE_NAME}
```

PUT 请求体：

```
{
  "name": "${SERVICE_NAME}",
  "state": "STARTED"
}
```

#### 4.6 销毁一个服务

除了停止一个服务，它也删除服务在 `hdfs` 上的根目录以及在 YARN 服务注册里的记录。

```
DELETE  http://localhost:8088/app/v1/services/${SERVICE_NAME}
```

### 5. 通过 YARN UI2 和 Timeline Service v2 建立服务 UI

一个新的 `service` 属性页被特地添加到 `YARN UI2` 以一等公民的方式显示 YARN 服务。服务框架上传数据至 `TimelineService`，`service UI` 从 `TimelineService` 读取数据并渲染其内容。

#### 5.1 开启 Timeline Service v2

请参考 [TimeLineService v2 doc](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/TimelineServiceV2.html)以了解如何启用 `Timeline Service v2`。

#### 5.2 开启新 YARN UI

在 `yarn-site.xml` 中设置如下配置并启动资源管理器。如果你在从源代码构建，确认你在 `mvn` 命令中使用了 `-Pyarn-ui`--这将为新 `YARN UI` 产生 war 文件。

```
<property>
    <description>To enable RM web ui2 application.</description>
    <name>yarn.webapp.ui2.enable</name>
    <value>true</value>
</property>
```

##### 安全运行

YARN 服务框架支持运行一个安全（`kerberized`）的环境。当他们启动服务时用户需要指定 `kerberos` 主体（principal ）名及其 `keytab`。例如，一个典型配置如下所示：

```
{
  "name": "sample-service",
  ...
  ...
  "kerberos_principal" : {
    "principal_name" : "hdfs-demo/_HOST@EXAMPLE.COM",
    "keytab" : "file:///etc/security/keytabs/hdfs.headless.keytab"
  }
}
```

##### 以 Docker 运行

上面的示例是非 Docker 为基础的服务。YARN 服务框架也对管理基于 docker 的服务提供一等公民支持。管理基于 docker 的服务的大多数步骤是一样的，除了在 docker 中 一个组件的 Artifact 类型为 `DOCKER`，Artifact `id` 为 `docker` 镜像的名字。关于如何在 YARN 上设置 docker 的细节，请参考 [Docker on YARN](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/DockerContainers.html)。

有了 docker 的支持，它开启了实现一系列新特性的大门，比如在 YARN 上通过 DNS 来发现服务容器，参考 [ServiceDiscovery](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/yarn-service/ServiceDiscovery.html)以获取更多内容。

### Reference

- [yarn quick start](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/yarn-service/QuickStart.html)