# 使用卷（volumes）
卷是持久化Docker容器产生和使用的首选方案，虽然绑定挂载（bind mounts）依赖于主机目录结构，卷却是完全由容器控制。卷相比绑定点有如下优势：
- 卷相对绑定点易于备份和迁移
- 你可以用Docker命令行和Docker API来管理卷
- 卷在Linux，Windows容器上皆可工作
- 卷能够更安全地在多个容器间共享
- 卷驱动可以让你把卷存在远端主机甚至云上，加密卷的内容，或者别的什么功能
- 卷可拥有由容器预先产生的内容
此外，卷通常是比利用容器的可写层来持久化数据的更好的选择，因为卷不会增加使用卷的容器的大小，而且卷的内容的生命周期与容器无关。

![types-of-mounts-volume](https://github.com/wbb1975/blogs/blob/master/container/images/types-of-mounts-volume.png)

如果你的容器将要产生非持久化的状态数据，可以考虑用临时文件系统挂载（tmpfs mount）来避免把数据到处持久化，而且，由于不把数据写入容器可写层。从而提升了容器的性能。

卷使用rprivate绑定传播（bind propagation），而绑定传播不能针对卷配置。
## 选择-v或--mount标记
最初，-v或--volume标记用于单独的容器而--mount用于一大群服务。但是，从Docker 17.06开始，--mount选项也可用于单独的容器。基本上，--mount更直白，更冗长。最大的区别在于-v在一个字段中把多个选项绑定在一起，而--mount把选项分开。下面是每个选项的无法对比。
> 新用户应该尽量使用--mount语法，它比-v更简单

如果你必须指定卷驱动选项，你就必须使用--mount：
- -v or --volume：由三个被冒号分割的（:）字段构成，这些这段必须顺序正确，并且每个字段的含义马上就很清晰:
  1. 如果是命名卷，第一个字段是卷的名字，它必须在给定机器上唯一；如果是匿名卷，首字段省略
  2. 第二个字段是将被挂载到容器的文件或目录
  3. 第三个字段可选，是逗号分隔的选项列表，比如ro。这些选项下面再细谈。
- --mount：由多个逗号分割的键值对组成，键值对格式为“键＝值”。--mount语法比-v or --volume冗长，但它键的顺序不重要，而且它的选项值更易理解。
  1. type：挂载类型，它可以是bind，volume，或tmpfs。本文讨论卷，所以type总是设为volume。
  2. source：挂载源，如果是命名卷，用于指定卷的名字；如果是匿名卷，该字段省略。可以选择用source或src指定。
  3. destination：目标路径，用于指定文件或目录在容器中的路径，可以用destination，dst或target来指定。
  4. readonly：只读选项，如果存在，则只读挂载。
  5. volume-opt：卷选项，可以用名值对指定多次。
  > 利用外部csv解析器来分解选项
  > 如果你的卷驱动接受一个逗号分隔的选项列表，你必须利用外部csv解析器来分解选项。要想成功实现这点，必须用 (") 包围volume-opt，整个选项列表用 (')包围。下面的片段显示了一个local的正确做法：
  ```
  $docker service create \
     --mount 'type=volume,src=<VOLUME-NAME>,dst=<CONTAINER-PATH>,volume-driver=local,volume-opt=type=nfs,volume-opt=device=<nfs-server>:<nfs-path>,"volume-opt=o=addr=<nfs-address>,vers=4,soft,timeo=180,bg,tcp,rw"'
    --name myservice \
    <IMAGE>
  ```
下面的例子将显示--mount和-v语法，--mount会被首先演示。

## -v和--mount的行为差异
和绑定挂载（bind mounts）相反，所有卷相关的选项对--mount和-v都可用。

但当卷用于服务时，只有--mount被支持。

## 卷创建和管理
不象绑定传播（bind propagation），你可以在任何容器之外创建和管理卷。
### 创建卷
```$ docker volume create my-vol```
### 打印卷列表
```
$ docker volume ls
local            my-vol
```
### 检视卷
```
$ docker volume inspect my-vol
[
    {
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": {},
        "Scope": "local"
    }
]
```
### 删除卷
```$ docker volume rm my-vol```
## 带卷启动容器
如果你启动一个容器，其附带的容器不存在，Docker将为你创建它。下面的例子将把卷 myvol2 挂载到容器中的/app/位置。

```docker run -d --name devtest --mount source=myvol2,target=/app nginx:latest```

或者

```$ docker run -d --name devtest -v myvol2:/app nginx:latest```

使用“docker inspect devtest”来验证卷是否创建并正确挂载。查看Mounts段：
```
"Mounts": [
    {
        "Type": "volume",
        "Name": "myvol2",
        "Source": "/var/lib/docker/volumes/myvol2/_data",
        "Destination": "/app",
        "Driver": "local",
        "Mode": "",
        "RW": true,
        "Propagation": ""
    }
],
```
结果显示挂载的类型是卷，同时也展示了卷的源和目标，以及挂载后的读写属性。

可以停止容器并删除卷。注意卷删除是个单独的步骤。
```
$ docker container stop devtest
$ docker container rm devtest
$ docker volume rm myvol2
```

## 带卷启动服务
当你启动一个服务并定义一个卷，每个服务容器都会使用其本地卷。如果你使用本地（local）驱动，那么没有任何容器可以共享卷的数据。但是有一些卷驱动类型可以支持数据共享。用于AWS和Azure的Docker利用Cloudstor插件来支持持久存储。

下面的例子启动一个包含四个副本的nginx服务，每个副本使用名为myvol2的本地（local）卷：
```
$ docker service create -d --replicas=4 --name devtest-service \
  --mount source=myvol2,target=/app nginx:latest
```
使用“docker service ps devtest-service”命令来验证服务被正常启动：
```
$ docker service ps devtest-service
ID              NAME                IMAGE          NODE     DESIRED STATE   CURRENT STATE       ERROR           PORTS
4d7oz1j85wwn    devtest-service.1   nginx:latest   moby     Running         Running 14 seconds ago
```
移除服务，这将停止其所有任务。

```$ docker service rm devtest-service```

移除服务并不会移除服务创建的任何卷，卷的移除是个单独的步骤。

## 针对服务的语义差别
“docker service create”命令不支持-v 或 --volume选项，当把卷挂载进服务容易时，必须使用--mount选项。
## 用容器填充（populates）眷数据
如果你象上面提到的那样启动一个容器，新创建一个卷，并且挂载过来的卷里含有文件或目录（象上面的/app/），文件的内容就被拷贝到卷中。接下来容器挂载并使用卷，其它使用这个卷的容器也可以访问到其中的内容。

为了演示这个，本例将启动一个nginx容器，并把容器/usr/share/nginx/html中的内容填充（populates）到新卷nginx-vol中，填充的内容主要是nginx的缺省HTML内容。
```
$ docker run -d --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html nginx:latest
```
或
```
$ docker run -d --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html nginx:latest
```
运行完上面的任一例子，运行下面的命令清理容器和卷。注意清理卷是个单独的步骤：
```
$ docker container stop nginxtest
$ docker container rm nginxtest
$ docker volume rm nginx-vol
```
## 使用只读卷
对某些应用，容器需要把数据写回挂载点（bind mount ）从而能把数据持久化回Docker主机。但有些时候，容器只需要数据的只读访问。记住多个容器可以挂载同一个卷，并且这个圈可以同时维持对某些容器是读写挂载，而对另一些容器维持只读挂载。

这个例子对上面的例子稍作修改，在容器内的挂载点后添加了ro选项，这里给出了多个挂载选项，以逗号分割：
```
$ docker run -d --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html,readonly nginx:latest
```
或
```
$ docker run -d --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html:ro nginx:latest
```
用“docker inspect nginxtest”来验证只读挂载点并正确创建。查看Mounts段：
```
"Mounts": [
    {
        "Type": "volume",
        "Name": "nginx-vol",
        "Source": "/var/lib/docker/volumes/nginx-vol/_data",
        "Destination": "/usr/share/nginx/html",
        "Driver": "local",
        "Mode": "",
        "RW": false,
        "Propagation": ""
    }
],
```
停止容器并删除卷。注意卷删除是个单独的步骤。
```
$ docker container stop nginxtest
$ docker container rm nginxtest
$ docker volume rm nginx-vol
```
## 在机器间共享数据
当创建 fault-tolerant应用时，你需要配置同一服务的多个副本来访问同样的文件。

![共享卷](https://github.com/wbb1975/blogs/blob/master/container/images/volumes-shared-storage.svg)

当开发你的应用你有几种方法能达成目标：一种方法是让你的应用添加逻辑，把文件存进云对象存储系统，比如Amazon S3。另一种就是利用支持往外部存储系统比如NFS或Amazon S3写入文件的驱动来创建卷。

卷驱动能够让你从应用逻辑中抽象底层存储系统。比如，如果你的服务使用NFS驱动的卷，你就可以更新你的应用使用不同的驱动，一个例子就是把数据存到云中而不需要更改任何应用逻辑。


## 参考
- [use volumes](https://docs.docker.com/storage/volumes/)
