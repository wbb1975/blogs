## 教程
本部分包含介绍面向您可在 IAM 中执行的常见任务的完整的端到端过程的演练。这些演练适用于实验室类型环境，使用了示例公司名称、用户名称等。其目的在于提供一般性指导。这些演练不适合在未进行仔细审核并针对组织环境的独特点进行适应性改进的情况下在您的生产环境中直接使用。
### 委托对账单控制台的访问权限
AWS 账户所有者可以向需要查看或管理 AWS 账户的 AWS Billing and Cost Management数据的特定 IAM 用户委派访问权限。下面的说明将帮助您设置一个预先测试过的场景，使您可以获得配置账单权限的实践经验，而无需担心影响您的主 AWS生产账户。

此工作流程具有四个基本步骤。
![tutorial-billing](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-billing.png)
- 步骤 1：启用对您的 AWS 测试账户的账单数据的访问权限
   如果您创建单个 AWS 账户，只有 AWS 账户所有者 (AWS 账户根用户) 才能查看和管理账单信息。在账户所有者激活 IAM 访问权限并附加向用户或角色提供记账操作的策略之前，IAM 用户无法访问账单数据。要查看需要您以根用户身份登录的其他任务，请参阅[需要账户根用户的 AWS 任务](https://docs.amazonaws.cn/general/latest/gr/aws_tasks-that-require-root.html)。
- 步骤 2：创建授予账单数据权限的 IAM 策略
   对您的账户启用账单访问权限后，您仍必须向特定 IAM 用户或组显式授予账单数据访问权限。您应当使用客户托管策略授予此访问权限。
- 步骤 3：将账单策略附加到组
   将策略附加到组时，该组的所有成员都会收到与该策略关联的完整访问权限集。在此场景中，您将新账单策略附加到只包含需要账单访问权限的用户的组。
- 步骤 4：测试对账单控制台的访问权限
   一旦完成核心任务，您即可测试策略。测试确保策略按预期方式运行。

#### 先决条件
创建要在本教程中使用的测试 AWS 账户。在此账户中创建两个测试用户和两个测试组，如下表所示。请确保为每个用户分配密码，以便在后面的步骤 4 中可以登录
创建用户账户|创建和配置组账户
--|--

用户名称|组名|将用户添加为成员
--|--|--
FinanceManager|BillingFullAccessGroup|FinanceManager
FinanceUser|BillingViewAccessGroup|FinanceUser
#### 步骤 1：启用对您的 AWS 测试账户的账单数据的访问权限
1. 使用您的 AWS 账户电子邮件地址和密码以 AWS 账户根用户 身份登录 AWS 管理控制台。
2. 在导航栏上，选择您的账户名，然后选择 My Account。
3. 选择 IAM User and Role Access to Billing Information (IAM 用户和角色访问账单信息的权限) 旁的 Edit (编辑)。
4. 然后，选中 Activate IAM Access (激活 IAM 访问权限) 旁边的复选框并选择Update (更新)。
5. 注销控制台，然后执行步骤 2：创建授予账单数据权限的 IAM 策略。
#### 步骤 2：创建授予账单数据权限的 IAM 策略
接下来，创建自定义策略，以授予对 Billing and Cost Management 控制台中页面的查看权限和完整访问权限。有关 IAM 权限策略的一般信息，请参阅托管策略与内联策略。
1. 以具有管理员凭证的用户身份登录 AWS 管理控制台。根据 IAM 最佳实践，请勿使用根用户凭证登录。有关更多信息，请参阅[创建单独的 IAM 用户](创建单独的 IAM 用户)。
2. 通过以下网址打开 IAM 控制台：https://console.amazonaws.cn/iam/。
3. 在导航窗格中选择 Policies，然后选择 Create policy。
4. 在可视化编辑器选项卡上，选择选择服务以开始使用。然后，选择账单。
5. 按照以下步骤创建两个策略：

**完全访问权限**

    a. 选择选择操作，然后选中所有操作 (*) 旁边的复选框。您不需要为该策略选择资源或条件。
    b. 选择查看策略。
    c.  在 Review (审核) 页上的 Name (名称) 旁边键入 BillingFullAccess，然后选择 Create policy (创建策略) 以保存该策略。

**只读访问权限**

    a. 重复步骤 3 和 4。
    b. 选择选择操作，然后选中读取旁边的复选框。您不需要为该策略选择资源或条件。
    c. 选择查看策略。
    d. 在 Review (审核) 页面上，为 Name (名称) 键入 BillingViewAccess。然后，选择创建策略以保存该策略。

要查看 IAM 策略中向用户授予对 Billing and Cost Management 控制台的访问权限的每个可用权限的说明，请参阅账单权限说明。
#### 步骤 3：将账单策略挂载到组
现在您已经有了可用的自定义账单策略，可以将它们附加到之前创建的相应组。虽然可以将策略直接附加到用户或角色，但我们 (根据 IAM 最佳实践) 建议附加到组。有关更多信息，请参阅[使用组向 IAM 用户分配权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#use-groups-for-permissions)。
1. 在导航窗格中，选择 Policies 以显示您的 AWS 账户可用的策略的完整列表。要将各策略附加到适当的组，请遵循以下步骤：
  
    **完全访问权限**

    a. 在策略搜索框中键入 BillingFullAccess，然后选中策略名称旁的复选框。

    b. 选择 Policy actions，然后选择 Attach。

    c. 在身份（用户、组和角色）搜索框中键入 BillingFullAccessGroup，选中组名旁的复选框，然后选择 Attach policy (附加策略)。

    **只读访问权限**

    a. 在策略搜索框中键入 BillingViewAccess，然后选中策略名称旁的复选框。

    b. 选择 Policy actions，然后选择 Attach。

    c. 在身份（用户、组和角色）搜索框中键入 BillingViewAccessGroup，选中组名旁的复选框，然后选择 Attach policy (附加策略)。
2. 注销控制台，然后执行步骤 4：测试对账单控制台的访问权限。
#### 步骤 4：测试对账单控制台的访问权限
您可以通过两种方法测试用户访问权限。对于本教程，我们建议您以各测试用户身份登录来测试访问权限，这样可以了解用户体验。另一种可以选择的用户访问权限测试方法是使用 IAM 策略模拟器。如果您希望了解查看这些操作的有效结果的另一种方法，请遵循以下步骤。
##### 使用两个测试用户账户登录以测试账单访问权限
1. 使用 AWS 账户 ID 或账户别名、您的 IAM 用户名和密码登录 IAM 控制台。
2. 通过下面提供的步骤使用每个账户登录以比较不同的用户体验。
  
  **完全访问权限(**
  
  a. 以用户 FinanceManager 的身份登录您的 AWS 账户。
  b. 在导航栏上，选择 FinanceManager@<account alias or ID number> (FinanceManager@<账户别名或 ID 号>)，然后选择 Billing & Cost Management (账单和成本管理)。
  c. 浏览页面并选择不同的按钮以确保您有完全修改权限。

  **只读访问权限**

  a. 以用户 FinanceUser 的身份登录您的 AWS 账户。
  b. 在导航栏上，选择 FinanceUser@<account alias or ID number> (FinanceUser@<账户别名或 ID 号>)，然后选择 Billing & Cost Management (账单和成本管理)。
  c. 浏览页面。注意您是否可以正常显示成本、报告和账单数据。不过，如果您选择一个选项来修改值，会收到 Access Denied 消息。例如，在 Preferences 页面上，选中页面上的任意复选框，然后选择 Save preferences。控制台消息通知您需要 ModifyBilling 权限才能对该页面进行更改。
##### 通过在 IAM 策略模拟器中查看有效权限以测试账单访问权限
1. 在以下位置打开 IAM 策略模拟器：https://policysim.amazonaws.cn/。（如果您尚未登录 AWS，会提示您登录）。
2. 在 Users, Groups, and Roles 下，选择一个属于您最近将策略挂载到的组的成员的用户。
3. 在 Policy Simulator 下，选择 Select service，然后选择 Billing。
4. 在 Select actions 旁，选择 Select All。
5. 选择 Run Simulation，将列出的用户权限与所有可能的与账单相关权限选项进行比较，以确保应用了正确的权限。

### 使用 IAM 角色委派跨 AWS 账户的访问权限
本教程将指导您如何使用角色来委派对您拥有的不同 AWS 账户 (Production 和 Development) 中的资源的访问权限。您将与另一账户中的用户共享一个账户中的资源。通过以这种方式设置跨账户访问，您不需要在每个账户中创建单个 IAM 用户。此外，用户不必从一个账户注销并登录另一个账户，以便访问不同 AWS 账户中的资源。配置角色后，您将了解如何从 AWS 管理控制台、AWS CLI 和 API 中使用角色。

在本教程中，假定 Production 账户用于管理活动应用程序；Development 账户是一个沙盒测试环境，开发人员和测试人员可以用来自由测试应用程序。在每个账户中，应用程序信息存储在 Amazon S3 存储桶中。您管理 Development 账户中的 IAM 用户，该账户中有两个 IAM 组：Developer 和 Tester。两个组中的用户拥有在 Development 账户中工作的权限，能访问该账户中的资源。有时，开发人员必须更新 Production 账户中的活动应用程序。这些应用程序存储在名为 productionapp 的 Amazon S3 存储桶中。

在本教程结束时，您将在生产账户 (信任账户) 中拥有一个角色，该角色允许开发账户 (受信任账户) 中的用户访问生产账户中的 productionapp 存储桶。开发人员可以在 AWS 管理控制台中使用该角色访问 Production 账户中的 productionapp 存储桶。他们还可以使用通过该角色提供的临时凭证进行了身份验证的 API 调用来访问该存储桶。测试人员同样尝试使用该角色，但会失败。

此工作流程具有三个基本步骤：

![tutorial-cross-accounts](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-cross-accounts.png)
- 步骤 1 - 创建角色
   首先，您使用 AWS 管理控制台在生产账户（ID 号 999999999999）和开发账户（ID 号 111111111111）之间建立信任。可通过创建名为 UpdateApp 的 IAM 角色开始。当您创建角色时，将开发账户定义为可信实体，并指定一个权限策略，允许可信用户更新 productionapp 存储桶。
- 步骤 2 - 对角色授予访问权限
   在教程的此步骤中，您将修改 IAM 组策略，以便拒绝测试人员访问 UpdateApp 角色。这种情况下，因为 Testers 有 PowerUser 访问权限，我们必须明确拒绝其使用该角色的权限。
- 步骤 3 - 通过切换角色测试访问权限
   最后，以开发人员的身份使用 UpdateApp 角色更新生产账户中的 productionapp 存储桶。您可以了解如何通过 AWS 控制台、AWS CLI 和 API 访问角色。
#### 先决条件
本教程假定您已准备好以下各项：
- 您可以使用的两个单独的 AWS 账户，一个代表开发账户，另一个代表生产账户。
- Development 账户中的用户和组的创建和配置方式如下：
   User|组|权限
   --|--|--
   David|Developers|两个用户均能在 Development 账户下登录并使用 AWS 管理控制台。
  Theresa|Testers|
- 您不需要在 Production 账户中创建任何用户或组。
- 在生产账户中创建 Amazon S3 存储桶。在本教程中，我们将其称为 ProductionApp，但由于 S3 存储桶名称必须全局唯一，您必须使用具有其他名称的存储桶。
#### 步骤 1 - 创建角色
为了让一个 AWS 账户中的用户能够访问另一个 AWS 账户中的资源，应创建一个角色，在角色中定义哪些人可以访问该账户以及该角色对切换到它的用户授予哪些权限。

在教程的这一步中，您将在 Production 账户中创建角色，并将 Development 账户指定为可信实体。此外，限制更改角色的许可，只有 productionapp 存储桶的读写权限。任何人只要获得使用该角色的权限，就能对 productionapp 存储桶进行读写。

在创建角色之前，您需要开发 AWS 账户的账户 ID。账户 ID 是分配给每个 AWS 账户的唯一标识符。
##### 获取开发 AWS 账户 ID
1. 以开发账户管理员身份登录 AWS 管理控制台并在 https://console.amazonaws.cn/iam/ 上打开 IAM 控制台。
2. 在导航栏中，依次选择 Support 和 Support Center。Account Number 位于右上角 Support 菜单正下方。账户 ID 是 12 位数字。对于本方案，我们假设开发账户 ID 是 111111111111，但是，如果您在测试环境中重新构造本方案，应使用有效的账户 ID。
##### 在可由 Development 账户使用的 Production 账户中创建角色
1. 以 Production 账户管理员身份登录 AWS 管理控制台并打开 IAM 控制台。
2. 创建角色之前，准备好定义角色所需权限的托管策略。您可在以后的步骤中将此策略附加到角色。

您想要设置针对 productionapp 存储桶的读写权限。尽管 AWS 提供了一些 Amazon S3 托管策略，但这些策略并未提供对单个 Amazon S3 存储桶的读写访问权限。您可以创建自己的自定义策略。

在左侧的导航窗格中，选择 Policies，然后选择 Create policy。
3. 选择 JSON 选项卡，然后复制以下 JSON 策略文档中的文本。将该文本粘贴到 JSON 文本框中，并将资源 ARN (arn:aws-cn:s3:::productionapp) 替换为与您的 S3 存储桶对应的真实资源 ARN。
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
       ],
      "Resource": "arn:aws-cn:s3:::productionapp"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws-cn:s3:::productionapp/*"
    }
  ]
}
```
    ListBucket 许可允许用户浏览 productionapp 存储桶中的对象。GetObject、PutObject、DeleteObject 权限允许用户查看、更新和删除 productionapp 存储桶中的内容。

4. 完成后，选择查看策略。策略验证程序将报告任何语法错误。
> 您可以随时在可视化编辑器和 JSON 选项卡之间切换。不过，如果您进行更改或在 Visual editor (可视化编辑器) 选项卡中选择 Review policy (查看策略)，IAM 可能会调整您的策略结构以针对可视化编辑器进行优化。有关更多信息，请参阅调整策略结构。
5. 在 Review (查看) 页面上，键入 read-write-app-bucket 作为策略名称。查看策略摘要以查看您的策略授予的权限，然后选择创建策略以保存您的工作。新策略会显示在托管策略列表中。
6. 在左侧的导航窗格中，选择 Roles，然后选择 Create role。
7. 选择 Another AWS account (其他 AWS 账户) 角色类型。
8. 对于 Account ID，键入 Development 账户 ID。
> 本教程使用示例账户 111111111111 作为 Development 账户。您应使用有效的账户 ID。如果使用无效的账户 ID，如 111111111111，IAM 不会让您创建新角色。
>
> 现在，您不必要求外部 ID 或要求用户拥有 Multi-Factor Authentication (MFA) 就可以代入该角色。因此，请将这些选项保持未选中状态。有关更多信息，请参阅[在 AWS 中使用多重身份验证 (MFA)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa.html)。
9.  选择 Next: Permissions 设置将与角色关联的权限。
10. 选中您之前创建的策略旁的框。
     >   对于 Filter，选择 Customer managed 对列表进行筛选，使其只包含您创建的策略。这会隐藏 AWS 创建的策略，更容易找到您所需要的策略。

      然后选择 Next: Tagging (下一步: 标记)。
11. （可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅 标记 IAM 实体。
12. 选择 Next: Review (下一步: 审核)，然后为角色名称键入 UpdateApp。
13. (可选) 对于 Role description，键入新角色的描述。
14. 检查角色后，选择 Create role：UpdateApp 角色显示在角色列表中。
现在，您必须获取该角色的 Amazon 资源名称 (ARN)，这是角色的唯一标识。当您修改 Developer 和 Tester 组的策略时，您将指定角色的 ARN 以授予或拒绝权限。
##### 如何获取用于 UpdateApp 的 ARN
1. 在 IAM 控制台的导航窗格中，选择 Roles。
2. 在角色列表中，选择 UpdateApp 角色。
3. 在详细信息窗格的 Summary (摘要) 部分中，复制 Role ARN (角色 ARN) 值。

Production 账户的账户 ID 是 999999999999，因此角色 ARN 是 arn:aws-cn:iam::999999999999:role/UpdateApp。确保为您的“生产”账户提供真实的 AWS 账户 ID。

此时，您已经通过在 Production 账户中创建一个将 Development 账户指定为可信委托人的角色，在 Production 与 Development 账户之间建立了信任关系。您还可以定义切换到 UpdateApp 角色的用户可执行哪些操作。

接下来，修改这些组的权限。
#### 步骤 2 - 对角色授予访问权限
现在，Testers 和 Developers 组成员都拥有相应权限，让他们能够自由测试 Development 账户中的应用程序。下面是添加切换到角色的权限所需执行的步骤。
##### 修改 Developers 组以允许他们切换到 UpdateApp 角色
1. 以开发账户中的管理员身份登录，打开 IAM 控制台。
2. 择 Groups，然后选择 Developers。
3. 选择 Permissions 选项卡，展开 Inline Policies 部分，然后选择 Create Group Policy。如果还没有内联策略，则不会显示此按钮。这时应选择“To create one, click here”后的链接。
4. 选择 Custom Policy，然后选择 Select 按钮。
5. 键入策略名称，如 allow-assume-S3-role-in-production。
6. 添加以下策略语句，允许对生产账户中的 AssumeRole 角色执行 UpdateApp 操作。请确保将 Resource 元素中的 PRODUCTION-ACCOUNT-ID 更改为 Production 账户的实际 AWS 账户 ID。
   ```
   {
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws-cn:iam::PRODUCTION-ACCOUNT-ID:role/UpdateApp"
    }
    }
   ```
   Allow 效果显式允许 Developers 组访问生产账户中的 UpdateApp 角色。尝试访问该角色的任何开发人员都会成功。
7. 选择 Apply Policy 将策略添加到 Developer 组。
##### 修改 Testers 组以拒绝担任 UpdateApp 角色的权限
> 在大多数环境中，可能不需要执行以下步骤。但是，如果您使用高级用户权限，则某些组可能已能够切换角色。以下过程介绍如何对 Testers 组添加“Deny”权限，以确保他们无法担任角色。如果您的环境中不需要此过程，建议不要添加该权限。“Deny”权限会让整个权限体系更为复杂，难以管理和理解。仅当您没有更好的选择时才使用“Deny”权限。
1. 选择 Groups，然后选择 Testers。
2. 选择 Permissions 选项卡，展开 Inline Policies 部分，然后选择 Create Group Policy。
3. 选择 Custom Policy，然后选择 Select 按钮。
4. 键入策略名称，如 deny-assume-S3-role-in-production。
5. 添加以下策略语句以拒绝对 AssumeRole 角色执行的 UpdateApp 操作。请确保将 Resource 元素中的 PRODUCTION-ACCOUNT-ID 更改为 Production 账户的实际 AWS 账户 ID。
   ```
   {
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Deny",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws-cn:iam::PRODUCTION-ACCOUNT-ID:role/UpdateApp"
    }
    }
   ```
  Deny 效果显式拒绝 Testers 组访问生产账户中的 UpdateApp 角色。任何尝试访问该角色的测试人员都会获得一条拒绝访问信息。
6. 选择 Apply Policy 将策略添加到 Tester 组。

Developers 组现在有相应权限，可以使用生产账户中的 UpdateApp 角色。Testers 组将无法使用 UpdateApp 角色。

接下来，您将了解开发人员 David 如何能够使用 AWS 管理控制台 、AWS CLI 命令和 AssumeRole API 调用访问 Production 账户中的 productionapp 存储桶。
#### 步骤 3 - 通过切换角色测试访问权限
完成本教程的前两个步骤后，您将具有一个可以授予对生产账户中资源的访问权限的角色。您还将在 Development 账户中有一个组，该组中的用户可以使用该角色。现在该角色已准备就绪可供使用。此步骤讨论如何对从 AWS 管理控制台、AWS CLI 和 AWS API 切换到该角色进行测试。
> **重要：**只有当您以 IAM 用户或联合用户身份登录时，才能切换角色。另外，如果启动 Amazon EC2 实例来运行应用程序，则应用程序可以通过实例配置文件承担角色。以 AWS 账户根用户身份登录后无法切换至角色。
##### 切换角色 (控制台)
如果 David 需要在 AWS 管理控制台 中以 Production 环境工作，他可以通过使用 Switch Role (切换角色) 实现。他指定账户 ID 或别名以及角色名称，他的权限会立即切换为该角色允许的权限。然后，他可以通过控制台使用 productionapp 存储桶，但是无法使用生产中的其他任何资源。当 David 使用角色时，他无法使用其在 Development 账户中的高级用户权限。这是因为，一次仅一组权限能够生效。

> **重要**：使用 AWS 管理控制台切换角色仅对不需要 ExternalId 的账户有效。如果您向第三方授予对您账户的访问权限，并且在权限策略的 Condition 元素中需要 ExternalId，则第三方只能通过使用 AWS API 或命令行工具访问您的账户。第三方不能使用控制台，因为它不能提供 ExternalId 值。有关此方案的更多信息，请参阅 AWS 安全博客 中的[如何在向第三方授予对 AWS 资源的访问权时使用外部 ID](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html)和[如何启用对 AWS 管理控制台的跨账户访问](http://amazonaws-china.com/blogs/security/how-to-enable-cross-account-access-to-the-aws-management-console)。

David 可以使用两种方法进入切换角色页：
  + David 收到其管理员提供的一个链接，该链接指向一个预定义的“Switch Role (切换角色)”配置。该链接在 Create role 向导最后一页上或在跨账户角色的 Role Summary 页面上提供给管理员。选择该链接将引导 David 进入已填写 Account ID 和 Role name 字段的 Switch Role 页面。David 只需选择 Switch Role 即可完成角色切换。
  + 管理员不会通过电子邮件发送该链接，而是发送账户 ID 号和角色名称值。David 必须手动键入这些值以切换角色。以下步骤对此进行说明。
  
##### 如何担任角色
1. David 使用开发组中他的常规用户登录到 AWS 控制台。
2. 他选择管理员通过电子邮件发送给他的链接。该链接将他引导至已填写账户 ID 或别名和角色名称信息的 Switch Role 页面。或者，他在导航栏上选择其姓名 (“Identity”菜单)，然后选择 Switch Role。
   
   如果这是 David 首次通过这种方式尝试访问 Switch Role 页面，则他会首先登录初始 Switch Role 页面。此页面提供有关切换角色如何使用户可以跨 AWS 账户管理资源的其他信息。David 必须选择此页面上的 Switch Role 按钮才能完成此过程的其余步骤。
3. 接下来，为了访问角色，David 必须手动键入生产账户 ID 号 (999999999999) 和角色名称 (UpdateApp)。
   
   此外，为帮助他了解当前哪个角色（及关联权限）处于活动状态，他在 Display Name 文本框中键入 PRODUCTION，选择红色选项，然后选择 Switch Role。
4. David 现在可以通过 Amazon S3 控制台使用 Amazon S3 存储桶，或使用 UpdateApp 角色有权限的其他任何资源。
5. David 可在完成自己应完成的工作后返回到其初始权限。为此，他可以选择导航栏上的 PRODUCTION 角色显示名称，然后选择 Back to David @ 111111111111。
6. 当 David 下次要切换角色，在导航栏中选择“Identity”菜单时，他将看到 PRODUCTION 条目仍在上次的位置。他可以选择该条目立即切换角色，无需重新输入账户 ID 和角色名称。
##### 切换角色 (AWS CLI)
如果 David 需要在生产环境中的命令行上工作，他可以使用[AWS CLI](http://www.amazonaws.cn/cli/)做到这一点。他运行 aws sts assume-role 命令并传递角色 ARN 以获取该角色的临时安全凭证。然后，他在环境变量中配置这些凭证，使后续的 AWS CLI 命令能够使用该角色的权限执行。当 David 使用角色时，他不能同时使用他在开发账户中的高级用户权限，因为同一时间只有一组权限有效。

请注意，所有访问密钥和令牌都只是示例，不能原样照用。请用您的实际环境的适当值替换。
##### 如何担任角色
1. David 打开命令提示符窗口，运行以下命令确认 AWS CLI 客户端正在工作：
2. 他通过运行以下命令开始角色切换过程，以切换到生产账户中的 UpdateApp 角色。他从创建该角色的管理员处获得了角色 ARN。该命令还需要您提供一个会话名称，您可以选择任何文本作为该名称。
   ```
   aws sts assume-role --role-arn "arn:aws-cn:iam::999999999999:role/UpdateApp" --role-session-name "David-ProdUpdate"
   ```
   然后 David 在输出中看到以下内容：
   ```
   {
    "Credentials": {
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "SessionToken": "AQoDYXdzEGcaEXAMPLE2gsYULo+Im5ZEXAMPLEeYjs1M2FUIgIJx9tQqNMBEXAMPLE
    CvSRyh0FW7jEXAMPLEW+vE/7s1HRpXviG7b+qYf4nD00EXAMPLEmj4wxS04L/uZEXAMPLECihzFB5lTYLto9dyBgSDy
    EXAMPLE9/g7QRUhZp4bqbEXAMPLENwGPyOj59pFA4lNKCIkVgkREXAMPLEjlzxQ7y52gekeVEXAMPLEDiB9ST3Uuysg
    sKdEXAMPLE1TVastU1A0SKFEXAMPLEiywCC/Cs8EXAMPLEpZgOs+6hz4AP4KEXAMPLERbASP+4eZScEXAMPLEsnf87e
    NhyDHq6ikBQ==",
            "Expiration": "2014-12-11T23:08:07Z",
            "AccessKeyId": "AKIAIOSFODNN7EXAMPLE"
        }
    }
   ```
3. David 在输出的“Credentials”部分中看到了他所需要的三个部分。
    + AccessKeyId
    + SecretAccessKey
    + SessionToken
  
    David 需要配置 AWS CLI 环境，以在后续的调用中使用这些参数。有关各种证书配置方法的信息，请参阅配置[AWS Command Line Interface](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence)。您不能使用 aws configure 命令，因为它不支持捕获会话令牌。但是，您可手动将信息键入到配置文件中。由于这些是到期时间相对较短的临时证书，将它们添加到您当前的命令行会话环境中是最简单的。
4. 为了将三个值添加到环境，David 将上一步的输出剪切并粘贴到以下命令中。请注意，您可能希望剪切并粘贴到简单文本编辑器中，以处理会话令牌输出中的换行问题。即使此处为清晰起见，将输出显示为换行格式，在添加时也必须是单个长字符串形式。
> 以下示例显示了 Windows 环境中的命令，其中“set”是创建环境变量的命令。在 Linux 或 Mac 计算机上，您可以使用“export”命令。该示例的其余部分对于三种环境均有效。
```
set AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
set AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
set AWS_SESSION_TOKEN=AQoDYXdzEGcaEXAMPLE2gsYULo+Im5ZEXAMPLEeYjs1M2FUIgIJx9tQqNMBEXAMPLECvS
Ryh0FW7jEXAMPLEW+vE/7s1HRpXviG7b+qYf4nD00EXAMPLEmj4wxS04L/uZEXAMPLECihzFB5lTYLto9dyBgSDyEXA
MPLEKEY9/g7QRUhZp4bqbEXAMPLENwGPyOj59pFA4lNKCIkVgkREXAMPLEjlzxQ7y52gekeVEXAMPLEDiB9ST3UusKd
EXAMPLE1TVastU1A0SKFEXAMPLEiywCC/Cs8EXAMPLEpZgOs+6hz4AP4KEXAMPLERbASP+4eZScEXAMPLENhykxiHen
DHq6ikBQ==
```

此时，以下所有命令都在这些凭证确定的角色的权限下运行。对 David 而言就是 UpdateApp 角色。
5. 运行该命令访问 Production 账户中的资源。在此示例中，David 仅使用以下命令列出其 S3 存储桶的内容。
   ```
   aws s3 ls s3://productionapp
   ```
 
  因为 Amazon S3 存储桶名称通常是唯一的，所以无需指定拥有存储桶的账户 ID。要访问其他 AWS 服务的资源，请参阅该服务的 AWS CLI 文档，了解引用其资源所需使用的命令和语法。
##### 使用 AssumeRole (AWS API)
当 David 需要通过代码来更新生产账户时，他执行 AssumeRole 调用来担任 UpdateApp 角色。该调用返回临时凭证，他可以使用这些凭证访问生产账户中的 productionapp 存储桶。使用这些凭证，David 可以调用 API 以更新 productionapp 存储桶。但是，即使他在 Development 账户中拥有高级用户权限，也无法通过调用 API 来访问 Production 账户中的任何其他资源。
1. David 把 AssumeRole 视为应用程序的一个段调用。他必须指定 UpdateApp ARN：arn:aws-cn:iam::999999999999:role/UpdateApp。
   
     AssumeRole 调用的响应包括临时凭证，其中有 AccessKeyId、SecretAccessKey 和 Expiration 时间，后者指示凭证到期而您必须请求新凭证的时间。
2. David 使用那些临时证书调用 s3:PutObject 升级 productionapp 存储段。他将凭证作为 AuthParams 参数传递给 API 调用。由于临时角色凭证只有 productionapp 存储桶的读写权限，因此对生产账户的任何其他操作都会被拒绝。
    
有关代码示例 (使用 Python)，请参阅[切换至 IAM 角色 (AWS API)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-api.html)。
```
import boto3

# The calls to AWS STS AssumeRole must be signed with the access key ID
# and secret access key of an existing IAM user or by using existing temporary 
# credentials such as those from antoher role. (You cannot call AssumeRole 
# with the access key for the root account.) The credentials can be in 
# environment variables or in a configuration file and will be discovered 
# automatically by the boto3.client() function. For more information, see the 
# Python SDK documentation: 
# http://boto3.readthedocs.io/en/latest/reference/services/sts.html#client

# create an STS client object that represents a live connection to the 
# STS service
sts_client = boto3.client('sts')

# Call the assume_role method of the STSConnection object and pass the role
# ARN and a role session name.
assumed_role_object=sts_client.assume_role(
    RoleArn="arn:aws-cn:iam::account-of-role-to-assume:role/name-of-role",
    RoleSessionName="AssumeRoleSession1"
)

# From the response that contains the assumed role, get the temporary 
# credentials that can be used to make subsequent API calls
credentials=assumed_role_object['Credentials']

# Use the temporary credentials that AssumeRole returns to make a 
# connection to Amazon S3  
s3_resource=boto3.resource(
    's3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken'],
)

# Use the Amazon S3 resource object that is now configured with the 
# credentials to access your S3 buckets. 
for bucket in s3_resource.buckets.all():
    print(bucket.name)
```

### 创建客户托管策略 (Create and Attach Your First Customer Managed Policy)
在本教程中，您将使用 AWS 管理控制台创建一个[客户托管策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#customer-managed-policies)，然后将该策略附加到您的 AWS 账户中的一个 IAM 用户。您创建的策略允许具有只读权限的 IAM 测试用户直接登录 AWS 管理控制台。

此工作流程具有三个基本步骤：

![Create Managed Policy](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-managed-policies.png)
#### 先决条件
要执行本教程中的步骤，您必须已具备以下内容：
+ 可使用 IAM 用户身份登录的具有管理权限的 AWS 账户。
+ 未分配有如下权限或组成员资格的测试 IAM 用户：  
  
  用户名称|组|权限
   --|--|--
  PolicyUser|<无>|无>
  
#### 步骤 1：创建策略
在该步骤中，您创建一个允许任何附加用户（具有 IAM 数据的只读访问权限）登录到 AWS 管理控制台的客户托管策略。
1. 使用具有管理员权限的用户身份通过 https://console.amazonaws.cn/iam/ 登录 IAM 控制台。
2. 在导航窗格中，选择 Policies。
3. 在内容窗格中，选择创建策略。
4. 选择 JSON 选项卡，然后复制以下 JSON 策略文档中的文本。将该文本粘贴到 JSON 文本框中。
     ```
     {
        "Version": "2012-10-17",
        "Statement": [ {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:Get*",
                "iam:List*"
            ],
            "Resource": "*"
        } ]
    }
     ```
5. 完成后，选择查看策略。策略验证程序将报告任何语法错误。
6. 在 Review (查看) 页面上，键入 UsersReadOnlyAccessToIAMConsole 作为策略名称。查看策略摘要以查看您的策略授予的权限，然后选择创建策略以保存您的工作。

将在托管策略列表中显示新策略，并已准备好附加该策略。
#### 步骤 2：附加策略
1. 在 IAM 控制台的导航窗格中，选择 Policies。
2. 在策略列表顶部的搜索框中，开始键入 UsersReadOnlyAccesstoIAMConsole，直到显示您的策略为止，然后选中列表中 UsersReadOnlyAccessToIAMConsole 旁边的框。
3. 选择 Policy Actions 按钮，然后选择 Attach。
4. 对于 Filter，选择 Users。
5. 在搜索框中开始键入 PolicyUser，直到该用户在列表上显示为止，然后选中列表中该用户旁边的框。
6. 选择 Attach Policy。

您已将策略挂载到 IAM 测试用户，这意味着现在该用户具有 IAM 控制台的只读访问权限。
#### 步骤 3：测试用户访问权限
对于本教程，我们建议您以测试用户身份登录来测试访问权限，这样可以观察结果并了解用户体验。
1. 使用您的 PolicyUser 测试用户通过 https://console.amazonaws.cn/iam/ 登录 IAM 控制台。
   
    ![IAM Alias Login](https://github.com/wbb1975/blogs/blob/master/aws/images/AccountAlias.console.png)
2. 浏览控制台的各个页面并尝试创建新的用户或组。请注意，PolicyUser 可以显示数据，但无法创建或修改现有 IAM 数据。
### 让您的用户能够配置他们自己的凭证和 MFA 设置(Enable Your Users to Configure Their Own Credentials and MFA Settings)
您可以允许您的用户在 My Security Credentials (我的安全凭证) 页面上自行管理他们自己的多重验证 (MFA) 设备和凭证。您可以使用 AWS 管理控制台为少量用户配置凭证 (访问密钥、密码、签名证书和 SSH 公有密钥) 和 MFA 设备。但随着用户数增加，这个任务很快会变得非常耗时。安全最佳实践指定用户应定期更改其密码并轮换其访问密钥。他们还应该删除或停用不再需要的凭证。我们还强烈建议他们使用 MFA 进行敏感操作。本教程旨在介绍如何实现这些最佳实践，而不给您的管理员带来负担。

本教程介绍如何允许用户访问 AWS 服务，不过此操作仅限于用户使用 MFA 登录的情况。如果未使用 MFA 设备登录，则用户无法访问其他服务。

此工作流程具有三个基本步骤。

![MFA](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-mfa.png)
#### 步骤 1：创建策略以实施 MFA 登录