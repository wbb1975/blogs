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
3. 
