# 什么是线程安全性，如何实现它？
## 1. 概览
Java 开箱支持多线程，这意味着通过在多个工作线程里并行运行字节码，[JVM](https://www.baeldung.com/jvm-vs-jre-vs-jdk)能够提升应用性能。

虽然多线程是个强大的特性，它也是有代价的。在多线程环境中，我们需要以一种线程安全的方式来撰写实现。这意味着不同线程可以访问同一资源，且不会导致错误的行为以及不可预料的结果。这个**编程方法论被称为“线程安全性”**。

在本教程中，我们将看到实现线程安全性的不同方式。
## 2. 无状态实现 （Stateless Implementations）
大多数情况下，多线程应用的错误是在多个线程之间共享状态的结果。因此，我们探访的首选是是**用无状态实现**来实现线程安全性。为了更好地理解这种方式，让我们考虑一个简单的工具类，它用来计算一个数的阶乘：
```
public class MathUtils {
    
    public static BigInteger factorial(int number) {
        BigInteger f = new BigInteger("1");
        for (int i = 2; i <= number; i++) {
            f = f.multiply(BigInteger.valueOf(i));
        }
        return f;
    }
}
```
**factorial() 方法是一个无状态确定函数**。给定一个特定的输入，它总会产生一样的输出。

该方法**既不依赖外部状态也根本不维护内部状态**，因此它被认为是线程安全的，因此它可以被多个线程在同一时间安全地调用。所有线程可以安全地调用 factorial()，并可得到期待的结果而不用担心线程相互干扰，也不会改变一个线程为其它线程产生的输出。

因此，**无状态实现是实现线程安全性的最简单的方式**。
## 3. 不可变实现（Immutable Implementations）
**如果我们需要在多线程间共享状态，我们可以创建线程安全的类來使得其不可变**。

不可变性是一个强大的语言不可知论的概念，它在Java中很容易实现。简单来讲，**一个类实例是不可变的意味着当其被构造后其内部状态不可被改变**。

在Java中实现一个不可变类的最简单方式是将所有字段声明为 private 且 final，并且不提供设置器（setters）。 
```
public class MessageService {
    
    private final String message;

    public MessageService(String message) {
        this.message = message;
    }
    
    // standard getter
    
}
```
一个 MessageService 对象时高效不可变的，意味它的状态在被构造后就不能再改变。而且，即使 MessageService 事实上是可变的，但多个线程对其仅仅拥有只读权限，他也是线程安全的。

因此，不可变性是实现线程安全性的又一种方式。
## 4. 线程本地字段（Thread-Local Fields）
在面向对象编程中，对象需要通过字段来维持状态，通过一个或多个方法来实现行为。

如果我们确实需要维护状态，**我们可以通过使得字段称为线程本地化（线程本地）来达到线程键不共享状态，从而创建线程安全类**。我们可以很容奇地创建拥有线程本地化字段的类，只需在 [Thread](https://docs.oracle.com/javase/8/docs/api/java/lang/Thread.html)类中声明private字段。

例如，我们将定义一个存储了一个整数数组的Thread类：
```
public class ThreadA extends Thread {
    
    private final List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);
    
    @Override
    public void run() {
        numbers.forEach(System.out::println);
    }
}
```
同时另一个线程类可能持有一个字符串数组：
```
public class ThreadB extends Thread {
    
    private final List<String> letters = Arrays.asList("a", "b", "c", "d", "e", "f");
    
    @Override
    public void run() {
        letters.forEach(System.out::println);
    }
}
```
**在两个实现中，类都有它们自己的状态，但并不与其它线程共享。因此，这些类是线程安全的**。

类似地，我们可以通过将字段指定为[ThreadLocal](https://www.baeldung.com/java-threadlocal)来创建线程安全的字段。例如，让我们考虑下面这个 StateHolder 类：
```
public class StateHolder {
    
    private final String state;

    // standard constructors / getter
}
```
我们可以简单地使其成为一个  thread-local 变量：
```
public class ThreadState {
    
    public static final ThreadLocal<StateHolder> statePerThread = new ThreadLocal<StateHolder>() {
        
        @Override
        protected StateHolder initialValue() {
            return new StateHolder("active");  
        }
    };

    public static StateHolder getState() {
        return statePerThread.get();
    }
}
```
线程本地化字段很像正常类字段，除了每个通过 setter/getter 方法它们的线程都独立得到这些字段的一个初始拷贝，因此每个线程拥有其自己的状态。
## 5. 同步集合（Synchronized Collections）
我们很容易通过使用集合框架里的同步包装器集来创建线程安全的集合。例如，我们可以通过[同步包装器](https://www.baeldung.com/java-synchronized-collections)里的一个来创建一个线程安全的集合。
```
Collection<Integer> syncCollection = Collections.synchronizedCollection(new ArrayList<>());
Thread thread1 = new Thread(() -> syncCollection.addAll(Arrays.asList(1, 2, 3, 4, 5, 6)));
Thread thread2 = new Thread(() -> syncCollection.addAll(Arrays.asList(7, 8, 9, 10, 11, 12)));
thread1.start();
thread2.start();
```
请记住同步集合在每个方法使用内部锁（我们将在稍后探讨内部锁）。

**这意味着在同一时间只有一个线程才能访问这些方法，其他线程将会杜泽直至第一个线程释放了锁**。

因此，由于内部同步访问的逻辑，同步是由性能代价的。
## 6. 并发集合（Concurrent Collections）
作为同步集合的一个替代，我们可以使用并发集合来创建线程安全的集合。Java 提供了 [java.util.concurren](thttps://docs.oracle.com/javase/8/docs/api/?java/util/concurrent/package-summary.html)包，里面包含了几个并发集合，例如 [ConcurrentHashMap](https://docs.oracle.com/javase/8/docs/api/?java/util/concurrent/package-summary.html):
```
Map<String,String> concurrentMap = new ConcurrentHashMap<>();
concurrentMap.put("1", "one");
concurrentMap.put("2", "two");
concurrentMap.put("3", "three");
```
不像它们的同步同伴，**并发集合是通过将其数据分割成段来实现线程安全**。例如，对于 ConcurrentHashMap，多个线程可以唉 Map 不同的段取得锁，所以多个线程可以在同一时间访问一个Map。由于其并发线程访问以身具来的优势，**并发集合性能比同步集合好得多**。值得注意的是，**同步和并发集合仅仅使集合本身线程安全而不是集合内容**。
## 7. 原子对象（Atomic Objects）
也可以通过Java提供的[原子类](https://www.baeldung.com/java-atomic-variables)集合来实现线程安全性，包括 [AtomicInteger](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicInteger.html), [AtomicLong](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicLong.html), [AtomicBoolean](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicBoolean.html), 和 [AtomicReference](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicReference.html)。

**原子类允许我们执行原子操作，这是线程安全的并无需使用同步**。一个原子操作在一个单一机器级别操作里执行。为了理解它解决的问题，让我们看看下面的 Counter 类：
```
public class Counter {
    
    private int counter = 0;
    
    public void incrementCounter() {
        counter += 1;
    }
    
    public int getCounter() {
        return counter;
    }
}
```
**让我们假设在一个竞争场景下，两个线程在同一时间访问 incrementCounter() 方法**。理论上，counter 字段的最终值是2。但我们不确信最终结果，因为线程在同时执行统一代码块且递增不是原子的。

让我们使用一个 AtomicInteger 对象来创建一个线程安全的 Counter 类实现：
```
public class AtomicCounter {
    
    private final AtomicInteger counter = new AtomicInteger();
    
    public void incrementCounter() {
        counter.incrementAndGet();
    }
    
    public int getCounter() {
        return counter.get();
    }
}
```
**这是线程安全的，因为在递增时，++ 花费多过一个操作，而 incrementAndGet 是原子的**。
## 8. 同步方法
上面的方式对于集合和基本类型很好，但现在是时候我们需要付出更多控制了。

因此，另一个取得线程安全性的方式是实现同步方法。**简单进，就是同一时间仅仅一个线程可以访问一个同步方法，而其它线程的访问被堵塞**。其它线程保持堵塞直至第一个线程访问结束或者该方法抛出一个异常。我们可以利用另一种方式，即使其成为一个同步方法来创建一个线程安全版本的 incrementCounter() ：
```
public synchronized void incrementCounter() {
    counter += 1;
}
```
我们已经创建了这个同步方法，仅仅需要在方法签名中添加 `synchronized` 关键字。因为一个线程可以在一个时间访问一个同步方法，一个线程将执行 incrementCounter() 方法，接下来其它线程将执行同样的操作。无论如何都糊会有之行的重叠。**同步方法依赖“固有锁”或“监控锁”的使用**，一个固有锁是一个与一个类实例关联的隐含内部实体。在多线程的语境下，术语监控（monitor）仅是锁操作执行时对关联对象角色的引用，就像它强加排它性访问与一系列方法和语句上。

**当一个线程调用一个同步方法时，它需要获取固有锁**。当线程执行完该方法后，它释放该锁，有次允许其它线程获取锁并可以访问该方法。

我们可以在实例方法，静态方法，语句块（同步语句块）里实现同步。
## 9. 同步语句块（Synchronized Statements）
有时候我们仅仅西药使得方法的一部分线程安全，这时候同步整个方法显得“过杀”。为了例证这个用例，让我们重构 incrementCounter() 方法：
```
public void incrementCounter() {
    // additional unsynced operations
    synchronized(this) {
        counter += 1; 
    }
}
```
这个例子很“卑微”，但它显示了如何创建一个同步语句块。加入该方法执行了一些额外的操作，它们不需要同步。我们仅仅在同步块中同步状态更改的部分。不想同步方法，同步代码块必须指定提供固有锁的对象，通常是 this 引用。

**同步是昂贵的，因此通过这个选项，我们可以仅仅一个方法的喜爱那个关部分**。
### 9.1. 其它对象用作锁
我们可以稍微改进 Counter 类的线程安全实现，即通过改用另一个对象作为监视锁而非 this。它不仅在多线程环境下提供了对共享资源的协调访问，**它还使用外部实体墙体对资源的排它性访问**。
```
public class ObjectLockCounter {

    private int counter = 0;
    private final Object lock = new Object();
    
    public void incrementCounter() {
        synchronized(lock) {
            counter += 1;
        }
    }
    
    // standard getter
}
```
我们使用一个简单的Objecthttps://docs.oracle.com/javase/8/docs/api/java/lang/Object.html对象来提供互斥访问。这个实现稍微好点，因为它在锁级别提高了安全性。

**我们使用 this 作为固有锁，一个攻击者通过获取固有锁并触发拒绝服务攻击条件可能导致死锁**。反之，当我们是用别的对象，似有对象从外部是无法访问的，这使得攻击者更难以获得锁并到这死锁。
### 9.2. 警告（Caveats）
即使我们可以使用任何对象作为一个固有锁，我们应该避免使用字符串作为锁对象。
```
public class Class1 {
    private static final String LOCK  = "Lock";

    // uses the LOCK as the intrinsic lock
}

public class Class2 {
    private static final String LOCK  = "Lock";

    // uses the LOCK as the intrinsic lock
}
```
一眼望去，似乎两个类使用不同的对象用作锁，但**实际上由于[字符串的内联](https://www.baeldung.com/string/intern)，这两个锁的值可能都指向字符串池里的同一个对象**。因此Class1 和 Class2 实际上共享一个锁对象。如此，在并发环境下，可能导致一些预料之外的情形。

除了字符串，我们应该避免使用[可缓存及可复用的](https://mail.openjdk.java.net/pipermail/valhalla-spec-observers/2020-February/001199.html)对象用作固有锁。例如，[Integer.valueOf()](https://github.com/openjdk/jdk/blob/8c647801fce4d6efcb3780570192973d16e4e6dc/src/java.base/share/classes/java/lang/Integer.java#L1062) 方法缓存了小的整数。因此，在不同的类中调用 Integer.valueOf(1) 将返回同样的对象。
## 10. 易变字段（Volatile Fields）
同步方法和块对解决不同线程中变量可见性的问题很方便，即使这样，普通类字段的值也可能被CPU缓存住。因此，接下来对某个定字段的更新，即使它们是同步的，也可能对其它线程不可见。

为了防止这类问题， 我们可以使用 [volatile](https://www.baeldung.com/java-volatile) 类字段：
```
public class Counter {

    private volatile int counter;

    // standard constructors / getter
    
}
```
**使用了 volatile 关键字，我们指示 JVM 和编译器将 counter 变量存储在主存中**。通过这种方式，我们确信每次 JVM 读取 counter 的值，它都需要从主存里读取而不是从 CPU 缓存。同样地，每次 JVM 写 counter 值，其值也会被写到主存。

而且，volatile 字段的使用确保对一个线程可见的所有字段都会冲主存中读取。让我们看看下面的例子：
```
public class User {

    private String name;
    private volatile int age;

    // standard constructors / getters
    
}
```
在这个例子中，每次 JVM 写 age volatile变量到主存，特也会写非volatile变量 name 到主存，这却抱ian个个变量的最新值都存储在主存，因此接下来对变量的更新会自动对其它线程可见。类似地，如果一个线程读一个 volatile 变量的值，对该线程可见的所有变量也会从主存中读回。

这个 volatile 变量提供的扩展保证被称为[完整可变性可见保证](http://tutorials.jenkov.com/java-concurrency/volatile.html)。
## 11. 重入锁
Java 提供了一套升级过的[锁](https://www.baeldung.com/java-concurrent-locks)实现，它们的行为比前面讨论的固有锁稍微复杂。

对于固有锁，锁的获取模型是相当死板的；一个线程拿到了锁，执行方法或代码块，并最终释放锁；因此，（接下来）其它下次你哼可以获得锁并执行方法。其低层级制并不检查排队线程，也并不给排队最久的线程一个优先级。

ReentrantLock 实例则允许我们如此做，**因此它可以防止排队线程出现某种类型的资源饿死**。
```
public class ReentrantLockCounter {

    private int counter;
    private final ReentrantLock reLock = new ReentrantLock(true);
    
    public void incrementCounter() {
        reLock.lock();
        try {
            counter += 1;
        } finally {
            reLock.unlock();
        }
    }
    
    // standard constructors / getter
    
}
```
ReentrantLock 构造函数接受一个可选的 公平性（fairness ）布尔类型参数。当设为true时，当多个线程在试图获取一个锁时，**JVM 将给等待最久的线程一个优先级并获得锁访问权限**。
## 12. 读写锁
另一个强大的实现线程安全性的机制是使用 [ReadWriteLock](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/ReadWriteLock.html)实现。一个 ReadWriteLock 锁实际上使用了一对关联的锁，一个用于只读操作，另一个用于写操作。结果是，可以由多个线程来读一个资源，只要没有线程在写它；而且，写该资源的线程将防止其它线程读取它。

我们可以如下使用一个 ReadWriteLock:
```
public class ReentrantReadWriteLockCounter {
    
    private int counter;
    private final ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();
    private final Lock readLock = rwLock.readLock();
    private final Lock writeLock = rwLock.writeLock();
    
    public void incrementCounter() {
        writeLock.lock();
        try {
            counter += 1;
        } finally {
            writeLock.unlock();
        }
    }
    
    public int getCounter() {
        readLock.lock();
        try {
            return counter;
        } finally {
            readLock.unlock();
        }
    }

   // standard constructors
   
}
```
## 13. 结论
在本文中，我们学习了**Java中的线程安全性是什么，已经深入探讨了实现它的多种不同方式**。

和往常一样，本文代码可在 [GitHub 仓库](https://github.com/eugenp/tutorials/tree/master/core-java-modules/core-java-concurrency-basic)上找到。

## Reference
- [什么是线程安全性，如何实现它](https://www.baeldung.com/java-thread-safety)