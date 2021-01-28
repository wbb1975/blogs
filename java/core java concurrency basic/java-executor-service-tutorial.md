# Java ExecutorService 指南
## 1. 概览
[ExecutorService](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html)是JDK提供的一个框架，用于简化异步模式下任务的执行。通常来讲，ExecutorService 自动提供了一个线程池以及把任务指派给它的API。
## 2. 实例化 ExecutorService
## 2.1 来自 Executors 类的工厂方法
创建 ExecutorService 的最早方式是使用 Executors 类的一个工厂方法。例如，下面的一行代码就可以创建一个10个线程的线程池：
```
ExecutorService executor = Executors.newFixedThreadPool(10);
```
还有其它工厂方法来创建预定义的 ExecutorService 来满足特定需求。为了找到瞒住你需求的最好方法，请查阅 [O]racle 官方文档](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Executors.html)。
## 2.2 直接创建一个 ExecutorService
由于 ExecutorService 是一个接口，任一它的实现类的实例都可被使用。在 [java.util.concurrent 包](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html)中有几种实现可供选择，你也可以创建你自己的实现。

例如，ThreadPoolExecutor 类拥有很少的构造函数用于配置一个执行服务器以及其内部（线程）池。
```
ExecutorService executorService = 
  new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS,   
  new LinkedBlockingQueue<Runnable>());
```
你可能注意到上面的代码与工厂方法 newSingleThreadExecutor() 的[代码](https://github.com/openjdk-mirror/jdk7u-jdk/blob/master/src/share/classes/java/util/concurrent/Executors.java#L133)很像，在大多数情况下，详细的手动配置时不必要的。
## 3. 向 ExecutorService 指派任务
ExecutorService 能够执行 Runnable 和 Callable 任务。在本文中为了保持简单，我们将使用两个简单的任务。注意这里使用了Lambda表达式来代替匿名内部类。
```
Runnable runnableTask = () -> {
    try {
        TimeUnit.MILLISECONDS.sleep(300);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
};

Callable<String> callableTask = () -> {
    TimeUnit.MILLISECONDS.sleep(300);
    return "Task's execution";
};

List<Callable<String>> callableTasks = new ArrayList<>();
callableTasks.add(callableTask);
callableTasks.add(callableTask);
callableTasks.add(callableTask);
```
可以使用几种方法来将任务添加到 ExecutorService，包括 execute()，它从 Executor 接口继承，以及 submit(), invokeAny(), invokeAll()。

**execute()** 方法没有返回值，它没有给定任何取得任务执行结果的可能性，也不能检查人物状态（它在运行或执行完成）：
```
executorService.execute(runnableTask);
```
**submit()** 向一个 ExecutorService 提交一个Callable 或 Runnable任务，并返回一个类型为 Future 的结果：
```
Future<String> future = 
  executorService.submit(callableTask);
```
**invokeAny()** 将一个任务集指派给一个 ExecutorService，每个都会被执行，但只返回所有任务中一个成功执行的任务的结果（如果有一个成功执行的任务）：
```
String result = executorService.invokeAny(callableTasks);
```
**invokeAll()** 将一个任务集指派给一个 ExecutorService，每个都会被执行，然后以一个 Future 列表的形式返回所有任务执行的结果：
```
List<Future<String>> futures = executorService.invokeAll(callableTasks);
```
现在，在继续深入之前，必须再讨论两个事情，停止一个 ExecutorService 以及 如何处理 Future 返回类型。
## 4. 停止 ExecutorService
基本上，在没有任务处理时 ExecutorService 并不会自动销毁。它将保持活着并等待新的任务来临。

在某些情况下这是很有帮助的，例如，一个应用需要处理在编译时不知道的不规则出现或数量不定的任务时。

另一方面，一个应用可能到达它的终点，但它不会被停止--一个等待的 ExecutorService 将会使 JVM 保持运行状态。

为了顺利停止一个 ExecutorService，我们拥有 shutdown() 和 shutdownNow() API。

**shutdown()** 方法并不会导致 ExecutorService 被马上销毁。它会使 ExecutorService 停止接受新的任务，并在运行线程结束结束它们的工作后停止。
```
executorService.shutdown();
```
**shutdownNow()** 方法努力马上销毁 ExecutorService，但是它不能保证所有的线称能够同时停止。该方法返回一个等待处理的任务列表。取决于开发者决定如何处理这些任务：
```
List<Runnable> notExecutedTasks = executorService.shutDownNow();
```
停止一个 ExecutorService（这也是[Oracle推荐](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html)的） 的好的方式是使用这两种方法并结合awaitTermination() 。通过这种方式，ExecutorService 首先停止接受新任务，然后等待一个特定的时间以便所有所有任务结束。如果该时间过期，执行将会马上终止：
```
executorService.shutdown();
try {
    if (!executorService.awaitTermination(800, TimeUnit.MILLISECONDS)) {
        executorService.shutdownNow();
    } 
} catch (InterruptedException e) {
    executorService.shutdownNow();
}
```
## 5. Future 接口
submit() 和 invokeAll() 放回一个或者一套 Future 类型的对象，它允许你得到任务执行的结果或检查任务的状态（在运行中或已经执行完成）。

Future 提供了一个特殊的堵塞接口 get()，对任务 Callable，它返回其执行的一个实际结果，对 Runnable 任务则返回null。在任务还在执行时调用 get() 方法将导致（当前线程的）执行堵塞直至任务执行完成且结果已经准备好。
```
Future<String> future = executorService.submit(callableTask);
String result = null;
try {
    result = future.get();
} catch (InterruptedException | ExecutionException e) {
    e.printStackTrace();
}
```
如果 get() 导致长时间堵塞，一个应用的性能将会下降。如果返回结果不很重要，一个皮面此类问题的方法是使用超时：
```
String result = future.get(200, TimeUnit.MILLISECONDS);
```
如果执行时间超过了指定值（本例为200毫秒），一个 TimeoutException 异常将会抛出。isDone() 方法可被用于检查直排的任务是否已经处理完成。

Future 接口还提供了取消任务执行的 cancel() 方法，以及检查取消状态的 isCancelled() 方法：
```
boolean canceled = future.cancel(true);
boolean isCancelled = future.isCancelled();
```
## 6. ScheduledExecutorService 接口
ScheduledExecutorService 在一个预定义的延迟后定期运行任务。再一次，实例化 ScheduledExecutorService 的最好方法是使用 Executors 类的工厂方法。

在本节，一个拥有一个线程的 ScheduledExecutorService 实例将会被使用：
```
ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
```
为了在一个固定的延迟后调度一个任务，使用 ScheduledExecutorService 的 scheduled() 方法。由两种 scheduled() 方法允许你执行 Runnable 或 Callable。
```
Future<String> resultFuture = executorService.schedule(callableTask, 1, TimeUnit.SECONDS);
```
scheduleAtFixedRate() 方法允许咋一个固定的延迟后周期性地运行一个任务，上面的代码在执行 callableTask 任务之前延迟1秒钟。

下面的代码块将会在初始100毫秒后执行一个任务，之后，每隔450毫秒执行同样的任务一次。如果处理器需要比 scheduleAtFixedRate() 方法 period 参数更多的时间片来执行指派的任务，ScheduledExecutorService 将会等待当前任务的完成才可以开始下一个。
```
Future<String> resultFuture = service
  .scheduleAtFixedRate(runnableTask, 100, 450, TimeUnit.MILLISECONDS);
```
如果任务迭代之间需要一个固定长度的延迟，应该选择 scheduleWithFixedDelay()。例如，下面代码将确保在当前执行结束之后以及开启下一个任务之间有150毫秒的停顿。
```
service.scheduleWithFixedDelay(task, 100, 150, TimeUnit.MILLISECONDS);
```
根据 scheduleAtFixedRate() 和 scheduleWithFixedDelay() 的约定，任务的周期执行将会在 ExecutorService 停止或任务执行中异常抛出时结束，
## 7. ExecutorService vs. Fork/Join
当Java 7发布时，许多开发者认为 ExecutorService 框架应该被 fork/join 框架替代。这并不总是一个正确的决定。尽管 fork/join 使用简单，性能优异，仍然有一部分开发者为并发执行放弃Fork/Join。

ExecutorService 给予开发者控制产生的线程的能力，以及由不同线程执行的任务的粒度。ExecutorService 最好的用例是独立任务的处理，例如交易或根据架构“一个线程一个任务”的请求。

作为对比，根据 [Oracle 文档](https://docs.oracle.com/javase/tutorial/essential/concurrency/forkjoin.html，fork/join) 被设计用于加速可被迭代地分解成更小任务的工作。
## 8. 结论
虽然 ExecutorService 相对简单，仍然有一些陷阱。我们总结一下：
- 保持不使用的 ExecutorService 活着：第4节有关于停止一个ExecutorService的完整解释
- 使用固定大小线程池时的错误大小：决定应用需要多少线程来有效执行任务是非常重要的。一个拥有太多线程的线程池只会导致大多数咸亨停留在等待状态；太少的线称会使得应用反应性下降--任务不得不在队列里等待很长时间。
- 在任务取消后调用 Future 的 get() 方法：尝试去获取一个已经取消的任务的结果会抛出一个 CancellationException 异常
- Future 的 get() 方法导致的长时间堵塞：应该使用超时来皮面不期待的等待。

本文代码可在 [GitHub 仓库](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)中找到。

## Reference
- [Java ExecutorService 指南](https://www.baeldung.com/java-executor-service-tutorial)