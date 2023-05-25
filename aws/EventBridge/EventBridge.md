# EventBridge

## 什么是亚马逊 EventBridge？

EventBridge 是一项无服务器服务，它使用事件将应用程序组件连接在一起，使您可以更轻松地构建可扩展的事件驱动应用程序。使用它可以将事件从自主开发的应用程序、AWS服务和第三方软件等来源路由到整个组织的消费者应用程序。 EventBridge 提供了一种简单、一致的方式来提取、筛选、转换和传送事件，因此您可以快速构建新的应用程序。

EventBridge 事件总线非常适合在事件驱动的服务之间 many-to-many 路由事件。[EventBridge Pipes](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-pipes.html) 旨在 point-to-point 整合这些[源](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-pipes-event-source.html)和[目标](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-pipes-event-target.html)，支持高级转换和[增益(enrichment)](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-pipes.html#pipes-enrichment)。

### 工作原理

EventBridge 接收[事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-events.html)、环境变化的指标，并应用[规则](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rules.html)将事件路由到[目标](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-targets.html)。规则根据事件的结构（称为 [“事件模式”](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)）或计划将事件与目标匹配。例如，当 Amazon EC2 实例从待处理变为正在运行时，您可以制定将事件发送到 Lambda 函数的规则。

所有发生的事件都与[事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus.html)相关联。 EventBridge 规则绑定到单个事件总线，因此它们只能应用于该事件总线上的事件。您的账户有一个默认的事件总线，用于接收来自AWS服务的事件，您可以创建自定义事件总线来发送或接收来自其它账户或地区的事件。

当AWS合作伙伴想要向AWS客户账户发送活动时，他们会设置[合作伙伴事件来源](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-saas.html)。然后，客户必须将事件总线与合作伙伴事件源相关联。

EventBridge [API 目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-destinations.html)是 HTTP 端点，您可以将其设置为规则的目标，就像向AWS服务或资源发送事件数据一样。通过使用 API 目标，您可以使用 REST API 调用在AWS服务、集成的 SaaS 应用程序和外部应用程序之间路由事件。创建 API 目标时，您可以指定要用于该目标的连接。每个连接都包含有关授权类型的细节以及授权访问 API 目标端点的参数信息。

要在 EventBridge 将事件传递给目标之前对其中的文本进行自定义，请在信息传递到目标之前使用[输入转换器](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html)对其进行编辑。

您可以[存档](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-archive-event.html)或保存事件，然后稍后从存档中[重播](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-replay-archived-event.html)这些事件。存档对于测试应用程序很有用，因为您可以使用大量事件，而不必等待新事件。

在构建使用 EventBridge 的无服务器应用程序时，无需生成事件即可了解典型事件的事件模式会很有帮助。事件模式在[架构](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-schema.html)中进行了描述，这些模式可用于 EventBridge 上的AWS服务生成的所有事件。您也可以为非来自AWS服务的事件创建或上传自定义架构。一旦有了事件的架构，就可以下载常用编程语言的代码绑定。

要组织 EventBridge 上的AWS资源或跟踪成本，您可以为AWS资源分配自定义标签或[标签](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-tagging.html)。使用[基于标签的策略](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-tag-policies.html)，您可以控制资源在 EventBridge 中可以做什么和不能做什么。

除了基于标签的策略外，还 EventBridge 支持[基于身份](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html)和[基于资源](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-resource-based.html)的策略来控制访问 EventBridge 的权限。使用基于身份的策略来控制群组、角色或用户的权限。使用基于资源的策略为每种资源授予特定权限，例如 Lambda 函数或 Amazon SNS 主题。

> **注意**: EventBridge 以前称为 Amazon CloudWatch Events。您在 CloudWatch 事件中创建的默认事件总线和规则也会显示在 EventBridge 控制台中。 EventBridge 使用相同 CloudWatch 的事件 API，因此您使用 CloudWatch 事件 API 的代码保持不变。添加的新 EventBridge 功能不会添加到 CloudWatch 活动中。

## 开始使用 Amazon EventBridge

EventBridge 的基础是创建将[事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-events.html)路由到[目标](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-targets.html)的[规则](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rules.html)。在这一部分，您将创建基本规则。有关特定场景和特定目标的教程，请参阅 [Amazon EventBridge](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-tutorial.html)。

### 在亚马逊 EventBridge 创建规则

要为事件创建规则，请指定在 EventBridge 收到与规则中事件模式相匹配的事件时要采取的操作。当事件匹配时，EventBridge 将事件发送到指定的目标并触发规则中定义的操作。

当您AWS账户中的某个AWS服务发出一个事件时，它始终会发送到您账户的默认[事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus.html)。要编写一个规则来匹配来自您账户AWS中的服务的事件，您必须将此规则与默认事件总线相关联。

#### 为AWS服务创建规则

1. 通过 https://console.aws.amazon.com/events/ 打开亚马逊 EventBridge 控制台。
2. 在导航窗格中，选择 **Rules (规则)**。
3. 选择 **Create rule (创建规则)**。
4. 为规则输入名称和描述。规则不能与同一区域中和同一事件总线上的另一个规则名称相同。
5. 对于 **Event bus（事件总线）**，请选择要与此规则关联的事件总线。如果您希望此规则对来自您自己的账户的匹配事件触发，请选择 AWS 默认事件总线。当您账户中的某个 AWS 服务发出一个事件时，它始终会发送到您账户的默认事件总线。
6. 对于 **Rule type（规则类型）**，选择 **Rule with an event pattern（具有事件模式的规则）**。
7. 选择**下一步**。
8. 对于 **Event source（事件源）**，选择 **AWS services（服务）**。
9. （可选）对于示例事件，选择事件的类型。
10. 对于事件模式，请执行以下操作之一：
    
    + 要使用模板创建您的事件模式，请选择 **Event pattern form（事件模式形式）**，然后选择 **Event source（事件源）**和**事件类**，如果您选择 **All Events（所有事件）**作为事件类型，此 AWS 服务发送的所有事件将会匹配规则。要自定义模板，请选择 **Custom pattern (JSON editor)**（自定义模式（JSON 编辑器））进行您的更改。
    + 要使用自定义事件模式，请选择 **Custom pattern (JSON editor)**（自定义模式（JSON 编辑器）），然后创建您的事件模式。
11. 选择 **Next（下一步）**。
12. 对于 **Target types（目标类型）**，选择 *AWS service（服务）**。
13. 对于**选择目标**，选择在 EventBridge 检测到与事件模式匹配的事件时要向其发送信息的AWS服务。
14. 显示的字段因您选择的服务而异。根据需要输入特定于此目标类型的信息。
15. 对于许多目标类型， EventBridge 需要权限以便将事件发送到目标。在这些情况下， EventBridge 可以创建运行事件所需的 IAM 角色。请执行下列操作之一：
    
    + 若要自动创建 IAM 角色，请选择 **Create a new role for this specific resource (为此特定资源创建新角色)**。
    + 要使用您之前创建的 IAM 角色，请选择 **Use existing role（使用现有角色）**，然后从下拉列表中选择现有角色。
16. （可选）对于 **Additional settings（其它设置）**，执行以下操作：
    
    + 对于 **Maximum age of event（事件的最大时长）**，输入一分钟（00:01）与 24 小时（24:00）之间的值。
    + 对于重试尝试，输入 0 到 185 之间的数字。
    + 对于死信队列，选择是否使用标准 Amazon SQS 队列作为死信队列。 EventBridge 如果与此规则匹配的事件未成功传递到目标，会将这些事件发送到死信队列。请执行下列操作之一：
      - 选择**无**不使用死信队列。
      - 在当前 AWS 帐户中选择**选择一个Amazon SQS队列用作死信队列**，然后从下拉列表中选择要使用的队列。
      - 选择**在其它 Amazon SQS 队列中选择其它队列 AWS 帐户作为死信队列**，然后输入要使用的队列的 ARN。您必须将基于资源的策略附加到队列，以授予向其发送消息的 EventBridge 权限。有关更多信息，请参阅[授死信队列的权限](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rule-dlq.html#eb-dlq-perms)

17. （可选）选择 **Add another target（添加其它目标）**，以为此规则添加其它目标。
18. 选择**下一步**。
19. （可选）为规则输入一个或多个标签。有关更多信息，请参阅[亚马逊 EventBridge 标签](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-tagging.html)
20. 选择**下一步**。
21. 查看规则详细信息并选择 **Create rule（创建规则）**。

## 亚马逊 EventBridge 事件总线

事件总线是接收[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)的管道。与事件总线关联的[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)会在事件到达时对其进行评估。每条规则都会检查事件是否符合规则的标准。您将规则与特定的事件总线相关联，因此该规则仅适用于该事件总线接收的事件。

要管理事件总线的权限，可以为其配置[基于资源的策略](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-resource-based.html)。基于资源的策略指定允许哪些事件，以及哪些实体有权为事件创建或修改规则或目标。例如，您可以使用事件总线上的策略来允许或拒绝来自不同 AWS 账户或 AWS 地区中的规则或事件总线等来源的事件。通过使用策略，您可以将来自应用程序或组织的所有事件聚合到一个账户和区域中。

您可以为每个事件总线配置最多 300 个规则。如果您的环境中有超过 300 条规则，则可以在您的账户中创建自定义事件总线，然后再将 300 条规则与每条事件总线关联。您可以通过为不同的服务创建具有不同权限的事件总线，自定义账户中接收事件的方式。

最常见的事件总线有：

- 每个账户中的默认事件总线会接收来自 AWS 服务的事件。
- 自定义事件总线向不同的账户发送事件或从另一个账户接收事件。
- 自定义事件总线向不同区域发送事件或接收来自不同区域的事件，以将事件聚合到单个位置。
- 合作伙伴活动总线接收来自 SaaS 合作伙伴的事件。有关更多信息，请参阅[使用亚马逊 EventBridge 接收来自 SaaS 合作伙伴的事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-saas.html)。

### 事件总线的权限

在您的AWS账户中的默认[事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus.html)进允许来自同一个账户的事件。您可以通过附加[基于资源的策略](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-resource-based.html)来对事件总线额外授权。使用基于资源的策略，您可以允许来自其它账户的 `PutEvents`、`PutRule`, 和 `PutTargets` API 调用。您还可以使用[IAM 条件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-conditions.html) 向组织授予权限的策略中，允许应用[标签](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-tagging.html)，或者将事件过滤到仅来自特定规则或帐户的事件。您可以在创建事件总线时或之后为事件总线设置基于资源的策略。

EventBridge APIs 如 `PutRule`、`PutTargets`、`DeleteRule`、`RemoveTargets`、`DisableRule`, 和 `EnableRule` 接受事件总线名字作为参数，也接受事件总线 ARN。使用这些参数通过 API 引用跨账户或跨区域的事件总线。例如，您可以调用 `PutRule` 在不同账户的事件总线上创建一个[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)使用，而无需代入角色。

您可以将本主题中的示例策略附加到 IAM 角色，以授予向其它账户或区域发送事件的权限。使用 IAM 角色设置组织控制策略和限制谁可以将事件从您的账户发送到其它账户。当规则的目标是事件总线时，我们建议始终使用 IAM 角色。您可以使用附加 IAM 角色调用 `PutTarget`。有关创建规则以将事件发送到其它账户或区域的信息，请参阅在[AWS账户之间发送和接收亚马逊 EventBridge 事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html)。

#### 管理事件总线权限

要修改现有事件总线的权限，请按照以下过程操作。有关如何使用的信息AWS CloudFormation要创建事件总线策略，请参阅[AWS::Events::EventBus策略](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-eventbuspolicy.html)。

##### 管理现有事件总线的权限

1. 打开 Amazon EventBridge 控制台在https://console.aws.amazon.com/events/.
2. 在左侧导航窗格中，选择**事件总线(()).
3. 在**名称**中，选择要管理权限总线的名称。

   如果资源策略附加到事件总线，则会显示该策略。
4. 选择**管理权限**，然后执行以下操作之一：

   + 输入包含要为事件总线授予的权限的策略。您可以粘贴来自其它来源的策略，也可以输入策略的 JSON。
   + 要使用策略的模板，请选择**加载模板**. 根据您的环境修改策略，并添加您授权策略中的委托人使用的其它操作。

5. 选择 **Update（更新）**。

该模板提供了您可以针对自己的账户和环境自定义的策略声明示例。Template 是无效策略。您可以根据自己的用例修改模板，也可以复制其中一个示例策略并对其进行自定义。

该模板加载的策略包括如何向账户授予使用使用 `PutEvents` 的权限、如何向组织授予权限，以及如何向账户授予管理账户中规则的权限。您可以为特定账户自定义模板，然后从模板中删除其它部分。本主题后文中将会包含更多示例策略。

如果您尝试更新总线的权限，但策略包含错误，则会显示一条错误消息，指出策略中的特定问题。

```

  ### Choose which sections to include in the policy to match your use case. ###
  ### Be sure to remove all lines that start with ###, including the ### at the end of the line. ###

  ### The policy must include the following: ###

  {
    "Version": "2012-10-17",
    "Statement": [

      ### To grant permissions for an account to use the PutEvents action, include the following, otherwise delete this section: ###

      {

        "Sid": "allow_account_to_put_events",
        "Effect": "Allow",
        "Principal": {
          "AWS": "<ACCOUNT_ID>"
        },
        "Action": "events:PutEvents",
        "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/default"
      },

      ### Include the following section to grant permissions to all members of your AWS Organizations to use the PutEvents action ###

      {
        "Sid": "allow_all_accounts_from_organization_to_put_events",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "events:PutEvents",
        "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/default",
        "Condition": {
          "StringEquals": {
            "aws:PrincipalOrgID": "o-yourOrgID"
          }
        }
      },

      ### Include the following section to grant permissions to the account to manage the rules created in the account ###

      {
        "Sid": "allow_account_to_manage_rules_they_created",
        "Effect": "Allow",
        "Principal": {
          "AWS": "<ACCOUNT_ID>"
        },
        "Action": [
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:RemoveTargets",
          "events:DisableRule",
          "events:EnableRule",
          "events:TagResource",
          "events:UntagResource",
          "events:DescribeRule",
          "events:ListTargetsByRule",
          "events:ListTagsForResource"],
        "Resource": "arn:aws:events:us-east-1:123456789012:rule/default",
        "Condition": {
          "StringEqualsIfExists": {
            "events:creatorAccount": "<ACCOUNT_ID>"
          }
        }
    }]
}
```

#### 示例策略：将事件发送到其它账户的默认总线

以下示例策略授予账户 `111122223333` 将事件发布到账户 `123456789012` 中的默认事件总线的权限。

```
{
   "Version": "2012-10-17",
   "Statement": [
       {
        "Sid": "sid1",
        "Effect": "Allow",
        "Principal": {"AWS":"arn:aws:iam::111112222333:root"},
        "Action": "events:PutEvents",
        "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/default"
        }
    ]
}
```

#### 示例策略：将事件发送到其它账户的自定义总线

以下示例策略授予账户 `111122223333` 向账户 `123456789012` 中的事件总线 `central-event-bus` 发布事件的权限，但仅适用于 `source` 设置为 `com.exampleCorp.webStore` 和 `detail-type` 设置为 `newOrderCreated` 的事件。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WebStoreCrossAccountPublish",
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Principal": {
        "AWS": "arn:aws:iam::111112222333:root"
      },
      "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/central-event-bus",
      "Condition": {
        "StringEquals": {
          "events:detail-type": "newOrderCreated",
          "events:source": "com.exampleCorp.webStore"
        }
      }
    }
  ]
}
```

#### 示例策略：将事件发送到同一账户中的事件总线

下面的名为 `CustomBus1` 示例策略附加到事件总线上，允许它接受来自同一账号且同一区域的事件。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": [
        "arn:aws:events:us-east-1:123456789:event-bus/CustomBus1"
      ]
    }
  ]
}
```

#### 示例策略：向同一个账户发送事件并限制更新

以下示例策略授予账户 `123456789012` 创建、删除、更新、禁用和启用规则以及添加或移除目标的权限。它限制了这些规则仅适用于 `source` 为 `com.exampleCorp.webStore` 的事件，它使用 "events:creatorAccount": "${aws:PrincipalAccount}" 以确保只有账户 `123456789012` 可以在创建这些规则和目标后对其进行修改。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InvoiceProcessingRuleCreation",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": [
        "events:PutRule",
        "events:DeleteRule",
        "events:DescribeRule",
        "events:DisableRule",
        "events:EnableRule",
        "events:PutTargets",
        "events:RemoveTargets"
      ],
      "Resource": "arn:aws:events:us-east-1:123456789012:rule/central-event-bus/*",
      "Condition": {
        "StringEqualsIfExists": {
          "events:creatorAccount": "${aws:PrincipalAccount}",
          "events:source": "com.exampleCorp.webStore"
        }
      }
    }
  ]
}
```

#### 示例策略：将仅从特定规则来的事件发送到不同区域的总线

以下示例策略授予账户 `111122223333` 在匹配位于中东（巴林）和美国西部（俄勒冈）区域的规则 `SendToUSE1AnotherAccount` 时，向位于美国东部（弗吉尼亚北部）的账户 `123456789012` 下事件总线 `CrossRegionBus` 发送事件的权限。示例策略已附加到账户` 123456789012` 下事件总线 `CrossRegionBus` 上。仅当事件与账户 `111122223333` 中为事件总线指定的规则匹配时，策略才允许这些事件。这些区域有：`Condition` 语句将事件限制为仅与具有指定规则 ARN 的规则匹配的事件。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificRulesAsCrossRegionSource",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111112222333:root"
      },
      "Action": "events:PutEvents",
      "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/CrossRegionBus",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": [
            "arn:aws:events:us-west-2:111112222333:rule/CrossRegionBus/SendToUSE1AnotherAccount",
            "arn:aws:events:me-south-1:111112222333:rule/CrossRegionBus/SendToUSE1AnotherAccount"
          ]
        }
      }
    }
  ]
}
```

#### 示例策略：将仅从特定区域来的事件发送到不同区域

以下示例策略授予账户 `111122223333` 权限，允许其将中东（巴林）和美国西部（俄勒冈）区域生成的所有事件发送到位于美国东部（弗吉尼亚北部）区域的账户 `123456789012` 名为 `CrossRegionBus` 的事件总线。账户 `111122223333` 无权发送在任何其它区域生成的事件。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allow_cross_region_events_from_us-west-2_and_me-south-1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111112222333:root"
      },
      "Action": "events:PutEvents",
      "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/CrossRegionBus",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": [
            "arn:aws:events:us-west-2:*:*",
            "arn:aws:events:me-south-1:*:*"
          ]
        }
      }
    }
  ]
}
```

#### 示例策略：拒绝来自特定区域的事件

以下示例策略附加到账户 `123456789012` 中的事件总线 `CrossRegionBus`，它授予事件总线接收来自账户 `111122223333` 的事件的权限，但不允许接收在美国西部（俄勒冈）区域生成的事件。

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1AllowAnyEventsFromAccount111112222333",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111112222333:root"
      },
      "Action": "events:PutEvents",
      "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/CrossRegionBus"
    },
    {
      "Sid": "2DenyAllCrossRegionUSWest2Events",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "events:PutEvents",
      "Resource": "arn:aws:events:us-east-1:123456789012:event-bus/CrossRegionBus",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": [
            "arn:aws:events:us-west-2:*:*"
          ]
        }
      }
    }
  ]
}
```

### 创建事件总线

您可以创建一个自定义[事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus.html)接收来自你的应用程序的事件。您的应用程序还可以将事件发送到默认事件总线。当你创建事件总线时，你可以附加[基于资源的策略](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-resource-based.html)以将权限授权。然后，其它账户可以将事件发送到当前账户中的事件总线。

#### 创建自定义事件总线

1. 打开 Amazon EventBridge 控制台https://console.aws.amazon.com/events/.
2. 在导航窗格中，选择 **Event Buses (事件总线)**。
3. 选择 **Create event bus (创建事件总线)**。
4. 输入新事件总线的名称。
5. 请执行下列操作之一：

   + 输入包含要为事件总线授予的权限的策略。您可以粘贴来自其它来源的策略或输入策略的 JSON。您可以使用示例策略之一并根据您的环境进行修改。
   + 要使用策略的模板，请选择加载模板. 根据您的环境修改策略，包括添加您授权策略中的委托人使用的其它操作。

6. 选择 **Create（创建）**。

### 从事件总线生成模板

AWS CloudFormation 通过将基础设施视为代码，使您能够以集中和可重复的方式跨账户和区域配置和管理AWS资源。 AWS CloudFormation 通过允许您创建模板来实现此目的，这些模板定义了要预置和管理的资源。

ventBridge 允许您从账户中的现有事件总线生成模板，以帮助您快速开始开发AWS CloudFormation模板。此外，还 EventBridge 提供了在模板中包含与该事件总线相关的规则的选项。然后，您可以使用这些模板作为[创建AWS CloudFormation管理资源堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html)的基础。

有关更多信息，AWS CloudFormation请参阅[《AWS CloudFormation用户指南》](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)。

> **注意** EventBridge 生成的模板中不包含[托管规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)。

#### 从事件总线生成AWS CloudFormation模板

1. 通过 https://console.aws.amazon.com/events/ 打开亚马逊 EventBridge。
2. 在导航窗格中，选择 **Event Buses (事件总线)**。
3. 选择要从中生成 AWS CloudFormation 模板的事件总线。
4. 从 **“操作”** 菜单中选择 **“CloudFormation 模板”**，然后选择 EventBridge 要生成模板的格式：**JSON** 或 **YAML**。

   EventBridge 显示以选定格式生成的模板。默认情况下，与事件总线关联的所有规则都包含在模板中。
   + 要生成不包含规则的模板，请取消选择“包括此规则” EventBus。
5. EventBridge 允许您选择下载模板文件或将模板复制到剪贴板。
   
   + 要下载模板文件，请选择 **Download**。
   + 要将模板复制到剪贴板，请选择 **Copy**。

6. 要退出模板，请选择**“取消”**。

一旦根据需要为用例自定义AWS CloudFormation模板后，就可以使用它来利用 AWS CloudFormation 创建堆栈。

#### 使用 Amazon EventBridge 生成的 AWS CloudFormation 模板时的注意事项

使用从事件总线生成的AWS CloudFormation模板时，请考虑以下因素：

- EventBridge 在生成模板中不包含任何密码。

   您可以编辑模板以包含[模板参数](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)，这些参数允许用户在使用模板创建或更新AWS CloudFormation堆栈时指定密码或其它敏感信息。

   此外，用户可以使用 Secrets Manager 在所需区域创建密钥，然后编辑生成的模板以使用[动态参数](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/dynamic-references.html#dynamic-references-secretsmanager)。
- 生成的模板中的目标与它们在原始事件总线中指定的完全相同。如果您在使用模板在其它区域创建堆栈之前未对其进行适当编辑，则可能会导致跨区域问题。此外，生成的模板不会自动创建下游目标。

## Amazon EventBridge 事件

事件表示变化，如一个环境如 AWS 环境的变化，一个 SaaS 合作伙伴服务或应用程序，或您的应用程序或服务之一发生了变化。以下是事件的示例：

- 当实例状态从待处理变为正在运行时，Amazon EC2 将生成事件。
- Amazon EC2 Auto Scaling 在启动或终止实例时生成事件。
- AWS CloudTrail 在你调用 API 时发布事件。

您还可以设置定期生成的计划事件。

有关生成事件的服务列表，包括每个服务的示例事件，请参阅[来自AWS服务的事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-service-event.html)并点击表中的链接。

事件以 JSON 对象的形式表示，它们都具有相似的结构和相同的顶级字段。

`detail` 顶级字段的内容因生成事件的服务以及所生成的事件而异。`source` 字段和 `detail-type` 字段的组合用于标识在 `detail` 字段中找到的字段和值。有关 AWS 生成的事件示例，请参阅[来自AWS服务的事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-service-event.html)。

### 事件结构

下面的字段会出现在一个事件中：

```
{
  "version": "0",
  "id": "UUID",
  "detail-type": "event name",
  "source": "event source",
  "account": "ARN",
  "time": "timestamp",
  "region": "region",
  "resources": [
    "ARN"
  ],
  "detail": {
    JSON object
  }
}
```

- version
  默认情况下，在所有事件中设置为 0 (零)。
- id
  为每个事件生成版本 4 UUID。事件通过规则移动id到目标时，您可以跟踪事件。
- detail-type
  与 source 字段组合起来标识显示在 detail 字段中的字段和值。

  由 CloudTrail 传送的事件的 `detail-type` 值为 "AWS API Call via CloudTrail"detail-type
- source
  标识生成事件的服务。来自AWS服务的所有事件都以 “aws” 开头。客户生成的事件可具有任意值，前提是它不以“aws.”开头。建议使用 Java 包名样式反向域名字符串。

  要找到AWS服务的正确值，请参阅[条件键表](https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html#context_keys_table)，从列表中选择服务，然后查找服务前缀。例如，亚马逊 CloudFront 的 `source`值为 `aws.cloudfront`。
- 账户
  标识 AWS 账户的 12 位数字。
- time
  事件时间戳，可由发起事件的服务指定。如果事件跨时间间隔，则服务可报告开始时间，因此该值可能早于接收事件的时间。
- 区域
  标识事件源自的AWS区域。
- resources
  包含用于标识事件中涉及的资源的 ARN 的 JSON 数组。生成事件的服务决定是否包含这些 ARN。例如，Amazon EC2 实例状态更改包含 Amazon EC2 实例 ARN，Auto Scaling 事件包含实例和 `Auto Scaling` 组的 ARN，而对 AWS CloudTrail 的 API 调用不包含资源 ARN。
- detail
  包含关于事件信息的 JSON 对象。生成事件的服务决定该字段的内容。详细内容可以像两个字段一样简单。 AWS API 调用事件的 `detail` 对象具有约 50 个字段，可嵌套多个级别。

#### 示例：Amazon EC2 实例状态变化通知

在 Amazon EventBridge 中下面的事件表明一个 Amazon EC2　实例被停止。

```
{
  "version": "0",
  "id": "6a7e8feb-b491-4cf7-a9f1-bf3703467718",
  "detail-type": "EC2 Instance State-change Notification",
  "source": "aws.ec2",
  "account": "111122223333",
  "time": "2017-12-22T18:43:48Z",
  "region": "us-west-1",
  "resources": [
    "arn:aws:ec2:us-west-1:123456789012:instance/i-1234567890abcdef0"
  ],
  "detail": {
    "instance-id": " i-1234567890abcdef0",
    "state": "terminated"
  }
}
```

### 有效的自定义事件所需的最少信息

创建自定义事件时，它们必须包含以下字段：

```
{
  "detail-type": "event name",
  "source": "event source",
  "detail": {
  }
}
```

- detail 包含关于事件信息的 JSON 对象。有可能为"{}"。

  > **注意** `PutEvents`接受 JSON 格式的数据。对于 JSON 数字（整数）数据类型，约为：最小值为 -9,223,372,036,854,775,808，最大值为 9,223,372,036,854,775,807。
- detail-type 标识事件类型的字符串。
- source 标识事件来源的字符串。客户生成的事件可具有任意值，前提是它不以 “aws.”开头。建议使用 Java 包名样式反向域名字符串。

### 事件模式（event patterns）

事件模式与它们匹配的[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)具有相同的结构。[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)使用事件模式来选择事件并将其发送到目标。事件模式匹配或不匹配事件。

> **重要**
> 在 EventBridge，可能创建导致无限循环的规则，即反复触发一个规则。例如，某规则可能检测到 S3 存储桶上的 ACL 已更改，然后触发软件以将 ACL 更改为所需状态。如果编写该规则时不小心，则 ACL 的后续更改将再次触发该规则，从而产生无限循环。
> 
> 为防止出现这种情况，请在编写规则时使触发的操作不会重复激发同一规则。例如，您的规则可能仅在发现 ACL 处于错误状态时而不是在进行任何更改之后激发。
> 
> 无限循环可能快速导致费用超出预期。我们建议您使用预算功能，以便在费用超出您指定的限制时提醒您。有关更多信息，请参阅[通过预算管理成本](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/budgets-managing-costs.html)。

以下事件演示了 Amazon EC2 中的一个简单AWS事件。

```
{
  "version": "0",
  "id": "6a7e8feb-b491-4cf7-a9f1-bf3703467718",
  "detail-type": "EC2 Instance State-change Notification",
  "source": "aws.ec2",
  "account": "111122223333",
  "time": "2017-12-22T18:43:48Z",
  "region": "us-west-1",
  "resources": [
    "arn:aws:ec2:us-west-1:123456789012:instance/i-1234567890abcdef0"
  ],
  "detail": {
    "instance-id": "i-1234567890abcdef0",
    "state": "terminated"
  }
}
```

以下事件模式处理所有 Amazon EC2instance-termination 事件。

```
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["terminated"]
  }
}
```

### 创建事件模式

要创建事件模式，请指定希望事件模式匹配的事件字段。仅指定用于匹配的字段。前面的事件模式示例仅提供三个字段的值：顶级字段 "source" 和 "detail-type"，以及"detail" 对象字段内的字段 "state"。EventBridge 应用规则时忽略事件中的所有其他字段。

要使事件模式与事件相匹配，事件必须包含事件模式中列出的所有字段名称。字段名称还必须以相同的嵌套结构出现在事件中。

EventBridge 忽略事件中并不包含在事件模式中的字段。效果相当于事件模式中未出现的字段有一个 “*”: “*” 通配符。

事件模式匹配的值遵循 JSON 规则。可以包括用引号（"）括起来的字符串、数字和关键字 `true`、`false` 和 `null`。

对于字符串，EventBridge 使用精确 `character-by-character` 匹配，而不进行小写化或任何其它字符串标准化。

对于数字，EventBridge 使用字符串表示。例如，`300`、`300.0` 和 `3.0e2` 不相等。

在编写事件模式来匹配事件时，您可以使用 `TestEventPattern` API 或 `test-event-pattern` CLI 命令来测试您的模式是否匹配正确的事件。有关更多信息，请参阅[TestEventPattern](https://docs.aws.amazon.com/AmazonCloudWatchEvents/latest/APIReference/API_TestEventPattern.html)。

以下是中可用的所有比较运算符的汇总 EventBridge。

> **注意** 目前并不是所有的比较运算都被[EventBridge Pipes](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-pipes.html)支持。

Comparison（比较）|示例|Rule syntax（规则语法）|由管道支持
--------|--------|--------|--------
Null|UserID is null|UserID": [ null ]|Yes
Empty|LastName is empty|"LastName": [""]|Yes
Equals|Name is "Alice"|"Name": [ "Alice" ]|Yes
Equals (ignore case)|Name is "Alice"|"Name": [ { "equals-ignore-case": "alice" } ]|No
And|Location is "New York" and Day is "Monday"|"Location": [ "New York" ], "Day": ["Monday"]|Yes
Or|PaymentType is "Credit" or "Debit"|"PaymentType": [ "Credit", "Debit"]|Yes
Or (multiple fields)|Location is "New York", or Day is "Monday".|"$or": [ { "Location": [ "New York" ] }, { "Day": [ "Monday" ] } ]|No
Not|Weather is anything but "Raining"|"Weather": [ { "anything-but": [ "Raining" ] } ]|Yes
Numeric (equals)|Price is 100|"Price": [ { "numeric": [ "=", 100 ] } ]|Yes
Numeric (range)|Price is more than 10, and less than or equal to 20|"Price": [ { "numeric": [ ">", 10, "<=", 20 ] } ]|Yes
Exists|ProductName exists|"ProductName": [ { "exists": true } ]|Yes
Does not exist|ProductName does not exist|"ProductName": [ { "exists": false } ]|Yes
Begins with|Region is in the US|"Region": [ {"prefix": "us-" } ]|Yes
Ends with|FileName ends with a .png extension.|"FileName": [ { "suffix": ".png" } ]|No

#### 匹配值
在事件模式中，要匹配的值位于 JSON 数组中，由方括号（“[”、“]”）包围，因此您可以提供多个值。例如，要匹配来自 Amazon EC2 或 AWS Fargate 的事件，您可以使用以下模式，该模式匹配 "source" 字段值为 "aws.ec2" 或 "aws.fargate" 的事件。

```
{
    "source": ["aws.ec2", "aws.fargate"]
}
```

### 示例事件和事件模式

您可以使用所有 JSON 数据类型和值来匹配事件。以下示例演示了事件和与它们匹配的事件模式。

#### 字段匹配

您可以匹配字段的值。考虑以下Amazon EC2 Auto Scaling 事件。

```
{
  "version": "0",
  "id": "3e3c153a-8339-4e30-8c35-687ebef853fe",
  "detail-type": "EC2 Instance Launch Successful",
  "source": "aws.autoscaling",
  "account": "123456789012",
  "time": "2015-11-11T21:31:47Z",
  "region": "us-east-1",
  "resources": [],
  "detail": {
    "eventVersion": "",
    "responseElements": null
  }
}
```

对于前面的事件，您可以使用该 "responseElements" 字段进行匹配。

```
{
  "source": ["aws.autoscaling"],
  "detail-type": ["EC2 Instance Launch Successful"],
  "detail": {
   "responseElements": [null]
  }
}
```

#### 值匹配

考虑以下 `Amazon Macie` 事件为例，该事件已被截断。

```
{
  "version": "0",
  "id": "0948ba87-d3b8-c6d4-f2da-732a1example",
  "detail-type": "Macie Finding",
  "source": "aws.macie",
  "account": "123456789012",
  "time": "2021-04-29T23:12:15Z",
  "region":"us-east-1",
  "resources": [

  ],
  "detail": {
    "schemaVersion": "1.0",
    "id": "64b917aa-3843-014c-91d8-937ffexample",
    "accountId": "123456789012",
    "partition": "aws",
    "region": "us-east-1",
    "type": "Policy:IAMUser/S3BucketEncryptionDisabled",
    "title": "Encryption is disabled for the S3 bucket",
    "description": "Encryption is disabled for the Amazon S3 bucket. The data in the bucket isn’t encrypted 
        using server-side encryption.",
    "severity": {
        "score": 1,
        "description": "Low"
    },
    "createdAt": "2021-04-29T15:46:02Z",
    "updatedAt": "2021-04-29T23:12:15Z",
    "count": 2,
.
.
.
```

以下事件模式与严重性分数为 `1` 且计数为 `2` 的任何事件相匹配。

```
{
  "source": ["aws.macie"],
  "detail-type": ["Macie Finding"],
  "detail": {
    "severity": {
      "score": [1]
    },
    "count":[2]
  }
}
```

#### 空值和空字符串

您可以创建与[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)中具有空值或空字符串的字段相匹配的[事件模式](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)。考虑以下示例事件。

```
{
  "version": "0",
  "id": "3e3c153a-8339-4e30-8c35-687ebef853fe",
  "detail-type": "EC2 Instance Launch Successful",
  "source": "aws.autoscaling",
  "account": "123456789012",
  "time": "2015-11-11T21:31:47Z",
  "region": "us-east-1",
  "resources": [
   ],
  "detail": {
    "eventVersion": "",
    "responseElements": null
   }
}
```

要匹配的 `eventVersion` 值为空字符串的事件，请使用以下事件模式，该模式与前面的事件相匹配。

```
{
  "detail": {
     "eventVersion": [""]
  }
}
```

要匹配值 `responseElements` 为空的事件，请使用以下事件模式，该模式与前面的事件相匹配。

```
{
  "detail": {
     "responseElements": [null]
  }
}
```

> **注意** 在模式匹配中，Null 值和空字符串是不可互换的。匹配空字符串的事件模式不匹配null 值。

#### 数组

[事件模式](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)中每个字段的值是一个包含一个或多个值的数组。如果数组中的任何值与事件中的值匹配，则事件模式与[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)相匹配。如果事件中的值是一个数组，则如果事件模式数组和事件数组的交叉点非空，则事件模式匹配。

例如，假设一个包含以下字段的事件模式。

```
"resources": [
   "arn:aws:ec2:us-east-1:123456789012:instance/i-b188560f",
   "arn:aws:ec2:us-east-1:111122223333:instance/i-b188560f",
   "arn:aws:ec2:us-east-1:444455556666:instance/i-b188560f",
]
```

前面的事件模式与包含以下字段的事件相匹配，因为事件模式数组中的第一项与事件数组中的第二项匹配。

```
"resources": [
   "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:eb56d16b-bbf0-401d-b893-d5978ed4a025:autoScalingGroupName/ASGTerminate",
   "arn:aws:ec2:us-east-1:123456789012:instance/i-b188560f" 
]
```

#### 基于内容的筛选

Amazon EventBridge 支持使用[事件模式](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-event-patterns.html)进行声明式内容过滤。通过内容过滤，您可以编写复杂的事件模式，这些模式仅在非常具体的条件下匹配事件。例如，如果[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)的字段在特定数值范围内，如果事件来自特定 IP 地址，或者仅当事件 JSON 中不存在特定字段时，您可以创建与事件匹配的事件模式。

##### 前缀匹配

您可以根据事件源中值的前缀来匹配事件。您可以对字符串值使用前缀匹配。

例如，以下事件模式将匹配"time"字段以"2017-10-02"例如开头的任何事件"time": "2017-10-02T18:43:48Z"。

```
{
  "time": [ { "prefix": "2017-10-02" } ]
}
```

##### 后缀匹配

您可以根据事件源中值的后缀来匹配事件。您可以对字符串值使用后缀匹配。

例如，以下事件模式将匹配"FileName"字段以.png文件扩展名结尾的任何事件。

```
{
  "FileName": [ { "suffix": ".png" } ]
}
```

##### Anything-but 匹配

匹配除规则中提供的内容之外的任何东西。

除了匹配字符串和数值，包括仅包含字符串或仅包含数字的列表，您可以使用任何其他方法。

以下事件模式显示除了与字符串和数字匹配之外的任何内容。

```
{
  "detail": {
    "state": [ { "anything-but": "initializing" } ]
  }
}

{
  "detail": {
    "x-limit": [ { "anything-but": 123 } ]
  }
}
```

以下事件模式显示了除与字符串列表匹配之外的任何内容。

```
{
  "detail": {
    "state": [ { "anything-but": [ "stopped", "overloaded" ] } ]
  }
}
```

以下事件模式显示了除与数字列表匹配之外的任何内容。

```
{
  "detail": {
    "x-limit": [ { "anything-but": [ 100, 200, 300 ] } ]
  }
}
```

以下事件模式显示了与除"state"字段中包含"init"前缀的事件之外的任何事件相匹配。

> **注意** Anything-but 仅仅匹配单个前缀而非列表。

```
{
  "detail": {
    "state": [ { "anything-but": { "prefix": "init" } } ]
  }
}
```

##### 数字匹配

数字匹配适用于 JSON 数字值。它仅限于介于 -5.0e9 和 +5.0e9 之间的值，精度为 15 位数或小数点右侧六位数。

以下显示事件模式的数值匹配，该事件模式仅匹配所有字段均为真的事件。

```
{
  "detail": {
    "c-count": [ { "numeric": [ ">", 0, "<=", 5 ] } ],
    "d-count": [ { "numeric": [ "<", 10 ] } ],
    "x-limit": [ { "numeric": [ "=", 3.018e2 ] } ]
  }
}
```

##### IP 地址匹配

您可以对 IPv4 和 IPv6 地址使用 IP 地址匹配。以下事件模式显示 IP 地址与以 10.0.0 开头并以 0 到 255 之间的数字结尾的 IP 地址匹配。

```
{
  "detail": {
    "sourceIPAddress": [ { "cidr": "10.0.0.0/24" } ]
  }
}
```

##### 存在匹配项

`Exists` 匹配适用于事件 JSON 中是否存在字段。

`Exists` 匹配仅适用于叶节点。它对于中间节点不起作用。

以下事件模式与任何具有 `detail.state` 字段的事件相匹配。

```
{
  "detail": {
    "state": [ { "exists": true  } ]
  }
}
```

前面的事件模式与以下事件相匹配。

```
{
  "version": "0",
  "id": "7bf73129-1428-4cd3-a780-95db273d1602",
  "detail-type": "EC2 Instance State-change Notification",
  "source": "aws.ec2",
  "account": "123456789012",
  "time": "2015-11-11T21:29:54Z",
  "region": "us-east-1",
  "resources": ["arn:aws:ec2:us-east-1:123456789012:instance/i-abcd1111"],
  "detail": {
    "instance-id": "i-abcd1111",
    "state": "pending"
  }
}
```

前面的事件模式与以下事件不匹配，因为它没有字 `detail.state` 段。

```
{
  "detail-type": [ "EC2 Instance State-change Notification" ],
  "resources": [ "arn:aws:ec2:us-east-1:123456789012:instance/i-02ebd4584a2ebd341" ],
  "detail": {
    "c-count" : {
       "c1" : 100
    }
  }
}
```

##### Equals-ignore-case 匹配

无论大小写如何，`Equals-ignore-case` 匹配都适用于字符串值。

以下事件模式与任何具有与指定字符串匹配的detail-type字段的事件相匹配，无论大小写如何。

```
{
  "detail-type": [ { "equals-ignore-case": "ec2 instance state-change notification" } ]
}
```

前面的事件模式与以下事件相匹配。

```
{
  "detail-type": [ "EC2 Instance State-change Notification" ],
  "resources": [ "arn:aws:ec2:us-east-1:123456789012:instance/i-02ebd4584a2ebd341" ],
  "detail": {
    "c-count" : {
       "c1" : 100
    }
  }
}
```

##### 具有多重匹配的复杂示例

您可以将多个匹配规则组合为更复杂的事件模式。例如，以下事件模式组合了 `anything-but` 和 `numeric`。

```
{
  "time": [ { "prefix": "2017-10-02" } ],
  "detail": {
    "state": [ { "anything-but": "initializing" } ],
    "c-count": [ { "numeric": [ ">", 0, "<=", 5 ] } ],
    "d-count": [ { "numeric": [ "<", 10 ] } ],
    "x-limit": [ { "anything-but": [ 100, 200, 300 ] } ]
  }
}
```

> **注意**：在构建事件模式时，如果一个关键词出现了多次，则最后一个引用将是用于评估事件的引用。例如，对于以下模式：
>   
>  ```
>  {
>    "detail": {
>      "location": [ { "prefix": "us-" } ],
>      "location": [ { "anything-but": "us-east" } ]
>    }
>  }
>  ```
>
> 在评估 `location` 时只有 { "anything-but": "us-east" } 将会被考虑。

##### 具有$or匹配功能的复杂示例

您还可以创建复杂的事件模式，检查多个字段中是否有任何字段值匹配。$or 用于创建匹配多个字段的任何值时匹配的事件模式。

请注意，您可以在 $or 构造中各个字段的模式匹配中包含其他过滤器类型，例如[数字匹配](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html#filtering-numeric-matching)和[数组](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-arrays.html)。

在满足以下任意条件时，以下事件模式将匹配：

- `c-count` 字段大于 0 或小于等于 5。
- 该 `d-count` 字段小于 10。
- 该 `x-limit` 字段等于 3.018e2。

```
{
  "detail": {
    "$or": [
      { "c-count": [ { "numeric": [ ">", 0, "<=", 5 ] } ] },
      { "d-count": [ { "numeric": [ "<", 10 ] } ] },
      { "x-limit": [ { "numeric": [ "=", 3.018e2 ] } ] }
    ]
  }
}
```

> **注意**
接受事件模式（例如 `PutRule`、`CreateArchiveUpdateArchive`、和 `TestEventPattern`）的 API 将在使用 $or 过程中有用超过 1000 个规则组合时抛出 `InvalidEventPatternException` 异常。

要确定事件模式中规则组合的数量，请将事件模式中每个 $or 数组的参数总数相乘。例如，上面的模式包含一个带有三个参数的单个 $or 数组，因此规则组合的总数也是三个。如果您添加另一个 $or 包含两个参数的数组，则规则组合总数将为六个。

### 使用 PutEvents 添加事件

`PutEvents` 操作在一次请求中将多个[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)发送到 EventBridge。有关更多信息，请参阅 Amazon EventBridge API 参考中的 [PutEvents](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_PutEvents.html) 和 AWS CLI命令参考中的 [put-events](https://docs.aws.amazon.com/cli/latest/reference/events/put-events.html)。

每个 `PutEvents` 请求可支持有限数目的条目。有关更多信息，请参阅[亚马逊 EventBridge 配额](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-quota.html)：`PutEvents` 操作将尝试按请求的自然顺序处理所有条目。调用 `PutEvents` 后，EventBridge 为每个事件分配一个唯一的 ID。


以下示例 Java 代码将两个相同的事件发送到 EventBridge。

```
EventBridgeClient eventBridgeClient =
    EventBridgeClient.builder().build();

PutEventsRequestEntry requestEntry = PutEventsRequestEntry.builder()
    .resources("resource1", "resource2")
    .source("com.mycompany.myapp")
    .detailType("myDetailType")
    .detail("{ \"key1\": \"value1\", \"key2\": \"value2\" }")
    .build();

List <PutEventsRequestEntry > requestEntries = new ArrayList<PutEventsRequestEntry> ();
requestEntries.add(requestEntry);

PutEventsRequest eventsRequest = PutEventsRequest.builder()
    .entries(requestEntries)
    .build();

PutEventsResponse result = eventBridgeClient.putEvents(eventsRequest);

for (PutEventsResultEntry resultEntry: result.entries()) {
    if (resultEntry.eventId() != null) {
        System.out.println("Event Id: " + resultEntry.eventId());
    } else {
        System.out.println("PutEvents failed with Error Code: " + resultEntry.errorCode());
    }
}
```

运行此代码后，`PutEvents` 结果包含一组响应条目。响应数组中的每个条目对应于请求数组中的一个条目，从请求和响应的开始到结束的顺序排列。响应 `Entries` 数组包含的条目数量始终与请求数组相同。

#### 处理 PutEvents 故障

默认情况下，如果请求中的单个条目失败，则 EventBridge 继续处理请求中的其余条目。响应条目数组可以包含成功和失败的条目。您必须检测出不成功的条目并将其包含在随后的调用中。

成功的结果条目包括一个Id值，不成功的结果条目包括 `ErrorCode` 和 `ErrorMessage` 值。`ErrorCode` 描述了错误的类型。`ErrorMessage` 提供了有关错误的更多信息。以下示例有三个 `PutEvents` 请求的结果条目。第二个输入不成功。

```
{
    "FailedEntryCount": 1, 
    "Entries": [
        {
            "EventId": "11710aed-b79e-4468-a20b-bb3c0c3b4860"
        },
        {   "ErrorCode": "InternalFailure",
            "ErrorMessage": "Internal Service Failure"
        },
        {
            "EventId": "d804d26a-88db-4b66-9eaf-9a11c708ae82"
        }
    ]
}
```

> **注意** 如果您使用 `PutEvents` 将事件发布到不存在的事件总线，则 EventBridge 事件匹配将找不到相应的规则并会丢弃该事件。尽管 EventBridge 会发送 `200` 响应，但它不会使请求失败，也不会将该事件包含在请求响应的 `FailedEntryCount` 值中。

您可以在后续 `PutEvents` 请求中加入不成功的条目。首先，要了解请求中是否有失败的条目，请检查 `PutEventsResult` 中的参数`FailedRecordCount`。如果不为零，则可以将每个其 `ErrorCode` 的值不为 `null` 的 `Entry` 添加到后续请求中。以下示例显示了一个失败处理程序。

```
PutEventsRequestEntry requestEntry = new PutEventsRequestEntry()
        .withTime(new Date())
        .withSource("com.mycompany.myapp")
        .withDetailType("myDetailType")
        .withResources("resource1", "resource2")
        .withDetail("{ \"key1\": \"value1\", \"key2\": \"value2\" }");

List<PutEventsRequestEntry> putEventsRequestEntryList = new ArrayList<>();
for (int i = 0; i < 3; i++) {
    putEventsRequestEntryList.add(requestEntry);
}

PutEventsRequest putEventsRequest = new PutEventsRequest();
putEventsRequest.withEntries(putEventsRequestEntryList);
PutEventsResult putEventsResult = awsEventsClient.putEvents(putEventsRequest);

while (putEventsResult.getFailedEntryCount() > 0) {
    final List<PutEventsRequestEntry> failedEntriesList = new ArrayList<>();
    final List<PutEventsResultEntry> PutEventsResultEntryList = putEventsResult.getEntries();
    for (int i = 0; i < PutEventsResultEntryList.size(); i++) {
        final PutEventsRequestEntry putEventsRequestEntry = putEventsRequestEntryList.get(i);
        final PutEventsResultEntry putEventsResultEntry = PutEventsResultEntryList.get(i);
        if (putEventsResultEntry.getErrorCode() != null) {
            failedEntriesList.add(putEventsRequestEntry);
        }
    }
    putEventsRequestEntryList = failedEntriesList;
    putEventsRequest.setEntries(putEventsRequestEntryList);
    putEventsResult = awsEventsClient.putEvents(putEventsRequest);
}
```

#### 使用 AWS CLI 发送事件

您可以使用 AWS CLI 向发送自定义事件至 EventBridge 以便对其进行处理。以下示例将一个自定义事件放入 EventBridge：

```
aws events put-events \
--entries '[{"Time": "2016-01-14T01:02:03Z", "Source": "com.mycompany.myapp", "Resources": ["resource1", "resource2"], "DetailType": "myDetailType", "Detail": "{ \"key1\": \"value1\", \"key2\": \"value2\" }"}]'
```

您还可以创建包含自定义事件的 `JSON `文件：

```
[
  {
    "Time": "2016-01-14T01:02:03Z",
    "Source": "com.mycompany.myapp",
    "Resources": [
      "resource1",
      "resource2"
    ],
    "DetailType": "myDetailType",
    "Detail": "{ \"key1\": \"value1\", \"key2\": \"value2\" }"
  }
]
```

然后，要使用从该 AWS CLI 文件读取条目并发送事件，请在命令提示符处键入：

```
aws events put-events --entries file://entries.json
```

#### 计算亚马逊 EventBridge PutEvents 事件条目数目

您可以使用 `PutEvents` 操作将自定义[事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-events.html)发送到 EventBridge 。您可以将多个事件条目批量合并为一个请求以提高效率。总条目大小必须小于 `256KB`。您可以在发送事件之前计算条目大小。

> **注意** 对条目大小施加了限制。即使条目小于大小限制，事件也总是大于条目大小。原因在于事件的 JSON 表示形式需要使用必需的字符和关键字。有关更多信息，请参阅[亚马逊 EventBridge 事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)

EventBridge 按如下方式计算 `PutEventsRequestEntry` 大小：

- 如果指定，则 `Time` 参数为 14 字节。
- `Source` 和 `DetailType` 参数是其 `UTF-8` 编码表单的字节数。
- 如果指定，则该 `Detail` 参数为其 `UTF-8` 编码形式的字节数。
- 如果指定，则 `Resources` 参数的每个条目都是其 `UTF-8` 编码表单的字节数。

以下示例 Java 代码计算给定PutEventsRequestEntry对象的大小：

```
int getSize(PutEventsRequestEntry entry) {
    int size = 0;
    if (entry.getTime() != null) {
        size += 14;
    }
    size += entry.getSource().getBytes(StandardCharsets.UTF_8).length;
    size += entry.getDetailType().getBytes(StandardCharsets.UTF_8).length;
    if (entry.getDetail() != null) {
        size += entry.getDetail().getBytes(StandardCharsets.UTF_8).length;
    }
    if (entry.getResources() != null) {
        for (String resource : entry.getResources()) {
            if (resource != null) {
                size += resource.getBytes(StandardCharsets.UTF_8).length;
            }
        }
    }
    return size;
}
```

> **注意** 如果条目大小超过 256KB，我们建议将事件上传到 Amazon S3 存储桶并将 `Object URL` 包含 在该事件 `PutEvents` 条目中。

## Amazon EventBridge 规则

规则匹配传入事件并将其发送到目标进行处理。一条规则可以将事件发送到多个目标，然后这些目标并行运行。规则要么基于事件模式，要么基于时间表。事件模式定义了事件结构和规则匹配的字段。基于时间表的规则会定期执行操作。

AWS 服务可在您的 AWS 账户中创建和管理这些服务中的某些函数需要的 EventBridge 规则。这些策略称为托管式规则。

当某个服务创建一个托管式规则时，它也可以创建一个 IAM 策略，以向该服务授予创建该规则的权限。以这种方式创建的 IAM 策略的作用局限于资源级权限，以仅允许创建必需的规则。

您可以使用**强制删除选项**删除托管规则，但只有在确定其它服务不再需要该规则时，才应将其删除。否则，删除托管式规则会导致依赖它的功能停止工作。

### 创建对事件做出反应的亚马逊 EventBridge 规则

要对亚马逊 EventBridge 收到的[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)采取行动，您可以创建[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)。当事件与规则中定义的事件模式匹配时，EventBridge 会将事件发送到指定的目标并触发规则中定义的操作。

#### 定义规则

首先，输入规则的名称和描述，以对其进行识别。您还必须定义事件总线，您的规则将在该总线中查找与事件模式匹配的事件。

**定义规则细节**

1. 通过 https://console.aws.amazon.com/events/ 打开亚马逊 EventBridge
2. 在导航窗格中，选择 **Rules (规则)**。
3. 选择 **Create rule (创建规则)**。
4. 输入规则的名称和描述（可选）。
   
   规则不能与同一 AWS 区域中和同一事件总线上的另一条规则的名称相同。

5. 对于 **Event bus（事件总线）**，请选择要与此规则关联的事件总线。如果您希望此规则对来自您账户的匹配事件触发，请选择 **AWS默认事件总线**。当您账户中的某个 AWS 服务发出一个事件时，它始终会发送到您账户的默认事件总线。
6. 对于 **Rule type（规则类型）**，选择 **Rule with an event pattern**（具有事件模式的规则）。
7. 选择 **Next**（下一步）。

#### 建立事件模式

接下来，构建事件模式。为此，请指定事件源，选择事件模式的基础，并定义要匹配的属性和值。您也可以在 JSON 中生成事件模式，并针对示例事件对其进行测试。

**建立事件模式**

1. 对于事件来源，选择 **AWS事件** 或 **EventBridge合作伙伴事件**。
2. （可选）如果要针对示例事件测试事件模式，请在 “示例事件” 部分中选择示例事件类型。提供了以下示例类型：
   
   + **AWS 事件**：从支持的事件中选择AWS 服务。
   + **EventBridge 合作伙伴事件**：从支持的 EventBridge第三方服务（例如 Salesforce）发起的事件中进行选择。
   + **输入我自己的事件**：以 JSON 文本输入你自己的事件。
3. 选择创建方法。您可以根据 EventBridge 架构或模板创建事件模式，也可以创建自定义事件模式。
   
   - 要使用现有 EventBridge schema 创建事件模式，请执行以下操作：
     + 在 “创建方法” 部分的 “方法” 中，选择 “使用 schema”。
     + 在 “事件模式” 部分中，对于 “Schema type”，选择 “从 schema 注册表中选择 schema”。
     + 对于 Schema 注册表，选择下拉框并输入 schema 注册表的名称，例如 `aws.events`。您也可以从出现的下拉列表中选择一个选项。
     + 对于 Schema，选择下拉框并输入要使用的 Schema 的名称。例如，`aws.s3@ObjectDeleted`。您也可以从出现的下拉列表中选择一个选项。
     + 在模型部分中，选择任何属性旁边的编辑按钮以打开其属性。根据需要设置 “关系” 和 “值” 字段，然后选择 “设置” 以保存该属性。
       
       > **注意** 有关属性定义的信息，请选择该属性名称旁边的 “信息” 图标。要参考如何在事件中设置属性属性，请打开属性属性对话框的注释部分。
       > 要删除某个属性的属性，请选择该属性的编辑按钮，然后选择清除。
     + 选择 “在 JSON 中生成事件模式”，将事件模式生成并验证为 JSON 文本。然后，选择以下任一选项：
       - 复制：将事件模式复制到设备的剪贴板。
       - Prettify — 通过添加换行符、制表符和空格，使 JSON 文本更易于阅读。
       - 测试模式 -针对示例事件部分中的示例事件测试 JSON 格式的模式。
   - 要编写自定义 schema 并将其转换为事件模式，请执行以下操作：
     + 在 “创建方法” 部分中，为 “方法” 选择 “使用 schema”。
     + 在 “事件模式” 部分中，对于 “schema 类型”，选择 “输入 schema”。
     + 在该文本框中输入您的架构。您必须将架构格式化为有效的 JSON 文本。
     + 在模型部分中，选择任何属性旁边的编辑按钮以打开其属性。根据需要设置 “关系” 和 “值” 字段，然后选择 “设置” 以保存该属性。
     + 选择 “在 JSON 中生成事件模式”，将事件模式生成并验证为 JSON 文本。然后，选择以下任一选项：
       - 复制：将事件模式复制到设备的剪贴板。
       - Prettify — 通过添加换行符、制表符和空格，使 JSON 文本更易于阅读。
       - 测试模式 -针对示例事件部分中的示例事件测试 JSON 格式的模式。 
   - 要以 JSON 格式编写自定义事件模式，请执行以下操作：
     + 在 “创建方法” 部分中，为 “方法” 选择 “自定义模式（JSON 编辑器）”。
     + 对于事件模式，以 JSON 格式的文本输入您的自定义事件模式。
     + 创建图案后，选择以下任一选项：
       - 复制：将事件模式复制到设备的剪贴板。
       - Prettify — 通过添加换行符、制表符和空格，使 JSON 文本更易于阅读。
       - 事件模式表单-在模式生成器中打开事件模式。如果图案无法在模式生成器中按原样呈现，则会在打开模式生成器之前向您 EventBridge 发出警告。
       - 测试模式 -针对示例事件部分中的示例事件测试 JSON 格式的模式。 
4. 选择 **Next**（下一步）。

#### 选择目标

选择一个或多个目标来接收与指定模式匹配的事件。目标可以包括 EventBridge 事件总线、EventBridge API 目的地，Salesforce 等 SaaS 合作伙伴，或其它 AWS 服务。

1. 对于 Typtype（目标类型），请选择以下任一选项：
   - 要选择 EventBridge 事件总线，请选择 **EventBridge 事件总线**，然后执行以下操作：
     + 要使用与此规则AWS 区域相同的事件总线，请在同一账户和区域中选择事件总线。然后，对于目标的事件总线，选择下拉框并输入事件总线的名称。您也可以从下拉列表中选择事件总线。
     + 要使用其他AWS 区域账户中的事件总线作为此规则，请选择其他账户或地区中的事件总线。然后，将事件总线作为目标，输入要使用的事件总线的 ARN。
   - 要使用 EventBridge API 目标，请选择 **EventBridge API 目标**，然后执行以下操作：
     + 要使用现有 API 目标，请选择使用现有 API 目标。然后，从下拉列表中选择 API 目标。
     + 要创建新的 API 目标，请选择创建新的 API 目标。然后，提供目的地的以下详细信息：
       - 名称 — 输入目的地的名称。名称在您的中必须唯一AWS 账户。名称最多可以包含 64 个字符。有效字符为 A-Z、a-z、0-9 和。 _ -（连字符）。
       - （可选）描述 — 输入目标的描述。描述最多可以包含 512 个字符。
       - API 目标端点-目标的 URL 端点。端点 URL 必须以开头 https。可以将通配符*作为路径参数包括在内。您可以从目标的 `HttpParameters` 属性中设置路径参数。
       - HTTP 方法-选择调用端点时使用的 HTTP 方法。
       - （可选）每秒调用速率限制-输入此目标每秒接受的最大调用次数。该值必须大于零。默认情况下，该值设置为 300。
       - 连接-要使用现有连接，请选择使用现有连接，然后从下拉列表中选择连接。要为此目标创建新连接，请选择创建新连接，然后定义连接的名称、目标类型和授权类型。您也可以为此连接添加可选的描述。
   - 要使用AWS 服务，请选择 AWS 服务，然后执行以下操作：
     + 在 “选择目标” 中，选择AWS 服务要用作目标的。提供您选择的服务所需的信息。

2. 对于 Exection 角色，执行以下操作之一：
   + 要为此规则创建新的执行角色，请选择为此特定资源创建新角色。然后输入此执行角色的名称，或使用 EventBridge 生成的名称。
   + 要使用该规则的现有执行角色，请选择 “使用现有角色”。然后，从下拉列表中选择或输入要使用的执行角色的名称。
3. （可选地）对额外设置，为你的目标类型指定任何可用的可选设置：
   + 事件总线：
   + API 目标：
   + AWS 服务：
4. （可选地）选择添加另一个目标为这个规则添加另一个目标。
5. 选择 Next（下一步）。

#### 配置标签和审查规则

最后，为该规则输入任何所需的标签，然后查看并创建规则。

1. （可选）为规则输入一个或多个标签。有关更多信息，请参阅[亚马逊 EventBridge 标签](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-tagging.html)。
2. 选择 Next（下一步）。
3. 查看新规则的详细信息。要对任何部分进行更改，请选择该部分旁边的编辑按钮。如果对规则详细信息感到满意，请选择创建规则。

### 创建一个按计划运行的Amazon EventBridge 规则

[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)可以响应[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)运行，也可以按特定的时间间隔运行。例如，要定期运行某个AWS Lambda函数，您可以创建一个按计划运行的规则。可以使用 `cron` 或 `rate` 表达式创建按计划运行的规则。所有预定事件均使用 UTC+0 时区，日程安排的最小精度为一分钟。您的预定规则在那一分钟内运行，但不在精确的第 0 秒内运行。

EventBridge 支持 `cron` 表达式和 `rate` 表达式。速率表达式更易于定义，cron 表达式提供了详细的时间表控制。例如，使用 cron 表达式，您可以定义在每周或每月的特定日期的指定时间运行的规则。相比之下，速率表达式以常规速率运行规则，例如每小时一次或每天一次。

> **注意**
EventBridge 现在提供了新的日程安排功能，即 `Amazon S EventBridge Scheduler`。 `EventBridge Scheduler` 是一种无服务器调度程序，它允许您通过一个中央托管服务创建、运行和管理任务。`EventBridge Scheduler` 具有高度可定制性，与 EventBridge 计划规则相比，具有更高的可扩展性，具有更广泛的目标 API 操作和AWS服务。

我们建议您使用 Amazon S EventBridge Scheduler 按计划调用目标。有关更多信息，请参阅 [Amazon S EventBridge cheduler 用户指南](https://docs.aws.amazon.com/scheduler/latest/UserGuide/)。

> **注意** EventBridge 不在计划表达式中提供二级精度。使用 cron 表达式的最佳分辨率为一分钟。由于 EventBridge 和目标服务的分布式特性，计划规则触发时间与目标服务实际执行目标资源的时间之间的延迟可能有几秒钟。

#### Cron 表达式

Cron 表达式有六个必填字段，之间以空格分隔。

##### 语法

```
cron(fields)
```

字段|值|通配符
--------|--------|--------
分钟|0-59|, - * /
小时|0-23|, - * /
Day-of-month|1-31|, - * ? / L W
月份|1-12 或 JAN-DEC|, - * /
Day-of-week|1-7 或 SUN-SAT|, - * ? L #
年|1970-2199|, - * /

##### 通配符

- ,（逗号）通配符包含其他值。在 “Month（月份）” 字段中，JAN、FEB 和 Mary 包含一月、二月、三月。
- -（破折号）通配符用于指定范围。在 Day 字段中，1-15 包含指定月份的 1-15 日。
- *（星号）通配符包含该字段中的所有值。在“Hours（小时）”字段中，* 包括每个小时。不能在 Day-of-month 和 Day-of-week 字段中都使用 *。如果您在一个中使用它，则必须在另一个中使用 ? 。
- /（斜杠）通配符用于指定增量。在“分钟”字段中，您可以输入 1/10 以指定从一个小时的第一分钟开始的每个第十分钟 (例如，第 11 分钟、第 21 分钟和第 31 分钟，依此类推)。
- 那个？ （问号）通配符用于指定任何值。在 Day-of-month 字段中，你可以输入 7，如果一周中的任何一天是可以接受的，你可以输入？ 在 Day-of-week 字段中。
- Day-of-month 或 Day-of-week 字段中的 L 通配符用于指定该月或该周的最后一天。
- Day-of-month 字段中的W通配符指定工作日。在 Day-of-month 字段中，3W指定最接近该月第三天的工作日。
- Day-of-week 字段中的 # 通配符用于指定某一月内指定日期的特定实例。例如，3#2 指该月的第二个星期二：3 指的是星期二，因为它是每周的第三天，2 是指该月内该类型的第二天。

   > **注意** 如果使用 “#” 字符，则只能在 day-of-week 字段中定义一个表达式。例如，"3#1,6#3" 是无效的，因为它被解释为两个表达式。

##### 限制

- 您无法在同一 cron 表达式中为 Day-of-month 和 Day-of-week 字段同时指定值。如果您在其中一个字段中指定值或 *（星号），则必须使用? （问号）在另一个里。
- 不支持产生的速率快于 1 分钟的 Cron 表达式。

##### 示例

在创建带计划的规则时，可以使用以下示例 cron 字符串。

分钟|小时|日期|月份|星期几|年份|意义
--------|--------|--------|--------|--------|--------|--------
0|10|*|*|?|*|每天上午 10:00（世界标准时间+0）运行
15|12|*|*|?|*|每天下午 12:15（UTC+0）运行
0|18|?|*|MON-FRI|*|每星期一到星期五下午的 6:00 (UTC+0) 运行
0|8|1|*|?|*|每月第 1 天的上午 8:00 (UTC+0) 运行
0/15|*|*|*|?|*|每 15 分钟运行一次
0/10|*|?|*|MON-FRI|*|从星期一到星期五，每 10 分钟运行一次
0/5|8-17|?|*|MON-FRI|*|星期一到星期五的上午 8:00 和下午 5:55 (UTC+0) 之间，每 5 分钟运行一次
0/30|20-2|?|*|MON-FRI|*|周一至周五每隔 30 分钟跑一次，从起始日晚上 10:00 到第二天凌晨 2:00（世界标准时间）,运行时间为星期一早上 12:00 至凌晨 2:00（世界标准时间）。

以下示例创建一个可在协调世界时每天下午的 12:00 运行的规则

```
aws events put-rule --schedule-expression "cron(0 12 * * ? *)" --name MyRule1
```

以下示例创建了每天在 UTC+0 下午 2:05 和下午 2:35 运行的规则。

```
aws events put-rule --schedule-expression "cron(5,35 14 * * ? *)" --name MyRule2
```

以下示例创建了一条规则，该规则在 2019 年至 2022 年期间每个月的最后一个星期五上午 10:15 UTC+0 运行。

```
aws events put-rule --schedule-expression "cron(15 10 ? * 6L 2019-2022)" --name MyRule3
```

#### Rate 表达式

速率表达式在您创建预定事件规则时启动，然后按定义的计划运行。

速率表达式有两个由空格分隔的必填字段。

##### 语法

```
rate(value unit)
```

##### 值

正数。

##### 单位

时间单位。需要不同的单位，例如，对于值 1 为 minute；对于大于 1 的值 1 为 minutes。

有效值：minute | minutes | hour | hours | day | days

##### 限制

如果值等于 1，则单位必须为单数。如果值大于 1，则单位必须有复数。例如，费率（1 小时）和费率（5 小时）无效，但费率（1 小时）和费率（5 小时）有效。

##### 示例

以下示例显示了如何在 AWS CLI `put-rule` 命令中使用速率表达式的方法。第一个示例每分钟触发一次规则，下一个示例每五分钟触发一次规则，第三个示例每小时触发一次，最后一个示例每天触发一次。

```
aws events put-rule --schedule-expression "rate(1 minute)" --name MyRule2

aws events put-rule --schedule-expression "rate(5 minutes)" --name MyRule3

aws events put-rule --schedule-expression "rate(1 hour)" --name MyRule4

aws events put-rule --schedule-expression "rate(1 day)" --name MyRule5
```

#### 创建规则

以下步骤将引导您了解如何创建定期触发的 EventBridge 规则。

> **注意** 您只能使用默认事件总线创建计划规则。

##### 创建定期运行的规则

1. 通过 https://console.aws.amazon.com/events/ 打开亚马逊 EventBridge 控制台。
2. 在导航窗格中，选择 **Rules (规则)**。
3. 选择 Create rule (创建规则)。
4. 为规则输入名称和描述。
5. 对于 Event bus（事件总线），请选择要与此规则关联的事件总线。如果您希望此规则对来自您自己的账户的匹配事件触发，请选择 AWS 默认设置事件总线。当您账户中的某个 AWS 服务发出一个事件时，它始终会发送到您账户的默认事件总线。
6. 对于 Rule type（规则类型），选择 Schedule（计划）。
7. 选择 Next（下一步）。
8. 对于 Schedule pattern（计划模式），执行以下操作之一：
   
   + 要使用 cron 表达式定义计划，请选择 A fine-grained schedule that runs at a specific time, such as 8:00 a.m.（在特定时间（例如上午 8:00）运行的精细计划） 每月第一个星期一太平洋标准时间。 然后输入 cron 表达式。
   + 要使用速率表达式定义时间表，请选择 A schedule that runs every 10 minutes（以常规速率运行的计划，例如每 10 分钟）。 然后输入速率表达式。
9.  选择 Next（下一步）。
10. 对于 Target types（目标类型），选择 AWS service（服务）。
11. 对于选择目标，选择在 EventBridge 检测到与事件模式匹配的事件时要向其发送信息的AWS服务。
12. 显示的字段因您选择的服务而异。根据需要输入特定于此目标类型的信息。
13. 对于许多目标类型， EventBridge 需要权限以便将事件发送到目标。在这些情况下， EventBridge 可以创建运行事件所需的 IAM 角色。请执行下列操作之一：
    
    + 若要自动创建 IAM 角色，请选择 Create a new role for this specific resource (为此特定资源创建新角色)。
    + 要使用您之前创建的 IAM 角色，请选择 Use existing role（使用现有角色），然后从下拉列表中选择现有角色。
14. （可选）对于 Additional settings（其他设置），执行以下操作：
    + 对于 Maximum age of event（事件的最大时长），输入一分钟（00:01）与 24 小时（24:00）之间的值。
    + 对于重试尝试，输入 0 到 185 之间的数字。
    + 对于死信队列，选择是否使用标准 Amazon SQS 队列作为死信队列。 EventBridge 如果与此规则匹配的事件未成功传递到目标，会将这些事件发送到死信队列。请执行下列操作之一：
      - 选择无不使用死信队列。
      - 在当前 AWS 帐户中选择选择一个Amazon SQS队列用作死信队列，然后从下拉列表中选择要使用的队列。
      - 选择在其他 Amazon SQS 队列中选择其他队列 AWS 帐户作为死信队列，然后输入要使用的队列的 ARN。您必须将基于资源的策略附加到队列，以授予向其发送消息的 EventBridge 权限。有关更多信息，请参阅[授死信队列的权限](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rule-dlq.html#eb-dlq-perms)
15. （可选）选择 Add another target（添加其他目标），以为此规则添加其他目标。
16. 选择 Next（下一步）。
17. （可选）为规则输入一个或多个标签。有关更多信息，请参阅[亚马逊 EventBridge 标签](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-tagging.html)
18. 选择 Next（下一步）。
19. 查看规则详细信息并选择 Create rule（创建规则）。

### 禁用或删除 Amazon EventBridge 规则

停止[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)使其不再处理事件或按计划运行，您可以删除或禁用该规则。以下步骤将指导您如何删除或禁用一条 EventBridge 规则。

#### 删除或禁用规则

1. 打开位于 https://console.aws.amazon.com/events/ 的 Amazon EventBridge 控制台。
2. 在导航窗格中，选择 Rules (规则)。
   
   在 Event bus (事件总线) 下，选择与规则关联的事件总线。
3. 请执行下列操作之一：
   
   - 要删除规则，请选择规则旁边的按钮，然后依次选择 **Actions、Delete 和 Delete**。如果该规则是托管规则，请输入规则的名称以确认它是托管规则，并且删除它可能会在创建规则的服务中停止功能。要继续，请输入规则名称并选择 Force delete (强制删除)。
   - 要临时禁用规则，请选择规则旁边的按钮，然后依次选择 **Disable** (禁用) 和 **Disable** (禁用)。您不能禁用托管规则。

### 使用 Amazon EventBridge 和 AWS Serverless Application Model 模板

你可以在 EventBridge 控制台中手动构建和测试[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)，这可以在您完善[事件模式](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)的开发过程中带来帮助。但是，一旦准备好部署应用程序，就会更容易使用类似[AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)的框架以持续启动所有无服务器资源。

我们将使用[示例应用](https://github.com/aws-samples/amazon-eventbridge-producer-consumer-example)以了解使用 AWS SAM 模板构建 EventBridge 资源的方法。本例中的 `template.yaml` 文件是一个 AWS SAM模板，它定义了四个[AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) 函数并展示了将 Lambda 函数与 EventBridge 集成的两种不同方法。

有关此示例应用程序的演练，请参阅[创建亚马逊 EventBridge 示例应用程序](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-tutorial-get-started.html)。

有两种方法使用 EventBridge 和AWS SAM 模板。对于一个简单集成，当一个Lambda 函数被一个规则调用时，**组合模板**是更被建议使用的方法。如果你有复杂的路由逻辑，或者你正在连接到你的外部的资源AWS SAM模板，***分离的模板**方法是更好的选择。

#### 组合模板

第一种方法使用 `Events` 属性配置 EventBridge 规则。下面的示例代码定义事件调用 Lambda 函数。

> **注意** 此示例自动在默认[事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus.html)下创建一个规则，它存在于每一个 AWS 账号。 要将规则与自定义事件总线相关联，可以向模板添加 `EventBusName`。

```
atmConsumerCase3Fn:
  Type: AWS::Serverless::Function
  Properties:
    CodeUri: atmConsumer/
    Handler: handler.case3Handler
    Runtime: nodejs12.x
    Events:
      Trigger:
        Type: CloudWatchEvent 
        Properties:
          Pattern:
            source:
              - custom.myATMapp
            detail-type:
              - transaction                
            detail:
              result:
                - "anything-but": "approved"
```

此 YAML 代码等同于 EventBridge 控制台中的事件模式。在 YAML 中，你只需要定义事件模式，AWS SAM 将自动创建具有所需权限的 IAM 角色。

#### 分离的模板

在 AWS SAM 中定义 EventBridge 配置的第二种方法，资源在模板中更清楚地分开。

1. 首先，您定义 Lambda 函数：
   ```
    atmConsumerCase1Fn:
    Type: AWS::Serverless::Function
    Properties:
        CodeUri: atmConsumer/
        Handler: handler.case1Handler
        Runtime: nodejs12.x
   ```
2. 接下来，使用 `AWS::Events::Rule` 资源定义规则。属性定义了事件模式，还可以指定[目标](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-targets.html). 您可以明确定义多个目标。
   ```
    EventRuleCase1: 
    Type: AWS::Events::Rule
    Properties: 
        Description: "Approved transactions"
        EventPattern: 
        source: 
            - "custom.myATMapp"
        detail-type:
            - transaction   
        detail: 
            result: 
            - "approved"
        State: "ENABLED"
        Targets: 
        - 
            Arn: 
            Fn::GetAtt: 
                - "atmConsumerCase1Fn"
                - "Arn"
            Id: "atmConsumerTarget1"
   ```
3. 最后，定义 `AWS::Lambda::Permission` 资源，它授予 EventBridge 调用目标的权限。
   ```
   PermissionForEventsToInvokeLambda: 
   Type: AWS::Lambda::Permission
   Properties: 
    FunctionName: 
      Ref: "atmConsumerCase1Fn"
    Action: "lambda:InvokeFunction"
    Principal: "events.amazonaws.com"
    SourceArn: 
      Fn::GetAtt: 
        - "EventRuleCase1"
        - "Arn"
   ```

### 根据亚马逊 EventBridge 规则生成 AWS CloudFormation 模板

AWS CloudFormation通过将基础设施视为代码，使您能够以集中和可重复的方式跨账户和区域配置和管理AWS资源。 AWS CloudFormation 通过允许您创建模板来实现此目的，这些模板定义了要预置和管理的资源。

EventBridge 允许您根据账户中的现有规则生成模板，以帮助您快速开始开发AWS CloudFormation模板。您可以选择单个规则或多个规则将其包含在模板中。然后，您可以使用这些模板作为[创建AWS CloudFormation管理资源堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html)的基础。

有关更多 AWS CloudFormation 信息，请参阅[《AWS CloudFormation用户指南》](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)。

> **注意** EventBridge 生成的模板中不包含[托管规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)。

您也可以[从现有的事件总线生成模板](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-generate-event-bus-template.html)，包括事件总线拥有的规则。

#### 根据规则生成AWS CloudFormation模板

1. 通过 https://console.aws.amazon.com/events/ 打开亚马逊 EventBridge 主机。
2. 在导航窗格中，选择 Rules (规则)。
3. 在 Select event bus 下，请选择要包含在模板中的规则的事件总线，请选择要包含在模板中的规则。
4. 在 “规则” 下，选择要包含在生成的 AWS CloudFormation 模板中的规则。
5. 选择 “CloudFormation 模板”，然后选择 EventBridge 要生成模板的格式：JSON 或 YAML。
   
   EventBridge 显示以选定格式生成的模板。
6. EventBridge 允许您选择下载模板文件或将模板复制到剪贴板。
   
   - 要下载模板文件，请选择 Download
   - 要将模板复制到剪贴板，请选择 Copy。
7 .要退出模板，请选择 “取消”。

根据需要为用例自定义AWS CloudFormation模板后，就可以使用它来在 AWS CloudFormation 下[创建堆栈](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html)。

#### 使用亚马逊 EventBridge 生成的 AWS CloudFormation 模板时的注意事项

使用从 EventBridge 中生成的AWS CloudFormation模板时，请考虑以下因素：

- EventBridge 在生成模板中不包含任何密码。

   您可以编辑模板以包含[模板参数](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)，这些参数允许用户在使用模板创建或更新AWS CloudFormation堆栈时指定密码或其它敏感信息。
   
   此外，用户可以使用 Secrets Manager 在所需区域创建密钥，然后编辑生成的模板以使用[动态参数](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/dynamic-references.html#dynamic-references-secretsmanager)。

- 生成的模板中的目标与它们在原始事件总线中指定的完全相同。如果您在使用模板在其它区域创建堆栈之前未对其进行适当编辑，则可能会导致跨区域问题。

  此外，生成的模板不会自动创建下游目标。

## Amazon EventBridge 目标

目标是一种资源或端点，当事件与为[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)定义的事件模式匹配时，EventBridge 会将[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html) 发送到该资源或端点。该规则处理[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)数据并将相关信息发送到目标。要将事件数据传送到目标，EventBridge 需要访问目标资源的权限。可以为每条规则定义最多五个目标。

当您将目标添加到规则并在不久之后运行该规则时，可能不会立即调用任何新的或更新的目标。请稍等片刻，以便更改生效。

### EventBridge 控制台中可用的目标

您可以在 EventBridge 控制台中为事件配置以下目标：

- [API 目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-destinations.html)
- [API Gateway](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-gateway-target.html)
- [Batch 作业队列](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-specifics-batch)
- [CloudWatch 日志组](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-specifics-cwl)
- [CodeBuild 项目](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-specifics-codebuild)
- CodePipeline
- 亚马逊 EBSCreateSnapshot API 调用
- EC2 Image Builder
- EC2 RebootInstances API 调用
- EC2 StopInstances API 调用
- EC2 TerminateInstances API 调用
- [ECS 任务](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-specifics-ecs-task)
- [不同账户或区域中的事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html)
- [同一账户和区域中的事件总线](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-bus-to-bus.html)
- Firehose 传输流
- Glue 工作流
- [Incident Manager 响应计划](https://docs.aws.amazon.com//incident-manager/latest/userguide/incident-creation.html#incident-tracking-auto-eventbridge)
- Inspector 评估模板
- Kinesis 流
- Lambda 函数（异步）
- Redshift 集群数据 API 查询
- SageMaker 管道
- SNS 主题
- SQS 队列
- Step Functions 状态机 (ASYNC)
- Systems Manager Automation
- Systems Manager OpsItem
- Systems Manager 运行命令

#### 目标参数

有些目标不会将事件负载中的信息发送给目标，而是将事件视为调用特定 API 的触发器。EventBridge 使用[目标](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_Target.html)参数来确定该目标会发生什么。这些功能包括：

- API 目标（发送到 API 目标的数据必须与 API 的结构相匹配。您必须使用该[InputTransformer](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_InputTransformer.html)对象来确保数据的结构正确。如果要包含原始事件负载，请在[InputTransformer](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_InputTransformer.html)中引用它。）
- API Gateway（发送到 API Gateway 的数据必须与 API 的结构相匹配。您必须使用该[InputTransformer](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_InputTransformer.html)对象来确保数据的结构正确。如果要包含原始事件负载，请在[InputTransformer](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_InputTransformer.html)中引用它。）
- Amazon EC2 Image Builder
- [RedshiftDataParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_RedshiftDataParameters.html)（Amazon Redshift ft 数据 API 集群）
- [SageMakerPipelineParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_SageMakerPipelineParameters.html)（亚马逊建 SageMaker 模管道）

> **注意** EventBridge 不支持所有 JSON 路径语法并在运行时对其进行评估。支持的语法包括：
> 点符号（例如，$.detail）
> 连接号
> 下划线
> 字母数字字符
> 数组索引
> 通配符 (*)

#### 动态路径参数

一些目标参数支持可选的动态 JSON 路径语法。此语法允许您指定 JSON 路径而不是静态值（例如 `$.detail.state`）。整个值必须是 JSON 路径，而不仅仅是其中的一部分。例如，`RedshiftParameters.Sql` 可以 `$.detail.state` 但不可能 "SELECT * FROM $.detail.state"。这些路径在运行时被来自指定路径的事件负载本身的数据动态替换。动态路径参数无法引用输入转换产生的新值或变换后的值。动态参数 JSON 路径支持的语法与转换输入时的语法相同。有关更多信息，请参阅[亚马逊 EventBridge 输入转换](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-transform-target-input.html)

动态语法可用于以下参数的所有字符串、非枚举字段：

- [EcsParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_EcsParameters.html)
- [HttpParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_HttpParameters.html)（HeaderParameters钥匙除外）
- [RedshiftDataParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_RedshiftDataParameters.html)
- [SageMakerPipelineParameters](https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_SageMakerPipelineParameters.html)

#### 权限

要对您拥有的资源执行 API 调用， EventBridge 需要相应权限。对于AWS Lambda和 Amazon SNS 资源， EventBridge 使用[基于资源的策略](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-use-resource-based.html)。对于 EC2 实例、Kinesis 数据流和 Step Functions 状态机， EventBridge 使用您在RoleARN参数中指定的 IAM 角色PutTargets。您可以使用配置的 IAM 授权调用 API Gateway 终端节点，但如果您尚未配置授权，则该角色是可选的。有关更多信息，请参阅[亚马逊 EventBridge 和AWS Identity and Access Management](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-iam.html)

如果另一个账户在同一区域并且已授予您权限，您可以向该账户发送事件。有关更多信息，请参阅[在AWS账户之间发送和接收亚马逊 EventBridge 事件](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-cross-account.html)：

如果目标已加密，您必须在 KMS 密钥策略中包含以下部分。

```
{
    "Sid": "Allow EventBridge to use the key",
    "Effect": "Allow",
    "Principal": {
        "Service": "events.amazonaws.com"
    },
    "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
    ],
    "Resource": "*"
}
```

#### EventBridge 目标细节

### 配置目标

#### API 目的地

Amazon EventBridge API 目标是您可以作为被调用的[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)的[目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html) 的HTTP 终端节点，类似于您调用AWS服务或资源作为目标的方式。使用 API 目标，您可以使用 API 调用在AWS服务、集成软件即服务 (SaaS) 应用程序和外部应用程序之间路由[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)。当您将一个 API 目标指定为规则的目标时，EventBridge 将为与规则中指定的[事件模式](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)匹配的任何事件 EventBridge 调用 HTTP 终端节点，然后随请求一起传送事件信息。使用 EventBridge，您可以使用除 CONNECT 和 TRACE 之外的任何 HTTP 方法进行请求。最常用的 HTTP 方法是 PUT 和 POST。您还可以使用输入转换器根据特定 HTTP 端点参数的参数自定义事件。有关更多信息，请参阅[亚马逊 EventBridge 输入转换](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html)。

> **重要** EventBridge 对 API 目标端点的请求的最大客户端执行超时时间必须为 5 秒。如果目标终端节点的响应时间超过 5 秒， EventBridge 则请求超时。 EventBridge 重试超时请求至重试策略上配置的最大值。默认情况下，最大值为 24 小时和 185 次。在达到最大重试次数后，如果有[死信队列](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rule-dlq.html)，则将事件发送到死信队列。否则，该事件将被丢弃。

##### API 目标的连接

创建 API 目标时，您可以指定要用于该目标的连接。连接制定了授权类型，以及向 API 目标端点授权所需参数。您可以从你的账户中选择现有连接，也可以在创建 API 目标时创建连接。EventBridge 支持 Basic、OAuth 和 API 密钥授权。

对于 Basic 和 API 密钥授权，EventBridge 为您填充所需的授权标头。对于 OAuth 授权，EventBridge 还可以将您的客户端 ID 和密钥交换为访问令牌，然后对其进行安全管理。创建连接时，还可以包括端点授权所需的标头、正文和查询参数。如果终端节点的授权相同，则可以对多个 API 目标使用同一个连接。

当返回 401 或 407 响应时，会刷新 OAuth 令牌。

当您创建连接并添加授权参数时，EventBridge 会在 AWS Secrets Manager 中创建密钥。存储 Secrets Manager 密钥的成本包含在使用 API 目标的费用中。要详细了解在 API 目标中使用密钥的最佳实践，请参阅CloudFormation 用户指南中的[AWS::Events::ApiDestination](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-apidestination.html)。

> **注意** 要成功创建或更新连接，您必须拥有一个有权使用 Secrets Manager 的帐户。所需的权限包含在 [AmazonEventBridgeFullAccess 策略](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html#eb-full-access-policy)。为在您的账户中创建的用于连接的[服务关联角色](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-destinations.html#eb-api-destination-slr)被授予相同的权限。

**创建连接**

1. 使用具有管理 EventBridge 权限的帐户登录 AWS 并打开 EventBridge控制台https://console.aws.amazon.com/events
2. 在左侧导航窗格中，选择 API 目标。
3. 向下滚动到 API 目标表，然后选择 “连接” 选项卡。
4. 选择 Create connection (创建连接)。
5. 在创建连接页面上，输入连接的连接名称。
6. 输入连接的描述。
7. 对于授权类型，选择用于授权连接到为使用此连接的 API 目标指定的 HTTP 端点的授权类型。请执行下列操作之一：
   + 选择 Basic（用户名/密码），然后输入用于对 HTTP 端点进行授权的用户名和密码。
   + 选择 OAuth 客户端证书（ OAuth Client Credentials,），然后输入用于对端点进行授权的授权端点、HTTP 方法、客户端 ID 和客户端密钥。
     - 在 OAuth Http 参数下，添加任何其他要包含的用于授权端点的参数。从下拉列表中选择一个参数，然后输入键和值。要包括其他参数，请选择添加参数。
     - 在 “调用 Http 参数” 下，添加要包含在授权请求中的任何其他参数。要添加参数，请从下拉列表中选择一个参数，然后输入键和值。要包括其他参数，请选择添加参数。
   + 选择 API 密钥，然后输入用于 API 密钥授权的 API 密钥名称和关联值。
     在 “调用 Http 参数” 下，添加要包含在授权请求中的任何其他参数。要添加参数，请从下拉列表中选择一个参数，然后输入键和值。要包括其他参数，请选择添加参数。
8. 选择创建。

**要编辑连接**

1. 打开 API 目标页面，然后选择 “连接”。
2. 在连接表中，选择要编辑的连接。
3. 在连接详细信息页面上，选择编辑。
4. 更新连接的值，然后选择 “更新”。

**取消连接授权**

取消对连接的授权时，它会删除所有授权参数。删除授权参数会将密钥从连接中删除，因此您无需创建新连接即可重复使用该密钥。

> **注意** 您必须更新使用已取消授权的连接的任何 API 目标才能使用不同的连接成功向 API 目标终端节点发送请求。

1. 在 “连接” 表中，选择连接。
2. 在连接详细信息页面上，选择取消授权。
3. 在 `取消授权连接？` 对话框中，输入连接的名称，然后选择 `取消授权`。

在过程完成之前，连接的状态会更改为取消授权。然后，状态更改为已取消授权。现在，您可以编辑连接以添加新的授权参数。

##### 创建 API 目标

每个 API 目的地都需要连接。连接指定了授权访问 API 目标授权类型以及相关凭证。您可以选择现有连接，或在创建 API 目标的同时创建连接。

1. AWS使用具有管理权限的帐户登录 EventBridge 并打开 [EventBridge控制台](https://console.aws.amazon.com/events)
2. 在左侧导航窗格中，选择 API 目标。
3. 向下滚动到 API 目标表，然后选择创建 API 目标。
4. 在创建 API 目标页面上，输入 API 目标的名称。您最多可以使用 64 个大写化或小写化字母、数字、点 (.)、短划线 (-) 或下划线 (_) 字符。该名称对于您在当前区域中的账户必须唯一。
5. 输入 API 目标的描述。
6. 输入 API 目标的 API 目标终端节点。API 目标端点是事件的 HTTP 调用端点目标。您在用于此 API 目标的连接中包含的授权信息用于针对此终端节点进行授权。URL 必须使用 HTTPS。
7. 输入用于连接到 API 目标端点的 HTTP 方法。
8. 可选）在每秒调用速率限制。您设置的速率限制可能会影响事件的 EventBridge 传送方式。有关更多信息，请参阅[调用速率如何影响事件交付](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-api-destinations.html#eb-api-destination-event-delivery)
9. 此外，执行以下操作之一：
   + 选择 “使用现有连接”，然后选择要用于此 API 目标的连接。
   + 选择 “创建新连接”，然后输入要创建的连接的详细信息。有关更多信息，请参阅[连接](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-api-destinations.html#eb-api-destination-connection)。
10. 选择创建。

创建 API 目标后，可以选择它作为[规则](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rules.html)的目标。要使用 API 目标作为目标，您必须提供具有正确权限的 IAM 角色。有关更多信息，请参阅[使用 IAM 角色访问 EventBridge 目标所需的权限](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-use-identity-based.html#eb-target-permissions)。

##### 创建发送事件至 API 目标的规则

当您创建 API 目标后，你可以选择它为规则https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html的目标。为了使用 API 目标作为目标，你必须提供一个带有正确权限的 IAM 角色。更多信息，请参见 EventBridge 使用 IAM 角色访问目标所需权限https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-use-identity-based.html#eb-target-permissions。

选择一个 API 目标作为目标是创建规则的一部分。

使用控制台创建发送事件至 API 目标的规则：

- 遵从[创建 Amazon EventBridge 规则以应对事件的流程](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule.html)
- 在[选择目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule.html#eb-create-rule-target)步骤，在提示选择目标类型时：
  
  + 选择 EventBridge API 目标
  + 选择已有 API 目标，或选择创建一个新的 API 目标。

  如果你选择创建一个新的 API 目标，如提示提供所需信息。
- 遵从步骤以完成规则创建。


##### API 目标的服务相关角色

当您为 API 目标创建连接时，会在您的账户中添加一个名为 AWSServiceRoleForAmazonEventBridgeApiDestinations 服务相关角色。EventBridge 使用这个服务相关角色在 Secrets Manager 中创建和存储密钥。EventBridge 将 AmazonEventBridgeApiDestinationsServiceRolePolicy 策略附加到该角色。该策略将授予的权限仅限于角色与连接密钥进行交互所必需的权限。不包含其他权限，并且该角色只能与您账户中的连接进行交互以管理密钥。

以下政策即为 AmazonEventBridgeApiDestinationsServiceRolePolicy：

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:CreateSecret",
                "secretsmanager:UpdateSecret",
                "secretsmanager:DescribeSecret",
                "secretsmanager:DeleteSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:*:*:secret:events!connection/*"
        }
    ]
}
```

有关服务相关角色的更多信息，请参阅 IAM 文档中的[使用服务相关角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html)。

##### 发往 API 目标的请求中包含的标头

除了为用于 API 目标的连接定义的授权标头外，每个请求中 EventBridge 还包括以下标头。

标题关键字|标头值
--------|--------
User-Agent|Amazon/EventBridge/ApiDestinations
Content-Type|application/json; charset=utf-8
Range|bytes=0-1048575
Accept-Encoding|gzip、deflate
Connection|close
Content-Length|表示发送到接收方的实体主体的大小 (以字节为单位)。
Host|一个请求标头，用于指定发送请求的服务器的主机和端口号。

##### API 目标错误代码

当 EventBridge 尝试将事件传送到 API 目标并发生错误时， EventBridge会执行以下操作：

- 重试与错误代码 429 和 5xx 相关的事件。
- 不会重试与错误代码 1xx、2xx、3xx 和 4xx（不包括 429）相关的事件。

EventBridge API 目标读取标准 HTTP 响应标头 `Retry-After`，以了解在发出后续请求之前需要等待多长时间。EventBridge 在定义的重试策略和 `Retry-After` 标头之间选择更保守的值。如果 `Retry-After` 值为负数，则 EventBridge 停止重试该事件的交付。

##### 调用速率如何影响事件交付

如果您将每秒调用速率设置为远低于生成的调用次数的值，则可能无法在 24 小时的事件重试时间内传送事件。例如，如果您将调用速率设置为每秒 10 次调用，但每秒生成数千个事件，则要交付的事件积压将很快超过 24 小时。为确保不会丢失任何事件，请设置死信队列以将调用失败的事件发送到死信队列，这样您就可以在以后处理这些事件。有关更多信息，请参阅[事件重试策略和使用死信队列](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-rule-dlq.html)。

##### API 目标合作伙伴

使用以下AWS合作伙伴提供的信息为其服务或应用程序配置 API 目标和连接。

#### Amaz EventBridge on API Gateway

您可以使用 Amazon API Gateway 创建、发布、维护和监控 API。Amazon EventBridge 支持将事件发送到 API Gateway 终端节点。当您将 API Gateway 终端节点指定为[目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html)时，发送到目标的每个[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)都映射为发送到该终端节点的请求。

> **重要** EventBridge 支持使用 API Gateway 边缘优化和区域终端节点作为目标。目前不支持@@ 私有终端节点。要了解端点的详情，请参阅https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html。

您可以将 API Gateway 目标用于以下使用案例：

- 基于AWS或第三方事件调用托管在 API Gateway 中的客户指定的 API。
- 按计划定期调用终端节点。

EventBridge JSON 事件信息作为 HTTP 请求的正文发送到您的终端节点。您可以在目标HttpParameters字段中指定其他请求属性，如下所示：

- `PathParameterValues` 例如，列出了按顺序对应于终端节点 ARN 中任何路径变量的值 "arn:aws:execute-api:us-east-1:112233445566:myapi/*/POST/pets/*"。
- `QueryStringParameters` 表示 EventBridge 附加到调用端点的查询字符串参数。
- `HeaderParameters` 定义要添加到请求的 HTTP 标头。

出于安全考虑，不允许使用以下 HTTP 标头键：

+ 任何以X-Amz或为前缀的东西X-Amzn
+ Authorization
+ Connection
+ Content-Encoding
+ Content-Length
+ Host
+ Max-Forwards
+ TE
+ Transfer-Encoding
+ Trailer
+ Upgrade
+ Via
+ WWW-Authenticate
+ X-Forwarded-For

##### 动态参数

调用 API Gateway 目标时，您可以将数据动态添加到发送到目标的事件中。有关更多信息，请参阅[目标参数](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-targets.html#targets-specific-parms)

##### 调用重试次数

与所有目标一样，EventBridge 重试一些失败的调用。对于 API Gateway，EventBridge 重试使用 5xx 或 429 HTTP 状态码发送的响应最长 24 小时，并呈[指数级回退和抖动](http://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)。之后，在亚马逊 CloudWatch 上 EventBridge 发布 `FailedInvocations` 指标。EventBridge 不会重试其他 4xx HTTP 错误。

##### Timeout

EventBridge 规则 API Gateway 请求的最大客户端执行超时时间必须为 5 秒。如果 API Gateway 的响应 EventBridge 时间超过 5 秒，则超时请求然后重试。

EventBridge 管道 API Gateway 请求的最大超时时间为 29 秒，即 API Gateway 的最大超时时间。

#### 在AWS账户之间发送和接收亚马逊 EventBridge 事件
#### 在AWS区域之间发送和接收亚马逊 EventBridge 事件
#### 在同一账户和同一地区的 EventBridge 事件总线之间发送和接收 Amazon 事件


### 输入转换

在将信息 EventBridge传递给[规则](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html)[目标](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html)之前，您可以自定义[事件](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events.html)中的文本。使用控制台或 API 中的输入转换器，您可以定义使用 JSON 路径引用原始事件源中的值的变量。将转换后的事件发送到目标而不是原始事件。但是，[动态路径参数](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html#targets-dynamic-parms)必须引用原始事件，而不是转换后的事件。您最多可以定义 100 个变量，为每个变量分配一个输入值。然后，您可以在输入模板 中以 `<variable-name>` 形式使用这些变量。

有关使用输入转换器的教程，请参见教程：[使用输入转换器自定义 EventBridge 传递给事件目标的内容](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-input-transformer-tutorial.html)。

#### 预定义变量

您可以使用预定义的变量而无需定义 JSON 路径。这些变量是保留的，您无法使用以下名称创建变量：

- `aws.events.rule-arn`— EventBridge 规则的亚马逊资源名称 (ARN)。
- `aws.events.rule-name`— EventBridge 规则的名称。
- `aws.events.event.ingestion-time`— EventBridge 接收事件的时间。这是 ISO 8601 时间戳。此变量由 EventBridge 生成，无法被覆盖。
- `aws.events.event`—  JSON 格式的原始事件负载（不含detail字段）。只能用作 JSON 字段的值，因为其内容不会被转义。
- `aws.events.event.json`— 完整的JSON 格式的原始事件负载（带字detail段）。只能用作 JSON 字段的值，因为其内容不会被转义。

#### 输入转换示例

以下是 Amazon EC2 事件的示例。

```
{
  "version": "0",
  "id": "7bf73129-1428-4cd3-a780-95db273d1602",
  "detail-type": "EC2 Instance State-change Notification",
  "source": "aws.ec2",
  "account": "123456789012",
  "time": "2015-11-11T21:29:54Z",
  "region": "us-east-1",
  "resources": [
    "arn:aws:ec2:us-east-1:123456789012:instance/i-abcd1111"
  ],
  "detail": {
    "instance-id": "i-0123456789",
    "state": "RUNNING"
  }
}
```

在控制台中定义规则时，在 “配置输入” 下选择 “输入转换器” 选项。此选项显示两个文本框：一个用于 Input Path (输入路径) ，一个用于 Input Template (输入模板)。

输入路径用于定义变量。使用 JSON 路径引用事件中的元素（条目），并将这些值存储在变量中。例如，您可以通过在第一个文本框中输入以下内容来创建一个输入路径，以引用示例事件中的值。你也可以使用方括号和索引从数组中获取元素。

> **注意** EventBridge 在运行时替换输入转换器以确保有效的 JSON 输出。因此，请在引用 JSON 路径参数的变量前后加上引号，但不要在引用 JSON 对象或数组的变量前后加上引号。

```
{
  "timestamp" : "$.time",
  "instance" : "$.detail.instance-id", 
  "state" : "$.detail.state",
  "resource" : "$.resources[0]"
}
```

这定义了四个变量`<timestamp>` `<instance>`、`<state>`、和 `<resource>`。您可以在创建输入模板 时引用这些变量。

输入模板是您要传递给目标的信息的模板。您可以创建将字符串或 JSON 传递到目标的模板。使用上一个事件和输入路径，以下输入模板示例将事件转换为示例输出，然后再将其路由到目标。

描述|模板|Output
--------|--------|--------
简单字符串|"instance <instance> is in <state>"|"instance i-0123456789 is in RUNNING"
带转义引号的字符串|"instance \"<instance>\" is in <state>"|"instance \"i-0123456789\" is in RUNNING"。请注意，这是 EventBridge 控制台中的行为。AWS CLI 对斜杠字符进行转义，结果为 "instance "i-0123456789" is in RUNNING"。
简单的 JSON|{"instance" : <instance>,"state": <state>}|{"instance" : "i-0123456789", "state": "RUNNING"}。
包含字符串和变量的 JSON|{"instance" : <instance>,"state": "<state>","instanceStatus": "instance \"<instance>\" is in <state>"}|{"instance" : "i-0123456789", "state": "RUNNING", "instanceStatus": "instance \"i-0123456789\" is in RUNNING"}
混合变量和静态信息的 JSON|{"instance" : <instance>,"state": [ 9, <state>, true ],"Transformed" : "Yes"}|{"instance" : "i-0123456789","state": [9,"RUNNING",true],"Transformed" : "Yes"}
在 JSON 中包含保留变量|{"instance" : <instance>,"state": <state>,"ruleArn" : <aws.events.rule-arn>,"ruleName" : <aws.events.rule-name>,"originalEvent" : <aws.events.event.json>}|{"instance" : "i-0123456789","state": "RUNNING","ruleArn" : "arn:aws:events:us-east-2:123456789012:rule/example","ruleName" : "example","originalEvent" : { ... // commented for brevity}}
在字符串中包含保留变量|"<aws.events.rule-name> triggered"|"example triggered"
亚马逊 CloudWatch 日志组|{"timestamp" : <timestamp>,"message": "instance \"<instance>\" is in <state>"}|{"timestamp" : 2015-11-11T21:29:54Z,"message": "instance "i-0123456789" is in RUNNING}

#### 使用 EventBridge API 转换输入


#### 使用以下方法转换输入AWS CloudFormation


#### 转换输入的常见问题


### 计划程序

除了计划规则外， EventBridge 现在还提供新的计划功能，即 Amazon EventBridge Scheduler。 EventBridge Scheduler 是一种无服务器调度程序，允许您通过一个中央托管服务创建、运行和管理任务。 EventBridge Scheduler 具有高度可定制性，与 EventBridge 计划规则相比，可扩展性更高，目标 API 操作和AWS服务范围更广。 EventBridge 调度器允许您调度数百万个任务，这些任务可以调用 270 多个AWS服务和超过 6,000 个 API 操作。无需预置和管理基础架构，也无需集成多种服务，S EventBridge cheduler 使您能够大规模交付计划并降低维护成本。

EventBridge Scheduler 通过内置机制可靠地交付您的任务，这些机制可根据下游目标的可用性调整计划。使用 EventBridge Scheduler，您可以使用 cron 和速率表达式为循环模式创建计划，或者配置一次性调用。您可以设置灵活的交付时间窗口、定义重试限制以及为失败的触发器设置最大保留时间。

我们建议您使用 EventBridge 调度器按计划调用目标。有关更多信息，请参阅下列内容。

EventBridge 调度器资源

- [EventBridge 调度器用户指南](https://docs.aws.amazon.com/scheduler/latest/UserGuide/index.html)
- [EventBridge 调度器 API 参考](https://docs.aws.amazon.com/scheduler/latest/APIReference/Welcome.html)

## Reference

- [EventBridge](https://docs.aws.amazon.com/zh_cn/eventbridge/latest/userguide/eb-what-is.html)