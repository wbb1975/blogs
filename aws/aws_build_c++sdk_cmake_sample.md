# 实例Cmake脚本使用CPP SDK来编译你的项目
利用最近提交的find_package的COMPONENTS参数，用户可以以一种简单的方式把AWS SDK 与CPP应用集成。
## 基本用法
```
find_package(AWSSDK REQUIRED COMPONENTS transfer s3-encryption dynamodb)
target_link_libraries(target ${AWSSDK_LINK_LIBRARIES})
```

现在用户：
- 不需要为每一个组件添加"aws-cpp-sdk-""
- 不用担心高级别依赖，比如，对s3-encryption，你无须了解s3-encryption依赖于s3, kms 和 core，也无需把这个告诉Cmake。
- find_package之后，一个变量AWSSD_LINK_LIBRARIES用于帮用户简单地链接（AWS库）。

如果你想一次找到多个组件，并且不同的目标链接不同的组件，AWSSDK_LINK_LIBRARIES不再合适，你需要手动添加他们并理解其依赖链：
```
find_package(AWSSDK REQUIRED COMPONENTS transfer s3-encryption dynamodb)
target_link_libraries(A aws-cpp-sdk-core)
target_link_libraries(B aws-cpp-sdk-transfer aws-cpp-sdk-s3 aws-cpp-sdk-core) # transfer depends on s3, and s3 depends on core
target_linl_libraries(C aws-cpp-sdk-s3-encryption aws-cpp-sdk-kms aws-cpp-sdk-s3 aws-cpp-sdk-core)
```
如果你想对不同的目标连接不同的静态编译组件，你也需要手动添加平台依赖，但我们已经定义了一个变量AWSSDK_PLATFORM_DEPS，比如：
```
find_package(AWSSD REQUIRED COMPONENTS transfer s3-encryption dynamodb)
target_link_libraries(A aws-cpp-sdk-core ${AWSSDK_PLATFORM_DEPS})
```
# 参考
- [Example CMake Scripts to Build Your Project Against the CPP SDK](https://github.com/aws/aws-sdk-cpp/wiki/Example-CMake-Scripts-to-Build-Your-Project-Against-the-CPP-SDK)