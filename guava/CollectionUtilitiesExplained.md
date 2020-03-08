## 集合工具类
任何对JDK集合框架有经验的程序员都熟悉和喜欢[java.util.Collections](http://docs.oracle.com/javase/7/docs/api/java/util/Collections.html)包含的工具方法。Guava沿着这些路线提供了更多的工具方法：适用于所有集合的静态方法。这是Guava最流行和成熟的部分之一。

我们用相对直观的方式把工具类与特定集合接口的对应关系归纳如下：

集合接口|属于JDK还是Guava|对应的Guava工具类
-----------|----------------|---------
Collection|JDK|[Collections2](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Collections2.html)
List|JDK|[Lists](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html)
Set|JDK|[Sets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html)
SortedSet|JDK|[Sets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html)
Map|JDK|[Maps](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html)
SortedMap|JDK|[Maps](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html)
Queue|JDK|[Queues](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Queues.html)
Multiset|Guava|[Multisets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html)
Multimap|Guava|[Multimaps](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html)
BiMap|Guava|[Maps](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html)
Table|Guava|[Tables](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html)

在找类似转化、过滤的方法？请看我们的函数时编程一章中，函数式风格。
### 1. 静态工厂方法
在JDK 7之前，构造新的范型集合时要讨厌地重复声明范型：
```
List<TypeThatsTooLongForItsOwnGood> list = new ArrayList<TypeThatsTooLongForItsOwnGood>();
```
我想我们都认为这很讨厌。因此Guava提供了能够推断范型的静态工厂方法：
```
List<TypeThatsTooLongForItsOwnGood> list = Lists.newArrayList();
Map<KeyType, LongishValueType> map = Maps.newLinkedHashMap();
```
可以肯定的是，JDK7版本的钻石操作符(<>)没有这样的麻烦：
```
List<TypeThatsTooLongForItsOwnGood> list = new ArrayList<>();
```
但Guava的静态工厂方法远不止这么简单。用工厂方法模式，我们可以方便地在初始化时就指定起始元素。
```
Set<Type> copySet = Sets.newHashSet(elements);
List<String> theseElements = Lists.newArrayList("alpha", "beta", "gamma");
```
此外，通过为工厂方法命名（Effective Java第一条），我们可以提高集合初始化大小的可读性：
```
List<Type> exactly100 = Lists.newArrayListWithCapacity(100);
List<Type> approx100 = Lists.newArrayListWithExpectedSize(100);
Set<Type> approx100Set = Sets.newHashSetWithExpectedSize(100);
```
确切的静态工厂方法和相应的工具类一起罗列在下面的章节。

注意：Guava引入的新集合类型没有暴露原始构造器，也没有在工具类中提供初始化方法。而是直接在集合类中提供了静态工厂方法，例如：
```
Multiset<String> multiset = HashMultiset.create();
```
### 2. Iterables
在可能的情况下，Guava提供的工具方法更偏向于接受Iterable而不是Collection类型。在Google，对于不存放在主存的集合——比如从数据库或其他数据中心收集的结果集，因为实际上还没有攫取全部数据，这类结果集都不能支持类似size()的操作 ——通常都不会用Collection类型来表示。

因此，很多你期望的支持所有集合的操作都在[Iterables](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html)类中。大多数Iterables方法有一个在[Iterators](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterators.html)类中的对应版本，用来处理Iterator。

Iterables中的大多数操作是延迟操作：只有在绝对必要时才将操作应用到后端。返回Iterables的方法也仅仅返回延迟计算的视图，而不会在内存中构造一个完整的集合。

截至Guava 12版本，Iterables使用[FluentIterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/FluentIterable.html)类进行了补充，它包装了一个Iterable实例，并对许多操作提供了”fluent”（链式调用）语法。

下面列出了一些最常用的工具方法，但更多Iterables的函数式方法将在后面的“[Guava函数式调用](https://github.com/google/guava/wiki/FunctionalExplained)”讨论。
#### 2.1 常规方法
方法|描述|参见
-----------|----------------|---------
[concat(Iterable<Iterable>)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#concat(java.lang.Iterable))|串联多个iterables的懒视图*|[concat(Iterable...)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#concat(java.lang.Iterable...))
[frequency(Iterable, Object)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#frequency(java.lang.Iterable,%20java.lang.Object))|返回对象在iterable中出现的次数|与Collections.frequency (Collection, Object)比较；[Multiset](http://code.google.com/p/guava-libraries/wiki/NewCollectionTypesExplained#Multiset)
[partition(Iterable, int)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#partition(java.lang.Iterable,%20int))|把iterable按指定大小分割，得到的子集都不能进行修改操作|[Lists.partition(List, int)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Lists.html#partition(java.util.List,%20int))；[paddedPartition(Iterable, int)](http://docs.guava-libraries.googlecode.com/git-history/release12/javadoc/com/google/common/collect/FluentIterable.html#first())
[getFirst(Iterable, T default)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#getFirst(java.lang.Iterable,%20T))|返回iterable的第一个元素，若iterable为空则返回默认值|与Iterable.iterator(). next()比较;[FluentIterable.first()](http://docs.guava-libraries.googlecode.com/git-history/release12/javadoc/com/google/common/collect/FluentIterable.html#first())
[getLast(Iterable)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#getLast(java.lang.Iterable))|返回iterable的最后一个元素，若iterable为空则抛出NoSuchElementException|[getLast(Iterable, T default)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#getLast(java.lang.Iterable,%20T))；[FluentIterable.last()](http://docs.guava-libraries.googlecode.com/git-history/release12/javadoc/com/google/common/collect/FluentIterable.html#last())
[elementsEqual(Iterable, Iterable)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#elementsEqual(java.lang.Iterable,%20java.lang.Iterable))|如果两个iterable中的所有元素相等且顺序一致，返回true|与List.equals(Object)比较
[unmodifiableIterable(Iterable)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#unmodifiableIterable(java.lang.Iterable))|返回iterable的不可变视图|与Collections. unmodifiableCollection(Collection)比较
[limit(Iterable, int)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#limit(java.lang.Iterable,%20int))|限制从iterable返回的元素个数|[FluentIterable.limit(int)](http://docs.guava-libraries.googlecode.com/git-history/release12/javadoc/com/google/common/collect/FluentIterable.html#limit(int))
[getOnlyElement(Iterable)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#getOnlyElement(java.lang.Iterable))|获取iterable中唯一的元素，如果iterable为空或有多个元素，则快速失败|[getOnlyElement(Iterable, T default)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Iterables.html#getOnlyElement(java.lang.Iterable,%20T))

*译者注：懒视图意味着如果还没访问到某个iterable中的元素，则不会对它进行串联操作。
```
Iterable<Integer> concatenated = Iterables.concat(
  Ints.asList(1, 2, 3),
  Ints.asList(4, 5, 6));
// concatenated has elements 1, 2, 3, 4, 5, 6

String lastAdded = Iterables.getLast(myLinkedHashSet);

String theElement = Iterables.getOnlyElement(thisSetIsDefinitelyASingleton);
  // if this set isn't a singleton, something is wrong!
```
#### 2.2 与Collection方法相似的工具方法
通常来说，Collection的实现天然支持操作其它Collection，但却不能操作Iterable。

下面的方法中，如果传入的Iterable是一个Collection实例，则实际操作将会委托给相应的Collection接口方法。例如，往Iterables.size方法传入是一个Collection实例，它不会真的遍历iterator获取大小，而是直接调用Collection.size。

方法|类似的Collection方法|等价的FluentIterable方法
-----------|----------------|---------
[addAll(Collection addTo, Iterable toAdd)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#addAll-java.util.Collection-java.lang.Iterable-)|Collection.addAll(Collection)|	
[contains(Iterable, Object)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#contains-java.lang.Iterable-java.lang.Object-)|Collection.contains(Object)|[FluentIterable.contains(Object)](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#contains-java.lang.Object-)
[removeAll(Iterable removeFrom, Collection toRemove)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#removeAll-java.lang.Iterable-java.util.Collection-)|Collection.removeAll(Collection)|	
[retainAll(Iterable removeFrom, Collection toRetain)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#retainAll-java.lang.Iterable-java.util.Collection-)|Collection.retainAll(Collection)|	
[size(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#size-java.lang.Iterable-)|Collection.size()|[FluentIterable.size()](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#size--)
[toArray(Iterable, Class)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#toArray-java.lang.Iterable-java.lang.Class-)|Collection.toArray(T[])|[FluentIterable.toArray(Class)](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#toArray-java.lang.Class-)
[isEmpty(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#isEmpty-java.lang.Iterable-)|Collection.isEmpty()|[FluentIterable.isEmpty()](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#isEmpty--)
[get(Iterable, int)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#get-java.lang.Iterable-int-)|List.get(int)|[FluentIterable.get(int)](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#get-int-)
[toString(Iterable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#toString-java.lang.Iterable-)|Collection.toString()|[FluentIterable.toString()](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#toString--)
#### 2.3 FluentIterable
### 3. Lists
### 4. Sets
### 5. Maps
### 6. BiMap工具
### 7. Multisets
### 8. Multimaps
### 9. Tables

## Reference
- [Collection Utilities](https://github.com/google/guava/wiki/CollectionUtilitiesExplained)