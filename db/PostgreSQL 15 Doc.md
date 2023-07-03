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

索引是一中提升数据库性能的常用方法。一个索引允许数据库服务器比没有索引时能够更快速地找到并检索特定行。但是索引也增加了数据库系统的整体负载，索引他们应该被聪明地使用。

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

没有任何提前准备的话，系统将逐行扫描整个 test1 表查找所有匹配的记录。如果 test1 中有很多数据行，但这个查询本身只返回有限数据行（零条或一条），很明显这是一个效率低下的方法。但如果系统被指导在 id 列上维护一条索引，它可以使用一种更高效的方法类定位匹配的数据行。例如，它可能只需要在查找树上迭代有限深度。

类似的方法常用于大部分非小说类书籍：名词和概念时读者经常查询的，它们常被以字典序索引形式手机在书籍末尾。感兴趣的读者可以相对快速地扫描索引并跳到期待页面，而不需要通读整本书以找到自己刚兴趣的材料。就像作者预测读者会查找拿些项这个工作一样，数据库程序员的工作就是预测那些索引将被使用。

```
SELECT content FROM test1 WHERE id = constant;
```

```
SELECT content FROM test1 WHERE id = constant;
```

#### 11.2. 索引类型
11.2.1. B-Tree
11.2.2. Hash
11.2.3. GiST
11.2.4. SP-GiST
11.2.5. GIN
11.2.6. BRIN
#### 11.3. 多列索引（Multicolumn Indexes）
#### 11.4. 索引和 ORDER BY
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