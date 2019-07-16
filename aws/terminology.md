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

  Amazon S3 将数据存储为存储桶中的对象。对象由文件和描述该文件的任何可选元数据组成。要将对象存储到 Amazon S3 中，请将要存储的文件上传到存储桶中。上传文件时，可以设置对对象以及任何元数据的权限。存储桶是存储对象的容器。您可以有一个或多个存储桶。对于每个存储桶，您都可以控制对它的访问权限 (哪些用户可以在存储桶中创建、删除和列出对象) 、查看存储桶及其对象的访问日志以及选择 Amazon S3 存储存储桶及其内容的地理区域。
  + 注册 Amazon S3 后，您就可以开始使用 AWS 管理控制台 创建存储桶。Amazon S3 中的每个对象都存储在存储桶中。必须先创建一个存储桶，然后才能在 Amazon S3 中存储数据。
  + 您已经创建了存储桶，现在可以为其添加对象。对象可以是任何类型的文件：文本文件、图片、视频等等。
  + 现在，您已将对象添加到存储桶，您可以查看有关对象的信息并将对象下载到本地计算机上。
  + 目前，您已向存储桶添加一个对象并已下载该对象。现在，我们创建文件夹，并通过复制和粘贴对象将其移动到此文件夹中。
  + 如果您完成此指南后不再需要存储您已上传并为其创建副本的对象，则应删除该对象以免进一步产生费用。您可以逐个删除对象。或者，您可以清空存储桶，这将删除存储桶中的所有对象而不删除存储桶。您也可以删除存储桶及其包含的所有对象。不过，如果您希望继续使用相同的存储桶名称，请不要删除该存储桶。我们建议您，清空并保留存储桶。删除存储桶后，该名称可供重用，但是出于各种原因，您可能无法重新使用该名称。
 
- **8. Amazon CloudFront**
    
  Amazon CloudFront 是一个 Web 服务，它加快将静态和动态 Web 内容（如 .html、.css、.js 和图像文件）分发到用户的速度。CloudFront 通过全球数据中心网络传输内容，这些数据中心称为边缘站点。当用户请求您用 CloudFront 提供的内容时，用户被路由到提供最低延迟 (时间延迟) 的边缘站点，从而以尽可能最佳的性能传送内容。
  + 如果该内容已经在延迟最短的边缘站点上，CloudFront 将直接提供它。
  + 如果内容没有位于边缘站点中，CloudFront 从定义的源中检索内容，例如，指定为内容最终版本来源的 Amazon S3 存储桶、MediaPackage 通道或 HTTP 服务器（如 Web 服务器）。
  
  例如，假设您要从传统的 Web 服务器中提供图像，而不是从 CloudFront 中提供图像。例如，您可能会使用 URL http://example.com/sunsetphoto.png 提供图像 sunsetphoto.png。

  您的用户可以轻松导航到该 URL 并查看图像。但他们可能不知道其请求从一个网络路由到另一个网络（通过构成 Internet 的相互连接的复杂网络集合），直到找到图像。

  CloudFront 通过 AWS 主干网络将每个用户请求传送到以最佳方式提供内容的边缘站点，从而加快分发内容的速度。通常，这是向查看器提供传输最快的 CloudFront 边缘服务器。使用 AWS 网络可大大降低用户的请求必须经由的网络数量，从而提高性能。用户遇到的延迟（加载文件的第一个字节所花的时间）更短，数据传输速率更高。

  您还会获得更高的可靠性和可用性，因为您的文件（也称为对象）的副本现在存储（或缓存）在全球各地的多个边缘站点上。

  **如何设置 CloudFront 以传输内容**
  您可以创建 CloudFront 分配以指示 CloudFront 您希望从何处传输内容，并了解如何跟踪和管理内容传输的详细信息。然后，在有人要查看或使用内容时，CloudFront 使用靠近您的查看器的计算机（边缘服务器）快速传输内容。

  ![How You Configure CloudFront](https://github.com/wbb1975/blogs/blob/master/aws/images/how-you-configure-cf.png)
  
  如何配置 CloudFront 以便传输您的内容：
  1. 您指定源服务器（如 Amazon S3 存储桶或您自己的 HTTP 服务器），CloudFront 从该服务器中获取您的文件，然后从全世界的 CloudFront 边缘站点中分配这些文件。
  2. 您将您的文件上传到源服务器。您的文件也称为对象，通常包括网页、图像和媒体文件，但可以是可通过 HTTP 或支持的 Adobe RTMP（Adobe Flash Media Server 使用的协议）版本提供的任何内容。
  3. 您创建一个 CloudFront 分配（create a CloudFront distribution），在用户通过您的网站或应用程序请求文件时，这会指示 CloudFront 从哪些源服务器中获取您的文件。同时，您还需指定一些详细信息，如您是否希望 CloudFront 记录所有请求以及您是否希望此项分配创建后便立即启用。
  4. CloudFront 为新分配指定一个域名（CloudFront assigns a domain name to your new distribution），您可以在 CloudFront 控制台中查看该域名，或者返回该域名以响应编程请求（如 API 请求）。
  5. CloudFront 将您的分配的配置（而不是您的内容）发送到它的所有边缘站点，边缘站点是位于地理位置分散的数据中心（CloudFront 在其中缓存您的对象的副本）的服务器集合。

- **9. Amazon Elastic Block Store (Amazon EBS)**
  
  Amazon Elastic Block Store (Amazon EBS) 提供了块级存储卷以用于 EC2 实例。EBS 卷是高度可用、可靠的存储卷，您可以将其附加到同一可用区域中任何正在运行的实例。附加到 EC2 实例的 EBS 卷公开为独立于实例生命周期存在的存储卷。使用 Amazon EBS，您可以按实际用量付费。

  如果数据必须能够快速访问且需要长期保存，建议使用 Amazon EBS。EBS 卷特别适合用作文件系统和数据库的主存储，还适用于任何需要细粒度更新及访问原始的、未格式化的块级存储的应用程序。Amazon EBS 非常适合依赖随机读写操作的数据库式应用程序以及执行长期持续读写操作的吞吐量密集型应用程序。

  为简化数据加密，您可以将 EBS 卷作为加密卷启动。Amazon EBS 加密 提供了用于 EBS 卷的简单加密解决方案，您无需构建、管理和保护自己的密钥管理基础设施。创建加密 EBS 卷并将它连接到支持的实例类型时，该卷上静态存储的数据、磁盘 I/O 和通过该卷创建的快照都会进行加密。加密在托管 EC2 实例的服务器上进行，对从 EC2 实例传输到 EBS 存储的数据进行加密。有关更多信息，请参阅 [Amazon EBS Encryption](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSEncryption.html)。

  Amazon EBS 加密在创建加密卷以及通过加密卷创建任何快照时，使用 AWS Key Management Service (AWS KMS) 主密钥。首次在区域中创建加密的 EBS 卷时，将自动为您创建一个默认主密钥。此密钥将用于 Amazon EBS 加密，除非您选择采用 AWS Key Management Service 单独创建的客户主密钥 (CMK)。创建您自己的 CMK 可以让您在定义访问控制时获得更高的灵活性，包括创建、轮换、禁用和审核特定于各个应用程序和用户的加密密钥的能力。有关更多信息，请参阅 [AWS Key Management Service Developer Guide](https://docs.aws.amazon.com/kms/latest/developerguide/)。

  您可以将多个卷附加到同一实例，但是不能超过 AWS 账户指定的限额。您的账户对您可以使用的 EBS 卷数量和总存储量有相应的限制。如要了解有关限制的更多信息，以及如何申请提高限额，请参阅[请求提高 Amazon EBS 卷限制](https://console.aws.amazon.com/support/home#/case/create?issueType=service-limit-increase&limitType=service-code-ebs)。

  Amazon EBS 的功能：
  + 您可以创建大小高达 16TiB 的 EBS 通用型 SSD (gp2)、预配置 IOPS SSD (io1)、吞吐优化 HDD (st1) 和 Cold HDD (sc1) 卷。您可以将这些卷作为设备装载在您的 Amazon EC2 实例上。您可以在同一实例上安装多个卷，但每个卷一次只能连接到一个实例。您可以动态更改附加到实例的卷的配置。有关更多信息，请参阅 [创建 Amazon EBS 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-creating-volume.html)。
  + 通过 通用型 SSD (gp2) 卷，基本性能可以达到 3 IOPS/GiB，能突增至 3000 IOPS 并保持一段较长的时间。Gp2 卷适用于多种使用案例，例如引导卷、中小型数据库以及开发和测试环境。Gp2 卷最高可支持 16,000 IOPS 和 250 MiB/s 的吞吐量。有关更多信息，请参阅 [通用型 SSD (gp2) 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_gp2)。
  + 通过 预配置 IOPS SSD (io1) 卷，您可以预配置特定级别的 I/O 性能。Io1 卷最高可支持 64,000 IOPS 和 1,000 MB/s 的吞吐量。因此，您可预见性地将每个 EC2 实例扩展到数万 IOPS。有关更多信息，请参阅 [预配置 IOPS SSD (io1) 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_piops)。
  + 吞吐优化 HDD (st1) 卷提供低成本的磁性存储，该存储以吞吐量而不是 IOPS 定义性能。这种卷的吞吐量高达 500MiB/s，非常适合大型顺序工作负载，例如 Amazon EMR、ETL、数据仓库和日志处理。有关更多信息，请参阅[吞吐优化 HDD (st1) 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_st1)。
  + Cold HDD (sc1) 卷提供低成本的磁性存储，该存储以吞吐量而不是 IOPS 定义性能。sc1 的吞吐量高达 250MiB/s，是大型顺序冷数据工作负载的理想选择。如果您需要频繁访问数据并且希望节约成本，sc1 提供价格低廉的数据块存储。有关更多信息，请参阅[Cold HDD (sc1) 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_sc1)。
  + EBS 卷的行为类似于原始、未格式化的块储存设备。您可基于这些卷来创建文件系统，或以任何其他块储存设备 (如硬盘) 使用方式使用这些卷。有关创建文件系统和装载卷的更多信息，请参阅使 [Amazon EBS 卷可在 Linux 上使用](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-using-volumes.html)。
  + 您可以使用加密 EBS 卷为监管/审核的数据和应用程序实现各种静态数据加密要求。有关更多信息，请参阅 [Amazon EBS Encryption](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSEncryption.html)。
  + 您可以创建持久保存到 Amazon S3 的 EBS 卷的时间点快照。快照可为数据提供保护以获得长期持久性，可用作新 EBS 卷的起点。您随心所欲地用相同快照对任意多的卷进行实例化。可以跨多个 AWS 区域复制这些快照。有关更多信息，请参阅[Amazon EBS 快照](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSSnapshots.html)。
  + EBS 卷在特定可用区中创建，随后可以附加到同一可用区内的任何实例。若要在可用区外部提供某个卷，您可以创建一个快照并将该快照还原到该区域中任意位置处的新卷。您可以将快照复制到其他区域，再将它们还原到该区域中的新卷，从而更轻松地利用多个 AWS 区域来实现地理扩展、数据中心迁移和灾难恢复。有关更多信息，请参阅[创建 Amazon EBS 快照](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-creating-snapshot.html)、[从快照还原 Amazon EBS 卷](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-restoring-volume.html)和[复制 Amazon EBS 快照](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ebs-copy-snapshot.html)。
  + 带宽、吞吐量、延迟和平均队列长度等性能指标是通过 AWS 管理控制台提供的。通过 Amazon CloudWatch 提供的这些指标，您可以监视卷的性能，确保为应用程序提供足够性能，又不会为不需要的资源付费。有关更多信息，请参阅[Linux 实例上的 Amazon EBS 卷性能](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/EBSPerformance.html)。
  
- **10. Amazon Simple Notification Service(SNS)**

  Amazon Simple Notification Service (Amazon SNS) 是一项 Web 服务，用于协调和管理向订阅终端节点或客户端交付或发送消息的过程。在 Amazon SNS 中，有两类客户端—发布者和订阅者—也称为创建者和用户。发布者通过创建消息并将消息发送至主题与订阅者进行异步交流，主题是一个逻辑访问点和通信渠道。订阅者（即 Web 服务器、电子邮件地址、Amazon SQS 队列、AWS Lambda 函数）在其订阅主题后通过受支持协议（即 Amazon SQS、HTTP/S、电子邮件、SMS、Lambda）之一使用或接收消息或通知。
 
  ![How SNS Works](https://github.com/wbb1975/blogs/blob/master/aws/sns-how-works.png)

  使用 Amazon SNS 时，您（作为拥有者）可通过定义确定哪些发布者和订阅者能就主题进行交流的策略来创建主题和控制对主题的访问权。发布者会发送消息至他们创建的主题或他们有权发布的主题。除了在每个消息中包括特定目标地址之外，发布者还要将消息发送至主题。Amazon SNS 将主题与订阅了该主题的用户列表对应，并将消息发送给这些订阅者中的每一个。每个主题都有一个独特的名称，用户为发布者识别 Amazon SNS 终端节点，从而发布消息和订阅者以注册通知。订阅者接收所有发布至他们所订阅主题的消息，并且一个主题的所有订阅者收到的消息都相同。

- **11. AWS Identity and Access Management (IAM)**
  
  AWS Identity and Access Management (IAM) 是一种 Web 服务，可以帮助您安全地控制对 AWS 资源的访问。您可以使用 IAM 控制对哪个用户进行身份验证 (登录) 和授权 (具有权限) 以使用资源。

  当您首次创建 AWS 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 AWS 账户 根用户，可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。强烈建议您不使用 根用户 执行日常任务，即使是管理任务。请遵守[仅将根用户用于创建首个 IAM 用户的最佳实践](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#create-iam-users)。然后请妥善保存 根用户 凭证，仅用它们执行少数账户和服务管理任务。

  IAM 功能：
  + 对您 AWS 账户的共享访问权限：您可以向其他人员授予管理和使用您 AWS 账户中的资源的权限，而不必共享您的密码或访问密钥。
  + 精细权限：您可以针对不同资源向不同人员授予不同权限。例如，您可以允许某些用户完全访问 Amazon Elastic Compute Cloud (Amazon EC2)、Amazon Simple Storage Service (Amazon S3)、Amazon DynamoDB、Amazon Redshift 和其他 AWS 服务。对于另一些用户，您可以允许仅针对某些 S3 存储桶的只读访问权限，或是仅管理某些 EC2 实例的权限，或是访问您的账单信息但无法访问任何其他内容的权限。
  + 在 Amazon EC2 上运行的应用程序针对 AWS 资源的安全访问权限：您可以使用 IAM 功能安全地为 EC2 实例上运行的应用程序提供凭证。这些凭证为您的应用程序提供权限以访问其他 AWS 资源。示例包括 S3 存储桶和 DynamoDB 表。
  + 多重验证 (MFA)：您可以向您的账户和各个用户添加双重身份验证以实现更高安全性。借助 MFA，您或您的用户不仅必须提供使用账户所需的密码或访问密钥，还必须提供来自经过特殊配置的设备的代码。
  + 联合身份：您可以允许已在其他位置（例如，在您的企业网络中或通过 Internet 身份提供商）获得密码的用户获取对您 AWS 账户的临时访问权限。
  + 实现保证的身份信息：如果您使用 [AWS CloudTrail](https://aws.amazon.com/cloudtrail/)，则会收到日志记录，其中包括有关对您账户中的资源进行请求的人员的信息。这些信息基于 IAM 身份。
  + PCI DSS 合规性：IAM 支持由商家或服务提供商处理、存储和传输信用卡数据，而且已经验证符合支付卡行业 (PCI) 数据安全标准 (DSS)。有关 PCI DSS 的更多信息，包括如何请求 AWS PCI Compliance Package 的副本，请参阅 [PCI DSS 第 1 级](https://aws.amazon.com/compliance/pci-dss-level-1-faqs/)。
  + 已与很多 AWS 服务集成：有关使用 IAM 的 AWS 服务的列表，请参阅[使用 IAM 的 AWS 服务](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。
  + 最终一致性：与许多其他 AWS 服务一样，IAM 具有[最终一致性](https://wikipedia.org/wiki/Eventual_consistency)。IAM 通过在 Amazon 的全球数据中心中的多个服务器之间复制数据来实现高可用性。如果成功请求更改某些数据，则更改会提交并安全存储。不过，更改必须跨 IAM 复制，这需要时间。此类更改包括创建或更新用户、组、角色或策略。在应用程序的关键、高可用性代码路径中，我们不建议进行此类 IAM 更改。而应在不常运行的、单独的初始化或设置例程中进行 IAM 更改。另外，在生产工作流程依赖这些更改之前，请务必验证更改已传播。有关更多信息，请参阅 [我所做的更改可能不会立即可见](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/troubleshoot_general.html#troubleshoot_general_eventual-consistency)。
  + 免费使用：AWS Identity and Access Management (IAM) 和 AWS Security Token Service (AWS STS) 是为您的 AWS 账户提供的功能，不另行收费。仅当您使用 IAM 用户或 AWS STS 临时安全凭证访问其他 AWS 服务时，才会向您收取费用。有关其他 AWS 产品的定价信息，请参阅 [Amazon Web Services 定价页面](https://aws.amazon.com/pricing/)。
  
  访问 IAM：
  + AWS 管理控制台：控制台是用于管理 IAM 和 AWS 资源的基于浏览器的界面。有关通过控制台访问 IAM 的更多信息，请参阅 [IAM 控制台和登录页面](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/console.html)。有关指导您使用控制台的教程，请参阅[创建您的第一个 IAM 管理员用户和组](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。
  + AWS 命令行工具：您可以使用 AWS 命令行工具，在系统的命令行中发出命令以执行 IAM 和 AWS 任务。与控制台相比，使用命令行更快、更方便。如果要构建执行 AWS 任务的脚本，命令行工具也会十分有用。
  
   AWS 提供两组命令行工具：[AWS Command Line Interface (AWS CLI)](https://aws.amazon.com/cli/) 和 [适用于 Windows PowerShell 的 AWS 工具](https://aws.amazon.com/powershell/)。有关安装和使用 AWS CLI 的更多信息，请参阅 [AWS Command Line Interface 用户指南](https://docs.aws.amazon.com/cli/latest/userguide/)。有关安装和使用Windows PowerShell 工具的更多信息，请参阅[适用于 Windows PowerShell 的 AWS 工具 用户指南](https://docs.aws.amazon.com/powershell/latest/userguide/)。
  + AWS 开发工具包：AWS 提供的 SDK (开发工具包) 包含各种编程语言和平台 (Java、Python、Ruby、.NET、iOS、Android 等) 的库和示例代码。开发工具包提供便捷的方式来创建对 IAM 和 AWS 的编程访问。例如，开发工具包执行以下类似任务：加密签署请求、管理错误以及自动重试请求。有关 AWS 开发工具包的信息（包括如何下载及安装），请参阅[适用于 Amazon Web Services 的工具](https://aws.amazon.com/tools/)页面。
  + IAM HTTPS API：您可以使用 IAM HTTPS API（可让您直接向服务发布 HTTPS 请求）以编程方式访问 IAM 和 AWS。使用 HTTPS API 时，必须添加代码，才能使用您的凭证对请求进行数字化签名。有关更多信息，请参见[通过提出 HTTP 查询请求来调用 API](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/programming.html)和 [IAM API 参考](https://docs.aws.amazon.com/IAM/latest/APIReference/)。

## 参看
- [AWS文档](https://docs.aws.amazon.com/)
