# 使用绑定挂载（bind mounts）
绑定挂载自Docker早期就应经在使用，相对卷，绑定挂载功能有限。当你使用绑定挂载，一个主机文件或目录就将被挂载到容器里。在主机里，文件或目录以相对或绝对路径访问。作为对比，当你使用卷时，一个新目录在主机上的Docker存储目录中被创建，并由Docker来管理目录的内容。

这个文件或目录无需在Docker主机上存在，如果不存在，它就会被按需创建。绑定挂载性能很好，但它依赖于主机删文件系统有一套特殊的可用的目录结构。如果你在开发新的Docker应用，请考虑使用命名卷。你不能够使用Docker命令行来直接管理绑定挂载。

![types-of-mounts-volume](https://github.com/wbb1975/blogs/blob/master/container/images/types-of-mounts-volume.png)

## 选择-v或--mount标记
最初，-v或--volume标记用于单独的容器而--mount用于一大群服务。但是，从Docker 17.06开始，--mount选项也可用于单独的容器。基本上，--mount更直白，更冗长。最大的区别在于-v在一个字段中把多个选项绑定在一起，而--mount把选项分开。下面是每个选项的语法对比。
> 小技巧：新用户应该尽量使用--mount语法，有经验的用户可能对-v 或 --volume更熟悉，但鼓励使用--mount选项，研究显示它更易于使用。
- -v or --volume：由三个被冒号分割的（:）字段构成，这些这段必须顺序正确，并且每个字段的含义并非马上就很清晰:
  1. 如果绑定挂载，第一个字段是指向主机上的文件或目录的路径
  2. 第二个字段是文件或目录在容器中的挂载路径
  3. 第三个字段可选，是逗号分隔的选项列表，比如ro, consistent, delegated, cached, z, 和 Z。这些选项稍后再细谈。
- --mount：由多个逗号分割的键值对组成，键值对格式为“键＝值”。--mount语法比-v or --volume冗长，但它键的顺序不重要，而且它的选项值更易理解。
  1. type：挂载类型，它可以是bind，volume，或tmpfs。本文讨论绑定挂载，所以type总是设为bind。
  2. source：挂载源，如果是绑定挂载，用于指定Docker引擎主机文件或目录的路径。可以选择用source或src指定。
  3. destination：目标路径，用于指定文件或目录在容器中的路径，可以用destination，dst或target来指定。
  4. readonly：只读选项，如果存在，则只读挂载。
  5. bind propagation：绑定传播，如果存在，将改变绑定传播属性。可以为rprivate, private, rshared, shared, rslave, slave之一。
  6. consistency：一致性选项，可以为consistent, delegated, 或　cached。仅仅适用Mac平台的Docker桌面，其它所有平台将被忽略。
  7. --mount标记不支持用z 或 Z去改变安全标签Linux（selinux labels）

下面的例子将显示--mount和-v语法，--mount会被首先演示。

## -v和--mount的行为差异
因为-v 和 --volume标记已经是Docker的一部分很久了，它们的行为不能改变。这也意味着在-v 间 --mount有一个不同的行为差异。

如果你使用-v 或 --volume来绑定挂载一个在Docker主机不存在的文件或目录，-v选项将为你创建这个端点（endpoint）。它总是被创建为一个目录。

如果你使用--mount来绑定挂载一个在Docker主机不存在的文件或目录，Docker不会为你自动创建它，但会产生一个错误。

## 带绑定挂载启动容器
考虑一个例子，你有一个名为source的目录，当你编译代码的时候，编译结果都被保存到source/target/。如果你期望编译结果被放到容器中的/app/，并且你期望在你的开发机上每次编译代码时容器能够访问到编译结果。使用下面的命令把target/目录绑定挂载到容器中的/app/，从source目录运行这个命令。在Linux 或　macOS 主机上$(pwd)子命令被展开成当前工作目录。

下面--mount 和 -v的例子将产生一样的结果。你不能同时运行两者，除非当您运行完第一个容器后删除devtest容器。
```
$ docker run -d -it --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app nginx:latest
```

或者

```$ docker run -d -it --name devtest -v "$(pwd)"/target:/app nginx:latest```

使用“docker inspect devtest”来验证绑定挂载是否被成功创建。查看Mounts段：
```
"Mounts": [
    {
        "Type": "bind",
        "Source": "/tmp/source/target",
        "Destination": "/app",
        "Mode": "",
        "RW": true,
        "Propagation": "rprivate"
    }
],
```

结果显示挂载的类型是绑定挂载，同时也展示了挂载的源和目标，以及挂载后的读写属性，并且传播属性被设置为rprivate。

停止容器：
```
$ docker container stop devtest
$ docker container rm devtest
```
### 挂载到容器中的一个非空目录
如果你绑定挂载到容器中的一个非空目录，那么目录中的已有内容将会被绑定挂载屏蔽。这可能是有用的，比如你期待测试你的应用的最新版本而不想重新创建镜像。但是，它也可能是令人吃惊的，其行为与卷不同。

下面的例子有点极端，用宿主主机上的/tmp/目录替换容器中的/usr/目录。在大多数情况下，这将导致一个不可用的容器。

--mount 和 -v的例子将产生一样的结果。

```
$ docker run -d -it --name broken-container --mount type=bind,source=/tmp,target=/usr nginx:latest

docker: Error response from daemon: oci runtime error: container_linux.go:262:
starting container process caused "exec: \"nginx\": executable file not found in $PATH".
```

或者

```
$ docker run -d -it --name broken-container -v /tmp:/usr nginx:latest

docker: Error response from daemon: oci runtime error: container_linux.go:262:
starting container process caused "exec: \"nginx\": executable file not found in $PATH".
```
容器可以被创建，但不能启动。删除它：

```$ docker container rm broken-container```
### 使用只读绑定挂载
对某些应用，容器需要把数据写回挂载点（bind mount）从而能把数据持久化回Docker主机。但有些时候，容器只需要数据的只读访问。

这个例子对上面的例子稍作修改，在容器内的挂载点后添加了ro选项，这里给出了多个挂载选项，以逗号分割：

```$ docker run -d -it --name devtest --mount type=bind,source="$(pwd)"/target,target=/app,readonly nginx:latest```

或者

```$ docker run -d -it --name devtest -v "$(pwd)"/target:/app:ro nginx:latest```

使用“docker inspect devtest”来验证绑定挂载是否被成功创建。查看Mounts段：
```
"Mounts": [
    {
        "Type": "bind",
        "Source": "/tmp/source/target",
        "Destination": "/app",
        "Mode": "ro",
        "RW": false,
        "Propagation": "rprivate"
    }
],
```
停止容器：
```
$ docker container stop devtest
$ docker container rm devtest
```
### 配置绑定扩散（bind propagation）
对卷和绑定挂载来说缺省绑定扩散都为rprivate。只有对Linux宿主机，并且绑定挂载才可配置。绑定扩散是个高级主题，许多用户从不需要更改它。

绑定扩散指对由命名卷和绑定挂载创建的挂载点，可否扩散到其副本上去。考虑一个挂载点/mnt，他也被挂载到/tmp。扩散设置控制是否挂载点/tmp/a在/mnt/a仍然可用。每个扩散设置有一个对应递归对应物。在递归的情况下，考虑/tmp/a是否被挂载为/foo。扩散设置控制/mnt/a 和/或 /tmp/a是否存在。

扩散设置|描述
----|----
shared|原始挂载点的子挂载点在副本挂载点可见，副本挂载点的子挂载点在原始挂载点可见
slave|和shared类似，但只有单向。如果原始挂载点暴露其子挂载点，副本挂载点可以见到它；但是，如果副本挂载点暴露其子挂载点，原始挂载点不能见到它
private|挂载点私有。原始挂载点的子挂载点对副本挂载点不可见，副本挂载点的子挂载点在原始挂载点也不可见
rshared|和shared相同，但扩散属性延伸到原始挂载点和副本挂载点的所有子挂载点。
rslave|和slave相同，但扩散属性延伸到原始挂载点和副本挂载点的所有子挂载点。
rprivate|缺省设置，和private相同，意味着原始挂载点和副本挂载点的所有子挂载点在任何方向上都不可见。

在你对一个挂载点设置绑定扩散之前，主机文件系统应该已支持绑定扩散。关于绑定扩散的更多信息，请参见[Linux kernel documentation for shared subtree](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)。

下面的例子把target/挂载到容器中两次，且第二次挂载设置了ro属性和rslave绑定扩散属性。

--mount 和 -v拥有一样的效果。

```$ docker run -d -it --name devtest -v "$(pwd)"/target:/app -v "$(pwd)"/target:/app2:ro,rslave nginx:latest```

或者

```$ docker run -d -it --name devtest -v "$(pwd)"/target:/app -v "$(pwd)"/target:/app2:ro,rslave nginx:latest```

现在如果你创建/app/foo/, /app2/foo/也会存在。

## 配置安全Linux标签（selinux label）
如果你使用安全Linux（selinux），你可以添加z 和 Z选项来更改挂载到容器中的主机上的文件或目录的安全Linux标签。这将影响到这些文件或目录在宿主机器上的文件本身，还在Docker之外带来一系列后果：
+ z选项指示绑定挂载点的内容在多个容器间共享
+ Z选项指示绑定挂载点的内容是私有，不共享的
  
对这两个选项应高度警惕。用Z选项绑定挂载一个系统目录，比如/home 或 /usr，将使你的宿主局不能互操作，而你可能需要顺手重新给你的宿主机文件打标签。
> 重要：当对服务使用绑定挂载时，安全Linux标签 (:Z 和 :z)，以及:ro选项将会被忽略。更多细节请参见[moby/moby #32579](https://github.com/moby/moby/issues/32579)

下面的例子使用z来指定多个容器可以共享绑定挂载点的内容：

不能使用--mount选项来改变安全Linux标签

```$ docker run -d -it --name devtest -v "$(pwd)"/target:/app:z nginx:latest```

## 参考
- [bind mounts](https://docs.docker.com/storage/bind-mounts/)