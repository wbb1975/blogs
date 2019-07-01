# Docker之几种storage-driver比较
目前Docker支持如下几种storage driver：
- overlay2 is the preferred storage driver, for all currently supported Linux distributions, and requires no extra configuration.
- aufs is the preferred storage driver for Docker 18.06 and older, when running on Ubuntu 14.04 on kernel 3.13 which has no support for overlay2.
- devicemapper is supported, but requires direct-lvm for production environments, because loopback-lvm, while zero-configuration, has very poor performance. devicemapper was the recommended storage driver for CentOS and RHEL, as their kernel version did not support overlay2. However, current versions of CentOS and RHEL now have support for overlay2, which is now the recommended driver.
- The btrfs and zfs storage drivers are used if they are the backing filesystem (the filesystem of the host on which Docker is installed). These filesystems allow for advanced options, such as creating “snapshots”, but require more maintenance and setup. Each of these relies on the backing filesystem being configured correctly.
- The vfs storage driver is intended for testing purposes, and for situations where no copy-on-write filesystem can be used. Performance of this storage driver is poor, and is not generally recommended for production use.

## Storage Driver的选择
可以使用docker info命令查看你的Docker使用的storage driver，我的机器上的信息如下：
```
 ...
 Storage Driver: aufs
 Root Dir: /var/snap/docker/common/var-lib-docker/aufs
 Backing Filesystem: xfs
 Dirs: 104
 Dirperm1 Supported: true
 ...
```
可以看到的我本机上使用的storage driver是aufs。此外，还有一个Backing Filesystem它只你本机的文件系统，我的是xfs，aufs是在extfs之上创建的。你能够使用的storage driver是与你主机上的Backing Filesystem有关的。比如，btrfs只能在backing filesystem为btrfs上的主机上使用。storage driver与Backing Filesystem的匹配关系如下表所示:
Storage driver|Supported backing filesystems
--|--
overlay2|overlay	xfs with ftype=1, ext4
aufs|xfs, ext4
devicemapper|direct-lvm
btrfs|btrfs
zfs|zfs
vfs|any filesystem

你可以通过在docker daemon命令中添加--storage-driver=<name>标识来指定要使用的storage driver，或者在/etc/default/docker文件中通过DOCKER_OPTS指定。选择的storage driver对容器中的应用是有影响的，那具体选择哪种storage driver呢？答案是“It depends”，有如下几条原则可供参考： 
- 选择你及你的团队最熟悉的
- 如果你的设施由别人提供技术支持，那么选择它们擅长的
- 选择有比较完备的社区支持的

## AUFS
AUFS是Docker最先使用的storage driver，它技术很成熟，社区支持也很好，它的特性使得它成为storage driver的一个好选择，使用它作为storage driver，Docker会： 
- 容器启动速度很快 
- 存储空间利用很高效 
- 内存的利用很高效

尽管如此，仍有一些Linux发行版不支持AUFS，主要是它没有被并入Linux内核。下面对AUFS的特性做介绍：
- AUFS是一种联合文件系统，意思是它将同一个主机下的不同目录堆叠起来(类似于栈)成为一个整体，对外提供统一的视图。AUFS是用联合挂载来做到这一点。 
- AUFS使用单一挂载点将多个目录挂载到一起，组成一个栈，对外提供统一的视图，栈中的每个目录作为一个分支。栈中的每个目录包括联合挂载点都必须在同一个主机上。 
- 在Docker中，AUFS实现了镜像的分层。AUFS中的分支对应镜像中的层。 
- 此外，容器启动时创建的读写层也作为AUFS的一个分支挂载在联合挂载点上。

### aufs中文件的读写
AUFS通过写时复制策略来实现镜像镜像的共享和最小化磁盘开销。AUFS工作在文件的层次上，也就是说AUFS对文件的操作需要将整个文件复制到读写层内，哪怕只是文件的一小部分被改变，也需要复制整个文件。这在一定成度上会影响容器的性能，尤其是当要复制的文件很大，文件在栈的下面几层或文件在目录中很深的位置时，对性能的影响会很显著。 

### aufs中文件的删除
AUFS通过在最顶层(读写层)生成一个whiteout文件来删除文件。whiteout文件会掩盖下面只读层相应文件的存在，但它事实上没有被删除。

### Docker中使用aufs
要在Docker中使用AUFS，首先查看系统是否支持AUFS：
```
wangbb@wangbb-ThinkPad-T420:~/git/blogs$ grep aufs /proc/filesystems 
nodev	aufs
```

然后在dockerdaemon中添加--storage-driver使之支持AUFS：
```
$ docker daemon --storage-driver=aufs &
```

或者在/etc/default/docker文件中加入：
```
DOCKER_OPTS="--storage-driver=aufs"
```

### AUFS下的本地存储 
以AUFS作为storage dirver，Docker的镜像和容器的文件都存储在/var/lib/docker/aufs文件夹下。
- 镜像(Image): 
  Docker镜像的各层的全部内容都存储在/var/lib/docker/aufs/diff/<image-id>文件夹下，每个文件夹下包含了该镜像层的全部文件和目录，文件以各层的UUID命名。 
  /var/lib/docker/aufs/layer文件夹下包含的是有关镜像之间的各层是如何组织的元数据。该文件夹下的每一个文件对应镜像或容器中的一个层，每个文件中的内容是该层下面的层的UUID，按照从上至下的顺序排列。
- 容器(Container):
  正在运行的容器的文件系统被挂载在/var/lib/docker/aufs/mnt/<container-id>文件夹下，这就是AUFS的联合挂载点，在这里的文件夹下，你可以看到容器文件系统的所有文件。如果容器没有在运行，它的挂载目录仍然存在，不过是个空文件夹。 
  容器的元数据和各种配置文件被放在/var/lib/docker/containers/<container-id>文件夹下，无论容器是运行还是停止都会有一个文件夹。如果容器正在运行，其对应的文件夹下会有一个log文件。 
  容器的只读层存储在/var/lib/docker/aufs/diff/<container-id>目录下，对容器的所有修改都会保存在这个文件夹下，即便容器停止，这个文件夹也不会删除。也就是说，容器重启后并不会丢失原先的更改。 
  容器中镜像层的信息存储在/var/lib/docker/aufs/layers/<container-id>文件中。文件中从上至下依次记录了容器使用的各镜像层。

### AUFS在Docker中的性能表现
AUFS在性能方面的特性可以总结如下： 
- 在容器密度比较高的场景下，AUFS是非常好的选择，因为AUFS的容器间共享镜像层的特性使其磁盘利用率很高，容器的启动时间很短； 
- AUFS中容器之间的共享使对系统页缓存的利用率很高； 
- AUFS的写时复制策略会带来很高的性能开销，因为AUFS对文件的第一次更改需要将整个文件复制带读写层，当容器层数很多或文件所在目录很深时尤其明显；

最后，需要说明的是，数据卷(data volumes)可以带来很好的性能表现，这是因为它绕过storage driver直接将文件卸载宿主机上，不需要使用写时复制策略。正因如此，当需要大量的文件写操作时最好使用数据卷。

## device mapper
Docker在Debian，Ubuntu系的系统中默认使用aufs，在RedHat系中使用device mapper。device mapper在Linux2.6内核中被并入内核，它很稳定，也有很好的社区支持。

device mapper中镜像的分层和共享:

device mapper将所有的镜像和容器存储在它自己的虚拟设备上，这些虚拟设备是一些支持写时复制策略的快照设备。device mapper工作在块层次上而不是文件层次上，这意味着它的写时复制策略不需要拷贝整个文件。device mapper创建镜像的过程如下： 
- 使用device mapper的storge driver创建一个精简配置池；精简配置池由块设备或稀疏文件创建。
- 接下来创建一个基础设备； 
- 每个镜像和镜像层都是基础设备的快照；这写快照支持写时复制策略，这意味着它们起始都是空的，当有数据写入时才耗费空间。

在device mapper作为storage driver的系统中，容器层container layer是它依赖的镜像的快照。与镜像一样，container layer也支持写时复制策略，它保存了所有对容器的更改。当有数据需要写入时，device mapper就为它们在资源池中分配空间:

![资源池，基础设备和两个镜像之间的关系](https://github.com/wbb1975/blogs/blob/master/container/images/devicemapper.jpg)

从上面的图可以看出，镜像的每一层都是它下面一层的快照，镜像最下面一层是存在于thin pool中的base device的快照。容器是创建容器的镜像的快照，
![容器与镜像的关系](https://github.com/wbb1975/blogs/blob/master/container/images/container_and_image.jpg)

### device mapper中的读操作
下图展示了容器中的某个进程读取块号为0x44f的数据： 

![devicemapper read](https://github.com/wbb1975/blogs/blob/master/container/images/devicemapper_read.jpg)

步骤如下： 
- 某个进程发出读取文件的请求；由于容器只是镜像的精简快照(thin snapshot)，它并没有这个文件。但它有指向这个文件在下面层中存储位置的指针。 
- device mapper由指针找到在镜像层号为a005e中的块号为0xf33的数据； 
- device mapper将这个位置的文件复制到容器的存储区内； 
- device mapper将数据返回给应用进程；

### device mapper中的写操作
在device mapper中，对容器的写操作由“需要时分配”策略完成。更新已有数据由“写时复制”策略完成，这些操作都在块的层次上完成，每个块的大小为64KB。 
向容器写入56KB的新数据的步骤如下： 
- 进程向容器发出写56KB数据的请求； 
- device mapper的“需要时分配”策略分配一个64KB的块给容器快照(container snapshot)；如果要写入的数据大于64KB，就分配多个大小为64KB的块。 
- 将数据写入新分配的块中；

### device mapper在Docker中的性能表现
device mapper的性能主要受“需要时分配”策略和“写时复制”策略影响，下面分别介绍：
- 需要时分配(allocate-on-demand)
  device mapperdriver通过allocate-on-demand策略为需要写入的数据分配数据块。也就是说，每当容器中的进程需要向容器写入数据时，device mapper就从资源池中分配一些数据块并将其映射到容器。当容器频繁进行小数据的写操作时，这种机制非常影响影响性能。一旦数据块被分配给了容器，对它进行的读写操作都直接对块进行操作了。
- 写时复制(copy-on-write)
  与aufs一样，device mapper也支持写时复制策略。容器中第一次更新某个文件时，device mapper调用写时复制策略，将数据块从镜像快照中复制到容器快照中。device mapper的写时复制策略以64KB作为粒度，意味着无论是对32KB的文件还是对1GB大小的文件的修改都仅复制64KB大小的文件。这相对于在文件层面进行的读操作具有很明显的性能优势。但是，如果容器频繁对小于64KB的文件进行改写，device mapper的性能是低于aufs的。
- 存储空间使用效率
  device mapper不是最有效使用存储空间的storage driver，启动n个相同的容器就复制了n份文件在内存中，这对内存的影响很大。所以device mapper并不适合容器密度高的场景。