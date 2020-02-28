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
## 源代码表示
源代码是UTF-8编码的Unicode文本。文本并未规范化，因此一个单独的单重音码点与由一个重音和一个字母组合而成的同一个字符是完全不同的；它们被认为是两个码点。为了简化，本文中将使用不合格的术语“字符”（character）来指代源代码文本中的码点。

每个码点都是不同的，例如，大小和小写字母是不同的字符。

实现限制：为了与其它工具兼容，一个编译器可能在源代码文本中禁用NUL字符（U+0000）。

实现限制：为了与其它工具兼容，一个编译器可能忽略UTF-8的编码字节序标识 (U+FEFF)--如果它在源代码文本中为第一个码点。源代码中其它位置的字节序标识不被允许。
### 字符（Characters）
下面的标记用于指代特定的Unicode字符类：
```
newline        = /* the Unicode code point U+000A */ .
unicode_char   = /* an arbitrary Unicode code point except newline */ .
unicode_letter = /* a Unicode code point classified as "Letter" */ .
unicode_digit  = /* a Unicode code point classified as "Number, decimal digit" */ .
```
在[Unicode标准8.0](https://www.unicode.org/versions/Unicode8.0.0/)第4.5“通用分类”节定义了一套字符类别。Go把Lu, Ll, Lt, Lm, or Lo等字母类别中的所有字符当做Unicode字母，把数字类别 Nd中的所有字符当做Unicode数字。
### 字母和数字（Letters and digits）
下划线_ (U+005F)也被认为是一个字母：
 ```
letter        = unicode_letter | "_" .
decimal_digit = "0" … "9" .
binary_digit  = "0" | "1" .
octal_digit   = "0" … "7" .
hex_digit     = "0" … "9" | "A" … "F" | "a" … "f" .
 ```
## 语汇元素
### 注释
### 标记
### 分号
### 标识符
### 关键字
### 操作符和标点（Operators and punctuation）
### 整形字面量
### 浮点数字面量
### 复数字面量
### 字符字面量（Rune literals）
### 字符串字面量
## 常量
## 变量
## 类型
### 方法集
### 布尔类型
### 数字类型
### 字符串类型
### 数组类型
### 切片类型
### 结构体类型
### 指针类型
### 函数类型（Function types）
### 接口类型
### 映射类型
### 通道类型
## 类型和值的属性
### 类型识别符
### 可赋值性（Assignability）
### 表示行（Representability）
## 块
## 声明和作用范围
### 标签作用范围
### 空标识符
### 预定义标识符
### 导出标识符
### 标识符唯一性
### 一致性声明
### iota
### 类型声明
### 变量声明
### 短变量声明
### 函数声明（Function declarations）
### 方法声明（Method declarations）
## 表达式
### 操作码
### 合格标识符
### 合成字面量（Composite literals）
### 函数字面量
### 主表达式
### 选择器（selectors）
### 方法表达式
### 方法值
## 语句
## 内建函数
## 包
### 源文件组织
### 包条文（Package clause）
### 导入声明
### 一个包样例
## 程序初始化和执行
### 零值
### 包初始化
### 程序执行
## 错误（处理）
## 运行时异常（Run-time panics）
## 系统考量
### unsafe包
### 大小和对齐保证

## Reference
- [The Go Programming Language Specification](https://golang.google.cn/ref/spec#Exported_identifiers)