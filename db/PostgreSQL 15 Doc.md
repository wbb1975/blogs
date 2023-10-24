# PostgreSQL 15.3 Documentation
**The PostgreSQL Global Development Group**

## Preface
1. What Is PostgreSQL?
2. A Brief History of PostgreSQL
3. Conventions
4. Further Information
5. Bug Reporting Guidelines
## I. Tutorial
1. Getting Started
2. The SQL Language
3. Advanced Features
## II. The SQL Language
### 4. SQL Syntax
### 5. Data Definition
### 6. Data Manipulation
### 7. Queries
### 8. Data Types
### 9. Functions and Operators
### 10. Type Conversion

### 11. 索引

索引是一种提升数据库性能的常用方法。一个索引允许数据库服务器比没有索引时能够更快速地找到并检索特定行。但是索引也增加了数据库系统的整体负载，因此索引应该被聪明地使用。

#### 11.1. 介绍

假设我们有一个如下的表：

```
CREATE TABLE test1 (
    id integer,
    content varchar
);
```

应用发布了许多如下的查询：

```
SELECT content FROM test1 WHERE id = constant;
```

没有任何提前准备的话，系统将逐行扫描整个 `test1` 表查找所有匹配的记录。如果 `test1` 中有很多数据行，但这个查询本身只返回有限数据行（零条或一条），很明显这是一个效率低下的方法。但如果指导系统被在 `id` 列上维护一条索引，它可以使用一种更高效的方法来定位匹配的数据行。例如，它可能只需要在查找树上迭代有限深度。

类似的方法常用于大部分非小说类书籍：名词和概念是读者经常查询的，它们常被以字典序索引形式收集在书籍末尾。感兴趣的读者可以相对快速地扫描索引并跳到期待页面，而不需要通读整本书以找到自己刚兴趣的材料。就像作者预测读者会查找哪些项这个工作一样，数据库程序员的工作就是预测哪些索引将被使用。

就像我们刚讨论的那样，下面的命令可以用于在 `id` 列上创建一个索引：

```
CREATE INDEX test1_id_index ON test1 (id);
```

名字 `test1_id_index` 可以自由选择，但这个名字应该携带一些信息可以帮助你记起这个索引的背景。

为了删除索引，使用 `DROP INDEX` 命令。索引可以随时向表中添加或从表中移除。

索引一旦被创建，并不需要再介入：当表被修改时系统会更新索引；查询时如果它认为利用索引比顺序表扫描更高效，那么索引就会被使用。但你可能需要定期运行 `ANALYZE` 命令更新统计信息，如此查询计划器才能够做出聪明的决策。查阅[１４章](https://www.postgresql.org/docs/current/performance-tips.html)可以了解如何检查一个索引是否被使用，何时以及为何计划器将选择不使用索引的一些信息。

索引也对带查询条件的 `UPDATE` 和 `DELETE` 有利。索引也可用于连接（`join`）查询。因此，在一个列上定义的索引，如果列是连接条件的一部分，那么它就可以极大地加快连接查询。

在一个大表上创建索引可能需要花费很长时间。默认情况下 PostgreSQL 允许再一个表上的读操作（`SELECT` 语句）与索引创建并行进行，但是写操作（`INSERT`, `UPDATE`, `DELETE`）将被堵塞直至索引创建完成。在产品环境中这经常是不可接受的。允许写操作与索引创建并行运行是可能的，但需要意识到这里有几个陷阱－－更多信息，请参见[并行构建索引](https://www.postgresql.org/docs/current/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY)。

一个索引被创建后，系统必须保证它与表的同步。这增加了数据修改操作的负担。索引也可阻止[堆上元组](https://www.postgresql.org/docs/current/storage-hot.html)的创建。因此，很少使用或根本不用的索引应该被删除掉。

#### 11.2. 索引类型

PostgreSQL 提供了几种索引类型：`B-tree`, `Hash`, `GiST`, `SP-GiST`, `GIN`, `BRIN`, 以及扩展[布隆](https://www.postgresql.org/docs/current/bloom.html)索引。每种索引使用不同的算法，该种算法将最适用于某种特定查询。默认地，[CREATE INDEX](https://www.postgresql.org/docs/current/sql-createindex.html) 将创建 `B-tree` 索引，它适用于大多数常见情况。通过写下关键字 `USING` 及其跟随的索引类型名可以选择其它索引类型。例如，为了创建一个 `Hash` 索引：

```
CREATE INDEX name ON table USING HASH (column);
```

11.2.1. B-Tree

B-trees 能够处理可依据某种顺序排序的数据的相等和范围查询。特别地，在一个索引列涉及如下操作符的比较操作时，PostgreSQL 查询计划器将会考虑使用    B-tree 索引。

```
<   <=   =   >=   >
```

也有一些与上面操作符相等的构造，比如 `BETWEEN` 和 `IN`, 也可能用一个 B-tree 索引搜索来实现。同理，一个在索引列上的 `IS NULL` 或 `IS NOT NULL` 也可用作 B-tree 索引。

优化器也可将 B-tree 索引用于设计模式匹配操作符如 `LIKE` 和 `~` 的查询，只要模式是个常量并且锚定于字符串的开始位置--例如 `col LIKE 'foo%'` 或 `col ~ '^foo'`, 但不能是 `col LIKE '%bar'`。但是，如果你的数据库没有使用 `C locale`，你将需要利用特殊的操作符类来创建索引以支持模式匹配查询的索引，可参阅下面的[11.10 节](https://www.postgresql.org/docs/current/indexes-opclass.html)。将 B-tree 用于 `ILIKE` 和 `~*` 也是可能的，但只有模式不是以字母字符开始的才可以，例如，字符应该不受大小写转换影响。

B-tree 索引也可更具排序顺序检索数据。它并不总是比一个简单扫描并排序更快，但它通常是有用的。

11.2.2. Hash

哈希索引存储有来自索引列的值32位哈希值。因此，此类索引仅能处理相等比较操作符。当一个索引列涉及到一个等于操作符的比较时，查询计划器将会考虑使用一个哈希索引。

```
=
```

11.2.3. GiST

GiST 不是一个简单的索引类别，而是一套许多不同的索引策略能够实现的基础设施。相应地，GiST 索引能够使用的特定操作符随索引策略（操作符类）变化很大。例如，标准 PostgreSQL 发布为多个二位地理信息数据类型包括了 GiST 操作符类，它们支持使用如下操作符的索引查询。

```
<<   &<   &>   >>   <<|   &<|   |&>   |>>   @>   <@   ~=   &&
```

（[参考章节 9.11](https://www.postgresql.org/docs/current/functions-geometry.html) 以获取这些操作符的意义）包含在标准发布中的 GiST 操作符类在[表 68.1](https://www.postgresql.org/docs/current/gist-builtin-opclasses.html#GIST-BUILTIN-OPCLASSES-TABLE)里进行了讲解。许多其它 GiST 操作符类在 `contrib` 聚合或者单独项目里。更多信息，请参见[章节 68](https://www.postgresql.org/docs/current/gist.html)。

GiST 索引也能够优化“最近邻里”查询，例如：

```
SELECT * FROM places ORDER BY location <-> point '(101,456)' LIMIT 10;
```

它找到里给定目标点最近的十个地方。实现这个的能力再一次依赖于被使用的特定操作符类。在[表 68.1](https://www.postgresql.org/docs/current/gist-builtin-opclasses.html#GIST-BUILTIN-OPCLASSES-TABLE)，能够通过这种方式使用的操作符在 “排序操作符” 列里给出。

11.2.4. SP-GiST

SP-GiST 索引，就像 GiST 索引，提供支持各种类型检索的基础设施。SP-GiST 允许实现更广范围的不同的非平衡基于磁盘的数据结构，例如 `quadtrees`，`k-d trees`，和 `radix trees (tries)`。作为一个例子，PostgreSQL 标准发布包含了二位点的 SP-GiST 操作符类，它支持如下操作符的索引查询：

```
<<   >>   ~=   <@   <<|   |>>
```

（[参考章节 9.11](https://www.postgresql.org/docs/current/functions-geometry.html) 以获取这些操作符的意义）标准发布中的 SP-GiST 操作符类在[表 68.1](https://www.postgresql.org/docs/current/gist-builtin-opclasses.html#GIST-BUILTIN-OPCLASSES-TABLE)里进行了讲解。更多信息，请参见[章节 69](https://www.postgresql.org/docs/current/spgist.html)。

和 GiST 一样，SP-GiST 支持“最近邻里”查询。对于支持按距离排序的 SP-GiST 操作符类，对应的操作符在[表 69.1](https://www.postgresql.org/docs/current/spgist-builtin-opclasses.html#SPGIST-BUILTIN-OPCLASSES-TABLE) 中的 “排序操作符” 列里给出。

11.2.5. GIN

GIN 属于倒排序索引，它适用于包含多个组件值的数据值，例如数组。倒排序索引为每个组件包含一个单独的入口，可以高效处理类似这样的查询，即检测特定组件值的存在。

就像 GiST 和 SP-GiST, GIN 能够支持不同的用户定义的索引策略，一个 GIN 索引能够被使用的特定操作符依赖于索引策略而变化很大。一个例子，标准PostgreSQL 发布中一个用于数组的 GIN 操作符类，它支持使用如下操作符的索引查询：

```
<@   @>   =   &&
```

（[参考章节 9.19](https://www.postgresql.org/docs/current/functions-array.html) 以获取这些操作符的意义）标准发布中的 GIN 操作符类在[表 70.1](https://www.postgresql.org/docs/current/gin-builtin-opclasses.html#GIN-BUILTIN-OPCLASSES-TABLE)里进行了讲解。更多信息，请参见[章节 70](https://www.postgresql.org/docs/current/gin.html)。

11.2.6. BRIN

BRIN（块范围索引简写）索引存储了位于一个表的顺序物理块范围内的值的总结信息。因此，如果列值与表中的数据行的物理顺序有很好的相关性，BRIN 索引是很高效的。如同 GiST, SP-GiST 和 GIN，BRIN 能够支持不同的索引策略，而且能够被使用的特定操作符依赖于索引策略而变化很大。对于拥有线性排序顺序的数据类型，索引数据对应着每个块范围内列值的最小最大值。它支持使用如下操作符的索引查询：

```
<   <=   =   >=   >
```

标准发布中的 BRIN 操作符类在[表 71.1](https://www.postgresql.org/docs/current/brin-builtin-opclasses.html#BRIN-BUILTIN-OPCLASSES-TABLE)里进行了讲解。更多信息，请参见[章节 71](https://www.postgresql.org/docs/current/brin.html)。

#### 11.3. 多列索引（Multicolumn Indexes）

一个索引可以定义在一个表的多个列上。例如，你有一个如下模式的表：

```
CREATE TABLE test2 (
  major int,
  minor int,
  name varchar
);
```

（假如，你在一个数据库中存放 `/dev` 目录），而且你经常发布如下查询：

```
SELECT name FROM test2 WHERE major = constant AND minor = constant;
```

那么就适合在列 `major` 和 `minor` 一起定义一个索引，例如：

```
CREATE INDEX test2_mm_idx ON test2 (major, minor);
```

当前，**只有 `B-tree`, `GiST`, `GIN`, 和 `BRIN` 索引类型**支持多列索引。是否能够拥有多列与包含列是否能够被加进索引不相关。索引最多可以拥有 32 列，包括`INCLUDE` 列（这个限制可以在构建 PostgreSQL 时修改，参见文件 `pg_config_manual.h`）。

一个多列 B-tree 索引能够用于查询条件涉及索引列的任一子集的情况，但索引在引用索引最左边列的约束最高效。准确的规则是最左边列上的相等约束，加上首列的不相等约束--它没有相等性约束，可被用于限制扫描索引的大小。直至最右边列的约束被索引检查，因此它能够减少表扫描的时间，但不能减少必须扫描的索引的数量。例如，给定一个在 `(a, b, c)` 上的索引，一个查询条件为 `WHERE a = 5 AND b >= 42 AND c < 77`, 索引将不得不从 `a = 5 and b = 42` 的第一条条目直至 `a = 5` 的最后一条。满足 `c >= 77` 的索引条目将被跳过，但它们不得不被扫描（过滤过）。索引原则上可用于在 `b 和/或 c` 上有限制但 `a`` 没限制的查询--但所有的索引不得不被扫描。因此在大多数情况下，计划器将倾向于序列表扫描而非利用索引。

一个多列 GiST 索引可被用于查询条件涉及索引列的任一子集的情况。额外列上的条件限制了通过索引返回的的条目，但首列上的条件对决定扫描的索引量是最重要的。对于一个 GiST 索引，如果其首列仅拥有少量不同值时相对低效，即使在额外列上拥有许多不同的值。

一个多列 GIN 索引可被用于查询条件涉及索引列的任一子集的情况。不像 `B-tree` 或 `GiST`无论查询条件使用哪个索引列，索引检索有效性都一样。

一个多列 BRIN 索引可被用于查询条件涉及索引列的任一子集的情况。像 `GIN` 而不像 `B-tree` 或 `GiST`无论查询条件使用哪个索引列，索引检索有效性都一样。在一个表上拥有多个 `BRIN` 索引而非一个多列 `BRIN` 索引的唯一原因在于拥有不同的 `pages_per_range` 存储参数。

当然，每个列必须使用匹配索引的操作符，涉及其它操作符的子句不会被考虑。

多列索引应该被适度使用。在大多数情况下，单个列上的索引是足够的，且节省时间和空间。多于三个列的索引不可能有帮助，除非表的使用是非常程式化的。参见[章节 11.5](https://www.postgresql.org/docs/current/indexes-bitmap-scans.html)和[章节 11.9](https://www.postgresql.org/docs/current/indexes-index-only-scans.html)以获取关于不同索引配置优点的讨论。

#### 11.4. 索引和 ORDER BY

除了在一个查询中简单地找到返回的行，索引能够以一个特定排序顺序返回数据。这允许查询的 `ORDER BY` 需求无需一个单独的排序步骤也能实现。

#### 11.5. 绑定多个索引（Combining Multiple Indexes）
#### 11.6. 唯一索引（Unique Indexes）
#### 11.7. 表达式上的索引（Indexes on Expressions）
#### 11.8. 部分索引（Partial Indexes）
#### 11.9. Index-Only Scans and Covering Indexes
#### 11.10. Operator Classes and Operator Families
#### 11.11. Indexes and Collations
#### 11.12. 检查索引使用（Examining Index Usage）
### 12. Full Text Search
### 13. Concurrency Control
### 14. Performance Tips
### 15. Parallel Query
## III. Server Administration
1.  Installation from Binaries
2.  Installation from Source Code
3.  Installation from Source Code on Windows
4.  Server Setup and Operation
5.  Server Configuration
6.  Client Authentication
7.  Database Roles
8.  Managing Databases
9.  Localization
10. Routine Database Maintenance Tasks
11. Backup and Restore
12. High Availability, Load Balancing, and Replication
13. Monitoring Database Activity
14. Monitoring Disk Usage
15. Reliability and the Write-Ahead Log
16. Logical Replication
17. Just-in-Time Compilation (JIT)
18. Regression Tests
## IV. Client Interfaces
1.  libpq — C Library
2.  Large Objects
3.  ECPG — Embedded SQL in C
4.  The Information Schema
## V. Server Programming
1.  Extending SQL
2.  Triggers
3.  Event Triggers
4.  The Rule System
5.  Procedural Languages
6.  PL/pgSQL — SQL Procedural Language
7.  PL/Tcl — Tcl Procedural Language
8.  PL/Perl — Perl Procedural Language
9.  PL/Python — Python Procedural Language
10. Server Programming Interface
11. Background Worker Processes
12. Logical Decoding
13. Replication Progress Tracking
14. Archive Modules
## VI. Reference
## I. SQL Commands
## II. PostgreSQL Client Applications
## III. PostgreSQL Server Applications
## VII. Internals
1.  Overview of PostgreSQL Internals
2.  System Catalogs
3.  System Views
4.  Frontend/Backend Protocol
5.  PostgreSQL Coding Conventions
6.  Native Language Support
7.  Writing a Procedural Language Handler
8.  Writing a Foreign Data Wrapper
9.  Writing a Table Sampling Method
10. Writing a Custom Scan Provider
11. Genetic Query Optimizer
12. Table Access Method Interface Definition
13. Index Access Method Interface Definition
14. Generic WAL Records
15. Custom WAL Resource Managers
16. B-Tree Indexes
17. GiST Indexes
18. SP-GiST Indexes
19. GIN Indexes
20. BRIN Indexes
21. Hash Indexes
22. Database Physical Storage
23. System Catalog Declarations and Initial Contents
24. How the Planner Uses Statistics
25. Backup Manifest Format
## VIII. Appendixes
A. PostgreSQL Error Codes
B. Date/Time Support
C. SQL Key Words
D. SQL Conformance
E. Release Notes
F. Additional Supplied Modules
G. Additional Supplied Programs
H. External Projects
I. The Source Code Repository
J. Documentation
K. PostgreSQL Limits
L. Acronyms
M. Glossary
N. Color Support
O. Obsolete or Renamed Features

## Reference

- [PostgreSQL 15.3 Documentation](https://www.postgresql.org/docs/current/index.html)
- [Index Columns for `LIKE` in PostgreSQL](https://niallburkley.com/blog/index-columns-for-like-in-postgres/)
- [POSTGRESQL: MORE PERFORMANCE FOR LIKE AND ILIKE STATEMENTS](https://www.cybertec-postgresql.com/en/postgresql-more-performance-for-like-and-ilike-statements/)