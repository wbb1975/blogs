# Redis事件库（Event Library）
## 事件库（Event Library）
为什么我们需要事件库呢？让我们通过一系列问答形式来解析它：
+ 问：你期待一个网络服务器一直在忙于什么？
+ 答：在监听端口上检测连接请求并接受它们
+ 问：调用[call](http://man.cx/accept%282%29%20accept)将产生一个描述符，我们将用它来做什么？
+ 答：保存该描述符，并在其上执行非堵塞读写操作
+ 问：为什么这些读写（操作）必须为非堵塞的？
+ 答：如果文件操作（Unix中socket也是一个文件）是堵塞的，当一个服务器被一个文件操作堵塞，它怎样才能接受其它客户的连接请求？
+ 问：我猜测我必须在socket上做很多非堵塞操作来检测它何时准备好，对吗？
+ 答：是的，这正是事件库所做的工作。你已经抓住了本质。
+ 问：事件库是如何运作以达成目标的？
+ 答：它们使用操作系统的 [轮循](http://www.devshed.com/c/a/BrainDump/Linux-Files-and-the-Event-Poll-Interface/)机制和计时器。
+ 问：那么存在一些开源库来做你所描述的工作吗？
+ 答：是的，libevent和libev是两个从我脑海中出现的两个事件库。
+ 问：Redis使用了以上开源事件库来处理Socket上的事件吗？
+ 答：不，基于[各种原因](http://groups.google.com/group/redis-db/browse_thread/thread/b52814e9ef15b8d0/)，Redis使用自己的事件库。
## Redis 事件库（Event Library）
Redis实现了自己的事件库，它们位于ae.c中。

理解Redis事件库最好的方法是理解Redis如何使用它。
### 时间循环初始化
在redis.c定义的initServer函数初始化redisServer结构体变量的众多字段，其中之一就是Redis事件循环指针：
```
aeEventLoop *el
```
initServer 通过调用在ae.c中定义的aeCreateEventLoop函数来初始化`server.el`： 
```
typedef struct aeEventLoop
{
    int maxfd;
    long long timeEventNextId;
    aeFileEvent events[AE_SETSIZE]; /* Registered events */
    aeFiredEvent fired[AE_SETSIZE]; /* Fired events */
    aeTimeEvent *timeEventHead;
    int stop;
    void *apidata; /* This is used for polling API specific data */
    aeBeforeSleepProc *beforesleep;
} aeEventLoop;
```
 ### aeCreateEventLoop
 aeCreateEventLoop首先为aeEventLoop结构体分配内存，然后调用ae_epoll.c:aeApiCreate。

 aeApiCreate为aeApiState分配内存，aeApiState拥有两个字段：epfd持有从[epoll_create](http://man.cx/epoll_create%282%29)调用返回的epoll文件描述符，以及由Linux epoll库定义的epoll_event 结构体类型的字段events。events字段的使用将稍后描述。

 接下来是 ae.c:aeCreateTimeEvent。但在此之前initServer调用anet.c:anetTcpServer创建并返回一个监听描述符。该描述符缺省在端口6379上监听。返回的监听描述符被存储在server.fd字段中。
### aeCreateTimeEvent
aeCreateTimeEvent接受下列参数：
+ eventLoop：这是在redis.c中的server.el
+ milliseconds：从最近时间到计时器过期所需毫秒数（milliseconds）
+ proc：函数指针。用于存储计时器过期（expires）时必须调用的函数地址
+ clientData：大多数时为NULL
+ finalizerProc：定时事件从定时事件列表删除之前被调用的函数地址

initServer调用aeCreateTimeEvent来将一个定时事件加入到server.el的timeEventHead字段中。timeEventHead是此类定时事件的一个列表。从redis.c:initServer函数中对aeCreateTimeEvent的调用如下所示：
 ```
 aeCreateTimeEvent(server.el /*eventLoop*/, 1 /*milliseconds*/, serverCron /*proc*/, NULL /*clientData*/, NULL /*finalizerProc*/);
 ```
 redis.c:serverCron执行许多帮助Redis保持正常运行的操作。
### aeCreateFileEvent
aeCreateFileEvent函数的核心是执行系统调用[epoll_ctl](http://man.cx/epoll_ctl)来向由anetTcpServer创建的监听描述符添加EPOLLIN事件监控，并将它与由aeCreateEventLoop创建的epoll描述符联系起来。

下面是对从redis.c:initServer调用的aeCreateFileEvent所做操作的精确描述：

initServer传递以下参数给aeCreateFileEvent：
+ server.el：由aeCreateEventLoop创建的时间循环。epoll描述符可从server.el中获取
+ server.fd：监听描述符，他同时也是一个访问eventLoop->events列表的相关文件事件结构以及额外信息如回掉函数的索引，
+ AE_READABLE：指示server.fd被监听EPOLLIN事件
+ acceptHandler：当被监听事件被触发时调用的函数。该函数指针被存储在eventLoop->events[server.fd]->rfileProc。

这里就完成了Redis时间循环的初始化。
### 事件循环处理（Event Loop Processing）
从redis.c:main调用的ae.c:aeMain将进行前一阶段初始化好的事件循环的处理工作。

ae.c:aeMain在一个while循环中调用ae.c:aeProcessEvents处理pending时间和文件事件。
#### aeProcessEvents
ae.c:aeProcessEvents在事件循环上调用ae.c:aeSearchNearestTimer查找pending事件最小的时间事件。在我们的例子事件循环中只有由ae.c:aeCreateTimeEvent创建的一个计时器事件。

记住，由aeCreateTimeEvent创建的计时器事件到现在为止可能已经过期了，原因在于它拥有毫秒（milliseconds）精度的过期时间。由于计时器已经过期，tvp timeval结构体变量的seconds和microseconds被初始化为0.

tvp结构体变量和事件循环变量一起被传递给ae_epoll.c:aeApiPoll。

aeApiPoll在epoll描述符上调用[epoll_wait](http://man.cx/epoll_wait)并按下面的细节设置eventLoop->fired表：
+ fd：读写就绪的描述符，依赖于掩码（mask）值
+ 掩码（mask）值：在对应描述符上可以执行的读写事件

aeApiPoll返回可以执行读写操作的描述符数。联系上下文，如果一个客户请求一个连接，aeApiPoll将会通知该事件，并在eventLoop->fired表中设置一项，其描述符为监听描述符，而掩码值为AE_READABLE。

现在，aeProcessEvents调用被注册为回调的redis.c:acceptHandler。acceptHandler在监听描述符上执行一个[accept](http://man.cx/accept)操作，并返回一个对应客户的连接描述符。redis.c:createClient通过像下面那样在连接描述符上调用ae.c:aeCreateFileEvent 来添加文件事件：
```
if (aeCreateFileEvent(server.el, c->fd, AE_READABLE,
    readQueryFromClient, c) == AE_ERR) {
    freeClient(c);
    return NULL;
}
```

c是redisClient结构体变量，c->fd是该连接描述符。

接下来ae.c:aeProcessEvent 将调用ae.c:processTimeEvents。 
#### processTimeEvents
ae.processTimeEvents将迭代由eventLoop->timeEventHead开始的时间事件列表。

对每个到期的时间事件processTimeEvents将调用其注册回调函数。本例中它将调用唯一时间事件回调函数redis.c:serverCron。回掉函数返回该函数被再次调用时必须经过的毫秒（milliseconds）数。这个修改通过ae.c:aeAddMilliSeconds记录，并将在ae.c:aeMain时间循环的下一次迭代中调用。

这就是所有的信息了：）。

## Reference
- [Redis Internals documentation](https://redis.io/topics/internals)
- [Redis Event Library](https://redis.io/topics/internals-rediseventlib)