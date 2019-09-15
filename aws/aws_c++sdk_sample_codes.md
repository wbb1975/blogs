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
你可以通过设置，获取，删除桶策略的方式等操作来管理对Amazon S3 存储桶的访问。

> **注意**：代码片段假设你理解[AWS SDK for C++入门](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/getting-started.html)的内容，并已经依据[提供AWS凭证](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html)
##### 设置一个桶策略
对一个特定的S3存储桶，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 PutBucketPolicy方法来设置桶策略，并传递桶名字以及存在一个[PutBucketPolicyRequest](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_put_bucket_policy_request.html)对象中的JSON形式的桶策略。
**包含文件**
```
#include <cstdio>
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/PutBucketPolicyRequest.h>
```

**代码**
```
const Aws::String policy_string =
    "{\n"
    "  \"Version\":\"2012-10-17\",\n"
    "  \"Statement\":[\n"
    "   {\n"
    "     \"Sid\": \"1\",\n"
    "     \"Effect\": \"Allow\",\n"
    "     \"Principal\": {\"AWS\":\"*\"},\n"
    "     \"Action\": [\"s3:GetObject\"],\n"
    "     \"Resource\": [\"arn:aws:s3:::" + bucket_name + "/*\"]\n"
    "   }]\n"
    "}";

auto request_body = Aws::MakeShared<Aws::StringStream>("");
st_body << policy_string;

Aws::S3::Model::PutBucketPolicyRequest request;
request.SetBucket(bucket_name);
request.SetBody(request_body);

auto outcome = s3_client.PutBucketPolicy(request);

if (outcome.IsSuccess()) {
    std::cout << "Done!" << std::endl;
} else {
    std::cout << "SetBucketPolicy error: "
              << outcome.GetError().GetExceptionName() << std::endl
              << outcome.GetError().GetMessage() << std::endl;
}
```
> **注意**： Aws::Utils::Json::JsonValue 工具类能够被用于帮你构造有效的JSON对象来传递给PutBucketPolicy方法。

参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/put_bucket_policy.cpp)。
##### 获取一个桶策略
为了检索一个S3存储桶的策略，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 GetBucketPolicy方法，并传递一个含有桶名字的[GetBucketPolicyRequest对象](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_get_bucket_policy_request.html)。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/GetBucketPolicyRequest.h>
```

**代码**
```
Aws::S3::Model::GetBucketPolicyRequest request;
request.SetBucket(bucket_name);

auto outcome = s3_client.GetBucketPolicy(request);

if (outcome.IsSuccess())
{
    Aws::StringStream policyStream;
    Aws::String line;
    while (outcome.GetResult().GetPolicy())
    {
        outcome.GetResult().GetPolicy() >> line;
        policyStream << line;
    }
    std::cout << "Policy: " << std::endl << policyStream.str() << std::endl;
}
else
{
    std::cout << "GetBucketPolicy error: " <<
        outcome.GetError().GetExceptionName() << std::endl <<
        outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/get_bucket_policy.cpp)。
##### 删除一个桶策略
为了删除一个S3存储桶的策略，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 DeleteBucketPolicy方法，并传递一个含有桶名字的[DeleteBucketPolicyRequest对象](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_delete_bucket_policy_request.html)。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/DeleteBucketPolicyRequest.h>
```

**代码**
```
Aws::S3::Model::DeleteBucketPolicyRequest request;
request.SetBucket(bucket_name);

auto outcome = s3_client.DeleteBucketPolicy(request);

if (outcome.IsSuccess())
{
    std::cout << "Done!" << std::endl;
}
else
{
    std::cout << "DeleteBucketPolicy error: "
        << outcome.GetError().GetExceptionName() << " - "
        << outcome.GetError().GetMessage() << std::endl;
}
```

这个方法将会成功，即使该存储桶并不拥有策略。如果你指定一个并不存在的桶，或者你对通没有访问权限，一个AmazonServiceException异常将会抛出。

参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/delete_bucket_policy.cpp)。

**更多信息**
- [PutBucketPolicy](https://docs.aws.amazon.com/AmazonS3/latest/API/PutBucketPolicy.html)  Amazon S3 API 参考
- [GetBucketPolicy](https://docs.aws.amazon.com/AmazonS3/latest/API/GetBucketPolicy.html) Amazon S3 API 参考
- [DeleteBucketPolicy](https://docs.aws.amazon.com/AmazonS3/latest/API/GetBucketPolicy.html) Amazon S3 API 参考
- [Access Policy Language Overview](https://docs.aws.amazon.com/AmazonS3/latest/API/DeleteBucketPolicy.html) Amazon S3 开发者指南
- [Bucket Policy Examples](https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html)  Amazon S3 开发者指南
#### 5.5 将Amazon S3存储桶配置为一个站点
你可以将一个Amazon S3存储桶配置成象网站一样工作。为了实现这个，你需要设置它的网站配置。

> **注意**：代码片段假设你理解[AWS SDK for C++入门](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/getting-started.html)的内容，并已经依据[提供AWS凭证](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/credentials.html)
##### 设置桶的网站配置
对一个S3存储桶的网站配置，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 [PutBucketWebsiteRequest](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_put_bucket_website_request.html)方法，它含有桶名字以及容纳网站配置信息的一个[PutBucketPolicyRequest](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_website_configuration.html)对象。

设置一个主文档（index document）是必须的，其它所有参数是可选的。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/IndexDocument.h>
#include <aws/s3/model/ErrorDocument.h>
#include <aws/s3/model/WebsiteConfiguration.h>
#include <aws/s3/model/PutBucketWebsiteRequest.h>
```

**代码**
```
Aws::S3::Model::IndexDocument index_doc;
index_doc.SetSuffix(index_suffix);

Aws::S3::Model::ErrorDocument error_doc;
error_doc.SetKey(error_key);

Aws::S3::Model::WebsiteConfiguration website_config;
website_config.SetIndexDocument(index_doc);
website_config.SetErrorDocument(error_doc);

Aws::S3::Model::PutBucketWebsiteRequest request;
request.SetBucket(bucket_name);
request.SetWebsiteConfiguration(website_config);

auto outcome = s3_client.PutBucketWebsite(request);

if (outcome.IsSuccess())
{
    std::cout << "Done!" << std::endl;
}
else
{
    std::cout << "PutBucketWebsite error: "
        << outcome.GetError().GetExceptionName() << std::endl
        << outcome.GetError().GetMessage() << std::endl;
}
```
> **注意**： 设置网站配置并不会改变对你的存储桶的访问权限。为了使你的文件在网站上访问，你需要设置一个桶策略来允许对桶中文件的公开读访问。跟过信息，请参阅[使用桶策略来管理对存储桶的访问](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/examples-s3-bucket-policies.html)。

参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/put_website_config.cpp)。
##### 获取桶的网站配置
为了检索一个S3存储桶的网站配置，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 GetBucketWebsite方法，并传递一个含有桶名字的[GetBucketWebsiteRequest](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_get_bucket_website_request.html)对象。

配置信息将以返回的outcome对象所包含的的[GetBucketWebsiteResult](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_get_bucket_website_result.html)呈现。如果这个桶没有网站配置，null将返回。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/GetBucketWebsiteRequest.h>
```

**代码**
```
Aws::S3::Model::GetBucketWebsiteRequest request;
request.SetBucket(bucket_name);

auto outcome = s3_client.GetBucketWebsite(request);

if (outcome.IsSuccess())
{
    std::cout << "  Index page: "
        << outcome.GetResult().GetIndexDocument().GetSuffix()
        << std::endl
        << "  Error page: "
        << outcome.GetResult().GetErrorDocument().GetKey()
        << std::endl;
}
else
{
    std::cout << "GetBucketWebsite error: "
        << outcome.GetError().GetExceptionName() << " - "
        << outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/get_website_config.cpp)。
##### 删除桶的网站配置
为了删除一个S3存储桶的网站配置，你可以调用 [S3Client](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_s3_client.html)对象的 DeleteBucketPolicy方法，并传递一个含有桶名字的[DeleteBucketWebsiteRequest](https://sdk.amazonaws.com/cpp/api/LATEST/class_aws_1_1_s3_1_1_model_1_1_delete_bucket_website_request.html)对象。
**包含文件**
```
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/DeleteBucketWebsiteRequest.h>
```

**代码**
```
Aws::S3::Model::DeleteBucketWebsiteRequest request;
request.SetBucket(bucket_name);

auto outcome = s3_client.DeleteBucketWebsite(request);

if (outcome.IsSuccess())
{
    std::cout << "Done!" << std::endl;
}
else
{
    std::cout << "DeleteBucketWebsite error: "
        << outcome.GetError().GetExceptionName() << std::endl
        << outcome.GetError().GetMessage() << std::endl;
}
```
参见[完整代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/delete_website_config.cpp)。

**更多信息**
- [设置存储桶网站配置](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUTwebsite.html) Amazon S3 API 参考
- [获取存储桶网站配置](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETwebsite.html) Amazon S3 API 参考
- [删除存储桶网站配置](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketDELETEwebsite.html) Amazon S3 API 参考
### $6 Amazon SQS 示例
### $7 异步方法
#### 异步SDK方法
对于许多方法，AWS SDK for C++同时提供同步和异步版本。一个方法如果其名字包含Async后缀就是异步的。比如，Amazon S3 方法PutObject是同步的，但PutObjectAsync就是异步的。

就像所有的异步操作一样，一个异步SDK方法会在其主要任务完成之前返回。例如，PutObjectAsync将会在在将文件上传到Amazon S3存储桶之前返回。当上传过程继续时，应用可以执行其它操作，包括调用其他异步方法。 当异步操作完成时，应用将会被通知，其关联回调函数将会被调用。

下面的章节描述了调用SDK异步函数的示例代码。每一节关注例子的[完整源代码](https://github.com/awsdocs/aws-doc-sdk-examples/tree/master/cpp/example_code/s3/put_object_async.cpp)的一部分。
#### 调用异步SDK方法
基本上，一个SDK函数的异步版本接受下列参数：
+ 一个和其同步版本一样指向一个Request-type的引用
+ 一个指向回复处理回掉函数的引用，这个回掉函数的将会在异步操作完成时调用。其中一个参数含有操作的返回值。
+ 一个可选的指向AsyncCallerContext对象的智能共享指针（shared_ptr）。该对象被传递给回复处理回调函数。它包含一个UUID属性，可以被用来传递文本信息到回调函数。

下面的put_s3_object_async方法设置并调用Amazon S3 PutObjectAsync方法来异步上传一个文件到一个S3存储桶。

该方法与其同步版本一样的方式初始化一个PutObjectRequest对象。另外，一个指向AsyncCallerContext对象的智能指针被分配，它的UUID被设置为S3存储桶名字。出于演示目的，回复处理回调函数将访问该属性并打印其值。

对PutObjectAsync的调用包含了一个对回复处理回调函数put_object_async_finished的引用参数，灰调函数将会在下一节详细解释。
```
bool put_s3_object_async(const Aws::S3::S3Client& s3_client,
    const Aws::String& s3_bucket_name,
    const Aws::String& s3_object_name,
    const std::string& file_name)
{
    // Verify file_name exists
    if (!file_exists(file_name)) {
        std::cout << "ERROR: NoSuchFile: The specified file does not exist"
            << std::endl;
        return false;
    }

    // Set up request
    Aws::S3::Model::PutObjectRequest object_request;

    object_request.SetBucket(s3_bucket_name);
    object_request.SetKey(s3_object_name);
    const std::shared_ptr<Aws::IOStream> input_data =
        Aws::MakeShared<Aws::FStream>("SampleAllocationTag",
            file_name.c_str(),
            std::ios_base::in | std::ios_base::binary);
    object_request.SetBody(input_data);

    // Set up AsyncCallerContext. Pass the S3 object name to the callback.
    auto context =
        Aws::MakeShared<Aws::Client::AsyncCallerContext>("PutObjectAllocationTag");
    context->SetUUID(s3_object_name);

    // Put the object asynchronously
    s3_client.PutObjectAsync(object_request, 
                             put_object_async_finished,
                             context);
    return true;
```

与一个异步操作直接关联的资源必须在操作完成前继续存在。例如，调用SDK一步方法的客户端对象必须在操作完成，应用收到通知前存在。类似地，应用本身不能在异步操作完成前终止。

由于这个原因，put_s3_object_async方法接受一个传入的S3Client对象的引用，而不是在函数内部创建一个S3Client局部变量。在例子中，方法在开始异步操作后立即返回给调用者，能够使调用者在异步处理过程中处理其它的任务。如果客户端在局部变量中，方法返回后它将退出其作用域。但是，知道异步操作完成前客户端对象必须继续存在。
#### 异步操作完成的通知
当一个异步操作完成后，一个应用回复处理回调函数将会被调用。通知包括了操作的输出结果。输出结果包含在和其同步版本一样的 Outcome-type类中。在示例代码中，输出结果包含在一个PutObjectOutcome对象中。

示例代码的应用回复处理回调函数put_object_async_finished在下面展示。它检查了异步操作成功了还是失败了。它使用了std::condition_variable来通知应用线程异步操作已经完成了。
```
std::mutex upload_mutex;
std::condition_variable upload_variable;
```

```
void put_object_async_finished(const Aws::S3::S3Client* client, 
    const Aws::S3::Model::PutObjectRequest& request, 
    const Aws::S3::Model::PutObjectOutcome& outcome,
    const std::shared_ptr<const Aws::Client::AsyncCallerContext>& context)
{
    // Output operation status
    if (outcome.IsSuccess()) {
        std::cout << "put_object_async_finished: Finished uploading " 
            << context->GetUUID() << std::endl;
    }
    else {
        auto error = outcome.GetError();
        std::cout << "ERROR: " << error.GetExceptionName() << ": "
            << error.GetMessage() << std::endl;
    }

    // Notify the thread that started the operation
    upload_variable.notify_one();
}
```
当异步操作完成，相关资源可以被释放。应用本身也可以终止了。

下面的代码演示了在一个应用中put_object_async 和 put_object_async_finished是如何被使用的。

S3Client对象被分配，因此它将在异步操作完成前继续存在。当put_object_async被调用后，应用本身可以执行任何它希望的操作。为了简化，例子使用std::mutex 和 std::condition_variable来等待回复处理回调函数通知它上传操作已经完成。
```
// NOTE: The S3Client object that starts the async operation must 
// continue to exist until the async operation completes.
Aws::S3::S3Client s3Client(clientConfig);

// Put the file into the S3 bucket asynchronously
std::unique_lock<std::mutex> lock(upload_mutex);
if (put_s3_object_async(s3Client, 
                        bucket_name, 
                        object_name, 
                        file_name)) {
    // While the upload is in progress, we can perform other tasks.
    // For this example, we just wait for the upload to finish.
    std::cout << "main: Waiting for file upload to complete..." 
        << std::endl;
    upload_variable.wait(lock);

    // The upload has finished. The S3Client object can be cleaned up 
    // now. We can also terminate the program if we wish.
    std::cout << "main: File upload completed" << std::endl;
}
```
## 参考
- [开发人员指南](https://docs.aws.amazon.com/zh_cn/sdk-for-cpp/v1/developer-guide/welcome.html)
- [CMake tutorial](https://cmake.org/cmake-tutorial/)
- [How to build AWS C++ SDK on Windows](https://www.megalacant.com/techblog/2019/02/28/building-aws-cpp-sdk-windows.html)
- [AWS SDK for C++ API Reference](https://sdk.amazonaws.com/cpp/api/LATEST/index.html)