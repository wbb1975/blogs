# AWS Identity and Access Management (IAM)

##  第三章 入门
本主题向您介绍如何在您的 AWS 账户下创建 AWS Identity and Access Management (IAM) 用户，以允许访问您的 AWS 资源。首先，您将学习在创建组和用户之前应了解的 IAM 概念；然后，您将详细了解如何使用 AWS 管理控制台 执行必要的任务。第一个任务是设置 AWS 账户的管理员组。AWS 账户中，管理员组不是必需的，但我们强烈建议您创建它。
> **注意**： 这套文档主要介绍 IAM 服务。要了解如何使用 AWS 以及使用多种服务来解决构建和启动您的第一个项目等问题，请参阅[入门资源中心](http://www.amazonaws.cn/getting-started/)。

在下图所示的简单示例中，AWS 账户有三个组。一个群组由一系列具有相似责任的用户组成。在此示例中，一个群组为管理员群组（名为 Admins）。另外还有一个 Developers 群组和一个 Test 群组。每个群组均包含多个用户。尽管图中并未列明，但每个用户可处于多个群组中。您不得将群组置于其他群组中。您可使用策略向群组授予许可。

![IAM Users And Groups](https://github.com/wbb1975/blogs/blob/master/aws/images/iam-intro-users-and-groups.diagram.png)

在随后的流程中，您需要执行下列任务：
- 创建管理员组并向该组提供访问您 AWS 账户的所有资源的权限。
- 为您自己创建一个用户并将该用户添加到管理员组。
- 为您的用户创建密码，以便可以登录 AWS 管理控制台。

您需要授予管理员组权限，以访问 AWS 账户内所有可用的源。可用的资源是指您使用或注册的任何 AWS 产品。管理员组中的用户也可以访问您的 AWS 账户信息，AWS 账户的安全证书除外。
### 1. 建您的第一个 IAM 管理员用户和组（Creating Your First IAM Admin User and Group）
作为[最佳实践](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#lock-away-credentials)，请勿在不必要时使用 AWS 账户根用户执行任务，而是应为需要管理员访问权限的每个人创建新的 IAM 用户。然后，通过将这些用户放入到一个您附加了 AdministratorAccess 托管策略的“管理员”组中，使这些用户成为管理员。

之后，管理员组中的用户应为 AWS 账户设置组、用户等。所有将来的交互均应通过 AWS 账户的用户以及他们自己的密钥进行，而不应使用 根用户。但是，要执行一些账户和服务管理任务，您必须使用根用户凭证登录。要查看需要您以 根用户 身份登录的任务，请参阅[需要账户根用户的 AWS 任务](https://docs.amazonaws.cn/general/latest/gr/aws_tasks-that-require-root.html)。
#### 1.1 创建管理员 IAM 用户和组（控制台）：
此过程将介绍如何使用 AWS 管理控制台自行创建 IAM 用户，并将该用户添加到具有已附加托管策略中的管理权限的组。

**自行创建管理员用户并将该用户添加到管理员组（控制台）**
1. 使用 AWS 账户电子邮件地址和密码，以 [AWS 账户根用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_root-user.html)身份登录到[IAM 控制台](https://console.aws.amazon.com/iam/) 
    > 注意：强烈建议您遵守以下使用 Administrator IAM 用户的最佳实践，妥善保存根用户凭证。只在执行少数[账户和服务管理任务](https://docs.amazonaws.cn/general/latest/gr/aws_tasks-that-require-root.html)时才作为根用户登录。
2. 启用对你创建的IAM管理员账号的账单数据的访问权限
   + 在导航窗格中，选中你的账号名，然后选择**My Account（我的账号）**
   + 选择“IAM 用户和角色访问账单信息的权限”，选中**Edit（编辑）**
   + 选中“激活 IAM 访问权限”的单选框，然后点击**Update（更新）**
   + 在导航栏上，选择**服务**，然后选择 **IAM** 以返回到 IAM 控制面板
3. 在导航窗格中，选择 **Users (用户)**，然后选择**Add user (添加用户)**
4. 对于 **User name**，键入 **Administrator**
5. 选中 **AWS 管理控制台 access (AWS 管理控制台访问)** 旁边的复选框，选择 **Custom password (自定义密码)**，然后在文本框中键入新密码。默认情况下，AWS 将强制新用户在首次登录时创建新密码。您可以选择清除 **User must create a new password at next sign-in (用户必须在下次登录时创建新密码)** 旁边的复选框，以允许新用户在登录后重置其密码。
6. 选择 **Next: Permissions (下一步: 权限)**
7. 在**设置权限**页面上，选择**将用户添加到组**
8. 选择 **Create group**
9.  在 **Create group (创建组)** 对话框中，对于 **Group name (组名称)**，键入 **Administrators**
10. 选择 **Policy Type (策略类型)**，然后选择 AWS 托管 - 工作职能以筛选表内容。
11. 在策略列表中，选中 **AdministratorAccess** 的复选框。然后选择 **Create group**
12. 返回到组列表中，选中您的新组所对应的复选框。如有必要，选择 Refresh 以在列表中查看该组。
13. 选择 **Next: Tagging (下一步: 标记)**。
14. （可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅[标记 IAM 用户和角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。
15. 选择 **Next: Review** 以查看要添加到新用户的组成员资格的列表。如果您已准备好继续，请选择 **Create user**。

您可使用此相同的流程创建更多的组和用户，并允许您的用户访问 AWS 账户资源。要了解有关使用限制用户对特定 AWS 资源的权限的策略的信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)和[IAM 基于身份的策略示例](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)。要在创建组之后向其中添加其他用户，请参阅[在IAM 组中添加和删除用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_groups_manage_add-remove-users.html)。
#### 1.2 创建 IAM 用户和组 (AWS CLI)
如果执行了上一节中的步骤，则您已使用 AWS 管理控制台设置了一个管理员组，同时在您的 AWS 账户中创建了 IAM 用户。此过程显示创建组的替代方法。

**概述：设置管理员组**
1. 创建一个组并为其提供名称 (例如 Admins)。有关更多信息，请参阅[创建组 (AWS CLI)](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html#Using_CreateGroup)。
2. 附加一个策略以便为组提供管理权限（对所有 AWS 操作和资源的访问权限）。有关更多信息，请参阅[将策略附加到组 (AWS CLI)](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html#Using_AddingAdminRightsPolicy)。
3. 向组至少添加一个用户。有关更多信息，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。
##### 1.2.1 创建组 (AWS CLI)
本部分将介绍如何在 IAM 系统中创建一个组。
1. 键入 [aws iam create-group](https://docs.amazonaws.cn/cli/latest/reference/iam/create-group.html)命令，并使用您为组选择的名称。（可选）您可以包含路径作为该群组名的一部分。有关路径的更多信息，请参阅 易记名称和路径。名称可包含字母、数字以及以下字符：加号 (+)、等号 (=)、逗号 (,)、句点 (.)、at 符号 (@)、下划线 (_) 和连字符 (-)。名称不区分大小写，且最大长度可为 128 个字符。

在此示例中，您将创建名为 Admins 的组。
```
wangbb@wangbb-ThinkPad-T420:~/.aws$ aws iam create-group --group-name Admins
{
    "Group": {
        "Path": "/",
        "GroupName": "Admins",
        "GroupId": "AGPAQCVPU47AL4YEYRVOG",
        "Arn": "arn:aws:iam::005737080768:group/Admins",
        "CreateDate": "2020-01-03T06:40:32Z"
    }
}
}
```
2. 键入[aws iam list-groups](https://docs.amazonaws.cn/cli/latest/reference/iam/list-groups.html) 命令以列出您的 AWS 账户中的组并确认该组已创建。
```
wangbb@wangbb-ThinkPad-T420:~/.aws$ aws iam list-groups
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "Administrators",
            "GroupId": "AGPAQCVPU47AMAE7BBUNO",
            "Arn": "arn:aws:iam::005737080768:group/Administrators",
            "CreateDate": "2020-01-03T06:23:22Z"
        },
        {
            "Path": "/",
            "GroupName": "Admins",
            "GroupId": "AGPAQCVPU47AL4YEYRVOG",
            "Arn": "arn:aws:iam::005737080768:group/Admins",
            "CreateDate": "2020-01-03T06:40:32Z"
        }
    ]
}
```
响应中包括您的新群组的 Amazon 资源名称 (ARN)。ARN 是 AWS 用于识别资源的标准格式。ARN 中的 12 位数字是您的 AWS 账户 ID。您分配至组 (Admins) 的易记名称将在组 ARN 的末尾显示。
##### 1.2.2 将策略附加到组 (AWS CLI)
本节介绍了如何附加策略，从而允许组中的任何用户对 AWS 账户内的任何资源执行任何操作。您可以通过将名为 AdministratorAccess 的 [AWS 托管策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)附加到 Admins 组来执行此操作。有关策略的更多信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)。

**添加提供了完整管理员权限的策略 (AWS CLI)**
1. 键入 [aws iam attach-group-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/attach-group-policy.html) 命令以将名为 AdministratorAccess 的策略附加到 Admins 组。该命令使用名为 AdministratorAccess 的 AWS 托管策略的 ARN。
   ```
   aws iam attach-group-policy --group-name Admins --policy-arn arn:aws-cn:iam::aws:policy/AdministratorAccess
   ```
   如果命令执行成功，则没有应答。
2. 键入 [aws iam list-attached-group-policies](https://docs.amazonaws.cn/cli/latest/reference/iam/list-attached-group-policies.html) 命令以确认该策略已附加到 Admins 组。
```
aws iam list-attached-group-policies --group-name Admins
```
在响应中列出附加到 Admins 组的策略名称。类似如下的响应告诉您名为 AdministratorAccess 的策略已附加到 Admins 组：
```
wangbb@wangbb-ThinkPad-T420:~/.aws$ aws iam list-attached-group-policies --group-name Admins
{
    "AttachedPolicies": [
        {
            "PolicyName": "AdministratorAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AdministratorAccess"
        }
    ]
}
```
您可使用 [aws iam get-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/get-policy.html) 命令来确认特定策略的内容。
```
wangbb@wangbb-ThinkPad-T420:~/.aws$ aws iam get-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
{
    "Policy": {
        "PolicyName": "AdministratorAccess",
        "PolicyId": "ANPAIWMBCKSKIEE64ZLYK",
        "Arn": "arn:aws:iam::aws:policy/AdministratorAccess",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 2,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "Description": "Provides full access to AWS services and resources.",
        "CreateDate": "2015-02-06T18:39:46Z",
        "UpdateDate": "2015-02-06T18:39:46Z"
    }
}
```
> 重要：在您完成管理员群组的设置后，您必须在该群组中至少添加一位用户。有关向组中添加用户的更多信息，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。
##### 1.2.3 创建 IAM 用户（AWS CLI）
1. 创建用户：[aws iam create-user](https://docs.amazonaws.cn/cli/latest/reference/iam/create-user.html)
    ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-user --user-name "admin"
    {
        "User": {
            "UserName": "admin", 
            "Path": "/", 
            "CreateDate": "2019-08-03T01:32:54Z", 
            "UserId": "AIDAQCVPU47ABPOFBEDIN", 
            "Arn": "arn:aws:iam::005737080768:user/admin"
        }
    }
    ```
2. （可选）向用户提供对 AWS 管理控制台的访问权限。这需要密码。您必须还向用户提供您的账户登录页的 URL：
     [aws iam create-login-profile](https://docs.amazonaws.cn/cli/latest/reference/iam/create-login-profile.html)
    ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-login-profile --user-name "admin" --password "XXXX"
    {
        "LoginProfile": {
            "UserName": "admin", 
            "CreateDate": "2019-08-03T01:34:09Z", 
            "PasswordResetRequired": false
        }
    }
    ```
3. （可选）向用户提供编程访问。这需要访问密钥：[aws iam create-access-key](https://docs.amazonaws.cn/cli/latest/reference/iam/create-access-key.html)
   ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-access-key --user-name "admin"
    {
        "AccessKey": {
            "UserName": "admin", 
            "Status": "Active", 
            "CreateDate": "2019-08-03T01:37:14Z", 
            "SecretAccessKey": "I4EKl9sZfk29uTa6PbWtZY+XBSdJ0qFP7ZzNnUHy", 
            "AccessKeyId": "AKIAQCVPU47AIQNHHJFQ"
        }
    }
   ```
4. 将该用户添加到一个或多个组。您指定的组应具有用于向用户授予适当的权限的附加策略：[aws iam add-user-to-group](https://docs.amazonaws.cn/cli/latest/reference/iam/add-user-to-group.html)
5. （可选）向用户附加策略，此策略用于定义该用户的权限。注意：建议您通过将用户添加到一个组并向该组附加策略（而不是直接向用户附加策略）来管理用户权限：[aws iam attach-user-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/attach-user-policy.html)
6. （可选）通过附加标签来向用户添加自定义属性。有关更多信息，请参阅[管理 IAM 实体的标签（AWS CLI 或 AWS API）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html#id_tags_procs-cli-api)。
7. （可选）向用户授予用于管理其自身的安全凭证的权限。有关更多信息，请参阅AWS：[允许经过 MFA 身份验证的 IAM 用户在“My Security Credentials (我的安全凭证)”页面上管理自己的凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html)。
### 2. 创建委派用户(Creating a Delegated User)
要支持您的 AWS 账户中的多个用户，您必须委派权限以允许其他人仅执行您要允许的操作。为此，请创建一个 IAM 组（其中具有这些用户所需的权限），然后在创建必要的组时将 IAM 用户添加到这些组。您可以使用此过程为您的整个 AWS 账户设置组、用户和权限。

此解决方案最适合中小型组织，其中 AWS 管理员可以手动管理用户和组。对于大型组织，您可以使用[自定义 IAM 角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)、[联合身份验证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers.html)或[单一登录](https://docs.amazonaws.cn/singlesignon/latest/userguide/what-is.html)。
#### 2.1 创建委派的 IAM 用户和组（控制台）
您可以使用 AWS 管理控制台创建具有委派权限的 IAM 组，然后为其他人创建 IAM 用户并将此用户添加到该组。
1. 登录 AWS 管理控制台 并通过以下网址打开[IAM 控制台](https://console.amazonaws.cn/iam/)
2. 在左侧的导航窗格中，选择**策略**。如果这是您首次选择 **Policies**，则会显示 **Welcome to Managed Policies** 页面。选择 **Get Started** 。
3. 选择 **Create policy**。
4. 选择 **JSON** 选项卡，然后在窗口右侧，选择 **Import managed policies (导入托管策略)**。
5. 在 **Import managed policies (导入托管策略)** 窗口中，键入**power** 以缩小策略列表。然后，选择 **PowerUserAccess** AWS 托管策略旁的按钮。
6. 选择 **Import**：导入策略将添加到您的 JSON 策略中。
7. 选择**查看策略**。
8. 在 **Review (审核)** 页面上，为 **Name (名称)** 键入 **PowerUserExampleCorp**。对于 **Description (描述)**，键入 **Allows full access to all services except those for user management**。然后，选择**创建策略**以保存您的工作。
9. 在导航窗格中，选择 **Groups (组)**，然后选择 **Create New Group (创建新组)**。
10. 在 **Group Name (组名称) 框中**，键入 **PowerUsers**。
11. 在策略列表中，选中 **PowerUserExampleCorp** 旁边的复选框。然后选择 **Next Step**。
12. 选择 **Create Group**。
13. 在导航窗格中，选择 **Users (用户)**，然后选择 **Add user (添加用户)**。
14. 对于 **User name**，键入 **mary.major@examplecorp.com**。
15. 选择 **Add another user (添加其他用户)** 并键入 **diego.ramirez@examplecorp.com** 作为第二个用户。
16. 选中 **AWS 管理控制台 access (AWS 管理控制台访问)** 旁边的复选框，然后选择 **Autogenerated password (自动生成的密码)**。默认情况下，AWS 将强制新用户在首次登录时创建新密码。清除 **User must create a new password at next sign-in (用户必须在下次登录时创建新密码）**旁边的复选框以允许新用户在登录后重置其密码
17. 选择 **Next: Permissions (下一步: 权限)**。
18. 在 **Set permissions (设置权限)** 页面上，选择 **Add user to group (将用户添加到组)**并选中 **PowerUsers** 旁边的复选框。
19. 选择 **Next: Tagging (下一步: 标记)**。
20. （可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅[标记 IAM 实体](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。
21. 选择 **Next: Review** 以查看要添加到新用户的组成员资格的列表。如果您准备好继续，请选择 **Create users (创建用户)**。
22. 下载或复制新用户的密码并安全地将其提供给用户。单独为您的用户提供[指向您的 IAM 用户控制台页面的链接](https://docs.amazonaws.cn/IAM/latest/UserGuide/console.html#user-sign-in-page)以及您刚刚创建的用户名。
#### 2.2 减少组权限
PowerUser 组的成员可以完全访问除提供用户管理操作（如 IAM 和 组织）的少数服务之外的所有服务。经过预定义的不活动时段（如 90 天）后，您可以查看组成员已访问的服务。然后，您可以减少 PowerUserExampleCorp 策略的权限以仅包含您的团队所需的服务。

有关上次访问的服务相关数据的更多信息，请参阅[使用上次访问的服务数据优化权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_access-advisor.html)。
##### 2.2.1 查看上次访问的服务相关数据
等待预定义的不活动时段（如 90 天）经过。然后，您可以查看您的用户或组上次访问的服务相关数据，以了解您的用户上次尝试访问您的 PowerUserExampleCorp 策略允许的服务的时间。
1. 登录 AWS 管理控制台并通过以下网址打开 [IAM 控制台](https://console.amazonaws.cn/iam/)。
2. 在导航窗格中，选择 **Groups (组)**，然后选择 **PowerUser** 组名称。
3. 在组摘要页面上，选择 **Access Advisor (访问顾问)**选项卡。

    上次访问的服务相关数据表显示组成员上次尝试访问每个服务的时间（按时间顺序，从最近的尝试开始）。该表仅包含策略允许的服务。在此情况下，PowerUserExampleCorp 策略允许访问所有 AWS 服务。
4. 查看此表并生成您的组成员最近访问过的服务的列表。
    
   例如，假设在上个月内，您的团队仅访问了 Amazon EC2 和 Amazon S3 服务。但 6 个月前，他们访问了 Amazon EC2 Auto Scaling 和 IAM。您知道他们正在调查 EC2 Auto Scaling，但您认定不需要这样做。您还知道他们使用 IAM 创建角色以允许 Amazon EC2 访问 S3 存储桶中的数据。因此，您决定减少用户的权限，以仅允许访问 Amazon EC2 和 Amazon S3 服务。
##### 2.2.2 编辑策略以减少权限
在查看上次访问的服务相关数据后，可以编辑策略以仅允许访问您的用户所需的服务。
1. 在导航窗格中，选择 **Policies (策略)**，然后选择 **PowerUserExampleCorp** 策略名称。
2. 选择 **Edit policy (编辑策略)**，然后选择 **JSON **选项卡。
3. 编辑 JSON 策略文档以仅允许所需的服务。
   
    例如，编辑第一个包括 Allow 效果和 NotAction 元素的语句以仅允许 Amazon EC2 和 Amazon S3 操作。为此，请将其替换为具有 FullAccessToSomeServices ID 的语句。您的新策略将类似于以下示例策略。
   ```
   {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "FullAccessToSomeServices",
                "Effect": "Allow",
                "Action": [
                    "ec2:*",
                    "s3:*"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:CreateServiceLinkedRole",
                    "iam:DeleteServiceLinkedRole",
                    "iam:ListRoles",
                    "organizations:DescribeOrganization"
                ],
                "Resource": "*"
            }
        ]
    }
   ```
4. 要进一步减少策略对特定操作和资源的权限，请在 CloudTrail Event history (事件历史记录) 中查看您的事件。在此处，您可以查看有关用户已访问的特定操作和资源的详细信息。有关更多信息，请参阅 AWS CloudTrail 用户指南 中的[在 CloudTrail 控制台中查看 CloudTrail 事件](https://docs.amazonaws.cn/awscloudtrail/latest/userguide/view-cloudtrail-events-console.html)。
### 3. 用户如何登录您的账户
创建 IAM 用户（具有密码）后，这些用户可以登录到 AWS 管理控制台。用户需要您的账户 ID 或别名进行登录。他们也可从包含您的账户 ID 的自定义 URL 登录。
> 注意：如果贵公司现在有一个身份系统，您可能需要创建单一登录 (SSO) 选项。SSO 向用户提供对 AWS 管理控制台 的访问权限，而不要求他们具有 IAM 用户身份。SSO 也无需用户单独登录您的组织的网站和 AWS。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。

在为您的账户创建登录 URL 前，您可以创建账户别名，使得 URL 包含您的账户名称而不是账户 ID。有关更多信息，请参阅 [AWS 账户 ID 及其别名](https://docs.amazonaws.cn/IAM/latest/UserGuide/console_account-alias.html)。您可以在 IAM 控制台控制面板中找到账户的登录 URL。

![AccountAlias.console](https://github.com/wbb1975/blogs/blob/master/aws/images/AccountAlias.console.png)

要为您的 IAM 用户创建登录 URL，请使用以下模式：
```
https://account-ID-or-alias.signin.amazonaws.cn/console
```

IAM 用户还可以在以下终端节点登录并手动输入账户 ID 或别名，而不是使用您的自定义 URL：
```
https://signin.amazonaws.cn/console
```
#### 3.1 控制台活动所需的权限
您账户中的 IAM 用户只能访问您在策略中指定的 AWS 资源。该策略必须附加到用户或用户所属的 IAM 组。要在控制台开展工作，用户必须有权限执行控制台执行的操作（例如列出和创建 AWS 资源）。有关更多信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)和[IAM 基于身份的策略示例](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)。

如果您账户中的用户需要编程访问，您可以为每个用户创建一个访问密钥对（访问密钥 ID 和秘密访问密钥）。有关更多信息，请参阅[管理访问密钥（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)。
#### 3.2 在 CloudTrail 中记录登录详细信息
如果您启用 CloudTrail 来记录登录事件，则必须了解 CloudTrail 记录事件的方式。CloudTrail 包括全局和区域日志条目。登录事件记录到 CloudTrail 中的位置取决于您用户登录的方式。有关详细信息，请参阅[使用 CloudTrail 记录 IAM 事件](https://docs.amazonaws.cn/IAM/latest/UserGuide/cloudtrail-integration.html)。

## Reference
- [IAM入门](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started.html)

