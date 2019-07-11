# AWS常见术语
- **1. 区域和可用区（Regions and Availability Zones）**

  Amazon EC2 托管在全球多个位置。这些位置由地区和可用区域构成。每个区域 都是一个单独的地理区域。每个区域均有多个相互隔离的位置，称为可用区。Amazon EC2 让您可以在多个位置放置资源（例如实例和数据）。除非您特意这样做，否则资源不会跨区域复制。

  Amazon 运行着具有高可用性的先进数据中心。数据中心有时会发生影响托管于同一位置的所有实例的可用性的故障，虽然这种故障极少发生。如果您将所有实例都托管在受此类故障影响的同一个位置，则您的所有实例都将不可用。

  每一个区域都是完全独立的。每个可用区都是独立的，但区域内的可用区通过低延迟链接相连。下图阐明了区域和可用区之间的关系。

  ![区域和可用区](https://github.com/wbb1975/blogs/blob/master/aws/images/aws_regions.png)

  Amazon EC2 资源要么具有全球性，与某个区域相关联，要么与某个可用区相关联。有关更多信息，请参阅[资源位置](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/resources.html)。
- **2. Amazon EC2**
  
  Amazon Elastic Compute Cloud (Amazon EC2) 在 Amazon Web Services (AWS) 云中提供可扩展的计算容量。使用 Amazon EC2 可避免前期的硬件投入，因此您能够快速开发和部署应用程序。通过使用 Amazon EC2，您可以根据自身需要启动任意数量的虚拟服务器、配置安全和网络以及管理存储。Amazon EC2 允许您根据需要进行缩放以应对需求变化或流行高峰，降低流量预测需求。

  Amazon EC2 提供以下功能：
  + 虚拟计算环境，也称为实例
  + 实例的预配置模板，也称为 Amazon 系统映像 (AMI)，其中包含您的服务器需要的程序包（包括操作系统和其他软件）。
  + 实例 CPU、内存、存储和网络容量的多种配置，也称为实例类型
  + 使用密钥对的实例的安全登录信息（AWS 存储公有密钥，您在安全位置存储私有密钥）
  + 临时数据（停止或终止实例时会删除这些数据）的存储卷，也称为实例存储卷
  + 使用 Amazon Elastic Block Store (Amazon EBS) 的数据的持久性存储卷，也称为 Amazon EBS 卷。
  + 用于存储资源的多个物理位置，例如实例和 Amazon EBS 卷，也称为区域 和可用区
  + 防火墙，让您可以指定协议、端口，以及能够使用安全组到达您的实例的源 IP 范围
  + 用于动态云计算的静态 IPv4 地址，称为弹性 IP 地址
  + 元数据，也称为标签，您可以创建元数据并分配给您的 Amazon EC2 资源
  + 您可以创建的虚拟网络，这些网络与其余 AWS 云在逻辑上隔离，并且您可以选择连接到您自己的网络，也称为 Virtual Private Cloud (VPC)
- **3. Amazon Elastic Container Service**
  
  Amazon Elastic Container Service (Amazon ECS) 是一项高度可扩展的快速容器管理服务，它可轻松运行、停止和管理集群上的 Docker 容器。您可以通过使用 Fargate 启动类型启动服务或任务，将集群托管在由 Amazon ECS 管理的无服务器基础设施上。若要进行更多控制，您可以在使用 EC2 启动类型进行管理的 Amazon Elastic Compute Cloud (Amazon EC2) 实例集群上托管您的任务。有关启动类型的更多信息，请参阅 [Amazon ECS 启动类型](https://docs.aws.amazon.com/zh_cn/AmazonECS/latest/developerguide/launch_types.html)。

  Amazon ECS 启动类型决定了托管您的任务和服务的基础设施类型。
  + Fargate 启动类型
     Fargate 启动类型允许您运行容器化的应用程序，而无需预置和管理后台基础设施。只需注册您的任务定义，Fargate 就会为您启动容器。下图显示了一般架构：

     ![Fargate 启动类型](https://github.com/wbb1975/blogs/blob/master/aws/images/overview-fargate.png)
  + EC2 启动类型
     EC2 启动类型允许您在管理的 Amazon EC2 实例集群上运行容器化的应用程序。下图显示了一般架构：
     
     ![EC2 启动类型](https://github.com/wbb1975/blogs/blob/master/aws/images/overview-standard.png)
- **4. AWS Lambda**
  
  AWS Lambda 是一项计算服务，可使您无需预配置或管理服务器即可运行代码。AWS Lambda 只在需要时执行您的代码并自动缩放，从每天几个请求到每秒数千个请求。您只需按消耗的计算时间付费 – 代码未运行时不产生费用。借助 AWS Lambda，您几乎可以为任何类型的应用程序或后端服务运行代码，并且不必进行任何管理。AWS Lambda 在可用性高的计算基础设施上运行您的代码，执行计算资源的所有管理工作，其中包括服务器和操作系统维护、容量预置和自动扩展、代码监控和记录。您只需要以 AWS Lambda 支持的一种语言提供您的代码。

  您可以使用 AWS Lambda 运行代码以响应事件，例如更改 Amazon S3 存储桶或 Amazon DynamoDB 表中的数据；以及使用 Amazon API Gateway 运行代码以响应 HTTP 请求；或者使用通过 AWS SDK 完成的 API 调用来调用您的代码。借助这些功能，您可以使用 Lambda 轻松地为 Amazon S3 和 Amazon DynamoDB 等 AWS 服务构建数据处理触发程序，处理 Kinesis 中存储的流数据，或创建您自己的按 AWS 规模、性能和安全性运行的后端。

  您也可以构建由事件触发的函数组成的无服务器应用程序，并使用 CodePipeline 和 AWS CodeBuild 自动部署这些应用程序。有关更多信息，请参阅 [AWS Lambda 应用程序](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/deploying-lambda-apps.html)。

  有关 AWS Lambda 执行环境的更多信息，请参阅 [AWS Lambda 运行时](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/lambda-runtimes.html)。有关 AWS Lambda 如何确定执行您的代码所需的计算资源的信息，请参阅[AWS Lambda 函数配置](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/resource-model.html)。
- **5. Amazon Simple Queue Service**
  
  Amazon Simple Queue Service (Amazon SQS) 提供安全、持久且可用的托管队列，可让您集成和分离分布式软件系统和组件。Amazon SQS 提供常见的构造，例如[死信队列](https://docs.aws.amazon.com/zh_cn/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html)和[成本分配标签](https://docs.aws.amazon.com/zh_cn/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-queue-tags.html)。它提供了一个通用 Web 服务 API，并且可通过 AWS 开发工具包支持的任何编程语言访问。

  Amazon SQS 支持[标准队列](https://docs.aws.amazon.com/zh_cn/AWSSimpleQueueService/latest/SQSDeveloperGuide/standard-queues.html)和 [FIFO 队列](https://docs.aws.amazon.com/zh_cn/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html)。有关更多信息，请参阅 我需要哪种类型的队列？

  我需要哪种类型的队列？
  
  标准队列|FIFO 队列
  --|--
  无限吞吐量 – 标准 队列每个 操作支持接近无限的每秒事务数 (TPS)|高吞吐量 – 默认情况下，借助批处理，FIFO 队列每秒支持多达 3000 条消息。要请求提高上限，请提交支持请求。 在不使用批处理的情况下，FIFO 队列的每个操作（SendMessage、ReceiveMessage 或 DeleteMessage）每秒最多支持 300 条消息
  至少传送一次 – 消息至少传送一次，但偶尔会传送消息的多个副本|仅传输一次处理 – 消息传递一次并在使用者处理并删除它之前保持可用。不会将重复项引入到队列中
  最大努力排序 – 消息偶尔可能按不同于其发送时的顺序传递|先进先出传递 – 严格保持消息的发送和接收顺序。
  !![Standard](https://github.com/wbb1975/blogs/blob/master/aws/images/sqs-what-is-sqs-standard-queue-diagram.png)|![FIFO](https://github.com/wbb1975/blogs/blob/master/aws/images/sqs-what-is-sqs-fifo-queue-diagram.png)
  当吞吐量很重要时，请在应用程序之间发送数据|当事件的顺序重要时，请在应用程序之间发送数据
- **6. 用于 Redis 的 Amazon ElastiCache**
  
  ElastiCache 是一种 Web 服务，通过该服务可以在云中轻松设置、管理和扩展分布式内存数据存储或内存缓存环境。它可以提供高性能、可扩展且符合成本效益的缓存解决方案，同时消除与部署和管理分布式缓存环境关联的复杂性。现有的使用 Redis 的应用程序可以几乎不进行任何修改就使用 ElastiCache。您的应用程序只需要有关您已部署的 ElastiCache 节点的主机名和端口号的信息。

  ElastiCache for Redis 具有多个可提高关键生产部署的可靠性的功能：
  + 缓存节点故障的自动检测和恢复
  + 在支持复制的 Redis 集群中，将失败的主集群自动故障转移到只读副本的多可用区。
  + Redis (已启用集群模式)支持将数据划分到最多 90 个分片。
  + 从 Redis 版本 3.2.6 开始，所有后续支持版本均支持使用身份验证进行传输中加密和静态加密，这样您就可以构建符合 HIPAA 要求的应用程序。
  + 在可用区中灵活放置节点和集群，以提高容错能力。
  + 与其他 AWS 服务（如 Amazon EC2、Amazon CloudWatch、AWS CloudTrail 和 Amazon SNS）集成以提供安全、
  + 高性能的托管内存缓存解决方案。

  ElastiCache for Redis 术语
  + 缓存集群或节点与节点（Cache Cluster or Node vs. Node）
    在没有副本节点时，节点与缓存集群之间存在一对一的关系，因而 ElastiCache 控制台通常互换使用这两个术语。以后，控制台将统一使用术语节点。唯一的例外是 Create Cluster (创建集群) 按钮，该按钮用于启动一个流程来创建包含或不包含副本节点的集群。
  + 集群与复制组（Cluster vs. Replication Group）
    控制台现在为所有 ElastiCache for Redis 集群使用术语集群。控制台在以下所有情况中使用术语“集群”：
    - 集群是单节点 Redis 集群。
    - 集群是 Redis (已禁用集群模式)集群并支持单分片（在 API 和 CLI 中称为节点组）中的复制。
    - 集群是 Redis (已启用集群模式)集群并支持 1–90 个分片中的复制。
    
   下图从控制台的角度阐明了各种 ElastiCache for Redis 集群拓扑。

   ![Console View: topologies of ElastiCache for Redis clusters](https://github.com/wbb1975/blogs/blob/master/aws/images/ElastiCache-Clusters-ConsoleView.png)

    ElastiCache API 和 AWS CLI 操作将继续区分单节点 ElastiCache for Redis 集群与多节点复制组。下图从 ElastiCache API 和 AWS CLI 的角度阐明了各种 ElastiCache for Redis 拓扑。
    
    ![API View: topologies of ElastiCache for Redis clusters](https://github.com/wbb1975/blogs/blob/master/aws/images/ElastiCache-Clusters-APIView.png)
- **7. Amazon Simple Storage Service (S3)**
  
  Amazon Simple Storage Service (Amazon S3) 是一项面向 Internet 的存储服务。您可以通过 Amazon S3 随时在 Web 上的任何位置存储和检索的任意大小的数据。您可以通过 AWS 管理控制台这一简单直观的 Web 界面来完成这些任务。
- **8. Amazon Elastic Block Store (Amazon EBS)**
- **9. **
- **10. **


## 参看
- [AWS文档](https://docs.aws.amazon.com/)
