## Multi-stage

这一阶段将讨论多阶段构建。为什么我们想要使用多阶段构建，其主要原因有两个：

- 它们允许你并行运行构建步骤，使你的构建流水线更快且更具效率。
- 它们允许你构建更小的最终镜像，仅仅包含运行你的程序所需目标。

在一个 Dockerfile，一个构建阶段由一个 FROM 指令代表。前面章节的 Dockerfile 并没有充分利用多阶段构建，它只有一个构建阶段。这意味着最终镜像也将包含编译应用的资源。

```
docker build --tag=buildme .
docker images buildme
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
buildme      latest    c021c8a7051f   5 seconds ago   150MB
```

程序编译为二进制可执行文件，因此你不需要 Go 语言工具存在于最终镜像中。

### 添加阶段

使用多阶段构建，你可以为你的编译和运行环境选择不同的基础镜像。你能够从构建阶段拷贝构建资源到运行阶段。

将 Dockerfile 文件修改如下。这个修改使用了最小的 `scratch` 镜像作为基础镜像创建了一个新的阶段。在最终的 `scratch` 阶段，在前面阶段生成的二进制程序被拷贝到新阶段的文件系统中。

```
# syntax=docker/dockerfile:1
FROM golang:1.21-alpine
WORKDIR /src
COPY go.mod go.sum .
RUN go mod download
COPY . .
RUN go build -o /bin/client ./cmd/client
RUN go build -o /bin/server ./cmd/server
+
+ FROM scratch
+ COPY --from=0 /bin/client /bin/server /bin/
  ENTRYPOINT [ "/bin/server" ]
```

现在，如果你构建这个镜像并检视它，你应该看到镜像尺寸已经大大缩小。

```
docker build --tag=buildme .
docker images buildme
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
buildme      latest    436032454dd8   7 seconds ago   8.45MB
```

镜像大小从 150MB 变为只有 8.45MB。这是因为镜像只包含二进制文件而不含其它。

### 并行

你已经减小了文件的尺寸。下面的步骤告诉你如何使用多阶段构建并行特性来改善构建速度。构建当前一个接一个产生二进制文件。你可以同时编译服务器端和客户端。

你可以将构建阶段划分为分离的阶段。在最终 `scratch`` 阶段，从每个构建阶段拷贝二进制文件。通过将这些构建分散至不同的阶段，Docker 可以并行运行它们。

构建二进制文件的阶段都需要 Go 编译工具以及应用依赖。将这些公共阶段定义为可复用基础阶段。你可以通过给阶段命名来达到这个目的：`FROM image AS stage_name`。这允许你在一个阶段通过 FROM 指令引用另一个阶段名（`FROM stage_name`）。

你也可以为二进制构建阶段命名，当拷贝二进制文件到最终镜像时可以在 `COPY --from=stage_name` 指令中引用另一个阶段名。

```
  # syntax=docker/dockerfile:1
- FROM golang:1.21-alpine
+ FROM golang:1.21-alpine AS base
  WORKDIR /src
  COPY go.mod go.sum .
  RUN go mod download
  COPY . .
+
+ FROM base AS build-client
  RUN go build -o /bin/client ./cmd/client
+
+ FROM base AS build-server
  RUN go build -o /bin/server ./cmd/server

  FROM scratch
- COPY --from=0 /bin/client /bin/server /bin/
+ COPY --from=build-client /bin/client /bin/
+ COPY --from=build-server /bin/server /bin/
  ENTRYPOINT [ "/bin/server" ]
```

现在，我们无需一个接一个构建二进制文件，build-client 和 build-server 两个阶段可以并行运行。

### 构建阶段

最后的镜像很小，而且你可以利用并行高效构建。但这个镜像有点奇怪，因为它在一个镜像中包含了客户端和服务端二进制文件。它们难道不应该在两个不同的镜像里吗？

利用同一 Dockerfile 构建多个不同的镜像是可能的。你可以使用 `--target`` 标记来指定构建阶段。替换未命名的 `FROM scratch`` 阶段，使用 `client`` 和 `server`` 分别构建。

```
  # syntax=docker/dockerfile:1
  FROM golang:1.21-alpine AS base
  WORKDIR /src
  COPY go.mod go.sum .
  RUN go mod download
  COPY . .

  FROM base AS build-client
  RUN go build -o /bin/client ./cmd/client

  FROM base AS build-server
  RUN go build -o /bin/server ./cmd/server

- FROM scratch
- COPY --from=build-client /bin/client /bin/
- COPY --from=build-server /bin/server /bin/
- ENTRYPOINT [ "/bin/server" ]

+ FROM scratch AS client
+ COPY --from=build-client /bin/client /bin/
+ ENTRYPOINT [ "/bin/client" ]

+ FROM scratch AS server
+ COPY --from=build-server /bin/server /bin/
+ ENTRYPOINT [ "/bin/server" ]
```

现在你可以将客户端和服务器端程序构建为不同的 Docker 镜像（tags）。

```
docker build --tag=buildme-client --target=client .
docker build --tag=buildme-server --target=server .
docker images buildme 
REPOSITORY       TAG       IMAGE ID       CREATED          SIZE
buildme-client   latest    659105f8e6d7   20 seconds ago   4.25MB
buildme-server   latest    666d492d9f13   5 seconds ago    4.2MB
```

镜像现在甚至更小了，每个约 4 MB。

这个修改也避免了每次不得不构建两个应用。当选择构建 `client` 目标，Docker 仅仅构建创建目标的阶段。如果不需要，`build-server` 和 `server` 阶段将被跳过。同样的，当构建 `server` 目标时，`build-client` 和 `client` 阶段将被跳过。

### 总结

多阶段构建对于构建更小更精简的镜像是有用的，并且能够使构建更快。


## Dockerfile多阶段构建（multi-stage builds）

多阶段构建对优化Dockerfile很有用，同时还保持了Dockerfile的可读性和可维护性。

### 多阶构建之前

保持镜像尽可能的小是构建镜像最重要的一件事情，Dockerfile中每个指令都会在镜像中创建一个层。我们每创建完一层都要把不再需要的东西清除掉，想要写出高效的Dockerfile，您除了需要掌握shell技巧，还需要从逻辑上保待层尽可能的小，并且只保留下一个层必需的目标。

有一种常见的做法，一个 Dockerfile 用于开发（包含构建您的应用的所有东西），一个简化的用于生产，只包含你的应用和运行它需要的东西。这通常被称为构建模式。维护两个 Dockerfile 并不是个好主意。

下面的例子使用了上面讲的构建模式，两个 Dockerfile.build 和 Dockerfile

Dockerfile.build：

```
FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
COPY app.go .
RUN go get -d -v golang.org/x/net/html   && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
```

这个例子人工的把两个RUN命令用 Bash && 操作压缩，避免添加更多的层到镜像中。然而这样容易发生故障且难以维护。例如，很容易插入另一个命令而忘记使用\字符继续行。

Dockerfile:

```
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY app .
CMD ["./app"] 
```

build.sh:

```
#!/bin/sh
echo Building alexellis2/href-counter:build

docker build --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy \  
    -t alexellis2/href-counter:build . -f Dockerfile.build

docker container create --name extract alexellis2/href-counter:build  
docker container cp extract:/go/src/github.com/alexellis/href-counter/app ./app  
docker container rm -f extract

echo Building alexellis2/href-counter:latest

docker build --no-cache -t alexellis2/href-counter:latest .
rm ./app
```

当您运行 `build.sh` 脚本时，它需要构建第一个镜像，并从中创建一个容器来复制中间物，然后构建第二个镜像。这两个镜像都占用了系统上的空间，您的本地磁盘上仍然有app中间物。

多阶段构建极大地简化了这种情况!

### 使用多阶段构建

对于多阶段构建，您可以在Dockerfile中使用多个FROM语句。每个FROM指令都可以使用不同的基镜像，并且它们都开始了构建的新阶段。您可以有选择地将中间物从一个阶段复制到另一个阶段，舍弃在最后的镜像中您不想要的所有内容。为了演示这是如何工作的，让我们修改前一节中的 Dockerfile，以使用多阶段构建。

Dockerfile：

```
FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]  
```

您只需要一个 Dockerfile。也不需要单独的构建脚本。只需运行 docker 构建。

```
$ docker build -t alexellis2/href-counter:latest .
```

最终的结果是与以前一样小的生产镜像，并且显著降低了复杂性。您不需要创建任何中间镜像，也不需要将任何中间物提取到本地系统中。

它是如何工作的? 第二个FROM指令以 `alpine:latest image` 为基础，开始了一个新的构建阶段。`COPY --from=0` 行只将前一个阶段构建的中间物复制到这个新阶段。Go SDK 和任何中间构件都被遗留下来，没有保存在最终的镜像中。

### 命名你的构建阶段

默认情况下，这些阶段没有命名，您可以通过它们的整数索引引用它们，第一个 `FROM` 指令为 `0`。但是，您可以通过在 `FROM` 指令中添加 `AS <NAME>` 来为阶段命名。这个例子通过命名阶段和在 COPY 指令中使用名称来改进前面的例子。这意味着即使 Dockerfile 中的指令稍后被调整顺序，COPY 也不会出错。

```
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html  
COPY app.go    .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]
```

### 在特定的构建阶段停止

构建镜像时，不需要构建整个 Dockerfile 中包括的每个阶段。 您可以指定目标构建阶段。 以下命令假定您正在使用以前的 Dockerfile，但在名为 `builder` 的阶段停止：

```
$ docker build --target builder -t alexellis2/href-counter:latest .
```

一些场景中这可能非常强大：

- 调试特定的构建阶段。
- 使用 `debug` 阶段——启用了所有调试符号或工具，和干净的 `production` 阶段。
- 使用 `testing` 阶段，在该阶段中，您的应用填充了测试数据，但生产构建使用另一个使用真实数据的阶段。

### 将外部镜像用作“阶段”

使用多阶段构建时，您不仅限于从 Dockerfile 中之前创建的阶段进行复制。 您可以使用 `COPY --from` 指令从单独的镜像中复制，可以是本地镜像名称，本地或Docker注册中心上可用的标签，或一个标签 ID。 Docker 客户端在必要时拉取镜像并从中复制构件。 语法为：

```
COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
```

### 将上一个阶段用作新阶段

在使用FROM指令时，可以通过引用前一个阶段结束的地方来进行选择。 例如：

```
FROM alpine:latest as builder
RUN apk --no-cache add build-base

FROM builder as build1
COPY source1.cpp source.cpp
RUN g++ -o /binary source.cpp

FROM builder as build2
COPY source2.cpp source.cpp
RUN g++ -o /binary source.cpp
```

### Reference

- [Multi-stage](https://docs.docker.com/build/guide/multi-stage/)
- [Overview of best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#use-multi-stage-builds)
- [Best practices for Dockerfile instructions](https://docs.docker.com/develop/develop-images/instructions/)
- [Dockerfile多阶段构建（multi-stage builds）](https://www.yii666.com/blog/370786.html)