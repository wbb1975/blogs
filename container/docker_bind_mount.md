# 使用绑定挂载（bind mounts）
绑定挂载自Docker早期就应经在使用，相对卷，绑定挂载功能有限。当你使用绑定挂载，一个主机文件或目录就将被挂载到容器里。在主机里，文件或目录以相对或绝对路径访问。作为对比，当你使用卷时，一个新目录在主机上的Docker存储目录中被创建，并由Docker来管理目录的内容。

这个文件或目录无需在Docker主机上存在，如果不存在，它就会被按需创建。绑定挂载性能很好，但它依赖于主机删文件系统有一套特殊的可用的目录结构。如果你在开发新的Docker应用，请考虑使用命名卷。你不能够使用Docker命令行来直接管理绑定挂载。

![types-of-mounts-volume](https://github.com/wbb1975/blogs/blob/master/container/images/types-of-mounts-volume.png)