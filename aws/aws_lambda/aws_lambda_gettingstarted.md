# 开始使用 AWS Lambda
要开始使用 AWS Lambda，请使用 Lambda 控制台创建函数。在几分钟的时间内，您可以创建一个函数，调用它，并查看日志、指标（metrics）和跟踪数据（trace data）。
> **注意** 要使用 Lambda 和其他 AWS 服务，您需要 AWS 账户。如果您没有账户，请访问 www.amazonaws.cn，然后选择创建 AWS 账户。有关详细说明，请参阅[创建和激活 AWS 账户](http://www.amazonaws.cn/premiumsupport/knowledge-center/create-and-activate-aws-account/)。
> 
> 作为最佳实践，您还应创建一个具有管理员权限的 AWS Identity and Access Management (IAM) 用户，并在不需要根凭证的所有工作中使用该用户。创建密码以用于访问控制台，并创建访问密钥以使用命令行工具。有关说明，请参阅[ IAM 用户指南 中的创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

您可以在 Lambda 控制台中编写函数，也可以使用 IDE 工具包、命令行工具或软件开发工具包编写函数。Lambda 控制台为非编译语言提供了[代码编辑器](https://docs.amazonaws.cn/lambda/latest/dg/code-editor.html)，使您可以快速修改和测试代码。[AWS CLI](https://docs.amazonaws.cn/lambda/latest/dg/gettingstarted-awscli.html) 使您可以直接访问 Lambda API 以获取高级配置和自动化使用案例。
## 使用控制台创建 Lambda 函数
在本入门练习中，您将使用 AWS Lambda 控制台创建一个 Lambda 函数。接下来，您将使用示例事件数据手动调用 Lambda 函数。AWS Lambda 将执行 Lambda 函数并返回结果。然后，您将验证执行结果，包括您的 Lambda 函数已创建的日志和各种 CloudWatch 指标。
### 创建 Lambda 函数
1. 打开 [AWS Lambda 控制台](https://console.amazonaws.cn/lambda/home)
2. 选择 Create a function。
3. 在**函数名称**中，输入 my-function。
4. 选择 **Create function**。

Lambda 创建一个 Node.js 函数和授予该函数上传日志的权限的执行角色。在您调用函数时，Lambda 代入执行角色，并使用它为 AWS 开发工具包创建凭证和从事件源读取数据。
### 使用 Designer
**设计器**显示您的函数及其上游和下游资源的概述。您可以使用它来配置触发器、层和目标。

![console-designer](https://github.com/wbb1975/blogs/blob/master/aws/images/console-designer.png)

在 Designer 中选择 my-function 返回到函数的代码和配置。对于脚本语言，Lambda 包含返回成功响应的示例代码。只要源代码未超过 3 MB 的限制，您就可以使用嵌入式 [AWS Cloud9](https://docs.amazonaws.cn/cloud9/latest/user-guide/) 编辑器编辑函数代码。
### 调用 Lambda 函数
使用控制台中提供的示例事件数据**调用 Lambda 函数**。
1. 在右上角，选择**测试**。
2. 在 **Configure test event** 页面中，选择 **Create new test event**，并且在 **Event template** 中，保留默认的 **Hello World** 选项。输入 **Event name** 并记录以下示例事件模板：
   ```
   {
     "key3": "value3",
     "key2": "value2",
     "key1": "value1"
   }
   ```
   可以更改示例 JSON 中的键和值，但不要更改事件结构。如果您更改任何键和值，则必须相应更新示例代码。
3. 选择 **Create (创建)**，然后选择 **Test (测试)**。每个用户每个函数可以创建最多 10 个测试事件。这些测试事件不适用于其他用户。
4. AWS Lambda 代表您执行您的函数。您的 Lambda 函数中的 handler 接收并处理示例事件。
5. 成功执行后，在控制台中查看结果。
   - **Execution result** 部分将执行状态显示为 **succeeded**，还将显示由 return 语句返回的函数执行结果。
   - **Summary** 部分显示在 **Log output** 部分中报告的密钥信息（执行日志中的 REPORT 行）
   - **Log output** 部分显示 AWS Lambda 针对每次执行生成的日志。这些是由 Lambda 函数写入到 CloudWatch 的日志。为方便起见，AWS Lambda 控制台为您显示了这些日志。

   注意：**Click here** 链接在 CloudWatch 控制台中显示日志。然后，该函数在与 Lambda 函数对应的日志组中向 Amazon CloudWatch 添加日志。
6. 运行 Lambda 函数几次以收集您可在下一个步骤中查看的一些指标。
7. 选择 Monitoring。此页面显示了 Lambda 发送到 CloudWatch 的指标的图表。

   ![metrics-functions-list](https://github.com/wbb1975/blogs/blob/master/aws/images/metrics-functions-list.png)

   有关这些图表的更多信息，请参阅在 [AWS Lambda 控制台中监控函数](https://docs.amazonaws.cn/lambda/latest/dg/monitoring-functions-access-metrics.html)。
## 使用 AWS Lambda 控制台编辑器创建函数
使用 AWS Lambda 控制台中的代码编辑器，您可以编写和测试您的 Lambda 函数代码并查看其执行结果。

该代码编辑器包含菜单栏（menu bar）、窗口（windows） 和编辑器窗格（editor pane）。

![code-editor](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor.png)

有关命令可执行的操作的列表，请参阅 AWS Cloud9 用户指南 中的[菜单命令参考](https://docs.amazonaws.cn/cloud9/latest/user-guide/menu-commands.html)。请注意，该参考中列出的一些命令在代码编辑器中不可用。
### 处理文件和文件夹
您可以在代码编辑器中使用 **Environment** 窗口为您的函数创建、打开和管理文件。

![code-editor-env](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-env.png)

**要显示或隐藏“Environment”窗口**，请选择 **Environment** 按钮。如果 **Environment** 按钮不可见，请选择菜单栏上的 **Window**、**Environment**。

![code-editor-env-button](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-env-button.png)

![code-editor-env-menu](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-env-menu.png)

**要打开单个文件并在编辑器窗格中显示其内容**，请在 **Environment** 窗口中双击该文件。

**要打开多个文件并在编辑器窗格中显示其内容**，请在 **Environment** 窗口中选择这些文件。右键单击选定内容，然后选择 **Open**。

**要创建新文件**，请执行以下操作之一：
   + 在 Environment 窗口中，右键单击您希望将新文件放入的文件夹，然后选择 New File。键入文件的名称和扩展名，然后按 Enter 。
   + 在菜单栏上选择 File、New File。当您准备好保存文件时，在菜单栏上选择 File、Save 或 File、Save As。然后，使用显示的 Save As 对话框命名文件并选择保存该文件的位置。
   + 在编辑器窗格的选项卡按钮栏中，选择 + 按钮，然后选择 New File。当您准备好保存文件时，在菜单栏上选择 File、Save 或 File、Save As。然后，使用显示的 Save As 对话框命名文件并选择保存该文件的位置。

   ![code-editor-env-new](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-env-new.png)

**要创建新文件夹**，请在 **Environment** 窗口中右键单击您希望将新文件夹放入的文件夹，然后选择 **New Folder**。键入文件夹名称，然后按 **Enter**。

**要保存某个文件**，请在编辑器窗格中打开该文件并显示其内容，然后在菜单栏上选择 **File**、**Save**。

**要重命名某个文件或文件夹**，请在 **Environment**窗口中右键单击该文件或文件夹。键入替换名称，然后按 **Enter**。

**要删除文件或文件夹**，请在 **Environment** 窗口中选择文件或文件夹。右键单击选定内容，然后选择 **Delete**。然后，通过选择 **Yes** (对于单个选定项) 或 **Yes to All** 来确认删除。

**要剪切、拷贝、粘贴或复制文件或文件夹**，请在 **Environment** 窗口中选择文件或文件夹。右键单击选定内容，然后相应地选择 **Cut**、**Copy**、**Paste** 或 **Duplicate**。

**要折叠文件夹**，请选择 **Environment** 窗口中的齿轮图标，然后选择 **Collapse All Folders**。

![code-editor-env-collapse](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-env-collapse.png)

要显示已隐藏的文件，请选择 **Environment** 窗口中的齿轮图标，然后选择 **Show Hidden Files**。
### 使用代码
使用代码编辑器中的编辑器窗格可以查看和编写代码。

![code-editor-editor-pane](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-editor-pane.png)
### 在全屏模式下工作
您可以展开代码编辑器，以获得更多的空间来处理您的代码。

要将代码编辑器展开到 Web 浏览器窗口的边缘，请在菜单栏中选择 **Toggle fullscreen** 按钮。

![code-editor-menu-bar-fullscreen](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-menu-bar-fullscreen.png)

要将代码编辑器缩小到其原始大小，请再次选择 **Toggle fullscreen** 按钮。

在全屏模式下，将在菜单栏上显示额外的选项：**Save (保存)** 和 **Test (测试)**。选择 **Save** 可以保存函数代码。选择 **Test** 或 **Configure Events** 可以创建或编辑函数的测试事件。
### 使用首选项
您可以更改各种代码编辑器设置，例如显示哪些编码提示和警告，代码折叠行为，代码自动完成行为以及其他功能。

要更改代码编辑器设置，请在菜单栏中选择 Preferences 齿轮图标。

![code-editor-menu-bar-preferences](https://github.com/wbb1975/blogs/blob/master/aws/images/code-editor-menu-bar-preferences.png)

有关这些设置的作用的列表，请参阅 AWS Cloud9 用户指南中的以下参考。
+ [您可以执行的项目设置更改](https://docs.amazonaws.cn/cloud9/latest/user-guide/settings-project.html#settings-project-change)
+ [您可以执行的用户设置更改](https://docs.amazonaws.cn/cloud9/latest/user-guide/settings-user.html#settings-user-change)

请注意，这些参考中列出的一些设置在代码编辑器中不可用。
## 将 AWS Lambda 与 AWS Command Line Interface 结合使用
## AWS Lambda 概念
利用 AWS Lambda，您可以运行函数以处理事件。您可以通过使用 Lambda API 调用函数或将 AWS 服务或资源配置为调用函数来向函数发送事件。
### 功能
函数是一个资源，您可以调用它来在 AWS Lambda 中运行您的代码。一个函数具有处理事件的代码，以及在 Lambda 与函数代码之间传递请求和响应的运行时。您负责提供代码，并且可以使用提供的运行时或创建自己的运行时。

有关更多信息，请参阅[AWS Lambda 运行时](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)。
### Runtime
Lambda 运行时允许不同语言的函数在同一基本执行环境中运行。将您的函数配置为使用与您的编程语言匹配的运行时。运行时位于 Lambda 服务和函数代码之间，并在二者之间中继调用事件、上下文信息和响应。您可以使用 Lambda 提供的运行时，或构建您自己的运行时。

有关更多信息，请参阅[AWS Lambda 运行时](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)。
### Event
事件是 JSON 格式的文档，其中包含要处理的函数的数据。Lambda 运行时将事件转换为一个对象，并将该对象传递给函数代码。在调用函数时，可以确定事件的结构和内容。当 AWS 服务调用您的函数时，该服务会定义事件。

有关来自 AWS 服务的事件的详细信息，请参阅[将 AWS Lambda 与其他服务结合使用](https://docs.amazonaws.cn/lambda/latest/dg/lambda-services.html)。
### 并发
并发性是您的函数在任何给定时间所服务于的请求的数目。在调用函数时，Lambda 会预配置其实例以处理事件。当函数代码完成运行时，它会处理另一个请求。如果当仍在处理请求时再次调用函数，则预配置另一个实例，从而增加该函数的并发性。

并发性受区域级别限制的约束。您还可以配置单个函数来限制其并发性，或确保它们能够达到特定级别的并发性。有关更多信息，请参阅[管理 Lambda 函数的并发](https://docs.amazonaws.cn/lambda/latest/dg/configuration-concurrency.html)。
### Trigger
触发器是调用 Lambda 函数的资源或配置。这包括可配置为调用函数的 AWS 服务、您开发的应用程序以及事件源映射。事件源映射是 Lambda 中的一种资源，它从流或队列中读取项目并调用函数。

有关更多信息，请参阅[调用AWS Lambda 函数](https://docs.amazonaws.cn/lambda/latest/dg/lambda-invocation.html)和[将 AWS Lambda 与其他服务结合使用](https://docs.amazonaws.cn/lambda/latest/dg/lambda-services.html)。
## AWS Lambda 功能
## 与 AWS Lambda 一起使用的工具
## AWS Lambda 限制
AWS Lambda 将限制可用来运行和存储函数的计算和存储资源量。以下限制按区域应用，并且可以提高这些限制。要请求提高限制，请使用[支持中心控制台](https://console.amazonaws.cn/support/v1#/case/create?issueType=service-limit-increase)。

资源|默认限制
--|--
并发执行|1,000
函数和层存储|75 GB

有关并发以及 Lambda 如何扩展您的函数并发以响应流量的详细信息，请参阅[AWS Lambda 函数扩展](https://docs.amazonaws.cn/lambda/latest/dg/scaling.html)。

以下限制适用于函数配置、部署和执行。无法对其进行更改。

资源|限制
--|--
函数内存分配|128 MB 到 3,008 MB，以 64 MB 为增量。
函数超时|900 秒（15 分钟）
函数环境变量|4 KB
函数基于资源的策略|20 KB
函数层|5 层
函数突增并发|500 - 3000（每个区域各不相同）
调用频率（每秒请求数）|10 倍并发执行限制（同步 – 所有资源）10 倍并发执行限制（异步 – 非 AWS 资源）无限制（异步 – AWS 服务资源）
调用负载（请求和响应）|6 MB（同步）256 KB（异步）
部署程序包大小|50 MB（已压缩，可直接上传）250 MB（解压缩，包括层）3 MB（控制台编辑器）
每个 VPC 的弹性网络接口数|160
测试事件（控制台编辑器）|10
/tmp 目录存储|512 MB
文件描述符|1,024
执行进程/线程|1,024

其他服务的限制（如 AWS Identity and Access Management、Amazon CloudFront (Lambda@Edge) 和 Amazon Virtual Private Cloud）会影响您的 Lambda 函数。有关更多信息，请参阅 [AWS 服务限制](https://docs.amazonaws.cn/general/latest/gr/aws_service_limits.html)和[将 AWS Lambda 与其他服务结合使用](https://docs.amazonaws.cn/lambda/latest/dg/lambda-services.html)。

## Reference
- [开始使用 AWS Lambda](https://docs.amazonaws.cn/lambda/latest/dg/getting-started.html?shortFooter=true)