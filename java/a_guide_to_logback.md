# logback教程
## 1. 简介
[logback](https://logback.qos.ch/)是Java社区最广泛使用的日志框架之一。它是[对其前任Log4j的替代](https://logback.qos.ch/reasonsToSwitch.html)。Logback提供了比Log4j更快的实现，提供了更多配置选项，也提供了归档旧的日志文件时更多的弹性。

本文介绍了Logback的结构，并向你展示如何使用它才能使你的应用更好。
## 2. Logback 架构
3个类组成了 `Logback` 的主体架构：`Logger`, `Appender`, 和 `Layout`。

`logger` 是打印消息的上下文。这是应用主要交互的类，用来创建日志消息。

`Appenders` 将日志消息纸放到它们的最终目的地。一个 `Logger`可以拥有多个 `Appenders`。我们通常认为 `Appender` 附加到文本文件上，但 `Logback` 可以做到更多。

`Layout` 准备消息用于输出。`Logback` 支持创建自定义类来格式化消息，也支持对现有类的健壮的配置选项。
## 3. 安装
### 3.1 Maven依赖
`Logback`使用Simple Logging Facade for Java (SLF4J)作为它的原生接口。在我们能够开始记录消息之前，我们需要将 Logback 和 Slf4j 添加到我们的 `pom.xml` 里:
```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-core</artifactId>
    <version>1.2.3</version>
</dependency>
 
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>1.7.30</version>
    <scope>test</scope>
</dependency>
```
Maven 中央存储库拥有[`Logback Core`的最新版本](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22ch.qos.logback%22%20AND%20a%3A%22logback-core%22)和[slf4j-api的最新版本](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22org.slf4j%22%20AND%20a%3A%22slf4j-api%22)。
### 3.2 类路径（Classpath）
`Logback`也要求 [logback-classic.jar](https://search.maven.org/classic/#search%7Cga%7C1%7Clogback-classic)在其运行类路径上。

我们将它加到`pom.xml`中作为测试依赖：
```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>
```
## 4. 基本示例和配置
让我们开始一个在应用中使用 `Logback` 的快速实例。

首先，我们需要一个配置文件，我们创建了一个名为 `logback.xml` 的文本文件，并把它放在类路径下：
```
<configuration>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>
 
  <root level="debug">
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
```
接下来，我们需要一个带有 `main` 方法的简单类：
```
public class Example {
 
    private static final Logger logger 
      = LoggerFactory.getLogger(Example.class);
 
    public static void main(String[] args) {
        logger.info("Example log from {}", Example.class.getSimpleName());
    }
}
```
这个类创建了一个 `Logger` ，并调用其 `info()` 方法来产生一条日志信息。

当I运行这个示例时，你会看到我们的消息呗打印到终端上：
`20:34:22.136 [main] INFO Example - Example log from Example`

很容易看到为什么`Logback` 这么流行：我们只需几分钟就可以把它运行起来。

配置文件和代码给了我们一些它如何工作的提示：
- 我们拥有一个名为 `STDOUT的`的`Appendar`，它引用类 `ConsoleAppender`
- 有一个模式 `pattern` 描述了我们的日志消息的格式
- 我们的代码创建了一个 `Logger`，我们把我们的消息通过 `info()` 方法传递给它。

现在我们已经了解了基础部分，接下来让我们就近观察它。
## 5. Logger上下文
### 5.1 创建一个上下文
为了打印一条消息到`Logback`，我们从`SLF4J` 或 `Logback`初始化一个`Logger`：
```
private static final Logger logger 
  = LoggerFactory.getLogger(Example.class);

```
接下来并使用它：
```
logger.info("Example log from {}", Example.class.getSimpleName()
```
这是我们的日志上下文。当我们创建它时，我们向 `LoggerFactory`传递我们的类。这给了logger一个名字（有一个重载函数接受字符串参数）。

日志上下文以一种层级形式存在，看上去非常想Java对象层级体系：
- 一个 logger当其名字和“.”是一个后继 logger 名字的前缀时，它就是后者的祖先（ancestor）。
- 一个 logger如果在它及其子logger之间没有额外级别，它就是一个父亲级别，

例如，下面的`Example`类位于`com.baeldung.logback`包中，由另外一个类`ExampleAppender`位于`com.baeldung.logback.appenders`包中。
- ExampleAppender的logger属于Example logger的儿子。
- 所有的loggers都是预定义的根logger的子孙。

一个`logger`拥有一个日志级别，可以通过配置文件或`Logger.setLevel()`方法设定。代码中的级别设定将覆盖配置文件中的设定。

可能的日志级别按顺序为：`TRACE`, `DEBUG`, `INFO`, `WARN` 和 `ERROR`。每个级别有一个对应的方法，我们使用它来记录独影级别的消息。

如果一个logger没有显式设定日志级别，它会从离其最近的祖先中继承。根logger缺省级别为DEBUG，下面我们将看到如何改变它。
### 5.2 创建一个上下文
### 5.3 创建一个上下文
### 5.4 创建一个上下文
### 5.5 创建一个上下文
## 6. 基本示例和配置
## 7. 基本示例和配置
## 8. 基本示例和配置
## 9. 结论

## Reference
- [A Guide To Logback](https://www.baeldung.com/logback)