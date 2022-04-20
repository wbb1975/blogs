# 最重要的 JVM 参数指南

## 1. 概述

在这个快速教程中，我们将探索广为人知的 Java 虚拟机的配置选项。

## 2. 显式堆内存 -- Xms and Xmx 选项

最常见的性能相关实践是根据应用的需要初始化堆内存。

这就是我们指定最小最大堆大小的原因所在。下面的参数可以用于实现这个：
```
-Xms<heap size>[unit] 
-Xmx<heap size>[unit]
```

这里，**unit** 代表内存（由堆大小指定）初始化单位，Units 可用 **‘g'** 代表 GB, **‘m'** 代表 MB， **‘k'** 代表 KB.

例如，如果你想指定最小内存 2 GB, 最大 5 GB 给 JVM，我们需要指定如下：
```
-Xms2G -Xmx5G
```

从 Java 8 开始，[Metaspace](https://matthung0807.blogspot.com/2019/03/about-g1-garbage-collector-permanent.html) 大小未被指定。一旦它达到全局限制，JVM 自动增加它。但是为了克服不必要的不稳定性，我们可以如下设置 `Metaspace`：
```
-XX:MaxMetaspaceSize=<metaspace size>[unit]
```

这里，**metaspace size** 指定了我们想指派给 Metaspace 的内存数。

根据 [Oracle 指南](https://docs.oracle.com/en/java/javase/11/gctuning/factors-affecting-garbage-collection-performance.html#GUID-189AD425-F9A0-444A-AC89-C967E742B25C)，所有可用内存之后，第二最重要的影响因素是为年轻代预留的堆比例，默认情况下，年轻代最小大小为 1310 MB，最大大小无限制。

我们可以显式制定它们：
```
-XX:NewSize=<young size>[unit] 
-XX:MaxNewSize=<young size>[unit]
```

## 3. 垃圾收集

为了更好的程序稳定性，选择正确的垃圾收集算法是至关重要的。

JVM 拥有四种垃圾收集实现：
- 串行垃圾收集器
- 并行垃圾收集器
- CMS 垃圾收集器
- G1 垃圾收集器

这些实现可以用如下参数声明：
```
-XX:+UseSerialGC
-XX:+UseParallelGC
-XX:+USeParNewGC
-XX:+UseG1GC
```

垃圾收集器实现的更多细节可以在[这里](https://www.baeldung.com/jvm-garbage-collectors)找到。

## 4. 垃圾收集日志

为了严格地监控应用的健康，我么应该总是检查 JVM 垃圾收集性能。做这个最简单的方式就是以人类可读的格式记录 GC 活动。

使用下买你的参数，我们可以记录 GC 活动：
```
-XX:+UseGCLogFileRotation 
-XX:NumberOfGCLogFiles=< number of log files > 
-XX:GCLogFileSize=< file size >[ unit ]
-Xloggc:/path/to/gc.log
```

**UseGCLogFileRotation** 指定了日志文件滚动策略，很像 log4j，s4lj 等。**NumberOfGCLogFiles** 指定了在应用生命周期中可以产生的最大日志文件数目。**GCLogFileSize** 指定了每个日志文件的大小。最后，**loggc** 指定了文件位置。

这里需要注意的是有两个额外的 JVM 参数（**-XX:+PrintGCTimeStamps** 和 **-XX:+PrintGCDateStamps**），它们可用于在垃圾收集器日志中输出日期。

例如，如果你期待最多写出 100 个垃圾收集器日志文件，每个最大 50M 并将其存储在 `/home/user/log/`，那么你可以像下面这样指定：
```
-XX:+UseGCLogFileRotation  
-XX:NumberOfGCLogFiles=10
-XX:GCLogFileSize=50M 
-Xloggc:/home/user/log/gc.log
```

但是，问题在于一个额外的守护线程用于在后台监控系统时间。这个行为可能导致某些性能瓶颈；这就是生产环境中不启用这个参数的原因。

## 5. 处理内存耗尽

对一个大型应用来讲，内存用尽并导致应用崩溃时很常见的。这是一个非常关键的场景，它难于复现因此难以解决。

这是为什么 JVM 提供一些参数用于将堆内存导出到物理文件中以便稍后查找（内存泄露）。
```
-XX:+HeapDumpOnOutOfMemoryError 
-XX:HeapDumpPath=./java_pid<pid>.hprof
-XX:OnOutOfMemoryError="< cmd args >;< cmd args >" 
-XX:+UseGCOverheadLimit
```

一些值得注意的点包括：

- **HeapDumpOnOutOfMemoryError** 指示 JVM 当有 OutOfMemoryError 发生时将堆内存倾泻到物理文件
- **HeapDumpPath** 指定输出文件路径；可以给定任何文件，但是如果 JVM 在名字中发现了 **<pid>** 标签，导致内存用尽错误的当前进程 id 将会追加到文件名末尾， 其格式是 **.hprof**
- **OnOutOfMemoryError** 用于指定当发生内存用尽错误时执行的紧急命令；因该在 **cmd args** 中指定合适的命令。如果我们想在内存用尽错误发生时尽快重启服务器，我们应该设置如下：
  ```
  -XX:OnOutOfMemoryError="shutdown -r"
  ```
- **UseGCOverheadLimit** 是一个策略，它用于限制在内存用尽错误抛出前限制虚拟机花在垃圾收集上的时间

## 6. 32/64 位

在一个32位和64位软件包都安装的操作系统环境中，JVM 会自动选择32位环境的软件包。

如果我们想手动设置环境为64位，我们可以如下设置：
```
-d<OS bit>
```

`OS bit` 可以是32位或者64位，更多信息可以在[这里](http://www.oracle.com/technetwork/java/hotspotfaq-138619.html#64bit_layering)找到。

## 7. 杂项

- **-server** 开启 “Server Hotspot VM”，这个参数默认被64位 JVM 使用
- **-XX:+UseStringDeduplication** Java 8u20 引入了这个 JVM 参数以减少由于创建了同一个字符串的多个实例而导致的不必要的内存占用。它通过减少重复的字符串值到一个单一全局字符数组以优化堆内存
- **-XX:+UseLWPSynchronization** 设置基于 LWP (Light Weight Process，轻量级进程)的同步策略而非基于线程的同步
- **-XX:LargePageSizeInBytes** 设置 Java 堆使用的大页面大小。它带有参数如 GB/MB/KB。利用更大的分页大小，我们可以更好的利用虚拟内存硬件资源。这可能导致更大的 PermGen 空间，这会导致 Java 堆空间的减小。
- **-XX:MaxHeapFreeRatio** 设置垃圾收集后最大的堆释放百分比以避免收缩
- **-XX:MinHeapFreeRatio** 设置垃圾收集后最小的堆释放百分比以避免扩张，你可以使用随 JDK 发布的 [VisualVM](https://visualvm.github.io/)来监控堆的使用
- **-XX:SurvivorRatio** `eden/survivor` 空间大小比率--例如， `-XX:SurvivorRatio=6`  设置每个 survivor 空间与 eden 空间的比率为 16
- **-XX:+UseLargePages** 如果系统支持就使用大页面内存。请注意如果使用这个参数 OpenJDK 7 可能会崩溃
- **-XX:+UseStringCache** 在字符串池中开启最常分配的字符串的缓存
- **-XX:+UseCompressedStrings** 对于可以完全由纯粹 ASCII 表示的字符串使用 byte[] 来代表字符串
- **-XX:+OptimizeStringConcat** 它尽可能地优化字符串拼接操作

## 8. 结论

如果你想更详细地探索这些引用的参数，你可以从[这里](http://www.oracle.com/technetwork/articles/java/vmoptions-jsp-140102.html)开始。

## Reference
- [Guide to the Most Important JVM Parameters](https://www.baeldung.com/jvm-parameters)