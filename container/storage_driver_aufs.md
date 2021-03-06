# Docker存储 - AUFS
 Docker存储可以分为分层文件系统和卷，本文将介绍AUFS分层文件系统。

## 基础知识
### Storage driver
> docker除了支持AUFS，还支持DeviceMapper等多种storage driver。
- StorageDriver
- OverlayFS: overlay or overlay2
- AUFS : aufs
- Btrfs : btrfs
- Device Mapper: devicemapper
- VFS : vfs
- ZFS : zfs

### 什么是AUFS
> AUFS是一种Union File System, 它是Docker最早支持的storage driver。因为使用的时间也较长了，虽然还是不太习惯这个所谓的长的概念，docker从最初只支持AUFS一种，目前已经到支持上面6种FS，成长的速度飞快。最初使用docker的实践者们已经在实际环境中开始使用AUFS了，而且也有较强的社区支持。

### Linux的文件系统
一个典型的 Linux 系统要能运行的话，它至少需要两个文件系统：
- boot file system （bootfs）：包含 boot loader 和 kernel。用户不会修改这个文件系统。实际上，在启动（boot）过程完成后，整个内核都会被加载进内存，此时 bootfs 会被卸载掉从而释放出所占用的内存。同时也可以看出，对于同样内核版本的不同的 Linux 发行版的 bootfs 都是一致的。
- root file system （rootfs）：包含典型的目录结构，包括 /dev, /proc, /bin, /etc, /lib, /usr, and /tmp 等再加上要运行用户应用所需要的所有配置文件，二进制文件和库文件。这个文件系统在不同的Linux 发行版中是不同的。而且用户可以对这个文件进行修改。

Linux 系统在启动时，roofs 首先会被挂载为只读模式，然后在启动完成后被修改为读写模式，随后它们就可以被修改了。
> 简单总结为bootfs在用linux的时候不出问题是意识不到的，rootfs在linux启动之后我们无时无刻不在与之打交道。

![Linux的两类文件系统](https://github.com/wbb1975/blogs/blob/master/container/images/linux_fs.jpg)

### AUFS
AUFS 是一种 Union File System（联合文件系统），又叫 Another UnionFS，后来叫Alternative UnionFS，再后来叫成高大上的 Advance UnionFS。所谓 UnionFS，简单的来说，AUFS能将一台机器上的多个目录或文件，以联合的方式提供统一视图进行管理。下面是它的一些特点
- 最早docker所支持的storage driver
- 使用这种方式，container启动速度较快
- 存储和内存的使用效率较高
- 支持COW(copy-on-write)
- 所有的文件和目录以及挂载点都必须在同一台机器上
- AUFS迟迟不能加入到linux内核主线之中，目前流行的发型版只有ubuntu支持AUFS
- docker的layer较深时效率较为低下
- 因为AUFS是文件级别的动作方式，单个文件很大时，性能和效率不是特别理想

## Docker文件系统
### Docker 镜像的 rootfs
前面基础知识部分谈到过，同一个内核版本的所有 Linux 系统的 bootfs 是相同的，而 rootfs 则是不同的。在 Docker 中，基础镜像中的 roofs 会一直保持只读模式，Docker 会利用 union mount 来在这个 rootfs 上增加更多的只读文件系统，最后它们看起来就像一个文件系统即容器的 rootfs。

![docker rootfs](https://github.com/wbb1975/blogs/blob/master/container/images/docker_multi_layer.jpg)

可见在一个Linux 系统之中：
- 所有 Docker 容器都共享主机系统的 bootfs 即 Linux 内核
- 每个容器有自己的 rootfs，它来自不同的 Linux 发行版的基础镜像，包括 Ubuntu，Debian 和 SUSE 等
- 所有基于一种基础镜像的容器都共享这种 rootfs

### Docker 使用的 AUFS 文件系统
![ubuntu的镜像是如何用AUFS联合到一起的](https://github.com/wbb1975/blogs/blob/master/container/images/image_layer.gif)

> **注意**：AUFS把每个目录都作为一个AUFS branch，整整齐齐的垛在一起，在最上面提供了一个统一的视图union mount point进行管理。另外，对于一个容器来说，只有顶层的容器layer是可读写的，而下面的layer都是只读的。

这种分层文件系统可以通过官网的图来清晰的展示出来：

![分层文件系统系意图](https://github.com/wbb1975/blogs/blob/master/container/images/layer_fs.jpg)
### 做一些实验
1. 在容器中创建一个文件，该文件会被创建在可写的容器层中
```
root@docker1:/var/lib/docker/aufs/diff# find -iname createdbysammy
./2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab/opt/webapp/createdbysammy
root@docker1:/var/lib/docker/aufs/diff# ls -lt
total 60
drwxr-xr-x  9 root root 4096 Oct  4 22:37 2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab
drwxr-xr-x  6 root root 4096 Oct  1 11:56 2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab-init
```
2. 修改一个镜像层中的文件
   
   修改前，文件 /etc/apt/sources.list 出现在两个层中：
   ```
   root@docker1:/var/lib/docker/aufs/diff# find -iname sources.list
   ./f68672aaf17dd158aabc635b2d8d459d79db1cd5ff38bf3834fe8f9c7a05235e/etc/apt/sources.list
   ./b2188d5c09cfe24acd6da5ce67720f81138f0c605a25efc592f1f55b3fd3dffa/etc/apt/sources.list
   ```
   
   在容器中对它进行修改后，它被拷贝到了容器层然后被修改了：
   ```
   root@docker1:/var/lib/docker/aufs/diff# find -iname sources.list
   ./f68672aaf17dd158aabc635b2d8d459d79db1cd5ff38bf3834fe8f9c7a05235e/etc/apt/sources.list
   ./2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab/etc/apt/sources.list
   ./b2188d5c09cfe24acd6da5ce67720f81138f0c605a25efc592f1f55b3fd3dffa/etc/apt/sources.list
   ```
   
   而另外两个层中的文件保持了不变。这说明了 AUFS 的 CoW 特性。

3. 删除容器层中的文件
   
   容器中的文件 ./usr/local/lib/python2.7/dist-packages/itsdangerous.py 位于 56d37c8eecd8be9ba13e07e1486e7a6ac2f0aa01f8e865ee6136137369d8d8a0 层中，这是一个只读层，在容器内删除它：

   ```
   root@fa385836d5b9:/# find -iname itsdangerous.py
   ./usr/local/lib/python2.7/dist-packages/itsdangerous.py
   root@fa385836d5b9:/# rm ./usr/local/lib/python2.7/dist-packages/itsdangerous.py
   root@fa385836d5b9:/# find -iname itsdangerous.py
   ```

   然后，容器层中出现了一个 .wh 文件，而镜像层中的文件保持不变：

   ```
   root@docker1:/var/lib/docker/aufs/diff# find -iname *itsdangerous.py
   ./56d37c8eecd8be9ba13e07e1486e7a6ac2f0aa01f8e865ee6136137369d8d8a0/usr/local/lib/python2.7/dist-packages/itsdangerous.py
   ./2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab/usr/local/lib/python2.7/dist-packages/.wh.itsdangerous.py
   ```

   在手工将 .wh 文件删除后，文件就会再次回到容器中。

   ```
   rm ./2ee58d81e4ac6811bbc78beb4b46bf213c79c9e2dc7e441741afc8c4349c6bab/usr/local/lib/python2.7/dist-packages/.wh.itsdangerous.py
   root@fa385836d5b9:/# find -iname itsdangerous.py
   ./usr/local/lib/python2.7/dist-packages/itsdangerous.py
   ```

## 参考
- [Docker 存储 - AUFS](https://www.cnblogs.com/sammyliu/p/5931383.html)