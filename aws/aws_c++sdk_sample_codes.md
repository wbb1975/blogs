## 第四章 代码示例
本节包括使用AWS SDK for C++开发特定AWS服务的实例，指南，小窍门。
### $1 Amazon CloudWatch 示例
### $2 Amazon DynamoDB 示例
### $3 Amazon EC2 示例
### $4 Amazon IAM 示例
### $5 Amazon S3 示例
亚马逊简单存储服务（Amazon S3）是服务于互联网的存储。你可使用下面的例子利用 AWS SDK for C++对Amazon S3编程。

>  **注意**： 只有对展示技术有用的代码片段在这里提供，[完整的代码可见于Github](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp)，你可以从那里下载一个文件，或者克隆整个代码仓库，构建并运行它们。
#### 创建，列出，删除存储桶
每个Amazon S3上的对象或文件必须驻留在一个存储桶中，后者代表对象目录。每个存储桶有AWS生态中全局唯一的名字标识。对于存储桶的详细信息及其配置，请参阅Amazon S3开发者指南中的[使用 Amazon S3 存储桶](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html)。

> **注意**：最佳实践
> 我们推荐在你的Amazon S3存储桶上开启[AbortIncompleteMultipartUpload](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUTlifecycle.html)生命周期规则。

> 这个规则指示Amazon S3在多部上传（multipart uploads）在启动后，在一个指定时间内不能完成时放弃该操作。当时间限制超过时，Amazon S3放弃上传并删除掉已经上传的不完整的文件。 

> **注意**：代码片段假设你理解[AWS SDK for C++入门](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/getting-started.html)的内容，并已经依据[提供AWS凭证](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/credentials.html)中的内容配置好了缺省凭证。
##### 创建存储桶
使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的CreateBucket方法，传给它一个CreateBucketRequest和存储桶的名字。缺省地，存储桶在us-east-1 (N. Virginia)区域创建。下面的代码演示了如何在任意区域创建存储桶。

**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/CreateBucketRequest.h>
```
**代码**
```
bool create_bucket(const Aws::String &bucket_name,
    const Aws::S3::Model::BucketLocationConstraint &region = Aws::S3::Model::BucketLocationConstraint::us_east_1)
{
    // Set up the request
    Aws::S3::Model::CreateBucketRequest request;
    request.SetBucket(bucket_name);

    // Is the region other than us-east-1 (N. Virginia)?
    if (region != Aws::S3::Model::BucketLocationConstraint::us_east_1)
    {
        // Specify the region as a location constraint
        Aws::S3::Model::CreateBucketConfiguration bucket_config;
        bucket_config.SetLocationConstraint(region);
        request.SetCreateBucketConfiguration(bucket_config);
    }

    // Create the bucket
    Aws::S3::S3Client s3_client;
    auto outcome = s3_client.CreateBucket(request);
    if (!outcome.IsSuccess())
    {
        auto err = outcome.GetError();
        std::cout << "ERROR: CreateBucket: " << 
            err.GetExceptionName() << ": " << err.GetMessage() << std::endl;
        return false;
    }
    return true;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/create_bucket.cpp)。
##### 列出存储桶
使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的ListBucket方法。如果成功，返回一个ListBucketOutcome对象，它包含一个ListBucketResult对象。

使用ListBucketResult对象的GetBuckets得到一个Bucket对象的列表，包含你的账号下每个Amazon S3存储桶的信息。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/Bucket.h>
```
**代码**
```
Aws::S3::S3Client s3_client;
auto outcome = s3_client.ListBuckets();

if (outcome.IsSuccess())
{
    std::cout << "Your Amazon S3 buckets:" << std::endl;

    Aws::Vector<Aws::S3::Model::Bucket> bucket_list =
        outcome.GetResult().GetBuckets();

    for (auto const &bucket : bucket_list)
    {
        std::cout << "  * " << bucket.GetName() << std::endl;
    }
}
else
{
    std::cout << "ListBuckets error: "
        << outcome.GetError().GetExceptionName() << " - "
        << outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/list_buckets.cpp)。
##### 删除存储桶
使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的DeleteBucket方法，传给它一个DeleteBucketRequest和存储桶的名字。存储桶必须为空，否则返回错误。

**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/DeleteBucketRequest.h>
```
**代码**
```
Aws::Client::ClientConfiguration config;
config.region = user_region;
Aws::S3::S3Client s3_client(config);

Aws::S3::Model::DeleteBucketRequest bucket_request;
bucket_request.SetBucket(bucket_name);

auto outcome = s3_client.DeleteBucket(bucket_request);

if (outcome.IsSuccess())
{
    std::cout << "Done!" << std::endl;
}
else
{
    std::cout << "DeleteBucket error: "
        << outcome.GetError().GetExceptionName() << " - "
        << outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/delete_bucket.cpp)。
#### 操作存储桶
#### 管理Amazon S3访问权限
#### 使用存储桶策略来管理对Amazon S3存储桶的访问
#### 将Amazon S3存储桶配置为一个站点
### $6 Amazon SQS 示例
### $7 异步方法

## 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)
- [CMake tutorial](https://cmake.org/cmake-tutorial/)
- [How to build AWS C++ SDK on Windows](https://www.megalacant.com/techblog/2019/02/28/building-aws-cpp-sdk-windows.html)
- [AWS SDK for C++ API Reference](https://sdk.amazonaws.com/cpp/api/LATEST/index.html)