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
## 入门（Getting Started ）
### 设立AWS SKD C++
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

### 提供AWS证书（Providing AWS Credentials）
### 使用AWS SKD C++
### 用Cmake创建你的程序
## 配置SDK
## 使用SDK
## 代码示例

# 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)