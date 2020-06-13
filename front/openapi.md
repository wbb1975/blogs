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

## Reference
- [OpenAPI Homepage](https://swagger.io/)