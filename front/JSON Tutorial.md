# JSON 教程
## 一 什么是 JSON
JSON (JavaScript Object Notation) 是网站数据交换使用最广泛的数据格式。数据交换可能发生在位于不同地区的或同一机器的两个不同应用之间。

好消息是 JSON 是一种易于人阅读机器也易于阅读的格式。因此应用/库可以解析 JSON 文档--人也可以查看数据并了解其含义。

所有现代编程语言（如 `Java`, `JavaScript`, `Ruby`, `C#`, `PHP`, `Python`, 和 `Groovy`）和应用平台产生（序列化）和消费（反序列化）JSON 数据提供了优秀的支持。
### 1. JSON 规范
`Douglas Crockford` 最早于 2001 年创建了 JSON，而后于 `2006` 年通过 `IETF` 在 [RFC 4627](https://www.ietf.org/rfc/rfc4627.txt)下首次标准化。`2013` Ecma 国际也在 [ECMA 404](https://www.ecma-international.org/publications/standards/Ecma-404.htm) 下标准化了 JSON。

新的规范移除了于其它 JSON 规范的不一致之处，修正了一些规范里的错误，提供了基于经验的互操作指南。
### 2. JSON 文件和 MIME 类型
在文件系统里存储 JSON 文档的标准文件类型是 `.json`。

JSON 的 Internet Assigned Numbers Authority (IANA) 媒体类型是 [application/json](https://www.iana.org/assignments/media-types/application/json)。
### 3. JSON 文档
一个 JSON 文档可能含有文本，大括号，中括号，分毫，逗号，双引号，可能还有一些其它字符。

基本上，一个有效的 JSON 文档包含两个部分：
1. 一个大括号包裹的一个对象，包含多个名称/值对。不同的语言中，它被实现为纪录（record），结构（struct），字典（dictionary），哈希表（hash table），有键列表（keyed list），或者关联数组 （associative array）。
2. 一个由中括号包裹的值的有序列表（An ordered list of values）或者数组。在大部分语言中，它被实现为 vector, list, 或 sequence.。
### 4. JSON 示例
一个 JSON 文档示例：
```
//JSON Object
{
    "employee": {
        "id": 1,
        "name": "Admin",
        "location": "USA"
    }
}
//JSON Array
{
    "employees": [
        {
            "id": 1,
            "name": "Admin",
            "location": "India"
        },
        {
            "id": 2,
            "name": "Author",
            "location": "USA"
        },
        {
            "id": 3,
            "name": "Visitor",
            "location": "USA"
        }
    ]
}
```
正如我们能够看到的，JSON 文档还有名称/值对。这些名称/值对反应了数据的结构。
### 5. 学习 JSON
在这个 JSON 教程中，我们将会学到 JSON 的各种概念以及示例：
- JSON 与 XML 的不同
- JSON 语法与文档类型
- 如何读 JSON 文档
- 如何写 JSON 文档
- 将 JSON 转换为字符串以及字符串转换为 JSON 等
## 二 JSON 语法
一个 JSON 文档可以包含由下列分隔符或记号分割的信息：
+ ":" 用于分割名称与值
+ "," 用于分割名称与值对
+ "{" 和 "}" 用于对象
+ "[" 和 "]" 用于数组
### 1. JSON 名称-值对示例
名称-值对在它们之间由一个冒号：`"name" : "value"`。

JSON 名称在冒号左边，它们需要用于用冒号包裹，如 `"name"`，它可以是任何有效的字符串。在每个对象内部，每个键必须是唯一的。

JSON 值位于冒号右边。在细粒度上，它们需要是以下6种数据类型中的一种：
- 字符串
- 数字
- 对象
- 数组
- boolean
- null 或 empty

每个名称-值对由逗号分隔，因此 JSON 看起来像这样：
```
"name" : "value", "name" : "value", "name": "value"
```
例如：
```
{
    "color" : "Purple",
    "id" : "210"
}
```
### 2. JSON 对象示例
一个 JSON 对象是一个名称-值对数据格式，典型地由大括号包围。一个 JSON 对象看起来像这样：
```
{
    "color" : "Purple",
    "id" : "210",
    "composition" : {
        "R" : 70,
        "G" : 39,
        "B" : 89
    }
}
```
### 3. JSON 数组示例
通过使用 JavaScript 数组数据可以在 JSON 内嵌套，它通过以一个值的形式传递并在数组值的首位添加中括号。

JSON 数据是有序集合且可以包含不同数据类型的值：
```
{
    "colors" :
    [
        {
        "color" : "Purple",
        "id" : "210"
        },
        {
        "color" : "Blue",
        "id" : "211"
        },
        {
        "color" : "Black",
        "id" : "212"
        }
    ]
}
```
## 三 JSON 数据类型
在细粒度级别，JSON 包括六种数据类型。前四种数据类型（string, number, boolean 和 null）可被成为简单数据类型，后两种数据类型（object 和 array）可被视为复杂数据类型。
- string
- number
- boolean
- null/empty
- object
- array

让我们逐个学习这些数据类型。
### 1. string
字符串是零个或多个 `Unicode` 字符的序列，以 `“` 和 `”` 包裹（双引号）。以单引号 `'` 包裹的字符串是无效的。
```
{
    "color" : "Purple"
}
```
JSON 字符串可以包括以下反斜杠转义字符：
- \\" – 双引号
- \\\ – 反斜杠
- \\/ – 斜杠
- \b – 回退键
- \f – 换页
- \n – 换行
- \r – 回车
- \t – 制表符
- \u – 后跟4个十六进制数
### 2. number
JSON 数字遵从 `JavaScript` 的双精度浮点数格式。
+ 以10进制表示，没有多余的前导0（如 67, 1, 100）
+ 包括 0 ~ 9 之间的数字
+ 可以是负数如 `-10`
+ 可以有一个以 `10` 为底的指数，加以前缀 `e` 或 `E`，以及一个正号或负号以指示是正或负指数
+ 8进制以及16进制不被支持
+ 没有一个值为 NaN （非数字）及 Infinity
```
{
    "number_1" : 210,
    "number_2" : -210,
    "number_3" : 21.05,
    "number_4" : 1.0E+2
}
```
## 3. boolean
Booleans 值可以为 `true` 或 `false`。布尔值无需引号包围，可被作为字符串值看待：
```
{
    "visibility" : true
}
```
### 4. null
虽然从技术上看不是一个值类型，`null` 在JSON 中是一个特殊值。当没有一个字指派给一个键时，它可被视为一个 `null`。

null 不应该被引号包围：
```
{
	"visibility" : true,
	"popularity" : null, //empty
	"id" : 210
}
```
### 5. object
+ 一个无序的名称/值对的集合，位于 {} 之间（大括号）
+ 一个对象可以包括零个或多个名称/值对
+ 多个名称/值对以逗号分隔
```
{
    "visibility" : true,
    "popularity" : "immense",
    "id" : 210
}
```
### 6. array
+ 一个无序的值的集合
+ 以  [ 开始，以 ] 结尾
+ 它的值以逗号分隔
```
{
    "ids" : ["1","2","3"]
}

//or
{
"ids" : [
        {"id" : 1},
        {"id" : 2},
        {"id" : 3}
    ]
}
```
## 四 JSON Schema
经常应用需要验证 JSON 对象的有效性，以确保必要的属性存在，以及满足了额外的验证性限制（例如价格不能少于1美元）。这些验证典型地在 JSON Schema 的背景下执行。
### 1. 语法 vs 语义验证（Syntactic vs Semantic Validation）
当没有其 Schema 时，我们验证一个 JSON 文档就仅仅只能验证其语义法。语法的验证仅能保证文档时格式良好的。

工具如 JSONLinthttps://jsonlint.com/ 以及 JSON 解析器仅仅执行语法验证。

语义验证比语法验证包含更多，它执行语法检查以及数据检查。

语义验证可以帮助确保客户仅仅发送 JSON 文档允许的字段，禁止无效名/值对。

它也能帮助检查诸如一个电话号码，日期/时间，邮政编码，邮件地址以及信用卡号等的格式。
### 2. 什么是 JSON Schema？
### 3. JSON Schema 验证示例
#### 3.1. 有效 JSON 文档示例
#### 3.2. 无效 JSON 文档示例 (年龄 > 64)
## 五 JSON 对象
## 六 JSON 数组
## 七 JSON parse()
## 八 JSON stringify()
## 九 JSON vs XML
## 十 JSON with Ajax
## 十一 JSONPath

## Reference 
- [JSON Tutorial](https://restfulapi.net/introduction-to-json/)
- [Introducing JSON](https://www.json.org/)