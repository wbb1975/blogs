## 第四章 代码示例
本节包括使用AWS SDK for C++开发特定AWS服务的实例，指南，小窍门。
### $1 Amazon CloudWatch 示例
### $2 Amazon DynamoDB 示例
### $3 Amazon EC2 示例
### $4 Amazon IAM 示例
### $5 Amazon S3 示例
亚马逊简单存储服务（Amazon S3）是服务于互联网的存储。你可使用下面的例子利用 AWS SDK for C++对Amazon S3编程。

>  **注意**： 只有对展示技术有用的代码片段在这里提供，[完整的代码可见于Github](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp)，你可以从那里下载一个文件，或者克隆整个代码仓库，构建并运行它们。
#### 5.1 创建，列出，删除存储桶
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
#### 5.2 操作存储桶
一个Amazon S3 对象代表一个文件，一个数据的集合。一个对象必须驻留在一个[存储桶](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/examples-s3-buckets.html)中。

> **注意**：代码片段假设你理解[AWS SDK for C++入门](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/getting-started.html)的内容，并已经依据[提供AWS凭证](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/credentials.html)中的内容配置好了缺省凭证。
##### 上传对象
使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的PutObject方法，传给它一个存储桶的名字，键的名字以及上传的文件。存储桶必须存在，否则将返回错误。

**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/PutObjectRequest.h>
#include <iostream>
#include <fstream>
#include <sys/stat.h>
```

**代码**
```
Aws::S3::S3Client s3_client(clientConfig);
Aws::S3::Model::PutObjectRequest object_request;

object_request.SetBucket(s3_bucket_name);
object_request.SetKey(s3_object_name);
const std::shared_ptr<Aws::IOStream> input_data = 
    Aws::MakeShared<Aws::FStream>("SampleAllocationTag", 
                                  file_name.c_str(), 
                                  std::ios_base::in | std::ios_base::binary);
object_request.SetBody(input_data);

// Put the object
auto put_object_outcome = s3_client.PutObject(object_request);
if (!put_object_outcome.IsSuccess()) {
    auto error = put_object_outcome.GetError();
    std::cout << "ERROR: " << error.GetExceptionName() << ": " 
        << error.GetMessage() << std::endl;
    return false;
}
return true;
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/put_object.cpp)。
##### 列出对象
为了得到一个存储桶的对象列表，使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的ListObjects方法，传给它一个ListObjectsRequest对象，该对象含有你打算列表其内容的存储桶的名字。

ListObjects方法返回一个ListObjectsOutcome对象，你可以用它获得一个Object实例的列表。

**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/ListObjectsRequest.h>
#include <aws/s3/model/Object.h>
```

**代码**
```
Aws::S3::S3Client s3_client;

Aws::S3::Model::ListObjectsRequest objects_request;
objects_request.WithBucket(bucket_name);

auto list_objects_outcome = s3_client.ListObjects(objects_request);

if (list_objects_outcome.IsSuccess())
{
    Aws::Vector<Aws::S3::Model::Object> object_list =
        list_objects_outcome.GetResult().GetContents();

    for (auto const &s3_object : object_list)
    {
        std::cout << "* " << s3_object.GetKey() << std::endl;
    }
}
else
{
    std::cout << "ListObjects error: " <<
        list_objects_outcome.GetError().GetExceptionName() << " " <<
        list_objects_outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/list_objects.cpp)。
##### 下载对象
使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的GetObject方法，传给它一个GetObjectRequest对象，借助该对象你可以设置存储桶的名字，以及键的名字。GetObject返回一个GetObjectOutcome对象，你可以用它来获取S3对象的数据。

下面的例子从Amazon S3下载一个对象，对象的内容被存在一个局部变量中，第一行的内容在终端上输出。

**包含文件**
```
#include <fstream>
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/GetObjectRequest.h>
```

**代码**
```
// Assign these values before running the program
const Aws::String bucket_name = "BUCKET_NAME";
const Aws::String object_name = "OBJECT_NAME";  // For demo, set to a text file

// Set up the request
Aws::S3::S3Client s3_client;
Aws::S3::Model::GetObjectRequest object_request;
object_request.SetBucket(bucket_name);
object_request.SetKey(object_name);

// Get the object
auto get_object_outcome = s3_client.GetObject(object_request);
if (get_object_outcome.IsSuccess())
{
    // Get an Aws::IOStream reference to the retrieved file
    auto &retrieved_file = get_object_outcome.GetResultWithOwnership().GetBody();


    // Output the first line of the retrieved text file
    std::cout << "Beginning of file contents:\n";
    char file_data[255] = { 0 };
    retrieved_file.getline(file_data, 254);
    std::cout << file_data << std::endl;

    // Alternatively, read the object's contents and write to a file
    const char * filename = "/PATH/FILE_NAME";
    std::ofstream output_file(filename, std::ios::binary);
    output_file << retrieved_file.rdbuf();
   
}
else
{
    auto error = get_object_outcome.GetError();
    std::cout << "ERROR: " << error.GetExceptionName() << ": " 
        << error.GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/get_object.cpp)。
##### 删除对象
为了得到一个存储桶的对象列表，使用[S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的DeleteObject方法，传给它一个DeleteObjectRequest对象，该对象含有你打算删除的存储桶及键的名字。指定的存储桶及键必须存在，否则将返回错误。

**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/DeleteObjectRequest.h>
#include <fstream>
```

**代码**
```
Aws::S3::S3Client s3_client;

Aws::S3::Model::DeleteObjectRequest object_request;
object_request.WithBucket(bucket_name).WithKey(key_name);

auto delete_object_outcome = s3_client.DeleteObject(object_request);

if (delete_object_outcome.IsSuccess())
{
    std::cout << "Done!" << std::endl;
}
else
{
    std::cout << "DeleteObject error: " <<
        delete_object_outcome.GetError().GetExceptionName() << " " <<
        delete_object_outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/delete_object.cpp)。
#### 5.3 管理Amazon S3访问权限
对一个Amazon S3存储桶或对象的访问权限由访问控制列表（ACL）定义。ACL指定了存储桶及对象的所有者以及对其的一系列授权。每个授权指定了一个用户，以及用户对存储桶，对象的访问权限，比如读或写权限。
##### 管理一个对象的访问控制列表
一个对象的访问控制列表可以通过调用S3Client的GetObjectAcl方法来获取。该方法接受对象名及其所属存储桶名作为参数。返回值包括访问控制列表的所有者及一系列授权。

```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/AccessControlPolicy.h>
#include <aws/s3/model/GetObjectAclRequest.h>
#include <aws/s3/model/PutObjectAclRequest.h>
#include <aws/s3/model/Grant.h>
#include <aws/s3/model/Grantee.h>
#include <aws/s3/model/Permission.h>
```

```
// Set up the get request
Aws::S3::S3Client s3_client;
Aws::S3::Model::GetObjectAclRequest get_request;
get_request.SetBucket(bucket_name);
get_request.SetKey(object_name);

// Get the current access control policy
auto get_outcome = s3_client.GetObjectAcl(get_request);
if (!get_outcome.IsSuccess())
{
    auto error = get_outcome.GetError();
    std::cout << "Original GetObjectAcl error: " << error.GetExceptionName()
        << " - " << error.GetMessage() << std::endl;
    return;
}
```

访问控制列表可以以创建新的访问控制列表或修改当前访问控制列表中的授权的方式修改。修改过的访问控制列表被传给PutObjectAcl方法后便可成为新的当前访问控制列表。

下面的代码使用GetObjectAcl访问控制列表并对其添加一个授权。用户或被授权人被给予对象读权限。修改过的访问控制列表被传递给PutObjectAcl方法，使它成为新的当前访问控制列表。更多信息请参见[示例代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/get_put_object_acl.cpp)。
```
// Reference the retrieved access control policy
auto result = get_outcome.GetResult();

// Copy the result to an access control policy object (cannot type cast)
Aws::S3::Model::AccessControlPolicy acp;
acp.SetOwner(result.GetOwner());
acp.SetGrants(result.GetGrants());

// Define and add new grant
Aws::S3::Model::Grant new_grant;
Aws::S3::Model::Grantee new_grantee;
new_grantee.SetID(grantee_id);
new_grantee.SetType(Aws::S3::Model::Type::CanonicalUser);
new_grant.SetGrantee(new_grantee);
new_grant.SetPermission(GetPermission(permission));
acp.AddGrants(new_grant);

// Set up the put request
Aws::S3::Model::PutObjectAclRequest put_request;
put_request.SetAccessControlPolicy(acp);
put_request.SetBucket(bucket_name);
put_request.SetKey(object_name);

// Set the new access control policy
auto set_outcome = s3_client.PutObjectAcl(put_request);
```
##### 管理一个存储桶的访问控制列表
大多数情况下，我们还是更喜欢通过定义存储通策略的方式来设置存储桶的访问权限。但是，存储桶也支持针对访问用户的访问控制列表。

对存储桶的访问控制列表的管理与对象相同。GetBucketAcl方法一个存储桶的当前访问控制列表，并用PutBucketAcl来设置新的访问控制列表。

下面的例子演示了获取以及设置存储桶访问控制列表。更多信息请参见[示例代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/get_put_bucket_acl.cpp)。

```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/AccessControlPolicy.h>
#include <aws/s3/model/GetBucketAclRequest.h>
#include <aws/s3/model/PutBucketAclRequest.h>
#include <aws/s3/model/Grant.h>
#include <aws/s3/model/Grantee.h>
#include <aws/s3/model/Permission.h>
```

```
// Set up the get request
Aws::S3::S3Client s3_client;
Aws::S3::Model::GetBucketAclRequest get_request;
get_request.SetBucket(bucket_name);

// Get the current access control policy
auto get_outcome = s3_client.GetBucketAcl(get_request);
if (!get_outcome.IsSuccess())
{
    auto error = get_outcome.GetError();
    std::cout << "Original GetBucketAcl error: " << error.GetExceptionName()
        << " - " << error.GetMessage() << std::endl;
    return;
}

// Reference the retrieved access control policy
auto result = get_outcome.GetResult();

// Copy the result to an access control policy object (cannot typecast)
Aws::S3::Model::AccessControlPolicy acp;
acp.SetOwner(result.GetOwner());
acp.SetGrants(result.GetGrants());

// Define and add new grant
Aws::S3::Model::Grant new_grant;
Aws::S3::Model::Grantee new_grantee;
new_grantee.SetID(grantee_id);
new_grantee.SetType(Aws::S3::Model::Type::CanonicalUser);
new_grant.SetGrantee(new_grantee);
new_grant.SetPermission(GetPermission(permission));
acp.AddGrants(new_grant);

// Set up the put request
Aws::S3::Model::PutBucketAclRequest put_request;
put_request.SetAccessControlPolicy(acp);
put_request.SetBucket(bucket_name);

// Set the new access control policy
auto set_outcome = s3_client.PutBucketAcl(put_request);
```
#### 5.4 使用存储桶策略来管理对Amazon S3存储桶的访问
#### 5.5 将Amazon S3存储桶配置为一个站点
### $6 Amazon SQS 示例
### $7 异步方法

## 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)
- [CMake tutorial](https://cmake.org/cmake-tutorial/)
- [How to build AWS C++ SDK on Windows](https://www.megalacant.com/techblog/2019/02/28/building-aws-cpp-sdk-windows.html)
- [AWS SDK for C++ API Reference](https://sdk.amazonaws.com/cpp/api/LATEST/index.html)