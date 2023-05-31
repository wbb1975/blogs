# Spark SQL 指南

Spark SQL 用于结构化数据处理的 Spark 模块。不像基础 `Spark RDD API`, `Spark SQL` 提供的接口为 Spark 提供了事关处理数据和运算的更多结构信息。在内部 `Spark SQL` 使用这些额外信息来执行额外的优化。有多种 `Spark SQL` 交互方式，包括 `SQL` 和 `Dataset API`。计算结果时使用相同的运算引擎，无论 你用什么样的 API/语言表达你的运算。这种统一意味着开发者可以在不同 API 间自由切换，并选择能够表达给定转换的最自然的方式。

本页面上的所有示例的数据都包括在 Spark 分发中，可以在 `spark-shell`, `pyspark shell`, 或 `sparkR shell` 中执行。

#### SQL

Spark SQL 的一种使用场景是执行 SQL 查询。Spark SQL 可被用于从一个已有 Hive 安装读取数据。关于如何配置这个特性的更多信息，请参见 Hive Tableshttps://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html 章节。

#### Datasets and DataFrames

## 1. 入门篇
## 2. 数据源
## 3. 性能调优
## 4. 分布式 SQL 引擎
## 5. 基于带 Apache Arrow 的 Pandas PySpark使用指南（PySpark Usage Guide for Pandas with Apache Arrow）
## 6. 迁移指南
## 7. SQL 参考
## 8. 错误条件（Error Conditions）

## Reference 

- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)