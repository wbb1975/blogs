# C++ 智能指针最佳实践&源码分析
> 智能指针在 C++11 标准中被引入真正标准库（C++98 中引入的 auto_ptr 存在较多问题），但目前很多 C++开发者仍习惯用原生指针，视智能指针为洪水猛兽。但很多实际场景下，智能指针却是解决问题的神器，尤其是一些涉及多线程的场景下。本文将介绍智能指针可以解决的问题，用法及最佳实践。并且根据源码分析智能指针的实现原理。
## 一、为什么需要使用智能指针
### 1.1 内存泄漏
C++在堆上申请内存后，需要手动对内存进行释放。代码的初创者可能会注意内存的释放，但随着代码协作者加入，或者随着代码日趋复杂，很难保证内存都被正确释放。

尤其是一些代码分支在开发中没有被完全测试覆盖的时候，就算是内存泄漏检查工具也不一定能检查到内存泄漏。
```
void test_memory_leak(bool open)
{
    A *a = new A();

    if(open)
    {
        // 代码变复杂过程中，很可能漏了 delete(a);
        return;
    }

    delete(a);
    return;
}
```
### 1.2 多线程下对象析构问题
多线程遇上对象析构，是一个很难的问题，稍有不慎就会导致程序崩溃。因此在对于 C++开发者而言，经常会使用静态单例来使得对象常驻内存，避免析构带来的问题。这势必会造成内存泄露，当单例对象比较大，或者程序对内存非常敏感的时候，就必须面对这个问题了。

先以一个常见的 C++多线程问题为例，介绍多线程下的对象析构问题。

比如我们在开发过程中，经常会在一个 Class 中创建一个线程，这个线程读取外部对象的成员变量。
```
// 日志上报Class
class ReportClass
{
private:
    ReportClass() {}
    ReportClass(const ReportClass&) = delete;
    ReportClass& operator=(const ReportClass&) = delete;
    ReportClass(const ReportClass&&) = delete;
    ReportClass& operator=(const ReportClass&&) = delete;

private:
    std::mutex mutex_;
    int count_ = 0;
    void addWorkThread();

public:
    void pushEvent(std::string event);

private:
    static void workThread(ReportClass *report);

private:
    static ReportClass* instance_;
    static std::mutex static_mutex_;

public:
    static ReportClass* GetInstance();
    static void ReleaseInstance();
};

std::mutex ReportClass::static_mutex_;
ReportClass* ReportClass::instance_;

ReportClass* ReportClass::GetInstance()
{
    // 单例简单实现，非本文重点
    std::lock_guard<std::mutex> lock(static_mutex_);
    if (instance_ == nullptr) {
        instance_ = new ReportClass();
        instance_->addWorkThread();
    }
    return instance_;
}

void ReportClass::ReleaseInstance()
{
    std::lock_guard<std::mutex> lock(static_mutex_);
    if(instance_ != nullptr)
    {
        delete instance_;
        instance_ = nullptr;
    }
}

// 轮询上报线程
void ReportClass::workThread(ReportClass *report)
{
    while(true)
    {
        // 线程运行过程中，report可能已经被销毁了
        std::unique_lock<std::mutex> lock(report->mutex_);
        if(report->count_ > 0)
        {
            report->count_--;
        }

        usleep(1000*1000);
    }
}

// 创建任务线程
void ReportClass::addWorkThread()
{
    std::thread new_thread(workThread, this);
    new_thread.detach();
}

// 外部调用
void ReportClass::pushEvent(std::string event)
{
    std::unique_lock<std::mutex> lock(mutex_);
    this->count_++;
}
```
使用 `ReportClass` 的代码如下：
```
ReportClass::GetInstance()->pushEvent("test");
```
但当这个外部对象（即 `ReportClass`）析构时，对象创建的线程还在执行。此时线程引用的对象指针为野指针，程序必然会发生异常。

解决这个问题的思路是在对象析构的时候，对线程进行 `join`。
```
// 日志上报Class
class ReportClass
{
private:
    //...
    ~ReportClass();

private:
    //...
    bool stop_ = false;
    std::thread *work_thread_;
    //...
};

// 轮询上报线程
void ReportClass::workThread(ReportClass *report)
{
    while(true)
    {
        std::unique_lock<std::mutex> lock(report->mutex_);

        // 如果上报停止，不再轮询上报
        if(report->stop_)
        {
            break;
        }

        if(report->count_ > 0)
        {
            report->count_--;
        }

        usleep(1000*1000);
    }
}

// 创建任务线程
void ReportClass::addWorkThread()
{
    // 保存线程指针，不再使用分离线程
    work_thread_ = new std::thread(workThread, this);
}

ReportClass::~ReportClass()
{
    // 通过join来停止内部线程
    stop_ = true;
    work_thread_->join();
    delete work_thread_;
    work_thread_ = nullptr;
}
```
这种方式看起来没问题了，但是由于这个对象一般是被多个线程使用。假如某个线程想要释放这个对象，但另外一个线程还在使用这个对象，可能会出现野指针问题。就算释放对象的线程将对象释放后将指针置为 `nullptr`，但仍然可能在多线程下在指针置空前被另外一个线程取得地址并使用。
线程 A|线程 B
--------|--------
ReportClass::GetInstance()->ReleaseInstance();|ReportClass *report = ReportClass::GetInstance(); if(report) {// 此时切换到线程 A report->pushEvent("test");}
## 二、智能指针的基本用法
智能指针设计的初衷就是可以帮助我们管理堆上申请的内存，可以理解为开发者只需要申请，而释放交给智能指针。

目前 C++11 主要支持的智能指针为以下几种：
- unique_ptr
- hared_ptr
- weak_ptr
### 2.1 unique_ptr
先上代码
```
class A
{
public:
    void do_something() {}
};

void test_unique_ptr(bool open)
{
    std::unique_ptr<A> a(new A());
    a->do_something();

    if(open)
    {
        // 不再需要手动释放内存
        return;
    }

    // 不再需要手动释放内存
    return;
}
```
`unique_ptr` 的核心特点就如它的名字一样，它拥有对持有对象的唯一所有权。即两个 `unique_ptr` 不能同时指向同一个对象。

那具体这个唯一所有权如何体现呢？
+ `unique_ptr` 不能被复制到另外一个 `unique_ptr`
+ `unique_ptr` 所持有的对象只能通过转移语义将所有权转移到另外一个 `unique_ptr`
  ```
  std::unique_ptr<A> a1(new A());
  std::unique_ptr<A> a2 = a1;//编译报错，不允许复制
  std::unique_ptr<A> a3 = std::move(a1);//可以转移所有权，所有权转义后a1不再拥有任何指针
  ```

智能指针有一个通用的规则，就是 `->` 表示用于调用指针原有的方法，而 `.` 则表示调用智能指针本身的方法。

`unique_ptr` 本身拥有的方法主要包括：
1. get() 获取其保存的原生指针，尽量不要使用
2. bool() 判断是否拥有指针
3. release() 释放所管理指针的所有权，返回原生指针。但并不销毁原生指针。
4. reset() 释放并销毁原生指针。如果参数为一个新指针，将管理这个新指针
   ```
   std::unique_ptr<A> a1(new A());
   A *origin_a = a1.get();//尽量不要暴露原生指针
   if(a1)
   {
       // a1 拥有指针
   }

   std::unique_ptr<A> a2(a1.release());//常见用法，转义拥有权
   a2.reset(new A());//释放并销毁原有对象，持有一个新对象
   a2.reset();//释放并销毁原有对象，等同于下面的写法
   a2 = nullptr;//释放并销毁原有对象
   ```
### 2.2 shared_ptr
与 `unique_ptr` 的唯一所有权所不同的是， `shared_ptr` 强调的是共享所有权。也就是说多个 `shared_ptr` 可以拥有同一个原生指针的所有权。
```
std::shared_ptr<A> a1(new A());
std::shared_ptr<A> a2 = a1;//编译正常，允许所有权的共享
```
`shared_ptr` 是通过引用计数的方式管理指针，当引用计数为 `0` 时会销毁拥有的原生对象。

`shared_ptr`本身拥有的方法主要包括：
1. get() 获取其保存的原生指针，尽量不要使用
2. bool() 判断是否拥有指针
3. reset() 释放并销毁原生指针。如果参数为一个新指针，将管理这个新指针
4. unique() 如果引用计数为 1，则返回 true，否则返回 false
5. use_count() 返回引用计数的大小
```
std::shared_ptr<A> a1(new A());
std::shared_ptr<A> a2 = a1;//编译正常，允许所有权的共享

A *origin_a = a1.get();//尽量不要暴露原生指针

if(a1)
{
    // a1 拥有指针
}

if(a1.unique())
{
    // 如果返回true，引用计数为1
}

long a1_use_count = a1.use_count();//引用计数数量
```
### 2.3 weak_ptr
`weak_ptr` 比较特殊，它主要是为了配合 `shared_ptr` 而存在的。就像它的名字一样，它本身是一个弱指针，因为它本身是不能直接调用原生指针的方法的。如果想要使用原生指针的方法，需要将其先转换为一个 `shared_ptr`。那 `weak_ptr` 存在的意义到底是什么呢？

由于 `shared_ptr` 是通过引用计数来管理原生指针的，那么最大的问题就是循环引用（比如 a 对象持有 b 对象，b 对象持有 a 对象），这样必然会导致内存泄露。而 `weak_ptr` 不会增加引用计数，因此将循环引用的一方修改为弱引用，可以避免内存泄露。

`weak_ptr` 可以通过一个 `shared_ptr` 创建。
```
std::shared_ptr<A> a1(new A());
std::weak_ptr<A> weak_a1 = a1;//不增加引用计数
```
`weak_ptr` 本身拥有的方法主要包括：
1. expired() 判断所指向的原生指针是否被释放，如果被释放了返回 true，否则返回 false
2. use_count() 返回原生指针的引用计数
3. lock() 返回 shared_ptr，如果原生指针没有被释放，则返回一个非空的 shared_ptr，否则返回一个空的 shared_ptr
4. reset() 将本身置空

```
std::shared_ptr<A> a1(new A());
std::weak_ptr<A> weak_a1 = a1;//不增加引用计数

if(weak_a1.expired())
{
    //如果为true，weak_a1对应的原生指针已经被释放了
}

long a1_use_count = weak_a1.use_count();//引用计数数量

if(std::shared_ptr<A> shared_a = weak_a1.lock())
{
    //此时可以通过shared_a进行原生指针的方法调用
}

weak_a1.reset();//将weak_a1置空
```
## 三、智能指针的最佳实践
以上只是智能指针的基本用法，但是真正上手实践的时候，却发现程序在不经意间崩溃了。踩过了几次坑后，很多同学就骂骂咧咧的放弃了（什么辣鸡东西）。因此想要用好智能指针还需要进一步了解智能指针，甚至需要了解智能指针源码实现。

这一节我们会基于基本用法，进一步说明智能指针的实践用法，一起驯服智能指针这头野兽。
### 3.1 智能指针如何选择
在介绍指针如何选择之前，我们先回顾一下这几个指针的特点
1. `unique_ptr` 独占对象的所有权，由于没有引用计数，因此性能较好
2. `shared_ptr` 共享对象的所有权，但性能略差
3. `weak_ptr` 配合 `shared_ptr`，解决循环引用的问题

由于性能问题，那么可以粗暴的理解：优先使用 `unique_ptr`。但由于 `unique_ptr` 不能进行复制，因此部分场景下不能使用的。
#### 3.1.1 unique_ptr 的使用场景
`unique_ptr` 一般在不需要多个指向同一个对象的指针时使用。但这个条件本身就很难判断，在我看来可以简单的理解：这个对象在对象或方法内部使用时优先使用 `unique_ptr`。
1. 对象内部使用
   ```
    class TestUnique
    {
    private:
        std::unique_ptr<A> a_ = std::unique_ptr<A>(new A());
    public:
        void process1()
        {
            a_->do_something();
        }

        void process2()
        {
            a_->do_something();
        }

        ~TestUnique()
        {
            //此处不再需要手动删除a_
        }
    };
   ```
2. 方法内部使用
   ```
   void test_unique_ptr()
   {  
       std::unique_ptr<A> a(new A());
       a->do_something();
   }
   ```
#### 3.1.2 shared_ptr 的使用场景及最佳实践
`shared_ptr` 一般在需要多个执行同一个对象的指针使用。在我看来可以简单的理解：这个对象需要被多个 Class 同时使用的时候。
```
class B
{
private:
    std::shared_ptr<A> a_;

public:
    B(std::shared_ptr<A>& a): a_(a) {}
};

class C
{
private:
    std::shared_ptr<A> a_;

public:
    C(std::shared_ptr<A>& a): a_(a) {}
};

std::shared_ptr<B> b_;
std::shared_ptr<C> c_;

void test_A_B_C()
{
    std::shared_ptr<A> a = std::make_shared<A>();
    b_ = std::make_shared<B>(a);
    c_ = std::make_shared<C>(a);
}
```
在上面的代码中需要注意，我们使用 `std::make_shared` 代替 `new` 的方式创建 `shared_ptr`。

因为使用 `new` 的方式创建 `shared_ptr` 会导致出现两次内存申请，而 `std::make_shared` 在内部实现时只会申请一个内存。因此建议后续均使用 `std::make_shared`。

如果A想要调用B和C的方法怎么办呢？可否在A中定义B和C的 `shared_ptr` 呢？答案是不可以，这样会产生循环引用，导致内存泄露。

此时就需要 `weak_ptr` 出场了。
```
class A
{
private:
    std::weak_ptr<B> b_;
    std::weak_ptr<C> c_;
public:
    void do_something() {}

    void set_B_C(const std::shared_ptr<B>& b, const std::shared_ptr<C>& c)
    {
        b_ = b;
        c_ = c;
    }
};
```

```
a->set_B_C(b_, c_);
```
如果想要在A内部将当前对象的指针共享给其他对象，需要怎么处理呢？

```
class D
{
private:
    std::shared_ptr<A> a_;

public:
    std::shared_ptr<A>& a): a_(a) {}
};

class A
{
//上述代码省略

public:
    void new_D()
    {
        //错误方式，用this指针重新构造shared_ptr，将导致二次释放当前对象
        std::shared_ptr<A> this_shared_ptr1(this);
        std::unique_ptr<D> d1(new D(this_shared_ptr1));
    }
};
```
如果采用 `this` 指针重新构造 `shared_ptr` 是肯定不行的，因为重新创建的 `shared_ptr` 与当前对象的 `shared_ptr` 没有关系，没有增加当前对象的引用计数。这将导致任何一个 `shared_ptr` 计数为 0 时提前释放了对象，后续操作这个释放的对象都会导致程序异常。

此时就需要引入 `shared_from_this`。对象继承了 `enable_shared_from_this` 后，可以通过 `shared_from_this()`  获取当前对象的 `shared_ptr` 指针。

```
class A: public std::enable_shared_from_this<A>
{
//上述代码省略

public:
    void new_D()
    {
        //错误方式，用this指针重新构造shared_ptr，将导致二次释放当前对象
        std::shared_ptr<A> this_shared_ptr1(this);
        std::unique_ptr<D> d1(new D(this_shared_ptr1));
        //正确方式
        std::shared_ptr<A> this_shared_ptr2 = shared_from_this();
        std::unique_ptr<D> d2(new D(this_shared_ptr2));
    }
};

```
### 3.2 智能指针的错误用法
智能指针的使用时有较多常见的错误用法，可能会导致程序异常。下面我会列举这些错误用法，开发时需要避免。
#### 3.2.1 使用智能指针托管的对象，尽量不要再使用原生指针
很多开发同学（包括我在内）在最开始使用智能指针的时候，对同一个对象会混用智能指针和原生指针，导致程序异常。
```
void incorrect_smart_pointer1()
{
    A *a= new A();
    std::unique_ptr<A> unique_ptr_a(a);

    // 此处将导致对象的二次释放
    delete a;
}
```
#### 3,2,2 不要把一个原生指针交给多个智能指针管理
如果将一个原生指针交个多个智能指针，这些智能指针释放对象时会产生对象的多次销毁
```
void incorrect_smart_pointer2()
{
    A *a= new A();
    std::unique_ptr<A> unique_ptr_a1(a);
    std::unique_ptr<A> unique_ptr_a2(a);// 此处将导致对象的二次释放
}
```
#### 3.2.3 尽量不要使用 get()获取原生指针
```
void incorrect_smart_pointer3()
{
    std::shared_ptr<A> shared_ptr_a1 = std::make_shared<A>();

    A *a= shared_ptr_a1.get();

    std::shared_ptr<A> shared_ptr_a2(a);// 此处将导致对象的二次释放

    delete a;// 此处也将导致对象的二次释放
}

```
#### 3.2.4 不要将 this 指针直接托管智能指针
```
class E
{
    void use_this()
    {
        //错误方式，用this指针重新构造shared_ptr，将导致二次释放当前对象
        std::shared_ptr<E> this_shared_ptr1(this);
    }
};
```

```
std::shared_ptr<E> e = std::make_shared<E>();
```
#### 3.2.5 智能指针只能管理堆对象，不能管理栈上对象
栈上对象本身在出栈时就会被自动销毁，如果将其指针交给智能指针，会造成对象的二次销毁
```
void incorrect_smart_pointer5()
{
    int int_num = 3;
    std::unique_ptr<int> int_unique_ptr(&int_num);
}
```
### 3.3 解决多线程下对象析构问题
有了智能指针之后，我们就可以使用智能指针解决多线程下的对象析构问题。

我们使用 `shared_ptr` 管理 `ReportClass`。并将 `weak_ptr` 传给子线程，子线程会判断外部的 `ReportClass` 是否已经被销毁，如果没有被销毁会通过 `weak_ptr` 换取 `shared_ptr`，否则线程退出。解决了外部对象销毁，内部线程使用外部对象的野指针的问题。
```
// 日志上报Class
class ReportClass: public std::enable_shared_from_this<ReportClass>
{
    //...

private:
    static void workThread(std::weak_ptr<ReportClass> weak_report_ptr);

private:
    static std::shared_ptr<ReportClass> instance_;
    static std::mutex static_mutex_;

public:
    static std::shared_ptr<ReportClass> GetInstance();
    static void ReleaseInstance();
};

std::mutex ReportClass::static_mutex_;
std::shared_ptr<ReportClass> ReportClass::instance_;

std::shared_ptr<ReportClass> ReportClass::GetInstance()
{
    // 单例简单实现，非本文重点
    std::lock_guard<std::mutex> lock(static_mutex_);
    if (!instance_) {
        instance_ = std::shared_ptr<ReportClass>(new ReportClass());
        instance_->addWorkThread();
    }
    return instance_;
}

void ReportClass::ReleaseInstance()
{
    std::lock_guard<std::mutex> lock(static_mutex_);
    if(instance_)
    {
        instance_.reset();
    }
}

// 轮询上报线程
void ReportClass::workThread(std::weak_ptr<ReportClass> weak_report_ptr)
{
    while(true)
    {
        std::shared_ptr<ReportClass> shared_report_ptr = weak_report_ptr.lock();
        if(!shared_report_ptr)
        {
            return;
        }

        std::unique_lock<std::mutex>(shared_report_ptr->mutex_);

        if(shared_report_ptr->count_ > 0)
        {
            shared_report_ptr->count_--;
        }

        usleep(1000*1000);
    }
}

// 创建任务线程
void ReportClass::addWorkThread()
{
    std::weak_ptr<ReportClass> weak_report_ptr = shared_from_this();
    std::thread work_thread(workThread, weak_report_ptr);
    work_thread.detach();
}

// 外部调用
void ReportClass::pushEvent(std::string event)
{
    std::unique_lock<std::mutex> lock(mutex_);
    this->count_++;
}
```
并且在多个线程使用的时候，由于采用 `shared_ptr` 管理，因此只要有 `shared_ptr` 持有对象，就不会销毁对象，因此不会出现多个线程使用时对象被析构的情况。只有该对象的所有 `shared_ptr` 都被销毁的时候，对象的内存才会被释放，保证的对象析构的安全。
## 四、智能指针源码解析
在介绍智能指针源码前，需要明确的是，智能指针本身是一个栈上分配的对象。根据栈上分配的特性，在离开作用域后，会自动调用其析构方法。智能指针根据这个特性实现了对象内存的管理和自动释放。

本文所分析的智能指针源码基于 `Android ndk-16b` 中 `llvm-libc++` 的 `memory` 文件。
### 4.1 unique_ptr
先看下 `unique_ptr` 的声明。`unique_ptr` 有两个模板参数，分别为 `_Tp` 和 `_Dp`。
- `_Tp` 表示原生指针的类型。
- `_Dp` 则表示析构器，开发者可以自定义指针销毁的代码。其拥有一个默认值 `default_delete<_Tp>`，其实就是标准的 `delete` 函数。
函数声明中 `typename __pointer_type<_Tp, deleter_type>::type` 可以简单理解为 `_Tp*`，即原生指针类型。
```
template <class _Tp, class _Dp = default_delete<_Tp> >
class _LIBCPP_TEMPLATE_VIS unique_ptr {
public:
  typedef _Tp element_type;
  typedef _Dp deleter_type;
  typedef typename __pointer_type<_Tp, deleter_type>::type pointer;
  //...
}
```
`unique_ptr` 中唯一的数据成员就是原生指针和析构器的 `pair`：
```
private:
  __compressed_pair<pointer, deleter_type> __ptr_;
```
下面看下unique_ptr的构造函数。
```
template <class _Tp, class _Dp = default_delete<_Tp> >
class _LIBCPP_TEMPLATE_VIS unique_ptr {

public:
  // 默认构造函数，用pointer的默认构造函数初始化__ptr_
  constexpr unique_ptr() noexcept : __ptr_(pointer()) {}

  // 空指针的构造函数，同上
  constexpr unique_ptr(nullptr_t) noexcept : __ptr_(pointer()) {}

  // 原生指针的构造函数，用原生指针初始化__ptr_
  explicit unique_ptr(pointer __p) noexcept : __ptr_(__p) {}

  // 原生指针和析构器的构造函数，用这两个参数初始化__ptr_,当前析构器为左值引用
  unique_ptr(pointer __p, _LValRefType<_Dummy> __d) noexcept
      : __ptr_(__p, __d) {}

  // 原生指针和析构器的构造函数，析构器使用转移语义进行转移
  unique_ptr(pointer __p, _GoodRValRefType<_Dummy> __d) noexcept
      : __ptr_(__p, _VSTD::move(__d)) {
    static_assert(!is_reference<deleter_type>::value,
                  "rvalue deleter bound to reference");
  }

  // 移动构造函数，取出原有unique_ptr的指针和析构器进行构造
  unique_ptr(unique_ptr&& __u) noexcept
      : __ptr_(__u.release(), _VSTD::forward<deleter_type>(__u.get_deleter())) {
  }

  // 移动赋值函数，取出原有unique_ptr的指针和析构器进行构造
  unique_ptr& operator=(unique_ptr&& __u) _NOEXCEPT {
    reset(__u.release());
    __ptr_.second() = _VSTD::forward<deleter_type>(__u.get_deleter());
    return *this;
  }
}
```
再看下 `unique_ptr` 几个常用函数的实现。
```
template <class _Tp, class _Dp = default_delete<_Tp> >
class _LIBCPP_TEMPLATE_VIS unique_ptr {
    // 返回原生指针
    pointer get() const _NOEXCEPT {
    return __ptr_.first();
    }

    // 判断原生指针是否为空
    _LIBCPP_EXPLICIT operator bool() const _NOEXCEPT {
    return __ptr_.first() != nullptr;
    }

    // 将__ptr置空，并返回原有的指针
    pointer release() _NOEXCEPT {
    pointer __t = __ptr_.first();
    __ptr_.first() = pointer();
    return __t;
    }

    // 重置原有的指针为新的指针，如果原有指针不为空，对原有指针所指对象进行销毁
    void reset(pointer __p = pointer()) _NOEXCEPT {
    pointer __tmp = __ptr_.first();
    __ptr_.first() = __p;
    if (__tmp)
        __ptr_.second()(__tmp);
    }
}
```
再看下 `unique_ptr` 指针特性的两个方法。
```
// 返回原生指针的引用
typename add_lvalue_reference<_Tp>::type
operator*() const {
  return *__ptr_.first();
}
// 返回原生指针
pointer operator->() const _NOEXCEPT {
  return __ptr_.first();
}
```
最后再看下 `unique_ptr` 的析构函数。
```
// 通过reset()方法进行对象的销毁
~unique_ptr() { reset(); }
```
### 4.2 shared_ptr
`shared_ptr` 与 `unique_ptr` 最核心的区别就是比 `unique_ptr` 多了一个引用计数，并由于引用计数的加入，可以支持拷贝。

先看下 `shared_ptr` 的声明。`shared_ptr` 主要有两个成员变量，一个是原生指针，一个是控制块的指针，用来存储这个原生指针的 `shared_ptr` 和 `weak_ptr` 的数量。
```
template<class _Tp>
class shared_ptr
{
public:
    typedef _Tp element_type;

private:
    element_type*      __ptr_;
    __shared_weak_count* __cntrl_;
    //...
}
```
我们重点看下 `__shared_weak_count` 的定义。
```
// 共享计数类
class __shared_count
{
    __shared_count(const __shared_count&);
    __shared_count& operator=(const __shared_count&);

protected:
    // 共享计数
    long __shared_owners_;
    virtual ~__shared_count();
private:
    // 引用计数变为0的回调，一般是进行内存释放
    virtual void __on_zero_shared() _NOEXCEPT = 0;

public:
    // 构造函数，需要注意内部存储的引用计数是从0开始，外部看到的引用计数其实为1
    explicit __shared_count(long __refs = 0) _NOEXCEPT
        : __shared_owners_(__refs) {}

    // 增加共享计数
    void __add_shared() _NOEXCEPT {
      __libcpp_atomic_refcount_increment(__shared_owners_);
    }

    // 释放共享计数，如果共享计数为0（内部为-1），则调用__on_zero_shared进行内存释放
    bool __release_shared() _NOEXCEPT {
      if (__libcpp_atomic_refcount_decrement(__shared_owners_) == -1) {
        __on_zero_shared();
        return true;
      }
      return false;
    }

    // 返回引用计数，需要对内部存储的引用计数+1处理
    long use_count() const _NOEXCEPT {
        return __libcpp_relaxed_load(&amp;__shared_owners_) + 1;
    }
};
```

```
class __shared_weak_count
    : private __shared_count
{
    // weak ptr计数
    long __shared_weak_owners_;

public:
    // 内部共享计数和weak计数都为0
    explicit __shared_weak_count(long __refs = 0) _NOEXCEPT
        : __shared_count(__refs),
          __shared_weak_owners_(__refs) {}
protected:
    virtual ~__shared_weak_count();

public:
    // 调用通过父类的__add_shared，增加共享引用计数
    void __add_shared() _NOEXCEPT {
      __shared_count::__add_shared();
    }
    // 增加weak引用计数
    void __add_weak() _NOEXCEPT {
      __libcpp_atomic_refcount_increment(__shared_weak_owners_);
    }
    // 调用父类的__release_shared，如果释放了原生指针的内存，还需要调用__release_weak，因为内部weak计数默认为0
    void __release_shared() _NOEXCEPT {
      if (__shared_count::__release_shared())
        __release_weak();
    }
    // weak引用计数减1
    void __release_weak() _NOEXCEPT;
    // 获取共享计数
    long use_count() const _NOEXCEPT {return __shared_count::use_count();}
    __shared_weak_count* lock() _NOEXCEPT;

private:
    // weak计数为0的处理
    virtual void __on_zero_shared_weak() _NOEXCEPT = 0;
};
```
其实 `__shared_weak_count` 也是虚类，具体使用的是 `__shared_ptr_pointer`。`__shared_ptr_pointer` 中有一个成员变量 `__data_`，用于存储原生指针、析构器、分配器。`__shared_ptr_pointer`继承了`__shared_weak_count`，因此它就主要负责内存的分配、销毁，引用计数。
```
class __shared_ptr_pointer
    : public __shared_weak_count
{
    __compressed_pair<__compressed_pair<_Tp, _Dp>, _Alloc> __data_;
public:
    _LIBCPP_INLINE_VISIBILITY
    __shared_ptr_pointer(_Tp __p, _Dp __d, _Alloc __a)
        :  __data_(__compressed_pair<_Tp, _Dp>(__p, _VSTD::move(__d)), _VSTD::move(__a)) {}

#ifndef _LIBCPP_NO_RTTI
    virtual const void* __get_deleter(const type_info&) const _NOEXCEPT;
#endif

private:
    virtual void __on_zero_shared() _NOEXCEPT;
    virtual void __on_zero_shared_weak() _NOEXCEPT;
};
```
了解了引用计数的基本原理后，再看下shared_ptr的实现。
```
// 使用原生指针构造shared_ptr时，会构建__shared_ptr_pointer的控制块
shared_ptr<_Tp>::shared_ptr(_Yp* __p,
                            typename enable_if<is_convertible<_Yp*, element_type*>::value, __nat>::type)
    : __ptr_(__p)
{
    unique_ptr<_Yp> __hold(__p);
    typedef typename __shared_ptr_default_allocator<_Yp>::type _AllocT;
    typedef __shared_ptr_pointer<_Yp*, default_delete<_Yp>, _AllocT > _CntrlBlk;
    __cntrl_ = new _CntrlBlk(__p, default_delete<_Yp>(), _AllocT());
    __hold.release();
    __enable_weak_this(__p, __p);
}

// 如果进行shared_ptr的拷贝，会增加引用计数
template<class _Tp>
inline
shared_ptr<_Tp>::shared_ptr(const shared_ptr& __r) _NOEXCEPT
    : __ptr_(__r.__ptr_),
      __cntrl_(__r.__cntrl_)
{
    if (__cntrl_)
        __cntrl_->__add_shared();
}

// 销毁shared_ptr时，会使共享引用计数减1，如果减到0会销毁内存
template<class _Tp>
shared_ptr<_Tp>::~shared_ptr()
{
    if (__cntrl_)
        __cntrl_->__release_shared();
}
```
### 4.3 weak_ptr
了解完 `shared_ptr`，`weak_ptr` 也就比较简单了。`weak_ptr` 也包括两个对象，一个是原生指针，一个是控制块。虽然 `weak_ptr` 内存储了原生指针，不过由于未实现 `operator->` 因此不能直接使用。
```
class _LIBCPP_TEMPLATE_VIS weak_ptr
{
public:
    typedef _Tp element_type;
private:
    element_type*        __ptr_;
    __shared_weak_count* __cntrl_;

}
```

```
// 通过shared_ptr构造weak_ptr。会将shared_ptr的成员变量地址进行复制。增加weak引用计数
weak_ptr<_Tp>::weak_ptr(shared_ptr<_Yp> const&amp; __r,
                        typename enable_if<is_convertible<_Yp*, _Tp*>::value, __nat*>::type)
                         _NOEXCEPT
    : __ptr_(__r.__ptr_),
      __cntrl_(__r.__cntrl_)
{
    if (__cntrl_)
        __cntrl_->__add_weak();
}

// weak_ptr析构器
template<class _Tp>
weak_ptr<_Tp>::~weak_ptr()
{
    if (__cntrl_)
        __cntrl_->__release_weak();
}

```

## Reference
- [C++ 智能指针最佳实践&源码分析](https://cloud.tencent.com/developer/article/1922161)
- [C++ 智能指针最佳实践&源码分析](https://blog.csdn.net/Tencent_TEG/article/details/122053250)