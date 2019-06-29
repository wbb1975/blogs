# Linux2.6 内核的Initrd机制解析

## 1. 什么是Initrd
initrd 的英文含义是 boot loader initialized RAM disk，就是由 boot loader 初始化的内存盘。在 linux内核启动前， boot loader 会将存储介质中的 initrd 文件加载到内存，内核启动时会在访问真正的根文件系统前先访问该内存中的 initrd 文件系统。在 boot loader 配置了 initrd 的情况下，内核启动被分成了两个阶段，第一阶段先执行 initrd 文件系统中的"某个文件"，完成加载驱动模块等任务，第二阶段才会执行真正的根文件系统中的 /sbin/init 进程。这里提到的"某个文件"，Linux2.6 内核会同以前版本内核的不同，所以这里暂时使用了"某个文件"这个称呼，后面会详细讲到。第一阶段启动的目的是为第二阶段的启动扫清一切障碍，最主要的是加载根文件系统存储介质的驱动模块。我们知道根文件系统可以存储在包括IDE、SCSI、USB在内的多种介质上，如果将这些设备的驱动都编译进内核，可以想象内核会多么庞大、臃肿。

Initrd 的用途主要有以下四种：
1. Initrd 的用途主要有以下四种：
   linux 发行版必须适应各种不同的硬件架构，将所有的驱动编译进内核是不现实的，initrd 技术是解决该问题的关键技术。Linux 发行版在内核中只编译了基本的硬件驱动，在安装过程中通过检测系统硬件，生成包含安装系统硬件驱动的 initrd，无非是一种即可行又灵活的解决方案。
2. livecd 的必备部件
   同 linux 发行版相比，livecd 可能会面对更加复杂的硬件环境，所以也必须使用 initrd。
3. 制作 Linux usb 启动盘必须使用 initrd
   usb 设备是启动比较慢的设备，从驱动加载到设备真正可用大概需要几秒钟时间。如果将 usb 驱动编译进内核，内核通常不能成功访问 usb 设备中的文件系统。因为在内核访问 usb 设备时， usb 设备通常没有初始化完毕。所以常规的做法是，在 initrd 中加载 usb 驱动，然后休眠几秒中，等待 usb设备初始化完毕后再挂载 usb 设备中的文件系统。
4. 在 linuxrc 脚本中可以很方便地启用个性化 bootsplash。
   
## 2．Linux2.4内核对Initrd的处理流程
Linux2.4内核的initrd的格式是文件系统镜像文件，本文将其称为image-initrd，以区别后面介绍的linux2.6内核的cpio格式的initrd。 linux2.4内核对initrd的处理流程如下：
1. boot loader把内核以及/dev/initrd的内容加载到内存，/dev/initrd是由boot loader初始化的设备，存储着initrd。
2. 在内核初始化过程中，内核把 /dev/initrd 设备的内容解压缩并拷贝到 /dev/ram0 设备上。
3. 内核以可读写的方式把 /dev/ram0 设备挂载为原始的根文件系统。
4. 如果 /dev/ram0 被指定为真正的根文件系统，那么内核跳至最后一步正常启动。
5. 执行 initrd 上的 /linuxrc 文件，linuxrc 通常是一个脚本文件，负责加载内核访问根文件系统必须的驱动， 以及加载根文件系统。
6. /linuxrc 执行完毕，真正的根文件系统被挂载。
7. 如果真正的根文件系统存在 /initrd 目录，那么 /dev/ram0 将从 / 移动到 /initrd。否则如果 /initrd 目录不存在， /dev/ram0 将被卸载。
8. 在真正的根文件系统上进行正常启动过程 ，执行 /sbin/init。 linux2.4 内核的 initrd 的执行是作为内核启动的一个中间阶段，也就是说 initrd 的 /linuxrc 执行以后，内核会继续执行初始化代码，我们后面会看到这是 linux2.4 内核同 2.6 内核的 initrd 处理流程的一个显著区别。

## 3. Linux2.6 内核对 Initrd 的处理流程
linux2.6 内核支持两种格式的 initrd，一种是前面第 3 部分介绍的 linux2.4 内核那种传统格式的文件系统镜像－image-initrd，它的制作方法同 Linux2.4 内核的 initrd 一样，其核心文件就是 /linuxrc。另外一种格式的 initrd 是 cpio 格式的，这种格式的 initrd 从 linux2.5 起开始引入，使用 cpio 工具生成，其核心文件不再是 /linuxrc，而是 /init，本文将这种 initrd 称为 cpio-initrd。尽管 linux2.6 内核对 cpio-initrd和 image-initrd 这两种格式的 initrd 均支持，但对其处理流程有着显著的区别，下面分别介绍 linux2.6 内核对这两种 initrd 的处理流程。

cpio-initrd 的处理流程
1. boot loader 把内核以及 initrd 文件加载到内存的特定位置。
2. 内核判断initrd的文件格式，如果是cpio格式。
3. 将initrd的内容释放到rootfs中。
4. 执行initrd中的/init文件，执行到这一点，内核的工作全部结束，完全交给/init文件处理。
   
image-initrd的处理流程
1. boot loader把内核以及initrd文件加载到内存的特定位置。
2. 内核判断initrd的文件格式，如果不是cpio格式，将其作为image-initrd处理
3. 内核将initrd的内容保存在rootfs下的/initrd.image文件中。
4. 内核将/initrd.image的内容读入/dev/ram0设备中，也就是读入了一个内存盘中。
5. 接着内核以可读写的方式把/dev/ram0设备挂载为原始的根文件系统。
6. 如果/dev/ram0被指定为真正的根文件系统，那么内核跳至最后一步正常启动。
7. 执行initrd上的/linuxrc文件，linuxrc通常是一个脚本文件，负责加载内核访问根文件系统必须的驱动， 以及加载根文件系统。
8. 	/linuxrc执行完毕，常规根文件系统被挂载
9. 如果常规根文件系统存在/initrd目录，那么/dev/ram0将从/移动到/initrd。否则如果/initrd目录不存在， /dev/ram0将被卸载。
10. 在常规根文件系统上进行正常启动过程 ，执行/sbin/init。

通过上面的流程介绍可知，Linux2.6内核对image-initrd的处理流程同linux2.4内核相比并没有显著的变化， cpio-initrd的处理流程相比于image-initrd的处理流程却有很大的区别，流程非常简单，在后面的源代码分析中，读者更能体会到处理的简捷。

## 4．cpio-initrd同image-initrd的区别与优势
没有找到正式的关于cpio-initrd同image-initrd对比的文献，根据笔者的使用体验以及内核代码的分析，总结出如下三方面的区别，这些区别也正是cpio-initrd的优势所在：
- cpio-initrd的制作方法更加简单
  cpio-initrd的制作非常简单，通过两个命令就可以完成整个制作过程
  ```
  #假设当前目录位于准备好的initrd文件系统的根目录下
  bash# find . | cpio -c -o > ../initrd.img
  bash# gzip ../initrd.img
  ```

  而传统initrd的制作过程比较繁琐，需要如下六个步骤
  ```
  #假设当前目录位于准备好的initrd文件系统的根目录下
  bash# dd if=/dev/zero of=../initrd.img bs=512k count=5
  bash# mkfs.ext2 -F -m0 ../initrd.img
  bash# mount -t ext2 -o loop ../initrd.img  /mnt
  bash# cp -r  * /mnt
  bash# umount /mnt
  bash# gzip -9 ../initrd.img
  ```
- cpio-initrd的内核处理流程更加简化
  通过上面initrd处理流程的介绍，cpio-initrd的处理流程显得格外简单，通过对比可知cpio-initrd的处理流程在如下两个方面得到了简化：
  1. cpio-initrd并没有使用额外的ramdisk,而是将其内容输入到rootfs中，其实rootfs本身也是一个基于内存的文件系统。这样就省掉了ramdisk的挂载、卸载等步骤。
  2. cpio-initrd启动完/init进程，内核的任务就结束了，剩下的工作完全交给/init处理；而对于image-initrd，内核在执行完/linuxrc进程后，还要进行一些收尾工作，并且要负责执行真正的根文件系统的/sbin/init。通过图1可以更加清晰的看出处理流程的区别：
   
   图1 内核对cpio-initrd和image-initrd处理流程示意图
  ![cpio-initrd和image-initrd处理流程](https://github.com/wbb1975/blogs/blob/master/container/images/initrd_workflow.gif)
- cpio-initrd的职责更加重要
  如图1所示，cpio-initrd不再象image-initrd那样作为linux内核启动的一个中间步骤，而是作为内核启动的终点，内核将控制权交给cpio-initrd的/init文件后，内核的任务就结束了，所以在/init文件中，我们可以做更多的工作，而不比担心同内核后续处理的衔接问题。当然目前linux发行版的cpio-initrd的/init文件的内容还没有本质的改变，但是相信initrd职责的增加一定是一个趋势。

## 5. linux2.6内核initrd处理的源代码分析

