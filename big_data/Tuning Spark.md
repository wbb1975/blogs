## Spark 调优

由于大多数 Spark 运算的内存性质，Spark 程序可由集群内的任何资源形成瓶颈：CPU, 网络带宽， 或内存。最常见的是数据填充内存，瓶颈在网络带宽；但有时候你需要做一些调优，例如[将 RDD 存为序列化形式](https://spark.apache.org/docs/latest/rdd-programming-guide.html#rdd-persistence)来降低内存使用。这个指南将覆盖两个主题：数据序列化，这对好的网络性能至关重要，也能降低内存使用；以及内存调优。我们还将简单描述几个稍小主题。

### 1. 数据序列化

对任何分布式应用的性能，序列化都扮演了非常重要的角色。序列化很慢，或者消耗大量字节的格式将极大地拖慢运算。它经常是你优化 Spark 应用应首先调整的选项。Spark 努力在便利性（可以让你在你的操作中与 Java 类型交互）和性能之间获取平衡。它提供了两个序列化库：

- [Java 序列化](https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html)：Spark 默认使用 Java 的 `ObjectOutputStream` 框架来序列化对象，它可以与任何你创建的实现了 [java.io.Serializable](https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html) 接口的类一起工作。我们可以通过扩展 [java.io.Externalizable](https://docs.oracle.com/javase/8/docs/api/java/io/Externalizable.html) 来更紧密地控制你的序列化性能。Java 序列化足够灵活，但通常很慢，类如果很多则导致大量的序列化格式。
- [Kryo 序列化](https://github.com/EsotericSoftware/kryo)：Spark 可以使用 Kryo 库（版本4）来更快地序列化对象。Kryo 快得多，且比 Java 序列化更紧凑（通常 10x），但不支持所有的 Serializable 类型，而且需要你事先注册你在应用中用到的类以取得最佳性能。

通过用一个 [SparkConf](https://spark.apache.org/docs/latest/configuration.html#spark-properties)初始化你的 Job 并调用 `conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")`，你可以切换使用 Kryo。这个设置不仅配置了在工作节点间 `shuffling` 数据的序列化器（serializer），也设置了将 RDDs 序列化至磁盘的序列化器（serializer）。Kryo 没成为默认序列化的唯一原因是自定义注册需求，但我们推荐在任何网络密集型应用中试用它。从 `Spark 2.0.0` 起，我们已经在内部使用 `Kryo serializer` 来 `shuffling` 简单类型，简单类型数组以及字符串类型的 RDDs。

Spark 为许多来自 [Twitter chill](https://github.com/twitter/chill) `AllScalaRegistrar` 里的常用核心 Scala 类自动包含 `Kryo serializers`。

为了用 Kryo 注册你的自定义类，使用 registerKryoClasses 方法：

```
val conf = new SparkConf().setMaster(...).setAppName(...)
conf.registerKryoClasses(Array(classOf[MyClass1], classOf[MyClass2]))
val sc = new SparkContext(conf)
```

[Kryo 文档](https://github.com/EsotericSoftware/kryo)描述了更多高级注册选项，例如添加自定义序列化。这个值需要足够大至能够容纳你序列化的最大对象。

如果你的对象很大，你可能也需要增加你的 `spark.kryoserializer.buffer` [配置](https://spark.apache.org/docs/latest/configuration.html#compression-and-serialization)。

最后，如果你没有注册你的自定义类，Kryo 仍可工作，但它将不得不为每个对象存储器类名，这是一种浪费。

### 2. Memory Tuning
Memory Management Overview
Determining Memory Consumption
Tuning Data Structures
Serialized RDD Storage
Garbage Collection Tuning
### 3. Other Considerations
Level of Parallelism
Parallel Listing on Input Paths
Memory Usage of Reduce Tasks
Broadcasting Large Variables
Data Locality
### 4. Summary

### Reference

- [Tuning Spark](https://spark.apache.org/docs/latest/tuning.html#data-serialization)
- [kryo](https://github.com/EsotericSoftware/kryo)