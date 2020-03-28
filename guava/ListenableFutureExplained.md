## ListenableFuture
并发编程是一个难题，但是一个强大而简单的抽象可以显著的简化并发的编写。出于这样的考虑，Guava 定义了 [ListenableFuture](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/ListenableFuture.html)接口并继承了JDK concurrent包下的Future 接口。

我们强烈地建议你在代码中多使用ListenableFuture来代替JDK的 Future, 因为：
+ 大多数Futures 方法中需要它。
+ 转到ListenableFuture 编程比较容易。
+ Guava提供的通用公共类封装了公共的操作方方法，不需要提供Future和ListenableFuture的扩展方法。
### 1. 接口
传统JDK中的Future代表一个异步计算的返回结果:该计算可能已经结束运算并返回结果，或者尚未结束运算。Future是运行中的一个运算的引用句柄，确保在服务执行完成后返回一个结果。

ListenableFuture可以允许你注册回调方法(callbacks)，在运算（多线程执行）完成的时候进行调用,  或者在运算（多线程执行）已经完成后立即执行。这样简单的改进，使得可以明显的支持更多的操作，这样的功能在JDK concurrent中的Future是不支持的。

ListenableFuture 中的基础方法是[addListener(Runnable, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/ListenableFuture.html#addListener-java.lang.Runnable-java.util.concurrent.Executor-), 该方法会在由Future代表的多线程运算结束的时候，由指定的Runnable参数传入的对象会被指定的Executor执行。
### 2. 添加回调（Callbacks）
多数用户喜欢使用[Futures.addCallback(ListenableFuture<V>, FutureCallback<V>, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#addCallback-com.google.common.util.concurrent.ListenableFuture-com.google.common.util.concurrent.FutureCallback-java.util.concurrent.Executor-)。FutureCallback<V> 中实现了两个方法：
- [onSuccess(V)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/FutureCallback.html#onSuccess-V-),在Future成功的时候执行，根据Future结果来判断。
- [onFailure(Throwable)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/FutureCallback.html#onFailure-java.lang.Throwable-), 在Future失败的时候执行，根据Future结果来判断。
### 3. ListenableFuture的创建
对应JDK中的[ExecutorService.submit(Callable)](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html#submit-java.util.concurrent.Callable-) 提交多线程异步运算的方式，Guava 提供了[ListeningExecutorService](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/ListeningExecutorService.html)接口, 该接口返回 ListenableFuture， 而相应的 ExecutorService 返回普通的 Future。将 ExecutorService 转为 ListeningExecutorService，可以使用[MoreExecutors.listeningDecorator(ExecutorService)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/MoreExecutors.html#listeningDecorator-java.util.concurrent.ExecutorService-)进行装饰。
```
ListeningExecutorService service = MoreExecutors.listeningDecorator(Executors.newFixedThreadPool(10));
ListenableFuture<Explosion> explosion = service.submit(
    new Callable<Explosion>() {
      public Explosion call() {
        return pushBigRedButton();
      }
    });
Futures.addCallback(
    explosion,
    new FutureCallback<Explosion>() {
      // we want this handler to run immediately after we push the big red button!
      public void onSuccess(Explosion explosion) {
        walkAwayFrom(explosion);
      }
      public void onFailure(Throwable thrown) {
        battleArchNemesis(); // escaped the explosion!
      }
    },
    service);
```

另外, 假如你是从[FutureTask](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/FutureTask.html)转换而来的, Guava 提供[ListenableFutureTask.create(Callable<V>)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/ListenableFutureTask.html#create-java.util.concurrent.Callable-) 和[ListenableFutureTask.create(Runnable, V)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/ListenableFutureTask.html#create-java.lang.Runnable-V-)， 和 JDK不同的是，ListenableFutureTask 不能随意被继承。

假如你喜欢抽象的方式来设置future的值，而不是想实现接口中的方法，可以考虑继承抽象类[AbstractFuture<V>](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/AbstractFuture.html) 或者直接使用[SettableFuture](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/SettableFuture.html) 。

假如你必须将其他API提供的Future转换成 ListenableFuture，你没有别的方法只能采用硬编码的方式[JdkFutureAdapters.listenInPoolThread(Future)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/JdkFutureAdapters.html)来将 Future 转换成 ListenableFuture。尽可能地采用修改原生的代码返回 ListenableFuture会更好一些。
### 4. Application
使用ListenableFuture 最重要的理由是它可以进行一系列的复杂链式的异步操作。
```
ListenableFuture<RowKey> rowKeyFuture = indexService.lookUp(query);
AsyncFunction<RowKey, QueryResult> queryFunction =
  new AsyncFunction<RowKey, QueryResult>() {
    public ListenableFuture<QueryResult> apply(RowKey rowKey) {
      return dataService.read(rowKey);
    }
  };
ListenableFuture<QueryResult> queryFuture =
    Futures.transformAsync(rowKeyFuture, queryFunction, queryExecutor);
```
其它更多的操作可以更加有效的被ListenableFuture支持，而JDK中的Future是没法支持的。不同的操作可以在不同的Executors中执行，单独的ListenableFuture 可以有多个操作等待。

当一个操作开始的时候其他的一些操作也会尽快开始执行–“fan-out”–ListenableFuture 能够满足这样的场景：促发所有的回调（callbacks）。借助稍微多一点的工作，我们可以利用满足“fan-in”场景，促发ListenableFuture 获取（get）计算结果，同时其它的Futures也会尽快执行：可以参考[the implementation of Futures.allAsList](https://google.github.io/guava/releases/snapshot/api/docs/src-html/com/google/common/util/concurrent/Futures.html#line.1276) 。（译者注：fan-in和fan-out是软件设计的一个术语，可以参考这里：http://baike.baidu.com/view/388892.htm#1或者看这里的解析Design Principles: Fan-In vs Fan-Out，这里fan-out的实现就是封装的ListenableFuture通过回调，调用其它代码片段。fan-in的意义是可以调用其它Future）。

方法|描述|参考
--------|--------|--------
[transform(ListenableFuture<A>, AsyncFunction<A, B>, Executor) *](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transformAsync-com.google.common.util.concurrent.ListenableFuture-com.google.common.util.concurrent.AsyncFunction-java.util.concurrent.Executor-)|返回一个新的ListenableFuture ，该ListenableFuture 返回的result是由传入的AsyncFunction 参数指派到传入的 ListenableFuture中|[transform(ListenableFuture<A>, AsyncFunction<A, B>)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transformAsync-com.google.common.util.concurrent.ListenableFuture-com.google.common.util.concurrent.AsyncFunction-)
[transform(ListenableFuture<A>, Function<A, B>, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transform-com.google.common.util.concurrent.ListenableFuture-com.google.common.base.Function-java.util.concurrent.Executor-)|返回一个新的ListenableFuture ，该ListenableFuture 返回的result是由传入的Function 参数指派到传入的 ListenableFuture中|[transform(ListenableFuture<A>, Function<A, B>)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transform-com.google.common.util.concurrent.ListenableFuture-com.google.common.base.Function-)
[allAsList(Iterable<ListenableFuture<V>>)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#allAsList-java.lang.Iterable-)|返回一个ListenableFuture ，该ListenableFuture 返回的result是一个List，List中的值是每个ListenableFuture的返回值，假如传入的其中之一fails或者cancel，这个Future fails 或者canceled|[allAsList(ListenableFuture<V>...)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#allAsList-com.google.common.util.concurrent.ListenableFuture...-)
[successfulAsList(Iterable<ListenableFuture<V>>)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#successfulAsList-java.lang.Iterable-)|返回一个ListenableFuture ，该Future的结果包含所有成功的Future，按照原来的顺序，当其中之一Failed或者cancel，则用null替代|[successfulAsList(ListenableFuture<V>...)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#successfulAsList-com.google.common.util.concurrent.ListenableFuture...-)

* [AsyncFunction<A, B>](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/AsyncFunction.html) 中提供一个方法ListenableFuture<B> apply(A input)，它可以被用于异步变换值。

```
List<ListenableFuture<QueryResult>> queries;
// The queries go to all different data centers, but we want to wait until they're all done or failed.

ListenableFuture<List<QueryResult>> successfulQueries = Futures.successfulAsList(queries);

Futures.addCallback(successfulQueries, callbackOnSuccessfulQueries);
```
### 5. CheckedFuture
Guava也提供了 CheckedFuture<V, X extends Exception> 接口。CheckedFuture 是一个ListenableFuture ，其中包含了多个版本的get 方法，方法声明抛出检查异常.这样使得创建一个在执行逻辑中可以抛出异常的Future更加容易 。将 ListenableFuture 转换成CheckedFuture，可以使用 Futures.makeChecked(ListenableFuture<V>, Function<Exception, X>)。
### 6. 避免Future嵌套
mouxie情况下代码调用了一个通用接口并返回一个Future，有可能出现返回嵌套Future的情况，比如：
```
executorService.submit(new Callable<ListenableFuture<Foo>() {
  @Override
  public ListenableFuture<Foo> call() {
    return otherExecutorService.submit(otherCallable);
  }
});
```
这将返回一个ListenableFuture<ListenableFuture<Foo>>。代码是不正确的，因为取消外部Future与五宝Future的完成存在竞争，并且取消操作不会扩散到内部Future。使用get()或者一个监听器来检查其它Future的失败状态是一种常见错误，除非特别注意，否则从otherCallable抛出的异常通常会被丢弃。为了避免这个，Guava's future的所有方法（某些来自于JDK）拥有安全解包嵌套调用的异步版本--[transform(ListenableFuture<A>, Function<A, B>, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transform-com.google.common.util.concurrent.ListenableFuture-com.google.common.base.Function-java.util.concurrent.Executor-)，和 [transformAsync(ListenableFuture<A>, AsyncFunction<A, B>, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#transformAsync-com.google.common.util.concurrent.ListenableFuture-com.google.common.util.concurrent.AsyncFunction-java.util.concurrent.Executor-), 或 [ExecutorService.submit(Callable)](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html#submit-java.util.concurrent.Callable-) 和 [submitAsync(AsyncCallable<A>, Executor)](https://google.github.io/guava/releases/snapshot/api/docs/com/google/common/util/concurrent/Futures.html#submitAsync-com.google.common.util.concurrent.AsyncCallable-java.util.concurrent.Executor-)等。

## Reference
- [ListenableFuture Explained](https://github.com/google/guava/wiki/ListenableFutureExplained)