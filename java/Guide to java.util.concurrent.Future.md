# Guide to java.util.concurrent.Future
## 1. 概述
在本文中，我们将学习[Future](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html)。一个自Java 1.5引入的接口，在异步调用和并行处理是非常有用。
## 2. 创建Futures
简单来说，Future 类代表一个异步运算的将来结果--一个将来在运算结束后最终将出现的结果。

让我们看看如何写方法来创建并返回Future实例。

长期运行的方法是异步处理和Future接口的很好候选，它可以使得我们可以在等待由Future 封装的任务完成之前执行一些其它的处理。

下面是一些影响Future 的异步属性的操作示例：
- 计算密集型处理（数学和科学计算）
- 操纵大的数据结构（大数据）
- 远程方法调用（下载文件，HTML 解析（HTML scrapping），Web服务）
### 2.1 利用FutureTask实现Futures
对于我们的例子，我们将创建一个简单的类来计算整数的平方。这显然不符合“长期运行”的方法一类，但我们将会把Thread.sleep()放置进去让其运行1秒才结束。
```
public class SquareCalculator {    
    
    private ExecutorService executor 
      = Executors.newSingleThreadExecutor();
    
    public Future<Integer> calculate(Integer input) {
        return executor.submit(() -> {
            Thread.sleep(1000);
            return input * input;
        });
    }
}
```
执行实际计算的代码包含在call() 方法里， 并通过Lambda表达式提供。你能看到没什么特别的，除了之前提到过的sleep() 调用。

当我们把我们的关注点转向[Callable](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Callable.html)和[ExecutorService](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html)的使用时，一切会变得更为有趣。

Callable 是一个代表一个任务的接口，该任务返回一个结果并拥有一个call() 方法。这里，我们已经用Lambda创建了一个它的实例。

创建一个Callable 的实例并不会带我们飞，我们任然不得不把这个实例传递给一个执行器（executor），它将照顾好在一个新的线程里开启该任务并向我们返回一个宝贵的Future 对象。这是ExecutorService 出现的目的。

有一些方式让我们控制ExecutorService 实例，大部分由工具类[Executors](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html)的静态工厂方法提供。在本例中，我们使用了基础的newSingleThreadExecutor()，它给我们一个ExecutorService 一次可以处理一个线程。

一旦我们拥有了一个ExecutorService 对象，我们只需调用submit() 传递我们的Callable 对象作为参数，submit() 将帮你启动任务并返回一个[FutreTask](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/FutureTask.html)对象，它是Future 接口的一个实现。
## 3. 消费Futures
到现在这个点，我们已经知道了如何创建一个Future对象。

在本节中，我们将通过探寻作为Future API一部分的所有方法来学习如何与该实例一起工作。
### 3.1 利用isDone() 和 get() 来取得结果
现在我们需要调用calculate() 并使用返回的Future 来得到结果整数。Future API的两个方法可以在该任务上帮助到我们。

[Future.isDone()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#isDone--)告诉我们executor 是否已经完成了该任务的处理。如果任务已经完成，它将会返回true，否则会返回false。

从计算返回实际结果的方法是[Future.get()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#get--)。注意这个方法会堵塞（当前线程的）执行直至任务结束，但是在我们的例子中，这不是一个问题--我们首先通过调用isDone().检查任务是否已经完成。

通过这两个方法我们可以在等待主任务完成时运行其它代码：
```
    Future<Integer> future = new SquareCalculator().calculate(10);

    while(!future.isDone()) {
        System.out.println("Calculating...");
        Thread.sleep(300);
    }

    Integer result = future.get();
```
在这个例子中，我们向标准输出写了一条简单消息让我们知道程序在执行运算。

方法get() 堵塞程序运行直至任务结束。但我们并不担心这个，因为我们的程序只在确认任务已经结束后才调用get() 。因此在这种场景下，uture.get() 将会立即返回。

值得注意的是get()拥有一个重载版本，它需要一个timeout 和一个[TimeUnit](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/TimeUnit.html)作为参数。
```
    Integer result = future.get(500, TimeUnit.MILLISECONDS);
```
[get(long, TimeUnit)](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#get-long-java.util.concurrent.TimeUnit-)和 [get()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#get--)的区别在于前者当在指定时间范围为结束时抛出一个[TimeoutException](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/TimeoutException.html)。
### 3.2 利用cancel()来取消Futures
假设我们已经触发了一个任务，但基于某些原因我们不再关心任务结果。我们可以使用[Future.cancel(boolean)](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#cancel-boolean-)告诉执行器停止运行该操作并中断底层线程。
```
    Future<Integer> future = new SquareCalculator().calculate(4);

    boolean canceled = future.cancel(true);
```
我们上面代码中的Future 实例将永远不会结束其执行。实际上，如果你在该实例上在调用cancel()再调用get()，结果讲师一个[CancellationException](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CancellationException.html)。[Future.isCancelled()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html#isCancelled--)将会告诉我们一个Future 是否已经被取消了。这对于避免得到一个CancellationException 是很有用的。

有可能调用cancel() 失败。在这种情况下，返回值将会是false，注意cancel()接收一个boolean值作为其参数--这个值控制执行这个任务的线程是否该被中断。
## 4. 与Thread Pools相关的多线程
因为是通过[Executors.newSingleThreadExecutor](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html#newSingleThreadExecutor--)获取到的，我们现在的ExecutorService 是单线程的。为了强调“单线程”，让我们同事触发两个计算：
```
    SquareCalculator squareCalculator = new SquareCalculator();

    Future<Integer> future1 = squareCalculator.calculate(10);
    Future<Integer> future2 = squareCalculator.calculate(100);

    while (!(future1.isDone() && future2.isDone())) {
        System.out.println(
        String.format(
            "future1 is %s and future2 is %s", 
            future1.isDone() ? "done" : "not done", 
            future2.isDone() ? "done" : "not done"
        )
        );
        Thread.sleep(300);
    }

    Integer result1 = future1.get();
    Integer result2 = future2.get();

    System.out.println(result1 + " and " + result2);

    squareCalculator.shutdown();
```
现在让我们来分析上面代码的输出：
```
calculating square for: 10
future1 is not done and future2 is not done
future1 is not done and future2 is not done
future1 is not done and future2 is not done
future1 is not done and future2 is not done
calculating square for: 100
future1 is done and future2 is not done
future1 is done and future2 is not done
future1 is done and future2 is not done
100 and 10000
```
很明显处理并非并行的，注意到第二个任务仅当第一个任务结束后才开始，从而使整个处理花费了2秒钟才结束。

为了使我们的程序真正地多线程，我们应当是用一个不同风格的ExecutorService。让我们看看如果我们使用一个通过工厂方法[Executors.newFixedThreadPool()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html#newFixedThreadPool-int-)得到的线程池，我们的程序将如何运行。
```
public class SquareCalculator {
 
    private ExecutorService executor = Executors.newFixedThreadPool(2);
    
    //...
}
```
随着对SquareCalculator类的一点小小修改，现在我们拥有了一个可以使用两个线程的执行器。

如果我们运行同样的客户端代码，我们将会得到下面的输出：
```
calculating square for: 10
calculating square for: 100
future1 is not done and future2 is not done
future1 is not done and future2 is not done
future1 is not done and future2 is not done
future1 is not done and future2 is not done
100 and 10000
```
这看起来好多了。注意到两个任务几乎同时开始和结束，并且整个过程花费约1秒就结束了。

也有其它的工厂方法来创建线程池，[Executors.newCachedThreadPool()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html#newCachedThreadPool--)复用以前用过的可用线程，[Executors.newScheduledThreadPool()](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html#newScheduledThreadPool-int-)将会在一定时延后调度命令。 

关于ExecutorService的更多信息，阅读聚焦与这个主题的这篇[文章](https://www.baeldung.com/java-executor-service-tutorial)。
## 5. ForkJoinTask概述
## 6. 结论

## Reference
- [Guide to java.util.concurrent.Future](https://www.baeldung.com/java-future)
- [Guide to the Java ExecutorService](https://www.baeldung.com/java-executor-service-tutorial)
- [Guide to the Fork/Join Framework in Java](https://www.baeldung.com/java-fork-join)
- [Guide to CompletableFuture](https://www.baeldung.com/java-completablefuture)