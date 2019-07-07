# 使用临时文件系统挂载（tmpfs mounts）
卷和绑定挂载让你在宿主机和容器间共享文件，从而即使容器已经停止你扔可以保留数据。

如果你在Linux上运行Docker，你可以有第三种选择：临时文件系统挂载（tmpfs）。当你创建一个含tmpfs挂载的容器时，容器将在其可写层之外创建文件。

和卷和绑定挂载相反，一个文件系统挂载是一个临时的，只被持久化到内存的挂载。当容器停止后，临时文件系统挂载将被删除，所写文件将不会被保留。
这个文件或目录无需在Docker主机上存在，如果不存在，它就会被按需创建。绑定挂载性能很好，但它依赖于主机删文件系统有一套特殊的可用的目录结构。如果你在开发新的Docker应用，请考虑使用命名卷。你不能够使用Docker命令行来直接管理绑定挂载。

![types-of-mounts-tmpfs](https://github.com/wbb1975/blogs/blob/master/container/images/types-of-mounts-tmpfs.png)

这种临时存储当你不想把敏感文件保留到宿主机器或者容器可写层来说是有用的。
## 临时文件系统挂载的局限
+ 不想卷和绑定挂载，你不能在容器间共享临时文件系统挂载
+ 此功能只在运行Linux的Docker上可用。

## 选择--tmpfs 或 --mount标记
最初，--tmpfs用于独立容器，--mount用于一大群服务（swarm services）。但是，从Docker 17.06开始，--mount选项也可用于独立容器。基本上，--mount更直白，更冗长。最大的区别在于--tmpfs不支持任何可配选项。
- --tmpfs：挂在一个临时文件系统挂载，不能够指定任何可配选项，并且只能用于用于独立容器
- --mount：由多个逗号分割的键值对组成，键值对格式为“键＝值”。--mount语法比volume冗长
   + type：挂载类型，它可以是bind，volume，或tmpfs。本文讨论临时文件系统挂载，所以type总是设为tmpfs。
   + destination：目标路径，用于指定文件或目录在容器中的路径，可以用destination，dst或target来指定。
   + tmpfs-type和tmpfs-mode，详见临时文件系统挂载选项

下面的例子将显示--mount和-v语法，--mount会被首先演示。
## --tmpfs和--mount的行为差异
- --tmpfs标记不允许你指定任何可配选项
- --tmpfs不能用于一大群服务（swarm services）。你可以使用--mount标记
## 在容器中使用临时文件系统挂载
为了在容器中使用临时文件系统挂载，可以使用--tmpfs标记，或者带type=tmpfs 和 destination选项使用--mount标记。临时文件系统挂载没有source选项。下面的例子在Nginx容器的/app创建一个临时文件系统挂载。第一个例子使用--mount标记，第二个使用--tmpfs标记。

```$ docker run -d -it --name tmptest --mount type=tmpfs,destination=/app nginx:latest```

或者

```$ docker run -d -it --name tmptest --tmpfs /app nginx:latest```

使用“docker container inspect tmptest”来验证临时文件系统挂载是否被成功创建。查看Mounts段：
```
"Tmpfs": {
    "/app": ""
},
```
停止容器：
```
$ docker container stop tmptest
$ docker container rm tmptest
```
### 指定临时文件系统挂载选项
临时文件系统挂载选项允许你指定两个选项，但没有一个是必须的。如果你需要指定他们，必须使用--mount标记，因为--tmpfs不支持它们。
选项|描述
----|----
tmpfs-size|临时文件系统挂载以字节记大小，缺省无限制
tmpfs-mode|临时文件系统挂载的八进制文件模式。例如700 or 0770，缺省1777，全部可写。

下面的例子设置tmpfs-mode为1770，因此在容器内并非全部可读了。

```docker run -d -it --name tmptest --mount type=tmpfs,destination=/app,tmpfs-mode=1770 nginx:latest```

## 参考
- [tmpfs mounts](https://docs.docker.com/storage/tmpfs/)