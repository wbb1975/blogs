欢迎来到AWS C++ SDK　wiki!
# 普通常见问题（General FAQ）
## 我怎样从源代码编译SDK
参阅相对详细的[逐步指南](https://github.com/wbb1975/blogs/blob/master/aws/build_c%2B%2Bsdk_on_ec2.md)来入门。
## 我怎么打开日志
日至设施的类型和可见性是在SDK的初始化过程中由SDKOptions指定的。指定任何非LogLevel::Off的级别将打开缺省日志器（logger）。缺省的日志器将会写向文件系统，日志文件将采用形如aws_sdk_YYYY-MM-DD-HH.log的命名模式。日志器将每小时创建一个新的日志文件。总共由六个日志级别：
1. Off (the default)
2. Fatal
3. Error
4. Warn
5. Info
6. Debug
7. Trace
比如，打开Debug日志：
```
Aws::SDKOptions options;
options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Debug;
Aws::InitAPI(options);
// ...
Aws::ShutdownAPI(options);
```

SDK带有一个终端日志器－－它把日志消息打到标准输出上。为了使用终端日志器代替缺省文件系统日志器：

```
#include <aws/core/utils/logging/ConsoleLogSystem.h>

using namespace Aws::Utils::Logging;
Aws::SDKOptions options;
options.loggingOptions.logLevel = LogLevel::Debug;
options.loggingOptions.logger_create_fn = [] { return std::make_shared<ConsoleLogSystem>(LogLevel::Trace); };
Aws::InitAPI(options);
// ...
Aws::ShutdownAPI(options);
```
## 支持什么样的编译器
当前我们支持以下编译器：
1. GCC 4.9.x and later
2. Clang 3.3 and later
3. Visual Studio 2015 and later
## 我仍在使用一个较老的编译器（C++11之前版本），我该怎么使用SDK
很快到来
## 我们遵从什么样的版本命名规范
主版本号.次版本号.补丁号（Major.Minor.Patch）
+ 主版本号为全面修改保留（我们目前还不需要它）
+ 次版本号是为源代码级别的不兼容而引入的，我们将尽力减少此类修改
+ 补丁号主要是针对频繁的服务升级
## InitAPI and ShutdownAPI主要做了什么
很快到来
## 我们为什么要有Aws::String，它与std::string有什么区别？
很快到来
## CMake编译选项
 除了你可以传递的所有标准CMake编译选项，以下选项是AWS SDK特有的：
 + -DBUILD_ONLY
  这个选项让你选择性的编译服务而非整个SDK。如果你感兴趣的仅仅是单一服务，这个选项是很方便的。比如，为了编译S3 & Lambda你可以传递-DBUILD_ONLY="s3,lambda"
 + -DBUILD_DEPS
  缺省这个选项是打开的，为了独立于SDK之外编译第三方依赖库，关闭这个选项。
 + DREGENERATE_CLIENTS
  缺省这个选项是关闭的，为了重新产生服务的客户端，打开它。注意：这将调用代码生成器，这是用Java编译出来的（据我所知）。当重新产生客户端时，必必须在机器上拥有JDK, maven和python。
