# java.util.concurrent概览
## 1. 概览
java.util.concurrent 包提供了创建并行应用的工具。在本文中，我们将对整个包做一个概览。
## 2. 主要组件
java.util.concurrent 包含许多值得讨论的特性。在本文中，我们将关注该包中一些最常用的工具如：
- 执行器（Executor）
- 执行服务器（ExecutorService）
- 调度执行服务器（ScheduledExecutorService）
- Future
- CountDownLatch
- CyclicBarrier
- 信号量（Semaphore）
- 线程（ThreadFactory）
- 堵塞队列（BlockingQueue）
- 延时队列（DelayQueue）
- 锁（Locks）
- 移相器（Phaser）

你也会找到许多关于这里的类的独立的文章。
### 2.1 执行器（Executor）
**执行器是一个接口，该接口代表一个执行提供的任务的对象**。

任务在新线程或当前线程执行依赖特定实现（从那里函数调用发起）。因此，使用这个接口我们就能把任务执行流与任务实际执行机制解耦。

这里需要注意的一点是执行器并不严格要求任务异步执行。在最简单的例子中，一个执行器甚至可以立即在调用线程里执行提交的任务。

我们需要创建一个 invoker 来创建执行器实例：
```
public class Invoker implements Executor {
    @Override
    public void execute(Runnable r) {
        r.run();
    }
}
```
现在，我们可以使用这个 invoker 来执行任务：
```
public void execute() {
    Executor executor = new Invoker();
    executor.execute( () -> {
        // task to be performed
    });
}
```
这里需要注意的是如果执行器不能接受一个任务来执行，则它应该抛出[RejectedExecutionException](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/RejectedExecutionException.html)。
### 2.2 执行服务器（ExecutorService）
ExecutorService 是异步处理的完整解决方案。它管理一个内存中的队列，并基于可用线程调度提交的任务。

为了使用执行服务器（ExecutorService），我们需要创建一个 Runnable 类：
```
public class Task implements Runnable {
    @Override
    public void run() {
        // task details
    }
}
```
现在我们可以创建一个 ExecutorService 实例并向其指派任务。在创建时，我们需要指定线程池大小：
```
ExecutorService executor = Executors.newFixedThreadPool(10);
```
如果我们想创建一个单线程 ExecutorService 实例，我们可以使用 newSingleThreadExecutor(ThreadFactory threadFactory) 来创建实例。

一旦执行器被创建，我们就可以使用它来提交任务：
```
public void execute() { 
    executor.submit(new Task()); 
}
```
我们也可以在提交任务时创建 Runnable 实例：
```
executor.submit(() -> {
    new Task();
});
```
它还提供了两个开箱即用得终止执行的方法。第一个是shutdown()；它等待直至所有提交的任务完成执行。另一个方法是shutdownNow() ，它立即停止所有悬挂/执行的任务。

还有另外一个方法 awaitTermination(long timeout, TimeUnit unit) ，它在触发一个停止事件后强制堵塞直至所有任务完成执行或者执行超时，或者执行线程本身被中断。
```
try {
    executor.awaitTermination( 20l, TimeUnit.NANOSECONDS);
} catch (InterruptedException e) {
    e.printStackTrace();
}
```
### 2.3 调度执行服务器（ScheduledExecutorService）
ScheduledExecutorService 是个和 ExecutorService 一样的接口，但它可以周期性执行任务。

**Executor 和 ExecutorService 的方法都在原地调度而没有引入任何人工延迟**。0或负值指示请求需要被立即执行。

我们可以使用 Runnable 和 Callable来定义任务：
```
public void execute() {
    ScheduledExecutorService executorService
      = Executors.newSingleThreadScheduledExecutor();

    Future<String> future = executorService.schedule(() -> {
        // ...
        return "Hello world";
    }, 1, TimeUnit.SECONDS);

    ScheduledFuture<?> scheduledFuture = executorService.schedule(() -> {
        // ...
    }, 1, TimeUnit.SECONDS);

    executorService.shutdown();
}
```
ScheduledExecutorService 也可以**在某个给定的固定时延后**调度任务：
```
executorService.scheduleAtFixedRate(() -> {
    // ...
}, 1, 10, TimeUnit.SECONDS);

executorService.scheduleWithFixedDelay(() -> {
    // ...
}, 1, 10, TimeUnit.SECONDS);
```
这里 `scheduleAtFixedRate( Runnable command, long initialDelay, long period, TimeUnit unit)` 方法创建并周期性地执行一个行动，它在一个提供的初始时延后首次执行，接下来在给定的周期执行直至服务实例被终止。

`scheduleWithFixedDelay( Runnable command, long initialDelay, long delay, TimeUnit unit)` 方法创建并周期性地执行一个行动，它在一个提供的初始时延后首次执行，接下来在以一个执行终止和下次执行之间的固定时延重复执行。
### 2.4 Future
**Future 用于代表异步操作的结果**。它提供了方法来检查异步操作是否已经结束，取得计算结果，等。

而且，cancel(boolean mayInterruptIfRunning) API 取消操作并释放执行线程。如果 mayInterruptIfRunning 的值为 true， 执行任务的线程将会被立即终止。否则，执行中的任务将会被允许结束。

我们可以使用下面的代码片段来创建一个Future：
```
public void invoke() {
    ExecutorService executorService = Executors.newFixedThreadPool(10);

    Future<String> future = executorService.submit(() -> {
        // ...
        Thread.sleep(10000l);
        return "Hello world";
    });
}
```
我们可以使用下面的代码片段来检验一个Future的结果是否已经准备好，如果运算已经就绪就取得其结果：
```
if (future.isDone() && !future.isCancelled()) {
    try {
        str = future.get();
    } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
    }
}
```
我们也可以为指定的操作指定一个超时。如果一个任务话费了比此更长的时间，一个 TimeoutException 异常将会被抛出：
```
try {
    future.get(10, TimeUnit.SECONDS);
} catch (InterruptedException | ExecutionException | TimeoutException e) {
    e.printStackTrace();
}
```
### 2.5 CountDownLatch
CountDownLatch（JDK1.5引入）是一个工具类，它堵塞一套线程直至某个操作完成。

一个 CountDownLatch 以一个计数器（整数类型）初始化；当其依赖的线程完成执行后计数器减一。但是一旦计数器达到0，其它线程也得到释放。

你可以在[这里](https://www.baeldung.com/java-countdown-latch)学到更多关于 CountDownLatch 的知识。
### 2.6 CyclicBarrier
CyclicBarrier 工作方式基本和 CountDownLatch 一样，除了我们可以服用它。不像 CountDownLatch，它允许多个线程利用 await() 方法在调用最终任务之前互相等待（得名屏障条件）。

我们需要创建一个 Runnable 任务实例来初始化屏障条件：
```
public class Task implements Runnable {

    private CyclicBarrier barrier;

    public Task(CyclicBarrier barrier) {
        this.barrier = barrier;
    }

    @Override
    public void run() {
        try {
            LOG.info(Thread.currentThread().getName() + 
              " is waiting");
            barrier.await();
            LOG.info(Thread.currentThread().getName() + 
              " is released");
        } catch (InterruptedException | BrokenBarrierException e) {
            e.printStackTrace();
        }
    }

}
```
现在我们可以调用一些线程来为屏障条件竞争：
```
public void start() {

    CyclicBarrier cyclicBarrier = new CyclicBarrier(3, () -> {
        // ...
        LOG.info("All previous tasks are completed");
    });

    Thread t1 = new Thread(new Task(cyclicBarrier), "T1"); 
    Thread t2 = new Thread(new Task(cyclicBarrier), "T2"); 
    Thread t3 = new Thread(new Task(cyclicBarrier), "T3"); 

    if (!cyclicBarrier.isBroken()) { 
        t1.start(); 
        t2.start(); 
        t3.start(); 
    }
}
```
这里，isBroken() 方法检查了是否有一个线程在执行时被中断。我们通常应该在执行实际过程之前执行此类检查。
### 2.7 信号量（Semaphore）
信号量用于堵塞对于部分物理和逻辑资源的线程级访问。信号量包括一套允许集：当一个线程试着进入一个关键区，它需要检查一个信号量是否还有一个允许存在。

**如果一个允许不存在（通过 tryAcquire()），线程将不被允许跳入关键区；但如果允许存在，则该访问被授权， 而允许计数器递减**。

一旦执行线程释放了关键区，再一次允许计数器将递增（通过 release() 方法），

我们可以使用 tryAcquire(long timeout, TimeUnit unit) 方法来指定获取访问的超时限制。

**我们也可检查可用的允许数目，或者等待获取该信号量的线程数**。下面的代码片段可用于实现一个信号量：
```
static Semaphore semaphore = new Semaphore(10);

public void execute() throws InterruptedException {

    LOG.info("Available permit : " + semaphore.availablePermits());
    LOG.info("Number of threads waiting to acquire: " + 
      semaphore.getQueueLength());

    if (semaphore.tryAcquire()) {
        try {
            // ...
        }
        finally {
            semaphore.release();
        }
    }

}
```
我们可以使用Semaphore来实现类似 Mutex 类似的数据结构。更多细节[可以在这里找到](https://www.baeldung.com/java-semaphore)。
### 2.8 线程（ThreadFactory）
正如其名字所建议的，ThreadFactory 用做一个线程（不存在）池，它随需创建一个新的线程。它结束了实现高效线程创建机制时模板代码的必要性，

我们可以定义一个 ThreadFactory:
```
public class BaeldungThreadFactory implements ThreadFactory {
    private int threadId;
    private String name;

    public BaeldungThreadFactory(String name) {
        threadId = 1;
        this.name = name;
    }

    @Override
    public Thread newThread(Runnable r) {
        Thread t = new Thread(r, name + "-Thread_" + threadId);
        LOG.info("created new thread with id : " + threadId +
            " and name : " + t.getName());
        threadId++;
        return t;
    }
}
```
我们可以使用 newThread(Runnable r) 方法来在运行时创建一个线程：
```
BaeldungThreadFactory factory = new BaeldungThreadFactory( 
    "BaeldungThreadFactory");
for (int i = 0; i < 10; i++) { 
    Thread t = factory.newThread(new Task());
    t.start(); 
}
```
### 2.9 堵塞队列（BlockingQueue）
在异步编程中，使用最广泛的集成模式之一就是[生产者-消费者模式](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem]。java.util.concurrent 包提供了数据结构如BlockingQueue -- 他可以在异步场景下非常有用。

在[这里](https://www.baeldung.com/java-blocking-queue)可以看到工作示例的更多细节。
### 2.10 延时队列（DelayQueue）
DelayQueue 是一个无限大小的堵塞队列，其内元素只有其过期时间到达后才可以被访问（即用户定义时延）。因此，最顶端元素（头）拥有最大时延，并会被厚厚取出。

更多关于它的信息以及工作示例可以在[这里](https://www.baeldung.com/java-delay-queue)找到。
### 2.11 锁（Locks）
并不奇怪，锁是一种除当前执行线程防止其它线程访问一段代码的工具。

锁和同步块的主要区别是同步块完全包含在方法内部；但是，我们能够在单独的方法里利用锁的API lock() 和 unlock() 操作。

更多关于它的信息以及工作示例可以在[这里](https://www.baeldung.com/java-concurrent-locks)找到。
### 2.12 移相器（Phaser）
移相器是一个比 CyclicBarrier 和 CountDownLatch 更灵活的解决方案--用来充作一个可复用的屏障，一个动态数目的线程在其上等待直至能够继续执行。我们能够协调程序执行的多个阶段，对每个阶段服用一个 Phaser 实例。

更多关于它的信息以及工作示例可以在[这里](https://www.baeldung.com/java-phaser)找到。
## 3. 结论
在这个高度概括介绍性文章中，我们专注于 java.util.concurrent 包里的不同工具。

和往常一样，完整源代码可在[GitHub](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)上得到。

## Reference
- [java.util.concurrent概览](https://www.baeldung.com/java-util-concurrent)