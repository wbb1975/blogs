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
除了上面和函数式编程提到的方法，FluentIterable还有一些便利方法用来把自己拷贝到不可变集合：
结果类型|方法
----------|---------------
ImmutableList|[toImmutableList()](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#toImmutableList--)
ImmutableSet|[toImmutableSet()](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#toImmutableSet--)
ImmutableSortedSet|[toImmutableSortedSet(Comparator)](http://google.github.io/guava/releases/12.0/api/docs/com/google/common/collect/FluentIterable.html#toImmutableSortedSet-java.util.Comparator-)
### 3. Lists
除了静态工厂方法和函数式编程方法，Lists为List类型的对象提供了若干工具方法。

方法|描述
----------|---------------
[partition(List, int)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#partition-java.util.List-int-)|返回底层List的视图，把List按指定大小分割
[reverse(List)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#reverse-java.util.List-)|返回给定List的反转视图。注: 如果List是不可变的，考虑改用[ImmutableList.reverse()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ImmutableList.html#reverse--)。

```
List<Integer> countUp = Ints.asList(1, 2, 3, 4, 5);
List<Integer> countDown = Lists.reverse(theList); // {5, 4, 3, 2, 1}

List<List<Integer>> parts = Lists.partition(countUp, 2); // { {1, 2}, {3, 4}, {5} }
```
#### 3.1 静态工厂方法
Lists提供如下静态工厂方法：

具体实现类型|工厂方法
----------|---------------
ArrayList|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayList--), [with elements](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayList-E...-), [from Iterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayList-java.lang.Iterable-), [with exact capacity](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayListWithCapacity-int-), [with expected size](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayListWithExpectedSize-int-), [from Iterator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newArrayList-java.util.Iterator-)
LinkedList|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newLinkedList--), [from Iterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Lists.html#newLinkedList-java.lang.Iterable-)
### 4. Sets
[Sets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html)工具类包含了若干好用的方法。
#### 4.1 集合理论方法
我们提供了很多标准的集合运算（Set-Theoretic）方法，这些方法接受Set参数并返回[SetView](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.SetView.html)，可用于：
+ 直接当作Set使用，因为SetView也实现了Set接口；
+ 用[copyInto(Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.SetView.html#copyInto-S-)拷贝进另一个可变集合；
+ 用[immutableCopy()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.SetView.html#immutableCopy--)对自己做不可变拷贝。

方法|描述
----------|---------------
[union(Set, Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#union-java.util.Set-java.util.Set-)|
[intersection(Set, Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#intersection-java.util.Set-java.util.Set-)|
[difference(Set, Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#difference-java.util.Set-java.util.Set-)|
[symmetricDifference(Set, Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#symmetricDifference-java.util.Set-java.util.Set-)|

使用范例：
```
Set<String> wordsWithPrimeLength = ImmutableSet.of("one", "two", "three", "six", "seven", "eight");
Set<String> primes = ImmutableSet.of("two", "three", "five", "seven");

SetView<String> intersection = Sets.intersection(primes, wordsWithPrimeLength); // contains "two", "three", "seven"
// I can use intersection as a Set directly, but copying it can be more efficient if I use it a lot.
return intersection.immutableCopy();
```
#### 4.2 其他Set工具方法
方法|描述|另请参见
----------|---------------|---------------
[cartesianProduct(List<Set>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#cartesianProduct-java.util.List-)|返回所有集合的笛卡儿积|[cartesianProduct(Set...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#cartesianProduct-java.util.Set...-)
[powerSet(Set)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#powerSet-java.util.Set-)|返回给定集合的所有子集

```
Set<String> animals = ImmutableSet.of("gerbil", "hamster");
Set<String> fruits = ImmutableSet.of("apple", "orange", "banana");

Set<List<String>> product = Sets.cartesianProduct(animals, fruits);
// { {"gerbil", "apple"}, {"gerbil", "orange"}, {"gerbil", "banana"},
//   {"hamster", "apple"}, {"hamster", "orange"}, {"hamster", "banana"} }

Set<Set<String>> animalSets = Sets.powerSet(animals);
// { {}, {"gerbil"}, {"hamster"}, {"gerbil", "hamster"} }
```
#### 4.3 静态工厂方法
Sets提供如下静态工厂方法：

具体实现类型|工厂方法
HashSet|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newHashSet--), [with elements](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newHashSet-E...-), [from Iterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newHashSet-java.lang.Iterable-), [with expected size](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newHashSetWithExpectedSize-int-), [from Iterator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newHashSet-java.util.Iterator-)
LinkedHashSet|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newLinkedHashSet--), [from Iterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newLinkedHashSet-java.lang.Iterable-), [with expected size](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newLinkedHashSetWithExpectedSize-int-)
TreeSet|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newTreeSet--), [with Comparator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newTreeSet-java.util.Comparator-), [from Iterable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Sets.html#newTreeSet-java.lang.Iterable-)
### 5. Maps
[Maps](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Maps.html)类有若干值得单独说明的、很酷的方法。
#### 5.1 uniqueIndex
[Maps.uniqueIndex(Iterable,Function)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#uniqueIndex-java.lang.Iterable-com.google.common.base.Function-)通常针对的场景是：有一组对象，它们在某个属性上分别有独一无二的值，而我们希望能够按照这个属性值查找对象——译者注：这个方法返回一个Map，键为Function返回的属性值，值为Iterable中相应的元素，因此我们可以反复用这个Map进行查找操作。

比方说，我们有一堆字符串，这些字符串的长度都是独一无二的，而我们希望能够按照特定长度查找字符串：
```
ImmutableMap<Integer, String> stringsByIndex = Maps.uniqueIndex(strings, new Function<String, Integer> () {
    public Integer apply(String string) {
      return string.length();
    }
  });
```
如果索引值不是独一无二的，请参见下面的Multimaps.index方法。
#### 5.2 difference
[Maps.difference(Map, Map)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#difference-java.util.Map-java.util.Map-)用来比较两个Map以获取所有不同点。该方法返回MapDifference对象，把不同点的维恩图(Venn diagram)分解为：

方法|描述
----------|---------------
[entriesInCommon()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/MapDifference.html#entriesInCommon--)|两个Map中都有的映射项，包括匹配的键与值
[entriesDiffering()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/MapDifference.html#entriesDiffering--)|键相同但是值不同值映射项。返回的Map的值类型为[MapDifference.ValueDifference](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/MapDifference.ValueDifference.html)，以表示左右两个不同的值
[entriesOnlyOnLeft()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/MapDifference.html#entriesOnlyOnLeft--)|键只存在于左边Map的映射项
[entriesOnlyOnRight()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/MapDifference.html#entriesOnlyOnRight--)|键只存在于右边Map的映射项

```
Map<String, Integer> left = ImmutableMap.of("a", 1, "b", 2, "c", 3);
Map<String, Integer> right = ImmutableMap.of("b", 2, "c", 4, "d", 5);
MapDifference<String, Integer> diff = Maps.difference(left, right);

diff.entriesInCommon(); // {"b" => 2}
diff.entriesDiffering(); // {"c" => (3, 4)}
diff.entriesOnlyOnLeft(); // {"a" => 1}
diff.entriesOnlyOnRight(); // {"d" => 5}
```
### 6. BiMap工具
Guava中处理BiMap的工具方法在Maps类中，因为BiMap也是一种Map实现。

BiMap工具方法|相应的Map工具方法
----------|---------------
[synchronizedBiMap(BiMap)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#synchronizedBiMap-com.google.common.collect.BiMap-)|Collections.synchronizedMap(Map)
[unmodifiableBiMap(BiMap)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#unmodifiableBiMap-com.google.common.collect.BiMap-)|Collections.unmodifiableMap(Map)
#### 6.1 静态工厂方法
Maps提供如下静态工厂方法：

具体实现类型|工厂方法
----------|---------------
HashMap|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newHashMap--), [from Map](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newHashMap-java.util.Map-), [with expected size](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newHashMapWithExpectedSize-int-)
LinkedHashMap|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newLinkedHashMap--), [from Map](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newLinkedHashMap-java.util.Map-)
TreeMap|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newTreeMap--), [from Comparator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newTreeMap-java.util.Comparator-), [from SortedMap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newTreeMap-java.util.SortedMap-)
EnumMap|[from Class](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newEnumMap-java.lang.Class-), [from Map](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newEnumMap-java.util.Map-)
ConcurrentMap|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newConcurrentMap--)
IdentityHashMap|[basic](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Maps.html#newIdentityHashMap--)
### 7. Multisets
标准的Collection操作会忽略Multiset重复元素的个数，而只关心元素是否存在于Multiset中，如containsAll方法。为此，[Multisets](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html)提供了若干方法，以顾及Multiset元素的重复性：

方法|说明|和Collection方法的区别
----------|---------------|---------------
[containsOccurrences(Multiset sup, Multiset sub)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#containsOccurrences-com.google.common.collect.Multiset-com.google.common.collect.Multiset-)|对任意o，如果sub.count(o)<=super.count(o)，返回true|Collection.containsAll忽略个数，而只关心sub的元素是否都在super中
[removeOccurrences(Multiset removeFrom, Multiset toRemove)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#removeOccurrences-com.google.common.collect.Multiset-com.google.common.collect.Multiset-)|对toRemove中的重复元素，仅在removeFrom中删除相同个数|Collection.removeAll移除所有出现在toRemove的元素
[retainOccurrences(Multiset removeFrom, Multiset toRetain)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#retainOccurrences-com.google.common.collect.Multiset-com.google.common.collect.Multiset-)|修改removeFrom，以保证任意o都符合removeFrom.count(o)<=toRetain.count(o)|Collection.retainAll保留所有出现在toRetain的元素
[i]ntersection(Multiset, Multiset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#intersection-com.google.common.collect.Multiset-com.google.common.collect.Multiset-)|返回两个multiset的交集|没有类似方法

```
Multiset<String> multiset1 = HashMultiset.create();
multiset1.add("a", 2);

Multiset<String> multiset2 = HashMultiset.create();
multiset2.add("a", 5);

multiset1.containsAll(multiset2); // returns true: all unique elements are contained,
  // even though multiset1.count("a") == 2 < multiset2.count("a") == 5
Multisets.containsOccurrences(multiset1, multiset2); // returns false

multiset2.removeOccurrences(multiset1); // multiset2 now contains 3 occurrences of "a"

multiset2.removeAll(multiset1); // removes all occurrences of "a" from multiset2, even though multiset1.count("a") == 2
multiset2.isEmpty(); // returns true
```

Multisets中的其他工具方法还包括：

方法|描述
----------|---------------
[copyHighestCountFirst(Multiset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#copyHighestCountFirst-com.google.common.collect.Multiset-)|返回Multiset的不可变拷贝，并将元素按重复出现的次数做降序排列
[unmodifiableMultiset(Multiset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#unmodifiableMultiset-com.google.common.collect.Multiset-)|返回Multiset的只读视图
[unmodifiableSortedMultiset(SortedMultiset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multisets.html#unmodifiableSortedMultiset-com.google.common.collect.SortedMultiset-)|返回SortedMultiset的只读视图

```
Multiset<String> multiset = HashMultiset.create();
multiset.add("a", 3);
multiset.add("b", 5);
multiset.add("c", 1);

ImmutableMultiset<String> highestCountFirst = Multisets.copyHighestCountFirst(multiset);

// highestCountFirst, like its entrySet and elementSet, iterates over the elements in order {"b", "a", "c"}
```
### 8. Multimaps
[Multimaps](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html)提供了若干值得单独说明的通用工具方法
#### 8.1 index
作为Maps.uniqueIndex的兄弟方法，[Multimaps.index(Iterable, Function)](http://docs.guava-libraries.googlecode.com/git-history/release/javadoc/com/google/common/collect/Multimaps.html#index(java.lang.Iterable,%20com.google.common.base.Function))通常针对的场景是：有一组对象，它们有共同的特定属性，我们希望按照这个属性的值查询对象，但属性值不一定是独一无二的。

比方说，我们想把字符串按长度分组。
```
ImmutableSet<String> digits = ImmutableSet.of(
    "zero", "one", "two", "three", "four",
    "five", "six", "seven", "eight", "nine");
Function<String, Integer> lengthFunction = new Function<String, Integer>() {
  public Integer apply(String string) {
    return string.length();
  }
};
ImmutableListMultimap<Integer, String> digitsByLength = Multimaps.index(digits, lengthFunction);
/*
 * digitsByLength maps:
 *  3 => {"one", "two", "six"}
 *  4 => {"zero", "four", "five", "nine"}
 *  5 => {"three", "seven", "eight"}
 */
```
#### 8.2 invertFrom
鉴于Multimap可以把多个键映射到同一个值（译者注：实际上这是任何map都有的特性），也可以把一个键映射到多个值，反转Multimap也会很有用。Guava 提供了[invertFrom(Multimap toInvert,
Multimap dest)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#invertFrom-com.google.common.collect.Multimap-M-)做这个操作，并且你可以自由选择反转后的Multimap实现。

注：如果你使用的是ImmutableMultimap，考虑改用[ImmutableMultimap.inverse()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ImmutableMultimap.html#inverse--)做反转。

```
ArrayListMultimap<String, Integer> multimap = ArrayListMultimap.create();
multimap.putAll("b", Ints.asList(2, 4, 6));
multimap.putAll("a", Ints.asList(4, 2, 1));
multimap.putAll("c", Ints.asList(2, 5, 3));

TreeMultimap<Integer, String> inverse = Multimaps.invertFrom(multimap, TreeMultimap.<String, Integer> create());
// note that we choose the implementation, so if we use a TreeMultimap, we get results in order
/*
 * inverse maps:
 *  1 => {"a"}
 *  2 => {"a", "b", "c"}
 *  3 => {"c"}
 *  4 => {"a", "b"}
 *  5 => {"c"}
 *  6 => {"b"}
 */
```
#### 8.3 forMap
想在Map对象上使用Multimap的方法吗？[forMap(Map)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#forMap-java.util.Map-)把Map包装成SetMultimap。这个方法特别有用，例如，与Multimaps.invertFrom结合使用，可以把多对一的Map反转为一对多的Multimap。

```
Map<String, Integer> map = ImmutableMap.of("a", 1, "b", 1, "c", 2);
SetMultimap<String, Integer> multimap = Multimaps.forMap(map);
// multimap maps ["a" => {1}, "b" => {1}, "c" => {2}]
Multimap<Integer, String> inverse = Multimaps.invertFrom(multimap, HashMultimap.<Integer, String> create());
// inverse maps [1 => {"a", "b"}, 2 => {"c"}]
```
#### 8.4 包装器
Multimaps提供了传统的包装方法，以及让你选择Map和Collection类型以自定义Multimap实现的工具方法。


Multimaps类型|只读包装|同步包装|自定义实现
----------|---------------|---------------|---------------
Multimap|[unmodifiableMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#unmodifiableMultimap-com.google.common.collect.Multimap-)|[synchronizedMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#synchronizedMultimap-com.google.common.collect.Multimap-)|[newMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#newMultimap-java.util.Map-com.google.common.base.Supplier-)
ListMultimap|[unmodifiableListMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#unmodifiableListMultimap-com.google.common.collect.ListMultimap-)|[synchronizedListMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#synchronizedListMultimap-com.google.common.collect.ListMultimap-)|[newListMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#newListMultimap-java.util.Map-com.google.common.base.Supplier-)
SetMultimap|[unmodifiableSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#unmodifiableSetMultimap-com.google.common.collect.SetMultimap-)[synchronizedSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#synchronizedSetMultimap-com.google.common.collect.SetMultimap-)|[newSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#newSetMultimap-java.util.Map-com.google.common.base.Supplier-)
SortedSetMultimap|[unmodifiableSortedSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#unmodifiableSortedSetMultimap-com.google.common.collect.SortedSetMultimap-)|[synchronizedSortedSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#synchronizedSortedSetMultimap-com.google.common.collect.SortedSetMultimap-)|]newSortedSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Multimaps.html#newSortedSetMultimap-java.util.Map-com.google.common.base.Supplier-)

自定义Multimap的方法允许你指定Multimap中的特定实现。但要注意的是：
+ Multimap假设对Map和Supplier产生的集合对象有完全所有权。这些自定义对象应避免手动更新，并且在提供给Multimap时应该是空的，此外还不应该使用软引用、弱引用或虚引用。
+ 无法保证修改了Multimap以后，底层Map的内容是什么样的。
+ 即使Map和Supplier产生的集合都是线程安全的，它们组成的Multimap也不能保证并发操作的线程安全性。并发读操作是工作正常的，但需要保证并发读写的话，请考虑用同步包装器解决。
+ 只有当Map、Supplier、Supplier产生的集合对象、以及Multimap存放的键值类型都是可序列化的，Multimap才是可序列化的。
+ Multimap.get(key)返回的集合对象和Supplier返回的集合对象并不是同一类型。但如果Supplier返回的是随机访问集合，那么Multimap.get(key)返回的集合也是可随机访问的。

请注意，用来自定义Multimap的方法需要一个Supplier参数，以创建崭新的集合。下面有个实现ListMultimap的例子——用TreeMap做映射，而每个键对应的多个值用LinkedList存储。
```
ListMultimap<String, Integer> myMultimap = Multimaps.newListMultimap(
  Maps.<String, Collection<Integer>>newTreeMap(),
  new Supplier<LinkedList<Integer>>() {
    public LinkedList<Integer> get() {
      return Lists.newLinkedList();
    }
  });
```
### 9. Tables
[Tables](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html)类提供了若干称手的工具方法。
#### 9.1 customTable
堪比Multimaps.newXXXMultimap(Map, Supplier)工具方法，[Tables.newCustomTable(Map, Supplier<Map>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html#newCustomTable-java.util.Map-com.google.common.base.Supplier-)允许你指定Table用什么样的map实现行和列。
```
// use LinkedHashMaps instead of HashMaps
Table<String, Character, Integer> table = Tables.newCustomTable(
  Maps.<String, Map<Character, Integer>>newLinkedHashMap(),
  new Supplier<Map<Character, Integer>> () {
    public Map<Character, Integer> get() {
      return Maps.newLinkedHashMap();
    }
  });
```
#### 9.2 transpose
[transpose(Table<R, C, V>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html#transpose-com.google.common.collect.Table-)方法允许你把Table<C, R, V>转置成Table<R, C, V>。例如，如果你在用Table构建加权有向图，这个方法就可以把有向图反转。
#### 9.3 包装器
还有很多你熟悉和喜欢的Table包装类。然而，在大多数情况下还请使用[ImmutableTable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ImmutableTable.html):
+ [unmodifiableTable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html#unmodifiableTable-com.google.common.collect.Table-)
+ [unmodifiableRowSortedTable](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Tables.html#unmodifiableRowSortedTable-com.google.common.collect.RowSortedTable-)

## Reference
- [Collection Utilities](https://github.com/google/guava/wiki/CollectionUtilitiesExplained)
