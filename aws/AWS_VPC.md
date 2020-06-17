# AWS之VPC、Subnet与Security Groups
## 1. AWS之VPC、Subnet与CIDR
### 1.0 什么是CIDR?
CIDR是英文Classless Inter-Domain Routing的缩写，中文是无类别域间路由，是一个在Internet上创建附加地址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。CIDR将路由集中起来，使一个IP地址代表主要骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。

为什么要选择CIDR，CIDR？
- CIDR可以减轻Internet路由器的负担
- CIDR可以提高IP地址的利用率

再来介绍一下CIDR是如何实现以上两个功能的。CIDR的一个最主要的动作就是路由聚合（route aggregation），通过该动作可以实现如上两个功能，接下来举例介绍CIDR是如何通过路由聚合实现这两个功能的。
#### 1.1 CIDR功能之减轻Internet路由器的负担
假设我们有如下4个C类IP地址
- 192.168.0.8  / 255.255.255.0 /11000000.10101000.00000000.00000000
- 192.168.1.9  / 255.255.255.0 /11000000.10101000.00000001.00000000
- 192.168.2.10 / 255.255.255.0 /11000000.10101000.00000010.00000000
- 192.168.3.11 / 255.255.255.0 /11000000.10101000.00000011.00000000
可以看到以上4个IP地址的网络地址都不尽相同，所以在的路由表上面需要配置对应的4条路由到达相应的网络。

接下来做路由聚合，可以看到以上4个IP地址的二进制地址的前22位都是相同的，所以可以聚合成一个网络地址，这个网络地址的CIDR表达格式为192.164.0.0/22，该地址的解释为，这个网络的地址为192.164.0.0，且前22位为网络地址，后10位为主机地址。

因此现在可以将之前的4个C类地址配到这个网络下面，如此一来在路由器上面只需要配置一条路由到达192.164.0.0/22网络就可以了，从而达到减少路由器负担的目的。
#### 1.2 CIDR功能之提高IP地址的利用率
假设我们建立一个局域网，这个局域网初步规划将会有500个主机，因此需要500个IP地址，500个IP地址就需要这个地址是个B类地址，这个B类地址格式如下
```
192.168.0.0 / 255.255.0.0 /11000000.10101000.00000000.00000000
```
这个B类地址拥有256*256=65536个主机地址，但是只需要500个主机地址，因此造成了IP地址浪费，接下来来做路由聚合，只需要500个主机地址，因此需要后9位为主机地址。后9位为主机地址意味着将
会有512个主机地址，如此一来地址浪费将大大缩小，地址的利用率将大幅提高，聚合后的网络地址如下：
```
192.168.254.0/23 （192.168.254.0 / 255.255.254.0 /11000000.10101000.11111110.00000000）
```
### 2. 在AWS的VPC和Subnet上如何应用CIDR？
在AWS上我们需要先创建一个VPC（Virtual Private Cloud）虚拟私有云，我们需要为这个云指定一个CIDR地址，然后向这个云中加入subnet并为每个subnet指定CIDR地址，最后我们向subnet添加主机，AWS
会根据subnet的CIDR所拥有的主机地址自动分配主机地址给主机，接下来举例说明该过程：
1. 先创建一个VPC，该VPC的CIDR地址如下：
   ```default-vpc , 172.31.0.0/16 ,10101100.00011111.00000000.00000000```
2. 接下来可以向这个VPC里面添加如下subnet
   ```
   default-subnet , 172.31.0.0/20  , 10101100.00011111.00000000.00000000
   public-subnet  , 172.31.24.0/21 , 10101100.00011111.00011000.00000000
   private-subnet , 172.31.16.0/21  ,10101100.00011111.00010000.00000000
   ```
   从以上的二进制地址可以看出来所有subnet和VPC的网络地址的交集为10101100.00011111，即前16位相同 ,这正好为VPC的网络地址，因此可以顺利的将这3个subnet加入到VPC
3. 接下来可以尝试着将如下一个subnet加入到VPC看是否能够成功
   ```test-subnet , 172.31.0.0/21 ,10101100.00011111.00000000.00000000```
   这个地址是不可以加入到VPC的，其原因为test-subnet的21位网络地址与default-subnet的20位网络地址是重叠的，因此加入失败。

**由此可以总结出AWS上配置VPC和subnet的规则即：所有subnet的网络是指必须是VPC网络地址的子集且不能与其他Subnet的网络地址重叠，这样一来就可以为VPC指定一条路由就可以到达VPC里面的所有Subnet**。
## 2. AWS VPC
### 2.1 VPC 概述
1. VPC （Virtual Private cloud）虚拟私有云，是AWS提供的在网络层面对资源进行分组的技术，一个VPC可以看作是一个独立的集合，默认情况VPC与VPC之间不互通，是逻辑上的隔离。
2. 默认一个region下可以创建5个VPC，在创建VPC的时候需要指定网络CIDR，范围：/16 - /28。
3. 创建完VPC后，会默认创建一个main route table，其它子网都默认使用该main route table，也可以指定用户自定义的route table。
4. 一个VPC包含以下组件：
   - Subnets
   - Route tables
   - Dynamic Host Configuration Protocol （DHCP） option sets
   - Security Group
   - Network Access Control List（ACLs）
5. 也可以包含以下可选组件
   - Internet Gateways（IGW）
   - Elastic IP（EIP）address
   - Elastic Network Interfaces （ENIs）
   - Endpoints
   - Peering
   - Network Address Translation （NATs）instances and NAT gateways
### 2.2 Subnet
1. 一个VPC可以包含多个subnet，一个subnet对应于一个AZ
2. 子网CIDR确定后，前4个IP和最后1个IP不可用，AWS内部使用，例如：/28有16个IP，去掉5个后，还有11个供我们使用
3. AZ是物理上的隔离，由于VPC可以跨多个AZ，因此VPC是逻辑上的划分
4. VPC中的subnet永远是互通的，因为任何一个路由表都有包含一个本地路由，且不可删除
5. 在创建subnet的时候可以指定默认是否为每个新的instance分配public IP
6. Subnet有三种
   - Public subnet，在路由表中有一个指向IGW的路由
   - Private subnet，在路由表中没有指向IGW的路由
   - VPN subnet，面向VPN连接，在路由表中有指向VPG的路由
### 2.3 Route Tables
1. 路由表，用于确定子网中路由的去向
2. 一个子网只能且必须对应一个route table，一个route table可对应多个子网
### 2.4 Internat Gateways
1. 一个VPC只能有一个IGW，用于连接internet
2. 让instance连接到internet的步骤：新建subnet并关联一个新的route table，为route table添加一个指向IGW的rule，为instance分配public IP
### 2.5 Dynamic Host Configuration Protocol Option Sets
1. 指定如何为instance分配IP/Hostname等，默认AWS控制，也可以自定义DNS server
2. 可以配置的选项有
   - Domain name server
   - Domain name
   - NTP server
   - NetBios name server
   - NetBios node type
### 2.6 Elastic IP Address
1. 默认Public subnet下的instance会得到一个动态的public IP，如果重启instance，public会改变
2. 可以为instance指定一个静态IP，重启instance不会改变
3. 创建好EIP后就开始收费，不管是否关联到instance
4. 一个region默认可创建5个EIP
### 2.7 Elastic Network Instance（ENIs）
1. 为一个instance创建多个网卡，实现业务和管理网络的分离，如dual-home instances
### 2.8 Endpoints
+ 连接VPC和AWS服务（如S3等）的连接点，好处是不用走VPN或AWS Direct Connect
+ 创建好endpoint后需要在对应的route table中增加路由
### 2.9 Peering
1. 默认情况下VPC与VPC是不能通信的，可以增加peering connection，这样不同的VPC就可以相互通信
2. Peering没有传递性，例如，若VPC1和VPC2有对等连接，VPC2与VPC3有对等连接，那么VPC1和VPC3默认是没有的，需要手动增加对等连接
3. 创建peering的时候需要在两边VPC的route table中都增加相应路由
4. 只需创建一次peering申请，如VPC1申请与VPC2建立peering连接，连接创建后，不用VPC2再向VPC1申请peering，因为连接已经建好，是双向的
5. 现在peering的VPC可以跨region
6. 如果VPC1与VPC2的CIDR有包含或部分匹配关系，则不能创建peering
### 2.10 Security Group (EC2实例级别)
1. 安全组，通过创建rule来设置firewall，在instance层面控制网络访问
2. 一个VPC支持500个SG，一个SG有50个inbound和50个outbound
3. SG可以设置allow rule，但不能设置deny rule，这个与ACL不同
4. 默认没有inbound rule，除非手动增加，默认outbound allow all
5. SG是有状态的，言外之意，对于某个allow inbound，不用指定对应的outbound，会保留inbound的状态，再将响应返回
6. 对于有多个rule的SG，在判断是否allow或deny时，AWS会评估所有的rule再做决定，没有优先级rule的说法
7. 可以随时修改SG，即便关联到了某个instance，修改后立即生效，不用reboot instance
### 2.11 Network Access Contorl List（ACLs）(子网级别)
1. 在子网层面控制网络访问，默认都allow
2. 支持allow，也支持deny
3. 没有状态，需要同时指定inbound和outbound
4. 每个rule有优先级，通过优先级确定是allow还是deny
5. 影响的是整个子网，不用单独指定到某个instance
### 2.12 Network Address Translation（NAT） Instances and NAT Gateways
1. 都是用于private子网中的instance与外界通讯的技术，可以访问外网，但外网无法穿透到instance
2. NAT instance是AWS提供的AMI，部署后充当了proxy，需要将其部署在public subnet中并分配public IP，且disable source/destination check，然后再配置route table
3. NAT Gateway，不用手动创建proxy instance，仅创建Gateway 服务，当然AWS内部可能也创建了instance，但这个对用户是透明的。需要将Gateway部署在public subnet中，再指定public IP，同时修改路由
4. 推荐使用NAT Gateways，管理更简单
### 2.13 Virtual Private Gateways（VPGs）
1. VPN连接，例如Lab与VPC通信
2. VPG是在AWS端，CGWs是客户端的物理或软件VPN隧道
3. 需要从CGW到VPG初始化VPN隧道
4. VPG支持动态BGP路由，或静态路由
5. VPN连接包含两个隧道以提高高可用

## Reference
- [AWS之VPC、Subnet与CIDR](https://blog.csdn.net/chndata/article/details/46828193)
- [AWS VPC](http://www.manongjc.com/article/103183.html)