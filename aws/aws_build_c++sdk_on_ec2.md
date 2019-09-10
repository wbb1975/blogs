# 在EC2上从源代码编译SDK
## 如何一步一步在一个基于Ubuntu Server的EC2实例上编译和安装AWS C++ SDK
在这个指南中我们将使用"Ubuntu Server 16.04 LTS" EC2镜像。
1. 启动这个EC2实例并通过ssh登陆进去
2. 我们第一间要做的事情就是安装GCC (g++) 和 CMake
    ```
    $ sudo apt install g++ cmake -y
    ```
   在这个服务器版本上，zlib, OpenSSL 和 CURL 的开发头文件并未安装，因此我们需要安装它们：
   ```
   $ sudo apt install zlib1g-dev libssl-dev libcurl4-openssl-dev -y
    ```
    
    在这个镜像中git已经安装，因此我们可以把SDK克隆下来，并在其中创建build目录。
   ```
   $ git clone https://github.com/aws/aws-sdk-cpp.git
   $ mkdir build
   $ cd build
   ```
3. 下一步我们需要运行CMake脚本来配置和产生最终的Makefile。
   在这一步中有一些选项可以传递给CMake，所以参考README可得到完整选项列表。本指南只编译Release模式的S3共享库。我们将不指定安装路径前缀，所以CMake将使用缺省安装路径/usr/local/lib。
   ```
   $ cmake .. -DBUILD_ONLY=s3 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=ON
   ```
   以下是我的输出（你的输出可能会稍有不同）：
   ```
   -- Found Git: /usr/bin/git (found version "2.7.4")
   -- TARGET_ARCH not specified; inferring host OS to be platform compilation target
   -- Building AWS libraries as shared objects
   -- Generating linux build config
   -- Building project version: 1.4.65
   -- The CXX compiler identification is GNU 5.4.0
   -- Check for working CXX compiler: /usr/bin/c++
   -- Check for working CXX compiler: /usr/bin/c++ -- works
   -- Detecting CXX compiler ABI info
   -- Detecting CXX compiler ABI info - done
   -- Detecting CXX compile features
   -- Detecting CXX compile features - done
   -- Found ZLIB: /usr/lib/x86_64-linux-gnu/libz.so (found version "1.2.8")
   --   Zlib include directory: /usr/include
   --   Zlib library: /usr/lib/x86_64-linux-gnu/libz.so
   -- Encryption: Openssl
   -- Found OpenSSL: /usr/lib/x86_64-linux-gnu/libssl.so;/usr/lib/x86_64-linux-gnu/libcrypto.so (found version "1.0.2g")
   --   Openssl include directory: /usr/include
   --   Openssl library: /usr/lib/x86_64-linux-gnu/libssl.so;/usr/lib/x86_64-linux-gnu/libcrypto.so
   -- Http client: Curl
   -- Found CURL: /usr/lib/x86_64-linux-gnu/libcurl.so (found version "7.47.0")
   --   Curl include directory: /usr/include
   --   Curl library: /usr/lib/x86_64-linux-gnu/libcurl.so
   -- Performing Test HAVE_ATOMICS_WITHOUT_LIBATOMIC
   -- Performing Test HAVE_ATOMICS_WITHOUT_LIBATOMIC - Success
   -- Considering s3
   -- The C compiler identification is GNU 5.4.0
   -- Check for working C compiler: /usr/bin/cc
   -- Check for working C compiler: /usr/bin/cc -- works
   -- Detecting C compiler ABI info
   -- Detecting C compiler ABI info - done
   -- Detecting C compile features
   -- Detecting C compile features - done
   -- Updating version info to 1.4.65
   -- Custom memory management enabled; stl objects now using custom allocators
   -- Configuring done
   -- Generating done
   -- Build files have been written to: /home/ubuntu/aws-sdk-cpp/build
   ```
4. 最后一步是编译，链接和安装库
　这一步可能得花上一些时间，取决于你打算安装多少AWS服务以及你运行的EC2服务器类型，没准可以抽空喝点咖啡。
    ```
    $ make
    $ sudo make install
    ```
    这是所有的步骤。
5. 最终，可以用一个示例程序来测试是否一切OK，它简单地从S3下载一个文件到本地主机上。
   ```
   // program.cpp
   #include <aws/core/Aws.h>
   #include <aws/core/client/ClientConfiguration.h>
   #include <aws/core/auth/AWSCredentialsProviderChain.h>
   #include <aws/core/utils/logging/LogLevel.h>
   #include <aws/s3/S3Client.h>
   #include <aws/s3/model/GetObjectRequest.h>
   #include <iostream>
   #include <fstream>
   #include <memory>

   using namespace Aws;

   int main(int argc, char *argv[])
   {
       if (argc < 5) {
           std::cout << " Usage: s3sample <region-endpoint> <s3 bucket> <s3 key> <local destination path>\n"
                  << "Example: s3sample s3.us-west-2.amazonaws.com MyBucket MyKey MyLocalFile.pdf" << std::endl;
           return 0;
     }

    SDKOptions options;
    options.loggingOptions.logLevel = Utils::Logging::LogLevel::Error;
    InitAPI(options);
    {
        Client::ClientConfiguration config;
        config.endpointOverride = argv[1];
        config.scheme = Http::Scheme::HTTPS;

        S3::S3Client client(config);

        S3::Model::GetObjectRequest request;
        request.WithBucket(argv[2]).WithKey(argv[3]);
        request.SetResponseStreamFactory([argv] { return new std::fstream(argv[4], std::ios_base::out); });

        auto outcome = client.GetObject(request);
        if (outcome.IsSuccess()) {
            std::cout << "Completed!" << std::endl;
        } else {
            std::cout << "Failed with error: " << outcome.GetError() << std::endl;
        }
    }

    ShutdownAPI(options);
    return 0;
    }
   ```
   它的CMake脚本CMakeLists.txt：
    ```
    cmake_minimum_required(VERSION 3.5)
   project(s3sample)
   find_package(AWSSDK REQUIRED COMPONENTS s3)
   set(CMAKE_CXX_STANDARD 11)
   add_executable(s3sample "program.cpp")
   # list all deps for static linking
   target_link_libraries(s3sample ${AWSSDK_LINK_LIBRARIES})
   target_compile_options(s3sample PRIVATE "-Wall" "-Werror")
    ```
    选中一个你中意的地方为你的示例应用程序建立一个目录，然后编译并运行它。
    ```
    $ cd ~
   $ mkdir s3sample
   $ vim program.cpp
   $ vim CMakeLists.txt
   $ mkdir build; cd build; cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
   $ make
   $ export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
   $ ./s3sample s3.us-west-2.amazonaws.com SomeBucket SomeKey ALocalFile
    ```

    LD_LIBRARY_PATH这一步是必须的，因为/usr/local/lib缺省情况下并不被包含在内（安全原因）。
# 参考
- [Building the SDK from source on EC2](https://github.com/aws/aws-sdk-cpp/wiki/Building-the-SDK-from-source-on-EC2)