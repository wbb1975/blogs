## 排序(Ordering)
### 示例
```
assertTrue(byLengthOrdering.reverse().isOrdered(list));
```
### 概览
排序器[Ordering]是Guava Fluent风格比较器[Comparator]的实现，它可以用来为构建复杂的比较器，以完成集合排序的功能。

从实现上说，Ordering实例就是一个特殊的Comparator实例。Ordering把很多基于Comparator的方法（如Collections.max）包装为自己的实例方法，并且提供了链式调用方法，来调整和增强现有的比较器。
### 创建
常见的排序器可以由下面的静态方法提供：

**方法**|**描述**
----------|--------------
[natural()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#natural--)|使用Comparable类型的自然排序（natural ordering）
[usingToString()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#usingToString--)|按对象的字符串形式做字典排序（lexicographical ordering）
[from(Comparator)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#from-java.util.Comparator-)|把给定的Comparator转化为排序器

将一个已存在的Comparator转化为一个排序器非常简单，只要调用一下[Ordering.from(Comparator)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#from-java.util.Comparator-)即可。

但是创建一个定制排序器（Ordering ）的一个更通用的做法是跳过Comparator直接继承Ordering虚基类。
```
Ordering<String> byLengthOrdering = new Ordering<String>() {
  public int compare(String left, String right) {
    return Ints.compare(left.length(), right.length());
  }
};
```
### 链式调用
一个给定的排序器可以被包装从而得到一个派生的排序器。其中一些最常用的变体包括：
**方法**|**描述**
----------|--------------
[reverse()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#reverse--)|返回语义相反的排序器
[nullsFirst()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#nullsFirst--)|使用当前排序器，但额外把null值排到最前面。参见[nullsLast()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#nullsLast--)
[compound(Comparator)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#compound-java.util.Comparator-)|把给定的Comparator转化为排序器合成另一个比较器，以处理当前排序器中的相等情况。
[lexicographical()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#lexicographical--)|基于处理类型T的排序器，返回该类型的可迭代对象Iterable<T>的排序器
[onResultOf(Function)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#onResultOf-com.google.common.base.Function-)|对集合中元素调用Function，再按返回值用当前排序器排序

比如，假如你想给下面的类添加一个比较器：
```
class Foo {
  @Nullable String sortedBy;
  int notSortedBy;
}
```
考虑到排序器应该能处理sortedBy为null的情况，我们可以使用下面的链式调用来合成排序器：
```
Ordering<Foo> ordering = Ordering.natural().nullsFirst().onResultOf(new Function<Foo, String>() {
  public String apply(Foo foo) {
    return foo.sortedBy;
  }
});
```

当阅读链式调用产生的排序器时，应该从后往前读。上面的例子中，排序器首先调用apply方法获取sortedBy值，并把sortedBy为null的元素都放到最前面，然后把剩下的元素按sortedBy进行自然排序。之所以要从后往前读，是因为每次链式调用都是用后面的方法包装了前面的排序器。

> **注意**：用compound方法包装排序器时，就不应遵循从后往前读的原则。为了避免理解上的混乱，请不要把compound与其它链式调用混用。

超过一定长度的链式调用，也可能会带来阅读和理解上的难度。我们建议按下面的代码这样，在一个链中最多使用三个方法。此外，你也可以把Function分离成中间对象，让链式调用更简洁紧凑。
```
Ordering<Foo> ordering = Ordering.natural().nullsFirst().onResultOf(sortKeyFunction);
```
### 应用
Guava提供了许多利用排序器来操纵或检查值或集合的方法。我们将在下面列出一些最常用的：

**方法**|**描述**|**另请参见**  
----------|---------------|---------------
[greatestOf(Iterable iterable, int k)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#greatestOf-java.lang.Iterable-int-)|获取可迭代对象中最大的k个元素。并不是稳定（排序）的|[leastOf](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#leastOf-java.lang.Iterable-int-)
[isOrdered(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#isOrdered-java.lang.Iterable-)|测试可迭代对象按排序器给定的非递减顺序排列的|[isStrictlyOrdered](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#isStrictlyOrdered-java.lang.Iterable-)
[sortedCopy(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#sortedCopy-java.lang.Iterable-)|将指定可迭代对象的元素以排序列表的形式返回|[immutableSortedCopy](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#immutableSortedCopy-java.lang.Iterable-)
[min(E, E)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#min-E-E-)|返回两个参数中最小的那个。如果相等，则返回第一个参数。|[max(E, E)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#max-E-E-)
[min(E, E, E, E...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#min-E-E-E-E...-)|返回多个参数中最小的那个。如果有超过一个参数都最小，则返回第一个最小的参数。|[max(E, E, E, E...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#max-E-E-E-E...-)
[min(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#min-java.lang.Iterable-)|返回迭代器中最小的元素。如果可迭代对象中没有元素，则抛出NoSuchElementException。|[max(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#max-java.lang.Iterable-), [min(Iterator)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#min-java.util.Iterator-), [max(Iterator)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#max-java.util.Iterator-)


## Reference
- [Ordering Explained](https://github.com/google/guava/wiki/OrderingExplained)