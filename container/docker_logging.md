# 容器日志
## 查看容器或服务日志（View logs for a container or service）
docker logs命令显示一个运行中的容器记录的信息。docker service logs命令显示参与一个服务的所有容器记录的信息。那些信息被记录以及信息格式完全由容器的端点（endpoint）命令控制。

默认情况下，docker logs 或 docker service logs显示的命令输出就和您在终端交互运行这些命令一样。UNIX 和 Linux命令典型地会在运行时打开标准输入（STDIN）, 标准输出（STDOUT）, 标准错误输出（STDERR）三个流。STDIN是命令的输入流，它包括从键盘或其它命令的输入。STDOUT通常是命令的正常输出，STDERR典型地用于输出错误消息。

## 参考
- [Container Logging](https://docs.docker.com/config/containers/logging/)