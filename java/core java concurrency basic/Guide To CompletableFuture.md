# CompletableFuture指南
## 1. 简介
本教程是Java 8 中作为并发API增强引入的CompletableFuture类的功能和用例的指南。
## 2. Java中的异步计算
异步计算难以推断。通常我们把任何计算视为一系列步骤，但对于异步计算，**以回调为代表的动作趋向于在代码中十分分散或者相互之间嵌套严重**。当任一步有错误发生，而我们都需要处理它们时，情况变得更糟。

Java 5 中引进的Future 接口服务于一个异步运算的结果，但它没有任何方法来绑定计算或处理可能的错误。

Java 8 引入了CompletableFuture类。与Future 接口一道，它也实现了CompletionStage 接口，该接口定义了异步计算步骤相互绑定的协议。

CompletableFuture 同时也是一个构件块和一个框架，它拥有约50个方法用于构造，绑定，执行异步计算步骤以及处理错误。

如此一个巨大的API理应难以掌握的，但它们大多数落入几个清晰且明确的用例。
## 3. 将 CompletableFuture 用做简单的 Future
首先，CompletableFuture 类实现了Future接口，因此我们可以将它**用做一个Future实现，但是需要额外的完成逻辑**。

例如，我们可以利用这个类的无参构造来构建一个该类的实例以代表某个将来的结果，将其传递给消费者，将在将来某个时间点利用 complete 方法来结束它。消费者可以使用 get 方法来堵塞当前线程直至结果被提供。

在下面的例子中，我们有一个方法创建了一个 CompletableFuture 实例，接下来在另一个线程摆脱（spins off）这些计算并立即返回一个Future。

当运算结束，通过提供结果给complete 方法来结束该Future：
```
public Future<String> calculateAsync() throws InterruptedException {
    CompletableFuture<String> completableFuture = new CompletableFuture<>();

    Executors.newCachedThreadPool().submit(() -> {
        Thread.sleep(500);
        completableFuture.complete("Hello");
        return null;
    });

    return completableFuture;
}
```
为了摆脱这些运算，我们使用了Executor API。该方法创建并标记结束（completing）一个 `CompletableFuture` ，该 `CompletableFuture` 可被用于任何并行机制和API，包括原始线程（raw threads）。

注意 **`calculateAsync` 方法返回一个 `Future` 实例**。

我们仅仅调用该方法返回一个 Future 实例，当我们已经准备堵塞以取得结果时我们将调用其 get 方法。

也观察到 get 会抛出某些受检异常，即ExecutionException （封装在运算中发生的一个异常）和InterruptedException（对应一个执行某个方法的线程被中断的异常）：
```
Future<String> completableFuture = calculateAsync();

// ... 

String result = completableFuture.get();
assertEquals("Hello", result);
```
如果我们已经知道了计算结果，我们可以使用completedFuture 静态方法并传递一个代表计算结果的参数，Future 的get方法将永远不会堵塞，取而代之是立即返回结果：
```
Future<String> completableFuture = 
  CompletableFuture.completedFuture("Hello");

// ...

String result = completableFuture.get();
assertEquals("Hello", result);
```
另一个场景下，我们可能想[取消Future的执行](https://www.baeldung.com/java-future#2-canceling-a-future-with-cancel)。
## 4. CompletableFuture 和包装的计算逻辑（CompletableFuture with Encapsulated Computation Logic）
上面的代码允许我们选择任何并行执行的机制，但如果我们向跳过上面的样板代码，仅仅想异步地执行某些代码呢？

静态方法 runAsync 和 supplyAsync 允许我们在对应的Runnable和Supplier函数类型（Supplier functional types）之外创建一个CompletableFuture 对象。

感谢新的Java 8特性Runnable 和 Supplier 都是函数接口（functional interfaces），并允许以Lambda表达式形式传递它们的实例。

Runnable 接口是时和线程中使用的一样老的接口，它不允许返回一个值。

Supplier 是一个泛型函数接口，它仅有一个方法，该方法没有参数，并返回一个参数化类型值。

这允许我们提供一个Lambda形式的Supplier 实例，并让其计算并返回结果。它很简单：
```
CompletableFuture<String> future
  = CompletableFuture.supplyAsync(() -> "Hello");

// ...

assertEquals("Hello", future.get());
```
## 5. 异步计算的结果处理（Processing Results of Asynchronous Computations）
最通用的处理一个运算结果的方法是将其传递给一个函数。`thenApply` 方法就是用于这个目的：它接受一个 `Function` 实例，用它去处理结果并返回一个 `Future` 来持有该函数返回的结果。
```
CompletableFuture<String> completableFuture
  = CompletableFuture.supplyAsync(() -> "Hello");

CompletableFuture<String> future = completableFuture
  .thenApply(s -> s + " World");

assertEquals("Hello World", future.get());
```
如果顺着 Future 链下来不需要返回值，我们可以使用 `Consumer` 函数接口的实例。它的单一方法接受一个参数并返回void。

在CompletableFuture中有一个方法可以用于该用例。`thenAccept` 方法接收一个 `Consumer` 并将运算结果传递给它。接下来最终的future.get() 将会返回一个 `Void` 类型实例。
```
CompletableFuture<String> completableFuture
  = CompletableFuture.supplyAsync(() -> "Hello");

CompletableFuture<Void> future = completableFuture
  .thenAccept(s -> System.out.println("Computation returned: " + s));

future.get();
```
最终，如果我们不需要运算结果，也不期待在调用链结尾返回某些值，那么我们可以传递一个`Runnable Lambda`实例给 `thenRun` 方法。在下面的例子中，我们仅仅在调用`future.get()`后在终端行打印了一条语句：
```
CompletableFuture<String> completableFuture 
  = CompletableFuture.supplyAsync(() -> "Hello");

CompletableFuture<Void> future = completableFuture
  .thenRun(() -> System.out.println("Computation finished."));

future.get();
```
## 6. 绑定 Futures (Combining Futures)
CompletableFuture API最好的部分是其绑定 CompletableFuture 实例到一条运算链的各个步骤的能力。

这条链的结果是 CompletableFuture 自身，它可继续用余链（接）和绑定。这种方式在函数式语言中有点歧义，通常被称为单体（monadic ）设计模式。

**在下面的例子中我们将使用 `thenCompose` 方法来顺序连接两个Future。**

注意该方法需要一个返回一个CompletableFuture 实例的函数对象。该函数对象的参数的参数是上一运算步骤的结果。这允许我们在下一个CompletableFuture的Lambda中使用该结果。
```
CompletableFuture<String> completableFuture 
  = CompletableFuture.supplyAsync(() -> "Hello")
    .thenCompose(s -> CompletableFuture.supplyAsync(() -> s + " World"));

assertEquals("Hello World", completableFuture.get());
```
`thenCompose` 方法与 `thenApply` 一起实现了单体模式的构建块。它们与Java 8中的Stream和可选的其它类中的 `map` 和 `flatMap` 紧密相关。

两个方法都接受一个函数（对象）并将其应用于计算结果。但 **`thenCompose` （flatMap）方法接受一个函数，该函数返回同一类型的不同对象**。这种函数结构将这些类的实例组成构建块。

如果我们向执行两个独立的Future并对它们的结果进行某种操作，我们可以使用 `thenCombine` 方法--它接受一个Future 和一个接受两个参数的函数（对象）来处理两个结果。
```
CompletableFuture<String> completableFuture 
  = CompletableFuture.supplyAsync(() -> "Hello")
    .thenCombine(CompletableFuture.supplyAsync(
      () -> " World"), (s1, s2) -> s1 + s2));

assertEquals("Hello World", completableFuture.get());
```
一个简单的用例是如果我们相对两个Futures的结果进行某种操作，但不需要顺着Future链传递任何结果值，`thenAcceptBoth` 可能有帮助：
```
CompletableFuture future = CompletableFuture.supplyAsync(() -> "Hello")
  .thenAcceptBoth(CompletableFuture.supplyAsync(() -> " World"),
    (s1, s2) -> System.out.println(s1 + s2));
```
## 7. thenApply() 和 thenCompose()的区别
在上面的章节中，我们已经展示了关于 `thenApply()` 和 `thenCompose()` 的例子。两个API都帮助建立不同 CompletableFuture 调用的链，但是两个方法使用是不同的。
### 7.1 thenApply()
**我们可以使用该方法工作于上次调用的结果**。但是，一个需要记住的关键点是返回类型是所有调用组合。

因此该方法在我们向转换一个 CompletableFuture 调用的结果时是很有用的。
```
CompletableFuture<Integer> finalResult = compute().thenApply(s-> s + 1);
```
### 7.2. thenCompose()
`thenCompose()` 方法与 `thenApply()` 在返回一个新的 CompletionStage 是相同的，但是**thenCompose() 使用上一个stage作为参数**。它将 `flatten` 并直接返回一个持有结果的Future，而不是一个像我们观察到的thenApply()的嵌套Future。
```
CompletableFuture<Integer> computeAnother(Integer i) {
    return CompletableFuture.supplyAsync(() -> 10 + i);
}
CompletableFuture<Integer> finalResult = compute().thenCompose(this::computeAnother);
```
因此如果出发点是建立CompletableFuture 链，那么使用thenCompose()会更好。

也应注意到这两个方法的差别与 [`map()` and `flatMap()`的差别](https://www.baeldung.com/java-difference-map-and-flatmap)类似。
## 8. 多个Futures并行运行（Running Multiple Futures in Parallel）
当我们向并行运行多个Future时，我们通常期望等到所有运算结束并返回它们组合的结果。

`CompletableFuture`的 `allOf` 静态方法将会等待直至作为可变参数传递的所有Future 结束。
```
CompletableFuture<String> future1  
  = CompletableFuture.supplyAsync(() -> "Hello");
CompletableFuture<String> future2  
  = CompletableFuture.supplyAsync(() -> "Beautiful");
CompletableFuture<String> future3  
  = CompletableFuture.supplyAsync(() -> "World");

CompletableFuture<Void> combinedFuture 
  = CompletableFuture.allOf(future1, future2, future3);

// ...

combinedFuture.get();

assertTrue(future1.isDone());
assertTrue(future2.isDone());
assertTrue(future3.isDone());
```
注意`CompletableFuture.allOf()`的返回类型是一个 `CompletableFuture<Void>`。该方法的限制就是它并不返回所有Future的组合结果；取而代之，我们不得不手动从这些Future取得结果。`CompletableFuture.join()`方法和`Java 8 Streams API`使得这一过程简单：
```
String combined = Stream.of(future1, future2, future3)
  .map(CompletableFuture::join)
  .collect(Collectors.joining(" "));

assertEquals("Hello Beautiful World", combined);
```
`CompletableFuture.join()`与 `get` 方法很像，但如果一个Future没有正常结束它将抛出一个非受检异常。这使得它适合用作Stream.map()方法的方法引用。
## 9. 错误处理（Handling Errors）
对于链式异步计算步骤的错误处理，我们不得不采用相似的throw/catch模式。

代替捕获一个句法块中的异常，CompletableFuture类允许我们在同一个特殊的 handle 方法里处理它。该方法接受两个参数：一个运算结果（如果它成功完成），以及它抛出的异常（如果运算步骤不能正常完成）。

在下面的例子中，我们使用 handle 方法来提供一个当greeting 运算由于未提供名字而异常结束时的默认值。
```
String name = null;

// ...

CompletableFuture<String> completableFuture  
  =  CompletableFuture.supplyAsync(() -> {
      if (name == null) {
          throw new RuntimeException("Computation error!");
      }
      return "Hello, " + name;
  })}).handle((s, t) -> s != null ? s : "Hello, Stranger!");

assertEquals("Hello, Stranger!", completableFuture.get());
```
在另一个场景下，假设我们期待手动用一个值来结束一个Future，正如第一个例子，但也具有有异常时结束的能力。`completeExceptionally` 方法正好适用于这个。下面的例子中的`completableFuture.get()` 方法抛出一个 `RuntimeException` 作为其源头的 `ExecutionException` 异常。
```
CompletableFuture<String> completableFuture = new CompletableFuture<>();

// ...

completableFuture.completeExceptionally(
  new RuntimeException("Calculation failed!"));

// ...

completableFuture.get(); // ExecutionException
```
在上面的例子中，我们可以用 `handle` 方法异步处理这些异常，但使用 `get` 方法我们可以使用更典型的同步异常处理范式。
## 10. 异步方法
CompletableFuture 类中fluent API的大部分方法拥有两个带 Async 后缀的变体。这些方法通常用于**在另一个线程执行对应的运算步骤**。

没有 `Async` 后缀的方法使用调用线程执行下一个运算stage；没有 `Executor` 参数的 `Async` 方法是用一个公共的 `Executor` 的 `fork/join` 池实现来运行下一步，该Executor可由`ForkJoinPool.commonPool()` 方法访问。最后，带 `Executor` 参数的` Async` 方法利用传入的Executor执行运算步骤。

下面是一个处理Function 实例代表的运算结果的修改版。唯一可见的不同处是 `thenApplyAsync` 方法，但置于包裹在ForkJoinTask 实例（对于更多关于fork/join的信息，请参见[Java fork/join框架指南](https://www.baeldung.com/java-fork-join)）的函数对象下。这允许我们更加并行化我们的运算并更有效地利用系统资源：
```
CompletableFuture<String> completableFuture  
  = CompletableFuture.supplyAsync(() -> "Hello");

CompletableFuture<String> future = completableFuture
  .thenApplyAsync(s -> s + " World");

assertEquals("Hello World", future.get());
```
## 11. JDK 9 CompletableFuture API
Java 9对CompletableFuture API惊醒了如下的增强：
- 增加了新的工厂方法
- 延迟和超时支持
- 增强了子类化支持

以及新的实例API:
- Executor defaultExecutor()
- CompletableFuture<U> newIncompleteFuture()
- CompletableFuture<T> copy()
- CompletionStage<T> minimalCompletionStage()
- CompletableFuture<T> completeAsync(Supplier<? extends T> supplier, Executor executor)
- CompletableFuture<T> completeAsync(Supplier<? extends T> supplier)
- CompletableFuture<T> orTimeout(long timeout, TimeUnit unit)
- CompletableFuture<T> completeOnTimeout(T value, long timeout, TimeUnit unit)

我们现在也有了一些新的静态工具方法：
- Executor delayedExecutor(long delay, TimeUnit unit, Executor executor)
- Executor delayedExecutor(long delay, TimeUnit unit)
- <U> CompletionStage<U> completedStage(U value)
- <U> CompletionStage<U> failedStage(Throwable ex)
- <U> CompletableFuture<U> failedFuture(Throwable ex)

最后，为了解决超时，Java 9引入了两个新的函数：
- orTimeout()
- completeOnTimeout()

下面的文章可用于深入阅读：[Java 9 CompletableFuture API 增强](https://www.baeldung.com/java-9-completablefuture).
## 12. 结论
在本文中，我们描述了 CompletableFuture 类的方法和主要用例。本文中的代码可在[GitHub](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)上找到。

## reference
- [Guide To CompletableFuture](https://www.baeldung.com/java-completablefuture)
- [Runnable vs. Callable in Java](https://www.baeldung.com/java-runnable-callable)
- [Guide to java.util.concurrent.Future](https://www.baeldung.com/java-future)