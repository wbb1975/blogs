# 创建一个自定义 Logback Appender
## 1. 简介
在本文中，我们将探讨创建一个自定义Logback Appender。如果你在寻找Java中的日志设施的介绍， 那么请参考[这篇文章](https://www.baeldung.com/java-logging-intro)。

Logback 自带了许多内建的Appender，如写至标准输出，文件系统，数据库等。该框架的架构亮点杂鱼模块化，这意味着我们可以很容易定制它。

在本教程中，我们将关注 logback-classic，它需要下面的 Maven 依赖。
```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>
```

该依赖的最新版本可在[Maven中央仓库](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22ch.qos.logback%22%20AND%20a%3A%22logback-classic%22)获取。
## 2. 基类 Logback Appenders
Logback 提供了我们用于扩展创建自定义Appender的基类。

Appender 是所有的appenders都必须实现的普通接口。泛型类型为ILoggingEvent 或 AccessEvent，取决于我们是使用logback-classic 还是 logback-access。

**我们的自定义appender应该继承AppenderBase 或 UnsynchronizedAppenderBase**，这两者都实现了 Appender 并处理功能如 filters 和 status messages。

AppenderBase 是线程安全的，UnsynchronizedAppenderBase 子类自身负责管理线程安全。

就像ConsoleAppender 和 FileAppender 都扩展了OutputStreamAppender 并调用了基类函数 setOutputStream()。如果期待一个OutputStream，则自定义appender应该子类化 OutputStreamAppender。
## 3. 自定义Appender
队医我们的自定义实例，我么将创建一个名为 MapAppender 的玩具appender。这个 appender 将会把所有的日志事件插入到一个 ConcurrentHashMap，并以时间戳作为键。作为开始，我们子类化AppenderBase 并使用ILoggingEvent 为泛型类型。
```
public class MapAppender extends AppenderBase<ILoggingEvent> {

    private ConcurrentMap<String, ILoggingEvent> eventMap 
      = new ConcurrentHashMap<>();

    @Override
    protected void append(ILoggingEvent event) {
        eventMap.put(System.currentTimeMillis(), event);
    }
    
    public Map<String, ILoggingEvent> getEventMap() {
        return eventMap;
    }
}
```
接下来，为了让 MapAppender 开始接受日志事件，让我们在我们的配置文件 logback.xml 中添加它为一个Appender。
```
<configuration>
    <appender name="map" class="com.baeldung.logback.MapAppender"/>
    <root level="info">
        <appender-ref ref="map"/>
    </root>
</configuration>
``` 
## 4. 设置属性
Logback 使用 JavaBean 使用内省机制来分析 appender 的属性集。我们的 appender 需要 getter 和 setter 来允许内省机制来找到并设置这些属性。

让我们给 MapAppender 添加一个属性，该属性将为 eventMap 的键添加一个前缀。
```
public class MapAppender extends AppenderBase<ILoggingEvent> {

    //...

    private String prefix;

    @Override
    protected void append(ILoggingEvent event) {
        eventMap.put(prefix + System.currentTimeMillis(), event);
    }

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    //...

}
```
加下来，将该属性添加至我们的配置文件以设置前缀。
```
<configuration debug="true">

    <appender name="map" class="com.baeldung.logback.MapAppender">
        <prefix>test</prefix>
    </appender>

    //...

</configuration>
```
## 5. 错误处理
为了处理在我们的自定义appender的创建和配置过程中出现的错误，我们可以使用从 AppenderBase 继承过来的方法。

例如，当prefix 属性为null或者为空字符串时，MapAppender 可以调用 addError() 及早返回。
```
public class MapAppender extends AppenderBase<ILoggingEvent> {

    //...

    @Override
    protected void append(final ILoggingEvent event) {
        if (prefix == null || "".equals(prefix)) {
            addError("Prefix is not set for MapAppender.");
            return;
        }

        eventMap.put(prefix + System.currentTimeMillis(), event);
    }

    //...

}
```
当 debug 标记在我们的配置文件打开时，我们将在终端上看到一个错误警告我们前缀属性未被设置：
```
<configuration debug="true">

    //...

</configuration>
```
## 6. 结论
在这个快速指南中，我们关注了如何为 Logback 实现自定义 Appender。

和往常一样，实例代码可在 [Github](https://github.com/eugenp/tutorials/tree/master/logging-modules/logback) 上找到。

## Reference
- [Creating a Custom Logback Appender](https://www.baeldung.com/custom-logback-appender)
- [Chapter 6: Layouts](https://logback.qos.ch/manual/layouts.html#writingYourOwnLayout)
- [JSON logging using Logback](https://sivajag.wordpress.com/2013/09/23/json-logging-using-logback/)