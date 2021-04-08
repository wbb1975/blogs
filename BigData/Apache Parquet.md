# Apache Parquet
## 动机
我们创建 Parquet 是为了在 Hadoop 生态中的任一项目利用压缩的高效的列数据表示。

Parquet 基于思维中的嵌套数据结构从头开始构建，利用了 Dremel 论文中描述的[记录分片和装配算法（record shredding and assembly algorithm）](https://github.com/julienledem/redelm/wiki/The-striping-and-assembly-algorithms-from-the-Dremel-paper)。我们认为这种方式比网状名字空间的简单扁平化更具优势。

Parquet 支持高效压缩算法和编码模式（`schemes`）。多个项目已经展示了对数据采用正确的压缩算法和编码模式的性能影响。Parquet 允许压缩模式特定于每一个列级别。当新的编码方案被发明并实现后，它们可以被添加进来，从而永远不会过时。

Parquet 可以被任何人使用。Hadoop 生态多有数据处理框架，但我们对自娱自乐不感兴趣。我们相信一个高效的实现良好的列存储底层对所有框架都是有用的，因为它无需担心扩展的成本，以及设立依赖的困难。
## 模块
[parquet-format](https://github.com/apache/parquet-format) 项目包含格斯规范，以及正确地读入 Parquet 文件所需的元数据的 `Thrift` 定义。

[parquet-mr](https://github.com/apache/parquet-mr) 项目包括多个子模块，它实现了读写嵌套的面向列数据流的核心组件，将这个核心映射到 Parquet 格式，并提供 Hadoop 输入/输出格式，`Pig` 加载器，以及其它一些与 Parquet 交互的基于 Java 的工具。

[parquet-cpp](https://github.com/apache/parquet-cpp) 项目提供了一个读写 Parquet 文件的 C++ 库。

[parquet-rs](https://github.com/sunchao/parquet-rs) 项目是一个读写 Parquet 文件的 Rust 库。

[parquet-compatibility](https://github.com/Parquet/parquet-compatibility) 项目包含兼容性测试，用于验证不同语言读写相互的文件的实现。
## 构建
Java 资源可以使用 `mvn package` 构建。当前的稳定版本总是可以从 `Maven` 中央仓库获得。

`C++ thrift` 资源可以通过 `make` 生成。

`Thrift` 通过代码生成可产生其它多种支持 `Thrift` 的语言。
## 发布
请参见[如何发布](https://parquet.apache.org/documentation/how-to-release/)。
## 术语
- Block（hdfs block）：这是指 hdfs 的一个 block，它意味着在描述文件格式时是不可改变的。该文件格式被设计为在 hdfs 之上很好地工作。
- 文件：一个 hdfs 问你按必须包含该文件的元信息，它甚至不需要实际包含数据。
- 行组（Row group）：多行数据的逻辑横向分区。没有一个物理结构来保证一个行组。一个行组由包含该数据集中的每一个列的多个列块。
- 列块（Column chunk）：一个块数据仅包含一列。列快驻留于一个特殊的行组，且在文件里保证是连续的。
- 页（Page）：列块又被分割为页。也是一个概念上不可分割的单元（基于压缩和编码而言）。在一个列块内有多种类型的页相互交织。
## 并行单元（Unit of parallelization）
- MapReduce - 文件/行组
- IO - 列块
- 编码/压缩 - 页
## 文件格式
文件及其 Thrift 定义应该一起读入以理解文件格式。
```
4-byte magic number "PAR1"
<Column 1 Chunk 1 + Column Metadata>
<Column 2 Chunk 1 + Column Metadata>
...
<Column N Chunk 1 + Column Metadata>
<Column 1 Chunk 2 + Column Metadata>
<Column 2 Chunk 2 + Column Metadata>
...
<Column N Chunk 2 + Column Metadata>
...
<Column 1 Chunk M + Column Metadata>
<Column 2 Chunk M + Column Metadata>
...
<Column N Chunk M + Column Metadata>
File Metadata
4-byte length in bytes of file metadata
4-byte magic number "PAR1"
```
在上面的例子中，该表有 N 列，被分割成 M 个行组。文件元数据包含所有列元信息起始位置的信息。关于元数据的更多细节可以在 thrift 文件中找到。

元数据是在数据之后一次性写入的。

读程序期待首先读入文件元数据找到它该信去的所有列块，这些列块应该被顺序读取。

![Parquet 文件格式图](images/FileLayout.gif)
## 元数据
有三种类型的元数据：文件元数据，列（块）元数据，页头元数据。所有的 `thrift` 结构都使用 `TCompactProtocol` 序列化。

![Parquet 元数据](images/FileFormat.gif)
## 类型
文件格式支持的数据类型尽量少，而关注于这些类型如何影响磁盘存储。例如，在高效编码上由于 16 位整形数已经由 32 位整形数包含，16 位整形数并未被显式支持。这降低了实现该文件格式的读写应用的复杂性。这些类型包括：
- BOOLEAN: 1 位布尔值
- INT32: 32 位有符号整数
- INT64: 64 位有符号整数
- INT96: 96 位有符号整数
- FLOAT: IEEE 32 位浮点数
- DOUBLE: IEEE 64 位浮点数
- BYTE_ARRAY: 任意长字节数组
## 逻辑类型
逻辑类型通过执行基本类型如何被解释来扩展可用于 parquet 存储的类型。这保证基本数据类型集最小化，记忆高效编码。例如，字符串被存储为 UTF-8 注解的字节数组。这些注解定义了如何解码和解释数据。注解唉文件元数据中存储为 ConvertedType，其文挡在 [LogicalTypes.md](https://github.com/apache/parquet-format/blob/master/LogicalTypes.md)可见。
## 嵌套编码
## Nulls
## 数据页
## 列块
## Checksumming
## 错误恢复
## 分割元数据和列数据
## 配置
## 扩展性

## Reference
- [Apache Parquet](https://parquet.apache.org/documentation/latest/)
- [parquet-format](https://github.com/apache/parquet-format)