# Namespaces in operation
> By Michael Kerrisk January 4, 2013
## part 1: namespaces overview
从Linux 3.8的合并窗口可以看到Eric Biederman数量可观的系列[用户名字空间及相关补丁](https://lwn.net/Articles/528078/)。虽然还留有一些细节待完成--例如许多Linux 文件系统不是用户名字空间感知的--用户名字空间的功能实现尚未完全结束。

基于许多原因，用户名字空间工作的完成可从某种意义上视为一个里程碑。首先，这项工作代表了迄今为止最复杂的名字空间实现之一的完成，且被从用户名字空间实现的第一步（Linux 2.6.23）以来的近五年的工作所见证。其次，名字空间的工作最近达到了某个“稳定点”，其中大部分存在的名字空间实现已经完成。这并不意味着名字空间的工作已经结束：将来有可能加入其它的名字空间，已有的名字空间将来也有可能被扩展，例如[内核日志的名字空间隔离](https://lwn.net/Articles/527342/)的加入。最好，最近的用户名字空间实现的变化改变了游戏规则--它改变了名字空间的使用方式：从Linux 3.8 开始，非特权进程可以创建用户名字空间，且在其中它们拥有完全权限。它接下来可允许其它类型名字空间在用户名字空间被创建。

因此，当前节点可被视为一个很好的点来纵览名字空间，并以实际的观点检视名字空间API。本文是系列文章的第一篇：在本文中，我们提供了当前可用名字空间的一个概览；在接下来的文章中，我们将展示如何在程序中使用名字空间API。
### 1.1 名字空间（家族）
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
### 1.2 总结评论（Concluding remarks）
从第一个Linux名字空间实现开始到现在已经过去了10年。从那时开始，名字空间的概念已经被扩展到一个更通用的框架用来隔离以前是系统范围的一些全局资源。结果，现在名字空间以容器的方式为一个完整的轻量级虚拟化系统提供了基础。由于名字空间的概念已经扩展，相关API也增加了--从一个简单的系统调用（clone()）以及一个到两个/proc文件--到现在包括许多别的系统调用以及更多/proc下的文件。API的细节将在本文的后续文章里讨论。
## Part 2: the namespaces API
一个名字空间将某种全局系统资源包装成某种抽象，使得这些名字空间里的进程看起来拥有这些全局资源的隔离实例。名字空间可用于各种目的，但其最值得注意的一点是实现[容器](https://lwn.net/Articles/524952/)--一个轻量级虚拟化计数，这是关于名字空间实现及其API的系列文章的第二篇。该系列文章的[第一篇](https://lwn.net/Articles/531114/)给出了一个名字空间概览。本篇文章介绍了名字空间API的一些字节，并结合实例介绍了API的使用。

名字空间API包括了三个系统调用--`clone()`, `unshare()`, 和 `setns()`--以及许多/proc文件。在本文中，我们将看到所有这些系统调用及一些/proc文件。为了指定在哪种名字空间类型上操作，3个系统调用使用了上篇文章列出的CLONE_NEW* 常量：CLONE_NEWIPC, CLONE_NEWNS, CLONE_NEWNET, CLONE_NEWPID, CLONE_NEWUSER, 和 CLONE_NEWUTS.
### 2.1 在新的名字空间创建子进程： clone()
创建名字空间的一种方法是借助 [clone()](http://man7.org/linux/man-pages/man2/clone.2.html)，一个创建新进程的系统调用。针对我们的目的，clone()拥有下面的原型：
```
int clone(int (*child_func)(void *), void *child_stack, int flags, void *arg);
```
本质上，`clone()` 是传统UNIX `fork()` 系统调用的一个更通用的版本，它的功能可以通过 flags 参数来控制。总之，越有超过20个的不同的 `CLONE_*` 标记来控制 clone() 操作的各个方面，包括父进程与子进程是否共享资源如虚拟内存，打开文件描述符，信号量处理等。如果一个 `CLONE_NEW*` 位在调用中指定，那么一个对应类型的新的名字空间将被创建，新进程将成为该名字空间的一个成员。`flags` 参数可以指定多个 `CLONE_NEW*` 标记位。

我们的示例应用（demo_uts_namespace.c）使用 clone() 并传递一个 CLONE_NEWUTS 以创建一个 UTS 名字空间。正如我们上个星期所见，UTS 名字空间隔离两个系统标识符--主机名和NIS域名--它们由 `sethostname()` 和 `setdomainname()` 系统调用设置，并由 `uname()` 系统调用返回。你可以在[这里](https://lwn.net/Articles/531245/)找到完整的源代码。下面，我们将关注应用的关键部分（为了简单，我们会跳过错误处理代码，它们在现在的完整版本代码中是存在的）。

示例应用需要一个命令行参数。当运行时，它创建一个子进程在一个新的 `UTS` 名字空间里运行。在该名字空间里，子进程将主机名更改为命令行参数传递进来的值。

主程序最重要的部分是调用clone()以创建子进程：
```
child_pid = clone(childFunc, 
    child_stack + STACK_SIZE,   /* Points to start of downwardly growing stack */ 
    CLONE_NEWUTS | SIGCHLD, argv[1]);

printf("PID of child created by clone() is %ld\n", (long) child_pid);
```
新的子进程将唉用户定义函数childFunc()中开始其执行，该函数将接受最终的 clone() 参数（argv[1]）作为其参数。因为 `CLONE_NEWUTS` 作为flags参数的一部分被指定，子进程静载一个新创建的UTS 名字空间里开始执行。

主进程然后睡眠一会儿，这是一个给予子进程时机在其名字空间更改其主机名（粗暴的）方式。然后程序在父进程的 UTS 名字空间检索主机名并显示它：
```
sleep(1);           /* Give child time to change its hostname */

uname(&uts);
printf("uts.nodename in parent: %s\n", uts.nodename);
```
同时，由clone()创建的子进程开始执行 childFunc() 函数，它首先改变主机名为提供给它的参数，然后检索并答应修改后的主机名：
```
sethostname(arg, strlen(arg);
    
uname(&uts);
printf("uts.nodename in child:  %s\n", uts.nodename);
```
在结束前，子进程睡眠了一会儿，这拥有让子进程的UTS名字空间保持开放的效果；这给了我们进行后面将显示的一些实验的机会。

运行该实例应用将展示父进程和子进程拥有独立的 UTS 名字空间：
```
$ su                   # Need privilege to create a UTS namespace
Password: 
# uname -n
antero
# ./demo_uts_namespaces bizarro
PID of child created by clone() is 27514
uts.nodename in child:  bizarro
uts.nodename in parent: antero
```
和其它大多数名字空间一样（用户名字空间除外），创建 UTS 名字空间需要特权（尤其是CAP_SYS_ADMIN）。这对于防止某些场景是必须的：set-user-ID应用可能呗糊弄以做出错误的事情，因为系统有一个不期待的主机名。

另一个可能性是set-user-ID应用可能使用主机名作为文件锁名字的一部分。如果一个非特权用户可以在一个UTS名字空间中以任意主机名运行应用，这将使得该应用对各种攻击开放。最简单的，这将使得文件锁无效，从而触发运行在不同 UTS 名字空间的应用行为异常。另外，一个不怀好意的用户可能在一个带有特定主机名的 UTS 名字空间运行set-user-ID应用创建锁文件而覆盖重要文件（主机名可以包含任意字符，甚至斜杠）。
### 2.2 /proc/PID/ns 文件
每个进程都拥有一个 `/proc/PID/ns` 目录，其下每个名字空间有一个对应文件。从Linux 3.8开始，每个文件是一个特殊的符号链接，它提供了对一个进程的名字空间执行相关操作的句柄（handler）:
```
$ ls -l /proc/$$/ns         # $$ is replaced by shell's PID
wangbb@c005mkkbjde03:~> ls -l /proc/15112/ns
total 0
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 ipc -> ipc:[4026531839]
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 mnt -> mnt:[4026531840]
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 net -> net:[4026531956]
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 pid -> pid:[4026531836]
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 user -> user:[4026531837]
lrwxrwxrwx. 1 wangbb wangbb 0 Dec 20 12:23 uts -> uts:[4026531838]
```
这些符号链接的一个用途是发现两个进程是否在同一名字空间。内核做了一些魔法可以确保如果两个进程在同一名字空间，在`/proc/PID/ns`下的符号链接文件的inode号是一样的。inode号可以通过系统调用 [stat()](http://man7.org/linux/man-pages/man2/stat.2.html)（在返回结构体的st_ino成员里）。

但是，内核也在`/proc/PID/ns`构造了每一个符号链接，并且其名字包含可用于识别名字空间类型的字符串，其后跟随有inode号。我们可以使用 `ls -l` 或`readlink`命令来检查这个名字。让我们回到上次我们运行`demo_uts_namespaces`的shell会话，查看父进程和子进程在/proc/PID/ns下的符号链接提供了检测两个进程是否在同一个UTS名字空间的方法。
```
^Z                                # Stop parent and child
[1]+  Stopped          ./demo_uts_namespaces bizarro
# jobs -l                         # Show PID of parent process
[1]+ 27513 Stopped         ./demo_uts_namespaces bizarro
# readlink /proc/27513/ns/uts     # Show parent UTS namespace
uts:[4026531838]
# readlink /proc/27514/ns/uts     # Show child UTS namespace
uts:[4026532338]
```
正如你看到的，/proc/PID/ns/uts 符号链接的内容是不同的，指示两个进程位于不同的 UTS名字空间里。

/proc/PID/ns 符号链接也用于其它目的。如果我们打开其中任一文件，名字空间将保持打开，只要文件描述符把持打开，甚至名字空间里的所有进程都已经终止。通过挂载符号链接中的一个到文件系统的其它位置可以取得同样的效果。
```
# touch ~/uts                            # Create mount point
# mount --bind /proc/27514/ns/uts ~/uts
```
在Linux 3.8之前，/proc/PID/ns下的文件是硬链接而非上文描述的特殊符号链接形式。此外，只有ipc, net 和 uts 存在。
### 2.3 假如一个已有名字空间：setns()
### 2.4 脱离一个名字空间：unshare()
### 2.5 总结评论（Concluding remarks）
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
- [clone() system call](https://man7.org/linux/man-pages/man2/clone.2.html)