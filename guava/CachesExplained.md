## 缓存
### 1. 范例
```
LoadingCache<Key, Graph> graphs = CacheBuilder.newBuilder()
       .maximumSize(1000)
       .expireAfterWrite(10, TimeUnit.MINUTES)
       .removalListener(MY_LISTENER)
       .build(
           new CacheLoader<Key, Graph>() {
             @Override
             public Graph load(Key key) throws AnyException {
               return createExpensiveGraph(key);
             }
           });
```
### 2. 适用性
缓存在很多场景下都是相当有用的。例如，计算或检索一个值的代价很高，并且对同样的输入需要不止一次获取值的时候，就应当考虑使用缓存。

Guava Cache与ConcurrentMap很相似，但也不完全一样。最基本的区别是ConcurrentMap会一直保存所有添加的元素，直到显式地移除。相对地，Guava Cache为了限制内存占用，通常都设定为自动回收元素。在某些场景下，尽管LoadingCache 不回收元素，它也是很有用的，因为它会自动加载缓存。

通常来说，Guava Cache适用于：
- 你愿意消耗一些内存空间来提升速度。
- 你预料到某些键会被查询一次以上。
- 缓存中存放的数据总量不会超出内存容量。（Guava Cache是单个应用运行时的本地缓存。它不把数据存放到文件或外部服务器。如果这不符合你的需求，请尝试[Memcached](http://memcached.org/)这类工具）
如果你的场景符合上述的每一条，Guava Cache就适合你。

如同范例代码展示的一样，Cache实例通过CacheBuilder生成器模式获取，但是自定义你的缓存才是最有趣的部分。

> **注**：如果你不需要Cache中的特性，使用ConcurrentHashMap有更好的内存效率——但Cache的大多数特性都很难基于旧有的ConcurrentMap复制，甚至根本不可能做到。
### 3. 加载（Population）
在使用缓存前，首先问自己一个问题：有没有合理的默认方法来加载或计算与键关联的值？如果有的话，你应当使用CacheLoader。如果没有，或者你想要覆盖默认的加载运算，并且想同时保留“获取缓存-如果没有-则计算"（get-if-absent-compute）的原子语义，那么你应该在调用get时传入一个Callable实例。缓存元素可以通过Cache.put方法直接插入，但自动加载是首选的，因为它可以更容易地推断所有缓存内容的一致性。
#### 3.1 CacheLoader
LoadingCache是利用附带[CacheLoader](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/cache/CacheLoader.html)构建而成的缓存实现。创建自己的CacheLoader通常只需要简单地实现V load(K key) throws Exception方法。例如，你可以用下面的代码构建LoadingCache：
```
LoadingCache<Key, Graph> graphs = CacheBuilder.newBuilder()
       .maximumSize(1000)
       .build(
           new CacheLoader<Key, Graph>() {
             public Graph load(Key key) throws AnyException {
               return createExpensiveGraph(key);
             }
           });

...
try {
  return graphs.get(key);
} catch (ExecutionException e) {
  throw new OtherException(e.getCause());
}
```
从LoadingCache查询的正规方式是使用[get(K)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/cache/LoadingCache.html#get-K-)方法。这个方法要么返回已经缓存的值，要么使用CacheLoader向缓存原子地加载新值。由于CacheLoader可能抛出异常，LoadingCache.get(K)也声明为抛出ExecutionException异常。如果你定义的CacheLoader没有声明任何检查型异常，则可以通过getUnchecked(K)查找缓存；但必须注意，一旦CacheLoader声明了检查型异常，就不可以调用getUnchecked(K)。
```
LoadingCache<Key, Graph> graphs = CacheBuilder.newBuilder()
       .expireAfterAccess(10, TimeUnit.MINUTES)
       .build(
           new CacheLoader<Key, Graph>() {
             public Graph load(Key key) { // no checked exception
               return createExpensiveGraph(key);
             }
           });

...
return graphs.getUnchecked(key);
```
getAll(Iterable<? extends K>)方法用来执行批量查询。默认情况下，对每个不在缓存中的键，getAll方法会单独调用CacheLoader.load来加载缓存项。如果批量的加载比多个单独加载更高效，你可以重载CacheLoader.loadAll来利用这一点。getAll(Iterable)的性能也会相应提升。

> **注**：CacheLoader.loadAll的实现可以为没有明确请求的键加载缓存值。例如，为某组中的任意键计算值时，能够获取该组中的所有键值，loadAll方法就可以实现为在同一时间获取该组的其他键值。校注：getAll(Iterable<? extends K>)方法会调用loadAll，但会筛选结果，只会返回请求的键值对。
#### 3.2 Callable
所有类型的Guava Cache，不管有没有自动加载功能，都支持get(K, Callable<V>)方法。这个方法返回缓存中相应的值，或者用给定的Callable运算并把结果加入到缓存中。在整个加载方法完成前，缓存项相关的可观察状态都不会更改。这个方法简便地实现了模式"如果有缓存则返回；否则运算、缓存、然后返回"（"if cached, return; otherwise create, cache and return"）。
```
Cache<Key, Value> cache = CacheBuilder.newBuilder()
    .maximumSize(1000)
    .build(); // look Ma, no CacheLoader
...
try {
  // If the key wasn't in the "easy to compute" group, we need to
  // do things the hard way.
  cache.get(key, new Callable<Value>() {
    @Override
    public Value call() throws AnyException {
      return doThingsTheHardWay(key);
    }
  });
} catch (ExecutionException e) {
  throw new OtherException(e.getCause());
}
```
#### 3.3 显式插入
使用[cache.put(key, value)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/cache/Cache.html#put-K-V-)方法可以直接向缓存中插入值，这会直接覆盖掉给定键之前映射的值。使用Cache.asMap()视图提供的任何方法也能修改缓存。但请注意，asMap视图的任何方法都不能保证缓存项被原子地加载到缓存中。进一步说，asMap视图的原子运算在Guava Cache的原子加载范畴之外，所以相比于Cache.asMap().putIfAbsent(K,
V)，Cache.get(K, Callable<V>) 应该总是优先使用。
### 4. 缓存回收（Eviction）
一个残酷的现实是，我们几乎一定没有足够的内存缓存所有数据。你你必须决定：什么时候某个缓存项就不值得保留了？Guava Cache提供了三种基本的缓存回收方式：基于容量回收、定时回收和基于引用回收。
#### 4.1 基于容量的回收（size-based eviction）
#### 4.2 定时回收（Timed Eviction）
#### 4.3 基于引用的回收（Reference-based Eviction）
#### 4.4 显式清除
#### 4.5 移除监听器
#### 4.6 清理什么时候发生？
#### 4.7 刷新
### 5. 其他特性（Features）
### 6. 中断（Interruption）


## Reference
- [Caches Explained](https://github.com/google/guava/wiki/CachesExplained)