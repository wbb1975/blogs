## Apache Spark Dataset Encoders 解密

Encoders 就像 `Spark Dataset APIs`　的秘密酱汁，后者正成为 `Spark Jobs` 的默认范式。本文将试着揭秘其基本要素。

在 Spark 中 RDD, Dataframe, 和 Dataset 是一个数据记录集合的不同表现形式，并且每一种都有一套自己的 `API` 以在集合上执行期待的转换和行动（transformations and actions ）。在这三者中，RDD 是最老的且最基础的表现形式，而 Dataframe 和 Dataset 在 `Spark 1.6` 中引入。

但是，随着 `Spark 2.0` 的发布，在编写 `Spark Jobs` 时在 Spark 程序员中 Datasets 的使用已经成为默认标准。Dataframe（将记录集合表示成表格形式）的概念在　`Spark 2.0`　中与 Dataset 合并。在 `2.0` 中，一个 Dataframe 仅仅时某种类型的 Dataset 的一个别名。 Dataset 的流行源自以下事实，它被设计合并了 RDD 和 Dataframe 世界的优点，即 RDDs 的灵活性及编译器类型安全，以及 Dataframes 的效率及性能。

Dataset 概念的中心在于为 Dataset 提供了超过 RDDs 的存储及执行效率的一个 Encoder 框架。理解这个 `encoder` 框架对于编写和调试基于 Dataset 的 Spark Jobs 非常重要。由于每个 Dataset 必须与一种类型关联，当一个特定类型的 Dataset 被创建时（从一个文件，一个内存中的对象集合，RDD, 或者一个 Dataset），必须在 Dataset 创建 API 里指定一个对应的相同类型的 Encoder。但是，`encoder` 规范在某些场景下可能不明显，例如装箱基本类型。


### Reference

- [Apache Spark Dataset Encoders Demystified](https://towardsdatascience.com/apache-spark-dataset-encoders-demystified-4a3026900d63)