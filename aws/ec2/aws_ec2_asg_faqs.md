# Amazon EC2 Auto Scaling FAQs
## 一般性问题（General）
**问：什么是 Amazon EC2 Auto Scaling？**

Amazon EC2 Auto Scaling 是一项完全托管的服务，可自动启动或终止 Amazon EC2 实例，以帮助确保您拥有适当数量的 Amazon EC2 实例来处理应用程序负载。Amazon EC2 Auto Scaling 通过对 EC2 实例进行队列管理（fleet management），检测并替换运行状况异常的实例，并根据您定义的条件自动扩展或缩减 Amazon EC2 容量，从而帮助您保持应用程序的可用性。在需求高峰期，您可以使用 Amazon EC2 Auto Scaling 来自动增加 Amazon EC2 实例的数量以便保持性能，并在需求降低时减少容量以降低成本。

**问：我什么时候该使用 Amazon EC2 Auto Scaling，什么时候该使用 AWS Auto Scaling？**

你应该使用 AWS Auto Scaling 来管理跨多个服务的多个资源的伸缩。AWS Auto Scaling 允许你使用预定义伸缩策略来为多个 EC2 Auto Scaling Group 或其它资源定义动态伸缩策略。使用 AWS Auto Scaling 来为你的应用中的所有可伸缩资源配置伸缩策略比通过单独服务控制台来管理单个资源伸缩策略要快速。它也更简单，因为 AWS Auto Scaling 包含了预定义的伸缩策略，这简化了伸缩策略的设置。如果你想为EC2资源创建可预测的伸缩，你也应该使用 AWS Auto Scaling。

如果你仅仅需要伸缩 Amazon EC2 Auto Scaling groups，或者你对维护你的 EC2 编排感兴趣，你应该使用EC2 Auto Scaling。如果你需要创建和配置 Amazon EC2 Auto Scaling groups，或者如果你需要计划或分步（scheduled or step）伸缩策略（因为 AWS Auto Scaling 仅仅支持目标追踪申诉策略），你也应该使用 EC2 Auto Scaling。

EC2 Auto Scaling groups 必须在 AWS Auto Scaling 之外创建和配置，例如通过 EC2 控制台，Auto Scaling API 或通过 CloudFormation。AWS Auto Scaling 可帮助你为你已有的 EC2 Auto Scaling groups 配置动态伸缩策略。

**问：使用 Amazon EC2 Auto Scaling 有些什么好处？**

Amazon EC2 Auto Scaling 有助于维护 Amazon EC2 实例的可用性。不论您运行多少个 Amazon EC2 实例，都可以使用 Amazon EC2 Auto Scaling 来检测损坏的 Amazon EC2 实例，而且无需干预就能完成实例的替换工作。这样可确保您的应用程序具有您所期望的计算能力。您可以使用 Amazon EC2 Auto Scaling 按照应用程序的需求曲线自动扩展 Amazon EC2 队列，从而减少提前手动预置 Amazon EC2 容量的需要。例如，您可以设置一个条件，当 Amazon EC2 队列的平均使用率较高时，以增量方式向 ASG 添加新的 Amazon EC2 实例；同样，也可以设置一个条件，在 CPU 使用率较低时，以增量方式删除实例。您也可以使用 Amazon CloudWatch 发送警报，以触发扩展活动；并使用 Elastic Load Balancing (ELB) 向 ASG 内的实例分配流量。如果您的负载变化情况可以预测，那么您可以通过 Amazon EC2 Auto Scaling 制定伸缩活动计划。Amazon EC2 Auto Scaling 让您能够以最佳使用率运行 Amazon EC2 队列。

**问：什么是队列管理（fleet management）？它与动态扩展有何区别？**

如果您的应用程序在 Amazon EC2 实例上运行，那么您就拥有所谓的“队列”。队列管理指的是一种自动替换运行状况不佳的实例，从而使您的队列保持预期容量的功能。Amazon EC2 Auto Scaling 队列管理可确保您的应用程序能够接收流量，以及实例本身正常运行。如果 Auto Scaling 检测到某个实例未通过运行状况检查，就会自动替换该实例。

Amazon EC2 Auto Scaling 的动态扩展功能指的是一种根据负载或其它指标自动增加或减少容量的功能。例如，如果您的 CPU 峰值超过 80%（并且您设置了警报），则 Amazon EC2 Auto Scaling 可以动态添加新实例。

**问：什么是目标跟踪（target tracking）？**

目标跟踪是一种新型扩展策略，只需几个简单的步骤，您就可以用它为应用程序设置动态扩展。借助目标跟踪，您可以为应用程序选择负载指标（比如 CPU 利用率或请求次数）、设置目标值，并且 Amazon EC2 Auto Scaling 将根据需要调整 ASG 中的 EC2 实例数量以维持该目标。它就像一个家用恒温器，自动调节系统，使环境保持在您想要的温度。例如，您可以配置目标跟踪，使您的 Web 服务器整体的 CPU 利用率保持在 50％。然后，Amazon EC2 Auto Scaling 将根据需要启动或终止 EC2 实例，使平均 CPU 利用率保持在 50%。

**问：什么是 EC2 Auto Scaling 组 (ASG)？**

Amazon EC2 Auto Scaling 组 (ASG) 中包含一个 EC2 实例集合，这些实例具有相似的特征，并被作为一个逻辑分组用于队列管理和动态扩展。例如，如果单个应用程序在多个实例上运行，可能需要增加该组中的实例数量来提高应用程序性能，或者在需求下降时减少实例数量来降低成本。Amazon EC2 Auto Scaling 将自动调整组中的实例数量，以便在实例的运行状况不佳时或根据您指定的条件保持固定数量的实例。您可以在 [Amazon EC2 Auto Scaling 用户指南[(http://docs.aws.amazon.com/autoscaling/latest/userguide/AutoScalingGroup.html)中找到有关 ASG 的更多信息。

**问：如果删除 ASG，我的 Amazon EC2 实例会发生什么情况？**

如果您的 EC2 Auto Scaling 组 (ASG) 中有运行的实例，而且您选择删除该 ASG，则实例会被终止，ASG 会被删除。

**问：我如何知道 EC2 Auto Scaling 何时启动或终止 EC2 Auto Scaling 组中的 EC2 实例？**

当您使用 Amazon EC2 Auto Scaling 自动伸缩应用程序时，了解 EC2 Auto Scaling 何时启动或终止 EC2 Auto Scaling 组中的 EC2 实例将非常有用。Amazon SNS 可协调和管理向订阅客户端或终端节点的通知分发。您可以配置 EC2 Auto Scaling，使其在 EC2 Auto Scaling 组扩展时发送 SNS 通知。Amazon SNS 能够以 HTTP/HTTPS POST、电子邮件（SMTP，纯文本或 JSON 格式）或发布到 Amazon SQS 队列的消息的形式发送通知。例如，如果将 EC2 Auto Scaling 组配置为使用 autoscaling: EC2_INSTANCE_TERMINATE 通知类型，那么当 EC2 Auto Scaling 组终止某个实例时，它就会发送电子邮件通知。该电子邮件包含已终止实例的详细信息，如实例 ID 以及终止该实例的原因。

有关更多信息，请参阅[在 EC2 Auto Scaling 组伸缩时获取 SNS 通知](http://docs.aws.amazon.com/autoscaling/latest/userguide/ASGettingNotifications.html)。

**问：什么是启动配置？**

启动配置是指 EC2 Auto Scaling 组用于启动 EC2 实例的模板。创建启动配置时，您需指定实例的信息，例如 Amazon 系统映像 (AMI) ID、实例类型、一个密钥对、一个或多个安全组和一个块储存设备映射。如果您之前已启动 EC2 实例，可以指定相同的信息来启动实例。创建 EC2 Auto Scaling 组时必须指定启动配置。您可以使用多个 EC2 Auto Scaling 组来指定启动配置。但是一次只能为一个 EC2 Auto Scaling 组指定一个启动配置，而且启动配置在创建后不能修改。因此，如果要更改 EC2 Auto Scaling 组的启动配置，必须先创建启动配置，然后用新的启动配置更新 EC2 Auto Scaling 组。更改 EC2 Auto Scaling 组的启动配置后，系统将使用新的配置参数启动所有新实例，但现有实例不受影响。您可以参阅《EC2 Auto Scaling 用户指南》的[启动配置](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html)部分，了解更多详细信息。

**问：一个 EC2 Auto Scaling 组可以有多少实例？**

您可以在 EC2 Auto Scaling 组中拥有您的 EC2 配额允许的实例数量。

**问：如果扩展活动使我达到了 Amazon EC2 实例数量限制，会发生什么情况？**

Amazon EC2 Auto Scaling 的扩展无法超过您可以运行的 Amazon EC2 实例数量限制。如果需要运行更多数量的 Amazon EC2 实例，请填写 [Amazon EC2 实例请求表](https://aws.amazon.com/contact-us/ec2-request/)。

**问：EC2 Auto Scaling 组可以跨多个 AWS 区域吗？**

EC2 Auto Scaling 组是区域性结构。它们可以跨可用区，但不跨 AWS 区域。

**问：如何在 EC2 Auto Scaling 组中的多个实例之间实施更改？**

您可以使用 AWS CodeDeploy 或 CloudFormation 编排对 EC2 Auto Scaling 组中的多个实例的代码更改。

**问：如果我在 EC2 Auto Scaling 组中安装了数据，并且稍后动态创建了一个新实例，那么数据是否会复制到新实例？**

数据不会自动从现有实例复制到新实例。您可以使用[生命周期挂钩](http://docs.aws.amazon.com/autoscaling/latest/userguide/lifecycle-hooks.html)复制数据，或使用包含副本的 [Amazon RDS](https://aws.amazon.com/rds/) 数据库。

**问：当我从现有实例创建 EC2 Auto Scaling 组时，是否会创建一个新的 Amazon 系统映像 (AMI)？**

当您从现有实例创建 Auto Scaling 组时，不会创建新的 AMI。有关更多信息，请参阅[使用 EC2 实例创建 Auto Scaling 组](http://docs.aws.amazon.com/autoscaling/latest/userguide/create-asg-from-instance.html)。

**问：Amazon EC2 Auto Scaling 如何均衡容量？**

保持[可用区](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)之间的资源均衡是架构完善的应用程序的最佳实践，因为这极大地提高了聚合系统的可用性。当您在 EC2 Auto Scaling 组设置中[配置多个可用区时](http://docs.aws.amazon.com/autoscaling/latest/userguide/as-add-availability-zone.html)，Amazon EC2 Auto Scaling 会自动均衡这些可用区中的 EC2 实例。Amazon EC2 Auto Scaling 始终确保在启动新实例时，使它们尽可能均匀地分布在整个队列的可用区之间。此外，Amazon EC2 Auto Scaling 仅在其中有可用于所请求的实例类型的容量的可用区中启动。

**问：什么是生命周期挂钩？**

生命周期挂钩让您可以在实例投入使用或终止之前采取措施。如果您没有将软件环境融入到 Amazon 系统映像 (AMI) 中，这将非常有用。例如，启动挂钩可以在实例上执行软件配置，以确保它在 Amazon EC2 Auto Scaling 继续将其连接到负载均衡器之前完全做好处理流量的准备。可实现此目的的一种方法是将启动挂钩连接到在实例上调用 RunCommand 的 AWS Lambda 函数。终止挂钩可用于在实例被删除之前从实例中收集重要数据。例如，您可以使用终止挂钩来保存您的队列日志文件，方法是在实例停止使用时将其复制到 Amazon S3 存储桶。

请访问《Amazon EC2 Auto Scaling 用户指南》中的[生命周期挂钩](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html)，了解更多信息。

**问：“运行状况不佳”的实例有哪些特征？**

运行状况不佳的实例指的是硬件由于某种原因（磁盘损坏等）而受损或者没有通过用户配置的 ELB 运行状况检查的实例。Amazon EC2 Auto Scaling 定期对每个单独的 EC2 实例执行[运行状况检查](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html)，如果实例连接到 Elastic Load Balancing 负载均衡器，则还可以执行 [ELB 运行状况检查](http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-healthchecks.html)。

**问：我是否可以自定义运行状况检查？**

是，您可以使用 SetInstanceHealth API 将实例状态更改为“UNHEALTHY”，然后执行终止和替换操作。

**问：我是否可以暂停运行状况检查（例如，转而评估运行状况不佳的实例）？**

是，您可以使用 SuspendProcesses API 临时暂停 Amazon EC2 Auto Scaling 运行状况检查。您可以使用 ResumeProcesses API 恢复自动运行状况检查。

**问：我应该选择哪种类型的运行状况检查？**

如果您在组中使用 Elastic Load Balancing (ELB)，则应选择 ELB 运行状况检查。如果您未在组中使用 ELB，则应选择 EC2 运行状况检查。

**问：如果未使用 Elastic Load Balancing (ELB)，我是否可以使用 Amazon EC2 Auto Scaling 执行运行状况检查并替换运行状况不佳的实例？**

您无需使用 ELB 就能使用 Auto Scaling。您可以使用 EC2 运行状况检查来发现和替换运行状况不佳的实例。

**问：Elastic Load Balancing (ELB) 运行状况检查是否可与 Application Load Balancer 和 Network Load Balancer 配合使用？ 如果与一个实例关联的任何目标组的运行状况不佳，该实例是否会被标记为运行状况不佳？**

是，Amazon EC2 Auto Scaling 可与 Application Load Balancer 和 Network Load Balancer 配合使用，包括它们的运行状况检查功能。

**问：是否可以使用 Amazon EC2 Auto Scaling 仅添加卷而不添加实例？**

添加新实例时会附加卷。Amazon EC2 Auto Scaling 不会在现有卷接近容量限制时自动添加卷。您可以使用 EC2 API 为现有实例添加卷。

**问：术语“有状态实例”指的是什么？**

当提到有状态实例时，我们指的是包含数据且数据仅位于此实例上的实例。通常，终止有状态实例意味着实例上的数据（或状态信息）丢失。您可能需要考虑使用生命周期挂钩在有状态实例终止之前复制数据，或者启用实例保护功能以防止 Amazon EC2 Auto Scaling 终止实例。
## 替代受损的实例（Replacing Impaired Instances）


## 安全
## 成本优化
**问：我是否可以在 Auto Scaling 组中指定不同大小（CPU 核心、内存）的实例？**

可以。您可以指定区域中可用的任何实例类型。此外，您还可以为每个实例类型指定一个可选权重，该权重定义每个实例贡献给应用程序性能的容量单位。

**问：如果我想使用的实例类型在可用区中不可用，该怎么办？**

如果指定的实例类型在某个可用区中都不可用，Auto Scaling 会重新定位与 Auto Scaling 组关联的其他可用区中的启动。Auto Scaling 将始终致力于让您的计算在多个可用区之间保持平衡，如果所有实例类型在某个可用区中都不可用，它将重新定位。
## 价格
问：使用 Amazon EC2 Auto Scaling 的成本如何？

Amazon EC2 Auto Scaling 为 EC2 实例的编排管理不带有额外的费用。Amazon EC2 Auto Scaling 动态伸缩的能力是由 Amazon CloudWatch 赋予的，也不带有额外费用。Amazon EC2 和 Amazon CloudWatch 服务的费用已经包含这个，它们是单独计费的。

## Reference
- [Amazon EC2 Auto Scaling FAQs](https://aws.amazon.com/ec2/autoscaling/faqs/#:~:text=Yes.,a%20single%20Auto%20Scaling%20Group.)