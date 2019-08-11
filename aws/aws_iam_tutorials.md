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
