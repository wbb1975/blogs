# OpenAPI
## 什么是OpenAPI
OpenAPI规范（以前叫Swagger规范）是一个针对REST APIs的API描述格式。一个OpenAPI文件让你描述你的整个API，包括：
- 可用端点 (/users) 及在每个端点上的操作 (GET /users, POST /users)
- 每个操作的输入输出参数
- 认证方法
- 联系信息，授权，使用条款以及其它信息

API规范可以以YAML或JSON书写。其格式易于学习，对机器和人可读性都好。完整的OpenAPI规范可以在GitHub上找到： [OpenAPI 3.0 Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md)。
## 什么是Swagger？
Swagger是一套围绕OpenAPI规范建立的一套开源工具，用于帮助你设计，构建，文档化即消费你的REST APIs。主要的Swagger工具包括：
- [Swagger Editor](http://editor.swagger.io/?_ga=2.76399061.1544772937.1592006284-765129994.1592006284)：一款当你撰写OpenAPI规格是可用的基于浏览器的编辑器
- [Swagger UI](https://swagger.io/swagger-ui/)：将OpenAPI规格渲染成交互式API文档
- [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)：为你的OpenAPI规格生成服务端stubs和客户端库
## 为什么使用OpenAPI
API描述自身结构的能力是OpenAPI吸引大家的根源。一旦写定，一份OpenAPI规格书和Swagger工具能以多种方式驱动你的API开发。
- 设计优先用户：使用 [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)为你的API产生服务端stubs。剩下的唯一事情就是实现你的服务逻辑-你的API很快就能成功上线。
- 使用 [Swagger Codegen](https://github.com/swagger-api/swagger-codegen)可以为你的API产生多达40种以上语言产生客户端库
- 使用[Swagger UI](https://swagger.io/swagger-ui/)：产生交互式API文档，可以让你的客户直接在浏览器中测试你的API调用
- 使用规范来将API相关的工具连接到你的API。例如，将规范导入到[SoapUI](https://soapui.org/) 来为你的API创建自动化测试。
- 还有更多！检出可与Swagger集成的[open-source]和商业工具[https://swagger.io/commercial-tools/] 。

## Reference
- [OpenAPI Homepage](https://swagger.io/)