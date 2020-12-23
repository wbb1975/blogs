# Introduction to Caffeine
## 1. 简介
在本文中我们将看看[Caffeine](https://github.com/ben-manes/caffeine)--一款高性能Java缓存库。一个缓存和一个Map最基本的区别在于缓存可以回收存储的项。**回收策略决定了在任意给定时间什么对象将会被删除**。缓存策略**直接影响了缓存的命中率**--缓存库的一个关键特征。

Caffeine 使用 `Window TinyLfu` 回收策略--它提供了一个**接近最优的缓存命中率**（near-optimal hit rate.）。
## 2. 依赖
我们需要将caffeine 依赖加入到我们的pom.xml：
```
<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
    <version>2.5.5</version>
</dependency>
```
你可以在[Maven Central](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22com.github.ben-manes.caffeine%22%20AND%20a%3A%22caffeine%22)上找到caffeine的最新版本。
## 3. 填充Cache（Populating Cache）
让我们来关注Caffeine的**三种缓存填充战略**：手动，同步加载和异步加载。

首先，让我们写一个类来作为我们缓存的值的类型：
```
class DataObject {
    private final String data;

    private static int objectCounter = 0;
    // standard constructors/getters
    
    public static DataObject get(String data) {
        objectCounter++;
        return new DataObject(data);
    }
}
```
### 3.1 手动填充
在这个战略中，我们手动将值放置到缓存并在稍后检索它。

让我们初始化我们的缓存：
```
Cache<String, DataObject> cache = Caffeine.newBuilder()
  .expireAfterWrite(1, TimeUnit.MINUTES)
  .maximumSize(100)
  .build();
```
现在，**我们可以使用 getIfPresent 方法从缓存里取出一些值**，如果该值不在缓存里，则该方法将返回null。
```
String key = "A";
DataObject dataObject = cache.getIfPresent(key);

assertNull(dataObject);
```

我们可以使用put方法**手动填充缓存**：
```
cache.put(key, dataObject);
dataObject = cache.getIfPresent(key);

assertNotNull(dataObject);
```
**我们也可以使用get方法取值**，除了键（key），它带有一个Function 作为参数。这个Function 将被作为该键在缓存中不存在时提供 fallback 值，它将会计算后被插入到缓存中：
```
dataObject = cache.get(key, k -> DataObject.get("Data for A"));

assertNotNull(dataObject);
assertEquals("Data for A", dataObject.getData());
```
get方法自动执行计算。这意味着计算将被仅仅执行一次--即使多个线程在同时请求同一个值。这就是 **get 应该优先于 getIfPresent 被使用的原因**。

有时候我们需要**手动使得某些缓存值无效**：
```
cache.invalidate(key);
dataObject = cache.getIfPresent(key);

assertNull(dataObject);
```
### 3.2 同步加载
这种缓存加载的方法需要一个 Function，它被用于初始化值，就像手动战略里的 get 方法。让我们来查看如何使用它。

首先，我们需要初始化缓存：
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .maximumSize(100)
  .expireAfterWrite(1, TimeUnit.MINUTES)
  .build(k -> DataObject.get("Data for " + k));
```
现在，我们可以使用get方法来检索值：
```
DataObject dataObject = cache.get(key);

assertNotNull(dataObject);
assertEquals("Data for " + key, dataObject.getData());
```
我们也可以使用 getAll 方法来检索一个值得集合：
```
Map<String, DataObject> dataObjectMap 
  = cache.getAll(Arrays.asList("A", "B", "C"));

assertEquals(3, dataObjectMap.size());
```
值从底层后端初始化方法 Function 检索而来，并被传递给 build 方法。**这使得缓存可被作为访问值的主要门面**。
### 3.3 异步加载
该战略和上面一样运行，**但它执行异步操作并返回一个CompletableFuture 来持有实际的值**。
```
AsyncLoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .maximumSize(100)
  .expireAfterWrite(1, TimeUnit.MINUTES)
  .buildAsync(k -> DataObject.get("Data for " + k));
```
我们可以**以同样的方式使用get和getAll方法**，除了需要考虑到这个事实--它们返回CompletableFuture：
```
String key = "A";

cache.get(key).thenAccept(dataObject -> {
    assertNotNull(dataObject);
    assertEquals("Data for " + key, dataObject.getData());
});

cache.getAll(Arrays.asList("A", "B", "C"))
  .thenAccept(dataObjectMap -> assertEquals(3, dataObjectMap.size()));
```
CompletableFuture 拥有丰富易用的API。你可以在[这篇文章](https://www.baeldung.com/java-completablefuture)中了解到更多。
## 4. 值回收（Eviction of Values）
Caffeine 提供了回收值得三种战略：基于大小，基于时间，基于引用。
### 4.1 基于大小
这种类型的回收**假设当一个配置的缓存大小限制被超过时发生**。有两种方式来获取缓存大小：缓存中的对象数目，或者他们的权重。

让我们看看如何**计算缓存中的对象数目**。当缓存被初始化时，它的大小为0：
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .maximumSize(1)
  .build(k -> DataObject.get("Data for " + k));

assertEquals(0, cache.estimatedSize());
```
当加进一个值后，显然大小将增加1：
```
cache.get("A");

assertEquals(1, cache.estimatedSize());
```
我们可以向缓存中添加第二个值，这将导致第一个值被移除：
```
cache.get("B");
cache.cleanUp();

assertEquals(1, cache.estimatedSize());
```
这里值得提到**在获取缓存大小之前我们调用了 cleanUp 方法**。这是因为缓存回收是异步执行的，这个方法将**等到回收执行完成**。

我们也可传递 weigher 方法来获取缓存的大小。
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .maximumWeight(10)
  .weigher((k,v) -> 5)
  .build(k -> DataObject.get("Data for " + k));

assertEquals(0, cache.estimatedSize());

cache.get("A");
assertEquals(1, cache.estimatedSize());

cache.get("B");
assertEquals(2, cache.estimatedSize());
```
当权重超过10后值将被冲缓存中移除：
```
cache.get("C");
cache.cleanUp();

assertEquals(2, cache.estimatedSize());
```
### 4.2 基于时间
这个回收战略基于缓存项的过期时间，它有3种类型：
- 访问后过期--缓存项自上次读或写访问后经过一个固定的期限
- 写后过期--缓存项自上次写访问后经过一个固定的期限
- 自定义策略--每个缓存项的过期时间都是由Expiry 实现独立计算出来的

让我们使用expireAfterAccess 方法来配置访问后过期战略：
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .expireAfterAccess(5, TimeUnit.MINUTES)
  .build(k -> DataObject.get("Data for " + k));
```
使用 expireAfterWrite 方法可以配置写后过期战略：
```
cache = Caffeine.newBuilder()
  .expireAfterWrite(10, TimeUnit.SECONDS)
  .weakKeys()
  .weakValues()
  .build(k -> DataObject.get("Data for " + k));
```
为了初始化自定义策略，我们需要实现一个Expiry 接口：
```
cache = Caffeine.newBuilder().expireAfter(new Expiry<String, DataObject>() {
    @Override
    public long expireAfterCreate(
      String key, DataObject value, long currentTime) {
        return value.getData().length() * 1000;
    }
    @Override
    public long expireAfterUpdate(
      String key, DataObject value, long currentTime, long currentDuration) {
        return currentDuration;
    }
    @Override
    public long expireAfterRead(
      String key, DataObject value, long currentTime, long currentDuration) {
        return currentDuration;
    }
}).build(k -> DataObject.get("Data for " + k));
```
### 4.3 基于引用
我们可以配置缓存缓存键和/或缓存值被垃圾回收。为了实现这个，我们需要配置 WeakRefence 用于键和值，我们也可配置SoftReference 仅仅垃圾回收缓存值。

使用 WeakRefence 可以在没有强引用指向对象时回收对像。SoftReference 可以基于JVM的全局最少使用（Least-Recently-Used） 战略回收对像。[这里](https://www.baeldung.com/java-weakhashmap)有更多有关Java引用的细节资料。

我们可以使用Caffeine.weakKeys(), Caffeine.weakValues(), and Caffeine.softValues() 来开启每一个选项：
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .expireAfterWrite(10, TimeUnit.SECONDS)
  .weakKeys()
  .weakValues()
  .build(k -> DataObject.get("Data for " + k));

cache = Caffeine.newBuilder()
  .expireAfterWrite(10, TimeUnit.SECONDS)
  .softValues()
  .build(k -> DataObject.get("Data for " + k));
```
## 5. 刷新（Refreshing）
可以定义缓存在一个定义好的期限后自动刷新缓存项。让我们查看如何使用refreshAfterWrite 来实现它：
```
Caffeine.newBuilder()
  .refreshAfterWrite(1, TimeUnit.MINUTES)
  .build(k -> DataObject.get("Data for " + k));
```
这里我们应该理解expireAfter 和 refreshAfter的差别。当一个过期的缓存项被请求时，执行将被堵塞直到一个新的值被Function计算出来。

但是如果缓存项对刷新保持弹性，那么缓存将返回一个旧的值并异步加载新值。
## 6. （缓存）统计
Caffeine 有办法记录缓存使用的统计信息：
```
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
  .maximumSize(100)
  .recordStats()
  .build(k -> DataObject.get("Data for " + k));
cache.get("A");
cache.get("A");

assertEquals(1, cache.stats().hitCount());
assertEquals(1, cache.stats().missCount());
```
我们有可能传递进一个recordStats提供者，它创建StatsCounter的一个实现。这个对象将会被知会每一个事关统计的修改。
## 7. 结论
在本文中，我们熟悉了Java缓存库Caffeine。我们看到了如何配置一个缓存，填充缓存，以及怎么根据我们的需求选择合适的过期策略及涮新策略。本文中的源代码可以在[这里](https://github.com/eugenp/tutorials/tree/master/libraries-5)获取到。

## REference
- [Introduction to Caffeine](https://www.baeldung.com/java-caching-caffeine)
- [Guide To CompletableFuture](https://www.baeldung.com/java-completablefuture)
- [Spring Boot and Caffeine Cache](https://www.baeldung.com/spring-boot-caffeine-cache)