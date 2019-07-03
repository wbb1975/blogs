# 使用卷（volumes）
卷是持久化Docker容器产生和使用的首选方案，虽然绑定点依赖于主机目录结构，卷却是完全由容器控制。卷相比绑定点有如下优势：
- 卷相对绑定点易于备份和迁移
- 你可以用Docker命令行和Docker API来管理卷
- 卷在Linux，Windows容器上皆可工作
- 卷能够更安全地在多个容器间共享
- 卷驱动可以让你把卷存在远端主机甚至云上，加密卷的内容，或者别的什么功能
- 卷可拥有由容器预先产生的内容
此外，卷通常是比利用容器的可写层来持久化数据的更好的选择，因为卷不会增加使用卷的容器的大小，而且卷的内容的生命周期与容器无关。

![types-of-mounts-volume](https://github.com/wbb1975/blogs/blob/master/container/images/types-of-mounts-volume.png)

如果你的容器将要产生非持久化的状态数据，可以考虑用临时文件系统挂载（tmpfs mount）来避免把数据到处持久化，而且，由于不把数据写入容器可写层。从而提升了容器的性能。

卷使用rpricate绑定传播（bind propagation），而绑定传播不能针对卷配置。
## 选择-v或--mount标记
最初，-v或--volume标记用于单独的容器而--mount用于一大群服务。但是，从Docker 17.06开始，--mount选项也可用于单独的容器。基本上，--mount更直白，更冗长。最大的区别在于-v在一个字段中把多个选项绑定在一起，而--mount把选项分开。下面是每个选项的无法对比。
> 新用户应该尽量使用--mount语法，它把-v更简单

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

## 参考
- [use volumes](https://docs.docker.com/storage/volumes/)