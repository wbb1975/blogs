## 集合扩展工具类（Collection Helpers）
有时候你需要实现自己的集合扩展。也许你想要在元素被添加到列表时增加特定的行为，或者你想实现一个Iterable，其底层实际上是遍历数据库查询的结果集。Guava为你，也为我们自己提供了若干工具方法，以便让类似的工作变得更简单。（毕竟，我们自己也要用这些工具扩展集合框架。）
### 1. Forwarding装饰器
针对所有类型的集合接口，Guava都提供了Forwarding抽象类以简化[装饰器模式](http://en.wikipedia.org/wiki/Decorator_pattern)的使用。

Forwarding抽象类定义了一个抽象方法：delegate()，你可以覆盖这个方法来返回被装饰对象。所有其他方法都会直接委托给delegate()。例如说：ForwardingList.get(int)实际上执行了delegate().get(int)。

通过创建ForwardingXXX的子类并实现delegate()方法，可以选择性地覆盖子类的方法来增加装饰功能，而不需要自己委托每个方法——译者注：因为所有方法都默认委托给delegate()返回的对象，你可以只覆盖需要装饰的方法。

此外，很多集合方法都对应一个”标准方法[standardMethod ]”实现，可以用来恢复被装饰对象的默认行为，以提供相同的优点。比如在扩展AbstractList或JDK中的其他骨架类时。

让我们看看这个例子。假定你想装饰一个List，让其记录所有添加进来的元素。当然，无论元素是用什么方法——add(int, E), add(E), 或addAll(Collection)——添加进来的，我们都希望进行记录，因此我们需要覆盖所有这些方法。
```
class AddLoggingList<E> extends ForwardingList<E> {
  final List<E> delegate; // backing list
  @Override protected List<E> delegate() {
    return delegate;
  }
  @Override public void add(int index, E elem) {
    log(index, elem);
    super.add(index, elem);
  }
  @Override public boolean add(E elem) {
    return standardAdd(elem); // implements in terms of add(int, E)
  }
  @Override public boolean addAll(Collection<? extends E> c) {
    return standardAddAll(c); // implements in terms of add
  }
}
```
记住，默认情况下，所有方法都直接转发到被代理对象，因此覆盖ForwardingMap.put并不会改变ForwardingMap.putAll的行为。小心覆盖所有需要改变行为的方法，并且确保装饰后的集合满足接口契约。

通常来说，类似于AbstractList的抽象集合骨架类，其大多数方法在Forwarding装饰器中都有对应的”标准方法”实现。

对提供特定视图的接口，Forwarding装饰器也为这些视图提供了相应的”标准方法”实现。例如，ForwardingMap提供StandardKeySet、StandardValues和StandardEntrySet类，它们在可以的情况下都会把自己的方法委托给被装饰的Map，把不能委托的声明为抽象方法。

接口|Forwarding装饰器类
---------|----------
Collection|[ForwardingCollection](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingCollection.html)
List|[ForwardingList](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingList.html)
Set|[ForwardingSet](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingSet.html)
SortedSet|[ForwardingSortedSet](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingSortedSet.html)
Map|[ForwardingMap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingMap.html)
SortedMap|[ForwardingSortedMap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingSortedMap.html)
ConcurrentMap|[ForwardingConcurrentMap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingConcurrentMap.html)
Map.Entry|[ForwardingMapEntry](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingMapEntry.html)
Queue|[ForwardingQueue](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingQueue.html)
Iterator|[ForwardingIterator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingIterator.html)
ListIterator|[ForwardingListIterator](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingListIterator.html)
Multiset|[ForwardingMultiset](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingMultiset.html)
Multimap|[ForwardingMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingMultimap.html)
ListMultimap|[ForwardingListMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingListMultimap.html)
SetMultimap|[ForwardingSetMultimap](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ForwardingSetMultimap.html)
### 2. PeekingIterator
### 3. AbstractIterator
### 4. AbstractSequentialIterator

## Reference
- [Collection Helpers Explained](https://github.com/google/guava/wiki/CollectionHelpersExplained)