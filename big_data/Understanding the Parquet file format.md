## Understanding the Parquet file format

这是关于 Apache Arrow 系列博文的一部分，该系列包括下列文章：

- [Understanding the Parquet file format.md](https://www.jumpingrivers.com/blog/parquet-file-format-big-data-r/)
- [Reading and Writing Data with {arrow}](https://www.jumpingrivers.com/blog/arrow-reading-writing-feather-hive-parquet/)
- [Parquet vs the RDS Format](https://www.jumpingrivers.com/blog/arrow-rds-parquet-comparison/)

[Apache Parquet](https://parquet.apache.org/)是 Hadoop 系统如 Pig, [Spark](https://spark.apache.org/), 和 Hive 使用的流行的列存储格式。这个文件格式是语言中立的并且它是二进制格式。Parquet 用于存高效存储大型数据集，文件扩展名为 `.parquet`。本文旨在帮助理解 parquet 如何工作，以及它高效存储数据的技巧。

parquet 的关键特性是：

- 它是跨平台的
- 它是许多系统使用的公认的文件格式
- 它以列式布局存储数据
- 它存储元数据

后两点帮助高效存储数据和查询数据。

## 列式存储

假如我们拥有如下简单数据帧：

```
tibble::tibble(id = 1:3, 
              name = c("n1", "n2", "n3"), 
              age = c(20, 35, 62))
#> # A tibble: 3 × 3
#>      id name    age
#>   <int> <chr> <dbl>
#> 1     1 n1       20
#> 2     2 n2       35
#> 3     3 n3       62
```

如果我们将这个数据集存储为 CSV 格式，我们在 R 终端上看到的将被映射到文件存储格式。这是行存储，它对如下文件查询效率很高：

```
SELECT * FROM table_name WHERE id == 2
```

我们简单地跳到第二行并检索对应数据。添加新行到数据集也很容易--我们直接添加新行到文件末尾。但是，如果你想对 age 列求和，那么就潜在地不高效了。我们就需要决定每一行的 age 位置，并提取其具体值。

Parquet 使用列存储，在列布局中，同一列的值顺序存储。

```
1 2 3
n1 n2 n3
20 35 62
```

基于这个布局，下面的查询：

```
SELECT * FROM dd WHERE id == 2
```

将不再方便。但如果你想对 `age` 求和，我们可以简单地跳到第三行并将所有数值加在一起。

## 读写 parquet 文件

在 R 中，我们使用 `{arrow}` 包来读写 parquet 文件。

```
# install.packages("arrow")
library("arrow")
packageVersion("arrow")
#> [1] '14.0.0.2'
```

为了创建 parquet 文件，我们使用 `write_parquet()`:

```
# Use the penguins data set
data(penguins, package = "palmerpenguins")
# Create a temporary file for the output
parquet = tempfile(fileext = ".parquet")
write_parquet(penguins, sink = parquet)
```

为了读文件，我们使用 `read_parquet()`。使用 parquet 的一个收益是其文件大小。这在处理大数据集时是很重要的，尤其当你将云存储成本考虑进来时。减小大小通过如下两种方法达成：

- 文件压缩：这通过 `write_parquet()` 的 `compression` 参数指定。默认为 [snappy](https://en.wikipedia.org/wiki/Snappy_(compression))。
- 聪明的值的存储。

## Parquet 编码

因为 parquet 使用列存储，同类型的值按数量存储在一起。这打开了一个优化技巧的新世界，而这些在行存储，如 CSV 中不可用。


### 行程编码（Run length encoding）

假如一列在所有的行中包含同一值，我们可以记录“值 X 重复了 N 次”而不是一遍又一遍存储这个值（如 CSV 文件所做）。这意味着即使 `N` 变得很大，存储成本依然很小。如果一列有多个值，我们可以使用一个简单的查询表。在 parquet 中，这被称为行程编码（Run length encoding）。如果我们有下面这个列：

```
c(4, 4, 4, 4, 4, 1, 2, 2, 2, 2)
#>  [1] 4 4 4 4 4 1 2 2 2 2
```

这将被存储为：

- 值4，重复5次
- 值1，重复1次
- 值2，重复4次

为了检验其运作，让我们创建一个简单的例子，这里字符 `A` 在一个数据帧中重复了很多次：

```
x = data.frame(x = rep("A", 1e6))
```

我们可以为我们的实验创建许多临时文件：

```
parquet = tempfile(fileext = ".parquet")
csv = tempfile(fileext = ".csv")
```

并将数据输出到文件：

```
arrow::write_parquet(x, sink = parquet, compression = "uncompressed")
readr::write_csv(x, file = csv)
```

使用 `{fs}` 包，我们可以抽取文件大小：

```
# Could also use file.info()
fs::file_info(c(parquet, csv))[, "size"]
#> # A tibble: 2 × 1
#>          size
#>   <fs::bytes>
#> 1         808
#> 2       1.91M
```

我们可以看到 parquet 文件很小，而 CSV 文件接近 `2 M`。实际上文件大小见笑了仅 500 倍。

### 字典编码（Dictionary encoding）

假设我们拥有如下的字符向量：

```
arrow::write_parquet(x, sink = parquet, compression = "uncompressed")
readr::write_csv(x, file = csv)
```

如果我们想节省存储，我们可以将 `Jumping Rivers` 替换为数字 `0`，并创建一个表映射 `0` 和 `Jumping Rivers`。这可以极大地减小存储，尤其是对长向量。

```
x = data.frame(x = rep("Jumping Rivers", 1e6))
arrow::write_parquet(x, sink = parquet)
readr::write_csv(x, file = csv)
fs::file_info(c(parquet, csv))[, "size"]
#> # A tibble: 2 × 1
#>          size
#>   <fs::bytes>
#> 1         909
#> 2       14.3M
```

### 增量编码（Delta encoding）

这种编码典型地与时间戳一起使用。时间典型地存储为 Unix 时间。它代表自 1970-01-01 以来的以秒计时的数字。这种存储格式对人来说并不特别有帮助，但它打印出来后却很容易理解，例如：

```
(time = Sys.time())
#> [1] "2024-02-01 13:02:03 CET"
unclass(time)
#> [1] 1706788923
```

如果我们在一列上拥有大量时间戳，减小文件大小的 一种方法是从所有值中减去最小时间戳。例如，替代存储：

```
c(1628426074, 1628426078, 1628426080)
#> [1] 1628426074 1628426078 1628426080
```

我们使用：

```
c(0, 4, 6)
#> [1] 0 4 6
```

基本偏移量为 `1628426074`。

### 其它编码（Other encodings）

还有一些 parquet 使用的其它技巧。[Github 页面](https://github.com/apache/parquet-format/blob/master/Encodings.md) 提供了一个完整的介绍。

```
arrow::write_parquet(x, sink = parquet, compression = "uncompressed")
readr::write_csv(x, file = csv)
```

如果你拥有一个 parquet 文件，你可以使用 [parquet-mr](https://github.com/apache/parquet-mr) 来研究该文件使用的编码。但是，安装该工具并不简单且需要时间。 

## Feather vs Parquet

当我们讨论 parquet 时，一个出现在脑海的明显问题是，它如何与 feather 文件格式比较？Feather 为速度而优化，反之 parquet 为存储而优化。值得注意的是[Apache Arrow](https://arrow.apache.org/faq/#what-about-the-feather-file-format)的文件格式是Feather。

## Parquet vs RDS 格式

RDS 文件格式用于 readRDS()/saveRDS() 和 load()/save()。它是 R 的原生文件格式且只能被 R 读取。使用 RDS 的主要收益在于它能够存储任何 R 对象--环境，列表以及函数。

## Reference

- [Understanding the Parquet file format.md](https://www.jumpingrivers.com/blog/parquet-file-format-big-data-r/)
- [Reading and Writing Data with {arrow}](https://www.jumpingrivers.com/blog/arrow-reading-writing-feather-hive-parquet/)
- [Parquet vs the RDS Format](https://www.jumpingrivers.com/blog/arrow-rds-parquet-comparison/)
- [Parquet-tools](https://github.com/ktrueda/parquet-tools) 用于检视 Parquet 文件。
- [Difference between Apache parquet and arrow](https://stackoverflow.com/questions/56472727/difference-between-apache-parquet-and-arrow)
- [Parquet encoding definitions](https://github.com/apache/parquet-format/blob/master/Encodings.md)
- [Extreme IO performance with parallel Apache Parquet in Python](https://wesmckinney.com/blog/python-parquet-multithreading/)
- [apache/parquet-cpp](https://github.com/apache/parquet-cpp)
- [Deep Dive into Apache Parquet: Efficient Data Storage for Analytics](https://learncsdesigns.medium.com/understanding-apache-parquet-d722645cfe74)