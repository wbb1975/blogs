## 字符串工具
### 1. 连接器（Joiner）
用分隔符把字符串序列连接起来也可能会遇上不必要的麻烦。如果字符串序列中含有null，那连接操作会更难。Fluent风格的[Joiner](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Joiner.html)让连接字符串更简单。
```
Joiner joiner = Joiner.on("; ").skipNulls();
return joiner.join("Harry", null, "Ron", "Hermione");
```
上述代码返回”Harry; Ron; Hermione”。另外，useForNull(String)方法可以给定某个字符串来替换null，而不像skipNulls()方法是直接忽略null。 

Joiner也可以用来连接对象类型，在这种情况下，它会把对象的toString()值连接起来。
```
Joiner.on(",").join(Arrays.asList(1, 5, 7)); // returns "1,5,7"
```
> **警告**：joiner实例总是不可变的。用来定义joiner目标语义的配置方法总会返回一个新的joiner实例。这使得joiner实例都是线程安全的，你可以将其定义为static final常量。
### 2. 拆分器（Splitter）
JDK内建的字符串拆分工具有一些古怪的特性。比如，String.split悄悄丢弃了尾部的分隔符，StringTokenizer遵守精确的5个空白符并什么也不返回。

问题：”,a,,b,”.split(“,”)返回什么？
1. "", "a", "", "b", ""
2. null, "a", null, "b", null
3. "a", null, "b"
4. "a", "b"
5. 以上都不对
正确答案是以上都不对："", "a", "", "b"，只有尾部的空字符串被忽略了。这是我想象不到的。

[Splitter](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html)使用令人放心的、直白的流畅API模式对这些混乱的特性作了完全的掌控。
```
Splitter.on(',')
    .trimResults()
    .omitEmptyStrings()
    .split("foo,bar,,   qux");
```
上述代码返回Iterable<String>，其中包含”foo”、”bar”和”qux”。Splitter可以被设置为按照任何模式、字符、字符串或字符匹配器拆分。
#### 2.1 拆分器工厂（Base Factories）
方法|描述|范例
--------|--------|--------
[Splitter.on(char)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#on-char-)|按单个字符拆分|Splitter.on(‘;’)
[Splitter.on(CharMatcher)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#on-com.google.common.base.CharMatcher-)|按字符匹配器拆分|Splitter.on(CharMatcher.BREAKING_WHITESPACE)
[Splitter.on(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#on-java.lang.String-)|按字符串拆分|Splitter.on(“,   “)
[Splitter.on(Pattern)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#on-java.util.regex.Pattern-) [Splitter.onPattern(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#onPattern-java.lang.String-)|按正则表达式拆分|Splitter.onPattern(“\r?\n”)
[Splitter.fixedLength(int)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#fixedLength-int-)|按固定长度拆分；最后一段可能比给定长度短，但不会为空。|Splitter.fixedLength(3)
#### 2.2 拆分器修饰符（Modifiers）
方法|描述
--------|--------
[omitEmptyStrings()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#omitEmptyStrings--)|从结果中自动忽略空字符串
[trimResults()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#trimResults--)|移除结果字符串的前导空白和尾部空白
[trimResults(CharMatcher)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#trimResults-com.google.common.base.CharMatcher-)|给定匹配器，移除结果字符串的前导匹配字符和尾部匹配字符
[limit(int)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#limit-int-)|限制拆分出的字符串数量

如果你想要拆分器返回List，只要使用Lists.newArrayList(splitter.split(string))或类似方法。

> **警告**：splitter实例总是不可变的。用来定义splitter目标语义的配置方法总会返回一个新的splitter实例。这使得splitter实例都是线程安全的，你可以将其定义为static final常量。
#### 2.3 映射拆分器（Map Splitters）
通过[withKeyValueSeparator()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.html#withKeyValueSeparator-java.lang.String-)指定第二个分隔符你也可以使用一个拆分器来反序列化一个映射（map）。返回的[映射拆分器](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Splitter.MapSplitter.html)将使用拆分器分隔符来把输入拆分为映射项，然后把这些映射项使用指定的键值对分隔符切分为键和值，返回一个Map<String, String>对象。
### 3. 字符匹配器（CharMatcher）
在以前的Guava版本中，StringUtil类疯狂地膨胀，其拥有很多处理字符串的方法：allAscii、collapse、collapseControlChars、collapseWhitespace、indexOfChars、lastIndexNotOf、numSharedChars、removeChars、removeCrLf、replaceChars、retainAllChars、strip、stripAndCollapse、stripNonDigits。 所有这些方法指向两个概念上的问题：
1. 怎么才算匹配字符？
2. 如何处理这些匹配字符？

为了收拾这个泥潭，我们开发了CharMatcher。直观上，你可以认为一个CharMatcher实例代表着某一类字符，如数字或空白字符。事实上来说，CharMatcher实例就是对字符的布尔判断——CharMatcher确实也实现了Predicate<Character>——但类似”所有空白字符”或”所有小写字母”的需求太普遍了，Guava因此创建了这一API。

然而使用CharMatcher的好处更在于它提供了一系列方法，让你对字符作特定类型的操作：修剪[trim]、折叠[collapse]、移除[remove]、保留[retain]等等。CharMatcher实例首先代表概念1：怎么才算匹配字符？然后它还提供了很多操作概念2：如何处理这些匹配字符？这样的设计使得API复杂度的线性增加可以带来灵活性和功能两方面的增长。
```
String noControl = CharMatcher.javaIsoControl().removeFrom(string); // 移除control字符
String theDigits = CharMatcher.digit().retainFrom(string); // //只保留数字字符
String spaced = CharMatcher.whitespace().trimAndCollapseFrom(string, ' ');   // 去除两端的空格，并把中间的连续空格替换成单个空格
String noDigits = CharMatcher.javaDigit().replaceFrom(string, "*"); // 用*号替换所有数字
String lowerAndDigit = CharMatcher.javaDigit().or(CharMatcher.javaLowerCase()).retainFrom(string);  // 只保留数字和小写字母
```
> **注**：CharMatcher只处理char类型代表的字符；它不能理解0x10000到0x10FFFF的Unicode 增补字符。这些逻辑字符以代理对[surrogate pairs]的形式编码进字符串，而CharMatcher只能将这种逻辑字符看待成两个独立的字符。
#### 3.1 获取字符匹配器
CharMatcher中的工厂方法可以满足大多数字符匹配需求：
- [any()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#any--)
- [none()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#none--)
- [whitespace()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#whitespace--)
- [breakingWhitespace()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#breakingWhitespace--)
- [invisible()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#invisible--)
- [digit()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#digit--)
- [javaLetter()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaLetter--)
- [javaDigit()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaDigit--)
- [javaLetterOrDigit()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaLetterOrDigit--)
- [javaIsoControl()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaIsoControl--)
- [javaLowerCase()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaLowerCase--)
- [javaUpperCase()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#javaUpperCase--)
- [ascii()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#ascii--)
- singleWidth()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#singleWidth--)

其他获取字符匹配器的常见方法包括：

方法|描述
--------|--------
[anyOf(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#anyOf-java.lang.CharSequence-)|枚举匹配字符。如CharMatcher.anyOf(“aeiou”)匹配小写英语元音
[is(char)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#is-char-)|给定单一字符匹配。
[inRange(char, char)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#inRange-char-char-)|给定字符范围匹配，如CharMatcher.inRange(‘a’, ‘z’)

此外，CharMatcher还有[negate()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#negate--)、[and(CharMatcher)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#and-com.google.common.base.CharMatcher-)和[or(CharMatcher)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#or-com.google.common.base.CharMatcher-)方法。
#### 3.2 使用字符匹配器
CharMatcher提供了[多种多样的方法](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#method_summary)操作CharSequence中的特定字符。其中最常用的罗列如下：
方法|描述
--------|--------
[collapseFrom(CharSequence, char)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#collapseFrom-java.lang.CharSequence-char-)|把每组连续的匹配字符替换为特定字符。如WHITESPACE.collapseFrom(string, ‘ ‘)把字符串中的连续空白字符替换为单个空格。
[matchesAllOf(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#matchesAllOf-java.lang.CharSequence-)|测试是否字符序列中的所有字符都匹配。
[removeFrom(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#removeFrom-java.lang.CharSequence-)|从字符序列中移除所有匹配字符。
[retainFrom(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#retainFrom-java.lang.CharSequence-)|在字符序列中保留匹配字符，移除其他字符。
[trimFrom(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#trimFrom-java.lang.CharSequence-)|移除字符序列的前导匹配字符和尾部匹配字符。
[replaceFrom(CharSequence, CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CharMatcher.html#replaceFrom-java.lang.CharSequence-java.lang.CharSequence-)|用特定字符序列替代匹配字符。
> **注意**：所有这些方法返回String，除了matchesAllOf返回的是boolean。
### 4. 字符集（Charsets）
不要这样做：
```
try {
  bytes = string.getBytes("UTF-8");
} catch (UnsupportedEncodingException e) {
  // how can this possibly happen?
  throw new AssertionError(e);
}
```
作为替代可以这样写：
```
bytes = string.getBytes(Charsets.UTF_8);
```
[Charsets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Charsets.html)针对所有Java平台都要保证支持的六种字符集提供了常量引用。尝试使用这些常量，而不是通过名称获取字符集实例。

> **TODO**: charsets的解释以及何时应该使用它
> **注意**：如果你在使用JDK7，你应该使用[StandardCharsets](http://docs.oracle.com/javase/7/docs/api/java/nio/charset/StandardCharsets.html)中的常量。
### 5. 大小写格式（CaseFormat）
CaseFormat被用来方便地在各种ASCII大小写规范间转换字符串——比如，编程语言的命名规范。CaseFormat支持的格式如下：
格式|范例
--------|--------
[LOWER_CAMEL](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CaseFormat.html#LOWER_CAMEL)|lowerCamel
[LOWER_HYPHEN](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CaseFormat.html#LOWER_HYPHEN)|lower-hyphen
[LOWER_UNDERSCORE](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CaseFormat.html#LOWER_UNDERSCORE)|lower_underscore
[UPPER_CAMEL](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CaseFormat.html#UPPER_CAMEL)|UpperCamel
[UPPER_UNDERSCORE](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/CaseFormat.html#UPPER_UNDERSCORE)|UPPER_UNDERSCORE

CaseFormat的用法很直接：
```
CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, "CONSTANT_NAME")); // returns "constantName"
```
我们CaseFormat在某些时候尤其有用，比如编写代码生成器的时候。
### 6. Strings
数量不多的以下通用字符串工具驻留在[Strings](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html)类中。

## Reference
- [Strings Explained](https://github.com/google/guava/wiki/StringsExplained)