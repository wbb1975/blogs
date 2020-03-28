## 区间
### 1. 范例
```
List<Double> scores;
Iterable<Double> belowMedianScores = Iterables.filter(scores, Range.lessThan(median));
...
Range<Integer> validGrades = Range.closed(1, 12);
for(int grade : ContiguousSet.create(validGrades, DiscreteDomain.integers())) {
  ...
}
```
### 2. 简介
区间，有时也称为范围，是特定域中的凸性（非正式说法为连续的或不中断的）部分。在形式上，凸性表示对a<=b<=c, range.contains(a)且range.contains(c)意味着range.contains(b)。

区间可以延伸至无限——例如，范围”x>3″包括任意大于3的值——也可以被限制为有限，如” 2<=x<5″。Guava用更紧凑的方法表示范围，有数学背景的程序员对此是耳熟能详的：
- (a..b) = {x | a < x < b}
- [a..b] = {x | a <= x <= b}
- [a..b) = {x | a <= x < b}
- (a..b] = {x | a < x <= b}
- (a..+∞) = {x | x > a}
- [a..+∞) = {x | x >= a}
- (-∞..b) = {x | x < b}
- (-∞..b] = {x | x <= b}
- (-∞..+∞) = all values

上面的a、b称为端点 。为了提高一致性，Guava中的Range要求上端点不能小于下端点。上下端点有可能是相等的，但要求区间是闭区间或半开半闭区间（至少有一个端点是包含在区间中的）：
- [a..a]: singleton range
- [a..a); (a..a]: empty, but valid
- (a..a): invalid

Guava用类型[Range<C>](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html)表示区间。所有区间实现都是不可变类型。
### 3. 构建区间
区间实例可以由[Range](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html)类的静态方法获取：

区间类型|方法
--------|--------
(a..b)|[open(C, C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#open-java.lang.Comparable-java.lang.Comparable-)
[a..b]|[closed(C, C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#closed-java.lang.Comparable-java.lang.Comparable-)
[a..b)|[closedOpen(C, C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#closedOpen-java.lang.Comparable-java.lang.Comparable-)
(a..b]|[openClosed(C, C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#openClosed-java.lang.Comparable-java.lang.Comparable-)
(a..+∞)|[greaterThan(C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#greaterThan-C-)
[a..+∞)|[atLeast(C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#atLeast-C-)
(-∞..b)|[lessThan(C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#lessThan-C-)
(-∞..b]|[atMost(C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#atMost-C-)
(-∞..+∞)|[all()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#all--)

```
Range.closed("left", "right"); //字典序在"left"和"right"之间的字符串，闭区间
Range.lessThan(4.0); //严格小于4.0的double值
```

此外，也可以明确地指定边界类型来构造区间：

区间类型|方法
--------|--------
有界区间|[range(C, BoundType, C, BoundType)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#range-java.lang.Comparable-com.google.common.collect.BoundType-java.lang.Comparable-com.google.common.collect.BoundType-)
无上界区间((a..+∞) 或[a..+∞))|[downTo(C, BoundType)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#downTo-java.lang.Comparable-com.google.common.collect.BoundType-)
无下界区间[((-∞..b) 或(-∞..b])|[upTo(C, BoundType)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#upTo-java.lang.Comparable-com.google.common.collect.BoundType-)

这里的[BoundType](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/BoundType.html)是一个枚举类型，包含CLOSED和OPEN两个值。
```
Range.downTo(4, boundType);// (a..+∞)或[a..+∞)，取决于boundType
Range.range(1, CLOSED, 4, OPEN);// [1..4)，等同于Range.closedOpen(1, 4)
```
### 4. 区间运算
Range的基本运算是它的[contains(C)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#contains-C-) 方法，和你期望的一样，它用来区间判断是否包含某个值。此外，Range实例也可以当作Predicate，并且在[函数式编程](https://github.com/google/guava/wiki/functional)中使用。任何Range实例也都支持containsAll(Iterable<? extends C>)方法：
```
Range.closed(1, 3).contains(2); // returns true
Range.closed(1, 3).contains(4); // returns false
Range.lessThan(5).contains(5); // returns false
Range.closed(1, 4).containsAll(Ints.asList(1, 2, 3)); // returns true
```
### 4.1 查询运算
Range类提供了以下方法来查看区间的端点：
- [hasLowerBound()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#hasLowerBound--)和[hasUpperBound()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#hasUpperBound--)：判断区间是否有特定边界，或是无限的；
- [lowerBoundType()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#lowerBoundType--)和[upperBoundType()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#upperBoundType--)：返回区间边界类型，CLOSED或OPEN；如果区间没有对应的边界，抛出IllegalStateException；
- [lowerEndpoint()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#lowerEndpoint--)和[upperEndpoint()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#upperEndpoint--)：返回区间的端点值；如果区间没有对应的边界，抛出IllegalStateException；
- [isEmpty()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#isEmpty--)：判断是否为空区间。

```
Range.closedOpen(4, 4).isEmpty(); // returns true
Range.openClosed(4, 4).isEmpty(); // returns true
Range.closed(4, 4).isEmpty(); // returns false
Range.open(4, 4).isEmpty(); // Range.open throws IllegalArgumentException

Range.closed(3, 10).lowerEndpoint(); // returns 3
Range.open(3, 10).lowerEndpoint(); // returns 3
Range.closed(3, 10).lowerBoundType(); // returns CLOSED
Range.open(3, 10).upperBoundType(); // returns OPEN
```
### 4.2 关系运算
#### 4.2.1 包含（enclose）
区间之间的最基本关系就是包含[encloses(Range)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#encloses-com.google.common.collect.Range-)：如果内区间的边界没有超出外区间的边界，则外区间包含内区间。包含判断的结果完全取决于区间端点的比较！
- [3..6] 包含[4..5] ；
- (3..6) 包含(3..6) ；
- [3..6] 包含[4..4)，虽然后者是空区间；
- (3..6]不 包含[3..6] ；
- [4..5]不 包含(3..6)，即使前者包含了后者的所有值，离散域[discrete domains]可以解决这个问题
- [3..6]不 包含(1..1]，即使前者包含了后者的所有值。

包含是一种偏序关系[partial ordering](https://github.com/google/guava/wiki/GuavaTermsExplained#partial-ordering)。基于包含关系的概念，Range还提供了以下运算方法。
#### 4.2.2 相连（isConnected）
[Range.isConnected(Range)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#isConnected-com.google.common.collect.Range-)判断区间是否是相连的。具体来说，isConnected测试是否有区间同时包含于这两个区间，这等同于数学上的定义”两个区间的并集是连续集合的形式”（空区间的特殊情况除外）。

相连是一种自反的[reflexive](https://github.com/google/guava/wiki/GuavaTermsExplained#reflexive)、对称[symmetric](https://github.com/google/guava/wiki/GuavaTermsExplained#symmetric)的[[关系](https://github.com/google/guava/wiki/GuavaTermsExplained#relation)。
```
Range.closed(3, 5).isConnected(Range.open(5, 10)); // returns true
Range.closed(0, 9).isConnected(Range.closed(3, 4)); // returns true
Range.closed(0, 5).isConnected(Range.closed(3, 9)); // returns true
Range.open(3, 5).isConnected(Range.open(5, 10)); // returns false
Range.closed(1, 5).isConnected(Range.closed(6, 10)); // returns false
```
#### 4.2.3 交集（intersection）
[Range.intersection(Range)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#intersection-com.google.common.collect.Range-)返回两个区间的交集：既包含于第一个区间，又包含于另一个区间的最大区间。当且仅当两个区间是相连的，它们才有交集。如果两个区间没有交集，该方法将抛出IllegalArgumentException。

交集是可互换的[commutative](https://github.com/google/guava/wiki/GuavaTermsExplained#commutative)、关联的[associative](https://github.com/google/guava/wiki/GuavaTermsExplained#associative)运算。
```
Range.closed(3, 5).intersection(Range.open(5, 10)); // returns (5, 5]
Range.closed(0, 9).intersection(Range.closed(3, 4)); // returns [3, 4]
Range.closed(0, 5).intersection(Range.closed(3, 9)); // returns [3, 5]
Range.open(3, 5).intersection(Range.open(5, 10)); // throws IAE
Range.closed(1, 5).intersection(Range.closed(6, 10)); // throws IAE
```
#### 4.2.4 跨区间（span）
[Range.span(Range)](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/collect/Range.html#span(com.google.common.collect.Range))返回”同时包括两个区间的最小区间”，如果两个区间相连，那就是它们的并集。

span是可互换的[commutative](https://github.com/google/guava/wiki/GuavaTermsExplained#commutative) 、关联的[associative](https://github.com/google/guava/wiki/GuavaTermsExplained#associative) 、闭合的[closed](https://github.com/google/guava/wiki/GuavaTermsExplained#closed)运算。
```
Range.closed(3, 5).span(Range.open(5, 10)); // returns [3, 10)
Range.closed(0, 9).span(Range.closed(3, 4)); // returns [0, 9]
Range.closed(0, 5).span(Range.closed(3, 9)); // returns [0, 9]
Range.open(3, 5).span(Range.open(5, 10)); // returns (3, 10)
Range.closed(1, 5).span(Range.closed(6, 10)); // returns [1, 10]
```
### 5. 离散域
部分（但不是全部）可比较类型是离散的，即区间的上下边界都是可枚举的。

在Guava中，用[DiscreteDomain<C>](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/DiscreteDomain.html)实现类型C的离散形式操作。一个离散域总是代表某种类型值的全集；它不能代表类似”素数”、”长度为5的字符串”或”午夜的时间戳”这样的局部域。

[DiscreteDomain](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/DiscreteDomain.html)提供的离散域实例包括：

类型|离散域
--------|--------
Integer|[integers()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/DiscreteDomain.html#integers--)
Long|[longs()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/DiscreteDomain.html#longs--)

一旦获取了DiscreteDomain实例，你就可以使用下面的Range运算方法：
- [ContiguousSet.create(range, domain)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ContiguousSet.html#create-com.google.common.collect.Range-com.google.common.collect.DiscreteDomain-)：用ImmutableSortedSet<C>形式表示Range<C>中符合离散域定义的元素，并增加一些额外操作——译者注：实际返回ImmutableSortedSet的子类ContiguousSet。（对无限区间不起作用，除非类型C本身是有限的，比如int就是可枚举的）
- [canonical(domain)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Range.html#canonical-com.google.common.collect.DiscreteDomain-)：把离散域转为区间的”规范形式”。如果ContiguousSet.create(a, domain).equals(ContiguousSet.create(b, domain))并且!a.isEmpty()，则有a.canonical(domain).equals(b.canonical(domain))。（这并不意味着a.equals(b)）

```
ImmutableSortedSet<Integer> set = ContiguousSet.create(Range.open(1, 5), DiscreteDomain.integers());
// set contains [2, 3, 4]

ContiguousSet.create(Range.greaterThan(0), DiscreteDomain.integers());
// set contains [1, 2, ..., Integer.MAX_VALUE]
```
注意，ContiguousSet.create并没有真的构造了整个集合，而是返回了set形式的区间视图。
#### 5.1 你自己的离散域
你可以创建自己的离散域，但必须记住DiscreteDomain契约的几个重要方面。
- 一个离散域总是代表某种类型值的全集；它不能代表类似”素数”或”长度为5的字符串”这样的局部域。所以举例来说，你无法构造一个DiscreteDomain以表示精确到秒的JODA DateTime日期集合：因为那将无法包含JODA DateTime的所有值。
- DiscreteDomain可能是无限的——比如BigInteger DiscreteDomain。这种情况下，你应当用minValue()和maxValue()的默认实现，它们会抛出NoSuchElementException。但Guava禁止把无限区间传入ContiguousSet.create——译者注：那明显得不到一个可枚举的集合。
### 6. 如果我需要一个Comparator呢？
我们想要在Range的可用性与API复杂性之间找到特定的平衡，这部分导致了我们没有提供基于Comparator的接口：我们不需要操心区间是怎样基于不同Comparator互动的；所有API签名都是简单明确的；这样更好。

另一方面，如果你需要任意Comparator，可以按下列其中一项来做：
  - 使用通用的Predicate接口，而不是Range类。（Range实现了Predicate接口，因此可以用Predicates.compose(range, function)获取Predicate实例）
  - 使用包装类以定义期望的排序。

> 注：实际上Range规定元素类型必须是Comparable，这已经满足了大多数需求。如果需要自定义特殊的比较逻辑，可以用Predicates.compose(range, function)组合比较的function。
## Reference
- [Ranges Explained](https://github.com/google/guava/wiki/RangesExplained)