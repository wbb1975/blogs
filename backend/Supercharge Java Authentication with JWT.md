# Supercharge Java Authentication with JSON Web Tokens (JWTs)
正在构建Java 应用的安全认证或者正在为此缠斗？不确信使用令牌（尤其是JSON Web Token）的好处，以及它们应该如何部署？在本教程里，我将回答这些问题甚至更多。

在我们深入JSON Web Tokens ([JWTs](https://en.wikipedia.org/wiki/JSON_Web_Token)) 以及 [JJWT library](https://github.com/jwtk/jjwt) (由Stormpath's CTO， Les Hazlewood创建，由社区贡献者维护)之前，让我们先聊点基础性的东西。
## 1. Authentication vs. Token Authentication
应用用来确认用户身份的协议集即为认证。应用拥有传统上通过`session cookies`保存的持久化身份，这个模式依赖于session id的服务端存储，这个需求强迫开发者创建唯一的或者特定服务器的会话存储，或者实现一个完全分离的会话存储层。

令牌认证（Token authentication）被用来解决会话ID没有或者不能解决的问题。就像传统的认证方案，用户呈递可验证凭据，但现在是被发送一系列令牌而非会话ID。最初的凭据可能是用户名/密码，API keys，甚至来自另一个服务的令牌（Stormpath 的API Key认证功能是此方案的一个例子）。
### 1.1. Why Tokens?
非常简单，使用令牌代替会话ID可以降低服务端负载，流水线化权限管理，并且提供更好的工具以支持分布式或云基础设施。至于JWT，主要基于这类令牌（稍后将详述）无状态的本质特性来达成目的。

令牌提供了广泛的应用，包括：跨站点请求伪造保护([CSRF](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)) 模式，[OAuth 2.0](https://tools.ietf.org/html/rfc6749) 交互，会话ID，以及（如cookies）作为认证呈现。在大多数情况下，标准并不为令牌指定一个特殊的格式。下面是一个典型的HTML格式的[Spring Security CSRF token](https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/web/csrf/CsrfToken.html)。
```
<input name="_csrf" type="hidden" 
  value="f3f42ea9-3104-4d13-84c0-7bcb68202f16"/>
```
如果你试着不带正确的 CSRF 令牌来提交表单，你将得到一个错误回复。这就是令牌的作用。上面的例子是一个哑巴令牌，这意味着并不能从令牌本身收集到什么内在含义。这也是 JWTs 有很大不同所在。
## 2. What's in a JWT?
JWTs (念作 “jots”) 是地址安全的，编码的，加密签名（有时候加密的）的字符串，在很多应用场景下可用作令牌。
```
<input name="_csrf" type="hidden" 
  value="eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJlNjc4ZjIzMzQ3ZTM0MTBkYjdlNjg3Njc4MjNiMmQ3MCIsImlhdCI6MTQ2NjYzMzMxNywibmJmIjoxNDY2NjMzMzE3LCJleHAiOjE0NjY2MzY5MTd9.rgx_o8VQGuDa2AqCHSgVOD5G68Ld_YYM7N7THmvLIKc"/>
```
在这个例子中，你会看到令牌比上一个例子中的长的多。正如之前我们看到的，如果表单不带令牌提交，将会得到一个错误回复。

那么，为什么是 JWT？

上面的令牌是加密签名过的，所以可以被验证，从而证明其未被篡改。JWTs同时和许多附加信息一起被编码。

让我们来解剖 JWT，从而理解这种结构的好处。你可能注意到JWT包含被`.`分割的三个单独的部分。
Section|Content
--------|--------
Header|eyJhbGciOiJIUzI1NiJ9
Payload|eyJqdGkiOiJlNjc4ZjIzMzQ3ZTM0MTBkYjdlNjg3Njc4MjNiMmQ3MCIsImlhdCI6MTQ2NjYzMzMxNywibmJmIjoxNDY2NjMzMzE3LCJleHAiOjE0NjY2MzY5MTd9
Signature|rgx_o8VQGuDa2AqCHSgVOD5G68Ld_YYM7N7THmvLIKc

每一部分以 [base64](https://en.wikipedia.org/wiki/Base64) URL编码。这确保了它可以在一个URL中安全地使用，让我们来近距离了解每个部分。
### 2.1. 头部
如果你用Base64解码头部，你将会得到像下面的 JSON 字符串：
```
{"alg":"HS256"}
```
这意味着JWT使用[SHA-256](https://en.wikipedia.org/wiki/SHA-2)算法做[HMAC](https://en.wikipedia.org/wiki/Hash-based_message_authentication_code)签名的。
### 2.2. 载荷
如果你用Base64解码载荷，你将会得到像下面的 JSON 字符串（为了清晰做了格式化）：
```
{
  "jti": "e678f23347e3410db7e68767823b2d70",
  "iat": 1466633317,
  "nbf": 1466633317,
  "exp": 1466636917
}
```
正如你已经看到的，在载荷里有许多键值对。这些键被称为“声称”（claims），JWT 规范提供了7个注册的声称如下：
Claim|Explanation
-------|--------
iss|发布者
sub|标题
aud|受众
exp|过期时间
nbf|不在此之前
iat|发布时间
jti|JWT ID

在构建 JWT时，你可以添加任何自定义声称。上面的列表仅仅代表保留使用的声称及其类型。我们的 CSRF 拥有一个 JWT ID，一个发布时间，一个“不在此之前”时间，一个过期时间。过期时间仅仅是发布时间之后一分钟。
### 2.3. 签名
最后，签名部分是把头部与载荷用`.`拼接，然后和一个已知密钥一起传给一个特定算法（在这个例子中，使用SHA-256的HMAC算法）。注意密钥总是一个字节数组，并应该确保一个算法使用合适的长度。下面，我使用一个随机base64 编码字符串转化为字节数组，就像下面的伪代码：
```
computeHMACSHA256(
    header + "." + payload, 
    base64DecodeToByteArray("4pE8z3PBoHjnV1AhvGk+e8h2p+ShZpOnpr8cwHmMh1w=")
)
```
只要你知道这个密钥，你可以自己产生签名，并将你的计算结果与JWT中签名不分比较一验证它是否被篡改过。技术上，一个已被密钥签名的令牌被称为一个[JWS](https://tools.ietf.org/html/rfc7515)。JWTs 也可以被加密，然后被称为[JWE](https://tools.ietf.org/html/rfc7516)（在实际实践中，JWT 常用于描述 JWEs 和 JWSs）。

这将我们带回了使用JWT作为 CSRF 令牌的好处的讨论。我们可以验证签名，我们可以使用 JWT 携带的信息来验证它的有效性。因此，JWT 的字符串形式需要完全匹配服务端存储，我们还可以检视其过期时间从而保存令牌不过期。这可以将服务器从维护这些状态的符合中解放开来。

好的，我们已经讲了好多背景，下面我们来看看代码。
## 3. Setup the JJWT Tutorial
## 4. Building JWTs With JJWT
## 5. Parsing JWTs With JJWT
## 6. JWTs in Practice: Spring Security CSRF Tokens
## 7. JJWT Extended Features
## 8. Token Tools for Java Devs
## 9. JWT This Down!

## Reference
- [Supercharge Java Authentication with JSON Web Tokens (JWTs)](https://www.baeldung.com/java-json-web-tokens-jjwt)
- [Using JWT with Spring Security OAuth](https://www.baeldung.com/spring-security-oauth-jwt)
- [Spring REST API + OAuth2 + Angular](https://www.baeldung.com/rest-api-spring-oauth2-angular)
- [OAuth2 for a Spring REST API – Handle the Refresh Token in Angular](https://www.baeldung.com/spring-security-oauth2-refresh-token-angular)