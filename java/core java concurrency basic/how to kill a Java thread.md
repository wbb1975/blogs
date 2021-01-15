# How to Kill a Java Thread
## 1. 介绍
在这个简短的文章里我们将会讨论如何杀死一个Java线程--**这并不像看起来那么简单，Thread.stop() 已经被标记为废弃了**。

正如[Oracle的这篇文章](https://docs.oracle.com/javase/1.5.0/docs/guide/misc/threadPrimitiveDeprecation.html)所解释的，stop() 可能导致被监视对象被破坏。
## 2. 使用一个标记
让我们从一个创建和开启一个线程的类开始，这个任务不会自己结束，因此我们需要某种停止该线程的方法。

我们将为此使用一个原子标记：
```
public class ControlSubThread implements Runnable {

    private Thread worker;
    private final AtomicBoolean running = new AtomicBoolean(false);
    private int interval;

    public ControlSubThread(int sleepInterval) {
        interval = sleepInterval;
    }
 
    public void start() {
        worker = new Thread(this);
        worker.start();
    }
 
    public void stop() {
        running.set(false);
    }

    public void run() { 
        running.set(true);
        while (running.get()) {
            try { 
                Thread.sleep(interval); 
            } catch (InterruptedException e){ 
                Thread.currentThread().interrupt();
                System.out.println(
                  "Thread was interrupted, Failed to complete operation");
            }
            // do something here 
         } 
    } 
}
```
没有使用一个 while 循环来求值一个常量 true， 我们使用一个 AtomicBoolean，现在我们可以通过将其设置为 true/false 来开启/停止一个线程。

正如原子变量简介https://www.baeldung.com/java-atomic-variables，使用一个 AtomicBoolean 可防止不同线程设置和检查该变量的冲突。
## 3. 中断一个线程
当 sleep() 被以一个很长的间隔被调用的时候，或者我们在等待一个可能永远不会被释放的锁时会发生什么？**我们将面临堵塞很长时间或永远不能干净地结束的风险**。

我们可以调用 interrupt() 来解决这个困境，让我们为该类添加一些方法和一个新的标记。
```
public class ControlSubThread implements Runnable {

    private Thread worker;
    private AtomicBoolean running = new AtomicBoolean(false);
    private int interval;

    // ...

    public void interrupt() {
        running.set(false);
        worker.interrupt();
    }

    boolean isRunning() {
        return running.get();
    }

    boolean isStopped() {
        return stopped.get();
    }

    public void run() {
        running.set(true);
        stopped.set(false);
        while (running.get()) {
            try {
                Thread.sleep(interval);
            } catch (InterruptedException e){
                Thread.currentThread().interrupt();
                System.out.println(
                  "Thread was interrupted, Failed to complete operation");
            }
            // do something
        }
        stopped.set(true);
    }
}
```
我们添加了一个 interrupt() 方法，它将运行标记设置为 false 并调用工作者线程的 interrupt() 方法。如果线程在睡眠中时该方法被调用，正如其它阻塞方法一样，sleep() 将会以以抛出一个 InterruptedException 的方式退出。

这将把线程返回到循环，由于现在运行标记为 false，该线程将会退出。
## 4. 结论
在这个快速指南中，我们看到了如何使用原子变量，可选地与 interrupt() 方法一道来干净地停止一个线程。这比废弃的 stop() 方法更值得推荐，因为我们不用冒永远死锁或内存破坏的风险。

同样地，源代码在[GitHub](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)上。

## Reference
- [How to Kill a Java Thread](https://www.baeldung.com/java-thread-stop)