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
- Visual Studio 2015 or later
- or GNU Compiler Collection (GCC) 4.9 or later
- or Clang 3.3 or later
- A minimum of 4 GB of RAM
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
### $3 使用AWS SKD C++
使用AWS SDK for C++的应用必须初始化它，相似地，应用终止前，SDK必须被停止。两种操作（初始化和停止）都接受配置选项，这些选项将会影响初始化和停止过程以及其后的SDK调用。
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
### $4 用Cmake构建你的程序
[Cmake](https://cmake.org/)是一个创建适合你平台的makefiles，以及管理你的应用依赖的创建（build）工具。这是一个创建及编译AWS SDK for C++项目的简单方式。
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
Cmake需要知道aws-sdk-cpp-config.cmake的位置，如此它才能解析你的应用使用的AWS SDK库。你可以在[构建SDK](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/setup.html)已接种建立的build目录中找到它。

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
#### 安卓适用的CMake变量和选项
### $2 AWS客户端配置
### $3 覆写你的HTTP客户端
### $4 控制HttpClient 和 AWSClient的IO流
### $5 SDK Metrics
## 第三章 使用SDK
这一节介绍AWS SDK for C++的一般性用法，包含SDK入门篇不曾覆盖的内容。

关于特定服务相关的代码示例，请参见[AWS SDK for C++ Code Examples.](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/programming-services.html)。
### $1 服务客户端类
### $2 工具模块
### $3 内存管理
### $4 日志
### $5 错误处理
## 第四章 代码示例
本节包括使用AWS SDK for C++开发特定AWS服务的实例，指南，小窍门。
### $1 Amazon CloudWatch 示例
### $2 Amazon DynamoDB 示例
### $3 Amazon EC2 示例
### $4 Amazon IAM 示例
### $5 Amazon S3 示例
### $6 Amazon SQS 示例
### $7 异步方法

# 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)
- [CMake tutorial](https://cmake.org/cmake-tutorial/)