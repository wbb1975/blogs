# Namespaces in operation
> By Michael Kerrisk January 4, 2013
## part 1: namespaces overview
从Linux 3.8的合并窗口可以看到Eric Biederman数量可观的系列[用户名字空间及相关补丁](https://lwn.net/Articles/528078/)。虽然还留有一些细节待完成--例如许多Linux 文件系统不是用户名字空间感知的--用户名字空间的功能实现尚未完全结束。

基于许多原因，用户名字空间工作的完成可从某种意义上视为一个里程碑。首先，这项工作代表了迄今为止最复杂的名字空间实现之一的完成，且被从用户名字空间实现的第一步（Linux 2.6.23）以来的近五年的工作所见证。其次，名字空间的工作最近达到了某个“稳定点”，其中大部分存在的名字空间实现已经完成。这并不意味着名字空间的工作已经结束：将来有可能加入其它的名字空间，已有的名字空间将来也有可能被扩展，例如[内核日志的名字空间隔离](https://lwn.net/Articles/527342/)的加入。最好，最近的用户名字空间实现的变化改变了游戏规则--它改变了名字空间的使用方式：从Linux 3.8 开始，非特权进程可以创建用户名字空间，且在其中它们拥有完全权限。它接下来可允许其它类型名字空间在用户名字空间被创建。

因此，当前节点可被视为一个很好的点来纵览名字空间，并以实际的观点检视名字空间API。本文是系列文章的第一篇：在本文中，我们提供了当前可用名字空间的一个概览；在接下来的文章中，我们将展示如何在程序中使用名字空间API。
### 名字空间（家族）
当前Linux实现了6种不同类型的名字空间。每种名字空间的目的在于将某种特定全局系统资源包装成某种抽象，使得这些名字空间里的进程看起来拥有这些全局资源的隔离实例。名字空间的一个综合目标是支持实现[容器](https://lwn.net/Articles/524952/)--一个轻量级虚拟化（也有其它目的）工具，可以为一组进程提供一种错觉--它们是系统里的唯一进城。

在下面的讨论中，我们按照实现的顺序讨论名字空间（或者至少，按照实现完成的顺序）。括号中的`CLONE_NEW*`标识符是用于调用名字空间相关API（如clone(), unshare(), 和 setns()）时用于识别名字空间类型的常量名，这些API将会在下面的文章讨论。

[挂载名字空间](http://lwn.net/2001/0301/a/namespaces.php3)（CLONE_NEWNS, Linux 2.4.19）隔离了一组进程看到的文件系统挂载点。因此，不同挂载名字空间的进程会看到不同的文件系统层级。随着挂载名字空间的引入， [mount()](http://man7.org/linux/man-pages/man2/mount.2.html) and [umount()](http://man7.org/linux/man-pages/man2/umount.2.html)系统调用停止了对系统上所有进程可见的全局文件系统挂载点集上操作，取而代之的是，仅仅对调用进程相关的挂载名字空间进行操作。

挂载名字空间的一个用例是创建类似chroot囚笼的环境。但是，不同于使用chroot()系统调用，挂载名字空间是针对这个任务更安全和更具弹性的工具。其它关于挂载名字空间的[更复杂使用](http://www.ibm.com/developerworks/linux/library/l-mount-namespaces/index.html)也是可能的。例如，不同的挂载名字空间可建立一种主从关系，如此挂载事件可自动从一个名字空间传播到另一个；这允许，比如说，在一个名字空间挂载的关盘设备自动出现在另一个名字空间。

挂载名字空间是Linux实现的第一种名字空间，出现于2002年。这个实时解释了相对通用的"NEWNS"名字（"new namespace"的简写）。在那个时间点，没人会想到将来还需要其它类型的名字空间。

[UTS名字空间](https://lwn.net/Articles/179345/)（CLONE_NEWUTS, Linux 2.6.19）隔离两种系统标识符--nodename 和 domainname--由[uname()](http://man7.org/linux/man-pages/man2/uname.2.html)系统调用返回；名字由`sethostname()` 和 `setdomainname()`系统调用设置。在容器上下文中，UTS名字空间特征允许每个容器有其自己的主机名和NIS 域名。这可能对于初数化或配置脚本有用--它们可以根据这些名字采取相应行动。术语"UTS"来自于传递给`uname()`系统调用的结构名：`struct utsname`。该结构的名字则来自于UNIX分时系统（"UNIX Time-sharing System"）。

[IPC名字空间](https://lwn.net/Articles/187274/) (CLONE_NEWIPC, Linux 2.6.19)隔离特定进程间通讯资源，即[System V IPC](http://www.kernel.org/doc/man-pages/online/pages/man7/svipc.7.html) 对象和 (since Linux 2.6.30) [POSIX 消息队列](http://www.kernel.org/doc/man-pages/online/pages/man7/mq_overview.7.html)。这些IPC机制的共同特征是IPC使用一种不同于文件系统路径的识别方法。每个IPC 名字空间有一套自己的System V IPC标识符和自己的POSIX 消息队列文件系统。

[PID名字空间](https://lwn.net/Articles/259217/) (CLONE_NEWPID, Linux 2.6.24) 隔离进程ID数字空间。换句话说，在不同PID名字空间的进程可以拥有相同的PID。PID名字空间的一个主要用处在于容器可以在不同宿主机上迁移，但容器里的进程可以保持相同的进程ID。PID 名字空间也允许每个容器有其自己的 init (PID 1)，“所有进程的祖先”--其负责管理各种各样系统初始化任务，以及当进程终止是收割孤儿子进程。

从一个特定PID名字空间实例看，一个进程拥有两个ID：PID名字空间内的进程ID，以及在PID名字空间外即宿主机系统里的进程ID。PID 名字空间可以前套：一个进程可以在从其所在PID名字空间的每一层拥有一个进程ID，直至根PID名字空间。一个进程仅能（通过kill()发送信号）看到自己所属PID名字空间以及该PID名字空间的附属PID名字空间里的进程。
### 总结评论（Concluding remarks）
## Part 2: the namespaces API
## Part 3: PID namespaces
## Part 4: more on PID namespaces
## Part 5: user namespaces
## Part 6: more on user namespaces
## Part 7: network namespaces
## Mount namespaces and shared subtrees
## Mount namespaces, mount propagation, and unbindable mounts
## Append A namespaces(7)

## Referecen
- [Namespaces in operation](https://lwn.net/Articles/531114/)
- [namespaces(7) — Linux manual page](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Linux kernel cgroup-v1](https://www.kernel.org/doc/Documentation/cgroup-v1/)
- [Cgroup v2(PDF)](http://events.linuxfoundation.org/sites/events/files/slides/2014-KLF.pdf)
- [Linux kernel namespaces](https://www.kernel.org/doc/Documentation/namespaces/)