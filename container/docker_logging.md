# 容器日志
## 查看容器或服务日志（View logs for a container or service）
docker logs命令显示一个运行中的容器记录的信息。docker service logs命令显示参与一个服务的所有容器记录的信息。那些信息被记录以及信息格式完全由容器的端点（endpoint）命令控制。

默认情况下，docker logs 或 docker service logs显示的命令输出就和您在终端交互运行这些命令一样。UNIX 和 Linux命令典型地会在运行时打开标准输入（STDIN）, 标准输出（STDOUT）, 标准错误输出（STDERR）三个流。STDIN是命令的输入流，它包括从键盘或其它命令的输入。STDOUT通常是命令的正常输出，STDERR典型地用于输出错误消息。默认情况下，docker logs打印命令的标注输出和标准错误输出。关于更多 I/O 和 Linux请参阅 [Linux Documentation Project article on I/O redirection]（http://www.tldp.org/LDP/abs/html/io-redirection.html）

在某些情况下，docker logs不会显示多少有用信息，除非你采取一些额外步骤：
- 如果你采用的[日志驱动](https://docs.docker.com/config/containers/logging/configure/)将日志送往文件，其它主机，数据库或者其它日志后端，docker logs将不会显示有用的信息。
- 如果你的镜像运行一个非交互性的程序比如一个网站服务器或数据库服务器，应用可能将其输出送至日志文件而非标注输出或标准错误输出。

第一种情况，你的日志被以别的方式处理，你可能会选择不使用docker logs。针对第二种情况，官方nginx镜像给出了一种变通方案，官方Apache httpd镜像给出了另一种。

官方nginx镜像创建了一个/var/log/nginx/access.log 到/dev/stdout的软链接，同时创建了/var/log/nginx/error.log 到 /dev/stderr的软链接，覆盖了日志文件，使得日志被送到相关的特定设备上。参阅其[Dockerfile](https://github.com/nginxinc/docker-nginx/blob/8921999083def7ba43a06fabd5f80e4406651353/mainline/jessie/Dockerfile#L21-L23)。

官方Apache httpd更改其httpd的配置文件将正常输出直接写到/proc/self/fd/1 (STDOUT)，将错误消息写至/proc/self/fd/2 (STDERR). 参阅[Dockerfile](https://github.com/docker-library/httpd/blob/b13054c7de5c74bbaa6d595dbe38969e6d4f860c/2.2/Dockerfile#L72-L75)。
## 配置日志驱动（Configure logging drivers）
## 使用docker logs阅读配置了远程日志驱动的容器的日志（Use docker logs to read container logs for remote logging drivers）
## 使用日志驱动插件（Use a logging driver plugin）
## 定制日志驱动输出（Customize log driver output）
## 日志驱动细节（Logging driver details）

## 参考
- [Container Logging](https://docs.docker.com/config/containers/logging/)
- [Write a Dockerfile](https://docs.docker.com/engine/reference/builder/)