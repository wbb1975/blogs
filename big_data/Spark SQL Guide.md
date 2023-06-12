# Spark SQL 指南

Spark SQL 是用于结构化数据处理的 Spark 模块。不像基本 `Spark RDD API`, `Spark SQL` 提供的接口为 Spark 提供了处理的数据和运算的更多结构化信息。在内部 `Spark SQL` 使用这些额外信息来执行额外的优化。有多种 `Spark SQL` 交互方式，包括 `SQL` 和 `Dataset API`。计算结果时使用相同的运算引擎，无论你用什么样的 `API/Language` 表达你的运算。这种统一意味着开发者可以在不同 API 间自由切换，并选择能够表达给定转换的最自然的方式。

本页面上的所有示例的数据都包括在 Spark 分发中，可以在 `spark-shell`, `pyspark shell`, 或 `sparkR shell` 中执行。

#### SQL

Spark SQL 的一种使用场景是执行 SQL 查询。Spark SQL 可被用于从一个已有 Hive 安装读取数据。关于如何配置这个特性的更多信息，请参见 [Hive Tables](https://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html) 章节。在另一种编程语言中运行 SQL 时，结果以 [Dataset/DataFrame](https://spark.apache.org/docs/latest/sql-programming-guide.html#datasets-and-dataframes) 对象返回。你也可以利用[命令行](https://spark.apache.org/docs/latest/sql-distributed-sql-engine.html#running-the-spark-sql-cli) 或 [JDBC/ODBC](https://spark.apache.org/docs/latest/sql-distributed-sql-engine.html#running-the-thrift-jdbcodbc-server) 来与 SQL 接口交互。

#### Datasets 和 DataFrames

一个 Dataset 是一个分布式数据集合。Dataset 是自 `Spark 1.6` 添加的新接口，它提供了比 RDDs 更多的收益（强类型，使用强大 lambda 函数的能力）以及 Spark SQL 优化执行引擎。一个 Dataset 可以从 JVM 对象[构造](https://spark.apache.org/docs/latest/sql-getting-started.html#creating-datasets)并使用函数式转换（`map`, `flatMap`, `filter`，等）控制。Dataset API 包含 [Scala](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html) 及 [Java](https://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html)。Python 不支持 `Dataset API`，但由于 Python 的动态特性，Dataset API 的很多收益已经享受到了（例如，你可以很自然地利用 `row.columnName` 访问一行里的字段）。R 属于同样的情况。

一个 DataFrame 是拥有命名列名的 Dataset。它概念上与关系数据库里的一个表或者 `R/Python` 里的一个 `data frame` 相同，但背后拥有更多的优化。DataFrames 可从一个很大范围的[数据源](https://spark.apache.org/docs/latest/sql-data-sources.html)构造，例如：结构化数据文件，Hive 中的表，以及现存的 RDDs。DataFrame API 包含Scala, Java, [Python](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/api/pyspark.sql.DataFrame.html#pyspark.sql.DataFrame), 和 [R](https://spark.apache.org/docs/latest/api/R/index.html)。在 Scala 和 Java 中，一个 DataFrame 由包含 `Row` 的 Dataset 表示。在 [Scala API](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html)，DataFrame 仅仅是 `Dataset[Row]` 的类型别名；在 [Java API](https://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html)，用户需要使用 `Dataset<Row>` 来表示一个 DataFrame。

贯穿本文档，我们将把 `Scala/Java` 包含 `Row` 的 `Datasets` 称之为 `DataFrames`。

## 1. 入门篇

### 1.1 入口: SparkSession

Spark 中所有功能的入口点是 [SparkSession](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/SparkSession.html) 类。为了创建一个简单 SparkSession，只需使用 `SparkSession.builder()`：

```
// Scala
import org.apache.spark.sql.SparkSession

val spark = SparkSession
  .builder()
  .appName("Spark SQL basic example")
  .config("spark.some.config.option", "some-value")
  .getOrCreate()
```

```
// Java
import org.apache.spark.sql.SparkSession;

SparkSession spark = SparkSession
  .builder()
  .appName("Java Spark SQL basic example")
  .config("spark.some.config.option", "some-value")
  .getOrCreate();
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。从 `Spark 2.0` 开始 SparkSession 提供了对 Hive 特性包括使用 HiveQL 编写查询访问 Hive UDFs 的能力的内建支持，也包括从 Hive 表读取数据的能力。为了使用这些特性，你并不需要拥有一个 Hive 安装。

### 1.2 创建 DataFrames

利用 SparkSession，应用可以从一个[已有的 RDD](https://spark.apache.org/docs/latest/sql-getting-started.html#interoperating-with-rdds)，一个 Hive 表，或者从 [Spark 数据源](https://spark.apache.org/docs/latest/sql-data-sources.html) 创建 DataFrames。

作为一个示例，下面的例子基于一个 JSON 文件的内容创建了一个 DataFrame。

```
// Scala
val df = spark.read.json("examples/src/main/resources/people.json")

// Displays the content of the DataFrame to stdout
df.show()
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

```
// Java
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

Dataset<Row> df = spark.read().json("examples/src/main/resources/people.json");

// Displays the content of the DataFrame to stdout
df.show();
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

### 1.3 无类型（Untyped）Dataset 操作 (即 DataFrame 操作)

DataFrames 提供领域专用语言用于在 [Scala](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html), [Java](https://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html), [Python](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/api/pyspark.sql.DataFrame.html) 及 [R](https://spark.apache.org/docs/latest/api/R/reference/SparkDataFrame.html) 语言中进行结构化数据的处理。

这里我们包括了使用 Datasets 进行结构化数据处理的基本示例。

```
// Scala
// This import is needed to use the $-notation
import spark.implicits._
// Print the schema in a tree format
df.printSchema()
// root
// |-- age: long (nullable = true)
// |-- name: string (nullable = true)

// Select only the "name" column
df.select("name").show()
// +-------+
// |   name|
// +-------+
// |Michael|
// |   Andy|
// | Justin|
// +-------+

// Select everybody, but increment the age by 1
df.select($"name", $"age" + 1).show()
// +-------+---------+
// |   name|(age + 1)|
// +-------+---------+
// |Michael|     null|
// |   Andy|       31|
// | Justin|       20|
// +-------+---------+

// Select people older than 21
df.filter($"age" > 21).show()
// +---+----+
// |age|name|
// +---+----+
// | 30|Andy|
// +---+----+

// Count people by age
df.groupBy("age").count().show()
// +----+-----+
// | age|count|
// +----+-----+
// |  19|    1|
// |null|    1|
// |  30|    1|
// +----+-----+
```

```
// Java
// col("...") is preferable to df.col("...")
import static org.apache.spark.sql.functions.col;

// Print the schema in a tree format
df.printSchema();
// root
// |-- age: long (nullable = true)
// |-- name: string (nullable = true)

// Select only the "name" column
df.select("name").show();
// +-------+
// |   name|
// +-------+
// |Michael|
// |   Andy|
// | Justin|
// +-------+

// Select everybody, but increment the age by 1
df.select(col("name"), col("age").plus(1)).show();
// +-------+---------+
// |   name|(age + 1)|
// +-------+---------+
// |Michael|     null|
// |   Andy|       31|
// | Justin|       20|
// +-------+---------+

// Select people older than 21
df.filter(col("age").gt(21)).show();
// +---+----+
// |age|name|
// +---+----+
// | 30|Andy|
// +---+----+

// Count people by age
df.groupBy("age").count().show();
// +----+-----+
// | age|count|
// +----+-----+
// |  19|    1|
// |null|    1|
// |  30|    1|
// +----+-----+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。关于在一个 Dataset 上可以执行的操作类型的完整列表，参见 [API 文档](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html)。

除了简单的列引用和表达式，Datasets 也有丰富的库函数，包括字符串操作，日期算法，常见算术操作及更多。完整列表可在 [DataFrame 函数参考](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/functions$.html)处见到。

### 1.4 编程运行 SQL 查询

SparkSession 的 `sql` 函数让应用可以通过编程的方式来运行 SQL 查询，并以 DataFrame 的形式返回结果。

```
// Scala
// Register the DataFrame as a SQL temporary view
df.createOrReplaceTempView("people")

val sqlDF = spark.sql("SELECT * FROM people")
sqlDF.show()
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

```
// Java
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

// Register the DataFrame as a SQL temporary view
df.createOrReplaceTempView("people");

Dataset<Row> sqlDF = spark.sql("SELECT * FROM people");
sqlDF.show();
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

### 1.5 全局临时视图

在 Spark SQL 中临时视图是会话范围的，当创建它的会话终止时它也会消失。如果你期待一个临时视图在所有会话间共享，并保持存活直至 Spark 应用终止，你可以创建一个全局临时视图。全局临时视图与一个系统保留数据库 `global_temp` 绑定，我们必须使用限定名来引用它，如 `SELECT * FROM global_temp.view1`。

```
// Scala
// Register the DataFrame as a global temporary view
df.createGlobalTempView("people")

// Global temporary view is tied to a system preserved database `global_temp`
spark.sql("SELECT * FROM global_temp.people").show()
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+

// Global temporary view is cross-session
spark.newSession().sql("SELECT * FROM global_temp.people").show()
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

```
// Java
// Register the DataFrame as a global temporary view
df.createGlobalTempView("people");

// Global temporary view is tied to a system preserved database `global_temp`
spark.sql("SELECT * FROM global_temp.people").show();
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+

// Global temporary view is cross-session
spark.newSession().sql("SELECT * FROM global_temp.people").show();
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

### 1.6 创建 Datasets

Datasets 与 RDD 很像，但是，代替 Java 序列化或 `Kryo` 序列化，它们使用一种特殊的 [Encoder](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Encoder.html) 来序列化对象以通过网络处理或传送。`encoders` 和标准序列化负责将一个对象转换为字节，`encoders` 是代码动态生成地，它使用一种格式，这种格式允许 Spark 执行许多操作如过滤，排序，哈希而无需将字节反序列化成对象。

```
// Scala
case class Person(name: String, age: Long)

// Encoders are created for case classes
val caseClassDS = Seq(Person("Andy", 32)).toDS()
caseClassDS.show()
// +----+---+
// |name|age|
// +----+---+
// |Andy| 32|
// +----+---+

// Encoders for most common types are automatically provided by importing spark.implicits._
val primitiveDS = Seq(1, 2, 3).toDS()
primitiveDS.map(_ + 1).collect() // Returns: Array(2, 3, 4)

// DataFrames can be converted to a Dataset by providing a class. Mapping will be done by name
val path = "examples/src/main/resources/people.json"
val peopleDS = spark.read.json(path).as[Person]
peopleDS.show()
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

```
// Java
import java.util.Arrays;
import java.util.Collections;
import java.io.Serializable;

import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.Encoder;
import org.apache.spark.sql.Encoders;

public static class Person implements Serializable {
  private String name;
  private long age;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public long getAge() {
    return age;
  }

  public void setAge(long age) {
    this.age = age;
  }
}

// Create an instance of a Bean class
Person person = new Person();
person.setName("Andy");
person.setAge(32);

// Encoders are created for Java beans
Encoder<Person> personEncoder = Encoders.bean(Person.class);
Dataset<Person> javaBeanDS = spark.createDataset(
  Collections.singletonList(person),
  personEncoder);
javaBeanDS.show();
// +---+----+
// |age|name|
// +---+----+
// | 32|Andy|
// +---+----+

// Encoders for most common types are provided in class Encoders
Encoder<Long> longEncoder = Encoders.LONG();
Dataset<Long> primitiveDS = spark.createDataset(Arrays.asList(1L, 2L, 3L), longEncoder);
Dataset<Long> transformedDS = primitiveDS.map(
    (MapFunction<Long, Long>) value -> value + 1L,
    longEncoder);
transformedDS.collect(); // Returns [2, 3, 4]

// DataFrames can be converted to a Dataset by providing a class. Mapping based on name
String path = "examples/src/main/resources/people.json";
Dataset<Person> peopleDS = spark.read().json(path).as(personEncoder);
peopleDS.show();
// +----+-------+
// | age|   name|
// +----+-------+
// |null|Michael|
// |  30|   Andy|
// |  19| Justin|
// +----+-------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

### 1.7 RDD 互操作

Spark SQL 支持两种方式将已有 RDDs 转换为 Datasets。第一种方法使用反射来推导包含特定类型对象 RDD 的模式。在你编写 Spark 应用已经知道模式时基于反射的方法可以产生更简洁的代码且工作得很好。

第二种创建 Datasets 的方法是通过编程接口允许你构造一个模式并将其应用到一个已有的 RDD 上。当然这种方式更冗长，但它可让你在列及其类型直到运行时仍未知时构造 Datasets。

#### 1.7.1 使用反射推导模式（Inferring the Schema Using Reflection）

Spark SQL 支持自动将一个 [JavaBeans](http://stackoverflow.com/questions/3295496/what-is-a-javabean-exactly) 的 `RDD` 转换为 `DataFrame`。使用反射获取到的 `BeanInfo` 定义了表的模式。当前，Spark SQL 不支持 `JavaBean` 包含 `Map` 字段，但支持嵌套 `JavaBeans`，以及 `List` 或 `Array` 字段。你可以通过创建一个实现了 Serializable，并对所有字段拥有设置器和获取器的类以创建 JavaBean。

```
// Scala
// For implicit conversions from RDDs to DataFrames
import spark.implicits._

// Create an RDD of Person objects from a text file, convert it to a Dataframe
val peopleDF = spark.sparkContext
  .textFile("examples/src/main/resources/people.txt")
  .map(_.split(","))
  .map(attributes => Person(attributes(0), attributes(1).trim.toInt))
  .toDF()
// Register the DataFrame as a temporary view
peopleDF.createOrReplaceTempView("people")

// SQL statements can be run by using the sql methods provided by Spark
val teenagersDF = spark.sql("SELECT name, age FROM people WHERE age BETWEEN 13 AND 19")

// The columns of a row in the result can be accessed by field index
teenagersDF.map(teenager => "Name: " + teenager(0)).show()
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+

// or by field name
teenagersDF.map(teenager => "Name: " + teenager.getAs[String]("name")).show()
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+

// No pre-defined encoders for Dataset[Map[K,V]], define explicitly
implicit val mapEncoder = org.apache.spark.sql.Encoders.kryo[Map[String, Any]]
// Primitive types and case classes can be also defined as
// implicit val stringIntMapEncoder: Encoder[Map[String, Any]] = ExpressionEncoder()

// row.getValuesMap[T] retrieves multiple columns at once into a Map[String, T]
teenagersDF.map(teenager => teenager.getValuesMap[Any](List("name", "age"))).collect()
// Array(Map("name" -> "Justin", "age" -> 19))
```

```
// Java
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.Encoder;
import org.apache.spark.sql.Encoders;

// Create an RDD of Person objects from a text file
JavaRDD<Person> peopleRDD = spark.read()
  .textFile("examples/src/main/resources/people.txt")
  .javaRDD()
  .map(line -> {
    String[] parts = line.split(",");
    Person person = new Person();
    person.setName(parts[0]);
    person.setAge(Integer.parseInt(parts[1].trim()));
    return person;
  });

// Apply a schema to an RDD of JavaBeans to get a DataFrame
Dataset<Row> peopleDF = spark.createDataFrame(peopleRDD, Person.class);
// Register the DataFrame as a temporary view
peopleDF.createOrReplaceTempView("people");

// SQL statements can be run by using the sql methods provided by spark
Dataset<Row> teenagersDF = spark.sql("SELECT name FROM people WHERE age BETWEEN 13 AND 19");

// The columns of a row in the result can be accessed by field index
Encoder<String> stringEncoder = Encoders.STRING();
Dataset<String> teenagerNamesByIndexDF = teenagersDF.map(
    (MapFunction<Row, String>) row -> "Name: " + row.getString(0),
    stringEncoder);
teenagerNamesByIndexDF.show();
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+

// or by field name
Dataset<String> teenagerNamesByFieldDF = teenagersDF.map(
    (MapFunction<Row, String>) row -> "Name: " + row.<String>getAs("name"),
    stringEncoder);
teenagerNamesByFieldDF.show();
// +------------+
// |       value|
// +------------+
// |Name: Justin|
// +------------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

#### 1.7.2 编程指定模式（Programmatically Specifying the Schema）

当 JavaBean 类不能事先定义（例如，记录的结构被编码为一个字符串，或一个文本数据集将被解析且对不同用户字段映射不同），通过编程一个 `Dataset<Row>` 可以通过以下三步创建。

1. 从原始 RDD 创建一个 Row 的 RDD
2. 创建一个由 StructType 表示的模式，它应该匹配第一步创建的 RDD 的 Row 的结构
3. 通过 SparkSession 的 createDataFrame 方法将模式运用到对应 Row 的 RDD 上。

```
// Scala
import org.apache.spark.sql.Row

import org.apache.spark.sql.types._

// Create an RDD
val peopleRDD = spark.sparkContext.textFile("examples/src/main/resources/people.txt")

// The schema is encoded in a string
val schemaString = "name age"

// Generate the schema based on the string of schema
val fields = schemaString.split(" ")
  .map(fieldName => StructField(fieldName, StringType, nullable = true))
val schema = StructType(fields)

// Convert records of the RDD (people) to Rows
val rowRDD = peopleRDD
  .map(_.split(","))
  .map(attributes => Row(attributes(0), attributes(1).trim))

// Apply the schema to the RDD
val peopleDF = spark.createDataFrame(rowRDD, schema)

// Creates a temporary view using the DataFrame
peopleDF.createOrReplaceTempView("people")

// SQL can be run over a temporary view created using DataFrames
val results = spark.sql("SELECT name FROM people")

// The results of SQL queries are DataFrames and support all the normal RDD operations
// The columns of a row in the result can be accessed by field index or by field name
results.map(attributes => "Name: " + attributes(0)).show()
// +-------------+
// |        value|
// +-------------+
// |Name: Michael|
// |   Name: Andy|
// | Name: Justin|
// +-------------+
```

```
// Java
import java.util.ArrayList;
import java.util.List;

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;

import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;

// Create an RDD
JavaRDD<String> peopleRDD = spark.sparkContext()
  .textFile("examples/src/main/resources/people.txt", 1)
  .toJavaRDD();

// The schema is encoded in a string
String schemaString = "name age";

// Generate the schema based on the string of schema
List<StructField> fields = new ArrayList<>();
for (String fieldName : schemaString.split(" ")) {
  StructField field = DataTypes.createStructField(fieldName, DataTypes.StringType, true);
  fields.add(field);
}
StructType schema = DataTypes.createStructType(fields);

// Convert records of the RDD (people) to Rows
JavaRDD<Row> rowRDD = peopleRDD.map((Function<String, Row>) record -> {
  String[] attributes = record.split(",");
  return RowFactory.create(attributes[0], attributes[1].trim());
});

// Apply the schema to the RDD
Dataset<Row> peopleDataFrame = spark.createDataFrame(rowRDD, schema);

// Creates a temporary view using the DataFrame
peopleDataFrame.createOrReplaceTempView("people");

// SQL can be run over a temporary view created using DataFrames
Dataset<Row> results = spark.sql("SELECT name FROM people");

// The results of SQL queries are DataFrames and support all the normal RDD operations
// The columns of a row in the result can be accessed by field index or by field name
Dataset<String> namesDS = results.map(
    (MapFunction<Row, String>) row -> "Name: " + row.getString(0),
    Encoders.STRING());
namesDS.show();
// +-------------+
// |        value|
// +-------------+
// |Name: Michael|
// |   Name: Andy|
// | Name: Justin|
// +-------------+
```

在 Spark 源码仓库你可以从 `"examples/src/main/scala/org/apache/spark/examples/sql/SparkSQLExample.scala"` 或 `"examples/src/main/java/org/apache/spark/examples/sql/JavaSparkSQLExample.java"` 找到完整示例代码。

### 1.8 标量函数（Scalar Functions）

标量函数是对每行返回一个单一值的函数，这与聚集函数相反，其对一组行数据返回一个值。Spark SQL 支持[内建标量函数](https://spark.apache.org/docs/latest/sql-ref-functions.html#scalar-functions)的一个变体，它也支持[用户自定义标量函数](https://spark.apache.org/docs/latest/sql-ref-functions-udf-scalar.html)。

### 1.9 聚集函数（Aggregate Functions）

聚集函数其对一组行数据返回一个值。[内建聚集函数](https://spark.apache.org/docs/latest/sql-ref-functions-builtin.html#aggregate-functions)提供了常见聚集功能如 `count()`, `count_distinct()`, `avg()`, `max()`, `min()`，等。用户无须局限于预定义聚集函数--用户可以创建自定义函数。关于用户自定义聚集函数的更多细节，请参见[用户自定义聚集函数](https://spark.apache.org/docs/latest/sql-ref-functions-udf-aggregate.html)的文档。

## 2. 数据源

Spark SQL 支持通过 DataFrame 接口操作多种多样的数据源。一个 DataFrame 可以通过关系转换操作，也可以用于创建一个临时视图。将一个 DataFrame 注册为临时视图允许你在其上运行 SQL 查询。本节描述使用了 Spark 数据源加载及存储数据的一般方法，然后介绍内建数据源的特殊选项。

### 2.1 通用加载/保存函数

在这个简单的代码里，默认数据源（`parquet`，除非通过 `spark.sql.sources.default` 配置）被用于所有操作。

```
val usersDF = spark.read.load("examples/src/main/resources/users.parquet")
usersDF.select("name", "favorite_color").write.save("namesAndFavColors.parquet")

// Java
Dataset<Row> usersDF = spark.read().load("examples/src/main/resources/users.parquet");
usersDF.select("name", "favorite_color").write().save("namesAndFavColors.parquet");
```

完整示例代码可在 Spark 仓库 "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" 找到。

#### 2.1.1 Manually Specifying Options

你可以手动指定数据源，你可以将其与其它选项一道传递给数据源。数据源由完整可靠名字指定（如 org.apache.spark.sql.parquet），但对于内建数据源，你可以使用它们的短名字（json, parquet, jdbc, orc, libsvm, csv, text）。从任意数据源类型加载的 DataFrames 可通过这种语法转换为其它类型。

请参考 API 文档以获取内建数据源的可用选项，例如，`org.apache.spark.sql.DataFrameReader` 和 `org.apache.spark.sql.DataFrameWrite`r。那里记录下的选项也适用于 non-Scala Spark APIs（例如，PySpark）。对其它格式，请参考特定格式的 API 文档。

为了加载 JSON 你可以使用：

```
val peopleDF = spark.read.format("json").load("examples/src/main/resources/people.json")
peopleDF.select("name", "age").write.format("parquet").save("namesAndAges.parquet")

// Java
Dataset<Row> peopleDF =  spark.read().format("json").load("examples/src/main/resources/people.json");
peopleDF.select("name", "age").write().format("parquet").save("namesAndAges.parquet");
```

完整示例代码可在 Spark 仓库 "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" 找到。

为了加载 CSV 你可以使用：

```
val peopleDFCsv = spark.read.format("csv")
  .option("sep", ";")
  .option("inferSchema", "true")
  .option("header", "true")
  .load("examples/src/main/resources/people.csv")

// Java
Dataset<Row> peopleDFCsv = spark.read().format("csv")
  .option("sep", ";")
  .option("inferSchema", "true")
  .option("header", "true")
  .load("examples/src/main/resources/people.csv");
```

其它选项在写操作时也使用。例如，你可以为 ORC 数据源控制布隆过滤器和字典编码。下面的 ORC 示例将创建布隆过滤器，并仅为 `favorite_color` 使用字典编码。对于 Parquet， 也有 `parquet.bloom.filter.enabled` 和 `parquet.enable.dictionary`。为了找到 ORC/Parquet 额外选项的更多信息，请访问官方 Apache [ORC](https://orc.apache.org/docs/spark-config.html)/[Parquet](https://github.com/apache/parquet-mr/tree/master/parquet-hadoop) 网站。

ORC 数据源：

```
usersDF.write.format("orc")
  .option("orc.bloom.filter.columns", "favorite_color")
  .option("orc.dictionary.key.threshold", "1.0")
  .option("orc.column.encoding.direct", "name")
  .save("users_with_options.orc")

// Java
usersDF.write().format("orc")
  .option("orc.bloom.filter.columns", "favorite_color")
  .option("orc.dictionary.key.threshold", "1.0")
  .option("orc.column.encoding.direct", "name")
  .save("users_with_options.orc");
```

完整示例代码可在 Spark 仓库 "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" 找到。

Parquet 数据源：

```
usersDF.write.format("parquet")
  .option("parquet.bloom.filter.enabled#favorite_color", "true")
  .option("parquet.bloom.filter.expected.ndv#favorite_color", "1000000")
  .option("parquet.enable.dictionary", "true")
  .option("parquet.page.write-checksum.enabled", "false")
  .save("users_with_options.parquet")

// Java
usersDF.write().format("parquet")
    .option("parquet.bloom.filter.enabled#favorite_color", "true")
    .option("parquet.bloom.filter.expected.ndv#favorite_color", "1000000")
    .option("parquet.enable.dictionary", "true")
    .option("parquet.page.write-checksum.enabled", "false")
    .save("users_with_options.parquet");
```

完整示例代码可在 Spark 仓库 "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" 找到。

#### 2.1.2 在文件上直接运行 SQL

你可以通过 SQL 直接查询文件而无需使用读 API 来将一个文件加载进 DataFrame 并查询它。

```
val sqlDF = spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`")

// Java
Dataset<Row> sqlDF =
  spark.sql("SELECT * FROM parquet.`examples/src/main/resources/users.parquet`");
```

#### 2.1.3 保存模式

保存操作可选地带有 `SaveMode` 参数，它指定了如何处理与有数据存在的场景。必须认识到这些模式并未使用任何锁机制，因此不是原子操作。另外，当执行一个 `Overwrite` 时，在写新数据之已有数据将被删除。

Scala/Java|任何语言|意义
--------|--------|--------
SaveMode.ErrorIfExists（默认）|"error" or "errorifexists"（默认）|当把 DataFrame 保存到数据源时，如果数据已经存在，一个异常将被抛出。
SaveMode.Append|"append"|当把 DataFrame 保存到数据源时，如果数据已经存在，DataFrame 的内容期待被追加到已有的数据里。
SaveMode.Overwrite|"overwrite"|Overwrite 模式意味着在把 DataFrame 保存到数据源时，如果数据已经存在，已有数据将被 DataFrame 内容覆盖。
SaveMode.Ignore|"ignore"|Ignore 模式意味着在把 DataFrame 保存到数据源时，如果数据已经存在，保存操作将不保存 DataFrame 的内容，已有数据不做任何改变。这就像 SQL 中的 `CREATE TABLE IF NOT EXISTS`。

#### 2.1.4 保存到持久表中

DataFrames 也可使用 `saveAsTable` 命令保存进 Hive metastore 中的持久表。注意使用这个特性并不需要一个已有的 Hive 部署。Spark 将为你创建一个默认本地 Hive metastore（使用 `Derby`）。不像 `createOrReplaceTempView` 命令，`saveAsTable` 将物化 DataFrame 的内容并创建一个指向 Hive metastore 里数据的指针。即使  Spark 应用重启之后持久表依然存在，只要你维持对同一 metastore 的连接。为持久表的 DataFrame 可以通过调用 SparkSession 的 `table` 方法并传递表名创建。

对基于文件的数据源，例如 `text`, `parquet`, `json`，等，你可以通过 `path` 选项指定自定义表路径，例如 `df.write.option("path", "/some/path").saveAsTable("t")`。当表被删除时，自定义表路径并未被删除，且数据仍在那里。如果未指定自定义表路径，Spark 将把数据写到 `warehouse` 目录下的一个默认表路径。当表被删除时，默认表路径也将被删除。

从 `Spark 2.1` 开始，持久数据源存储拥有存储于 Hive metastore 的每分区元数据。这带来几个收益：

- 由于元数据仅仅返回查询所需必要的分区，对表的首次查询发现所有分区不再必要。
- Hive DDLs 如 `ALTER TABLE PARTITION ... SET LOCATION` 现在对于 Datasource API 创建的表可用。

注意在创建外部数据表（带有路径选项）时分区信息默认并未收集。为了在 `metastore` 中同步分区信息，你可以调用 `MSCK REPAIR TABLE`。

#### 2.1.5 桶，排序和分区（Bucketing, Sorting and Partitioning）

对基于文件的数据源，它也可能桶存储，并排序或分区输出。桶存储和排序仅对持久表可用。

```
peopleDF.write.bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed")

// Java
peopleDF.write().bucketBy(42, "name").sortBy("age").saveAsTable("people_bucketed");
```

当使用 `Dataset APIs` 时，分区可被用于 `save` 和 `saveAsTable`。

```
sersDF.write.partitionBy("favorite_color").format("parquet").save("namesPartByColor.parquet")

// Java
usersDF
  .write()
  .partitionBy("favorite_color")
  .format("parquet")
  .save("namesPartByColor.parquet");
```

对一个简单表，可以同时使用分区和桶存储。

```
usersDF
  .write
  .partitionBy("favorite_color")
  .bucketBy(42, "name")
  .saveAsTable("users_partitioned_bucketed")

// Java
usersDF
  .write()
  .partitionBy("favorite_color")
  .bucketBy(42, "name")
  .saveAsTable("users_partitioned_bucketed");
```

完整示例代码可在 Spark 仓库 "examples/src/main/java/org/apache/spark/examples/sql/JavaSQLDataSourceExample.java" 找到。

`partitionBy` 创建了一个在 [Partition Discovery](https://spark.apache.org/docs/latest/sql-data-sources-parquet.html#partition-discovery) 一节描述的目录结构。因此，它对拥有很多基数的列作用有限。相对而言，`bucketBy` 将数据分配至固定数量的桶中，它可用于部同值较多的列。

### 2.2 通用文件数据源选项（Generic File Source Options）

这些通用选项/配置只有在使用基于文件的数据源时才有效：parquet, orc, avro, json, csv, text。

请注意实例中使用的目录层级如下所示：

```
dir1/
 ├── dir2/
 │    └── file2.parquet (schema: <file: string>, content: "file2.parquet")
 └── file1.parquet (schema: <file, string>, content: "file1.parquet")
 └── file3.json (schema: <file, string>, content: "{'file':'corrupt.json'}")
```

#### 2.2.1 忽略损坏的文件（Ignore Corrupt Files）
#### 2.2.2 忽略缺失的文件（Ignore Missing Files）
#### 2.2.3 路径全局过滤器（Path Global Filter）
#### 2.2.4 递归文件查找（Recursive File Lookup）

### 2.3 Parquet 文件

#### 2.3.1 Loading Data Programmatically

#### 2.3.2 Partition Discovery

#### 2.3.3 Schema Merging

#### 2.3.4 Hive metastore Parquet table conversion

#### 2.3.5 Configuration

### 2.4 ORC 文件

### 2.5 JSON 文件

### 2.6 CSV 文件

### 2.7 Text 文件

### 2.8 Hive 表

#### 2.8.1 Specifying storage format for Hive tables

#### 2.8.2 Interacting with Different Versions of Hive Metastore

### 2.9 JDBC To Other Databases

### 2.10 Avro 文件

#### 2.10.1 Deploying
#### 2.10.2 Load and Save Functions
#### 2.10.3 to_avro() and from_avro()
#### 2.10.4 Data Source Option
#### 2.10.5 Configuration
#### 2.10.6 Compatibility with Databricks spark-avro
#### 2.10.7 Supported types for Avro -> Spark SQL conversion
#### 2.10.8 Supported types for Spark SQL -> Avro conversion

### 2.11 Protobuf 数据

#### 2.11.1 Deploying
#### 2.11.2 to_protobuf() and from_protobuf()
#### 2.11.3 Supported types for Protobuf -> Spark SQL conversion
#### 2.11.4 Supported types for Spark SQL -> Protobuf conversion
#### 2.11.5 Handling circular references protobuf fields

### 2.12 整体二进制文件（Whole Binary Files）
### 2.13 问题定位（Troubleshooting）

## 3. 性能调优
## 4. 分布式 SQL 引擎
## 5. 基于带 Apache Arrow 的 Pandas PySpark使用指南（PySpark Usage Guide for Pandas with Apache Arrow）
## 6. 迁移指南
## 7. SQL 参考

Spark SQL 是 Apache Spark 的结构化数据工作模块。这本指南是结构化查询语言（SQL）参考，包括语法，语义，关键字以及常用 SQL 使用示例。它包括如下主题的信息：

### 7.1 ANSI 兼容性（ANSI Compliance）
### 7.2 数据类型
### 7.3 Datetime 模式
### 7.4 Number 模式
### 7.5 函数
#### 7.5.1 内建函数（Built-in Functions）
#### 7.5.2 用户定义标量函数
#### 7.5.3 用户定义聚集函数
#### 7.5.4 与 Hive UDFs/UDAFs/UDTFs 集成
### 7.6 标识符
### 7.7 字面量
### 7.8 Null 语义
### 7.9 SQL 语法
#### 7.9.1 DDL 语句
#### 7.9.2 DML 语句
#### 7.9.3 数据检索语句
#### 7.9.4 Auxiliary Statements

## 8. 错误条件（Error Conditions）

## Reference 

- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [Java Dataset<T>](https://spark.apache.org/docs/latest/api/java/index.html?org/apache/spark/sql/Dataset.html)
- [Scala Dataset](https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/Dataset.html)
- [Dataframe and dataset](https://learning.oreilly.com/library/view/apache-spark-2-x/9781787126497/a8284e5f-1db5-49d2-971e-67126c51160e.xhtml)