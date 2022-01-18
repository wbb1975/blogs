# 创建异步方法
这个教程将带你创建异步查询 `GitHub`，重点在异步部分，一个可扩展服务常用到的特性。
## 我们将构建什么？
你将构建一个查询服务，它查询 `GitHub` 用户信息并通过 `GitHub API` 检索数据。对于可扩展服务的一种方法是在后台运行代价高昂的任务并使用 Java 的 [CompletableFuture](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)等待结果返回。Java 的 `CompletableFuture` 是常规 `Future` 的一种进化。它使得多个异步操作的管道化更为容易，并将它们合并成一个单独的异步计算。
## 我们需要些什么
- 大约15分钟
- 一个喜爱的文本编辑器或集成开发环境
- [JDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) 或更高版本
- [Gradle 4+](http://www.gradle.org/downloads) 或 [Maven 3.2+](https://maven.apache.org/download.cgi)
- 你可以将代码直接导入你的集成开发环境：
  + [Spring Tool Suite (STS)](https://spring.io/guides/gs/sts)
  + [IntelliJ IDEA](https://spring.io/guides/gs/intellij-idea/)
## 如何完成教程
像大多数Spring [入门指南](https://spring.io/guides)，你可以从头开始完成每一步，或跳过对你来讲很熟悉的基础设置步骤，每种方式你都可得到科工作的代码。

为了从头开始，请移步[Spring Initializr入门](https://spring.io/guides/gs/spring-boot/#scratch)。

为了跳过基础步骤，按下面的步骤操作：
+ [下载](https://github.com/spring-guides/gs-async-method/archive/main.zip)并解压本指南的代码库，货值使用git克隆：`git clone https://github.com/spring-guides/gs-async-method.git`
+ cd 到 `gs-async-method/initial`
+ 进入到[创建一个GitHub 用户表示类](https://spring.io/guides/gs/async-method/#initial)

当你完成后，你可以检查你的结果并与`gs-async-method/complete`中的代码比对。
## 从 Spring Initializr 开始
你可以使用[预初始化项目](https://start.spring.io/#!type=maven-project&language=java&platformVersion=2.5.5&packaging=jar&jvmVersion=11&groupId=com.example&artifactId=async-method&name=async-method&description=Demo%20project%20for%20Spring%20Boot&packageName=com.example.async-method&dependencies=web)，点击 `Generate` 并下载ZIP 文件。项目已经配置得适合教程里的项目。

为了手动初始化一个项目：
1. 导航到 `https://start.spring.io`，该服务将聚合你的项目所需的所有依赖，并为你做了大部分设置。
2. 选择 `Gradle` 或 `Maven` 以及你想使用的语言。本教程假设你使用 Java。
3. 点击 `Dependencies` 并选择 `Spring Web`
4. 点击 `Generate`
5. 下载结果 ZIP 文件。它是一个包含你的所有选择的一个归档文件。

> 如果你的集成开发环境已经有了 `Spring Initializr` 集成，你可以直接从你的集成开发环境完成这个过程
> 你也可以从 GitHub 克隆这个项目并用你的集成开发环境或文本编辑器打开。
## 创建一个 GitHub 用户表示
在你能够创建 GitHub 查询服务之前，你应该先定义一个表示类来代表你使用 GitHub API 检索返回的数据。

为了为用户表示建模，创建一个资源表示类。为了实现这个，创建一个带有字段，构造函数，访问器的 Java 普通对象，如下（`src/main/java/com/example/asyncmethod/User.java`）所示。
```
package com.example.asyncmethod;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown=true)
public class User {

  private String name;
  private String blog;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getBlog() {
    return blog;
  }

  public void setBlog(String blog) {
    this.blog = blog;
  }

  @Override
  public String toString() {
    return "User [name=" + name + ", blog=" + blog + "]";
  }

}
```
Spring 使用 [Jackson JSON](https://wiki.fasterxml.com/JacksonHome) 库来将 GitHub 的 JSON 回复转换为一个 `User` 对象。`@JsonIgnoreProperties` 注解告诉 Spring 忽略任何不在类里列出的属性，这使得 REST 调用及产生领域对象更容易。

在本教程中，为了演示目的我们仅仅抓取 `name` 和 `blog` 地址。
## 创建一个 GitHub 查询服务
接下来，我们需要创建一个服务查询 GitHub 以获取用户信息。下面（`src/main/java/com/example/asyncmethod/GitHubLookupService.java`）的代码就用于这个：
```
package com.example.asyncmethod;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.CompletableFuture;

@Service
public class GitHubLookupService {

  private static final Logger logger = LoggerFactory.getLogger(GitHubLookupService.class);

  private final RestTemplate restTemplate;

  public GitHubLookupService(RestTemplateBuilder restTemplateBuilder) {
    this.restTemplate = restTemplateBuilder.build();
  }

  @Async
  public CompletableFuture<User> findUser(String user) throws InterruptedException {
    logger.info("Looking up " + user);
    String url = String.format("https://api.github.com/users/%s", user);
    User results = restTemplate.getForObject(url, User.class);
    // Artificial delay of 1s for demonstration purposes
    Thread.sleep(1000L);
    return CompletableFuture.completedFuture(results);
  }

}
```
`GitHubLookupService` 使用 Spring 的 `RestTemplate` 来调用一个远程 REST 端点（`api.github.com/users/`），然后将回复转换为一个 `User` 对象。Spring Boot 自动提供了一个 `RestTemplateBuilder`，它为任何自动配置位（`MessageConverter`）使用默认值。

类使用 `@Service` 进行了注解，使得它成为 Spring 组件扫描并加入应用上下文的一个候选。

`findUser` 方法使用 Spring 的 `@Async` 注解进行了标记，指示它应该运行在一个单独的线程里。方法的返回类型是 [CompletableFuture<User>](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) 而非 `User`，这是所有异步服务的一个需求。代码使用 `completedFuture` 方法在 `GitHub` 查询完成结果可得时返回一个 `CompletableFuture` 实例。
> 创建 GitHubLookupService 的一个本地实例并不会允许 findUser 异步运行。它必须在一个 @Configuration 类里创建或者有 @ComponentScan 注解。

`GitHub API` 调用耗时可能变化较大，为了稍后在教程中演示，一个一秒的延迟并添加到该服务中。
## 使应用可执行
为了运行示例，你剋创建一个可执行 Jar。Spring 的 `@Async` 注解工作于 Web 应用，但你需要设置一个Web 容器以观察它的益处。下面的代码（`src/main/java/com/example/asyncmethod/AsyncMethodApplication.java`）演示了该如何做：
```
package com.example.asyncmethod;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@SpringBootApplication
@EnableAsync
public class AsyncMethodApplication {

  public static void main(String[] args) {
    // close the application context to shut down the custom ExecutorService
    SpringApplication.run(AsyncMethodApplication.class, args).close();
  }

  @Bean
  public Executor taskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(2);
    executor.setQueueCapacity(500);
    executor.setThreadNamePrefix("GithubLookup-");
    executor.initialize();
    return executor;
  }
}
```
> Spring Initializr 为你创建了一个 AsyncMethodApplication，你可以在从 Spring Initializr（（在 src/main/java/com/example/asyncmethod/AsyncMethodApplication.java 中）。）下载的 zip 文件中找到它。涅伊拷贝这个类到你的项目并修改它，或者从前面的列表中拷贝。

@SpringBootApplication 时一个方便的注解，它添加了以下这些：
- `@Configuration`： 标记类是一个为应用上下文的Bean定义源
- `@EnableAutoConfiguration`： 告诉 Spring Boot 基于类路径，其它 beans，以及各种属性设置来开始添加 bean。例如， 如果 `spring-webmvc` 在类路径上，这个注解将标记该应用为 Web 应用并激活关键行为，例如设置一个 `DispatcherServlet`。
- `@ComponentScan`： 告诉 Spring 去 `com/example` 包下查找其它组件，配置和服务，并让它找到控制器。

`main()` 使用 Spring Boot 的 `SpringApplication.run()` 方法来启动一个应用。你注意到这里没有一行 XML？这里也没有 `web.xml`。这个 Web 应用是 100% 纯 Java，你并不需要配置任何管道和基础设施。

`@EnableAsync` 注解切换 Spring 的功能以在后台线程池运行 `@Async` 方法。这个类通过定义一个新的 Bean 以自定义 `Executor`。这里该方法为 `taskExecutor`，因为它是 [Spring 查询的一个特殊方法](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/scheduling/annotation/EnableAsync.html)。在我们的例子中，我们想限制并行运行的线程数为 `2`，队列大小为 `500`。有[许多选项](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/integration.html#scheduling-task-executor)可以调整。如果你不指定一个 `Executor` bean，Spring 将创建一个 `SimpleAsyncTaskExecuton` 并使用它。

也有一个 CommandLineRunnerhttps://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-command-line-runner，它注入 GitHubLookupService 并调用该服务三次以演示方法的异步执行。

你也需要一个类以运行应用，你可以在 src/main/java/com/example/asyncmethod/AppRunner.java 中找到。下面是具体代码：
```
package com.example.asyncmethod;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;

@Component
public class AppRunner implements CommandLineRunner {

  private static final Logger logger = LoggerFactory.getLogger(AppRunner.class);

  private final GitHubLookupService gitHubLookupService;

  public AppRunner(GitHubLookupService gitHubLookupService) {
    this.gitHubLookupService = gitHubLookupService;
  }

  @Override
  public void run(String... args) throws Exception {
    // Start the clock
    long start = System.currentTimeMillis();

    // Kick of multiple, asynchronous lookups
    CompletableFuture<User> page1 = gitHubLookupService.findUser("PivotalSoftware");
    CompletableFuture<User> page2 = gitHubLookupService.findUser("CloudFoundry");
    CompletableFuture<User> page3 = gitHubLookupService.findUser("Spring-Projects");

    // Wait until they are all done
    CompletableFuture.allOf(page1,page2,page3).join();

    // Print results, including elapsed time
    logger.info("Elapsed time: " + (System.currentTimeMillis() - start));
    logger.info("--> " + page1.get());
    logger.info("--> " + page2.get());
    logger.info("--> " + page3.get());

  }
}
```
## 构建一个可执行 Jar
你可以从命令行上利用 Gradle 或 Maven 来运行应用。你也可以构建一个简单可执行 JAR 文件，它包含运行它所有必须的依赖，类，资源。构建一个可执行 JAR 使得在整个开发周期，跨不同环境交付，版本控制，以及部署应用为一个服务变得更容易。

如果你使用 Gradle，你可以使用 `./gradlew bootRun` 来运行应用。另一种方法是你运行 `./gradlew build` 以构建 `jar`，然后按如下方式运行 `jar`：
```
java -jar build/libs/gs-async-method-0.1.0.jar
```
如果你使用 Maven，你可以使用 `./mvnw spring-boot:run` 来运行应用。另一种方法是你运行 `./mvnw clean package` 以构建 `jar`，然后按如下方式运行 `jar`：
```
java -jar target/gs-async-method-0.1.0.jar
```
> 这里描述的是构建一个可运行jar，你也可以[构建一个经典 war 文件]https://spring.io/guides/gs/convert-jar-to-war/。

应用显示了日志输出，显示了每一次针对 `GitHub` 的查询。借助 `allOf` 工厂方法，我们创建了一个 `CompletableFuture` 对象数组。通过调用 `join` 方法，可以等到所有 `CompletableFuture` 对象的完成。

下面列出了实例应用的典型输出：
```
2016-09-01 10:25:21.295  INFO 17893 --- [ GithubLookup-2] hello.GitHubLookupService                : Looking up CloudFoundry
2016-09-01 10:25:21.295  INFO 17893 --- [ GithubLookup-1] hello.GitHubLookupService                : Looking up PivotalSoftware
2016-09-01 10:25:23.142  INFO 17893 --- [ GithubLookup-1] hello.GitHubLookupService                : Looking up Spring-Projects
2016-09-01 10:25:24.281  INFO 17893 --- [           main] hello.AppRunner                          : Elapsed time: 2994
2016-09-01 10:25:24.282  INFO 17893 --- [           main] hello.AppRunner                          : --> User [name=Pivotal Software, Inc., blog=https://pivotal.io]
2016-09-01 10:25:24.282  INFO 17893 --- [           main] hello.AppRunner                          : --> User [name=Cloud Foundry, blog=https://www.cloudfoundry.org/]
2016-09-01 10:25:24.282  INFO 17893 --- [           main] hello.AppRunner       
```
注意头两次调用发生在不同的线程里（`GithubLookup-2`, `GithubLookup-1`），第三次调用一直等待直到两个线程中的一个变得可用。为了与非异步版本比较任务的完成，注释掉 `@Async` 注解并再次运行服务。整个运行时间可以观察到可观的增长，原因在于每个查询花费至少一秒。你也可以增加 `corePoolSize` 的大小以调优 `Executor`。

重要的是，任务花费时间越长，同时运行的任务越多，从异步处理中你就能够看到更多的收益。你的代价是处理 CompletableFuture 接口。它增加了一层抽象，因为你不再直接处理结果。
## 总结
祝贺你！你已经开发了一个异步服务，它可以让你一次扩展多个调用。

[获取教程代码](https://github.com/spring-guides/gs-async-method)

## reference
- [Creating Asynchronous Methods](https://spring.io/guides/gs/async-method/)
- [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
- [Building an Application with Spring Boot](https://spring.io/guides/gs/spring-boot/)