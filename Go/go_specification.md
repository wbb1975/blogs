# Go语言规范
## 简介
这是一份有关Go编程语言的参考手册，如需更多信息或其它文档，请参阅[Go主页](https://golang.google.cn/)。

Go是一门从设计初衷就是用于系统编程的通用性语言。它是强类型语言，支持垃圾收集，对并行编程有显式支持。程序由包构建--包的属性允许有效的依赖管理。

Go程序紧凑，简单易于解析，可被自动化工具如IDE简单地分析。
## 表示法
语法使用扩展巴科斯-纳尔形式（EBNF）来指定：
```
Production  = production_name "=" [ Expression ] "." .
Expression  = Alternative { "|" Alternative } .
Alternative = Term { Term } .
Term        = production_name | token [ "…" token ] | Group | Option | Repetition .
Group       = "(" Expression ")" .
Option      = "[" Expression "]" .
Repetition  = "{" Expression "}" .
```
语句（Productions ）是从单词（term）和以下优先级递增的操作符（operators）构造的表达式（expression）：
```
|   alternation
()  grouping
[]  option (0 or 1 times)
{}  repetition (0 to n times)
```
小写语句名（Productions ）用于识别词汇标记（lexical tokens）；非词汇（Non-terminals）采用驼峰格式；词汇标记用双引号（double quotes ""）或反引号（back quotes ``）括起来。

a … b的记法代表从a至b的字符集合的一个替代，省略号…（horizontal ellipsis …）在本规范中也用于指代各种迭代和不须详细指定的代码片段。字符…（与三个字符的 ...相反）在Go语言中不是一个标记。 
## 源代码呈现
### 字符（Characters）
### 字母和数字（Letters and digits）

## Reference
- [The Go Programming Language Specification](https://golang.google.cn/ref/spec#Exported_identifiers)