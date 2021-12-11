# Spring WebClient vs. RestTemplate
## 1. 介绍
在本教程中，我们将比较 Spring 的两款 Web 客户端实现，[RestTemplate](https://www.baeldung.com/rest-template) 和 Spring 5 的 reactive 替代品 [WebClient](https://www.baeldung.com/spring-5-webclient)。
## 2. 阻塞 & 非阻塞客户端
在一个 Web 应用里对其它服务作 HTTP 调用是一个普遍的需求。因此，我们需要一个 Web 客户端工具。
### 2.1 RestTemplate 阻塞式客户
很长一段时间，Spring 提供 RestTemplate 作为 Web 客户端抽象。在底层，RestTemplate 使用了 Java Servlet API，它基于每个请求一个线程的模型。

这意味着该线程将会阻塞直至 web 客户端收到了回复。阻塞式代码的问题在于每个线程都会消耗一定量的内存和CPU时间片。

让我们思考有许多请求到来，这些请求都在等待很慢的服务的回复，这时将会导致什么？

迟早这些等待的请求将会累积起来。结果，应用创建了很多线程，这将耗尽线程池资源或者占用所有可用的内存。我们也会经历由于频繁的 CPU上下文（线程）切换而导致的性能下降。
### 2.2 WebClient 非阻塞式客户
另一方面，WebClient 利用了 Spring Reactive 框架的异步非堵塞特性。

和 RestTemplate 为每一个事件（ HTTP调用）使用调用线程不同，WebClient 将会为每个事件创建一个 “任务”。在底层，Reactive 框架将会把这些“任务”放入队列，并且只有在合适的回复可用时才会执行它们。

Reactive 框架使用一个事件驱动架构，它提供了通过 [Reactive Streams API](https://www.baeldung.com/java-9-reactive-streams) 来构造异步逻辑的方法。结果，相比同步/堵塞模式，Reactive 模式可以通过使用更少的线程和系统资源来处理更多的逻辑。

WebClient 是 Spring WebFluxhttps://www.baeldung.com/spring-webflux库的一部分。因此我们可以额外地利用 Reactive 类型（(Mono 和 Flux) 利用 函数式 fluent API 编写代码来作为声明式组件。
## 3. 示例比较
为了掩饰这两种方法的差异，我们需要许多并发客户端请求来运行性能测试。我们将看到对于阻塞方法，当并发客户端请求达到一个阈值后有一个重大的性能下降。

另一方面，reactive/非堵塞方法将给出一个一致的性能，不管有多少请求。

对于本文的目的，让我们实现两个端点，一个使用 RestTemplate，另一个使用 WebClient。它们的任务是调用另一个慢速 REST 服务，它将返回一个推文列表。

作为磕头，我们将需要 [Spring Boot WebFlux starter dependency](https://search.maven.org/search?q=a:spring-boot-starter-webflux)：
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```
进一步，下面是我们的慢速服务 REST 端点：
```
@GetMapping("/slow-service-tweets")
private List<Tweet> getAllTweets() {
    Thread.sleep(2000L); // delay
    return Arrays.asList(
      new Tweet("RestTemplate rules", "@user1"),
      new Tweet("WebClient is better", "@user2"),
      new Tweet("OK, both are useful", "@user1"));
}
```
### 3.1 使用 RestTemplate 来调用慢服务
现在，让我们来实现另一个 REST 端点，它将通过 web 客户端来调用我们的慢服务。我们首先使用 RestTemplate：
```
@GetMapping("/tweets-blocking")
public List<Tweet> getTweetsBlocking() {
    log.info("Starting BLOCKING Controller!");
    final String uri = getSlowServiceUri();

    RestTemplate restTemplate = new RestTemplate();
    ResponseEntity<List<Tweet>> response = restTemplate.exchange(
      uri, HttpMethod.GET, null,
      new ParameterizedTypeReference<List<Tweet>>(){});

    List<Tweet> result = response.getBody();
    result.forEach(tweet -> log.info(tweet.toString()));
    log.info("Exiting BLOCKING Controller!");
    return result;
}
```
当我们调用这个端点时，由于 RestTemplate 的同步属性，代码将堵塞等待我们的慢服务的回复。只有在回复收到之后，这个方法的其它调用才会被执行。在日志中，我们将看到：
```
Starting BLOCKING Controller!
Tweet(text=RestTemplate rules, username=@user1)
Tweet(text=WebClient is better, username=@user2)
Tweet(text=OK, both are useful, username=@user1)
Exiting BLOCKING Controller!
```
### 3.2 使用 WebClient 来调用慢服务
其次，我们将使用 WebClient 来调用慢服务：
```
@GetMapping(value = "/tweets-non-blocking", 
            produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public Flux<Tweet> getTweetsNonBlocking() {
    log.info("Starting NON-BLOCKING Controller!");
    Flux<Tweet> tweetFlux = WebClient.create()
      .get()
      .uri(getSlowServiceUri())
      .retrieve()
      .bodyToFlux(Tweet.class);

    tweetFlux.subscribe(tweet -> log.info(tweet.toString()));
    log.info("Exiting NON-BLOCKING Controller!");
    return tweetFlux;
}
```
在这个例子中，WebClient 在方法执行结束时返回了一个 Flux publisher。一旦结果可用，publisher 将会向它的 subscribers 传送推文。注意一个客户（这里是浏览器）调用这个 /tweets-non-blocking 端点也会订阅返回的 Flux 对象。

让我们观察这次的日志：
```
Starting NON-BLOCKING Controller!
Exiting NON-BLOCKING Controller!
Tweet(text=RestTemplate rules, username=@user1)
Tweet(text=WebClient is better, username=@user2)
Tweet(text=OK, both are useful, username=@user1)
```
注意该端点方法在回复受到之前已经返回。
## 4. 结论
在本文中，我们解释了两种在 Spring 中使用 Web 客户端的方式.

RestTemplate 使用 Java Servlet API，因此时同步且堵塞的。相反，WebClient 是异步的并且在等待挥发返回之前永不会堵塞调用线程。只有当回复已经准备好时通知才会被产生出来。

RestTemplate 任然可以使用。在某些情况下，非堵塞方式使用比堵塞方式少得多的系统资源。因此， 在这些场景下，WebClient 时更推荐的方式。

本文中提到的带有代码片段可以通过 [GitHub](https://github.com/eugenp/tutorials/tree/master/spring-5-reactive-2) 找到。

## Reference
- [Spring WebClient vs. RestTemplate](https://www.baeldung.com/spring-webclient-resttemplate)
