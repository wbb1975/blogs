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
首先，CompletableFuture 类实现了Future接口，因此我们可以将它用做一个Future实现，但是需要额外的完成逻辑。
## 4. CompletableFuture 和包装的计算逻辑
## 5. 异步计算的结果处理
## 6. 绑定 Futures
## 7. thenApply() 和 thenCompose()的区别
## 8. 多个Futures并行运行
## 9. 异常处理
## 10. 异步方法
## 11. JDK 9 CompletableFuture API
## 12. 结论
在本文中，我们描述了 CompletableFuture 类的方法和主要用例。本文中的代码可在[GitHub](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)上找到。

## reference
- [Guide To CompletableFuture](https://www.baeldung.com/java-completablefuture)
- [Runnable vs. Callable in Java](https://www.baeldung.com/java-runnable-callable)
- [Guide to java.util.concurrent.Future](https://www.baeldung.com/java-future)