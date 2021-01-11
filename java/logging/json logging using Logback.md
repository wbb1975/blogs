# 会用 Logback 打印Json 日志
日志是有用的，能给我们提供更多洞察的日志更有用，日过它们容易做到这一点，那么它们更有用：）

大多数日志实现假定是人去消费日志描述。所以它们是格式化良好的字符串（想象printf），如此人可以很容易地阅读它们。在这些情况下，我们实际做的是创建了太多的的日志数据，而不能方便人的消费并提供更多洞见。人们通过关注自己所记录的来减少这样的过载，其思想是更少的信息更方便人来处理。不幸的是，我们事先并不能够知道调式一个问题所需要的信息。所以最终比较常见的是一些重要的信息（在日志里）丢失了。

记得我们如何对机器编程来消费大量数据并提供更好的洞见吗？因此为了创建为人来阅读的文件，我们需要为机器而创建。

一个工作的很好的日志格式是JSON。JSON 对象并不特别适合于人的阅读，但机器喜欢它。你可以使用任何JSON库来解析我们的日志。那么让我们来看看如何在一个clojure项目中用Logback 来记录JSON格式的日志。最好的部分在于我们并不需要我们记录日志的方式，我们仅仅需要配置Logback 来用JSON 格式打印日志。

首先我们需要在我们的[project.clj](https://gist.github.com/sivajag/6654921#file-project-clj)中加入这些依赖：
```
;;Logging Related Stuff
[org.clojure/tools.logging "0.2.4"]
[ch.qos.logback/logback-classic "1.0.7"]
[ch.qos.logback/logback-core "1.0.6"]
[ch.qos.logback.contrib/logback-json-classic "0.1.2"]
[ch.qos.logback.contrib/logback-jackson "0.1.2"]
[org.codehaus.jackson/jackson-core-asl "1.9.12"]
[com.fasterxml.jackson.core/jackson-databind "2.2.2"]
[org.slf4j/slf4j-api "1.7.0"]
[clj-logging-config "1.9.10" :exclusions [log4j]]
```
也要加入以下全局排除指令：
```
:exclusions [org.clojure/clojure
             org.slf4j/slf4j-log4j12
             org.slf4j/slf4j-api
             org.slf4j/slf4j-nop
             log4j/log4j
             log4j
             commons-logging/commons-logging
             org.clojure/tools.logging]
```
不幸的是，由于maven处理以来的方式，我们不得不添加这些排除指令（exclusions）。如果你的项目不依赖于任何第三方库，那么你也许可能避开这些。如果你的项目以来点方库，那么你最好添加这些排除指令（exclusions），如此你确切知道了你的类路径上真正包含哪些版本的日志库。

在你的类路径下创建[logback.xml](https://gist.github.com/sivajag/6654977#file-logback-xml)：
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/development.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <!– daily rollover –>
      <fileNamePattern>logs/development.%d{yyyy-MM-dd}.%i.gz</fileNamePattern>
      <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
        <!– or whenever the file size reaches 100MB –>
        <maxFileSize>100MB</maxFileSize>
      </timeBasedFileNamingAndTriggeringPolicy>
      <!– keep 30 days worth of history –>
      <maxHistory>30</maxHistory>
    </rollingPolicy>
    <append>true</append>
    <!– encoders are assigned the type ch.qos.logback.classic.encoder.PatternLayoutEncoder by default –>
    <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
      <layout class="ch.qos.logback.contrib.json.classic.JsonLayout">
        <jsonFormatter class="ch.qos.logback.contrib.jackson.JacksonJsonFormatter">
          <!– prettyPrint is probably ok in dev, but usually not ideal in production: –>
          <prettyPrint>true</prettyPrint>
        </jsonFormatter>
        <context>api</context>
        <timestampFormat>yyyy-MM-dd'T'HH:mm:ss.SSS'Z'</timestampFormat>
        <timestampFormatTimezoneId>UTC</timestampFormatTimezoneId>
        <appendLineSeparator>true</appendLineSeparator>
      </layout>
      <!– <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} – %msg%n</pattern> –>
    </encoder>
  </appender>
  <root level="trace">
    <appender-ref ref="FILE"/>
  </root>
</configuration>
```
Logback 使用配置文件来做一下这些事情：
1. 添加你的日志到 logs/development.log 文件
2. 使用 JSON 格式化器（formatter）
3. 更改日志时间错为UTC
4. 在每个日志记录后添加新行符
5. 基于日志文件的时间和大小滚动

现在你的日志应改为JSON 格式，这是从我的项目里抽取出来的[日志](https://gist.github.com/sivajag/6655005#file-log-json)片段：
```
{
  "timestamp": "2013-08-26T21:58:54.970Z",
  "level": "DEBUG",
  "thread": "304416706@qtp-1620812446-0",
  "mdc": {
    "ip-address": "192.0.0.1",
    "guid": "51f051bf-32c2-4a06-a81e-806e80966787",
    "request-method": "put",
    "facility": "api",
    "query-string": "",
    "pid": "66896",
    "env": "development",
    "uri": "/users/51f051bf-32c2-4a06-a81e-806e80966787",
    "server-name": "dev_api..com",
    "trace-id": ".env-:development.h-.rh-57ba5d92-36e2-4480-a2e1-d839542b705b.c-2.ts-1377554334965.v-GIT-SHA-NOT-SET"
  },
  "logger": "store.user-store",
  "message": "Finding user for provider : :provider/facebook and property : :identity/provider-uid,XXXXXX",
  "context": "default"
}
```
你可以把这些日志传递给日志管理服务器如Loggly，或者写你自己的常旭来提供更多洞见。

祝好的日志体验。

## Reference
- [JSON logging using Logback](https://sivajag.wordpress.com/2013/09/23/json-logging-using-logback/)