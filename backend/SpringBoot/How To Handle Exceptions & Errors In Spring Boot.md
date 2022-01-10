# Spring Boot 中如何处理错误和异常？
我们中的每个人都花费了大量的时间来学习 Spring & Spring Boot 中的大的主题，如 [Spring Boot Rest](https://javatechonline.com/how-to-develop-rest-api-using-spring-boot/)，Spring Boot MVC，[Spring Boot Security](https://javatechonline.com/how-to-implement-security-in-spring-boot-project/) 等。但通常我们不会考虑“在Spring Boot 中如何处理错误和异常”？这个主题对于无障碍运行程序是最重要的。另外，它对于其它开发者更容易地理解我们的代码流很有帮助。如果我们不能合适地处理它们，即使是查找错误和异常的源头也是令人恼火，有些时候我们不得不调试整个代码流以找出问题所在并解决。这样说来异常处理在软件开发活动中攀岩了一个非常重要的角色。
![Error Flow in Spring Boot](images/SpringBootErrorController-1.jpg)

在本文 “Spring Boot 中如何处理错误和异常？”中，我们将逐步学习如何处理错误和异常的所有方面。但是，Spring Boot 内部已经在框架级别处理了大多数常见异常，所以它使得我们的工作非常简单。我们甚至可以在学习和实现异常的过程中观察到 Spring Boot 的魅力。在我看来，每个开发者都应该学习这个主题，并接下来把学到的概念应用到实际项目中。让我们开始 “Spring Boot 中如何处理错误和异常？”吧。
## 1 整体上你能够期待从本文中获得什么？
一旦你阅读完这篇文章，你应该可以回答：
- 什么是在一个 Spring Boot 应用中实现异常处理器的重要性以及益处
- Spring Boot 的内建错误/异常处理内部如何工作地？
- 在不同场景下预定义 BasicErrorController 如何工作？
- 如何显式有意义的自定义错误/异常页面？
- 另外，什么是 HTTP 回复状态码？
- 哪些是最常用的 HTTP 回复状态码？
- 如何为一个特殊 HTTP 回复状态码创建特定错误页面？
- 如何创建一个自定义异常并将其映射到反应一个特定 HTTP 回复状态码的错误页面？
- 如何在自定义错误控制器中添加自定义错误属性？
- 默认情况下预定义错误控制器如何处理一个 REST 调用抛出的异常？
- 我们如何自定义错误状态码以及错误详细属性？
- 最后，我们如何自定义所有的错误属性？
- 注解 `@ControllerAdvice`, `@RestControllerAdvice`, `@ExceptionHandler`, `@ResponseStatus`, `@ResponseBody` 的使用
- 最后一个但不是最少一个，Spring Boot 中如何处理错误和异常？
## 2 通过内建功能 Spring Boot 应用如何在内部处理错误/异常？
为了演示一个 Spring Boot 项目的内建错误处理，我们将考虑最常用的处理流如 Spring Boot MVC 和 Spring Boot REST，两者都基于控制器，或者是正常控制器或者 `RestController`。同时在两种情况下，任意请求都先与 DispatcherServlet 交互。而且，任意请求在把回复发送回客户端之前还得与 `DispatcherServlet` 交互，无论它返回一个成功的结果，或者抛出异常导致的失败。如果它返回失败的结果，`DispatcherServlet` 调用一个预定义[函数式接口](https://javatechonline.com/functional-interface-java8/) ErrorController。在这种情况下 `BasicErrorController`（接口 ErrorController 的一个实现） 将处理该请求。`BasicErrorController` 拥有如下两个方法以处理此类请求：
- `errorHtml()` – 当请求来自于浏览器时调用（MVC 调用）
- `error()` – 当请求来自于非浏览器时媒介例如 postman 工具/客户端应用/其它应用 (REST 调用)。

由于下面的 `@RequestMapping` 注解里的默认路径 `BasicErrorController` 会显式错误/异常：
```
@RequestMapping(“${server.error.path:${error.path:/error}}”)
```
最终，MVC调用时一个带有一些状态码的默认白标签错误页面会出现在屏幕上。相似地，如果是一个 `REST` 调用，你将收到一个 `Json` 格式的错误消息，带有一些默认错误属性，如 状态，错误，消息，时间戳等。更进一步，如果你想在屏幕上展示自定义页面，我们该如何做？参见后面的章节。
## 3 如何显式有意义的自定义错误/异常页面？
## 4 什么是 HTTP 回复状态码？
## 5 有哪些常用 HTTP 回复状态码？
## 6 如何为一个特殊 HTTP 回复状态码创建特定错误页面？
## 7 如何创建一个自定义异常并将其映射到反应一个特定 HTTP 回复状态码的错误页面
### 7.1 创建自定义异常
### 7.2 创建自定义错误页面 (404.html)
## 8 在 Spring Boot 中如何编写自定义错误控制器？
### 8.1 自定义错误控制器以得到 HTML 格式输出
#### 8.1.1 输出
### 8.2 自定义错误控制器以得到 JSON 格式输出
#### 8.2.1 输出
## 9 如何在自定义错误控制器中添加自定义错误属性？
### 9.1 输出
## 10 默认情况下预定义错误控制器如何处理一个 REST 调用抛出的异常？
### 10.1 Step#1 : 利用 STS（Spring Tool Suite）创建 Spring Boot 启动器项目
### 10.2 Step#2 : 创建模型类如 Invoice.java
### 10.3 Step#3 : 创建控制器类如 InvoiceRestController.java
### 10.4 Step#4 : 创建自定义异常类如 InvoiceNotFoundException.java
### 10.5 测试异常
### 10.6 结论
## 11 我们如何自定义错误状态码以及错误详细属性？
### 11.1 自定义输出
## 12 我们如何自定义所有的错误属性？
### 12.1 Step#1 : 编写一个性的模型类如 ErrorType.java
### 12.2 Step#2 : 编写写一个新的处理类如 InvoiceExceptionhandler.java 
### 12.3 Step#3 : 编写一个新的自定义异常类及 Rest 控制器
### 12.4 测试自定义所悟属性
## 13 总结


## Reference
- [How To Handle Exceptions & Errors In Spring Boot?](https://javatechonline.com/how-to-handle-exceptions-errors-in-spring-boot/)