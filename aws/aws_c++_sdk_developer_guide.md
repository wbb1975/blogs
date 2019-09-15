# AWS SKD C++开发者指南
欢迎来到AWS SKD C++开发者指南！

 AWS SDK  C++提供了访问AWS的现代C++接口（C++ 11或更新），它为几乎所有AWS特性提供了高级和低级接口，最小化依赖，并提供了Windows, macOS, Linux, 以及 mobile的可移植性。

 **其它文档和资源**

 除了这个指南，对于AWS SDK C++开发者下面是一些有用的线上资源： 
- [AWS SDK for C++ Reference](https://sdk.amazonaws.com/cpp/api/)
- [Video: Introducing the AWS SDK for C++ from AWS re:invent 2015](https://www.youtube.com/watch?v=fm4Aa3Whwos&amp;list=PLhr1KZpdzuke5pqzTvI2ZxwP8-NwLACuU&amp;index=9)
- [AWS C++ Developer Blog](http://aws.amazon.com/blogs/developer/category/cpp/)
- GitHub
  + [SDK source](https://github.com/aws/aws-sdk-cpp)
  + [SDK issues](https://github.com/aws/aws-sdk-cpp/issues)
- [SDK License](https://aws.amazon.com/apache2.0/)
## 第一章 入门（Getting Started ）
### $1 设立AWS SKD C++
本节给出了在你的开发平台上如何设立AWS SDK C++的相关信息。 
#### 前提 
为了使用AWS SDK for C++，你需要：
- Visual Studio 2015 或更高
- GNU Compiler Collection (GCC) 4.9  或更高
- Clang 3.3 或更高
- 至少4 GB内存
  > 注意： 你需要4GB内存来编译大的AWS客户端。AWS SDK可能在某些Amazon EC2类型如t2.micro, t2.small以及一些小型实例上失败，原因就是内存不够。

**Linux系统的额外需求**

为了在Linux上编译，必必须拥有libcurl, libopenssl, libuuid, zlib, 以及可选地，支持亚马逊策略支持（Amazon Polly support）的libpulse的头文件（-dev packages），典型地这些包可以利用系统的包管理器找到。

**在基于Debian/Ubuntu的系统上安装包**
```
sudo apt-get install libcurl4-openssl-dev libssl-dev uuid-dev zlib1g-dev libpulse-dev
```
**在基于Redhat/Fedora的系统上安装包**
```
sudo dnf install libcurl-devel openssl-devel libuuid-devel pulseaudio-devel
```
**在基于CentOS的系统上安装包**
```
sudo yum install libcurl-devel openssl-devel libuuid-devel pulseaudio-libs-devel
```
#### 为Visual C++使用NuGet获取SDK
如果你使用Microsoft Visual C++开发，你可以使用NuGet来管理你的AWS SDK for C++项目。为了使用这一步骤，你的系统必须已经安装[NuGet](https://www.nuget.org/)。

**通过NuGet使用SDK**：
1. 用Visual Studio打开你的项目
2. 在Solution Explorer，右击你的项目并选择Manage NuGet Packages
3. 搜索你的特殊服务或库来选择你的包。例如，你可能选择搜索aws s3 native。或者，由于AWS SDK for C++库的命名比较一致，使用AWSSDKCPP-service name来添加你的项目依赖的服务。
4. 选择Install来安装你的项目依赖的服务。
#### 为Visual C++使用Vcpkg获取SDK
如果你使用Microsoft Visual C++开发，你可以使用Vcpkg来管理你的AWS SDK for C++项目。为了使用这一步骤，你的系统必须已经安装[VCpkg](https://github.com/Microsoft/vcpkg)。

**通过VCpkg使用SDK**：
1. 打开一个Windows命令行窗口，切换至vcpkg目录
2. 将VCpkg集成到Visual Studio，可以集成到项目或用户。下面的命令行将vcpkg集成到当前用户：
  ```
  vcpkg integrate install
  ```
3. 安装AWS SDK for C++包。包将编译整个SDK及其依赖。这将花费一些时间。
   ```
   vcpkg install aws-sdk-cpp[*]:x86-windows --recurse
   ```
   为了减少编译时间，仅仅编译需要的包。在方括号中指定包名字。必须包括core包。
   ```
   vcpkg install aws-sdk-cpp[core,s3,ec2]:x86-windows
   ```
   包的名字可以从服务的AWS SDK for C++仓库目录得到，比如：
   ```
   aws-sdk-cpp\aws-cpp-sdk-<packageName>   # Repo directory name and packageName
   aws-sdk-cpp\aws-cpp-sdk-s3              # Example: Package name is s3
   ```
4. 在 Visual Studio中打开你的项目
5. 包含你的项目中用到的AWS SDK for C++头文件。

和NuGet一样，当你编译你的项目时，产生的二进制文件正确地包含了你使用的运行时、架构配置。
#### 从源代码编译SDK
如果你不想使用Visual Studio（或者你不想使用NuGet），你可以使用命令行工具从源代码编译SDK。这种方式使你可以定制你的SDK编译过程--参阅[CMake Parameters](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/cmake-params.html)可得到更多可用选项。
1. 下载或克隆源代码从GitHub [aws/aws-sdk-cpp ](https://github.com/aws/aws-sdk-cpp)
  + 直接下载：[aws/aws-sdk-cpp/archive/master.zip](https://github.com/aws/aws-sdk-cpp/archive/master.zip)
  + 用Git克隆
     ```
     git clone git@github.com:aws/aws-sdk-cpp.git          # or
     git clone https://github.com/aws/aws-sdk-cpp.git
     ```
2. 为你的平台安装[cmake](https://cmake.org/)(v3.2或更新)及及相关编译工具。确保它们在你的“PATH”里。
3. 推荐方式：把Build过程中产生的文件放在SDK源代码目录之外。创建一个新目录来存放这些文件。然后运行cmake来产生他们。在cmake命令行中指定创建 Debug还是Release 版本。
   ```
   sudo mkdir sdk_build
   cd sdk_build
   sudo cmake <path/to/sdk/source> -D CMAKE_BUILD_TYPE=[Debug | Release]
   ```
   另一种方式，在SDK源代码目录中直接创建
   ```
   cd <path/to/sdk/source>
   sudo cmake . -D CMAKE_BUILD_TYPE=[Debug | Release]
   ```

   编译整个SDK可能会花费较长时间，可以使用cmake BUILD_ONLY 参数仅仅编译一个特殊服务。下面的例子仅仅编译S3服务。更多改变创建输出的方式，请参阅[CMake Parameters](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/cmake-params.html)。
   ```
   sudo cmake -D CMAKE_BUILD_TYPE=[Debug | Release] -D BUILD_ONLY="s3"
   ```
4. 用如下操作系统中立的命令来创建SDK 二进制文件。如果你创建整个SDK，这将花费1个小时或更长。
   ```
   sudo make
   ```
   或者
   ```
   msbuild ALL_BUILD.vcxproj
   ```
5. 运行如下操作系统中立的命令来安装SDK
   ```
   sudo make install
   ```
   或者
   ```
   rem Run this command in a command shell running in ADMIN mode
   rem The SDK is installed in `\Program Files (x86)\aws-cpp-sdk-all\`
   msbuild INSTALL.vcxproj /p:Configuration=[Debug | Release | "Debug;Release"]
   ```
#### 为安卓（Android）编译SDK
为了创建安卓SDK，在cmake命令行上添加 -DTARGET_ARCH=ANDROID。AWS SDK for C++已经包含了所需的cmake工具链，前提是你已经设立了争取的环境变量(ANDROID_NDK)。 
### $2 提供AWS凭证（Providing AWS Credentials）
要连接仁义AWS SDK for C++支持的AWS服务，你必须提供AWS凭证。AWS SDKs 和 CLIs使用提供者链来在不同的地方寻找AWS凭证，包括系统/用户环境变量，以及本地AWS配置文件。

你可以用不同的方式设置AWS SDK for C++所需凭证，但下面是推荐的方式：
+ 在本地系统的AWS credentials profile文件中设置凭证
    - 在Linux, macOS, 或 Unix平台上是~/.aws/credentials on 
    -  在Windows平台上是C:\Users\USERNAME\.aws\credentials
    
    该文件应该包含如下格式内容：
    ```
    [default]
    aws_access_key_id = your_access_key_id
    aws_secret_access_key = your_secret_access_key
    ```
    将the values your_access_key_id 和 your_secret_access_key替换为你自己的AWS凭证值。
+ 设置AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY环境变量
    在Linux, macOS, 或 Unix，使用export设置环境变量
    ```
    export AWS_ACCESS_KEY_ID=your_access_key_id
    export AWS_SECRET_ACCESS_KEY=your_secret_access_key
    ```
    在Windows平台上，用set设置环境变量
    ```
    set AWS_ACCESS_KEY_ID=your_access_key_id
    set AWS_SECRET_ACCESS_KEY=your_secret_access_key
    ```
+ 对于一个EC2实例，制定一个IAM角色并授予你的EC2实例访问这个角色的权限。查阅Amazon EC2用户指南中的[ IAM Roles for Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)以获取这种方式如何工作的详细信息。

当你用如上任一方式设置好了AWS凭证后，AWS SDK for C++将使用默认凭证提供者链自动加载它们。

你也可以使用你自己的方式提供AWS凭证：
- 把你的凭证提供给AWS client类的构造函数
- 使用[Amazon Cognito](https://aws.amazon.com/cognito/)，一种AWS实体管理方案。你可以在实体管理项目中使用CognitoCachingCredentialsProviders。更多信息，请参阅[Amazon Cognito开发者指南](https://docs.aws.amazon.com/cognito/latest/developerguide/)。
### $3 使用AWS SDK for C++
使用AWS SDK for C++的应用必须初始化它，类似地，应用终止前，SDK必须被停止。两种操作（初始化和停止）都接受配置选项，这些选项将会影响初始化和停止过程以及其后的SDK调用。
#### 初始化和停止SDK
所有使用AWS SDK for C++的应用必须包含**aws/core/Aws.h**。

AWS SDK for C++必须调用Aws::InitAPI来初始化它。应用终止前，SDK必须Aws::ShutdownAPI来停止它。两种方法都接受Aws::SDKOptions参数。对SDK其它方法的调用在这两个方法之间发出。

最佳实践要求所有在Aws::InitAPI 和 Aws::ShutdownAPI之间的AWS SDK for C++调用要么被大括弧包装成代码块，要么在两个方法之间直接调用。

一个基本的应用框架如下所示：
```
#include <aws/core/Aws.h>
int main(int argc, char** argv)
{
   Aws::SDKOptions options;
   Aws::InitAPI(options);
   {
      // make your SDK calls here.
   }
   Aws::ShutdownAPI(options);
   return 0;
}
```
#### 设置SDK选项
[Aws::SDKOptions](https://sdk.amazonaws.com/cpp/api/LATEST/struct_aws_1_1_s_d_k_options.html)结构体含有SDK配置选项。

一个[Aws::SDKOptions](https://sdk.amazonaws.com/cpp/api/LATEST/struct_aws_1_1_s_d_k_options.html)结构体实例被传递给Aws::InitAPI 和 Aws::ShutdownAPI方法，同一个实例应该被传递给两个方法。

下面的例子演示了一些可用选项：
  - 用缺省日志器打开日志
     ```
     Aws::SDKOptions options;
    options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Info;
    Aws::InitAPI(options);
    {
        // make your SDK calls here.
    }
    Aws::ShutdownAPI(options);
     ```
  - 安装一个自定义内存管理器
    ```
    MyMemoryManager memoryManager;
    Aws::SDKOptions options;
    options.memoryManagementOptions.memoryManager = &memoryManager;
    Aws::InitAPI(options);
    {
        // make your SDK calls here.
    }
    Aws::ShutdownAPI(options);
    ```
  - 覆盖缺省HTTP client factory
     ```
     Aws::SDKOptions options;
     options.httpOptions.httpClientFactory_create_fn = [](){
        return Aws::MakeShared<MyCustomHttpClientFactory>(
            "ALLOC_TAG", arg1);
    };
     Aws::InitAPI(options);
     {
        // make your SDK calls here.
     }
     Aws::ShutdownAPI(options);
     ```
     > **注意**
     > httpOptions传递的是一个闭包而不是一个std::shared_ptr。SDK的每个工厂方法以同样的方式工作，这是由于在工厂内存分配发生时，内存管理器还没有安装。通过传递给方法一个闭包，内存管理器将会在安全的时候被调用来分配内存。完成这个过程的简单方式是使用Lambda表达式。
#### 更多信息
AWS SDK for C++的更多示例代码在[AWS SDK for C++ Code Examples](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/programming-services.html)中描述。每个示例包含了一个在GitHub上的完整代码的链接，这些事例可以作为你自己的应用的出发点。
### $4 用CMake构建你的程序
[Cmake](https://cmake.org/)是一个创建适合你平台的makefiles，以及管理你的应用依赖的构建（build）工具。这是一个创建及构建AWS SDK for C++项目的简单方式。
#### 创建一个CMake项目
1. 创建一个目录来容纳你的项目：`mkdir my_example_project`
2. 切换到目录，添加一个文件CMakeLists.txt--其指定你的项目的名字，可执行文件名，源代码及链接库等。下面是一个极小的示例：
    ```
    # minimal CMakeLists.txt for the AWS SDK for C++
    cmake_minimum_required(VERSION 3.2)

    # "my-example" is just an example value.
    project(my-example)

    # Locate the AWS SDK for C++ package.
    # Requires that you build with:
    #   -DCMAKE_PREFIX_PATH=/path/to/sdk_install
    find_package(AWSSDK REQUIRED COMPONENTS service1 service2 ...)

    # The executable name and its sourcefiles
    add_executable(my-example my-example.cpp)

    # The libraries used by your executable.
    # "aws-cpp-sdk-s3" is just an example.
    target_link_libraries(my-example ${AWSSDK_LINK_LIBRARIES})
    ```
> 注意： 你可以在你的创建文件CMakeLists.txt中设立很多选项。关于这个文件特性的介绍，请参阅CMake网站上的[CMake tutorial](https://cmake.org/cmake-tutorial/)。
#### 设置CMAKE_PREFIX_PAT H（可选）
Cmake需要知道aws-sdk-cpp-config.cmake的位置，如此它才能解析你的应用使用的AWS SDK库。你可以在[构建SDK](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/setup.html)一节中建立的build目录中找到它。

通过设置CMAKE_PREFIX_PATH，你不需要在够建你的应用时每次输入这个路径。

你可以在Linux, macOS, or Unix中象如下设置：
```
export CMAKE_PREFIX_PATH=/path/to/sdk_build_dir
```
在Windows上如下设置：
```
set CMAKE_PREFIX_PATH=C:\path\to\sdk_build_dir
```
#### 用CMake构建
创建一个目录，你将在着这个目录中构建
```
mkdir my_project_build
```
切换到构建目录，传入你的项目的源代码目录运行cmake命令
```
cd my_project_build
cmake ../my_example_project
```
如果你没有设置CMAKE_PREFIX_PATH，你必须用-Daws-sdk-cpp_DIR加入SDk构建目录
```
cmake -Daws-sdk-cpp_DIR=/path/to/sdk_build_dir ../my_example_project
```
当cmake产生了构建目录，你可以使用make (Windows上使用nmake)来构建你的应用。
## 第二章 配置SDK
### $1 CMake参数
使用本节介绍的CMake参数来定制你的SDK构建。

你可以使用CMake图形工具或者在命令行使用”-D“来设置这些选项，例如：
    ```
    cmake -DENABLE_UNITY_BUILD=ON -DREGENERATE_CLIENTS=1
    ```
#### 通用CMake变量和选项
  > 注意： 为了使用变量ADD_CUSTOM_CLIENTS 或 REGENERATE_CLIENTS，你必须安装了[Python 2.7](https://www.python.org/downloads/), Java ([JDK 1.8+](http://openjdk.java.net/install/)), and [Maven](https://maven.apache.org/)，并已经将它们加入到你的 PATH里。
- ADD_CUSTOM_CLIENTS
  基于API定义构建任意客户。将你的定义放在code-generation/api-definitions目录下，并将该参数传递给cmake。cmake的配置阶段将产生你的客户端，并将其以一个子目录的方式包进构建过程。这对于产生使用[APIGateway](https://aws.amazon.com/api-gateway/)服务的客户端尤其有用。
   ```
   -DADD_CUSTOM_CLIENTS="serviceName=myCustomService;version=2015-12-21;serviceName=someOtherService;version=2015-08-15"
   ```
- BUILD_ONLY
   仅仅构建你需要的客户端。如果设置一个高阶SDK，比如aws-cpp-sdk-transfer，BUILD_ONLY将解析任何底层客户端依赖。如果存在，它也构建你选择的项目的集成和单元测试。这是一个列表参数，值以分号分割。例如：
   ```
   -DBUILD_ONLY="s3;cognito-identity"
   ```
   > 注意：SDK核心模块，即aws-sdk-cpp-core，无论BUILD_ONLY被传入什么值，都会被构建。
- BUILD_SHARED_LIBS
   CMake内建选项，这里重为了可见性新导出。如果开启，将构建共享库，否则，它将仅构建静态库。
    > 注意：为了动态链接SDK，你必须为使用SDK的所有构建目标定义USE_IMPORT_EXPORT。

    Values

        ON/OFF
    
    Default

      ON
- CPP_STANDARD

   指定用户C++标准

   Values

        11/14/17
    
    Default

      11
- CUSTOM_MEMORY_MANAGEMENT
   为了使用用户内存管理器，设置这个值为1。你可以安装一个用户分配器，那样所有STL 类型都将使用你的定制分配接口。如果你将这个值设为0，你可能期望使用标准模板类型，此举有助于Windows上dll的安全性。

   如果静态链接开启，用户内存管理缺省关闭（0）。如果动态链接开启，用户内存管理缺省开启（1），并且应该避免跨Dll的分配和回收。

   > **注意**：为防止链接不匹配错误，你应该在你的整个构建系统中使用同样的值（0或1）。

   为了安装你自己的内存管理器来用于SDK的分配请求，你必须设置-DCUSTOM_MEMORY_MANAGEMENT并为依赖SDK的所有构建目标定义AWS_CUSTOM_MEMORY_MANAGEMENT。
- ENABLE_RTTI   
   控制SDK是否开启运行时信心（RTTI）

   Values

        ON/OFF
    
    Default

      ON
- ENABLE_TESTING
   控制SDK构建过程中时候构建单元及集成测试项目。

   Values

        ON/OFF
    
    Default

      ON
- ENABLE_UNITY_BUILD
  
   如果开启，大部分SDK库将被构建成一个简单的，生成的.cpp文件。这将极大地减小静态库大小并加快编译时间。

   Values

        ON/OFF
    
    Default

      ON
- FORCE_SHARED_CRT
   如果开启，SDK将动态链接C运行时；否则，它使用BUILD_SHARED_LIBS 的设置（有时候，对早期版本SDk的兼容性是需要的）

   Values

        ON/OFF
    
    Default

      ON
- G
   产生构建制品（artifacts），比如Visual Studio解决方案或Xcode项目。

   比如，在Windows上：
   ```
   -G "Visual Studio 12 Win64"
   ```
   更多信息，请参阅你的平台的CMake文档。
- MINIMIZE_SIZE
   ENABLE_UNITY_BUILD的超级设置，一旦开启，它将设置ENABLE_UNITY_BUILD，并同时打开一些减小二进制文件大小的设置。

   Values

        ON/OFF
    
    Default

      OFF
- NO_ENCRYPTION
   如果开启，将阻止平台特定的加密实现被编译进构建的库中。开启它，你可以注入自己的加密实现。

   Values

        ON/OFF
    
    Default

      OFF
- NO_HTTP_CLIENT
   如果开启，将阻止平台特定的HTTP client被编译进构建的库中。开启它，你可以注入自己的HTTP client。
   
   Values

        ON/OFF
    
    Default

      OFF
- REGENERATE_CLIENTS
   一旦开启，将清除所有产生的代码并从code-generation/api-definitions目录中产生客户目录，例如：`-DREGENERATE_CLIENTS=1`
- SIMPLE_INSTALL
   如果开启，安装过程将不会在bin/ and lib/下产生平台特定的中间目录。如果你需要在单一安装目录下发布多个平台的实现就关闭它。

   Values

        ON/OFF
    
    Default

      ON
- TARGET_ARCH
   
   为了交叉编译或者为了移动平台构建，你必须指定一个目标平台。默认地，构建过程会检测宿主操作系统并为检测到的操作系统构建。
    > 注意：当TARGET_ARCH是ANDROID时，有额外的选项可用，请参阅[Android CMake Variables and Options.](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/cmake-params.html#cmake-android-variables)。

    Values
    
       WINDOWS | LINUX | APPLE | ANDROID
#### 安卓适用的CMake变量和选项
### $2 AWS客户端配置
利用客户端配置来控制AWS SDK for C++.的各种行为。

ClientConfiguration声明：
```
struct AWS_CORE_API ClientConfiguration
{
    ClientConfiguration();

    Aws::String userAgent;
    Aws::Http::Scheme scheme;
    Aws::Region region;
    bool useDualStack;
    unsigned maxConnections;
    long requestTimeoutMs;
    long connectTimeoutMs;
    bool enableTcpKeepAlive;
    unsigned long tcpKeepAliveIntervalMs;
    unsigned long lowSpeedLimit;
    std::shared_ptr<RetryStrategy> retryStrategy;
    Aws::String endpointOverride;
    Aws::Http::Scheme proxyScheme;
    Aws::String proxyHost;
    unsigned proxyPort;
    Aws::String proxyUserName;
    Aws::String proxyPassword;
    std::shared_ptr<Aws::Utils::Threading::Executor> executor;
    bool verifySSL;
    Aws::String caPath;
    Aws::String caFile;
    std::shared_ptr<Aws::Utils::RateLimits::RateLimiterInterface> writeRateLimiter;
    std::shared_ptr<Aws::Utils::RateLimits::RateLimiterInterface> readRateLimiter;
    Aws::Http::TransferLibType httpLibOverride;
    bool followRedirects;
    bool disableExpectHeader;
    bool enableClockSkewAdjustment;
    bool enableHostPrefixInjection;
    bool enableEndpointDiscovery;
};
```

**配置变量**
- userAgent
  
   仅仅内部使用，不要更改其设置。
- scheme
  
   指定URI地址架构，HTTP 或 HTTPS， 默认为HTTPS。
- region
  
   **指定使用的AWS区域，比如us-east-1。默认地，使用的区域是可用AWS凭证配置的的缺省区域**。
- useDualStack

   控制是否使用 IPv4 和 IPv6 双栈端点。注意不是所有区域的所有AWS服务支持 IPv6 。
- maxConnections

   指定和单独一个服务的最大HTTP连接数。缺省值为25。除了你的带宽限制，没有真正最大允许连接数。
- requestTimeoutMs 和 connectTimeoutMs
  
   指定一个HTTP请求超时前等待的毫秒数（milliseconds）。比如，在传递大的文件前考虑增加这些值。
- enableTcpKeepAlive
  
   控制是否发送TCP保活（keep-alive）包，缺省设置为true。常与tcpKeepAliveIntervalMs一起使用。这个变量在WinINet和IXMLHTTPRequest2中不可用。
- tcpKeepAliveIntervalMs
   
   在一个TCP连接间发送keep-alive包的以毫秒计时的时间间隔。缺省间隔是30秒。最小设置是15秒。这个变量在WinINet和IXMLHTTPRequest2中不可用。
- lowSpeedLimit
  
   指定最小传输字节速率。如果传输速率低于这个值，传输过程就被放弃。缺省设置是1字节每秒。这个变量仅仅适用于CURL客户端。
- retryStrategy
  
  指向重试策略实现。缺省策略实现了一种指数递减策略。为了制定一个不同的策略，实现一个RetryStrategy的子类并将其实例赋给这个选项。
- endpointOverride

  指定一个覆写的与服务交互的HTTP端点
- proxyScheme, proxyHost, proxyPort, proxyUserName, 和 proxyPassword

  设置并配置与AWS通信的代理。这种机制适合的场景包括与Burp suite的调试，或链接互联网。
- executor
   
   指向一个异步执行器的实现。缺省的行为是为每个异步调用创建并脱离（detach）一个线程。为了改变这个行为，创建一个Executor的子类，并传递其实例给这个变量。
- verifySSL

   控制是否验证SSL凭证。缺省SSL凭证是验证的。如果不想验证，设置这个变量为false。
- caPath, caFile

  指示HTTP客户端去哪里查找你的SSL凭证信任存储。一个信任存储的例子可以使用OpenSSL c_rehash工具准备好的目录。这些变量不需要设置，除非你的环境使用了符号链接。这些变量在Windows 和 macOS上无效。
- writeRateLimiter 和 readRateLimiter
  
   指向一个读，写速度控制器的实现，用来限制传输层带宽。缺省情况下，读写带宽没有限制。为了引入流控，实现一个RateLimiterInterface的子类并传递其实例给这个变量。
- httpLibOverride

   指定有缺省HTTP工厂返回的HTTP实现。Windows平台的缺省HTTP客户端是现是WinHTTP。其它所有平台的HTTP客户端是CURL。
- followRedirects

   控制HTTP栈是否跟随300重定向码。
- disableExpectHeader

   仅适用于CURL HTTP客户端。缺省地，CURL在HTTP请求中添加"Expect: 100-Continue" 头，以此来避免在服务器在收到请求头这届发送一个错误时的情况下发送HTTP负荷。这个行为可以节省一个往返通讯，适用于负荷较小并有网路延迟的场合。该变量的缺省设置为false。CURL被要求同事发送HTTP请求头和负荷。
- enableClockSkewAdjustment

   控制是否每次HTTP通讯都调整时钟偏差。缺省为false。
- enableHostPrefixInjection

   控制是否在DiscoverInstances请求中为HTTP 主机添加"data-"前缀。缺省这个行为开启。为了关闭这个行为，将其设置为false。
- enableEndpointDiscovery

   控制是否使用端点发现。缺省，区域或覆盖的端点被使用。为了开启端点发现，将这个变量设置为true。
### $3 覆写你的HTTP客户端
Windows平台的缺省HTTP客户端是现是[WinHTTP](https://msdn.microsoft.com/en-us/library/windows/desktop/aa382925%28v=vs.85%29.aspx)。其它所有平台的HTTP客户端是[CURL](https://curl.haxx.se/)。如果需要，你可以创建一个定制的HttpClientFactory对象，并把它传递给任何服务的客户端构造函数。
### $4 控制HttpClient 和 AWSClient的IO流
缺省地，所有服务回复（response）使用一个基于stringbuf的输入流。服务需要，你可以覆盖其缺省行为。例如，如果你使用亚马逊S3GetObject方法，切不想把整个文件载入内存，你可以使用AmazonWebServiceRequest中的IOStreamFactory，并传递一个匿名函数来创建一个文件流。
```
GetObjectRequest getObjectRequest;
getObjectRequest.SetBucket(fullBucketName);
getObjectRequest.SetKey(keyName);
getObjectRequest.SetResponseStreamFactory([](){
    return Aws::New<Aws::FStream>(
        ALLOCATION_TAG, DOWNLOADED_FILENAME, std::ios_base::out); });

auto getObjectOutcome = s3Client->GetObject(getObjectRequest);
```
### $5 SDK 指标（Metrics）
AWS SDK指标企业支持 (SDK Metrics)使企业用户能够从其主机上的AWS SDK，以及与其共享AWS企业支持的客户那里收集指标。SDK指标能够为AWS企业支持客户提供信息用于加速发现和诊断与AWS服务间的连接问题。

像自动测量技术在每个主机上收集一样，它被通过UDP转发到127.0.0.1 (AKA localhost)上--CloudWatch代理汇聚这些数据并把它们发送至SDK指标服务。因此，为了收到指标，CloudWatch需要被加入到你的实例中。

下面的步骤将为一个使用AWS SDK for C++的客户端应用设立SDK指标，该指标从属于一个运行running Amazon Linux的Amazon EC2实例。如果你在配置AWS SDK for C++是开启了它，SDK指标在你的产品环境中也是可用的。

为了利用SDK指标，运行最新版本的CloudWatch代理。参见Amazon CloudWatch用户指南中的[为SDK指标配置CloudWatch代理](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Configure-CloudWatch-Agent-SDK-Metrics.html)以获得更多信息。

为开发工具包指标配置 CloudWatch 代理，请遵从以下指令：
1. 安装最新版本开发工具包
2. 将你的项目运行于一个Amazon EC2主机或一个本地环境
3. 创建一个应用使用AWS SDK for C++ 客户端访问AWS服务。
4. 在EC2实例或本地环境安装CloudWatch代理
5. 授权SDK指标手机和发送指标
6. 为AWS SDK for C++ 启用SDK指标
#### 为开发工具包启用SDK指标
缺省地，SDK指标使用端口号31000并被禁用。
```
//default values
 [
     'enabled' => false,
     'port' => 31000,
 ]
```
启用SDK指标与配置使用AWS服务的凭证是独立的。

你可以通过设置环境变量或使用AWS共享配置文件的方式来启用SDK指标。
- 选项1： 使用环境变量
   如果AWS_CSM_ENABLED没被设置，SDK将检查由环境变量AWS_PROFILE指定的剖面文件（profile）来决定是否开启SDk指标。缺省地，它被设为false。

   为了开启SDK指标，添加如下环境变量：
   ```
   export AWS_CSM_ENABLED=true
   ```
   > **注意**：开启SDK指标并没有配置你使用AWS服务的凭证
- 选项2： AWS共享配置文件
   如果环境变量中没有CSM相关设置，SDK将会查询你的缺省AWS剖面文件字段。如果AWS_DEFAULT_PROFILE被设置为非缺省文件，更新该文件。为了开启SDK指标，在~/.aws/config中添加csm_enabled设置。
   ```
   [default]
   csm_enabled = true

   [profile aws_csm]
   csm_enabled = true
   ```
   > **注意**： 开启SDK指标与配置你使用AWS服务的凭证是独立地。你可以使用一个独立的文件来授权。
#### 更新CloudWatch代理
为了使对端口的更改生效，你需要设置值并重启当前活跃的AWS工作（jobs）。
- 选项1： 使用环境变量
   大多数服务使用缺省端口。但如果你的服务需要一个唯一端口ID，在环境变量中添加AWS_CSM_PORT=[port_number]。
   ```
   export AWS_CSM_ENABLED=true
   export AWS_CSM_PORT=1234
   ```
- 选项2： AWS共享配置文件
   大多数服务使用缺省端口。但如果你的服务需要一个唯一端口ID，在~/.aws/config中添加csm_port = [port_number]。
   ```
   [default]
   csm_enabled = false
   csm_port = 1234

   [profile aws_csm]
   csm_enabled = false
   csm_port = 1234
   ```
- **重启SDK指标**

   为了重启一个job，运行以下命令：
   ```
   amazon-cloudwatch-agent-ctl –a stop;
   amazon-cloudwatch-agent-ctl –a start;
   ```
#### 禁用SDK指标
为了禁用SDK指标，在环境变量，或者在AWS共享配置文件~/.aws/config中设置csm_enabled为false。然后重启你的CloudWatch以使你的更改生效。

- **环境变量**
   ```
   export AWS_CSM_ENABLED=false
   ```
   
- **AWS共享配置文件**
   从AWS贡献配置文件~/.aws/config中移除csm_enabled。
   > **注意**： 环境变量覆盖共享配置文件设置。如果SDK指标在环境变量中开启，那么SDK指标维持开启。
   ```
   [default]
   csm_enabled = false

   [profile aws_csm]
   csm_enabled = false
   ```

   为了禁用SDK指标，使用下面的命令停止CloudWatch代理：
   ```
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop && echo "Done"
   ```

   如果你使用了CloudWatch其他的特性，使用下面的命令来重启CloudWatch代理：
   ```
   amazon-cloudwatch-agent-ctl –a start;
   ```

   为了重启一个job，运行以下命令：
   ```
   amazon-cloudwatch-agent-ctl –a stop;
   amazon-cloudwatch-agent-ctl –a start;
   ```
#### SDK指标的定义
你可以使用下面的SDK指标描述来解释你的结果。基本上，这些指标在日常商业评审中在与你的技术经理审核（review）是是可用的。AWS支持团队和你的技术经理有权限访问SDK指标数据，这能帮助你解决很多问题（cases），但如果你发现数据混淆或不是期望的，但并没有对你的应用的性能造成负面影响，最好在计划的商业评审中审核这些数据。

指标|定义|如何使用它
--|--|--
CallCount|你的代码中无论成功或失败调用API的次数|把它作为一个基线与其它指标如错误，限流关联起来
ClientErrorCount|带有客户端错误(4xx HTTP返回码)的API调用次数。例如，限流导致的访问拒绝，S3存储桶不存在，无效参数值等|除了某些限流导致的错误，支个指标能够指示你的应用代码需要修复。
ConnectionErrorCount|由于与AWS服务连接错误导致时代的API调用数|使用这个指标来判断是你的应用代码问题还是你的基础设施问题。高ConnectionErrorCount值也有可能和API调用超时设置太短有关。
EndToEndLatency|你的应用代码利用AWS SDK所费总时间，包括重试。换句话说，不管经过重试成功，或是马上由于不明原因失败|判断你的API滴啊用对你的整体延迟的贡献率。超过期待的高延迟可能由网络，防火墙，或者其它配置设置导致，也有可能有SDK重试导致。
ServerErrorCount|带有服务端错误(5xx HTTP返回码)的API调用次数。典型地，这些错误由AWS服务产生。|判断SDK错误或重试原因。这个指标并不总是指示AWS服务错误，一些AWS团队已经澄清延迟作为HTTP503返回码。
ThrottleCount|有AWS服务限流导致的API调用失败次数|使用这个指标来评价你的应用是否已经达到限流阀；也可用于判定应用重试或延迟的原因。考虑通过窗口分布化你的调用而非打包你的调用。
## 第三章 使用SDK
这一节介绍AWS SDK for C++的一般性用法，包含SDK入门篇不曾覆盖的内容。

关于特定服务相关的代码示例，请参见[AWS SDK for C++ Code Examples.](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/programming-services.html)。
### $1 服务的客户端类
C++开发工具包（AWS SDK for C++）包含了访问AWS服务的客户端类。每个客户端支持一个特定的AWS服务。例如，S3Client提供了访问AWS
S3服务的借口。

客户端类的命名空间遵从Aws::Service::ServiceClient的规范。例如，IAM的客户端类是Aws::IAM::IAMClient，AWS S3客户端类是Aws::S3::S3Client。

所有AWS服务的客户端类是线程安全的。

当实例化一个客户端类时，AWS凭证必须提供。关于凭证的更多信息，请参见[提供AWS凭证](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html)。
### $2 工具模块
C++开发工具包（AWS SDK for C++）包含了许多[工具模块](https://sdk.amazonaws.com/cpp/api/LATEST/namespace_aws_1_1_utils.html)来减少使用工具包开发应用的复杂性。
- HTTP栈
   一个HTTP栈提供了连接池，是线程安全的，可根据你的需要复用。更多信息，请参阅[AWS客户端配置](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/client-config.html)

   Headers|[/aws/core/http/](https://github.com/aws/aws-sdk-cpp/tree/master/aws-cpp-sdk-core/include/aws/core/http)
   --|--
   API Documentation|[Aws::Http](https://sdk.amazonaws.com/cpp/api/LATEST/namespace_aws_1_1_http.html)
- 字符串工具
   核心字符串功能，如trim, lowercase，与数字的转换等。

   Headers|[aws/core/utils/StringUtils.h](https://github.com/aws/aws-sdk-cpp/tree/master/aws-cpp-sdk-core/include/aws/core/utils/StringUtils.h)
   --|--
   API Documentation|[Aws::Utils::StringUtils](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_utils_1_1_string_utils.html)
- 哈希工具
   哈希函数例如SHA256, MD5, Base64, 和 SHA256_HMAC。

   Headers|[aws/core/utils/HashingUtils.h](https://github.com/aws/aws-sdk-cpp/tree/master/aws-cpp-sdk-core/include/aws/core/utils/HashingUtils.h)
   --|--
   API Documentation|[Aws::Utils::HashingUtils](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_utils_1_1_hashing_utils.html)
- JSON解析器
   一个全功能且轻量级JSON解析器（JsonCpp的浅封装）

   Headers|[/aws/core/utils/json/JsonSerializer.h](https://github.com/aws/aws-sdk-cpp/tree/master/aws-cpp-sdk-core/include/aws/core/utils/json/JsonSerializer.h)
   --|--
   API Documentation|[Aws::Utils::Json::JsonValue](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_utils_1_1_json_1_1_json_value.html)
- XML解析器
   一个轻量级XML解析库（tinyxml2的浅封装），[RAII模式](http://en.cppreference.com/w/cpp/language/raii)已经被添加进接口中。

   Headers|[/aws/core/utils/xml/XmlSerializer.h](https://github.com/aws/aws-sdk-cpp/tree/master/aws-cpp-sdk-core/include/aws/core/utils/xml/XmlSerializer.h)
   --|--
   API Documentation|[Aws::Utils::Xml](https://sdk.amazonaws.com/cpp/api/LATEST/namespace_aws_1_1_utils_1_1_xml.html)
### $3 内存管理
AWS SDK for C++以库的形式提供了分配和释放内存的方式。
> **注意**：用户内存管理只有在你使用某种库时才可用，这种库是在定义了编译期常量AWS_CUSTOM_MEMORY_MANAGEMENT的情况下构建而得。
>  
> **注意**：如果你的应用连接了没有定义编译期常量的库，全局内存管理函数比如InitializeAWSMemorySystem将不会工作；全局new和delete将会被使用。

关于更多编译期常量，请参阅[标准模板库与AWS字符串与向量](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/memory-management.html#stl-and-aws-strings-and-vectors)。
#### 分配及释放内存
1. 继承MemorySystemInterface：aws/core/utils/memory/MemorySystemInterface.h
    ```
    class MyMemoryManager : public Aws::Utils::Memory::MemorySystemInterface
   {
   public:
       // ...
       virtual void* AllocateMemory(
           std::size_t blockSize, std::size_t alignment,
           const char *allocationTag = nullptr) override;
       virtual void FreeMemory(void* memoryPtr) override;
   };
    ```
    > **注意**：必要时你可以改变AllocateMemory的签名。
2. 通过滴啊用InitializeAWSMemorySystem来把一个子类的实例安装为用户内存管理器，这个应该在你的应用开始处发生。例如，在你的main()函数：
     ```
     int main(void)
    {
       MyMemoryManager sdkMemoryManager;
       Aws::Utils::Memory::InitializeAWSMemorySystem(sdkMemoryManager);
       // ... do stuff
       Aws::Utils::Memory::ShutdownAWSMemorySystem();
       return 0;
    }
     ```
3. 在退出前，调用ShutdownAWSMemorySystem（前面的代码里已经出现过，但在这里重复一下）：
    ```
    Aws::Utils::Memory::ShutdownAWSMemorySystem();
    ```
#### 标准模板库与AWS字符串与向量
当初始化一个内存管理器时，AWS SDK for C++将延迟内存分配和释放至内存管理器。如果内存管理器不存在，SDK将使用全局new和delete。

如果你使用自定义STL分配器，你必须改变所有STL对象类型的签名，以此来匹配分配策略。由于STL在SDK的实现及接口中被大量使用，一个简单的方式将禁止将缺省STL对象直接传递到SDK及STL内存分配的控制中。可选地，一种混合方式--内部使用自定义分配器，允许接口定义中的标准和自定义STL对象--可能会使得调查内存问题更加困难。

解决方案是使用内存系统的编译期常量AWS_CUSTOM_MEMORY_MANAGEMENT来控制SDK使用哪种STL类型。

如果编译期常量开启，这些类型将被解析为连接到AWS内存系统的自定义分配器的STL类型。

如果编译期常量关闭，所有的Aws::*类型将被解析为对应的缺省std::* 类型。

**来自SDK文件AWSAllocator.h的示例代码**
```
#ifdef AWS_CUSTOM_MEMORY_MANAGEMENT
template< typename T >
class AwsAllocator : public std::allocator< T >
{
   ... definition of allocator that uses AWS memory system
};
#else
template< typename T > using Allocator = std::allocator<T>;
#endif
```
在上面的例子中，AwsAllocator可以使一个自定义分配器或者缺省分配器，依赖于编译器常量。

**来自SDK文件AWSVector.h的示例代码**
```
template<typename T> using Vector = std::vector<T, Aws::Allocator<T>>;
```
在示例代码中，我们定义了Aws::* 类型。

如果编译期常量开启，这个类型被映射到一个使用自定义内存分配和AWS内存系统的向量（vector）。

如果编译期常量关闭，这个类型将被映射到携有缺省类型参数的常规std::vector。

SDK中执行内存分配的所有std:: types使用了类型别名，比如容器，字符流，字符缓冲。AWS SDK for C++使用了这些类型。
#### 遗留问题
你可以在SDK中控制内存分配；但是，STL类型仍通过从字符串参数到模型对象的initialize和set方法统治着公共接口。如果你不想使用STL，取而代之使用字符串和容器类型，当你做一次服务调用时你将不得不创建许多临时变量。

为了移除使用非STL做服务调用时产生的临时变量和分配，我们已经实现了以下方法：
+ 每个接受字符串的Init/Set 方法都有一个接受const char*的重载版本。
+ 每个接受容器(map/vector)的Init/Set 方法都有一个add的变体能够接受单一一项值。
+ 每个接受二进制数据的Init/Set 方法都有一个接受指向数据的指针及其长度的重载版本
+ （可选地）每个接受字符串的Init/Set 方法都有一个接受非0结尾的const char*及其长度值的重载版本。
#### 本地SDK开发及内存控制
在SDK代码中遵从以下规则：
+ 不要使用new和delete，取而代之使用Aws::New<> and Aws::Delete<> 
+ 不要使用new[]和delete[]，取而代之使用Aws::NewArray<> and Aws::DeleteArray<> 
+ 不要使用std::make_shared；使用Aws::MakeShared
+ 使用Aws::UniquePtr用作指向单一对象的唯一指针；使用Aws::MakeUnique创建唯一指针
+ 使用Aws::UniqueArray 用作指向一个数组对象的唯一指针；使用Aws::MakeUniqueArray来创建唯一指针
+ 不要直接使用STL容器；使用 Aws:: typedefs中的一个或加入一个对你期望使用的容器的typedef，例如：`Aws::Map<Aws::String, Aws::String> m_kvPairs;`
+ 对任何传递进SDK，有SDK管理的外部指针使用shared_ptr。你必须使用一个匹配对象分配的析构策略来初始化共享指针。如果不期望SDK清理指针，可以使用原始指针。
### $4 日志
AWS SDK for C++包含你可配置的日志支持。当初始化日志系统时，你可以控制过滤级别以及日志目标（可以用一个配置的前缀名或流名来过滤）。产生的带前缀日志文件每小时产生一个新文件，以此来归档或删除日志文件。
```
Aws::Utils::Logging::InitializeAWSLogging(
    Aws::MakeShared<Aws::Utils::Logging::DefaultLogSystem>(
        "RunUnitTests", Aws::Utils::Logging::LogLevel::Trace, "aws_sdk_"));
```
如果你没有在你的应用中调用InitializeAWSLogging，SDK将不会记录任何日志。如果你使用了日志，请勿忘记在在程序结尾处利用ShutdownAWSLogging关闭日志。
```
Aws::Utils::Logging::ShutdownAWSLogging();
```
集成日志的例子：
```
#include <aws/external/gtest.h>

#include <aws/core/utils/memory/stl/AWSString.h>
#include <aws/core/utils/logging/DefaultLogSystem.h>
#include <aws/core/utils/logging/AWSLogging.h>

#include <iostream>

int main(int argc, char** argv)
{
    Aws::Utils::Logging::InitializeAWSLogging(
        Aws::MakeShared<Aws::Utils::Logging::DefaultLogSystem>(
            "RunUnitTests", Aws::Utils::Logging::LogLevel::Trace, "aws_sdk_"));
    ::testing::InitGoogleTest(&argc, argv);
    int exitCode = RUN_ALL_TESTS();
    Aws::Utils::Logging::ShutdownAWSLogging();
    return exitCode;
}
```
### $5 错误处理
AWS SDK for C++不使用异常；但是，你可以在你的代码中使用异常。每个服务的客户端将返回一个输出对象，包含一个结果及一个错误码：
```
bool CreateTableAndWaitForItToBeActive()
{
  CreateTableRequest createTableRequest;
  AttributeDefinition hashKey;
  hashKey.SetAttributeName(HASH_KEY_NAME);
  hashKey.SetAttributeType(ScalarAttributeType::S);
  createTableRequest.AddAttributeDefinitions(hashKey);
  KeySchemaElement hashKeySchemaElement;
  hashKeySchemaElement.WithAttributeName(HASH_KEY_NAME).WithKeyType(KeyType::HASH);
  createTableRequest.AddKeySchema(hashKeySchemaElement);
  ProvisionedThroughput provisionedThroughput;
  provisionedThroughput.SetReadCapacityUnits(readCap);
  provisionedThroughput.SetWriteCapacityUnits(writeCap);
  createTableRequest.WithProvisionedThroughput(provisionedThroughput);
  createTableRequest.WithTableName(tableName);

  CreateTableOutcome createTableOutcome = dynamoDbClient->CreateTable(createTableRequest);
  if (createTableOutcome.IsSuccess())
  {
     DescribeTableRequest describeTableRequest;
     describeTableRequest.SetTableName(tableName);
     bool shouldContinue = true;
     DescribeTableOutcome outcome = dynamoDbClient->DescribeTable(describeTableRequest);

     while (shouldContinue)
     {
         if (outcome.GetResult().GetTable().GetTableStatus() == TableStatus::ACTIVE)
         {
            break;
         }
         else
         {
            std::this_thread::sleep_for(std::chrono::seconds(1));
         }
     }
     return true;
  }
  else if(createTableOutcome.GetError().GetErrorType() == DynamoDBErrors::RESOURCE_IN_USE)
  {
     return true;
  }

  return false;
}
```
## 第四章 [代码示例](https://github.com/wbb1975/blogs/blob/master/aws/aws_c++_sdk_sample_codes.md)
## 第五章 规范
- 不要直接修改产生的客户端。应该修改产生器。直接在Core，Scripts，以及高阶接口中是可接受的。
- 不要到处使用静态变量（statics)，这容易导致用户内存管理器奔溃且无处可寻
- 使用四个空格的缩进，永远不要使用tab键
- 不要使用异常。。。再次强调，不要使用异常。如果你需要使用一个返货错误码，请使用Outcome模式返回数据。
- 经常考虑平台独立性。如果不可能，在其上加上一层好的抽象并使用抽象工厂模式。
- 使用RAII，Aws::New 和 Aws::Delete应该仅仅在构造函数以及析构函数中出现
- 确信遵从第5#规则
- 尽可能使用C++11标准
- 使用大写开头的驼峰模式（UpperCamelCase）与类型和函数定义。对成员变量使用m_*模式。不要使用静态变量。如果必须，使用UpperCammelCase模式用于静态变量。
- 总是使用const，并清醒意识到何处使用右值。我们不能够信任编译器能够一致地优化各种构建，所以请显示指出
- 命名空间名字应该遵从UpperCammelCase模式。永远不要把using namespace语句放到头文件中，除非它被放到class内部。在cpp文件中可以放置using namespace语句。
- 使用enum class而非enum
- 尽量使用#pragma once来做头文件保护
- 尽可能使用前向申明
- 使用nullptr而非NULL

# 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)
- [CMake tutorial](https://cmake.org/cmake-tutorial/)
- [How to build AWS C++ SDK on Windows](https://www.megalacant.com/techblog/2019/02/28/building-aws-cpp-sdk-windows.html)
- [AWS SDK for C++ API Reference](https://sdk.amazonaws.com/cpp/api/LATEST/index.html)
- [java 1.8+](http://openjdk.java.net/install/)
- [AWS SDK for C++](https://github.com/aws/aws-sdk-cpp)