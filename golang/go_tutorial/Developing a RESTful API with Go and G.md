# Developing a RESTful API with Go and Gin

这个教程介绍了使用 Go 和 [Gin Web Framework](https://gin-gonic.com/docs/) (Gin) 编写 `RESTful WebService API` 的基础知识。

如果你对 Go 及其工具有基本了解，那么本教程大部分内容你可以轻松通过。如果你是第一次接触 Go，请访问 [Tutorial: Get started with Go](https://go.dev/doc/tutorial/getting-started.html) 以获得一个快速介绍。

Gin 简化了许多构建 Web 应用及 Web 服务的编码任务，你将使用 Gin 来路由请求，获取请求细节以及为回复 `marshal json`.

在这个教程里，你将构建一个带两个端点的 `RESTful API server`，你的示例项目将是一个关于 `vintage` 爵士乐记录的数据仓库。

本教程包括以下几个章节：

1. 设计 API 端点
2. 为你的代码创建目录
3. 创建数据
4. 编写处理器以返回所有项目
5. 编写处理器以增加新项目
6. 编写处理器以返回特定项目

> 注意：其它教程，请参见[教程主页](https://go.dev/doc/tutorial/index.html)

点击下面的按钮，你就可以以交互式的方式在 [Google Cloud Shell](https://ide.cloud.google.com/?cloudshell_workspace=~&walkthrough_tutorial_url=https://raw.githubusercontent.com/golang/tour/master/tutorial/web-service-gin.md) 中完成这个教程。

## 0. 前提条件

- **一个 Go 1.16 或更新版本的安装**：关于安装指令，请参见[安装 Go](https://go.dev/doc/install)。
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。
- **curl 工具**：在 Linux 和 Mac 上它已经被安装好了。在 Windows 上，`Windows 10 Insider build 17063` 及其更新版本也已经安装了它。对于之前的 Windows 版本，你可能需要安装它。更多细节，请参考 [Tar and Curl Come to Windows](https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20171219-tar-and-curl-come-to-windows)。

## 1. 设计 API 端点

你将构建一个 API，它提供对一个存储关于 `vinyl` 的 `vintage recordings` 仓库的访问。因此，你需要提供访问端点--通过它客户可以获取以及添加唱片。

在开发一个 API 时，典型地你会从设计端点开始。如果端点容易理解，你的 API 用户将会更有成功感。

这里是你在本教程将要创建的两个端点：
- /albums

  + GET – 获取所有唱片的列表，以 JSON 格式返回。
  + POST – 添加一个新的唱片，请求数据格式也是 JSON。

- /albums/:id
  + GET – 以 ID 获取一个唱片，以 JSON 格式返回唱片数据。

接下来，我们将为你的代码创建目录。

## 2. 为你的代码创建目录

作为开始，为你即将编写的代码创建一个项目。

1. 打开命令行终端并切换到你的主目录：

   在 Linux 或 Mac:
   ```
   cd
   ```

   在 Windows:
   ```
   C:\> cd %HOMEPATH%
   ```

   教程剩余部分的提示符将显示为 `$`，你使用的命令也可作用于 `Windows`。

2. 从命令行提示符，为你的代码创建一个 `web-service-gin` 目录

   ```
   $ mkdir web-service-gin
   $ cd web-service-gin
   ```

3. 创建一个模块，你将在其中管理本教程中添加的依赖。

   运行 `go mod init` 命令，并传递你的新代码的模块路径。

   ```
   $ go mod init example/web-service-gin
   go: creating new go.mod: module example/web-service-gin
   ```

   这个命令创建了一个 `go.mod` 文件，其中你所添加的依赖被列出以便追踪。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

   > 注意：在实际开发中，你可以根据你的需求指定一个更特殊的模块路径。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

接下来，你将设计处理数据的数据结构。

## 3. 创建数据

为了保持教程里内容简单，你会将数据存储在内存里。一个更典型的 API 将会与数据库交互。

注意在内存里存储数据意味着每次你停止服务器数据集将会丢失，每次重新启动它服务时需要重新创建。

### 3.1 编写代码

1. 使用你的文本编辑器，在 `web-service` 目录下创建名为 `main.go` 的 Go 文件。你将在这个文件里编写你的 Go 代码。
2. 在 `main.go` 中，在文件顶部，粘贴进下面的包声明。

   ```
   package main
   ```

   一个独立应用（与库相反）总是在包 `main` 里。
3. 在包声明之下，粘贴进下面的 `album` 结构体定义。你将使用它来在内存里存储唱片数据。

    结构体标签如 `json:"artist"` 指定了当结构体内容被序列化成 JSON 字段名字应该是什么。没有它们，JSON 将会使用结构体的大写字段名字--这不是一个常见的 JSON 风格。

    ```
    // album represents data about a record album.
    type album struct {
        ID     string  `json:"id"`
        Title  string  `json:"title"`
        Artist string  `json:"artist"`
        Price  float64 `json:"price"`
    }
    ```
4. 在你刚添加的结构体声明之下，声明下面的 `album` 结构体切片以容纳你将使用的数据。

   ```
   // albums slice to seed record album data.
   var albums = []album{
       {ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
       {ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
       {ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
   }
   ```

接下来，你将编写代码来实现你的第一个端点。

## 4. 编写处理器以返回所有项目

当客户向 `GET /albums` 触发一个查询时，你想以 JSON 格式返回所有数据。

为了实现这个目标，你需要编写下面的代码：

- 准备一个回复的逻辑
- 将请求路径映射至你的逻辑的代码

注意这与它们在运行时执行顺序相反，但你是先添加依赖，再添加实际代码。

### 4.1 编写代码

1. 在上一节你添加的结构体定义之下，粘贴下面的代码以获取唱片列表。

   `getAlbums` 函数从 `album` 结构体切片创建 JSON，并将 JSON 写入回复。

   ```
   // getAlbums responds with the list of all albums as JSON.
   func getAlbums(c *gin.Context) {
       c.IndentedJSON(http.StatusOK, albums)
   }
   ```

   在这段代码中，你：
   + 编写一个需要一个 [gin.Context](https://pkg.go.dev/github.com/gin-gonic/gin#Context) 参数的函数 `getAlbums`。注意你可能给这个函数任意名字，`Gin` 和 `Go` 都不需要对函数名字格式有特殊需求。

     `gin.Context` 是 `Gin` 中最重要的部分。它携带有请求细节，验证并序列化 JSON 以及更多。（尽管名字相同，但它不同于 Go 的内建 [context](https://go.dev/pkg/context/) 包）。
   + 调用 [Context.IndentedJSON](https://pkg.go.dev/github.com/gin-gonic/gin#Context.IndentedJSON) 来将该结构体序列化成 JSON 并将其加入回复。

     函数的第一个参数是你想发送给客户的 HTTP 状态码。这里，你传递从 `net/http` 包的 [StatusOK](https://pkg.go.dev/net/http#StatusOK) 常量以指示 `200 OK`。

     注意你可以从用 [Context.JSON](https://pkg.go.dev/github.com/gin-gonic/gin#Context.JSON) 替换 `Context.IndentedJSON` 以发送一个更紧凑的 JSON。实际中，调试时缩进格式更易于工作，并且两者大小差别不大。

2. 在靠近 `main.go` 顶部，`albums` 切片声明之下，粘贴下面的代码以将处理器函数指派给一个端点路径。

　　这设定了 `getAlbums` 处理器和 `/albums` 端点路径之间的关联。

　　在这段代码中，你：
    + 使用 [Default](https://pkg.go.dev/github.com/gin-gonic/gin#Default) 函数初始化了一个 Gin 路由器。
    + 使用 [GET](https://pkg.go.dev/github.com/gin-gonic/gin#RouterGroup.GET) 函数来将 `GET HTTP` 方法和 `/albums` 路径与处理器函数关联起来。

    ```
    func main() {
       router := gin.Default()
       router.GET("/albums", getAlbums)

       router.Run("localhost:8080")
    }
    ```

    注意你传递了 `getAlbums` 函数的名字。这与传递该函数调用的结果，即 `getAlbums()`（注意括号）截然不同。
    + 使用 [Run](https://pkg.go.dev/github.com/gin-gonic/gin#Engine.Run) 函数将这个 Gin 路由器附在 `http.Server` 上并启动该服务器。

3. 在靠近 `main.go` 顶部，包声明之下，导入你刚编写的代码所需要的包。

    前面几行代码看起来应该像这样：

    ```
    package main

    import (
        "net/http"

        "github.com/gin-gonic/gin"
    )
    ```

4. 保存 `main.go`。

### 4.2 运行代码

1. 开始追踪作为一个依赖的 `Gin` 模块。
   
   使用  [go get](https://go.dev/cmd/go/#hdr-Add_dependencies_to_current_module_and_install_them) 来为你的模块添加 `github.com/gin-gonic/gin` 依赖。使用点号作为参数，这意味着“为当前目录里的代码获取依赖”。

   ```
   $ go get .
   go get: added github.com/gin-gonic/gin v1.7.2
   ```

   Go　解析并下载依赖以满足你在前面步骤添加的导入声明。

2. 在包含 `main.go` 的目录中开启一个命令行终端，运行代码。使用点号参数意味着“运行在当前目录里的代码”。

   ```
   $ go run .
   ```

   一旦代码运行起来，你就拥有了一个运行着的 HTTP 服务器，你可以向它发送请求。
3. 从一个新的命令行窗口，使用 `curl` 向你正在运行的 Web 服务发送一个请求。

   ```
   $ curl http://localhost:8080/albums
   ```

   命令将显示你之前为服务加入的数据。

   ```
   [
       {
               "id": "1",
               "title": "Blue Train",
               "artist": "John Coltrane",
               "price": 56.99
       },
       {
               "id": "2",
               "title": "Jeru",
               "artist": "Gerry Mulligan",
               "price": 17.99
       },
       {
               "id": "3",
               "title": "Sarah Vaughan and Clifford Brown",
               "artist": "Sarah Vaughan",
               "price": 39.99
       }
   ]
   ```

你已经成功启动了你的 API。下一节你将创建另一个端点以处理添加新唱片的 POST 请求。

## 5. 编写处理器以增加新项目

当客户在 `/albums` 上发起一个 `POST` 请求，你想将请求体内描述的唱片添加进已存在的唱片数据。

为了实现这个目标，你需要编写下面的代码：

- 向已有列表增加新唱片的逻辑
- 将 `POST` 请求路由至至你的逻辑代码

### 5.1 编写代码

1. 添加代码以将一个新唱片数据添加至唱片列表。

   在 `import` 语句之下某个地方，粘贴下面的代码。（文件结尾处对这段代码来讲是个好去处，但 Go 对你声明函数的顺序并没有强制要求。）

   ```
    // postAlbums adds an album from JSON received in the request body.
    func postAlbums(c *gin.Context) {
        var newAlbum album

        // Call BindJSON to bind the received JSON to
        // newAlbum.
        if err := c.BindJSON(&newAlbum); err != nil {
            return
        }

        // Add the new album to the slice.
        albums = append(albums, newAlbum)
        c.IndentedJSON(http.StatusCreated, newAlbum)
    }
   ```

   在这段代码中，你：
   + 使用 [Context.BindJSON](https://pkg.go.dev/github.com/gin-gonic/gin#Context.BindJSON) 绑定请求体到 `newAlbum`。
   + 将从 JSON 初始化来的 `album` 结构体添加进 `albums` 切片。
   + 给回复添加 `201` 状态码，以及你新添加的 `newAlbum` 的 JSON 呈现。

2. 创建你的 `main` 函数让它包括 `router.POST` 函数，如下所示：

    ```
    func main() {
        router := gin.Default()
        router.GET("/albums", getAlbums)
        router.POST("/albums", postAlbums)

        router.Run("localhost:8080")
    }
    ```

    在这段代码中，你：
    + 将在`/albums` 路径 上的 `POST` 方法与 postAlbums 函数关联起来。
      
      利用 Gin，你可以将处理器与一个 HTTP 方法与路径的组合相关联。这种方式，你可以基于客户使用的方法单独路由发送请求至一个简单路径。

### 5.2 运行代码

1. 如果服务从上一节开始一直在运行，先停止它。
2. 在包含 `main.go` 的目录中开启一个命令行终端，运行代码。

   ```
   $ go run .
   ```

3. 从一个新的命令行窗口，使用 `curl` 向你正在运行的 Web 服务发送一个请求。

   ```
   $ curl http://localhost:8080/albums \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"id": "4","title": "The Modern Sound of Betty Carter","artist": "Betty Carter","price": 49.99}'
   ```

   命令将显示 HTTP 头部以及新加入唱片的的 JSON 数据。

   ```
    HTTP/1.1 201 Created
    Content-Type: application/json; charset=utf-8
    Date: Wed, 02 Jun 2021 00:34:12 GMT
    Content-Length: 116

    {
        "id": "4",
        "title": "The Modern Sound of Betty Carter",
        "artist": "Betty Carter",
        "price": 49.99
    }
   ```
4. 像上一节一样，使用 `curl` 来检索唱片的完整列表，以此你可以确定你的新唱片确实已经添加进去了。

   ```
   $ curl http://localhost:8080/albums \
      --header "Content-Type: application/json" \
      --request "GET"
   ```

   命令将显示唱片列表。

   ```
   [
        {
                "id": "1",
                "title": "Blue Train",
                "artist": "John Coltrane",
                "price": 56.99
        },
        {
                "id": "2",
                "title": "Jeru",
                "artist": "Gerry Mulligan",
                "price": 17.99
        },
        {
                "id": "3",
                "title": "Sarah Vaughan and Clifford Brown",
                "artist": "Sarah Vaughan",
                "price": 39.99
        },
        {
                "id": "4",
                "title": "The Modern Sound of Betty Carter",
                "artist": "Betty Carter",
                "price": 49.99
        }
   ]
   ```

下一节，你见添加代码处理对一个特定唱片的 `GET` 请求。

## 6. 编写处理器以返回特定项目

当客户向 `/albums/[id]` 发起一个 `GET` 请求时，你期望返回一个唱片其 `ID` 匹配输入的 `id` 路径参数。

为了实现这个目标，你需要编写下面的代码：

- 增加逻辑以检索请求的唱片
- 将请求路径映射至你的逻辑

### 6.1 编写代码

1. 在上一节你添加的 `postAlbums` 函数之下，粘贴下面的代码以获取特定唱片。

   `getAlbumByID` 函数从请求路径中提取 `ID`，然后定位匹配的唱片。

   ```
    // getAlbumByID locates the album whose ID value matches the id
    // parameter sent by the client, then returns that album as a response.
    func getAlbumByID(c *gin.Context) {
        id := c.Param("id")

        // Loop over the list of albums, looking for
        // an album whose ID value matches the parameter.
        for _, a := range albums {
            if a.ID == id {
                c.IndentedJSON(http.StatusOK, a)
                return
            }
        }
        c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
    }
   ```

   在这段代码中，你：
   + 利用 [Context.Param](https://pkg.go.dev/github.com/gin-gonic/gin#Context.Param) 从 URL 中获取 `id` 路径参数。当你将一个处理器映射至该路径，你将在路径中包含一个占位符。
   + 循环迭代切片中的 `album ` 结构体，寻找其中 `ID` 字段值匹配 `id` 路径参数的那个。如果找到了，将那个 `album` 结构体序列化成 JSON，并将其与一个 `200 OK` HTTP 状态码一起作为回复返回。

     正如上面提到的，一个真实世界的服务将可能使用一个数据库来执行这个查询。
   + 如果唱片没有找到，利用 [http.StatusNotFound](https://pkg.go.dev/net/http#StatusNotFound) 返回一个 `HTTP 404` 错误。
2. 最后，修改你的 `main` 以使其包含对一个 `router.GET` 的调用，其路径现在为 `/albums/:id`。代码如下所示： 

    ```
    func main() {
        router := gin.Default()
        router.GET("/albums", getAlbums)
        router.GET("/albums/:id", getAlbumByID)
        router.POST("/albums", postAlbums)

        router.Run("localhost:8080")
    }
    ```

    在这段代码，你：
    + 将 `/albums/:id` 路径与 `getAlbumByID` 函数关联。在 Gin 中，路径中一个项目之前的冒号指示该乡路是个路径。

### 6.2 运行代码

1. 如果服务从上一节开始一直在运行，先停止它。
2. 在包含 `main.go` 的目录中开启一个命令行终端，运行代码。

   ```
   $ go run .
   ```

3. 从一个新的命令行窗口，使用 `curl` 向你正在运行的 Web 服务发送一个请求。

   ```
   $ curl http://localhost:8080/albums/2
   ```

   命令将显示 `ID` 字段匹配 `id` 路径参数的的唱片的 JSON 数据。如果唱片未找到，你将得到一个 JSON 格式的错误信息。

   ```
   {
       "id": "2",
       "title": "Jeru",
       "artist": "Gerry Mulligan",
       "price": 17.99
   }
   ```

## 7. 结论

祝贺你！你刚刚使用 `Go` 和 `Gin` 编写了一个简单的 `RESTful web` 服务。

建议关注下面的主题：

+ 如果你是 Go 新手，你将发现在 [Effective Go](https://go.dev/doc/effective_go) 以及 [How to write Go code](https://go.dev/doc/code) 里描述的最佳实践时很有用的。
+ [Go Tour](https://go.dev/tour/) 是一个极好的对 Go 基础的逐步介绍。
+ 关于更多 Gin，请参阅 [Gin Web Framework package documentation](https://pkg.go.dev/github.com/gin-gonic/gin) 或 [Gin Web Framework docs](https://gin-gonic.com/docs/)。

## 8. 完整代码

```
package main

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

// album represents data about a record album.
type album struct {
    ID     string  `json:"id"`
    Title  string  `json:"title"`
    Artist string  `json:"artist"`
    Price  float64 `json:"price"`
}

// albums slice to seed record album data.
var albums = []album{
    {ID: "1", Title: "Blue Train", Artist: "John Coltrane", Price: 56.99},
    {ID: "2", Title: "Jeru", Artist: "Gerry Mulligan", Price: 17.99},
    {ID: "3", Title: "Sarah Vaughan and Clifford Brown", Artist: "Sarah Vaughan", Price: 39.99},
}

func main() {
    router := gin.Default()
    router.GET("/albums", getAlbums)
    router.GET("/albums/:id", getAlbumByID)
    router.POST("/albums", postAlbums)

    router.Run("localhost:8080")
}

// getAlbums responds with the list of all albums as JSON.
func getAlbums(c *gin.Context) {
    c.IndentedJSON(http.StatusOK, albums)
}

// postAlbums adds an album from JSON received in the request body.
func postAlbums(c *gin.Context) {
    var newAlbum album

    // Call BindJSON to bind the received JSON to
    // newAlbum.
    if err := c.BindJSON(&newAlbum); err != nil {
        return
    }

    // Add the new album to the slice.
    albums = append(albums, newAlbum)
    c.IndentedJSON(http.StatusCreated, newAlbum)
}

// getAlbumByID locates the album whose ID value matches the id
// parameter sent by the client, then returns that album as a response.
func getAlbumByID(c *gin.Context) {
    id := c.Param("id")

    // Loop through the list of albums, looking for
    // an album whose ID value matches the parameter.
    for _, a := range albums {
        if a.ID == id {
            c.IndentedJSON(http.StatusOK, a)
            return
        }
    }
    c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
}
```

## Reference

- [Developing a RESTful API with Go and Gin](https://go.dev/doc/tutorial/web-service-gin)