# AWS Lambda Building with Go

Go 的实施方式与其他托管式运行时系统不同。由于 Go 可编译为原生代码，因此 Lambda 将 Go 视为自定义运行时系统。建议您使用 `provided.al2`` 运行时系统将 Go 函数部署到 Lambda。

### Go 运行时系统支持

Lambda 的 `Go 1.x` 托管式运行时系统基于 `Amazon Linux AMI（AL1）`。Lambda 将继续支持 `Go 1.x` 托管式运行时系统，直到2023年12月31日结束对 Amazon Linux AMI 的维护支持。如果您使用的是 `Go 1.x` 运行时系统，则必须将函数迁移到 `provided.al2`。此迁移无需更改任何代码。唯一需要进行的更改涉及如何构建部署包以及使用哪个运行时系统来创建函数。有关更多信息，请参阅 [.zip 程序包](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/golang-package.html)和[容器映像](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/go-image.html)的部署说明。

名称|标识符|操作系统|架构|弃用（阶段 1）
----|----|----|----|----
Go 1.x|go1.x|Amazon Linux|x86_64|2023年12月31日

与 `go1.x` 相比，`provided.al2` 运行时系统具有多种优势，包括支持 `arm64` 架构（`AWS Graviton2` 处理器）、二进制文件更小以及调用时间稍快。

名称|标识符|操作系统|架构|弃用（阶段 1）
----|----|----|----|----
自定义运行时|provided.al2|Amazon Linux 2|x86_64，arm64|
自定义运行时|provided|Amazon Linux|x86_64|2023年12月31日

### 工具和库

**Lambda 为 Go 运行时提供了以下工具和库**

- [适用于 Go 的 AWS 开发工具包](https://github.com/aws/aws-sdk-go)：适用于 Go 编程语言的官方 AWS 开发工具包。
- [github.com/aws/aws-lambda-go/lambda](https://github.com/aws/aws-lambda-go/tree/master/lambda)：适用于 Go 的 Lambda 编程模型的实现。AWS Lambda 使用此程序包调用您的[处理程序](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/golang-handler.html)。
- [github.com/aws/aws-lambda-go/lambdacontext](https://github.com/aws/aws-lambda-go/tree/master/lambdacontext)：用于帮助访问[上下文对象](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/golang-context.html)中的上下文信息。
- [github.com/aws/aws-lambda-go/events](https://github.com/aws/aws-lambda-go/tree/master/events)：此库提供常见事件源集成的类型定义。
- [github.com/aws/aws-lambda-go/cmd/build-lambda-zip](https://github.com/aws/aws-lambda-go/tree/master/cmd/build-lambda-zip)：此工具可用于在 Windows 上创建 .zip 文件存档。

有关更多信息，请参阅 GitHub 上的 [aws-lambda-go](https://github.com/aws/aws-lambda-go)。

**Lambda 为 Go 运行时提供了以下示例应用程序**

Go 中的 Lambda 应用程序示例:

- [go-al2](https://github.com/aws-samples/sessions-with-aws-sam/tree/master/go-al2)：返回公有 IP 地址的 `hello world` 函数。此应用程序使用 `provided.al2` 自定义运行时系统。
- [blank-go](https://github.com/awsdocs/aws-lambda-developer-guide/tree/main/sample-apps/blank-go) – 此 Go 函数显示 Lambda 的 Go 库、日志记录、环境变量和 AWS SDK 的使用情况。此应用程序使用 `go1.x` 运行时系统。

## AWS Lambda function handler in Go

Lambda 函数处理函数 `handler` 是函数代码中处理事件的方法。当调用函数时，Lambda 运行 `handler` 方法。您的函数会一直运行，直到 `handler` 返回响应、退出或超时。

在 Go 中 Lambda 函数被编写为 Go 可执行文件。在 Lambda 函数代码中，您需要包含 `github.com/aws/aws-lambda-go/lambda` 程序包，该程序包将实现适用于 Go 的 Lambda 编程模型。此外，您需要实现 `handler` 函数代码和 一个 main() 函数。

```
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(ctx context.Context, event *MyEvent) (*string, error) {
	if event == nil {
		return nil, fmt.Errorf("received nil event")
	}
	message := fmt.Sprintf("Hello %s!", event.Name)
	return &message, nil
}

func main() {
	lambda.Start(HandleRequest)
}
```

这里是函数的示例输入：

```
{
  "name": "Jane"
}
```

请注意以下几点：

- **package main**：在 Go 中，包含 `func main()`` 的程序包必须始终名为 `main`。
- **import**：您可以使用它来包含 Lambda 函数所需的库。在此实例中，它包括：
  + **上下文**：[Go 中的 AWS Lambda上下文对象](https://docs.aws.amazon.com/lambda/latest/dg/golang-context.html)。
  + **fmt**：用于格式化您的函数返回的值的 Go [格式化](https://golang.org/pkg/fmt/)对象。
  + `github.com/aws/aws-lambda-go/lambda`：如前所述，您可以用它来实现适用于 Go 的 Lambda 编程模型。

- **func HandleRequest(ctx context.Context, name MyEvent) (string, error)**：这是您的 Lambda 处理程序签名。它是 Lambda 的主要入口点，且包括你的代码被执行时的主要逻辑。此外，包含的参数表示以下含义：
  + **ctx context.Context**：为您的 Lambda 函数调用提供运行时信息。`ctx` 是您声明的变量，用于访问通过[Go 中的 AWS Lambda上下文对象](https://docs.aws.amazon.com/lambda/latest/dg/golang-context.html)提供的信息。
  + **event \*MyEvent**：名为 `event` 的参数指向 `MyEvent`，它代表了 Lambda 函数的输入。
  + **string, error**：处理器返回两个值：第一个结果指向一个 Lambda 函数结果的字符串；第二个结果是一个 `error` 类型，当没有错误时它是 `nil`，如果有错误发生则它包含一个[标准错误](https://golang.org/pkg/builtin/#error)信息。有关自定义错误处理的更多信息，请参阅[Go 中的 AWS Lambda 函数错误](https://docs.aws.amazon.com/lambda/latest/dg/golang-exceptions.html)。
  + **return &message, nil**：返回两个值。第一个指向一条字符串消息，它是使用输入事件中的 `Name` 字段构造的欢迎消息；第二个值 `nil` 则指示函数没遇到任何错误。

- **func main()**：这是运行您的 Lambda 函数代码的入口点。该项为必填项。
  通过在 **func main(){}** 代码括号之间添加 `lambda.Start(HandleRequest)`，可以执行您的 Lambda 函数。按照 Go 语言标准，开括号即 `{` 必须直接置于 `main` 函数签名末尾。

### 命名

#### provided.al2 运行时系统

对于使用 [.zip 部署包](https://docs.aws.amazon.com/lambda/latest/dg/golang-package.html)中的 `provided.al2` 运行时系统的 Go 函数，包含函数代码的可执行文件必须命名为 `bootstrap`。对于在[容器映像](https://docs.aws.amazon.com/lambda/latest/dg/go-image.html#go-image-al2)中使用 `provided.al2`` 运行时系统的 Go 函数，可执行文件可以使用任何名称。

处理程序(handler)可以使用任何名称。要在代码中引用处理程序值，可以使用 `_HANDLER` 环境变量。

#### go1.x 运行时系统

对于使用 `go1.x` 运行时系统的 Go 函数，可执行文件和处理程序可以共享任何名称。例如，如果您将处理程序的值设置为 `Handler`，Lambda 将在 `Handler` 可执行文件中调用该 `main()` 函数。

要在 Lambda 控制台中更改函数处理程序名称，请在 `Runtime settings`（运行时设置）窗格中，选择 `Edit`（编辑）。

### 使用结构化类型的 Lambda 函数处理程序

在上述示例中，输入类型是简单的字符串。但是，您也可以将结构化事件传递到您的函数处理程序：

```
package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"What is your name?"`
	Age  int    `json:"How old are you?"`
}

type MyResponse struct {
	Message string `json:"Answer"`
}

func HandleLambdaEvent(event *MyEvent) (*MyResponse, error) {
	if event == nil {
		return nil, fmt.Errorf("received nil event")
	}
	return &MyResponse{Message: fmt.Sprintf("%s is %d years old!", event.Name, event.Age)}, nil
}

func main() {
	lambda.Start(HandleLambdaEvent)
}
```

下面是该函数的一个示例输入：

```
{
    "What is your name?": "Jim",
    "How old are you?": 33
}
```

而响应将如下所示：

```
{
    "Answer": "Jim is 33 years old!"
}
```

若要导出，事件结构中的字段名称必须大写。有关来自AWS事件源的处理事件的更多信息，请参阅 [aws-lambda-go/events](https://github.com/aws/aws-lambda-go/tree/master/events)。

### 有效处理程序签名

在 Go 中构建 Lambda 函数处理程序时，您有多个选项，但您必须遵守以下规则：

- 处理程序必须为函数。
- 处理程序可能需要 0 到 2 个参数。如果有两个参数，则第一个参数必须实现 `context.Context`。
- 处理程序可能返回 0 到 2 个参数。如果有一个返回值，则它必须实现 `error`。如果有两个返回值，则第二个值必须实现 `error`。有关实现错误处理信息的更多信息，请参阅 [Go 中的 AWS Lambda 函数错误](https://docs.aws.amazon.com/lambda/latest/dg/golang-exceptions.html)。

下面列出了有效的处理程序签名。`TIn` 和 `TOut` 表示类型与 `encoding/json` 标准库兼容。有关更多信息，请参阅 [func Unmarshal](https://golang.org/pkg/encoding/json/#Unmarshal) 以了解如何反序列化这些类型。

```
func ()
func () error
func (TIn) error
func () (TOut, error)
func (context.Context) error
func (context.Context, TIn) error
func (context.Context) (TOut, error)
func (context.Context, TIn) (TOut, error)
```

### 使用全局状态

您可以声明并修改独立于 Lambda 函数的处理程序代码的全局变量。此外，您的处理程序可能声明一个 `init` 函数，该函数在加载您的处理程序时执行。AWS Lambda 的这种行为方式与标准 Go 程序一样。您的 Lambda 函数的单个实例绝不会同时处理多个事件。

使用全局状态的 Go 函数示例：
> 代码使用了 AWS SDK for Go V2。更多信息，请参见[AWS SDK for Go V2 入门指南](https://aws.github.io/aws-sdk-go-v2/docs/getting-started/)

```
package main
 
import (
    "log"
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/s3"
    "github.com/aws/aws-sdk-go/aws"
)
 
var invokeCount = 0
var myObjects []*s3.Object
func init() {
    svc := s3.New(session.New())
    input := &s3.ListObjectsV2Input{
            Bucket: aws.String("examplebucket"),
    }
    result, _ := svc.ListObjectsV2(input)
    myObjects = result.Contents
}
 
func LambdaHandler() (int, error) {
    invokeCount = invokeCount + 1
    log.Print(myObjects)
    return invokeCount, nil
}
 
func main() {
    lambda.Start(LambdaHandler)
}
```

## 上下文

当 Lambda 运行您的函数时，它会将上下文对象传递到[处理程序](https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html)。此对象提供的方法和属性包含有关调用、函数和执行环境的信息。

Lambda 上下文库提供以下全局变量、方法和属性。

#### 全局变量

- `FunctionName` – Lambda 函数的名称。
- `FunctionVersion` – 函数的版本。
- `MemoryLimitInMB` – 为函数分配的内存量。
- `LogGroupName` – 函数的日志组。
- `LogStreamName` – 函数实例的日志流。

#### 上下文方法

- `Deadline` – 返回执行超时的日期（Unix 时间格式，以毫秒为单位）。

#### 上下文属性

- `InvokedFunctionArn` – 用于调用函数的 `Amazon Resource Name (ARN)`。表明调用者是否指定了版本号或别名。
- `AwsRequestID` – 调用请求的标识符。
- `Identity` –（移动应用程序）有关授权请求的 `Amazon Cognito` 身份的信息。
- `ClientContext` –（移动应用程序）客户端应用程序提供给 Lambda 的客户端上下文。

### 访问调用上下文信息

Lambda 函数可以访问有关其环境和调用请求的元数据。这可以在[程序包上下文](https://golang.org/pkg/context/)处访问。如果您的处理程序将 `context.Context` 作为参数包含在内，则 Lambda 会将有关您的函数的信息插入上下文的 `Value` 属性。请注意，您需要导入 `lambdacontext` 库才能访问 `context.Context` 对象的内容。

```
package main
 
import (
    "context"
    "log"
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-lambda-go/lambdacontext"
)
 
func CognitoHandler(ctx context.Context) {
    lc, _ := lambdacontext.FromContext(ctx)
    log.Print(lc.Identity.CognitoIdentityPoolID)
}
 
func main() {
    lambda.Start(CognitoHandler)
}
```

在上述示例中，`lc` 是用于使用 `context` 对象捕获的信息的变量，`log.Print(lc.Identity.CognitoIdentityPoolID)` 将输出该信息 (在本例中为 `CognitoIdentityPoolID``)。

以下示例介绍了如何使用上下文对象来监控您的 Lambda 函数完成任务所需的时间。这让您能够分析性能期望并相应地调整您的函数代码 (如果需要)。

```
package main

import (
    "context"
    "log"
    "time"
    "github.com/aws/aws-lambda-go/lambda"
)

func LongRunningHandler(ctx context.Context) (string, error) {
    deadline, _ := ctx.Deadline()
    deadline = deadline.Add(-100 * time.Millisecond)
    timeoutChannel := time.After(time.Until(deadline))

    for {

        select {
            case <- timeoutChannel:
                return "Finished before timing out.", nil

            default:
                log.Print("hello!")
                time.Sleep(50 * time.Millisecond)
        }
    }
}

func main() {
    lambda.Start(LongRunningHandler)
}
```

## 部署 .zip 文件归档

您的 AWS Lambda 函数代码由脚本或编译的程序及其依赖项组成。您可以使用部署程序包将函数代码部署到 Lambda。Lambda 支持两种类型的部署程序包：容器镜像和 .zip 文件归档。

本页将介绍如何创建 .zip 文件作为 Go 运行时系统的部署包，然后使用 .zip 文件通过 `AWS Management Console`、`AWS Command Line Interface（AWS CLI）` 和 `AWS Serverless Application Model（AWS SAM）` 将函数代码部署到 AWS Lambda。

请注意，Lambda 使用 POSIX 文件权限，因此在创建 .zip 文件归档之前，您可能需要[为部署包文件夹设置权限](https://aws.amazon.com/premiumsupport/knowledge-center/lambda-deployment-package-errors/)。

### 在 macOS 和 Linux 上创建 .zip 文件

以下步骤显示如何使用 go build 命令编译可执行文件并为 Lambda 创建 .zip 文件部署包。在编译代码之前，请确保您已从 `GitHub` 安装 lambda 程序包。此模块提供运行时系统接口的实现，用于管理 Lambda 与函数代码之间的交互。要下载此库，请运行以下命令。

```
go get github.com/aws/aws-lambda-go/lambda
```

如果您的函数使用 AWS SDK for Go，请下载标准的开发工具包模块集以及应用程序所需的任何 AWS 服务 API 客户端。要了解如何安装适用于 Go 的开发工具包，请参阅 [AWS SDK for Go V2 入门](https://aws.github.io/aws-sdk-go-v2/docs/getting-started/)。

#### 使用 provided.al2 运行时系统（推荐）

Go 的实施方式与其他托管式运行时系统不同。由于 Go 可编译为原生代码，因此 Lambda 将 Go 视为自定义运行时系统。建议您使用 `provided.al2` 运行时系统将 Go 函数部署到 Lambda。

**创建 .zip 部署包（macOS/Linux）**

1. 在包含应用程序的 `main.go` 文件的项目目录中，编译可执行文件。请注意以下几点：
   
   + 可执行文件必须命名为 `bootstrap`。有关更多信息，请参阅[命名](https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html#golang-handler-naming)。
  + 设置目标指令集架构。`provided.al2` 运行时系统支持 `arm64` 和 `x86_64`。
  + 您可以使用可选的 `lambda.norpc` 标签排除 lambda 库的远程过程调用（RPC）组件。只有在使用 Go 1.x 运行时系统时才需要 RPC 组件。排除 RPC 会减小部署包的大小。

  对于 arm64 架构：
  ```
  GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o bootstrap main.go
  ```
  对于 x86_64 架构：
  ```
  GOOS=linux GOARCH=amd64 go build -tags lambda.norpc -o bootstrap main.go
  ```
2. （可选）您可能需要使用 Linux 上的 `CGO_ENABLED=0` 编译程序包：
   ```
   GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o bootstrap -tags lambda.norpc main.go
   ```
   此命令为标准 C 库 (libc) 版本创建稳定的二进制程序包，这在 Lambda 和其他设备上可能有所不同。
3. 通过将可执行文件打包为 .zip 文件来创建部署程序包。
   ```
   zip myFunction.zip bootstrap
   ```
4. 创建函数。请注意以下几点：
   + 处理程序值必须是 `bootstrap`。有关更多信息，请参阅[命名](https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html#golang-handler-naming)。
   + 仅在使用 `arm64` 时，必须使用 `--architectures`` 选项。默认值为 `x86_64`。
  + 对于 `--role`，指定[执行角色](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/lambda-intro-execution-role.html)的 Amazon 资源名称（ARN）。
    ```
    aws lambda create-function --function-name myFunction \
    --runtime provided.al2 --handler bootstrap 
    --architectures arm64 \
    --role arn:aws:iam::111122223333:role/lambda-ex \
    --zip-file fileb://myFunction.zip
    ```

### 在 Windows 上创建 .zip 文件

以下步骤演示如何从 GitHub 下载用于 Windows 的 [build-lambda-zip](https://github.com/aws/aws-lambda-go/tree/main/cmd/build-lambda-zip) 工具、如何编译可执行文件，以及如何创建 .zip 部署包。

> 注意：如果您尚未完成此操作，则必须安装 [git](https://git-scm.com/)，然后将 git 可执行文件添加到您的 `Windows %PATH%` 环境变量。

在编译代码之前，请确保您已从 GitHub 安装 [lambda](https://github.com/aws/aws-lambda-go/tree/master/lambda) 库。要下载此库，请运行以下命令。

```
go get github.com/aws/aws-lambda-go/lambda
```

如果您的函数使用 `AWS SDK for Go`，请下载标准的开发工具包模块集以及应用程序所需的任何 AWS 服务 API 客户端。要了解如何安装适用于 Go 的开发工具包，请参阅 [AWS SDK for Go V2 入门](https://aws.github.io/aws-sdk-go-v2/docs/getting-started/)。

#### 使用 provided.al2 运行时系统（推荐）

Go 的实施方式与其他托管式运行时系统不同。由于 Go 可编译为原生代码，因此 Lambda 将 Go 视为自定义运行时系统。建议您使用 `provided.al2` 运行时系统将 Go 函数部署到 Lambda。

**创建 .zip 部署包（Windows）**

1. 从 GitHub 下载 `build-lambda-zip` 工具。
   ```
   go install github.com/aws/aws-lambda-go/cmd/build-lambda-zip@latest
   ```
2. 使用来自 `GOPATH`` 的工具创建 .zip 文件。如果您有 Go 的默认安装，则该工具通常在 `%USERPROFILE%\Go\bin` 中。否则，请导航到安装 Go 运行时的位置，然后执行以下任一操作：
   
   **cmd.exe**
   在 cmd.exe 中，根据目标[指令集架构](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/foundation-arch.html)运行以下任一命令。`provided.al2` 运行时系统支持 `arm64` 和 `x86_64`。

   您可以使用可选的 `lambda.norpc` 标签排除 [lambda 库](https://github.com/aws/aws-lambda-go/tree/master/lambda)的远程过程调用（RPC）组件。只有在使用 `Go 1.x` 运行时系统时才需要 RPC 组件。排除 RPC 会减小部署包的大小。

   **例 – 对于 x86_64 架构:**
   ```
   set GOOS=linux
   set GOARCH=amd64
   set CGO_ENABLED=0
   go build -tags lambda.norpc -o bootstrap main.go
   %USERPROFILE%\Go\bin\build-lambda-zip.exe -o myFunction.zip bootstrap
   ```

   **例 – 对于 arm64 架构**
   ```
   set GOOS=linux
   set GOARCH=arm64
   set CGO_ENABLED=0
   go build -tags lambda.norpc -o bootstrap main.go
   %USERPROFILE%\Go\bin\build-lambda-zip.exe -o myFunction.zip bootstrap
   ```

   **PowerShell**
3. 创建函数。请注意以下几点：
   + 处理程序值必须是 `bootstrap`。有关更多信息，请参阅[命名](https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html#golang-handler-naming)。
   + 仅在使用 `arm64` 时，必须使用 `--architectures`` 选项。默认值为 `x86_64`。
   + 对于 `--role`，指定[执行角色](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/lambda-intro-execution-role.html)的 Amazon 资源名称（ARN）。
    ```
    aws lambda create-function --function-name myFunction \
    --runtime provided.al2 --handler bootstrap \
    --architectures arm64 \
    --role arn:aws:iam::111122223333:role/lambda-ex \
    --zip-file fileb://myFunction.zip
    ```

### 使用 .zip 文件创建和更新 Go Lambda 函数

创建 .zip 部署包后，您可以使用它来创建新的 Lambda 函数或更新现有的 Lambda 函数。您可以使用 Lambda 控制台、`AWS Command Line Interface` 和 Lambda API 部署 .zip 程序包。您也可以使用 `AWS Serverless Application Model（AWS SAM）` 和 `AWS CloudFormation` 创建和更新 Lambda 函数。

Lambda 的 .zip 部署包的最大大小为 `250MB`（已解压缩）。请注意，此限制适用于您上传的所有文件（包括任何 Lambda 层）的组合大小。

#### 使用控制台通过 .zip 文件创建和更新函数

要创建新函数，必须先在控制台中创建该函数，然后上传您的 .zip 归档。要更新现有函数，请打开函数页面，然后按照相同的步骤添加更新的 .zip 文件。

如果您的 .zip 文件小于 `50MB`，则可以通过直接从本地计算机上传该文件来创建或更新函数。对于大于 `50MB`` 的 .zip 文件，必须首先将您的程序包上传到 Amazon S3 存储桶。有关如何使用 AWS Management Console 将文件上传到 Amazon S3 存储桶的说明，请参阅 [Amazon S3 入门](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html)。要使用 AWS CLI 上传文件，请参阅《AWS CLI 用户指南》中的[移动对象](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-move)。

> **注意** 您无法将现有容器映像函数转换为使用 .zip 归档。您必须创建新函数。

**创建新函数（控制台）**
1. 打开 Lambda 控制台的[“函数”页面](https://console.aws.amazon.com/lambda/home#/functions)，然后选择**创建函数**。
2. 选择 **Author from scratch (从头开始创作)**。
3. 在 **Basic information (基本信息)**中，执行以下操作：
   - 对于**函数名称**，输入函数的名称。
   - 对于运行时系统，根据您创建的部署包类型，选择以下选项之一：
     + 在 `Amazon Linux 2` 上提供您自己的引导程序（推荐）：选择此选项可使用 `provided.al2` 运行时系统创建函数。
     + `Go 1.x`（旧版）：此运行时系统基于 `Amazon Linux AMI（AL1）`。Lambda 将继续支持 `Go 1.x` 运行时系统，直到 2023年12月31日结束对 `Amazon Linux AMI` 的维护支持。建议您改用 `provided.al2` 运行时系统。
4. （可选）在 **Permissions（权限）**下，展开 **Change default execution role**（更改默认执行角色）。您可以创建新的执行角色，也可以使用现有角色。
5. 选择 **Create function**（创建函数）。Lambda 使用您选择的运行时系统创建基本“Hello world”函数。

**从本地计算机上传 .zip 归档（控制台）**
1. 在 Lambda 控制台的[“函数”页面](https://console.aws.amazon.com/lambda/home#/functions)中，选择要为其上传 .zip 文件的函数。
2. 选择**代码**选项卡。
3. 在**代码源**窗格中，选择从**数据源上传**。
4. 选择 **.zip 文件**。
5. 要上传 .zip 文件，请执行以下操作：
  a. 选择**上传**，然后在文件选择器中选择您的 .zip 文件。
  b. 选择 **Open**（打开）。
  c. 选择 **Save**（保存）。

**从 Amazon S3 存储桶上传 .zip 归档（控制台）**
1. 在 Lambda 控制台的[“函数”页面](https://console.aws.amazon.com/lambda/home#/functions)中，选择要为其上传 .zip 文件的函数。
2. 选择**代码**选项卡。
3. 在**代码源**窗格中，选择从**数据源上传**。
4. 选择 **Amazon S3 位置**。
5. 粘贴 .zip 文件的 Amazon S3 链接 URL，然后选择**保存**。

#### 使用 AWS CLI 通过 .zip 文件创建和更新函数

您可以使用 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 创建新函数或使用 .zip 文件更新现有函数。使用 [create-function](https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html) 和 [update-function-code](https://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html) 命令部署 .zip 程序包。如果您的 .zip 文件小于 50MB，则可以从本地生成计算机上的文件位置上传 .zip 程序包。对于较大的文件，必须从 Amazon S3 存储桶上传 .zip 程序包。有关如何使用 AWS CLI 将文件上传到 Amazon S3 存储桶的说明，请参阅《AWS CLI 用户指南》中的[移动对象](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-move)。

> **注意** 如果您使用 AWS CLI 从 Amazon S3 存储桶上传 .zip 文件，则该存储桶必须与您的函数位于同一个 AWS 区域中。

要通过 AWS CLI 使用 .zip 文件创建新函数，则必须指定以下内容：
- 函数的名称 (`--function-name`)
- 函数的运行时系统 (`--runtime`)
- 函数的[执行角色](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) (`--role`) 的 Amazon 资源名称（ARN）
- 函数代码 (`--handler`) 中处理程序方法的名称

还必须指定 .zip 文件的位置。如果 .zip 文件位于本地生成计算机上的文件夹中，请使用 `--zip-file` 选项指定文件路径，如以下示例命令所示。

```
aws lambda create-function --function-name myFunction \
--runtime provided.al2 --handler bootstrap \
--role arn:aws:iam::111122223333:role/service-role/my-lambda-role \
--zip-file fileb://myFunction.zip
```

要指定 .zip 文件在 `Amazon S3` 存储桶中的位置，请使用 `--code` 选项，如以下示例命令所示。您只需对版本控制对象使用 `S3ObjectVersion` 参数。

```
aws lambda create-function --function-name myFunction \
--runtime provided.al2 --handler bootstrap \
--role arn:aws:iam::111122223333:role/service-role/my-lambda-role \
--code S3Bucket=myBucketName,S3Key=myFileName.zip,S3ObjectVersion=myObjectVersion
```

要使用 CLI 更新现有函数，请使用 `--function-name` 参数指定函数的名称。您还必须指定要用于更新函数代码的 .zip 文件的位置。如果 .zip 文件位于本地生成计算机上的文件夹中，请使用 `--zip-file` 选项指定文件路径，如以下示例命令所示。

```
aws lambda update-function-code --function-name myFunction \
--zip-file fileb://myFunction.zip
```

要指定 .zip 文件在 Amazon S3 存储桶中的位置，请使用 `--s3-bucket` 和 `--s3-key` 选项，如以下示例命令所示。您只需对版本控制对象使用 `--s3-object-version` 参数。

```
aws lambda update-function-code --function-name myFunction \
--s3-bucket myBucketName --s3-key myFileName.zip --s3-object-version myObject Version
```

#### 使用 Lambda API 通过 .zip 文件创建和更新函数

要使用 .zip 文件归档创建和更新函数，请使用以下 API 操作：

- [CreateFunction](https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html)
- [UpdateFunctionCode](https://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionCode.html)

#### 使用 AWS SAM 通过 .zip 文件创建和更新函数

AWS Serverless Application Model（AWS SAM）是一个工具包，可帮助简化在 AWS 上构建和运行无服务器应用程序的过程。您可以在 YAML 或 JSON 模板中为应用程序定义资源，并使用 AWS SAM 命令行界面（AWS SAM CLI）构建、打包和部署应用程序。当您通过 AWS SAM 模板构建 Lambda 函数时，AWS SAM 会使用您的函数代码和您指定的任何依赖项自动创建 .zip 部署包或容器映像。要了解有关使用 AWS SAM 构建和部署 Lambda 函数的更多信息，请参阅《AWS Serverless Application Model 开发人员指南》中的 [AWS SAM 入门](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-getting-started.html)。

您可以使用 AWS SAM 创建使用现有 .zip 文件归档的 Lambda 函数。要使用 AWS SAM 创建 Lambda 函数，您可以将 .zip 文件保存在 Amazon S3 存储桶或生成计算机上的本地文件夹中。有关如何使用 AWS CLI 将文件上传到 Amazon S3 存储桶的说明，请参阅《AWS CLI 用户指南》中的[移动对象](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-move)。

在 AWS SAM 模板中，`AWS::Serverless::Function` 资源将指定 Lambda 函数。在此资源中，设置以下属性以创建使用 .zip 文件归档的函数：

- `PackageType` – 设置为 Zip
- `CodeUri` – 设置为函数代码的 Amazon S3 URI、本地文件夹的路径或 [FunctionCode](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-functioncode.html) 对象
- `Runtime` – 设置为您选择的运行时系统

使用 AWS SAM，如果 .zip 文件大于 50MB，则不需要先将其上传到 Amazon S3 存储桶。AWS SAM 可以从本地生成计算机上的某个位置上传最大允许大小为 250MB（已解压缩）的 .zip 程序包。

要了解有关在 AWS SAM 中使用 .zip 文件部署函数的更多信息，请参阅《AWS SAM 开发人员指南》中的 [AWS::Serverless::Function](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-function.html)。


**示例：使用 AWS SAM，通过 provided.al2  构建 Go 函数**
1. 创建具有以下属性的 AWS SAM 模板：
   + **BuildMethod**：为应用程序指定编译器。使用 `go1.x`。
   + **Runtime**：使用 `provided.al2`。
   + **CodeUri**：输入代码路径。
   + **Architectures**：对于 `arm64` 架构，使用 `[arm64]`。对于 `x86_64` 指令集架构，使用 `[amd64]` 或删除 `Architectures` 属性。

   **例 template.yaml**:
   ```
   AWSTemplateFormatVersion: '2010-09-09'
   Transform: 'AWS::Serverless-2016-10-31'
   Resources:
   HelloWorldFunction:
    Type: AWS::Serverless::Function
    Metadata:
      BuildMethod: go1.x
    Properties:
      CodeUri: hello-world/ # folder where your main program resides
      Handler: bootstrap
      Runtime: provided.al2
      Architectures: [arm64]
   ```
2. 使用 [sam build](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-build.html) 命令编译可执行文件。
   ```
   sam build
   ```
3. 使用 [sam deploy](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-deploy.html) 命令将函数部署到 Lambda。
   ```
   sam deploy --guided
   ```

#### 使用 AWS CloudFormation 通过 .zip 文件创建和更新函数

您可以使用 AWS CloudFormation 创建使用 .zip 文件归档的 Lambda 函数。要从 .zip 文件创建 Lambda 函数，必须先将您的文件上传到 Amazon S3 存储桶。有关如何使用 AWS CLI 将文件上传到 Amazon S3 存储桶的说明，请参阅《AWS CLI 用户指南》中的[移动对象](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-move)。

在 AWS CloudFormation 模板中，`AWS::Lambda::Function` 资源将指定 Lambda 函数。在此资源中，设置以下属性以创建使用 .zip 文件归档的函数：

- **PackageType** – 设置为 Zip
- **Code** – 在 `S3Bucket` 和 `S3Key` 字段中输入 Amazon S3 存储桶名称和 .zip 文件名。
- **Runtime** – 设置为您选择的运行时系统

AWS CloudFormation 生成的 .zip 文件不能超过 4MB。要了解有关在 AWS CloudFormation 中使用 .zip 文件部署函数的更多信息，请参阅《AWS CloudFormation 用户指南》中的 [AWS::Lambda::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html)。

### 为依赖项创建 Go 层

> **注意** 在 Go 等编译语言中将层与函数结合使用，不一定会产生与使用 Python 等解释性语言的相同效果。由于 Go 是一种编译语言，因此函数仍然需要在初始化阶段将所有共享程序集手动加载到内存中，而这可能会增加冷启动时间。我们建议您改为在编译时包含任何共享代码，以充分利用内置编译器的优化。

本部分中的说明旨在向您展示如何将依赖项包含在层中。

Lambda 会自动检测 `/opt/lib` 目录中的任何库，以及 `/opt/bin` 目录中的任何二进制文件。为确保 Lambda 正确获取层内容，请创建包含以下结构的层：
```
custom-layer.zip
└ lib
    | lib_1
    | lib_2
└ bin
    | bin_1
    | bin_2
```
打包层后，请参阅[在 Lambda 中创建和删除层](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/creating-deleting-layers.html)和[向函数添加层](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/adding-layers.html)以完成层设置。

## 部署容器镜像

## 日志记录

## 错误

## 跟踪

## 环境变量

## Reference

- [Building with Go](https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html)