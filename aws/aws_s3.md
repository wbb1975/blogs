# 通过 AWS CLI 使用高级别 (s3) 命令
本主题介绍如何使用高级别 aws s3 命令管理 Amazon S3 存储桶和对象。

在运行任何命令之前，请设置默认证书。有关更多信息，请参阅 [配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html)。
## 管理存储桶
高级别 aws s3 命令支持常用的存储桶操作，如创建、列出和删除存储桶。
### 创建存储桶
使用 s3 mb 命令创建存储桶。存储桶名称必须全局唯一，并且应符合 DNS 标准。存储桶名称可以包含小写字母、数字、连字符和点号。存储桶名称只能以字母或数字开头和结尾，连字符或点号后不能跟点号。
```
$ aws s3 mb s3://bucket-name
```
### 列出存储桶
使用 s3 ls 命令列出您的存储桶。下面是一些常见使用情况示例。
下面的命令列出所有存储桶。
```
wangbb@wangbb-ThinkPad-T420:~$ aws s3 ls
2019-07-30 21:08:18 com.tr.ts.aws.wangbb.s3sample
2019-07-29 07:32:08 com.tr.ts.aws.wangbb.test
```

下面的命令列出一个存储桶中的所有对象和文件夹（在 S3 中称为“前缀”）：
```
wangbb@wangbb-ThinkPad-T420:~$ aws s3 ls s3://com.tr.ts.aws.wangbb.s3sample
2019-07-29 22:40:09        579 compress.py
```
### 删除存储段
要删除存储桶，请使用 s3 rb 命令。
```
$ aws s3 rb s3://bucket-name
```

默认情况下，存储桶必须为空，此操作才能成功。要删除非空存储桶，需要包含 --force 选项。

以下示例删除存储桶中的所有对象和子文件夹，然后删除存储桶:
```
$ aws s3 rb s3://bucket-name --force
```
**注意:** 如果您使用的是受版本控制的存储桶，即其中包含以前删除“但仍保留”的对象，则此命令不 允许您删除该存储桶。您必须先删除所有内容。
## 管理对象
高级别 aws s3 命令可以方便地管理 Amazon S3 对象。这些对象命令包括 [s3 cp](https://docs.amazonaws.cn/cli/latest/reference/s3/cp.html)、[s3 ls](https://docs.amazonaws.cn/cli/latest/reference/s3/ls.html)、[s3 mv](https://docs.amazonaws.cn/cli/latest/reference/s3/mv.html)、[s3 rm](https://docs.amazonaws.cn/cli/latest/reference/s3/rm.html) 和 [s3 sync](https://docs.amazonaws.cn/cli/latest/reference/s3/sync.html)。

cp、ls、mv 和 rm 命令的用法与它们在 Unix 中的对应命令相同，使您可以跨本地目录和 Amazon S3 存储桶无缝工作。sync 命令同步一个存储桶与一个目录或两个存储桶中的内容。
> **注意**
> 如果对象很大，所有涉及向 Amazon S3 存储桶（s3 cp、s3 mv 和 s3 sync）上传对象的高级命令都会自动执行分段上传。
> 
> 使用这些命令时，无法恢复失败的上传。如果分段上传由于超时而失败，或者通过按 Ctrl+C 手动取消，AWS CLI 将会清除创建的所有文件并中止上传。此过程可能耗时数分钟。
> 
> 如果进程被 kill 命令中断或者由于系统故障而中断，则正在进行的分段上传将保留在 Amazon S3 中，必须在 AWS 管理控制台中手动清除，或者使用 s3api abort-multipart-upload 命令来清除。

cp、mv 和 sync 命令包括一个 --grants 选项，可用来向指定用户或组授予对对象的权限。使用以下语法将 --grants 选项设置为权限列表。
```
--grants Permission=Grantee_Type=Grantee_ID
         [Permission=Grantee_Type=Grantee_ID ...]
```
每个值都包含以下元素：
- Permission – 指定授予的权限，可将其设置为 read、readacl、writeacl 或 full。
- Grantee_Type – 指定如何标识被授权者，可将其设置为 uri、 emailaddress 或 id。
- Grantee_ID – 根据 Grantee_Type 指定被授权者。
   + uri – 组 URI。有关更多信息，请参阅[谁是被授权者](https://docs.amazonaws.cn/AmazonS3/latest/dev/ACLOverview.html#SpecifyingGrantee)？
   + emailaddress – 账户的电子邮件地址。
   + id – 账户的规范 ID。

有关 Amazon S3 访问控制的更多信息，请参阅[访问控制](https://docs.amazonaws.cn/AmazonS3/latest/dev/UsingAuthAccess.html)。

下面的示例将一个对象复制到一个存储桶中。它授予所有人对对象的 read 权限，向 user@example.com 的关联账户授予 full 权限（read、readacl 和 writeacl）。
```
aws s3 cp file.txt s3://my-bucket/ --grants read=uri=http://acs.amazonaws.com.cn/groups/global/AllUsers full=emailaddress=user@example.com
```

还可以为上传到 Amazon S3 的对象指定非默认存储类（REDUCED_REDUNDANCY 或 STANDARD_IA）。为此，请使用 --storage-class 选项。

```aws s3 cp file.txt s3://my-bucket/ --storage-class REDUCED_REDUNDANCY```

s3 sync 命令使用如下语法。可能的源-目标组合有：
- 本地文件系统到 Amazon S3
- Amazon S3 到本地文件系统
- Amazon S3 到 Amazon S3

```$ aws s3 sync <source> <target> [--options]```

下面的示例将 my-bucket 中名为 path 的 Amazon S3 文件夹中的内容与当前工作目录同步。s3 sync 将更新与目标中的同名文件具有不同大小或修改时间的任何文件。输出显示在同步期间执行的特定操作。请注意，此操作将子目录 MySubdirectory 及其内容与 s3://my-bucket/path/MySubdirectory 递归同步。
```
$ aws s3 sync . s3://my-bucket/path
upload: MySubdirectory\MyFile3.txt to s3://my-bucket/path/MySubdirectory/MyFile3.txt
upload: MyFile2.txt to s3://my-bucket/path/MyFile2.txt
upload: MyFile1.txt to s3://my-bucket/path/MyFile1.txt
```

通常，s3 sync 仅在源和目标之间复制缺失或过时的文件或对象。不过，您还可以提供 --delete 选项来从目标中删除源中不存在的文件或对象。

下面的示例对上一示例进行了扩展，显示了其工作方式。
```
// Delete local file
$ rm ./MyFile1.txt

// Attempt sync without --delete option - nothing happens
$ aws s3 sync . s3://my-bucket/path

// Sync with deletion - object is deleted from bucket
$ aws s3 sync . s3://my-bucket/path --delete
delete: s3://my-bucket/path/MyFile1.txt

// Delete object from bucket
$ aws s3 rm s3://my-bucket/path/MySubdirectory/MyFile3.txt
delete: s3://my-bucket/path/MySubdirectory/MyFile3.txt

// Sync with deletion - local file is deleted
$ aws s3 sync s3://my-bucket/path . --delete
delete: MySubdirectory\MyFile3.txt

// Sync with Infrequent Access storage class
$ aws s3 sync . s3://my-bucket/path --storage-class STANDARD_IA
```

可以使用 --exclude 和 --include 选项指定规则来筛选要在同步操作期间复制的文件或对象。默认情况下，指定文件夹中的所有项都包含在同步中。因此，仅当需要指定 --exclude 选项的例外情况（也就是说，--include 实际上意味着“不排除”）时，才需要使用 --include。这些选项按指定顺序应用，如下例所示。
```
Local directory contains 3 files:
MyFile1.txt
MyFile2.rtf
MyFile88.txt
'''
$ aws s3 sync . s3://my-bucket/path --exclude "*.txt"
upload: MyFile2.rtf to s3://my-bucket/path/MyFile2.rtf
'''
$ aws s3 sync . s3://my-bucket/path --exclude "*.txt" --include "MyFile*.txt"
upload: MyFile1.txt to s3://my-bucket/path/MyFile1.txt
upload: MyFile88.txt to s3://my-bucket/path/MyFile88.txt
upload: MyFile2.rtf to s3://my-bucket/path/MyFile2.rtf
'''
$ aws s3 sync . s3://my-bucket/path --exclude "*.txt" --include "MyFile*.txt" --exclude "MyFile?.txt"
upload: MyFile2.rtf to s3://my-bucket/path/MyFile2.rtf
upload: MyFile88.txt to s3://my-bucket/path/MyFile88.txt
```

--exclude 和 --include 选项也可以与要在 s3 sync 操作（包括 --delete 选项）期间删除的文件或对象。在这种情况下，参数字符串必须指定要在目标目录或存储桶上下文中包含或排除在删除操作中的文件。下面是一个示例。
```
Assume local directory and s3://my-bucket/path currently in sync and each contains 3 files:
MyFile1.txt
MyFile2.rtf
MyFile88.txt
'''
// Delete local .txt files
$ rm *.txt

// Sync with delete, excluding files that match a pattern. MyFile88.txt is deleted, while remote MyFile1.txt is not.
$ aws s3 sync . s3://my-bucket/path --delete --exclude "my-bucket/path/MyFile?.txt"
delete: s3://my-bucket/path/MyFile88.txt
'''
// Delete MyFile2.rtf
$ aws s3 rm s3://my-bucket/path/MyFile2.rtf

// Sync with delete, excluding MyFile2.rtf - local file is NOT deleted
$ aws s3 sync s3://my-bucket/path . --delete --exclude "./MyFile2.rtf"
download: s3://my-bucket/path/MyFile1.txt to MyFile1.txt
'''
// Sync with delete, local copy of MyFile2.rtf is deleted
$ aws s3 sync s3://my-bucket/path . --delete
delete: MyFile2.rtf
```

s3 sync 命令还可以接受 --acl 选项，使用该选项可以设置对复制到 Amazon S3 中的文件的访问权限。--acl 选项接受 private、public-read 和 public-read-write 值。

```aws s3 sync . s3://my-bucket/path --acl public-read```

## 小结
如上文所述，s3 命令集包括 cp、mv、ls 和 rm，它们的用法与它们在 Unix 中的对应命令相同。下面是一些示例。
```
// Copy MyFile.txt in current directory to s3://my-bucket/path
$ aws s3 cp MyFile.txt s3://my-bucket/path/

// Move all .jpg files in s3://my-bucket/path to ./MyDirectory
$ aws s3 mv s3://my-bucket/path ./MyDirectory --exclude "*" --include "*.jpg" --recursive

// List the contents of my-bucket
$ aws s3 ls s3://my-bucket

// List the contents of path in my-bucket
$ aws s3 ls s3://my-bucket/path/

// Delete s3://my-bucket/path/MyFile.txt
$ aws s3 rm s3://my-bucket/path/MyFile.txt

// Delete s3://my-bucket/path and all of its contents
$ aws s3 rm s3://my-bucket/path --recursive
```

当 --recursive 选项与 cp、mv 或 rm 一起用于目录或文件夹时，命令会遍历目录树，包括所有子目录。与 --exclude 命令相同，这些命令也接受 --include、--acl 和 sync 选项。

## Reference
- [高级别 (s3) 命令](https://docs.amazonaws.cn/cli/latest/userguide/cli-services-s3-commands.html)