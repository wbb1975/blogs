# CPU性能问题答疑
## 问题 1：性能工具版本太低，导致指标不全
这是使用 CentOS 的同学普遍碰到的问题。在文章中，我的 pidstat 输出里有一个 %wait 指标，代表进程等待 CPU 的时间百分比，这是 systat 11.5.5 版本才引入的新指标，旧版本没有这一项。而 CentOS 软件库里的 sysstat 版本刚好比这个低，所以没有这项指标。

不过，你也不用担心。前面我就强调过，工具只是查找分析的手段，指标才是我们重点分析的对象。如果你的 pidstat 里没有显示，自然还有其他手段能找到这个指标。

比如说，在讲解系统原理和性能工具时，我一般会介绍一些 proc 文件系统的知识，教你看懂 proc 文件系统提供的各项指标。之所以这么做，一方面，当然是为了让你更直观地理解系统的工作原理；另一方面，其实是想给你展示，性能工具上能看到的各项性能指标的原始数据来源。

这样，在实际生产环境中，即使你很可能需要运行老版本的操作系统，还没有权限安装新的软件包，你也可以查看proc 文件系统，获取自己想要的指标。

但是，性能分析的学习，我还是建议你要用最新的性能工具来学。新工具有更全面的指标，让你更容易上手分析。这个绝对的优势，可以让你更直观地得到想要的数据，也不容易让你打退堂鼓。

当然，初学时，你最好试着去理解性能工具的原理，或者熟悉了使用方法后，再回过头重新学习原理。这样，即使是在无法安装新工具的环境中，你仍然可以从 proc 文件系统或者其他地方，获得同样的指标，进行有效的分析。
## 问题 2：使用 stress 命令，无法模拟 iowait 高的场景
使用 stress 无法模拟 iowait 升高，但是却看到了 sys 升高。这是因为案例中 的 stress -i 参数，它表示通过系统调用 sync()来模拟 I/O 的问题，但这种方法实际上并不可靠。

因为 sync() 的本意是刷新内存缓冲区的数据到磁盘中，以确保同步。如果缓冲区内本来就没多少数据，那读写到磁盘中的数据也就不多，也就没法产生 I/O 压力。

这一点，在使用 SSD 磁盘的环境中尤为明显，很可能你的 iowait 总是 0，却单纯因为大量的系统调用，导致了系统 CPU 使用率 sys 升高。

这种情况，我在留言中也回复过，推荐使用 stress-ng来代替 stress。担心你没有看到留言，所以这里我再强调一遍。你可以运行下面的命令，来模拟 iowait 的问题。
```
# -i 的含义还是调用 sync，而—hdd 则表示读写临时文件
$ stress-ng -i 1 --hdd 1 --timeout 600
```
## 问题 3：无法模拟出 RES 中断的问题
这个问题是说，即使运行了大量的线程，也无法模拟出重调度中断RES 升高的问题。

其实我在 CPU 上下文切换的案例中已经提到，重调度中断是调度器用来分散任务到不同 CPU 的机制，也就是可以唤醒空闲状态的 CPU ，来调度新任务运行，而这通常借助处理器间中断（Inter-Processor Interrupts，IPI）来实现。

所以，这个中断在单核（只有一个逻辑 CPU）的机器上当然就没有意义了，因为压根儿就不会发生重调度的情况。

不过，正如留言所说，上下文切换的问题依然存在，所以你会看到， cs（context switch）从几百增加到十几万，同时 sysbench 线程的自愿上下文切换和非自愿上下文切换也都会大幅上升，特别是非自愿上下文切换，会上升到十几万。根据非自愿上下文的含义，我们都知道，这是过多的线程在争抢 CPU。

其实这个结论也可以从另一个角度获得。比如，你可以在 pidstat 的选项中，加入 -u 和 -t 参数，输出线程的 CPU 使用情况，你会看到下面的界面：
```
pidstat -u -t 1

14:24:03      UID      TGID       TID    %usr %system  %guest   %wait    %CPU   CPU  Command
14:24:04        0         -      2472    0.99    8.91    0.00   77.23    9.90     0  |__sysbench
14:24:04        0         -      2473    0.99    8.91    0.00   68.32    9.90     0  |__sysbench
14:24:04        0         -      2474    0.99    7.92    0.00   75.25    8.91     0  |__sysbench
14:24:04        0         -      2475    2.97    6.93    0.00   70.30    9.90     0  |__sysbench
14:24:04        0         -      2476    2.97    6.93    0.00   68.32    9.90     0  |__sysbench
...
```
从这个 pidstat 的输出界面，你可以发现，每个 stress 线程的 %wait 高达 70%，而 CPU使用率只有不到 10%。换句话说，stress 线程大部分时间都消耗在了等待 CPU 上，这也表明，确实是过多的线程在争抢 CPU。

在这里顺便提一下，留言中很常见的一个错误。有些同学会拿 pidstat 中的 %wait 跟 top 中的 iowait% （缩写为 wa）对比，其实这是没有意义的，因为它们是完全不相关的两个指标。
+ pidstat 中， %wait 表示进程等待 CPU 的时间百分比。
+ top 中 ，iowait% 则表示等待 I/O 的 CPU 时间百分比。

回忆一下我们学过的进程状态，你应该记得，等待 CPU 的进程已经在 CPU 的就绪队列中，处于运行状态；而等待 I/O 的进程则处于不可中断状态。

另外，不同版本的 sysbench 运行参数也不是完全一样的的。比如，在案例 Ubuntu 18.04 中，运行 sysbench 的格式为：

```sysbench --threads=10 --max-time=300 threads run```

而在 Ubuntu 16.04 中，运行格式则为（感谢 Haku 留言分享的执行命令）：

```sysbench --num-threads=10 --max-time=300 --test=threads run```

## 问题 4：无法模拟出 I/O 性能瓶颈，以及 I/O 压力过大的问题
这个问题可以看成是上一个问题的延伸，只是把 stress 命令换成了一个在容器中运行的 app应用。

事实上，在 I/O 瓶颈案例中，除了上面这个模拟不成功的留言，还有更多留言的内容刚好相反，说的是案例 I/O 压力过大，导致自己的机器出各种问题，甚至连系统都没响应了。

之所以这样，其实还是因为每个人的机器配置不同，既包括了 CPU 和内存配置的不同，更是因为磁盘的巨大差异。比如，机械磁盘（HDD）、低端固态磁盘（SSD）与高端固态磁盘相比，性能差异可能达到数倍到数十倍。

其实，我自己所用的案例机器也只是低端的 SSD，比机械磁盘稍微好一些，但跟高端固态磁盘还是比不了的。所以，相同操作下，我的机器上刚好出现 I/O 瓶颈，但换成一台使用机械磁盘的机器，可能磁盘 I/O 就被压死了（表现为使用率长时间 100%），而换上好一些的 SSD 磁盘，可能又无法产生足够的 I/O 压力。

所以，在最新的案例中，我为 app 应用增加了三个选项。
+ -d 设置要读取的磁盘，默认前缀为 /dev/sd 或者 /dev/xvd 的磁盘。
+ -s 设置每次读取的数据量大小，单位为字节，默认为 67108864（也就是 64MB）。
+ -c 设置每个子进程读取的次数，默认为 20 次，也就是说，读取 20*64MB 数据后，子进程退出。

你可以点击 [Github](https://github.com/feiskyer/linux-perf-examples/tree/master/high-iowait-process) 查看它的源码，使用方法我写在了这里：

```docker run --privileged --name=app -itd feisky/app:iowait /app -d /dev/sdb -s 67108864 -c 20```

案例运行后，你可以执行 docker logs 查看它的日志。正常情况下，你可以看到下面的输出：
```
docker logs app
Reading data from disk /dev/sdb with buffer size 67108864 and count 20
```
## 问题 5：性能工具（如 vmstat）输出中，第一行数据跟其他行差别巨大
这个问题主要是说，在执行 vmstat 时，第一行数据跟其他行相比较，数值相差特别大。我相信不少同学都注意到了这个现象，这里我简单解释一下。

首先还是要记住，我总强调的那句话，**在碰到直观上解释不了的现象时，要第一时间去查命令手册**。

比如，运行 man vmstat 命令，你可以在手册中发现下面这句话：
```
The first report produced gives averages since the last reboot.  Additional reports give information on a sam‐ 
pling period of length delay.  The process and memory reports are instantaneous in either case. 
```
也就是说，第一行数据是系统启动以来的平均值，其他行才是你在运行 vmstat 命令时，设置的间隔时间的平均值。另外，进程和内存的报告内容都是即时数值。

你看，这并不是什么不得了的事故，但如果我们不清楚这一点，很可能卡住我们的思维，阻止我们进一步的分析。这里我也不得不提一下，文档的重要作用。

授之以鱼，不如授之以渔。我们专栏的学习核心，一定是教会你性能分析的原理和思路，性能工具只是我们的路径和和手段。所以，在提到各种性能工具时，我并没有详细解释每个工具的各种命令行选项的作用，一方面是因为你很容易通过文档查到这些，另一方面就是不同版本、不同系统中，个别选项的含义可能并不相同。

所以，不管因为哪个因素，自己 man 一下，一定是最快速并且最准确的方式。特别是，当你发现某些工具的输出不符合常识时，一定记住，第一时间查文档弄明白。实在读不懂文档的话，再上网去搜，或者在专栏里向我提问。

学习是一个“从薄到厚再变薄”的过程，我们从细节知识入手开始学习，积累到一定程度，需要整理成一个体系来记忆，这其中还要不断地对这个体系进行细节修补。有疑问、有反思才可以达到最佳的学习效果。
## 问题 6： 使用 perf 工具时，看到的是 16 进制地址而不是函数名
这是留言比较多的一个问题，在 CentOS 系统中，使用perf 工具看不到函数名，只能看到一些 16 进制格式的函数地址。

其实，只要你观察一下 perf 界面最下面的那一行，就会发现一个警告信息：

```Failed to open /opt/bitnami/php/lib/php/extensions/opcache.so, continuing without symbols```

这说明，perf 找不到待分析进程依赖的库。当然，实际上这个案例中有很多依赖库都找不到，只不过，perf 工具本身只在最后一行显示警告信息，所以你只能看到这这一条警告。

这个问题，其实也是在分析 Docker 容器应用时，我们经常碰到的一个问题，因为容器应用依赖的库都在镜像里面。

针对这种情况，我总结了下面四个解决方法。
+ 第一个方法，在容器外面构建相同路径的依赖库。这种方法从原理上可行，但是我并不推荐，一方面是因为找出这些依赖库比较麻烦，更重要的是，构建这些路径，会污染容器主机的环境。
+ 第二个方法，在容器内部运行 perf。不过，这需要容器运行在特权模式下，但实际的应用程序往往只以普通容器的方式运行。所以，容器内部一般没有权限执行 perf 分析。
  
  比方说，如果你在普通容器内部运行 perf record，你将会看到下面这个错误提示：
  ```
  perf_4.9 record -a -g
  perf_event_open(..., PERF_FLAG_FD_CLOEXEC) failed with unexpected error 1 (Operation not permitted)
  perf_event_open(..., 0) failed unexpectedly with error 1 (Operation not permitted)
  ```
  当然，其实你还可以通过配置 /proc/sys/kernel/perf_event_paranoid （比如改成 -1）来允许非特权用户执行 perf 事件分析。
  
  不过还是那句话，为了安全起见，这种方法我也不推荐。
+ 第三个方法，指定符号路径为容器文件系统的路径。比如对于第 05 讲的应用，你可以执行下面这个命令：
    ```
    mkdir /tmp/foo
    $ PID=$(docker inspect --format {{.State.Pid}} phpfpm)
    $ bindfs /proc/$PID/root /tmp/foo
    $ perf report --symfs /tmp/foo

    # 使用完成后不要忘记解除绑定
    $ umount /tmp/foo/
    ```
   不过这里要注意，bindfs 这个工具需要你额外安装。bindfs 的基本功能是实现目录绑定（类似于 mount--bind），这里需要你安装的是 1.13.10 版本（这也是它的最新发布版）。
+ 第四个方法，在容器外面把分析纪录保存下来，再去容器里查看结果。这样，库和符号的路径也就都对了。
比如，你可以这么做。先运行 perf record -g -p < pid>，执行一会儿（比如 15 秒）后，按 Ctrl+C 停止。

然后，把生成的 perf.data 文件，拷贝到容器里面来分析：
```
docker cp perf.data phpfpm:/tmp 
$ docker exec -i -t phpfpm bash
```
接下来，在容器的 bash 中继续运行下面的命令，安装 perf 并使用 perf report 查看报告：
```
cd /tmp/ 
$ apt-get update && apt-get install -y linux-tools linux-perf procps
$ perf_4.9 report
```
不过，这里也有两点需要你注意。
首先是 perf 工具的版本问题。在最后一步中，我们运行的工具是容器内部安装的版本 perf_4.9，而不是普通的 perf 命令。这是因为，perf 命令实际上是一个软连接，会跟内核的版本进行匹配，但镜像里安装的 perf 版本跟虚拟机的内核版本有可能并不一...

另外，php-fpm 镜像是基于 Debian 系统的，所以安装 perf 工具的命令，跟 Ubuntu 也并不完全一样。比如， Ubuntu 上的安装方法是下面这样：
```
apt-get install -y linux-tools-common linux-tools-generic linux-tools-$(uname -r)）
```
而在 php-fpm 容器里，你应该执行下面的命令来安装 perf：
```
apt-get install -y linux-perf
```

事实上，抛开我们的案例来说，即使是在非容器化的应用中，你也可能会碰到这个问题。假如你的应用程序在编译时，使用 strip 删除了 ELF 二进制文件的符号表，那么你同样也只能看到函数的地址。

现在的磁盘空间，其实已经足够大了。保留这些符号，虽然会导致编译后的文件变大，但对整个磁盘空间来说已经不是什么大问题。所以为了调试的方便，建议你还是把它们保留着。
## 问题 7：如何用 perf 工具分析 Java 程序
这两个问题，其实是上一个 perf 问题的延伸。像是 Java 这种通过 JVM 来运行的应用程序，运行堆栈用的都是 JVM 内置的函数和堆栈管理。所以，从系统层面你只能看到 JVM 的函数堆栈，而不能直接得到Java 应用程序的堆栈。

perf_events 实际上已经支持了 JIT，但还需要一个 /tmp/perf-PID.map 文件，来进行符号翻译。当然，开源项目 [perf-map-agent](https://github.com/jvm-profiling-tools/perf-map-agent) 可以帮你生成这个符号表。

此外，为了生成全部调用栈，你还需要开启 JDK 的选项 -XX:+PreserveFramePointer。因为这里涉及到大量的 Java 知识，我就不再详细展开了。如果你的应用刚好基于 Java ，那么你可以参考 NETFLIX 的技术博客 [Java in Flames](https://medium.com/netflix-techblog/java-in-flames-e763b3d32166)，来查看详细的使用步骤。

说到这里，我也想强调一个问题，那就是学习性能优化时，不要一开始就把自己限定在具体的某个编程语言或者性能工具中，纠结于语言或工具的细节出不来。

掌握整体的分析思路，才是我们首先要做的。因为，性能优化的原理和思路，在任何编程语言中都是相通的。
## 问题 8：为什么 perf 的报告中，很多符号都不显示调用栈
perf report 是一个可视化展示 perf.data的工具。在第 08 讲的案例中，我直接给出了最终结果，并没有详细介绍它的参数。估计很多同学的机器在运行时，都碰到了跟路过同学一样的问题，看到的是下面这个界面。

  ![Perf Report Without Detailed Callstack](https://github.com/wbb1975/blogs/blob/master/Linux_Tune_Tips/images/perf_report_without_detailed_callstack.png)

这个界面可以清楚看到，perf report 的输出中，只有 swapper 显示了调用栈，其他所有符号都不能查看堆栈情况，包括我们案例中的 app 应用。

这种情况我们以前也遇到过，当你发现性能工具的输出无法理解时，应该怎么办呢？当然还是查工具的手册。比如，你可以执行 man perf-report 命令，找到 -g参数的说明：
```
-g, --call-graph=<print_type,threshold[,print_limit],order,sort_key[,branch],value> 
           Display call chains using type, min percent threshold, print limit, call order, sort key, optional branch and value. Note that 
           ordering is not fixed so any parameter can be given in an arbitrary order. One exception is the print_limit which should be 
           preceded by threshold. 

               print_type can be either: 
               - flat: single column, linear exposure of call chains. 
               - graph: use a graph tree, displaying absolute overhead rates. (default) 
               - fractal: like graph, but displays relative rates. Each branch of 
                        the tree is considered as a new profiled object. 
               - folded: call chains are displayed in a line, separated by semicolons 
               - none: disable call chain display. 

               threshold is a percentage value which specifies a minimum percent to be 
               included in the output call graph.  Default is 0.5 (%). 

               print_limit is only applied when stdio interface is used.  It's to limit 
               number of call graph entries in a single hist entry.  Note that it needs 
               to be given after threshold (but not necessarily consecutive). 
               Default is 0 (unlimited). 

               order can be either: 
               - callee: callee based call graph. 
               - caller: inverted caller based call graph. 
               Default is 'caller' when --children is used, otherwise 'callee'. 

               sort_key can be: 
               - function: compare on functions (default) 
               - address: compare on individual code addresses 
               - srcline: compare on source filename and line number 

               branch can be: 
               - branch: include last branch information in callgraph when available. 
                         Usually more convenient to use --branch-history for this. 

               value can be: 
               - percent: diplay overhead percent (default) 
               - period: display event period 
               - count: display event count
```
通过这个说明可以看到，-g 选项等同于 --call-graph，它的参数是后面那些被逗号隔开的选项，意思分别是输出类型、最小阈值、输出限制、排序方法、排序关键词、分支以及值的类型。

我们可以看到，这里默认的参数是 graph,0.5,call,function,percent，具体含义文档中都有详细讲解，这里我就不再重复了。

现在再回过头来看我们的问题，堆栈显示不全，相关的参数当然就是最小阈值 threshold。通过手册中对threshold 的说明，我们知道，当一个事件发生比例高于这个阈值时，它的调用栈才会显示出来。

threshold 的默认值为 0.5%，也就是说，事件比例超过 0.5% 时，调用栈才能被显示。再观察我们案例应用 app 的事件比例，只有 0.34%，低于 0.5%，所以看不到 app 的调用栈就很正常了。

这种情况下，你只需要给 perf report 设置一个小于0.34% 的阈值，就可以显示我们想看到的调用图了。比如执行下面的命令：

```perf report -g graph,0.3```

你就可以得到下面这个新的输出界面，展开 app 后，就可以看到它的调用栈了。

  ![Perf Report Without Detailed Callstack](https://github.com/wbb1975/blogs/blob/master/Linux_Tune_Tips/images/perf_report_with_detailed_callstack.png)
## 问题 9：怎么理解 perf report 报告
看到 swapper，你可能首先想到的是 SWAP 分区。实际上， swapper 跟 SWAP 没有任何关系，它只在系统初始化时创建 init 进程，之后，它就成了一个最低优先级的空闲任务。也就是说，当 CPU 上没有其他任务运行时，就会执行 swapper 。所以，你可以称它为“空闲任务“。

回到我们的问题，在 perf report 的界面中，展开它的调用栈，你会看到， swapper 时钟事件都耗费在了 do_idle 上，也就是在执行空闲任务。

  ![Perf Report Without Detailed Callstack](https://github.com/wbb1975/blogs/blob/master/Linux_Tune_Tips/images/perf_report_for_swapper.png)

所以，分析案例时，我们直接忽略了前面这个 99% 的符号，转而分析后面只有 0.3% 的 app。其实从这里你也能理解，为什么我们一开始不先用 perf 分析。

因为在多任务系统中，次数多的事件，不一定就是性能瓶颈。所以，只观察到一个大数值，并不能说明什么问题。具体有没有瓶颈，还需要你观测多个方面的多个指标，来交叉验证。这也是我在套路篇中不断强调的一点。

另外，关于 Children 和 Self 的含义，手册里其实有详细说明，还很友好地举了一个例子，来说明它们的百分比的计算方法。简单来说，
- Self 是最后一列的符号（可以理解为函数）本身所占比例；
- Children 是这个符号调用的其他符号（可以理解为子函数，包括直接和间接调用）占用的比例之和。

正如同学留言问到的，很多性能工具确实会对系统性能有一定影响。就拿 perf 来说，它需要在内核中跟踪内核栈的各种事件，那么不可避免就会带来一定的性能损失。这一点，虽然对大部分应用来说，没有太大影响，但对特定的某些应用（比如那些对时钟周期特别敏感的应用），可能就是灾难了。

所以，使用性能工具时，确实应该考虑工具本身对系统性能的影响。而这种情况，就需要你了解这些工具的原理。比如，
- perf 这种动态追踪工具，会给系统带来一定的性能损失。
- vmstat、pidstat 这些直接读取 proc 文件系统来获取指标的工具，不会带来性能损失。
## 问题 10：性能优化书籍和参考资料推荐
在 如何学习 Linux 性能优化 的文章中，我曾经介绍过Brendan Gregg，他是当之无愧的性能优化大师，你在各种 Linux 性能优化的文章中，基本都能看到他的那张性能工具图谱。

所以，关于性能优化的书籍，我最喜欢的其实正是他写的那本《Systems Performance: Enterprise and the Cloud》。这本书也出了中文版，名字是《性能之巅：洞悉系统、企业与云计算》。

从出版时间来看，这本书确实算一本老书了，英文版的是 2013年出版的。但是经典之所以成为经典，正是因为不会过时。这本书里的性能分析思路以及很多的性能工具，到今天依然适用。

另外，我也推荐你去关注他的个人网站 http://www.brendangregg.com/，特别是 [Linux Performance](http://www.brendangregg.com/linuxperf.html) 这个页面，包含了很多 Linux 性能优化的资料，比如：
+ Linux 性能工具图谱
+ 性能分析参考资料
+ 性能优化的演讲视频
