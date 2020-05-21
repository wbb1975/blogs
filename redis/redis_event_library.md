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

 
### aeCreateTimeEvent
### aeCreateFileEvent
### 时间循环处理（Event Loop Processing）
### aeProcessEvents
### processTimeEvents

## Reference
- [Redis Internals documentation](https://redis.io/topics/internals)
- [Redis Event Library](https://redis.io/topics/internals-rediseventlib)