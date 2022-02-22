# 学习 REST

## 一 什么是 REST?

REST 是 **RE**presentational **S**tate **T**ransfer 的首字母缩略词，是分布式超媒体系统的一种架构风格。Roy Fielding 于 2000 年在他的[学位论文](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)中首次提出这个构想。

和其它架构风格一样，REST 尤其自身指导原则和限制。如果服务接口需要被成为 **RESTful**，这些原则就必须被满足。

> 一个 Web API（或 Web 服务）如果遵从 REST 架构风格，就可称为一个 REST API。

### 1. REST 的指导原则

六个指导原则或者 [RESTful 架构限制](https://restfulapi.net/rest-architectural-constraints/)是：

#### 1.1. 统一接口

通过对组件接口应用[一般性原则](https://www.d.umn.edu/~gshute/softeng/principles.html)，我们能够简化系统架构并改善交互的可见性。

多个架构限制帮助获得统一的接口并指导组件的行为。

下面四个限制可以取得统一的 REST 接口：

- **资源识别** – 接口必须唯一识别涉及在客户和服务器间交互的每一个资源。
- **通过呈现来控制资源** – 资源在服务器回复中应该有统一的呈现。API 消费者应该使用这些呈现来修改资源在服务器端的状态
- **自描述消息** – 每一个资源呈现应该携带足够的信息以描述如何处理这些消息。它也应该提供额外的客户端可以在资源上采取的行动信息。
- **超媒体作为应用状态的引擎** – 客户端应该仅仅拥有应用的初始 URL。客户端应用应该使用超链接来驱动所有其它资源和交互。

#### 1.2. 客户端-服务器

客户端-服务器设计模式强制关注点分离（separation of concerns），这帮助了客户端和服务器端组件各自独立演化。

通过分离用户接口关注点（客户端）和数据存储关注点（服务器端），我们改进了跨多个平台用户接口的可移植性，通过简化服务器端改进了其可扩展性。

当客户端和服务器端演化时，我们不得不确保客户端和服务器端的接口/协议不会被打破。

#### 1.3. 无状态（Stateless）

[无状态](https://restfulapi.net/statelessness/)意味着从客户端到服务器的任何请求必须包含理解和完成请求所需的所有信息。

服务器不能利用任何先前存储在服务器上的上下文信息。

基于这个原因，客户端必须完整保持会话状态。

#### 1.4. 可缓存（Cacheable）

[可缓存的限制](https://restfulapi.net/caching/)要求一个回复应该隐式地或者显式地标记自己可缓存地或不可缓存地。

如果回复可缓存，客户端得到授权在一个给定时期对相等的请求可以服用回复数据。

#### 1.5. 分层系统（Layered system）

分层系统的风格通过限制组件的行为来允许一个架构由多层构成。

例如，在一个分层系统中，每个组件不能看到与其交互直接层之外。

#### 1.6. 随需编码（可选）（Code on demand(optional））

REST 也允许通过下载和执行 applets 或 scripts 形式的代码以扩展客户端功能。

通过减少需要预先实现的特性数目，下载的代码可以简化客户端。服务器端可以以代码形式发送到客户端来提供部分特性。然后客户端只需执行代码。

### 2. 什么是一个资源

### 3. 资源方法

### 4. REST 和 HTTP 并不一样

### 5. 总结

## 二 REST 限制
## 三 REST 资源命名指南
# 指南
## 一 缓存（Caching）
## 二 压缩
## 三 内容协商（Content Negotiation）
## 四 HATEOAS
## 五 Idempotence
## 六 Security Essentials

## 七 版本变迁（Versioning）

为了管理复杂性，版本化你的 API。当需要的修改可以在 API 级别识别时，版本可以帮我们快速迭代。

> 随着我们对一个系统的知识和经常增长，API 的修改是不可避免的。当它可能破坏与客户的集成时，管理这种修改带来的影响是一个巨大的挑战。

### 7.1 什么时候版本化（When to version?）

**当做出破坏性修改时，API 仅仅需要递增版本（up-versioned ）**。

破坏性修改包括：

- 一个或多个调用的回复数据格式的修改
- 请求或回复类型的修稿（例如，修改整形数到浮点数）
- 移除部分 API

**破坏性修改**应该总会导致 API 主版本的数字或者内容[回复格式](https://www.iana.org/assignments/media-types/media-types.xhtml)变化)。

**非破坏性修改**，例如增加新的端点或新的回复参数，不需要修改主版本号。

> 但是，当做出修改以支持可能受到缓存版本数据或经历其它 API 问题的客户时，追踪 API 小版本的变化时很有帮助的。

### 7.2 如何版本化一个 REST API

[REST](https://restfulapi.net/)没有提供任何特定的版本化指南，但是常用的方式包含下面三种类别：

#### 7.2.1 URI 版本化

使用 URI 是最直接的方式（也是使用最广泛的方式），虽然它违反了一个 URI 应该指向一个唯一资源的原则。你也需要确保版本更新时会打破与客户端集成。

```
http://api.example.com/v1
http://apiv1.example.com
```

版本不需要是数字，也不需要特定于 `“v[x]”` 语法。

可选项包括日期，项目名，季节，或其它标识符，只要它们对产生 API 团队足够有意义且足够灵活--当版本变化时易于改变。

#### 7.2.2 使用自定义请求头部实现版本化

一个自定义头（例如 `Accept-version`）允许你在不同版本之间保留你的 URI，但它可以通过已有的接受头部（`Accept header`）老有效实现内容协商：

```
Accept-version: v1
Accept-version: v2
```

#### 7.2.3 使用 “Accept” 头部支持版本化

[内容协商](https://restfulapi.net/content-negotiation/)可以让你保留一套干净的 URLs，但有些地方你还是不得不处理服务于不同版本内容的复杂性。

这个负担移向你的 API 控制器栈的上部，它负责指出需要向哪个版本的资源发送请求。

由于客户在请求资源之前不得不清楚知道需要指定那些头部，这个结果将导致一个更为复杂的 API。

```
Accept: application/vnd.example.v1+json
Accept: application/vnd.example+json;version=1.0
```

在真实的世界里，一个 API 不会永远保持稳定。因此如何管理修改时很重要的。

对大部分 API 一个拥有良好文档且逐步废弃（无用）API 时一个可接受的实践。

## 八 REST APIs 里的无状态（Statelessness in REST APIs）
# 技术-如何做（Tech – How To）
## 一 REST API 设计教程
## 二 使用JAX-RS 创建 REST APIs
# 常见问题
## 一 PUT vs POST
## 二 N+1 Problem
## 三 ‘q’ Parameter
# 资源
## 一 What is an API?
## 二 SOAP 与 REST APIs 比较
## 三 HTTP 方法
## 四 Richardson 成熟度模型
## 五 HTTP 回复代码
### 200 (OK)
### 201 (Created)
### 202 (Accepted)
### 204 (No Content)
### 301 (Moved Permanently)

## Reference
- [Learn REST](https://restfulapi.net/)