# yaml入门简介
## yaml是什么
YAML是一个可读性高，用来表达数据序列的格式。YAML参考了其它多种语言，包括：C语言、Python、Perl，并从XML、电子邮件的数据格式中获得灵感。Clark Evans在2001年首次发表了这种语言。当前已经有数种编程语言或脚本语言支持这种语言。最新稳定版本为1.2，于2009年发布。YAML文件扩展名为.yaml或.yml。

YAML是”YAML Ain’t a Markup Language”(YAML不是一种标记语言)的递归缩写。在开发这种语言时，YAML的意思其实是：”Yet Another Markup Language”(仍是一种标记语言)，但为了强调这种语言以数据做为中心，而不是以标记语言为重点，而用反向缩略语重命名。

它是JSON的一个严格超集，在语法上增加了类似Python的换行和缩进。不过，与Python不同，YAML不允许使用Tab缩进。在YAML中，字符串不一定要用双引号标示。另外，在缩进中空白字符的数目并不是非常重要，只要相同层次结构的元素左侧对齐就可以了(不过不能使用TAB字符)。文件中重复的部分用这个方法处理：使用锚点（&）和引用（*）标签。也可以在文件中加入选择性的空行，以增加可读性。在一个文件中，可同时包含多个文件，并用"---"分隔。选择性的符号"..."可以用来表示文件结尾。
## 基本规则
YAML有一些基本的规则，用来避免与各种编程语言和编辑器相关的歧义问题，这些基本的规则使得无论哪个应用程序或软件库都能一致地解析YAML。
- 文件名以.yaml结尾
- 大小写敏感
- 使用缩进表示层级关系，缩进时不允许使用Tab键，只允许使用空格。缩进的空格数目不重要，只要相同层级的元素左侧对齐即可
- 注释由井字号(#)开始，可以出现在一行中的任何位置，而且范围只有一行(也就是一般所谓的单行注解)
- 在单一文件中，可用连续三个连字号(---)区分多个文件或表示文件的开始；另外，还有选择性的连续三个点号(...)用来表示文件结尾；
- 重复的内容可使从参考标记星号(*)复制到锚点标记(&)；
- YAML在使用逗号及冒号时，后面都必须接一个空白字符，所以可以在字符串或数值中自由加入分隔符号而不需要使用引号。另外还有两个特殊符号在YAML中被保留，有可能在未来的版本被使用(@)和(`)。
- YAML的数据形态不依赖引号之特点，使的YAML文件可以利用区块，轻易的插入各种其他类型文件，如：XML、SDL、JSON，甚至插入另一篇YAML。
## yaml数据类型
ymal包含3种数据类型：标量（scalars），列表（sequence或list）和映射（mapping，hashes或dictionary）。
### 标量
纯量是最基本的、不可再分的值。以下数据类型都属于JavaScript的标量。
- 字符串
- 布尔值
- 整数
- 浮点数
- Null
- 时间
- 日期

数值直接以字面量的形式表示：`number: 12.30`

转为 JavaScript 如下：`{ number: 12.30 }`

布尔值用true和false表示：`isSet: true`

转为 JavaScript 如下：`{ isSet: true }`

null用~表示：`parent: ~ `

转为 JavaScript 如下：`{ parent: null }`

时间采用 ISO8601 格式：`iso8601: 2001-12-14t21:59:43.10-05:00`

转为 JavaScript 如下：`{ iso8601: new Date('2001-12-14t21:59:43.10-05:00') }`

日期采用复合 iso8601 格式的年、月、日表示：`date: 1976-07-31`

转为 JavaScript 如下：`{ date: new Date('1976-07-31') }`

YAML 允许使用两个感叹号，强制转换数据类型：
```
e: !!str 123
f: !!str true
```
转为 JavaScript 如下：`{ e: '123', f: 'true' }`
#### 字符串
字符串是最常见，也是最复杂的一种数据类型。字符串默认不使用引号表示。
```
str: 这是一行字符串
```
转为 JavaScript 如下：`{ str: '这是一行字符串' }`

如果字符串之中包含空格或特殊字符，需要放在引号之中。
```
str: '内容： 字符串'
```
转为 JavaScript 如下：
```
{ str: '内容: 字符串' }
```

单引号和双引号都可以使用，双引号不会对特殊字符转义。
```
s1: '内容\n字符串'
s2: "内容\n字符串"
```
转为 JavaScript 如下：
```
{ s1: '内容\\n字符串', s2: '内容\n字符串' }
```

单引号之中如果还有单引号，必须连续使用两个单引号转义。
```
str: 'labor''s day' 
```
转为 JavaScript 如下：
```
{ str: 'labor\'s day' }
```

字符串可以写成多行，从第二行开始，必须有一个单空格缩进。换行符会被转为空格。
```
str: 这是一段
  多行
  字符串
```
转为 JavaScript 如下：
```
{ str: '这是一段 多行 字符串' }
```

多行字符串可以使用 `|` 保留换行符，也可以使用 `>` 折叠换行。
```
his: |
  Foo
  Bar
that: >
  Foo
  Bar
```
转为 JavaScript 如下：
```
{ this: 'Foo\nBar\n', that: 'Foo Bar\n' }
```

+表示保留文字块末尾的换行，-表示删除字符串末尾的换行。
```
s1: |
  Foo

s2: |+
  Foo


s3: |-
  Foo
```
转为 JavaScript 如下：
```
{ s1: 'Foo\n', s2: 'Foo\n\n\n', s3: 'Foo' }
```

字符串之中可以插入 HTML 标记。
```
essage: |

  <p style="color: red">
    段落
  </p>
```
转为 JavaScript 如下：
```
{ message: '\n<p style="color: red">\n  段落\n</p>\n' }
```
### 数组（list）
一组连词线开头的行，构成一个数组。
```
- Cat
- Dog
- Goldfish
```
转为 JavaScript 如下：
```
[ 'Cat', 'Dog', 'Goldfish' ]
```

数组也可以采用行内表示法。
```
animal: [Cat, Dog]
```
转为 JavaScript 如下：
```
{ animal: [ 'Cat', 'Dog' ] }
```
### 映射表
键值对，如：
```
animal: pets
```

如果值是一个序列：
```
pets:
  - Cat
  - Dog
  - Goldfish
```
## 引用
锚点&和别名*，可以用来引用。
```
defaults: &defaults
  adapter:  postgres
  host:     localhost

development:
  database: myapp_development
  <<: *defaults

test:
  database: myapp_test
  <<: *defaults
```

等同于下面的代码：
```
defaults:
  adapter:  postgres
  host:     localhost

development:
  database: myapp_development
  adapter:  postgres
  host:     localhost

test:
  database: myapp_test
  adapter:  postgres
  host:     localhost
```
&用来建立锚点（defaults），<<表示合并到当前数据，*用来引用锚点。

下面是另一个例子：
```
- &showell Steve 
- Clark 
- Brian 
- Oren 
- *showell 
```
转为 JavaScript 代码如下：
```
[ 'Steve', 'Clark', 'Brian', 'Oren', 'Steve' ]
```



## Reference
- [YAML文件简介](https://www.cnblogs.com/sddai/p/9626392.html)
- [YAML简介](https://blog.csdn.net/fengbingchun/article/details/88090609)
- [YAML简介](https://www.jianshu.com/p/2928df88ef50)