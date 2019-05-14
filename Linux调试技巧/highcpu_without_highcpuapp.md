我们知道，系统的 CPU 使用率，不仅包括进程用户态和内核态的运行，还包括中断处理、等待 I/O 以及内核线程等。所以，当你发现系统的 CPU 使用率很高的时候，不一定能找到相对应的高 CPU 使用率的进程。

今天，我就用一个 Nginx + PHP 的 Web 服务的案例，带你来分析这种情况。
＃＃　案例分析
＃＃＃　你的准备
今天依旧探究系统 CPU 使用率高的情况，所以这次实验的准备工作，与上节课的准备工作基本相同，差别在于案例所用的 Docker 镜像不同。

前面我们讲到过，ab（apache bench）是一个常用的HTTP 服务性能测试工具，这里同样用来模拟 Nginx的客户端。由于 Nginx 和 PHP 的配置比较麻烦，我把它们打包成了两个 [Docker 镜像](https://github.com/feiskyer/linux-perf-examples/tree/master/nginx-short-process)，这样只需要运行两个容器，就可以得到模拟环境。

![测试环境部署图](https://static001.geekbang.org/resource/image/90/3d/90c30b4f555218f77241bfe2ac27723d.png)

你可以看到，其中一台用作 Web 服务器，来模拟性能问题；另一台用作 Web 服务器的客户端，来给 Web 服务增加请求。使用两台虚拟机是为了相互隔离，避免“交叉感染”。

接下来，我们打开两个终端，分别 SSH 登录到两台机器上，并安装上述工具。如果你是用普通用户身份登陆系统，请运行 sudo su root 命令切换到 root 用户。

走到这一步，准备工作就完成了。接下来，我们正式进入操作环节。
＃＃＃　操作和分析
首先，我们在第一个终端，执行下面的命令运行 Nginx 和 PHP 应用：
```
docker run --name nginx -p 10000:80 -itd feisky/nginx:sp
$ docker run --name phpfpm -itd --network container:nginx feisky/php-fpm:sp
```
然后，在第二个终端，使用 curl 访问 http://[VM1 的 IP]:10000，确认 Nginx 已正常启动。你应该可以看到 It works! 的响应。
```
# 192.168.0.10 是第一台虚拟机的 IP 地址
$ curl http://192.168.0.10:10000/
It works!
```
接着，我们来测试一下这个 Nginx 服务的性能。在第二个终端运行下面的 ab 命令。要注意，与上次操作不同的是，这次我们需要并发 100 个请求测试 Nginx 性能，总共测试 1000 个请求。
```
# 并发 100 个请求测试 Nginx 性能，总共测试 1000 个请求
$ ab -c 100 -n 1000 http://192.168.0.10:10000/
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, 
...
Requests per second:    87.86 [#/sec] (mean)
Time per request:       1138.229 [ms] (mean)
...
```
从 ab 的输出结果我们可以看到，Nginx 能承受的每秒平均请求数，只有 87 多一点，是不是感觉它的性能有点差呀。那么，到底是哪里出了问题呢？我们再用 top 和 pidstat来观察一下。

这次，我们在第二个终端，将测试的并发请求数改成 5，同时把请求时长设置为 10 分钟（-t 600）。这样，当你在第一个终端使用性能分析工具时， Nginx 的压力还是继续的。
```
ab -c 5 -t 600 http://192.168.0.10:10000/
```

然后，我们在第一个终端运行 top 命令，观察系统的 CPU 使用情况：
```
top
...
%Cpu(s): 80.8 us, 15.1 sy,  0.0 ni,  2.8 id,  0.0 wa,  0.0 hi,  1.3 si,  0.0 st
...

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6882 root      20   0    8456   5052   3884 S   2.7  0.1   0:04.78 docker-containe
 6947 systemd+  20   0   33104   3716   2340 S   2.7  0.0   0:04.92 nginx
 7494 daemon    20   0  336696  15012   7332 S   2.0  0.2   0:03.55 php-fpm
 7495 daemon    20   0  336696  15160   7480 S   2.0  0.2   0:03.55 php-fpm
10547 daemon    20   0  336696  16200   8520 S   2.0  0.2   0:03.13 php-fpm
10155 daemon    20   0  336696  16200   8520 S   1.7  0.2   0:03.12 php-fpm
10552 daemon    20   0  336696  16200   8520 S   1.7  0.2   0:03.12 php-fpm
15006 root      20   0 1168608  66264  37536 S   1.0  0.8   9:39.51 dockerd
 4323 root      20   0       0      0      0 I   0.3  0.0   0:00.87 kworker/u4:1
...
```
观察 top 输出的进程列表可以发现，CPU 使用率最高的进程也只不过才 2.7%，看起来并不高。

然而，再看系统 CPU 使用率（ %Cpu ）这一行，你会发现，系统的整体 CPU 使用率是比较高的：用户 CPU 使用率（us）已经到了 80%，系统 CPU 为 15.1%，而空闲 CPU （id）则只有 2.8%。

为什么用户 CPU 使用率这么高呢？我们再重新分析一下进程列表，看看有没有可疑进程：
- docker-containerd 进程是用来运行容器的，2.7% 的 CPU 使用率看起来正常；
- Nginx 和 php-fpm 是运行 Web 服务的，它们会占用一些 CPU 也不意外，并且 2% 的 CPU 使用率也不算高；
- 再往下看，后面的进程呢，只有 0.3% 的 CPU 使用率，看起来不太像会导致用户 CPU 使用率达到 80%。

那就奇怪了，明明用户 CPU 使用率都 80% 了，可我们挨个分析了一遍进程列表，还是找不到高 CPU 使用率的的进程。看来 top 是不管用了，那还有其他工具可以查看进程 CPU 使用情况吗？试试我们的老朋友 pidstat：
```
# 间隔 1 秒输出一组数据（按 Ctrl+C 结束）
$ pidstat 1
...
04:36:24      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
04:36:25        0      6882    1.00    3.00    0.00    0.00    4.00     0  docker-containe
04:36:25      101      6947    1.00    2.00    0.00    1.00    3.00     1  nginx
04:36:25        1     14834    1.00    1.00    0.00    1.00    2.00     0  php-fpm
04:36:25        1     14835    1.00    1.00    0.00    1.00    2.00     0  php-fpm
04:36:25        1     14845    0.00    2.00    0.00    2.00    2.00     1  php-fpm
04:36:25        1     14855    0.00    1.00    0.00    1.00    1.00     1  php-fpm
04:36:25        1     14857    1.00    2.00    0.00    1.00    3.00     0  php-fpm
04:36:25        0     15006    0.00    1.00    0.00    0.00    1.00     0  dockerd
04:36:25        0     15801    0.00    1.00    0.00    0.00    1.00     1  pidstat
04:36:25        1     17084    1.00    0.00    0.00    2.00    1.00     0  stress
04:36:25        0     31116    0.00    1.00    0.00    0.00    1.00     0  atopacctd
...
```
观察一会儿，你是不是发现，所有进程的 CPU 使用率也都不高啊，最高的 Docker 和 Nginx 也只有4% 和 3%，即使所有进程的 CPU 使用率都加起来，也不过是 21%，离 80% 还差得远呢！

出现这种情况，很可能是因为前面的分析漏了一些关键信息。你可以先暂停一下，自己往上翻，重新操作检查一遍。或者，我们一起返回去分析 top 的输出，看看能不能有新发现。现在，我们回到第一个终端，重新运行 top 命令，并观察一会儿：
```
top
top - 04:58:24 up 14 days, 15:47,  1 user,  load average: 3.39, 3.82, 2.74
Tasks: 149 total,   6 running,  93 sleeping,   0 stopped,   0 zombie
%Cpu(s): 77.7 us, 19.3 sy,  0.0 ni,  2.0 id,  0.0 wa,  0.0 hi,  1.0 si,  0.0 st
KiB Mem :  8169348 total,  2543916 free,   457976 used,  5167456 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  7363908 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6947 systemd+  20   0   33104   3764   2340 S   4.0  0.0   0:32.69 nginx
 6882 root      20   0   12108   8360   3884 S   2.0  0.1   0:31.40 docker-containe
15465 daemon    20   0  336696  15256   7576 S   2.0  0.2   0:00.62 php-fpm
15466 daemon    20   0  336696  15196   7516 S   2.0  0.2   0:00.62 php-fpm
15489 daemon    20   0  336696  16200   8520 S   2.0  0.2   0:00.62 php-fpm
 6948 systemd+  20   0   33104   3764   2340 S   1.0  0.0   0:00.95 nginx
15006 root      20   0 1168608  65632  37536 S   1.0  0.8   9:51.09 dockerd
15476 daemon    20   0  336696  16200   8520 S   1.0  0.2   0:00.61 php-fpm
15477 daemon    20   0  336696  16200   8520 S   1.0  0.2   0:00.61 php-fpm
24340 daemon    20   0    8184   1616    536 R   1.0  0.0   0:00.01 stress
24342 daemon    20   0    8196   1580    492 R   1.0  0.0   0:00.01 stress
24344 daemon    20   0    8188   1056    492 R   1.0  0.0   0:00.01 stress
24347 daemon    20   0    8184   1356    540 R   1.0  0.0   0:00.01 stress
...
```
这次从头开始看 top 的每行输出，咦？Tasks 这一行看起来有点奇怪，就绪队列中居然有 6 个Running 状态的进程（6 running），是不是有点多呢？

再仔细看进程列表，这次主要看 Running（R） 状态的进程。你有没有发现，Nginx 和所有的 php-fpm 都处于Sleep（S）状态，而真正处于 Running（R）状态的，却是几个 stress 进程。这几个 stress 进程就比较奇怪了，需要我们做进一步的分析。

我们还是使用 pidstat 来分析这几个进程，并且使用-p 选项指定进程的 PID。首先，从上面 top 的结果中，找到这几个进程的 PID。比如，先随便找一个 24344，然后用 pidstat 命令看一下它的 CPU 使用情况：
```
pidstat -p 24344

16:14:55      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
```
奇怪，居然没有任何输出。难道是 pidstat 命令出问题了吗？在怀疑性能工具出问题前，最好还是先用其他工具交叉确认一下。那用什么工具呢？ ps 应该是最简单易用的。
```
# 从所有进程中查找 PID 是 24344 的进程
$ ps aux | grep 24344
root      9628  0.0  0.0  14856  1096 pts/0    S+   16:15   0:00 grep --color=auto 24344
```
还是没有输出。现在终于发现问题，原来这个进程已经不存在了，所以 pidstat 就没有任何输出。我们再用 top 命令确认一下：
```
top
...
%Cpu(s): 80.9 us, 14.9 sy,  0.0 ni,  2.8 id,  0.0 wa,  0.0 hi,  1.3 si,  0.0 st
...

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6882 root      20   0   12108   8360   3884 S   2.7  0.1   0:45.63 docker-containe
 6947 systemd+  20   0   33104   3764   2340 R   2.7  0.0   0:47.79 nginx
 3865 daemon    20   0  336696  15056   7376 S   2.0  0.2   0:00.15 php-fpm
  6779 daemon    20   0    8184   1112    556 R   0.3  0.0   0:00.01 stress
...
```
好像又错了。结果还跟原来一样，用户 CPU 使用率还是高达80.9%，系统 CPU 接近 15%，而空闲 CPU 只有 2.8%，Running 状态的进程有 Nginx、stress 等。

可是，刚刚我们看到 stress 进程不存在了，怎么现在还在运行呢？再细看一下 top 的输出，原来，这次 stress 进程的 PID 跟前面不一样了，原来的 PID 24344 不见了，现在的是 6779。

进程的 PID 在变，说明要么是这些进程在不停地重启，要么就是全新的进程，这无非也就两个原因：
- 第一个原因，进程在不停地崩溃重启，比如因为段错误、配置错误等等，这时，进程在退出后可能又被监控系统自动重启了。
- 第二个原因，这些进程都是短时进程，也就是在其他应用内部通过 exec 调用的外面命令。这些命令一般都只运行很短的时间就会结束，你很难用 top 这种间隔时间比较长的工具发现（上面的案例，我们碰巧发现了）。

至于 stress，我们前面提到过，它是一个常用的压力测试工具。它的 PID 在不断变化中，看起来像是被其他进程调用的短时进程。要想继续分析下去，还得找到它们的父进程。

要怎么查找一个进程的父进程呢？没错，用 pstree 就可以用树状形式显示所有进程之间的关系：
```
pstree | grep stress
        |-docker-containe-+-php-fpm-+-php-fpm---sh---stress
        |         |-3*[php-fpm---sh---stress---stress]
```
从这里可以看到，stress 是被 php-fpm 调用的子进程，并且进程数量不止一个（这里是 3 个）。找到父进程后，我们能进入 app 的内部分析了。

### execsnoop
[execsnoop](https://github.com/brendangregg/perf-tools/blob/master/execsnoop)是一个专为短时进程设计的工具。它通过 ftrace 实时监控进程的 exec() 行为，并输出短时进程的基本信息，包括进程 PID、父进程 PID、命令行参数以及执行的结果。

比如，用 execsnoop 监控上述案例，就可以直接得到 stress 进程的父进程 PID 以及它的命令行参数，并可以发现大量的 stress 进程在不停启动：
```
# 按 Ctrl+C 结束
$ execsnoop
PCOMM            PID    PPID   RET ARGS
sh               30394  30393    0
stress           30396  30394    0 /usr/local/bin/stress -t 1 -d 1
sh               30398  30393    0
stress           30399  30398    0 /usr/local/bin/stress -t 1 -d 1
sh               30402  30400    0
stress           30403  30402    0 /usr/local/bin/stress -t 1 -d 1
sh               30405  30393    0
stress           30407  30405    0 /usr/local/bin/stress -t 1 -d 1
...
```
execsnoop 所用的 ftrace 是一种常用的动态追踪技术，一般用于分析 Linux 内核的运行时行为。

## 小结
碰到常规问题无法解释的 CPU 使用率情况时，首先要想到有可能是短时应用导致的问题，比如有可能是下面这两种情况。
- 应用里直接调用了其他二进制程序，这些程序通常运行时间比较短，通过 top 等工具也不容易发现。
- 应用本身在不停地崩溃重启，而启动过程的资源初始化，很可能会占用相当多的 CPU。

对于这类进程，我们可以用 pstree 或者 execsnoop 找到它们的父进程，再从父进程所在的应用入手，排查问题的根源。
