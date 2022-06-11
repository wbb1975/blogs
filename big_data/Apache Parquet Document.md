# Apache Parquet

## 1. 概览

Apache Parquet 是一个列存储格式，可用于 Hadoop 生态系统中的任一项目，不管其选择何种数据处理框架，数据模型和编程语言。

### 1.1 动机

为了给 Hadoop 生态系统中的项目提供压缩高效的列数据呈现，我们创造了 Parquet。

Parquet 是从头开始构建的复杂嵌套数据结构，使用了 Dremel 论文里描述的[记录分割及装配算法（record shredding and assembly algorithm）](https://github.com/julienledem/redelm/wiki/The-striping-and-assembly-algorithms-from-the-Dremel-paper)。我们相信这种方式比嵌套名字空间的简单扁平化更优秀。

Parquet 被构建以支持非常高效的压缩及编码模式（schemes）。多个项目已经证明了对数据采用正确的压缩及编码模式的性能影响。Parquet 允许在列级别指定压缩模式，从它们被发明及实现之日起就允许添加更多更多编码方式，因此基本是永不过时的。

Parquet 可被任何人使用。Hadoop 生态系统拥有丰富的数据处理框架，但我们并不偏向任意一个。我们相信一个高效的，良好实现的列存储底层对所有框架都是有用的，而且不用担心成本扩张以及复杂的使用依赖。

## 2. 概念
> 相关术语词汇表。

**块 (hdfs 块)**：这意味着 hdfs 中的一个块，在描述这个文件格式时其意义并无改变。这个文件格式设计用于在 hdfs　之上良好工作。

**文件**：一个 hdfs 文件必须包含这个文件的元信息。它并不需要实际包含数据。

**行组**：一个包含多行数据的逻辑水平分区。没有物理结构来确保一个行组。一个行组包含数据集针对每个列的列块（column chunk）。

**列块**：特定列的数据块。它们驻留于一个特定的行组，且在文件中确保使连续的。

**页**：列块细分成页。一个页是一个概念上不可分割的单元（基于压缩和编码来讲）。在一个列块中可能拥有多个交错的页类型。

层次上看，一个文件包含一个或多个行组。一个行组内每个列拥有一个列块。列块包含一个或多个页。

## 3. 文件格式
> 关于 Parquet 文件格式的文档。

文件和 thrift 定义应该一起阅读以了解其格式：
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

在上面的例子中，表中有 N 个列，被划分进 M 个行组。文件元信息包含所有列元数据开始位置的信息。关于元信息包含什么的具体细节可以在 thrift 文件里找到。

元信息在数据之后被写入以允许单程写入。

**读取器期望首先读入文件元信息以找到它们感兴趣的所有列块。列块其后应该顺序读入**。

文件格式显式设计以分隔元数据和数据本身。这允许将列划分进多个文件，同时有一个单一元数据文件以引用多个 Parquet 文件。

![文件格式](images/FileLayout.gif)

### 3.1 配置

**行组大小**

更大的行组允许更大的列块，这使得更大的序列 IO 成为可能。更大的组同时需要在写入路径（或双道写入）上更大的缓存。我们推荐大的行组（512MB - 1GB）。因为整个行组可能需要被读入，我们期待它完美匹配一个 HDFS 块（HDFS block）。如此，HDFS 块大小也应该被调高。一个优化的读设置应该是： 1GB 行组, 1GB HDFS 块大小, 每 HDFS 文件1个 HDFS 块。

**数据页大小**

数据页应该被是为不可分的，因此更小的数据页允许更精细的读取（例如单行查询）。更大的页大小带来更小的空间消耗（更小的页头部）及潜在的更小的解析负荷（处理头部）。注意：对顺序扫描，并不期待一次读入一个页面，这并不是 IO 块，我们推荐 8KB 页大小。

### 3.2 扩展性（Extensibility）

### 3.3 元数据

### 3.4 类型

### 3.5 嵌套编码

### 3.6 数据页

### 3.7 Nulls

## 4. 开发者指南

## 5. 资源

## Reference
- [Apache Parquet](https://parquet.apache.org/docs/overview/)
