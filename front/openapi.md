# OpenAPI
## 1. 什么是OpenAPI
OpenAPI规范（以前叫Swagger规范）是一个针对REST APIs的API描述格式。一个OpenAPI文件让你描述你的整个API，包括：
- 可用端点 (/users) 及在每个端点上的操作 (GET /users, POST /users)
- 每个操作的输入输出参数
- 认证方法
- 联系信息，授权，使用条款以及其它信息

API规范可以以YAML或JSON书写。其格式易于学习，对机器和人可读性都好。完整的OpenAPI规范可以在GitHub上找到： [OpenAPI 3.0 Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md)。
## 2. 什么是Swagger？
Swagger是一套围绕OpenAPI规范建立的一套开源工具，用于帮助你设计，构建，文档化即消费你的REST APIs。主要的Swagger工具包括：
- [Swagger Editor](http://editor.swagger.io/?_ga=2.76399061.1544772937.1592006284-765129994.1592006284)：一款当你撰写OpenAPI规格是可用的基于浏览器的编辑器
- [Swagger UI](https://swagger.io/swagger-ui/)：将OpenAPI规格渲染成交互式API文档
- [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)：为你的OpenAPI规格生成服务端stubs和客户端库
## 3. 为什么使用OpenAPI
API描述自身结构的能力是OpenAPI吸引大家的根源。一旦写定，一份OpenAPI规格书和Swagger工具能以多种方式驱动你的API开发。
- 设计优先用户：使用 [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)为你的API产生服务端stubs。剩下的唯一事情就是实现你的服务逻辑-你的API很快就能成功上线。
- 使用 [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)可以为你的API产生多达40种以上语言产生客户端库
- 使用[Swagger UI](https://swagger.io/swagger-ui/)：产生交互式API文档，可以让你的客户直接在浏览器中测试你的API调用
- 使用规范来将API相关的工具连接到你的API。例如，将规范导入到[SoapUI](https://soapui.org/) 来为你的API创建自动化测试。
- 还有更多！检出可与Swagger集成的[open-source](https://swagger.io/open-source-integrations/)和[商业工具](https://swagger.io/commercial-tools/)。
## 4. 基础结构（Basic Structure）
你可以用[YAML](https://en.wikipedia.org/wiki/YAML)和[JSON](https://en.wikipedia.org/wiki/JSON)来撰写OpenAPI定义。我们尽使用YAML来演示示例，但JSON也能很好地工作。一个OpenAPI 3.0的定义样本如下所示：
```
openapi: 3.0.0
info:
  title: Sample API
  description: Optional multiline or single-line description in [CommonMark](http://commonmark.org/help/) or HTML.
  version: 0.1.9

servers:
  - url: http://api.example.com/v1
    description: Optional server description, e.g. Main (production) server
  - url: http://staging-api.example.com
    description: Optional server description, e.g. Internal staging server for testing

paths:
  /users:
    get:
      summary: Returns a list of users.
      description: Optional extended description in CommonMark or HTML.
      responses:
        '200':    # status code
          description: A JSON array of user names
          content:
            application/json:
              schema: 
                type: array
                items: 
                  type: string
```
所有关键字名字是大小写敏感的。
### 4.1 元数据（Metadata）
每个API定义必须包含必须包含该定义基于的OpenAPI版本号。 
```
openapi: 3.0.0
```
OpenAPI版本号定义了一个API定义的总体结构--你可以文档化那些以及如何文档化它。OpenAPI 3.0.0使用[语义版本号](http://semver.org/)，包含三部分版本号。 [可用版本号](https://github.com/OAI/OpenAPI-Specification/releases)有 3.0.0, 3.0.1, 3.0.2, and 3.0.3，它们的功能都是一样的。

info段包含API信息：标题，描述（可选）及版本号。
```
info:
  title: Sample API
  description: Optional multiline or single-line description in [CommonMark](http://commonmark.org/help/) or HTML.
  version: 0.1.9
```
标题是你的API的名字，描述是关于你的API的扩展信息。它可以是[多行](http://stackoverflow.com/a/21699210)的，也支持Markdown的[CommonMark](http://commonmark.org/help/)以呈现富文本。HTML被CommonMark (参见[CommonMark 0.27 规范](http://spec.commonmark.org/0.27/)中的[HTML Blocks](http://spec.commonmark.org/0.27/))一定程度上支持。版本号是一个任意字符串指定了你的API的版本号（不要与文件版本号或OpenAPI版本号混淆）。你可以使用[语义版本号](http://semver.org/)想major.minor.patch，或一个随机字符串如1.0-beta 或 2017-07-25。info也支持其它关键字如联系信息，授权，服务条款及其它细节。

参见：[Info Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#infoObject)。 
### 4.2 服务器（Servers）
servers段指定了API服务器及其基础URL。你可以定义一个或多个服务器，例如产品和沙箱。
```
servers:
  - url: http://api.example.com/v1
    description: Optional server description, e.g. Main (production) server
  - url: http://staging-api.example.com
    description: Optional server description, e.g. Internal staging server for testing
```
所有的API路径是相对于服务器路径的。在上面的例子中，`/users`意味着`http://api.example.com/v1/users` 或者`http://staging-api.example.com/users`，取决于使用的服务器。更多信息，参见[API服务器与基础路径](https://swagger.io/docs/specification/api-host-and-base-path/)。
### 4.3 路径（Paths）
paths段定义了你的API的单独端点（路径），以及这些端点支持的HTTP方法（可选）。例如，GET /users可被描述为：
```
paths:
  /users:
    get:
      summary: Returns a list of users.
      description: Optional extended description in CommonMark or HTML
      responses:
        '200':
          description: A JSON array of user names
          content:
            application/json:
              schema: 
                type: array
                items: 
                  type: string
```
一个操作定义包含参数，请求提（如果有），可能得回复状态代码（比如200 OK及404没有找到等）及回复内容。更多信息，参见[路径与操作](https://swagger.io/docs/specification/paths-and-operations/)。 
### 4.4 参数（Parameters）
操作可以含有经由URL 路径 (/users/{userId}), 查询字符串 (/users?role=admin), HTTP头 (X-CustomHeader: Value) 或 cookies (Cookie: debug=0)等传递的参数。你可以定义参数数据类型，格式，它们是必须还是可选的，以及其它细节。
```
paths:
  /user/{userId}:
    get:
      summary: Returns a user by ID.
      parameters:
        - name: userId
          in: path
          required: true
          description: Parameter description in CommonMark or HTML.
          schema:
            type : integer
            format: int64
            minimum: 1
      responses: 
        '200':
          description: OK
```
更多信息，参见[描述参数](https://swagger.io/docs/specification/describing-parameters/)。
### 4.5 请求体（Request Body）
如果一个操作发送了一个请求体，使用**requestBody**关键字来描述请求体内容和媒体类型。 
```
paths:
  /users:
    post:
      summary: Creates a user.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                username:
                  type: string
      responses: 
        '201':
          description: Created
```
更多信息，请参见[描述请求体](https://swagger.io/docs/specification/describing-request-body/)。
### 4.6 回复（Responses）
对每个操作，你可以定义可能的状态码，比如200 OK or 404 Not Found，以及回复体schema。Schemas可被内联定义，或通过[$ref](https://swagger.io/docs/specification/using-ref/)引用。你可以为不同的内容类型提供示例回复。
```
paths:
  /user/{userId}:
    get:
      summary: Returns a user by ID.
      parameters:
        - name: userId
          in: path
          required: true
          description: The ID of the user to return.
          schema:
            type: integer
            format: int64
            minimum: 1
      responses:
        '200':
          description: A user object.
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: integer
                    format: int64
                    example: 4
                  name:
                    type: string
                    example: Jessica Smith
        '400':
          description: The specified user ID is invalid (not a number).
        '404':
          description: A user with the specified ID was not found.
        default:
          description: Unexpected error
```
注意回复HTTP状态码必须用引号包裹："200" (OpenAPI 2.0 不要求这样)。跟多信息，参见[描述回复](https://swagger.io/docs/specification/describing-responses/)。 
### 4.7 输入和输出模型（Input and Output Models）
全局components/schemas段让你定义你的API中使用的公共数据结构。它们可被通过$ref引用，无论如何一个schema是必须的--在参数中，请求体中，回复体中。例如，这个JSON对象：
```
{
  "id": 4,
  "name": "Arthur Dent"
}
```
可被如下方式呈现：
```
components:
  schemas:
    User:
      properties:
        id:
          type: integer
        name:
          type: string
      # Both properties are required
      required:  
        - id
        - name
```
然后在请求体及回复体schema中被引用：
```
paths:
  /users/{userId}:
    get:
      summary: Returns a user by ID.
      parameters:
        - in: path
          name: userId
          required: true
          type: integer
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
  /users:
    post:
      summary: Creates a new user.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      responses:
        '201':
          description: Created
```
### 4.8 认证（Authentication）
securitySchemes和security用于描述你的API中用到的认证方法。
```
components:
  securitySchemes:
    BasicAuth:
      type: http
      scheme: basic

security:
  - BasicAuth: []
```
支持的认证方法包括：
- HTTP 认证: [Basic](https://swagger.io/docs/specification/authentication/basic-authentication/), [Bearer](https://swagger.io/docs/specification/authentication/bearer-authentication/)等
- [API key](https://swagger.io/docs/specification/authentication/api-keys/)：作为一个请求头，或查询字符串，或在Cookies中
- [OAuth 2](https://swagger.io/docs/specification/authentication/oauth2/)
- [OpenID Connect Discovery](https://swagger.io/docs/specification/authentication/openid-connect-discovery/)
更多信息，请参见[认证](https://swagger.io/docs/specification/authentication/)。 
### 4.9 完整规范（Full Specification）
OpenAPI 3.0的完整规范在[GitHub](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md)上可见。
## 5. 认证
### 5.1 基础认证
### 5.2 API Key
有些API使用API keys进行认证。一个API key是调用API时客户端提供的一个令牌。它可以以查询字符串的形式提供：
```
GET /something?api_key=abcdef12345
```
或者在一个请求头里：
```
GET /something HTTP/1.1
X-API-Key: abcdef12345
```
或者是一个Cookie：
```
GET /something HTTP/1.1
Cookie: X-API-KEY=abcdef12345
```
API keys假设是机密的，只有客户端和服务器端知晓它。像基础认证，基于API keys的认证只有当与其它安全设施如HTTPS/SSL一起使用时才被人为是安全的。
#### 5.2.1 描述API Keys
在OpenAPI 3.0中，API keys被描述如下：
```
openapi: 3.0.0
...

# 1) Define the key name and location
components:
  securitySchemes:
    ApiKeyAuth:        # arbitrary name for the security scheme
      type: apiKey
      in: header       # can be "header", "query" or "cookie"
      name: X-API-KEY  # name of the header, query parameter or cookie

# 2) Apply the API key globally to all operations
security:
  - ApiKeyAuth: []     # use the same name as under securitySchemes
```
这个实例定义了一个名为X-API-Key的API key，在请求头中发送 X-API-Key: <key>。对于security scheme，键ApiKeyAuth只是一个随机字符串（不要与name键指定的API key名字混淆）。名字ApiKeyAuth在security段中再次使用，用于将该security scheme 应用于API。注意：仅仅securitySchemes是不够的；你必须同时使用security以使API key生效。security也可在操作级别设置而非全局设置。这在仅仅一部分操作需要API key是有用的。
```
paths:
  /something:
    get:
      # Operation-specific security:
      security:
        - ApiKeyAuth: []
      responses:
        '200':
          description: OK (successfully authenticated)
```
注意在一个API中支持多种认证类型是可能的，参见[支持多种认证](https://swagger.io/docs/specification/authentication/#multiple)。
#### 5.2.2 多个API Keys
某些API使用一堆API keys，比如， API Key 和 App ID。为了指定一起使用的keys（成为逻辑与）将位于同一数组中的元素放进security数组中：
```
components:
  securitySchemes:
    apiKey:
      type: apiKey
      in: header
      name: X-API-KEY
    appId:
      type: apiKey
      in: header
      name: X-APP-ID

security:
  - apiKey: []
    appId:  []   # <-- no leading dash (-)
```
注意下面的不同形式：
```
security:
  - apiKey: []
  - appId:  []
```
这意味着每一个key都可使用（逻辑或），更多信息，参见[支持多种认证](https://swagger.io/docs/specification/authentication/#multiple)。
#### 5.2.3 401 回复
当收到缺少API key或无效API key的请求时你可以定义401 “Unauthorized”回复。这个回复包含WWW-Authenticate头--你应该想提到它。和其它公共回复一样，你可以在全局components/responses段中定义401回复，并在其它地方利用$ref来引用它。
```
paths:
  /something:
    get:
      ...
      responses:
        ...
        '401':
           $ref: "#/components/responses/UnauthorizedError"
    post:
      ...
      responses:
        ...
        '401':
          $ref: "#/components/responses/UnauthorizedError"

components:
  responses:
    UnauthorizedError:
      description: API key is missing or invalid
      headers:
        WWW_Authenticate:
          schema:
            type: string
```
了解更多描述回复的细节，请参阅[描述回复](https://swagger.io/docs/specification/describing-responses/)。 
### 5.3 Bearer认证
### 5.4 OAuth 2.0
[OAuth 2.0](https://oauth.net/2/)是一个授权协议，它给予一个API客户对一个Web服务器上的用户数据的有限访问。GitHub, Google, 和 Facebook APIs都使用了它。OAuth依赖于一个叫做流的认证场景，它允许资源所有者（用户）分享资源服务器上的受保护内容，而不用分享其证书。基于那个目的，一个OAuth 2.0服务器会发放访问令牌，借助它一个客户端应用可以代表资源所有者访问受保护资源。关于OAuth 2.0的更多信息，参见[oauth.net](https://oauth.net/2) 和 [RFC 6749](https://tools.ietf.org/html/rfc6749)。
#### 5.4.1 流（Flows）
流（也叫作授权类型）是客户端执行的一系列场景用于从授权服务器上拿到访问令牌。OAuth 2.0提供了几种流适用于不同的API客户端类型。
- 授权码（Authorization code ）：应用最广的流，主要用于服务端及移动Web应用。这个流和用户如何利用他们的Facebook，Google账号登录到一个Web应用很相似。
- 隐含（Implicit）：该流要求客户直接直接查询访问令牌。这在下面这些情况下有用，如用户的证书不能被存放在客户端代码中，因为这很容易被第三方访问到。它适用于没有服务端组件的web，桌面及移动应用。
- 资源所有者密码证书（Resource owner password credentials）：要求以用户名和密码登录。因为在那种情况下证书将会是请求的一部分。这个流仅仅对信任的客户适用（例如，由API提供商发布的正式应用）。
- 客户端证书（Client Credentials）：用于服务端-服务端认证。这个流描述了这样一种方式：客户端应用代表它自己而非一个个单独的用户。在大多数场景下，这个流提供了一种方式让用户在客户端应用中指定他们的证书，因此他能访问客户端的控制下的资源。
#### 5.4.2 用OpenAPI描述OAuth 2.0
为了描述一个由OAuth 2.0保护的API，首先，在全局components/securitySchemes 段用type: oauth2添加一个security scheme。然后添加security键来应用于全局security或单个操作。
```
# Step 1 - define the security scheme
components:
  securitySchemes:
    oAuthSample:    # <---- arbitrary name
      type: oauth2
      description: This API uses OAuth 2 with the implicit grant flow. [More info](https://api.example.com/docs/auth)
      flows:
        implicit:   # <---- OAuth flow(authorizationCode, implicit, password or clientCredentials)
          authorizationUrl: https://api.example.com/oauth2/authorize
          scopes:
            read_pets: read your pets
            write_pets: modify pets in your account

# Step 2 - apply security globally...
security: 
  - oAuthSample: 
    - write_pets
    - read_pets

# ... or to individual operations
paths:
  /pets:
    patch:
      summary: Add a new pet
      security: 
        - oAuthSample: 
          - write_pets
          - read_pets
      ...
```
flows关键字指定了一个或多个这个OAuth 2.0 scheme支持的命名流。流名字可以为：
+ 授权码 – 认证码流(在OpenAPI 2.0成为访问码)
+ 隐含 – 隐含流
+ 密码 – 资源所有者密码流
+ 客户端证书 – 客户端证书流 (OpenAPI 2.0中称之为应用)

flows关键字可以指定多个流，但每个类型只能一个。每个流包涵下面的信息：
字段名|描述|授权码|隐含|密码|客户端证书
--------|--------|--------|--------|--------|--------
authorizationUrl|该流使用的授权URL，可以是基于[API服务器URL](https://swagger.io/docs/specification/api-host-and-base-path/)的相对路径|+|+|-|-
tokenUrl|该流使用的令牌URL，可以是基于API服务器URL的相对路径|+|-|+|+
refreshUrl|可选。用于获取更新令牌的URL。可以是基于API服务器URL的相对路径|+|+|+|+
[范围](https://swagger.io/docs/specification/authentication/oauth2/#scopes-extra)|该OAuth2 security scheme的适用范围。一个范围名及其对应描述的映射|+|+|+|+
### 5.5 OpenID连接发现（OpenID Connect Discovery）
[OpenID Connect (OIDC)](http://openid.net/connect/)是建立于[OAuth 2.0](https://swagger.io/docs/specification/authentication/oauth2/)之上的实体层，被一些OAuth 2.0提供商支持，例如Google and Azure活动目录。它定义了一个登录流，允许一个客户应用认证一个用户，得到（或宣称）这个用户的信息，例如用户名，密码等。用户实体信息用JWT（JSON Web Toekn）编码，被称为ID Token。OpenID连接定义了一套发现机制，称为[OpenID连接发现](https://openid.net/specs/openid-connect-discovery-1_0.html)，这里一个OpenID服务器以一个众所周知的URL的形式发布它的元信息，典型地：
```
https://server.com/.well-known/openid-configuration
```
这个URL返回JSON列表包括OpenID/OAuth端点，支持范围及申明，公共键用于签名令牌，以及其它细节。客户端使用这些信息来向OpenID服务器构造一个请求，字段名及其值在[OpenID连接发现规范](https://openid.net/specs/openid-connect-discovery-1_0.html)中定义，下面是返回的示例数据：
```
{
  "issuer": "https://example.com/",
  "authorization_endpoint": "https://example.com/authorize",
  "token_endpoint": "https://example.com/token",
  "userinfo_endpoint": "https://example.com/userinfo",
  "jwks_uri": "https://example.com/.well-known/jwks.json",
  "scopes_supported": [
    "pets_read",
    "pets_write",
    "admin"
  ],
  "response_types_supported": [
    "code",
    "id_token",
    "token id_token"
  ],
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic"
  ],
  ...
}
```
#### 5.5.1 描述OpenID连接发现
OpenAPI 3.0让你以下面的方式描述OpenID连接发现：
```
openapi: 3.0.0
...

# 1) Define the security scheme type and attributes
components:
  securitySchemes:
    openId:   # <--- Arbitrary name for the security scheme. Used to refer to it from elsewhere.
      type: openIdConnect
      openIdConnectUrl: https://example.com/.well-known/openid-configuration

# 2) Apply security globally to all operations
security:
  - openId:   # <--- Use the same name as specified in securitySchemes
      - pets_read
      - pets_write
      - admin
```
第一段components/securitySchemes，定义了security scheme类型(openIdConnect)及发现端点URL(openIdConnectUrl)。不像OAuth 2.0，你不需要在securitySchemes中列出可用的范围--客户期待从发现端点中得到它们。security段接下来选中security scheme应用于你的API。API调用实际所需范围需要在此被列出。这可能是发现端点返回的范围的一个子集。如果不同的API操作需要不同的范围，你可以在操作级别而非全局级别应用security。对每个操作你可以列出相关范围如下：
```
paths:
  /pets/{petId}:
    get:
      summary: Get a pet by ID
      security:
        - openId:
          - pets_read
      ...

    delete:
      summary: Delete a pet by ID
      security:
        - openId:
          - pets_write
      ...
```
#### 5.5.2 相对发现URL
openIdConnectUrl可被基于[服务器URL](https://swagger.io/docs/specification/api-host-and-base-path/)的相对路径指定，如下所示：
```
servers:
  - url: https://api.example.com/v2

components:
  securitySchemes:
    openId:
      type: openIdConnect
      openIdConnectUrl: /.well-known/openid-configuration
```
相对路径根据[RFC 3986](https://tools.ietf.org/html/rfc3986#section-4.2)解析。在上例中，它将被解析为https://api.example.com/.well-known/openid-configuration。
#### 5.5.3 Swagger UI
OIDC当前不被Swagger Editor和Swagger UI支持，请遵循[这个问题](https://github.com/swagger-api/swagger-ui/issues/3517)来获取更新。 
### 5.6 Cookie认证

## Reference
- [OpenAPI Homepage](https://swagger.io/)
- [OpenAPI Specification](https://swagger.io/docs/specification/about/)
