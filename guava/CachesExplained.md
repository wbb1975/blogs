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
#### 3.1 CacheLoader
#### 3.2 Callable
#### 3.3 显式插入
### 4. 缓存回收
### 5. 适用性
### 6. 适用性
### 7. 适用性
### 8. 适用性
### 9. 适用性
### 10. 适用性

## Reference
- [Caches Explained](https://github.com/google/guava/wiki/CachesExplained)