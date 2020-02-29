# 用户指南
Guava项目包括几个Google的核心库, 这些库在Java项目中颇受依赖：集合，缓存，原生支持，并发库，常规注解，字符串处理，I/O等。这些工具中的每一个每天都被Googlers在产品服务中使用。

但是详细阅读Javadoc并不总是学习使用库的最有效方式，这里我们将对Guava中一些最流行，功能最强大的特性提供可读性好，令人舒适的解释。

这个wiki页仍处于进展状态，某些部分仍处于更新中。
- 基本工具（Basic utilities）：让使用Java语言变得更舒适
  + 使用和避免null：null是模棱两可的，会引起令人困惑的错误，有些时候它让人很不舒服。很多Guava工具类拒绝null，碰到null时快速失败，而不是盲目地接受
  + 前置条件（Preconditions）: 让方法中的条件检查更简单
  + 常见Object方法: 简化Object方法实现，如hashCode()和toString()
  + 排序（Ordering）: Guava强大的”流畅风格比较器”类
  + Throwables：简化了异常和错误的传播与检查
- 集合：Guava对JDK集合的扩展，这是Guava最成熟和流行的部分
  + 不可变集合: 用不变的集合进行防御性编程和性能提升
  + 新集合类型: multisets, multimaps, tables, bidirectional maps等
  + 强大的集合工具类（Powerful collection utilities）: 提供java.util.Collections中没有的集合工具
  + 扩展工具类（Extension utilities）：让实现和扩展集合类变得更容易，比如创建Collection的装饰器，或实现迭代器
- 图（graph）：一个对[图](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics))结构化数据建模的库，比如，实体以及实体之间的关系。关键特性包括：
  + 图：一个图，其边是匿名实体且没有身份，也没有它们自己的信息。
  + 值图：一个图其边附有非唯一性值
  + 网络：其边为唯一值的图
  + 对可变及不可变，有向或无向，以及几种别的属性的图的支持
- 缓存：本地缓存实现，支持多种缓存过期策略
- 函数式风格（Functional idioms）：Guava的函数式支持可以显著简化代码，但请谨慎使用它
- 并发：强大而简单的抽象，让编写正确的并发代码更简单
  + ListenableFuture: Futures, 提供当其完成时的回调
  + 服务：一组启动并停止，把你照顾一些困难的状态逻辑的东西
- 字符串：非常有用的字符串工具，包括分割、连接、填充等操作
- 原生类型：扩展 JDK 未提供的原生类型（如int、char）操作， 包括某些类型的无符号形式
- 区间：可比较类型的区间API，包括连续和离散类型
- I/O：简化I/O尤其是I/O流和文件的操作，针对Java5和6版本
- 散列（Hashing）：提供比Object.hashCode()更复杂的散列实现，并提供布隆过滤器的实现
- 事件总线（EventBus）：发布-订阅模式的组件通信，但组件不需要显式地注册到其他组件中
- 数学运算（Math）：优化的、充分测试的数学工具类
- 反射：Guava 的 Java 反射机制工具类
- 小提示：让你的应用以Guava的方式工作
  + 原理：Guava是什么，不是什么，以及我们的目标
  + 在你的构建中使用Guava：包括Maven，Gradle等多种构建系统
  + 使用ProGuard来避免把你未使用的Guava部分集成进你的Jar中
  + Apache Commons对等体，帮你把使用Apache Commons Collections的代码转换到使用Guava
  + 兼容性：Guava各个版本的兼容性细节
  + Idea Graveyard：已经被正是拒绝的特性请求
  + 朋友：我们喜欢并尊敬的开园项目 open-source projects we like and admire.
  + 如何贡献：怎样帮助Guava.
  
> **注意**：为了讨论本wiki中的内容，请加入guava-discuss邮件列表。

## Reference
- [Guava Wiki](https://github.com/google/guava/wiki)
- [Google Guava官方教程（中文版）](http://ifeve.com/google-guava/)