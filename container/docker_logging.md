# 容器日志
## 查看容器或服务日志（View logs for a container or service）
docker logs命令显示一个运行中的容器记录的信息。docker service logs命令显示参与一个服务的所有容器记录的信息。那些信息被记录以及信息格式完全由容器的端点（endpoint）命令控制。

默认情况下，docker logs 或 docker service logs显示的命令输出就和您在终端交互运行这些命令一样。UNIX 和 Linux命令典型地会在运行时打开标准输入（STDIN）, 标准输出（STDOUT）, 标准错误输出（STDERR）三个流。STDIN是命令的输入流，它包括从键盘或其它命令的输入。STDOUT通常是命令的正常输出，STDERR典型地用于输出错误消息。默认情况下，docker logs打印命令的标注输出和标准错误输出。关于更多 I/O 和 Linux请参阅 [Linux Documentation Project article on I/O redirection](http://www.tldp.org/LDP/abs/html/io-redirection.html)。

在某些情况下，docker logs不会显示多少有用信息，除非你采取一些额外步骤：
- 如果你采用的[日志驱动](https://docs.docker.com/config/containers/logging/configure/)将日志送往文件，其它主机，数据库或者其它日志后端，docker logs将不会显示有用的信息。
- 如果你的镜像运行一个非交互性的程序比如一个网站服务器或数据库服务器，应用可能将其输出送至日志文件而非标注输出或标准错误输出。

第一种情况，你的日志被以别的方式处理，你可能会选择不使用docker logs。针对第二种情况，官方nginx镜像给出了一种变通方案，官方Apache httpd镜像给出了另一种。

官方nginx镜像创建了一个/var/log/nginx/access.log 到/dev/stdout的软链接，同时创建了/var/log/nginx/error.log 到 /dev/stderr的软链接，覆盖了日志文件，使得日志被送到相关的特定设备上。参阅其[Dockerfile](https://github.com/nginxinc/docker-nginx/blob/8921999083def7ba43a06fabd5f80e4406651353/mainline/jessie/Dockerfile#L21-L23)。

官方Apache httpd更改其httpd的配置文件将正常输出直接写到/proc/self/fd/1 (STDOUT)，将错误消息写至/proc/self/fd/2 (STDERR). 参阅[Dockerfile](https://github.com/docker-library/httpd/blob/b13054c7de5c74bbaa6d595dbe38969e6d4f860c/2.2/Dockerfile#L72-L75)。
## 配置日志驱动（Configure logging drivers）
Docker包含多种日志机制来帮你[得到运行中的容器和服务相关信息](https://docs.docker.com/engine/admin/logging/view_container_logs/)。这些机制被称为日志驱动。

每个Docker服务（daemon）有一个缺省日志驱动，每个启动容器除非你配置它使用一个不同的日志驱动，否则将使用缺省驱动。

另外为了使用Docker中含有的日志驱动，你可以实现并使用[日志驱动插件](https://docs.docker.com/engine/admin/logging/plugins/)
### 配置缺省日志驱动
为了配置Docker daemon缺省使用一种特定日志驱动，在daemon.json设置“log-driver”的值为日志驱动名，该文件在Linux主机中位于/etc/docker/下（注意：在我的Ubuntu 18.04上位于/snap/docker/384/config），在Windows服务器主机在位于C:\ProgramData\docker\config\ 下。缺省日志驱动是“json-file”。下面的例子显式设置缺省日志驱动为"syslog"：
```
{
  "log-driver": "syslog"
}
```
如果日志驱动有其它可配置选项，你可以在daemon.json中的键“log-opts”下以JSON对象的格式设置它们。下面的例子为"json-file"型日志驱动设置了两个可配置选项：
```
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

> **注意：** 在配置文件daemon.json中log-opt必须以字符串形式提供。布尔类型和数字类型值必须以引号 (")包裹（如上例中的max-file设置）。

如果你不指定日志驱动，默认即为“json-file”，因此，一些命令比如docker inspect <CONTAINER> 的输出是JSON。

为了找出当前Docker daemon的缺省日志驱动，运行docker info并搜索Logging Driver。你可以在Linux, macOS, 或 PowerShell on Windows运行下面的命令：
```
$ docker info --format '{{.LoggingDriver}}'

json-file
```
### 为容器配置日志驱动
当你启动一个容器时，你可以用--log-driver标记来指定一个不同于Docker 服务（Docker daemon）缺省日志驱动的选项。如果这个日志驱动有可配置选项，你可以使用--log-opt <NAME>=<VALUE>来制定一个或多个选项值。即使容器使用缺省日志驱动，它也可指定不同的（日志驱动）配置项。

下面的例子使用日志驱动none来启动一个Alpine容器：
```
$ docker run -it --log-driver none alpine ash
```
为了找到运行中的容器的当前驱动日志，如果Docker 服务采用json-file日志驱动，如下运行docker inspect命令，并用容器名字或ID
替换<CONTAINER>：
```
$ docker inspect -f '{{.HostConfig.LogConfig.Type}}' <CONTAINER>

json-file
```
### 配置容器到日志驱动的消息发送模式
Docker提供两种模式用于发送从容器到日志驱动的消息：
- （缺省）直接模式，从容奇至日志驱动以阻塞方式发送
-  非阻塞模式，日志消息被存在一个容器级别的环形缓存中供日志驱动消费

非阻塞模式可防止由于记入日志的压力而阻塞，当 STDERR 或 STDOUT 流阻塞时，应用程序可能会以意想不到的方式失败。
> **警告**： 当缓冲区已满且新消息排入队列时，内存中最早的消息将被丢弃。我们更倾向于丢弃消息通常阻塞在应用程序的日志写入过程。

mode 这个日志选项用于控制使用阻塞（默认）还是非阻塞方式发送消息。

max-buffer-size 这个日志选项用于控制非阻塞方式下用作中间消息存储的环形缓冲区大小，默认是 1MB。

下面示例启动了日志输出为非阻塞模式且有 4MB 缓存的 Alpine 容器。
```
$ docker run -it --log-opt mode=non-blocking --log-opt max-buffer-size=4m alpine ping 127.0.0.1
```
### 为日志驱动使用环境变量或标签
部分日志驱动程序会将容器的 --env|-e 或 --label 标志值添加到容器的日志中。这个例子启动了一个使用 Docker 守护进程默认日志驱动程序（假设是 json-file）的容器，但是设置了环境变量 os=ubuntu。
```
$ docker run -dit --label production_status=testing -e os=ubuntu alpine sh
```
如果日志驱动程序支持，这会添加额外的字段到日志输出中。下面是 json-file 日志驱动程序的输出：
```
"attrs":{"production_status":"testing","os":"ubuntu"}
```
### 支持的日志驱动
Docker支持如下日志驱动。参考每个驱动程序的文档来了解相关配置选项。如果你使用了[日志驱动程序插件](https://docs.docker.com/engine/admin/logging/plugins/)，会有更多的选项。

驱动程序|描述
--|--
none|容器没有日志可用，docker logs 什么输出都不返回
[local](https://docs.docker.com/config/containers/logging/local/)|日志被以一种旨在最小化负荷的用户格式存储
[json-file](https://docs.docker.com/config/containers/logging/json-file/)|日志格式化为 JSON。这是 Docker 默认的日志驱动程序
[syslog](https://docs.docker.com/config/containers/logging/syslog/)|将日志消息写入 syslog 工具。syslog 守护程序必须在宿主机上运行
[journald](https://docs.docker.com/config/containers/logging/journald/)|将日志消息写入 journald。journald 守护程序必须在宿主机上运行
[gelf](https://docs.docker.com/config/containers/logging/gelf/)|将日志消息写入 Graylog Extended Log Format (GELF) 终端，例如 Graylog 或 Logstash
[fluentd](https://docs.docker.com/config/containers/logging/fluentd/)|将日志消息写入 fluentd（forward input）。fluentd 守护程序必须在宿主机上运行
[awslogs](https://docs.docker.com/config/containers/logging/awslogs/)|将日志消息写入 Amazon CloudWatch Logs。
[splunk](https://docs.docker.com/config/containers/logging/splunk/)|用HTTP事件收集器将日志消息写入splunk
[etwlogs](https://docs.docker.com/config/containers/logging/etwlogs/)|将日志消息写为 Windows 的 Event Tracing 事件。仅在Windows平台上可用
[gcplogs](https://docs.docker.com/config/containers/logging/gcplogs/)|将日志消息写入 Google Cloud Platform (GCP) Logging
[logentries](https://docs.docker.com/config/containers/logging/logentries/)|将日志消息写入 Rapid7 Logentries
### 日志驱动的限制
- Docker企业版用户可以使用“双日志”，这是你可以把docker logs命令用于任何日志驱动。参阅[使用docker logs阅读配置了远程日志驱动的容器的日志](https://docs.docker.com/config/containers/logging/dual-logging/)以获得关于用docker logs来本地读取第三方日志驱动解决方案的日志的信息，包括：
  + syslog
  + gelf
  + fluentd
  + awslogs
  + splunk
  + etwlogs
  + gcplogs
  + Logentries
- 当使用Docker社区版时，docker logs仅仅可用于以下驱动：
  + local
  + json-file
  + journald
- 读取日志信息需要解压轮转的（rotated）日志文件，这将导致解压时的CPU使用率上升和磁盘利用率暂时增大（直至在轮转日志文件中的消息被读取完毕）
- docker数据目录所驻主机存储大小决定了存储日志文件信息的多少。
## 使用docker logs阅读配置了远程日志驱动的容器的日志（Use docker logs to read container logs for remote logging drivers）
### 概览
在Docker企业版18.03之前，jsonfile和journald两种日志驱动支持用docker logs命令读取容器日志。但是，许多第三方日志驱动不支持用docker logs本地读取日志消息，包括：
- syslog
- gelf
- fluentd
- awslogs
- splunk
- etwlogs
- gcplogs
- Logentries
这给以一种自动化和标准化方式收集日志数据带来许多问题，尤其是UDP。日志信息仅仅能够以的第三方日志驱动指定的格式访问和查看。

从Docker企业版18.03.1-ee-1开始，你可以用docker logs命令读取日志记录无论你配置何种日志驱动或插件。这种能力，通常被称为双日志，由于Docker引擎已经配置了“local”日志驱动，能够让你以一种一致的格式本地读取容器日志，无论远端使用何种日志驱动。查阅[配置缺省日志驱动](https://docs.docker.com/config/containers/logging/configure)可以看到更多额外信息。
### 前提
- Docker 企业版 - 双日志只有企业版才支持，而且从Docker企业版引擎18.03.1-ee-1起默认开启支持。
### 用法
双日志缺省打开。你必须配置docker daemon或容器本身支持远程日志驱动。

下面的例子显示了在有及没有双日志能力的情况下docker logs命令的运行结果：
####  无双日志能力
当一个容器或dockerd配置为远程日志驱动，比如splunk，如果你试图读本地容器日志时将返回一个错误。
- 第1步： 配置Docker daemon
```
$ cat /etc/docker/daemon.json
  {
    "log-driver": "splunk",
    "log-opts": {
      ...
    }
  }
```
- 第2步：启动容器
```
$ docker run -d busybox --name testlog top 
```
- 第3步：读取容器日志
```
 $ docker logs 7d6ac83a89a0
  The docker logs command was not available for drivers other than json-file and journald.
```
####  拥有双日志能力
一个容器或dockerd配置为远程日志驱动，比如splunk。
- 第1步： 配置Docker daemon
```
$ cat /etc/docker/daemon.json
  {
    "log-driver": "splunk",
    "log-opts": {
      ...
    }
  }
```
- 第2步：启动容器
```
$ docker run -d busybox --name testlog top 
```
- 第3步：读取容器日志
```
 $ docker logs 7d6ac83a89a0
  2019-02-04T19:48:15.423Z [INFO]  core: marked as sealed
  2019-02-04T19:48:15.423Z [INFO]  core: pre-seal teardown starting
  2019-02-04T19:48:15.423Z [INFO]  core: stopping cluster listeners
  2019-02-04T19:48:15.423Z [INFO]  core: shutting down forwarding rpc listeners
  2019-02-04T19:48:15.423Z [INFO]  core: forwarding rpc listeners stopped
  2019-02-04T19:48:15.599Z [INFO]  core: rpc listeners successfully shut down
  2019-02-04T19:48:15.599Z [INFO]  core: cluster listeners successfully shut down
```
> **注意**：对于一个本地日志驱动，比如json-file和journald，双日志功能开启以否其功能没有差别，两种情况下都可以本地读取容器日志。
### 限制
- 你不能指定超过一种日志驱动
- 如果一个容器使用日志驱动远程发送日志，中间突发网络故障，不会有写本地缓存的情况发生。
- 如果一次向驱动写日志操作失败（文件系统满，或者没有写权限），缓存写操作将失败，daemon 将记录这次失败，但写向缓存的操作不回重拾。
- 在文件写操作较慢时，一个环形缓存用于防止容器被阻塞在IO上。由于默认环形缓冲大小的限制，某些日志可能从缓存丢失。管理员应该在docker daemon关闭时修复这个问题。
## 使用日志驱动插件（Use a logging driver plugin）
Docker的日志插件能让你扩展和定制Docker内建日志驱动的功能。日志服务提供者可以[实现他们自己的插件](https://docs.docker.com/engine/extend/plugins_logging/)，并在Docker Hub或一个私人仓库上发布，本文将介绍如何配置Docker来使用这种插件。
### 安装日志驱动插件
使用docker plugin install <org/image>命令来安装日志驱动插件，安装过程中需要参阅插件开发者提供的信息。

你可以使用docker plugin ls来列出已安装的所有插件，你也可以使用docker inspect来检视一个特定插件。
### 配置插件为缺省日志驱动
日志驱动插件安装后，你可以配置Docker daemon使用它作为日志缺省驱动：只需在daemon.json,中把log-driver设置为插件的名字。如果该驱动插件支持额外选项，你可以在该文件中使用log-opts数组来设置他们。
### 配置插件为容器日志驱动
日志驱动插件安装后，你可以配置容器使用它作为日志驱动：只需利用--log-driver把它们传递给docker run。如果该驱动插件支持额外选项，你可以传递一个或多个--log-opt标记，以选项名作为键，以选项值作为值。
## 定制日志驱动输出（Customize log driver output）
## 日志驱动细节（Logging driver details）

## 参考
- [Container Logging](https://docs.docker.com/config/containers/logging/)
- [Write a Dockerfile](https://docs.docker.com/engine/reference/builder/)
- [Docker日志收集最佳实践](https://www.cnblogs.com/jingjulianyi/p/6637801.html)
- [Docker 生产环境之日志 - 配置日志驱动程序](https://blog.csdn.net/kikajack/article/details/79575286)