# GDB简介
## GDB常用命令
1. thread apply all <command> 在所有线程上运行<command>命令，例如：
   ```
   (gdb) thread apply all backtrace
   ```
2. 检测当前栈帧：
   - info frame lists general info about the frame (where things start in memory, etc.)
   - info args lists arguments to the function
   - info locals lists local variables stored in the frame
## 调试多线程应用
GDB提供以下设施用于调试多线程应用：
- automatic notification of new threads
- ‘thread thread-id’, a command to switch among threads
- ‘info threads’, a command to inquire about existing threads
- ‘thread apply [thread-id-list | all] args’, a command to apply a command to a list of threads
- thread-specific breakpoints
- ‘set print thread-events’, which controls printing of messages on thread start and exit.
- ‘set libthread-db-search-path path’, which lets the user specify which libthread_db to use if the default choice isn’t compatible with the program.

GDB线程调试设施允许你在应用运行时观察所有线程--但一旦GDB获得了控制权，一个特殊的线程将成为调试的焦点。该线程被称为当前线程。调试命令将从当前线程的观点来显示程序信息。

无论何时当GDB在你的应用中检测到一个新的线程，它将以`‘[New systag]’`的消息格式显示该线程的目标系统标识。这里`systag`是线程标识符，它的格式随不同系统而不同。例如，但GDB注意到一个新线程（）产生时），在`GNU/Linux`上你可能看到：
```
[New Thread 0x41e02940 (LWP 25582)]
```
作为对照，在其它系统上，`systag` 可能就是简单地`‘process 368’`，没有其它修饰符。

基于调试目的，GDB把它自己的线程数--通常是一个简单的整数--与每一个inferior的线程关联。这个数字在inferior中的所有线程唯一，但在不同inferior的线程中不唯一。

你可以通过使用inferior-num.thread-num格式来引用一个inferior中的特定线程，这被称为qualified 线程ID。这里inferior-num是inferior 线程号，thread-num 是给定inferior中的线程号。例如，线程2.3指inferior中的线程3。如果你省略inferior号（比如，线程3），那么GDB 推测你在访问当前inferior的线程。

除非你创建了另一个inferior，GDB 并不会显示线程号的inferior-num部分，即使你可以使用inferior-num.thread-num的全名来指代初始inferior，即1中的线程号。

某些命令接受以空格分隔的线程ID列表作为参数，一个列表元素可能是：
1. 线程ID作为‘info threads’ 显式的第一个字段，有或者没有inferior 修饰符：例如 ‘2.1’ or ‘1’。
2. 一个线程号的范围，一样地有或者没有inferior 修饰符，就像inf.thr1-thr2 或者 thr1-thr2。 例如 ‘1.2-4’ 或 ‘2-4’。
3. 一个inferior的所有线程，以一个星号开始指定，有或者没有inferior 修饰符，就像inf.* (例如, ‘1.*’) 或者 *。前者指代一个inferior的所有线程，后者没有inferior 修饰符，那就指代当前inferior的所有线程。

## Reference
- [How can I examine the stack frame with GDB?](https://stackoverflow.com/questions/2770889/how-can-i-examine-the-stack-frame-with-gdb)
- [Debugging with GDB](https://sourceware.org/gdb/current/onlinedocs/gdb/index.html)