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

REST 中的一个关键信息抽象是[资源](https://restfulapi.net/resource-naming/)，任何我们可以命名的信息都可以被成为资源。例如，一个 REST 资源可以是一个文档或图片，一个时间服务，一个其它资源的契合，或一个非虚拟的对象（例如一个人）。

在任何特定的时间资源的状态被称为**资源的呈现（resource representation）**。

资源的呈现包括：

- 数据
- 描述数据的元数据
- 超媒体链接用于帮助客户转换到另一个其期待的状态

> 一个 REST API 由多个相互连接的资源装配而来。这种资源集合也被称之为 REST API 的**资源模型**。

#### 2.1 资源标识符

REST 使用资源标识符来识别客户端与服务端组件交互中设计的每一个资源。

#### 2.2 超媒体

呈现的数据格式被称之为[媒体类型](https://www.iana.org/assignments/media-types/media-types.xhtml)，媒体类型表示了一个规范用于定于一个呈现该如何处理。

一个REST API 看起来像超文本https://restfulapi.net/hateoas/。每个可定位的信息单元携带有地址，显式地（例如，链接和 id 属性）或者隐式地（例如来自媒体类型定义或呈现结构）。

#### 2.3 自描述

进一步，资源呈现应该是自描述的：客户端并不需知道一个资源是一个雇员或一台设备。它应该基于与资源关联的媒体类型采取行动。

因此在实践中，我们会创建大量的自定义媒体类型--通常一个媒体类型关联一个资源。

每一个媒体类型定义了一个默认的处理模型。例如，HTML 定义了超文本的渲染处理以及围绕每一个元素的浏览器行为。

> 媒体类型与资源方法如 GET/PUT/POST/DELETE/... 无关。

### 3. 资源方法

与 REST 相关的另一个重要事情是**资源方法**。这些资源方法用于执行任意资源的两个状态间的期待的转换。

许多人错误地将`资源方法`与 [HTTP 方法](https://restfulapi.net/http-methods/)（例如 `GET/PUT/POST/DELETE`）关联。围绕哪个方法适用于那种情况 `Roy Fielding` 从未提到过任何建议。所有强调的点是它应该是一个**统一的接口**。

例如，如果我们决定应用 API 将利用 HTTP POST 来更新一个资源 -- 而不是大多数人建议的 HTTP PUT--你可以这么做。应用的接口仍然是 RESTful。

理想地，需要转换资源状态的任何事情因该是资源呈现的一部分 -- 包括所有支持的方法以及呈现的格式。

### 4. REST 和 HTTP 并不一样

许多人喜欢比较 HTTP 和 REST，**REST 和 HTTP 并不是一回事**。

> **REST != HTTP**

虽然 REST 也试图使 web (internet) 更流水线化和标准化，Roy fielding 提倡更严格地使用 REST 原则。正是从那里开始人们试着去比较 REST 与 Web。

Roy fielding 在他的论文中并未提及任何实现方向--包括倾向于任一协议或者 HTTP。到现在而止，我们遵从 REST 的六个原则，我们称之为我们的接口 -- RESTful。

### 5. 总结

简单来讲，在 REST 架构风格中，数据和功能被认定为资源并可通过**统一资源定位符（ Uniform Resource Identifiers）**来访问。

资源按照一套简单地，定义良好的操作运行，另外，资源应该与其呈现解耦，如此客户端才能各种格式访问其内容，例如 `HTML`, `XML`, `plain text`, `PDF`, `JPEG`, `JSON`，以及其它。

客户端和服务器端使用标准化接口及协议来交换资源呈现。典型地，HTTP 是使用最广泛的协议，但 REST 并未强制使用它。

资源相关元数据也是可用的，它被用于控制缓存，检测传输错误，协商合适的传输协议，执行认证及访问控制。

最重要的，与服务器的任何交互应该是无状态的。

所有这些原则帮助 RESTful 应用简单，轻量且快。

## 二 REST 限制

REST 代表 **Re**presentational **S**tate **T**ransfer，一个由 [Roy Fielding](https://en.wikipedia.org/wiki/Roy_Fielding) 在 2000 年提出的术语。它是设计适用于 HTTP 协议松耦合应用的架构风格。它常被用于开发 Web 服务。

REST 对于底层如何实现被没有添加任何强制规则，它仅仅提供高阶设计指南，具体如何实现则取决于我们自己。

在我上个雇佣期间，我花费了两年时间为一个大型电信公司设计了 RESTful APIs。在本文中，除了标准设计实践我将分享我的思想。在一些观点上，你可能不同意我的想法，那没关系。我非常乐意以一个开放的态度与你探讨一切。

让我们从标准设计开始--特定场景来理清 Roy Fielding 想让我们构建什么。然后我将讨论我的思想，它是关于你设计你的 RESTful APIs 时的更细的点。

REST 定义了 6 个架构限制，它使得任何 Web 服务成为一个真正的 RESTful API。

### 2.1 统一接口

正如限制名本身所示，你必须为你的系统资源决定 APIs 接口，它们将被暴露给 API 用户并被如宗教版地遵守。系统中的一个资源应该仅仅拥有一个逻辑 URI，且应该提供相关或额外数据的访问方式。把一个资源与 Web 页面同步是一个更好的主意。

任何单个资源都不应该太大，应该饱和一个单一完整的呈现。无论何时如果相关，一个资源应该包含**指向相关 URIs 的链接**（HATEOAS）以获取相关信息。

跨越系统的资源呈现也应该遵从特定指南，例如命名规范，链接格式，或数据格式（XML 或/和 JSON）。

所有的资源应该通过一个共同的方式访问，例如 HTTP GET，类似地通过一个一致的方式修改（资源）。

> 一旦一个开发者已经熟悉了你的 API 中的一个，它应该能够以同样的方式处理其它 APIs。

### 2.2 客户端-服务器

这个限制主要意味着客户端应用于服务器端应用必须能够独立演化而没有相互间依赖。客户端应该仅仅知道资源 URIs，那是所有（的信息）。今天，这是 Web 开发的标准实践，从你这边考虑没啥复杂的事情。让它保持简单。

> 服务器端和客户端可以被独立替代和开发，只要它们之间的接口未被更改。

### 2.3 无状态

Roy fielding 从 HTTP 得到灵感，它被反映到这个限制。使所有客户端-服务器端交互无状态。服务器端不会存储客户最近 HTTP 请求的任何信息。它将把每个请求当作新的请求，没有会话，没有历史。

如果客户端应用需要对终端用户有状态，比如用户一旦登陆就可以放发送一些特权请求，那么从客户端的每个请求应该包含所有的信息以服务该请求--包括认证和授权细节。

> 在不同的请求间不应该有什么客户端上下文被存储在服务器端。（应该是）客户端负责管理应用的状态。

### 2.4 可缓存

在今天的世界里，只要可行/可能，数据和回复的缓存是非常重要的，这里你正在阅读的网页也是一个缓存的 HTML 页面。缓存带来了客户端性能的提升，由于负荷的减少，服务器端扩展的范畴会更广（better scope for scalability）。

在 REST 中，当可行时，资源应尽量使用缓存，然后这些资源必须声明它们自己是可缓存的。缓存可在服务器端或客户端实现。

> 管理良好的缓存部分地或全部地消除了客户端-服务器端的交互，进而提高了性能和扩展性。

### 2.5 分层系统

REST 允许你使用一种分层系统架构，例如在服务器 A 部署你的应用，在服务器 B 上存储数据，服务器 C 对请求授权。一个客户端不能简单地宣称它直接连接到了后端服务器或者另一个中间层（intermediary ）。

### 2.6 随需编码（可选）

好吧，这个限制是可选的。大多数时候，你在以 XML 或 JSO 的形式发送资源的静态呈现。但当你需要如此做的时候，你可以选择返回可执行代码来支持你的应用的一部分，例如，客户端可能调用你的 API 而得到一个图形用户界面渲染代码。这是允许的。

> 所有以上的限制帮助你构建一个真正的 RESTful API，你应该遵循它们。但是，有时候你会发现你自己违反了一条或两条限制。不要担心，你任然在构建一个 RESTful API--但是不是 “truly RESTful.”。

注意所有上面的限制大多与 WWW (the web) 紧密相关，使用 RESTful APIs，你可以向对待你的 Web 页面一样来对你的 Web 服务做同样的事情。

## 三 REST 资源命名指南

### 3.1 什么是资源

在 [REST](https://restfulapi.net/)中，主要的数据呈现被称为**资源**。拥有一个一致且健壮的 REST 资源命名策略从长期来看将提升你的设计决策之一。 

#### 3.1.1 单例和集群资源

一个**资源可以是一个单例或者一个集合**。

例如，“customers” 是一个集合资源，“customer” 是一个单例资源（在银行业领域）。

我们可以使用 URI “/customers” 来识别 “customers” 集合资源；我们也能使用 URI “/customers/{customerId}“ 来识别单个 “customer” 资源。

#### 3.1.2 集合和子集合资源

一个**资源也可以包含子集合资源**。

例如，特定  “customer” 的子集合资源 “accounts” 可以使用 URN “/customers/{customerId}/accounts”（在银行业领域） 来识别。

类似地，在子集合资源 “accounts” 里的单个资源 “account” 可以以下面的格式识别 “/customers/{customerId}/accounts/{accountId}“。

#### 3.1.3 URI

REST APIs 使用[统一资源识别符](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)（URIs) 来表达资源。REST API 设计者应该创建 URIs，它可以对 API 的潜在客户表达 REST API 的资源模型。当资源命名良好时，该 API 容易理解且容易使用。如果反之，同样的 API 其理解和使用都将是一个挑战。

当你在为了你的新 API创建资源 URIs，下面是你可以借用的一些小窍门。

### 3.2 最佳实践

#### 3.2.1 使用名词复数来代表资源

RESTful URI 应该引用一个资源--它是一件事物（名词）而非一个行动（动词），原因在于事物拥有属性二行动没有--类似的，资源拥有属性。资源的一些例子如：

- 系统用户
- 用户账号
- 网络设备等

它们的资源 URIs 可以设计如下：

```
http://api.example.com/device-management/managed-devices 
http://api.example.com/device-management/managed-devices/{device-id} 
http://api.example.com/user-management/users
http://api.example.com/user-management/users/{id}
```

更清楚一些，让我们把资源原型分为四类（文档，集合，存储，以及控制器）。那么你最好总是将你的资源置于四类原型之一，并一致使用其命名惯例。

考虑到统一性，坚决抵制混合使用多种原型的诱惑。

##### 3.2.1.1 文档

一个文档资源是一个单数概念，就像一个对象实例或数据库记录。

在 REST 中，你可以把它看成资源集合里的一个单个资源。一个文档的状态呈现典型地包括字段值及与其它相关资源的链接。

使用单数（“singular”）名用于指定文档资源原型。

```
http://api.example.com/device-management/managed-devices/{device-id}
http://api.example.com/user-management/users/{id}
http://api.example.com/user-management/users/admin
```

##### 3.2.1.2 集合

一个集合资源是一个服务端管理的资源目录。

客户端可以建议像一个集合资源添加新的资源。但是，取决于集合资源本身来选择是否创建新的资源。

一个集合资源选择它期待包含什么，它也决定了包含的每个资源得 URI。

使用复数（ “plural”）名用于指定集合资源原型。

```
http://api.example.com/device-management/managed-devices
http://api.example.com/user-management/users
http://api.example.com/user-management/users/{id}/accounts
```

##### 3.2.1.3 存储

一个存储是一个客户端管理的资源库。一个存储资源让一个 API 客户在其中放置资源，并决定何时删除它们。

一个存储永不会产生新的 URIs，取而代之的是每一个存进的资源有其 URI，该 URI 由客户端在最初上传时选择。

使用复数（ “plural”）名用于指定存储资源原型。

```
http://api.example.com/song-management/users/{id}/playlists
```

##### 3.2.1.4 控制器

一个控制器资源对一个过程化概念建模。控制器资源就像可执行函数，拥有参数，返回值，输入以及输出。

使用动词（ “verb”）名用于指定控制器原型。

```
http://api.example.com/cart-management/users/{id}/cart/checkout
http://api.example.com/song-management/users/{id}/playlist/play
```

#### 3.2.2 一致性是关键

使用一致的资源命名惯例和 URI 格式以最小化不明确，最大化可读性和可维护性。你可能实现下面的设计窍门以取得一致性。

##### 3.2.2.1 使用斜杠（/）以指明层次关系

斜杠用于 URI 中的路径分割以指明不同资源间的层次关系。

```
http://api.example.com/device-management
http://api.example.com/device-management/managed-devices
http://api.example.com/device-management/managed-devices/{id}
http://api.example.com/device-management/managed-devices/{id}/scripts
http://api.example.com/device-management/managed-devices/{id}/scripts/{id}
```

##### 3.2.2.2 在 URI 尾部不要使用斜杠（/）

作为一个 URI 路径的最后一个字符，`/` 没有添加任何语义值，并可能导致混淆。组好从 URI 中将其移除。

```
http://api.example.com/device-management/managed-devices/ 
http://api.example.com/device-management/managed-devices  /* This is much better version */
```

##### 3.2.2.3 使用连字符（-）以改善 URI 可读性

为了使你的 URI 易于扫描和解释，在长路径段中使用连字符 (-) 以改善名字的可读性。

```
http://api.example.com/devicemanagement/manageddevices/
http://api.example.com/device-management/managed-devices 	/*This is much better version*/
```

##### 3.2.2.4 不要使用下划线（_）

使用下划线替换连字符来用作分隔符是可能的，但取决于应用的字体，有可能在某些浏览器或屏幕里下划线字符部分不透明或者完全隐藏。

为了避免此类混淆，使用连字符替换下划线：

```
http://api.example.com/inventory-management/managed-entities/{id}/install-script-location  //More readable

http://api.example.com/inventory-management/managedEntities/{id}/installScriptLocation  //Less readable
```

##### 3.2.2.5 在 URI 中是用小写字符

方便的时候，URI 路径中小写字符应该是首选。

```
http://api.example.org/my-folder/my-doc       //1
HTTP://API.EXAMPLE.ORG/my-folder/my-doc       //2
http://api.example.org/My-Folder/my-doc       //3
```

在上面的例子中，1 和 2 是相同的，但 3 不同，原因在于它使用大写的 **My-Folder** 。

#### 3.2.3 不要使用文件扩展名

文件扩展名看起来不太好，也不会增加任何优势。移除它们还可以减少 URI 长度，没有理由留下它们。

除了以上原因，如果你想使用文件扩展名以高亮 API 的媒体类型，那么你应该依赖媒体类型，正如通过 Content-Type 头沟通以决定如何处理回复内容。

```
http://api.example.com/device-management/managed-devices.xml  /*Do not use it*/

http://api.example.com/device-management/managed-devices 	/*This is correct URI*/
```

#### 3.2.4 永远不要在 URIs 中使用 CRUD 函数名

我们不应该使用 URI 来指示一个 CRUD 函数。URI 应该被用于唯一识别一个资源而不是加之于其上的动作。

我们应该使用 HTTP 方法来指明哪种 CRUD 函数应该被执行。

```
HTTP GET http://api.example.com/device-management/managed-devices  //Get all devices
HTTP POST http://api.example.com/device-management/managed-devices  //Create new Device

HTTP GET http://api.example.com/device-management/managed-devices/{id}  //Get device for given Id
HTTP PUT http://api.example.com/device-management/managed-devices/{id}  //Update device for given Id
HTTP DELETE http://api.example.com/device-management/managed-devices/{id}  //Delete device for given Id
```

#### 3.2.5 使用查询组件来过滤 URI 集合

你经常会遇到这样的需求，你需要一个根据一些特定的资源属性排序，过滤或者限制的一个资源集合。

对于这种需求，不要创建新的 API--作为替代，在资源集合 API 上开放排序，过滤或者分页能力，或传递输入参数作为查询参数等。

```
http://api.example.com/device-management/managed-devices
http://api.example.com/device-management/managed-devices?region=USA
http://api.example.com/device-management/managed-devices?region=USA&brand=XYZ
http://api.example.com/device-management/managed-devices?region=USA&brand=XYZ&sort=installation-date
```

# 指南
## 一 缓存（Caching）
## 二 压缩
## 三 内容协商（Content Negotiation）
## 四 HATEOAS
## 五 Idempotence
## 六 Security Essentials

REST API 安全不是事后诸葛亮，它是任何开发项目的一个必需部分，[REST](https://restfulapi.net/) API 同样如此。

有许多方法可以使得 RESTful API 更安全，例如，[basic auth](https://howtodoinjava.com/resteasy/jax-rs-resteasy-basic-authentication-and-authorization-tutorial/), [OAuth](https://oauth.net/) 等，但可以确信的一点是 RESTful APIs 应该是无状态的--因此请求的认证授权应该不依赖于会话。

取而代之的是，每个 API 请求应该带有某种认证凭证，它可被服务端用于每个请求的验证。

### 6.1 REST 安全设计原则

由 Jerome Saltzer 和 Michael Schroeder 撰写的[计算机系统信息安全](http://web.mit.edu/Saltzer/www/publications/protection/)提出了计算机系统信息安全的八个设计原则，如下节所述：

- **最小权限**：一个实体应该只有完成其获得授权的行动所需的必必要权限，没有更多。权限可以在需要时添加，但当其不再使用时应该被撤销
- **失败回退默认权限**：一个用户对系统资源的默认访问级别应该是“拒绝”，除非他被显式赋予“允许”权限
- **机制的经济性**：实现应该尽可能简单。所有组件接口和交互应该简单易于理解
- **完整仲裁**：一个系统应该所有对其资源的访问权限以确保它们是被允许的，不应该依赖缓存的许可距阵。如果对一个资源的访问级别已被撤销，但它却未在许可矩阵中反映出来，它就违反了安全性。
- **开放设计**：这个原则的亮点在于以开放的方式构建一个一个系统--没有机密，保密的算法
- **权限分离**：授予对一个实体的许可不应该仅仅基于一个单一的情况，基于资源类型考虑多种情况是一个更好的主意。
- **最小公共机制**：它担心存在于不同组件间的共享状态。如果一个人可以破坏该状态，它就可以破坏依赖于它的所有其它组件。
- **心里接受度**：它描述了安全机制不应该使得对资源的访问比没有安全机制时更困难。一句话，安全性不应该影响用户体验。

### 6.2 REST APIs 安全最佳实践

下面的观点可以用作设计 REST APIs 安全机制的一个检查列表。

#### 6.2.1 保持其简单

使得 API/系统安全--只需要使其达到所需的安全。每次你使得你的方案不必要的复杂，你就有可能留下了一个大坑。

#### 6.2.2 总是使用 HTTPS

总是使用 SSLhttps://www.digicert.com/ssl/，认证凭证可以简化为随机产生的访问令牌。令牌在 HTTP Basic Auth 中的用户名（username ）字段中发送。它用起来相对简单，而且你得到了许多安全特性。

如果你使用 [HTTP 2](https://http2.github.io/)，为了提升性能，你甚至可以[通过一个连接发送多个请求](https://en.wikipedia.org/wiki/HTTP_persistent_connection)，如此你可以在后续请求中避免完整 TCP 和 SSL 握手的负担。 

#### 6.2.3 使用密码哈希

密码必须总是经过哈希以保护系统（或最小化破坏）即使它可能在某些骇客攻击中失效。存在许多[哈希算法](https://howtodoinjava.com/security/how-to-generate-secure-password-hash-md5-sha-pbkdf2-bcrypt-examples/)已经证明了在密码安全方面的有效性，比如 PBKDF2, bcrypt, 和 scrypt 算法。

#### 6.2.4 永远不要在 URLs 中暴露信息

用户名，密码，会话令牌，以及 API Key 应该永远不会出现在 URL 上，因为它们可以被服务器端日志捕获，这使得它们很容易被利用。

```
https://api.domain.com/user-management/users/{id}/someAction?apiKey=abcd123456789  //Very BAD !!
```

上面的 URL 暴露了 API key。因此，永远不要使用这种安全形式。

#### 6.2.5 考虑 OAuth

虽然基础认证https://en.wikipedia.org/wiki/Basic_access_authentication对于大多数 API 足够好了，只要正确实施，它也足够安全--你可能仍会考虑 [OAuth](https://tools.ietf.org/html/rfc6749)。

OAuth 2.0 授权框架允许第三方应用获得对 HTTP 服务的优先访问（权限），或者代表资源拥有着在资源拥有者和 HTTP 服务之间编排合适的交互，或者允许第三方应用代表其自己获取权限。

#### 6.2.6 考虑 在请求中添加时间戳

与其它请求参数一道，你可能在 HTTP 请求中添加请求时间戳作为一个自定义 HTTP 头部。

服务器将比较当前时间戳与请求时间戳，并仅仅接受一个在其后的时间范围里（可能30秒钟）的请求。

这可以防范基本的[回放攻击](https://en.wikipedia.org/wiki/Replay_attack)，其意图不改变时间戳来[暴力破解](https://en.wikipedia.org/wiki/Brute-force_attack)你的系统。

#### 6.2.7 输入参数验证

在到达应用逻辑前的每个第一步验证请求参数，施加严格的验证，如果验证失败立即拒绝请求。

在 API 回复中，发送相关错误消息，以及正确的输入格式以提升用户体验。

## 七 版本变迁（Versioning）

为了管理复杂性，版本化你的 API。当需要的修改可以在 API 级别识别时，版本可以帮我们快速迭代。

> 随着我们对一个系统的知识和经验的增长，API 的修改是不可避免的。当它可能破坏与客户的集成时，管理这种修改带来的影响是一个巨大的挑战。

### 7.1 什么时候版本化（When to version?）

**当做出破坏性修改时，API 仅仅需要递增版本（up-versioned ）**。

破坏性修改包括：

- 一个或多个调用的回复数据格式的修改
- 请求或回复类型的修稿（例如，修改整形数到浮点数）
- 移除部分 API

**破坏性修改**应该总会导致 API 主版本的数字或者内容[回复格式](https://www.iana.org/assignments/media-types/media-types.xhtml)变化。

**非破坏性修改**，例如增加新的端点或新的回复参数，不需要修改主版本号。

> 但是，当做出修改以支持可能受到缓存版本数据或经历其它 API 问题的客户时，追踪 API 小版本的变化是很有帮助的。

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

一个自定义头（例如 `Accept-version`）允许你在不同版本之间保持你的 URI，虽然它仅仅是通过已有的接受头部（`Accept header`）来有效实现内容协商的一个副本：

```
Accept-version: v1
Accept-version: v2
```

#### 7.2.3 使用 “Accept” 头部支持版本化

[内容协商](https://restfulapi.net/content-negotiation/)可以让你保持一套干净的 URLs，但有些地方你还是不得不处理服务于不同版本内容的复杂性。

这个负担移向你的 API 控制器栈的上部，它负责指出需要向哪个版本的资源发送请求。

由于客户在请求资源之前不得不清楚知道需要指定那些头部，这个结果将导致一个更为复杂的 API。

```
Accept: application/vnd.example.v1+json
Accept: application/vnd.example+json;version=1.0
```

在真实的世界里，一个 API 不会永远保持稳定。因此如何管理修改时很重要的。

对大部分 API 一个拥有良好文档且逐步废弃（无用）API 时一个可接受的实践。

## 八 REST APIs 里的无状态（Statelessness in REST APIs）

### 8.1 无状态

根据 REST（REpresentational “**State**” Transfer） 架构，服务器并不在服务器端存储客户端会话的任何状态，这个限制叫**无状态**。

来自客户端到达服务器的每一个请求必须包含所有必须信息以理解请求。服务器并不会利用存储于服务器上的任何上下文。

**应用的会话状态应该完全存储在客户端。客户端在自己一边负责会话相关信息的存储及处理**。

这也意味着但需要时客户端将负责把任何状态信息发送到服务器端。在客户端与服务器端之间应该不存在**会话亲缘性**或**粘滞会话**（sticky session）。

> 无状态意味着每一个 HTTP 请求运行于完全隔离的状态。当客户发出一个 HTTP 请求时，它包含所有服务器端处理该请求所必需的所有信息。
>
> 服务器端永远不会依赖来自于客户端的前一个请求的信息。如果此类信息很重要，那么客户端应该将其作为当前请求的一部分发送。

为了让客户端访问这些无状态 API，对于客户端创建/维护状态的每一项信息，服务器端有必要将其包含在内。

为了变成无状态，不要存储客户端[认证/授权](https://restfulapi.net/security-essentials/)的细节。为每一个请求提供认证证件。

因此每个请求必须是独立的，而且应不被同一客户先前的请求影响。

### 8.2 应用状态 vs 资源状态

理解应用状态与资源状态之间的关系时重要的。两者时完全不同的事物。

**应用状态**是服务器端数据，它存储用于识别进来的客户端请求，它们之前的交互细节，以及当前上下文信息。

**资源状态**是在任意时间点一个资源在服务器端的当前状态--它与服务器端/客户端的交互无关。它是我们获得可用于 API 回复的东西。我们称之为资源呈现。

> REST 无状态意味着与应用状态无关。

### 8.3 无状态 API 的优势

让 REST APIs 无状态拥有如下值得注意的优势：

- 通过部署应用至多个服务器，无状态可帮助扩展 API 至百万级并发用户。由于没有会话相关的依赖，任何服务器可以处理任何请求。
- 使 REST APIs 无状态减轻了 API 复杂性--它移除了服务器端状态同步逻辑
- 无状态 API 也容易[缓存](https://restfulapi.net/caching/)。特定软件可以通过检查 HTTP 请求决定是否缓存其结果。没有不停的唠叨抱怨先前的请求的状态会影响当前请求的缓存。它提高了应用的性能。
- 由于客户端在每个请求中发送了所有的信息，服务器端永远不会失去对应用的客户端的追踪。

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
- [REST APIs must be hypertext-driven](https://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven)
- [REST Arch Style](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)
- [Roy T. Fielding on Stateless](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_3)