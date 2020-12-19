# Namespaces in operation
> By Michael Kerrisk January 4, 2013
## part 1: namespaces overview
从Linux 3.8的合并窗口可以看到Eric Biederman数量可观的系列[用户名字空间及相关补丁](https://lwn.net/Articles/528078/)。虽然还留有一些细节待完成--例如许多Linux 文件系统不是用户名字空间感知的--用户名字空间的功能实现尚未完全结束。

基于许多原因，用户名字空间工作的完成可从某种意义上视为一个里程碑。首先，这项工作代表了迄今为止最复杂的名字空间实现之一的完成，且被从用户名字空间实现的第一步（Linux 2.6.23）以来的近五年的工作所见证。其次，名字空间的工作最近达到了某个“稳定点”，其中大部分存在的名字空间实现已经完成。这并不意味着名字空间的工作已经结束：将来有可能加入其它的名字空间，已有的名字空间将来也有可能被扩展，例如[内核日志的名字空间隔离](https://lwn.net/Articles/527342/)的加入。最好，最近的用户名字空间实现的变化改变了游戏规则--它改变了名字空间的使用方式：从Linux 3.8 开始，非特权进程可以创建用户名字空间，且在其中它们拥有完全权限。它接下来可允许其它类型名字空间在用户名字空间被创建。

因此，当前节点可被视为一个很好的点来纵览名字空间，并以实际的观点检视名字空间API。本文是系列文章的第一篇：在本文中，我们提供了当前可用名字空间的一个概览；在接下来的文章中，我们将展示如何在程序中使用名字空间API。
### 名字空间（家族）
当前Linux实现了6种不同类型的名字空间。每种名字空间的目的在于将某种特定全局系统资源包装成某种抽象，使得这些名字空间里的进程看起来拥有这些全局资源的隔离实例。名字空间的一个综合目标是支持实现[容器](https://lwn.net/Articles/524952/)--一个轻量级虚拟化（也有其它目的）工具，可以为一组进程提供一种错觉--它们是系统里的唯一进程。

在下面的讨论中，我们按照实现的顺序讨论名字空间（或者至少，按照实现完成的顺序）。括号中的`CLONE_NEW*`标识符是用于调用名字空间相关API（如clone(), unshare(), 和 setns()）时用于识别名字空间类型的常量名，这些API将会在下面的文章讨论。

[挂载名字空间](http://lwn.net/2001/0301/a/namespaces.php3)（CLONE_NEWNS, Linux 2.4.19）隔离了一组进程看到的文件系统挂载点。因此，不同挂载名字空间的进程会看到不同的文件系统层级。随着挂载名字空间的引入， [mount()](http://man7.org/linux/man-pages/man2/mount.2.html) and [umount()](http://man7.org/linux/man-pages/man2/umount.2.html)系统调用停止了对系统上所有进程可见的全局文件系统挂载点集上操作，取而代之的是，仅仅对调用进程相关的挂载名字空间进行操作。

挂载名字空间的一个用例是创建类似chroot囚笼的环境。但是，不同于使用chroot()系统调用，挂载名字空间是针对这个任务更安全和更具弹性的工具。其它关于挂载名字空间的[更复杂使用](http://www.ibm.com/developerworks/linux/library/l-mount-namespaces/index.html)也是可能的。例如，不同的挂载名字空间可建立一种主从关系，如此挂载事件可自动从一个名字空间传播到另一个；这允许，比如说，在一个名字空间挂载的关盘设备自动出现在另一个名字空间。

挂载名字空间是Linux实现的第一种名字空间，出现于2002年。这个实时解释了相对通用的"NEWNS"名字（"new namespace"的简写）。在那个时间点，没人会想到将来还需要其它类型的名字空间。

[UTS名字空间](https://lwn.net/Articles/179345/)（CLONE_NEWUTS, Linux 2.6.19）隔离两种系统标识符--nodename 和 domainname--由[uname()](http://man7.org/linux/man-pages/man2/uname.2.html)系统调用返回；名字由`sethostname()` 和 `setdomainname()`系统调用设置。在容器上下文中，UTS名字空间特征允许每个容器有其自己的主机名和NIS 域名。这可能对于初数化或配置脚本有用--它们可以根据这些名字采取相应行动。术语"UTS"来自于传递给`uname()`系统调用的结构名：`struct utsname`。该结构的名字则来自于UNIX分时系统（"UNIX Time-sharing System"）。

[IPC名字空间](https://lwn.net/Articles/187274/) (CLONE_NEWIPC, Linux 2.6.19)隔离特定进程间通讯资源，即[System V IPC](http://www.kernel.org/doc/man-pages/online/pages/man7/svipc.7.html) 对象和 (since Linux 2.6.30) [POSIX 消息队列](http://www.kernel.org/doc/man-pages/online/pages/man7/mq_overview.7.html)。这些IPC机制的共同特征是IPC使用一种不同于文件系统路径的识别方法。每个IPC 名字空间有一套自己的System V IPC标识符和自己的POSIX 消息队列文件系统。

[PID名字空间](https://lwn.net/Articles/259217/) (CLONE_NEWPID, Linux 2.6.24) 隔离进程ID数字空间。换句话说，在不同PID名字空间的进程可以拥有相同的PID。PID名字空间的一个主要用处在于容器可以在不同宿主机上迁移，但容器里的进程可以保持相同的进程ID。PID 名字空间也允许每个容器有其自己的 init (PID 1)，“所有进程的祖先”--其负责管理各种各样系统初始化任务，以及当进程终止是收割孤儿子进程。

从一个特定PID名字空间实例看，一个进程拥有两个ID：PID名字空间内的进程ID，以及在PID名字空间外即宿主机系统里的进程ID。PID 名字空间可以前套：一个进程可以在从其所在PID名字空间的每一层拥有一个进程ID，直至根PID名字空间。一个进程仅能（通过kill()发送信号）看到自己所属PID名字空间以及该PID名字空间的附属PID名字空间里的进程。

[网络名字空间](https://lwn.net/Articles/219794/) (CLONE_NEWNET, 始于 Linux 2.6.24 大体完成于约 Linux 2.6.29)提供了于网络相关的系统资源的隔离。因此，每个网络名字空间拥有其自己的网络设备，IP地址，IP路由表，/proc/net 目录，端口号，等等。

从联网的视角看，网络名字空间使得容器更有用：每个容器拥有自己的（虚拟）网络设备，并且其应用有独立的端口号空间（per-namespace port number space）；合适的主机系统路由表可直接将网络包导向到与特定容器关联的网络设施。因此，在同一宿主机上拥有多个容器化的Web服务器是可能的，每个Web服务器在其（每个容器的）网络名字空间里绑定到80端口。

[用户名字空间](https://lwn.net/Articles/528078/) (CLONE_NEWUSER, 始于 Linux 2.6.23 完成于 Linux 3.8) 隔离用户与组数字空间。换句话说，一个进程的用户ID和组ID在一个用户名字空间的内部和外部可能是不同的。这里最有趣的事情是：一个进程在一个用户名字空间外拥有一个非特权用户ID，但在该名字空间里其同时有用用户ID 0。这意味着在用户名字空间里该进程有用完全的根用户特权来执行各种操作，但在用户名字空间外它只能执行非特权操作。

从Linux 3.8起，非特权进程可以创建用户名字空间，这为应用带来了一些新的有趣的可能性：既然一个非特权进程在一个用户名字空间里拥有根用户特权，非特权进程现在可以访问一些以前特定于根用户的功能。Eric Biederman 已经付出极大的努力以使得用户名字空间实现安全且正确。但是，这项工作带来的改变是微妙的，影响范围很广。因此，将来可能会有一些用户名字空间的未发现安全问题被报告出来并被解决。
### 总结评论（Concluding remarks）
从第一个Linux名字空间实现开始到现在已经过去了10年。从那时开始，名字空间的概念已经被扩展到一个更通用的框架用来隔离以前是系统范围的一些全局资源。结果，现在名字空间以容器的方式为一个完整的轻量级虚拟化系统提供了基础。由于名字空间的概念已经扩展，相关API也增加了--从一个简单的系统调用（clone()）以及一个到两个/proc文件--到现在包括许多别的系统调用以及更多/proc下的文件。API的细节将在本文的后续文章里讨论。
## Part 2: the namespaces API
一个名字空间将某种全局系统资源包装成某种抽象，使得这些名字空间里的进程看起来拥有这些全局资源的隔离实例。名字空间可用于各种目的，但其最值得注意的一点是实现[容器](https://lwn.net/Articles/524952/)--一个轻量级虚拟化计数，这是关于名字空间实现及其API的系列文章的第二篇。该系列文章的[第一篇](https://lwn.net/Articles/531114/)给出了一个名字空间概览。本篇文章介绍了名字空间API的一些字节，并结合实例介绍了API的使用。

名字空间API包括了三个系统调用--`clone()`, `unshare()`, 和 `setns()`--以及许多/proc文件。在本文中，我们将看到所有这些系统调用及一些/proc文件。为了指定在哪种名字空间类型上操作，3个系统调用使用了上篇文章列出的CLONE_NEW* 常量：CLONE_NEWIPC, CLONE_NEWNS, CLONE_NEWNET, CLONE_NEWPID, CLONE_NEWUSER, 和 CLONE_NEWUTS.
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
- [cgroups(7) — Linux manual page](https://man7.org/linux/man-pages/man7/cgroups.7.html)