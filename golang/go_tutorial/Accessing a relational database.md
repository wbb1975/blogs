# 访问一个关系数据库

这个教程介绍了使用 Go 访问关系数据库的基础知识，以及标准库中的 `database/sql` 包。

如果你对 Go 及其工具有基本了解，那么本教程大部分内容你可以轻松通过。如果你是第一次接触 Go，请访问[Tutorial: Get started with Go](https://go.dev/doc/tutorial/getting-started.html) 以获得一个快速介绍。

你将使用的 `database/sql` 包含有连接数据库，执行事务，取消进行中的操作，以及更多功能的类型和函数。关于使用这个包的更多细节，请访问[访问数据库](https://go.dev/doc/database/index)。

在这个教程里，你将创建一个数据库，然后写代码访问这个数据库。你的示例项目将是一个关于 `vintage` 爵士乐记录的数据仓库。

在本教程中，你将经历以下几个章节：

1. 为你的代码创建一个目录
2. 设置数据库
3. 导入数据库驱动
4. 获取一个数据库句柄并连接
5. 查询多行
6. 查询单行
7. 添加数据

> 注意：其它教程，请参见[教程主页](https://go.dev/doc/tutorial/index.html)

## 0. 前提条件

- 一个安装好 **[MySQL](https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/)数据库管理系统（DBMS）**
- **一个安装好的 Go 环境**：关于安装指令，请参见[安装 Go](https://go.dev/doc/install)。
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。

## 1. 为你的代码创建一个目录

作为开始，为你即将编写的代码创建一个目录。

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

2. 从命令行提示符，为你的代码创建一个 `data-access` 目录

   ```
   $ mkdir data-access
   $ cd data-access
   ```

3. 创建一个模块，你将在其中管理本教程中添加的依赖。

   运行 `go mod init` 命令，并传递你的新代码的模块路径。

   ```
   $ go mod init example/data-access
   go: creating new go.mod: module example/data-access
   ```

   这个命令创建了一个 `go.mod` 文件，其中你所添加的依赖被列出以便追踪。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

   > 注意：在实际开发中，你可以根据你的需求指定一个更特殊的模块路径。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

   接下来，我们将创建一个数据库。

## 2. 设置数据库

在这一步，你将创建你工作用数据库。你将使用关系数据库系统本身的命令行工工具来创建数据库和表，并添加数据。

你将创建数据库来储存关于 `vinyl` 的 `vintage jazz` 记录的数据。

这里的代码使用 [MySQL CLI](https://dev.mysql.com/doc/refman/8.0/en/mysql.html)，但是大多数关系数据库系统拥有它们自己的命令行工具，并拥有类似特性。

1. 打开一个新的命令行提示符。
2. 在命令行中，如下面关于 MySQL 所示登陆进你的关系数据库系统。

   ```
   $ mysql -u root -p
   Enter password:

   mysql>
   ```

3. 在 mysql 命令提示符中，创建一个数据库。

   ```
   mysql> create database recordings;
   ```

4. 切换到你刚创建的数据库以创建表格。

   ```
   mysql> use recordings;
   Database changed
   ```

5. 在你的文本编辑器中，在 `data-access` 目录下，创建一个名为 `create-tables.sql` 的文件以容纳添加表的脚本。
6. 在文件中，粘贴进下面的 SQL 代码，然后保存文件。

   ```
   DROP TABLE IF EXISTS album;
   CREATE TABLE album (
     id         INT AUTO_INCREMENT NOT NULL,
     title      VARCHAR(128) NOT NULL,
     artist     VARCHAR(255) NOT NULL,
     price      DECIMAL(5,2) NOT NULL,
     PRIMARY KEY (`id`)
   );

   INSERT INTO album  (title, artist, price) VALUES
     ('Blue Train', 'John Coltrane', 56.99),
     ('Giant Steps', 'John Coltrane', 63.99),
     ('Jeru', 'Gerry Mulligan', 17.99),
     ('Sarah Vaughan', 'Sarah Vaughan', 34.98);
   ```

   在这段 SQL 代码中，你：

   + 删除 (drop) 了一个名为 `album` 的表。首先执行这条命令使得之后如果你需要从新开始这个表，从而再次运行这个脚本变得容易。
   + 创建了一个带四个列的  `album` 表：`title`, `artist`, 和 p`rice`。每一行的 `id` 值由关系数据库管理系统自动创建。
   + 添加四行数据值。

7. 在 mysql 命令提示符中，运行你刚创建的脚本。

   你可以如下所示使用 `source` 命令：

   ```
   mysql> source /path/to/create-tables.sql
   ```

8. 在你的关系数据库系统命令行提示符中，使用一个 `SELECT` 语句来验证你已经成功地创建了表和数据。
   ```
   mysql> select * from album;
   +----+---------------+----------------+-------+
   | id | title         | artist         | price |
   +----+---------------+----------------+-------+
   |  1 | Blue Train    | John Coltrane  | 56.99 |
   |  2 | Giant Steps   | John Coltrane  | 63.99 |
   |  3 | Jeru          | Gerry Mulligan | 17.99 |
   |  4 | Sarah Vaughan | Sarah Vaughan  | 34.98 |
   +----+---------------+----------------+-------+
   4 rows in set (0.00 sec)
   ```

接下来，你将编写一些 Go 代码来连接并查询。

## 3. 导入数据库驱动

现在你已经得到了一个数据库及一些数据，可以开始着手 Go 代码了。

定位及导入一个数据库驱动，它将 `database/sql` 包里的函数调用所做的请求转化为数据库能够理解的请求。

1. 在你的浏览器中，访问 [SQLDrivers](https://github.com/golang/go/wiki/SQLDrivers) wiki 页面，识别出你能够使用的驱动。

   使用页面的列表来定位你将使用的驱动。为了访问这个教程中的 MySQL，你将使用 [Go-MySQL-Driver](https://github.com/go-sql-driver/mysql/)。
2. 注意驱动的包名字--这里是 `github.com/go-sql-driver/mysql`。
3. 使用你的文本编辑器，在你先前创建的 `data-access` 目录下创建名为 `main.go` 的 Go 文件。
4. 在 `main.go` 中，粘贴下面的代码以导入驱动器包。

   ```
   package main

   import "github.com/go-sql-driver/mysql"
   ```

   在这段代码，你：

   + 将你的代码添加进了 `main` 包，如此你可以独立执行它。
   + 导入了 MySQL 驱动 `github.com/go-sql-driver/mysql`。

当驱动导入后，你就可以编写代码以访问数据库了。

## 4. 获取一个数据库句柄并连接

现在编写一些 Go 代码利用一个数据库句柄来访问数据库。

你将使用一个指向 `sql.DB` 结构体的指针，它代表队一个特定数据库的访问。

### 4.1 编写代码

1. 在 `main.go` 中，在你刚加入的导入语句之下，粘贴下面的 Go 代码以创建一个数据库句柄。

   ```
    var db *sql.DB

    func main() {
        // Capture connection properties.
        cfg := mysql.Config{
            User:   os.Getenv("DBUSER"),
            Passwd: os.Getenv("DBPASS"),
            Net:    "tcp",
            Addr:   "127.0.0.1:3306",
            DBName: "recordings",
        }
        // Get a database handle.
        var err error
        db, err = sql.Open("mysql", cfg.FormatDSN())
        if err != nil {
            log.Fatal(err)
        }

        pingErr := db.Ping()
        if pingErr != nil {
            log.Fatal(pingErr)
        }
        fmt.Println("Connected!")
    }
   ```
   
   在这段代码中，你：

   + 声明了一个类型为 [*sql.DB](https://pkg.go.dev/database/sql#DB) 的变量 `db`。这是你的数据库句柄。
     
     使 `db` 成为一个全局变量可以简化示例。在产品环境中，你应该避免全局变量，比如传递一个变量给所需函数，或将其封装在一个结构体里。
   + 使用 MySQL 驱动的 [Config](https://pkg.go.dev/github.com/go-sql-driver/mysql#Config)--以及该类型的 [FormatDSN](https://pkg.go.dev/github.com/go-sql-driver/mysql#Config.FormatDSN) 来收集链接属性并将它们格式化进一个 `DSN` 以产生一个连接字符串。

     `Config` 结构体使得代码比一个单纯的连接字符串更易读。
   + 传递 `FormatDSN` 返回值作为参数调用 [sql.Open](https://pkg.go.dev/database/sql#Open) 来初始化 `db` 变量。
   + 检查 `sql.Open` 是否有错误发生。例如，如果你的数据库连接属性没有很好地格式化它就可能失败。

     为了简化代码，你调用 log.Fatal 来结束执行并打印错误到终端。在产品代码中，你将以一种更优雅的方式来护理错误。
   + 调用 [DB.Ping](https://pkg.go.dev/database/sql#DB.Ping) 来确认数据库连接可以工作。在运行时，取决于驱动器 `sql.Open` 可能不会立即连接。这里你使用 `Ping` 来确认 `database/sql` 包在需要时可以连接。
   + 检查 `Ping` 是否有错误发生，比如连接失败。
   + 如果 `Ping` 连接成功就打印一条消息。
2. 在 `main.go` 顶部附近，在包声明之下，导入你刚编写的代码所有包。
   
   文件顶部现在应该看起来像这样：

   ```
    package main

    import (
        "database/sql"
        "fmt"
        "log"
        "os"

        "github.com/go-sql-driver/mysql"
    )
   ```

3. 保存 `main.go`。

### 4.2 运行代码

1. 开始追踪 MySQL 驱动模块作为一种依赖。

   使用  [go get](https://go.dev/cmd/go/#hdr-Add_dependencies_to_current_module_and_install_them) 来为你的模块添加 `github.com/go-sql-driver/mysql` 依赖。使用点号作为参数，这意味着“为当前目录里的参数获取依赖”。

   ```
   $ go get .
   go get: added github.com/go-sql-driver/mysql v1.6.0
   ```

   由于你在先前的步骤中再导入声明中添加它，Go 将下载这个依赖。关于更多依赖追踪，参见[添加一个依赖](https://go.dev/doc/modules/managing-dependencies#adding_dependency)。
2. 从命令行提示符，设置 Go 程序将使用的 `DBUSER` 和 `DBPASS` 环境变量。

   在 Linux 或 Mac：
   ```
   $ export DBUSER=username
   $ export DBPASS=password
   ```

   在 Windows：
   ```
   C:\Users\you\data-access> set DBUSER=username
   C:\Users\you\data-access> set DBPASS=password
   ```

3. 从命令行进入包含 `main.go` 的目录，输入 `go run` 加上一个点作为参数以运行代码，它意味着”运行在当前目录的包“。
   
   ```
   $ go run .
   Connected!
   ```

你可以连接了。接下来，你将查询一些数据。

## 5. 查询多行

在这一节，你将使用 Go 来执行一个设计返回多行数据的 SQL 查询。

对于可能返回多行的 `SQL statements`，你使用 `database/sql` 包里的 `Query` 方法，并循环迭代返回的每一行（稍后你将学习如何查询单行数据）。

### 5.1 编写代码

1. 在 `main.go` 中，在 `main` 函数之上，粘贴进下面的 `Album` 结构体定义。你将使用它来持有查询返回的单行数据。
   
   ```
    type Album struct {
        ID     int64
        Title  string
        Artist string
        Price  float32
    }
   ```
2. 在 `main` 函数之下，粘贴下面的 `albumsByArtist` 函数以查询数据库。

   ```
    // albumsByArtist queries for albums that have the specified artist name.
    func albumsByArtist(name string) ([]Album, error) {
        // An albums slice to hold data from returned rows.
        var albums []Album

        rows, err := db.Query("SELECT * FROM album WHERE artist = ?", name)
        if err != nil {
            return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
        }
        defer rows.Close()
        // Loop through rows, using Scan to assign column data to struct fields.
        for rows.Next() {
            var alb Album
            if err := rows.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
                return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
            }
            albums = append(albums, alb)
        }
        if err := rows.Err(); err != nil {
            return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
        }
        return albums, nil
    }
   ```

   在这段代码中，你：

   + 声明了一个你定义的 `Album` 类型的切片 `albums`。这将持有返回的多行数据。结构体字段名字及类型与数据库列名字集类型匹配
   + 使用 [DB.Query](https://pkg.go.dev/database/sql#DB.Query) 来执行一个 `SELECT` 语句以查询一个指定艺术家的所有唱片。

     查询的第一个参数是 `SQL statement`。其后你可以传递 0 个或更多任意类型的参数。这提供了一个地方让你能够为你的 `SQL statement` 中的参数指定值。通过分离 SQL 语句及其参数值（而不是使用 `fmt.Sprintf` 拼接它们），你使得 `database/sql` 包分开发送 SQL 文本和参数值，移除了 SQL 注入风险。
   + Defer 关闭 `rows`，如此它持有的任何资源都会在函数推出后释放。
   + 循环迭代返回的每一行，使用 [Rows.Scan](https://pkg.go.dev/database/sql#Rows.Scan) 将每一行列值赋值给 `Album` 结构体字段。

     Scan 使用指向 `Go values` 的一列指针，那里列值将会被写入。这里，你使用 `&` 操作符传递 `alb` 里的字段作为指针。Scan 通过指针写入值以更新结构体字段。
   + 在循环内部，检查将列值扫描进结构体字段中是否有错误发生。
   + 在循环内部，将新的 alb 添加进 `albums` 切片。
   + 循环结束后，使用 `rows.Err` 检查查询总体是否有错误发生。注意如果查询自生失败，在这里检查一个错误是发现返回结果不完整的唯一方法。

3. 更新你的 `main` 函数以调用 `albumsByArtist`。

   在 `main` 函数尾部，添加下面的代码：
   
   ```
    albums, err := albumsByArtist("John Coltrane")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Albums found: %v\n", albums)
   ```

   在新的代码中，你：

   + 调用了你加入的 `albumsByArtist` 函数，将其返回值赋值给一个 `albums` 变量。
   + 打印结果。

### 5.2 运行代码

从命令行进入包含 `main.go` 的目录，运行代码。
   
   ```
   $ go run .
   Connected!
   Albums found: [{1 Blue Train John Coltrane 56.99} {2 Giant Steps John Coltrane 63.99}]
   ```

接下来，你将查询单行。

## 6. 查询单行

在这一节，你将使用 Go 来查询数据库中的单行。

对于最多返回一行的 `SQL statements`，你能够使用 `QueryRow` 方法，它比使用查询循环简单。

### 6.1 编写代码

1. 在 `albumsByArtist` 函数之下，粘贴下面的 `albumByID` 函数定义。

   ```
    // albumByID queries for the album with the specified ID.
    func albumByID(id int64) (Album, error) {
        // An album to hold data from the returned row.
        var alb Album

        row := db.QueryRow("SELECT * FROM album WHERE id = ?", id)
        if err := row.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
            if err == sql.ErrNoRows {
                return alb, fmt.Errorf("albumsById %d: no such album", id)
            }
            return alb, fmt.Errorf("albumsById %d: %v", id, err)
        }
        return alb, nil
    }
   ```

   在这段代码中，你：

   + 使用 [DB.QueryRow](https://pkg.go.dev/database/sql#DB.QueryRow) 来执行一个 `SELECT` 语句以查询一个指定ID的唱片。

     查询返回一个 `sql.Row`。为了简化调用代码（你的代码），`QueryRow` 并未返回一个错误。作为替代，它安排其后从 `Rows.Scan` 返回任意查询错误（比如 `sql.ErrNoRows`）。
   + 使用 [Rows.Scan](https://pkg.go.dev/database/sql#Rows.Scan) 将列值拷贝进结构体字段。
   + 从 Scan 检查是否有错误发生。

     特殊错误 `sql.ErrNoRows` 指示查询没有返回数据。典型地，这里这个错误值得用更特定的文本替代，例如 “no such album”。

2. 更新你的 `main` 函数以调用 `albumByID`。

   在 `main` 函数尾部，添加下面的代码：
   
   ```
    albums, err := albumsByArtist("John Coltrane")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Albums found: %v\n", albums)// Hard-code ID 2 here to test the query.
    alb, err := albumByID(2)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Album found: %v\n", alb)
   ```

   在新的代码中，你：

   + 调用了你加入的 `albumByID` 函数。
   + 打印 album 结果。

### 6.2 运行代码

从命令行进入包含 `main.go` 的目录，运行代码。

   ```
   Connected!
   Albums found: [{1 Blue Train John Coltrane 56.99} {2 Giant Steps John Coltrane 63.99}]
   Album found: {2 Giant Steps John Coltrane 63.99}
   ```

接下来，你将添加一个唱片到数据库。

## 7. 添加数据

在这一节，你将使用 Go 来执行 `SQL INSERT` 语句以向数据库添加新一行数据。

你已经看到了使用 `Query 和 QueryRow` 借助 SQL 语句以返回数据，为了执行不返回数据的 SQL 语句，你可使用 `Exec` 方法。

### 7.1 编写代码

1. 在 `albumByID` 函数之下，粘贴下面的 `addAlbum` 函数定义以向数据库增加一个唱片，然后保存 `main.go`。

   ```
    // addAlbum adds the specified album to the database,
    // returning the album ID of the new entry
    func addAlbum(alb Album) (int64, error) {
        result, err := db.Exec("INSERT INTO album (title, artist, price) VALUES (?, ?, ?)", alb.Title, alb.Artist, alb.Price)
        if err != nil {
            return 0, fmt.Errorf("addAlbum: %v", err)
        }
        id, err := result.LastInsertId()
        if err != nil {
            return 0, fmt.Errorf("addAlbum: %v", err)
        }
        return id, nil
    }
   ```

   在这段代码中，你：

   + 使用 [DB.Exec](https://pkg.go.dev/database/sql#DB.Exec) 执行了一个 `INSERT` 语句。

     就像查询，`Exec` 需要一个 SQL 语句后跟该 SQL 语句所需参数。
   + 检查 `INSERT` 是否有错误发生。
   + 使用 [Result.LastInsertId](https://pkg.go.dev/database/sql#Result.LastInsertId) 检索最新插入的唱片的 ID。
   + 检查检索 ID 时是否有错误发生。

2. 更新你的 `main` 函数以调用 `addAlbum`。

   在 `main` 函数尾部，添加下面的代码：
   
   ```
    albID, err := addAlbum(Album{
        Title:  "The Modern Sound of Betty Carter",
        Artist: "Betty Carter",
        Price:  49.99,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("ID of added album: %v\n", albID)
   ```

   在新的代码中，你：

   + 以一个新的 `album` 调用 `addAlbum` 函数，指定你新加入唱片的 ID 给一个 `albID` 变量。

### 7.2 运行代码

从命令行进入包含 `main.go` 的目录，运行代码。

   ```
   $ go run .
   Connected!
   Albums found: [{1 Blue Train John Coltrane 56.99} {2 Giant Steps John Coltrane 63.99}]
   Album found: {2 Giant Steps John Coltrane 63.99}
   ID of added album: 5
   ```

## 8. 结论

祝贺你！你刚刚使用 Go 完成了对关系数据库的简单操作。

建议关注下面的主题：

+ 看一看数据访问指南，它包括比我们这里接触的更多信息。
+ 如果你是 Go 新手，你将发现在 [Effective Go](https://go.dev/doc/effective_go) 以及 [How to write Go code](https://go.dev/doc/code) 里描述的最佳实践时很有用的。
+ [Go Tour](https://go.dev/tour/) 是一个极好的对 Go 基础的逐步介绍。

## 9. 完整代码

这一节包含你在这个教程开发的应用的完整代码。

```
package main

import (
    "database/sql"
    "fmt"
    "log"
    "os"

    "github.com/go-sql-driver/mysql"
)

var db *sql.DB

type Album struct {
    ID     int64
    Title  string
    Artist string
    Price  float32
}

func main() {
    // Capture connection properties.
    cfg := mysql.Config{
        User:   os.Getenv("DBUSER"),
        Passwd: os.Getenv("DBPASS"),
        Net:    "tcp",
        Addr:   "127.0.0.1:3306",
        DBName: "recordings",
    }
    // Get a database handle.
    var err error
    db, err = sql.Open("mysql", cfg.FormatDSN())
    if err != nil {
        log.Fatal(err)
    }

    pingErr := db.Ping()
    if pingErr != nil {
        log.Fatal(pingErr)
    }
    fmt.Println("Connected!")

    albums, err := albumsByArtist("John Coltrane")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Albums found: %v\n", albums)

    // Hard-code ID 2 here to test the query.
    alb, err := albumByID(2)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Album found: %v\n", alb)

    albID, err := addAlbum(Album{
        Title:  "The Modern Sound of Betty Carter",
        Artist: "Betty Carter",
        Price:  49.99,
    })
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("ID of added album: %v\n", albID)
}

// albumsByArtist queries for albums that have the specified artist name.
func albumsByArtist(name string) ([]Album, error) {
    // An albums slice to hold data from returned rows.
    var albums []Album

    rows, err := db.Query("SELECT * FROM album WHERE artist = ?", name)
    if err != nil {
        return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
    }
    defer rows.Close()
    // Loop through rows, using Scan to assign column data to struct fields.
    for rows.Next() {
        var alb Album
        if err := rows.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
            return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
        }
        albums = append(albums, alb)
    }
    if err := rows.Err(); err != nil {
        return nil, fmt.Errorf("albumsByArtist %q: %v", name, err)
    }
    return albums, nil
}

// albumByID queries for the album with the specified ID.
func albumByID(id int64) (Album, error) {
    // An album to hold data from the returned row.
    var alb Album

    row := db.QueryRow("SELECT * FROM album WHERE id = ?", id)
    if err := row.Scan(&alb.ID, &alb.Title, &alb.Artist, &alb.Price); err != nil {
        if err == sql.ErrNoRows {
            return alb, fmt.Errorf("albumsById %d: no such album", id)
        }
        return alb, fmt.Errorf("albumsById %d: %v", id, err)
    }
    return alb, nil
}

// addAlbum adds the specified album to the database,
// returning the album ID of the new entry
func addAlbum(alb Album) (int64, error) {
    result, err := db.Exec("INSERT INTO album (title, artist, price) VALUES (?, ?, ?)", alb.Title, alb.Artist, alb.Price)
    if err != nil {
        return 0, fmt.Errorf("addAlbum: %v", err)
    }
    id, err := result.LastInsertId()
    if err != nil {
        return 0, fmt.Errorf("addAlbum: %v", err)
    }
    return id, nil
}
```

## Reference

- [访问一个关系数据库](https://go.dev/doc/tutorial/database-access)
- [PostgreSQL新手入门](https://www.ruanyifeng.com/blog/2013/12/getting_started_with_postgresql.html)
- [如何配置PostgreSQL允许被远程访问](https://zhuanlan.zhihu.com/p/23927799)
- [SQL database drivers](https://github.com/golang/go/wiki/SQLDrivers)
- [pq - A pure Go postgres driver for Go's database/sql package](https://github.com/lib/pq)
- [Connecting to a PostgreSQL database with Go's database/sql package](https://www.calhoun.io/connecting-to-a-postgresql-database-with-gos-database-sql-package/)
- [Quickstart: Use Go language to connect and query data in Azure Database for PostgreSQL - Single Server](https://learn.microsoft.com/en-us/azure/postgresql/single-server/connect-go)