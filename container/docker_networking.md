# 容器联网
## 第一章 Docker容器联网（Docker container networking）
本节提供Docker缺省联网行为的综述，包括创建网络的缺省类型，以及如何创建用户自定义网络。它也描述了在单个主机上或跨主机集群上创建网络所需资源。

关于在Linux主机上Docker与iptables交互的细节，请参阅[Docker and iptables](https://docs.docker.com/engine/userguide/networking/#docker-and-iptables)。
### 1.1 缺省网络（Default networks）
当你安装Docker时，它将自动安装三个网络。你可以用`docker network ls`命令打印这些网络。
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network ls
[sudo] wangbb 的密码： 
NETWORK ID          NAME                DRIVER              SCOPE
5bbfcdd0f429        bridge              bridge              local
083182596fb9        host                host                local
7c7b0d8f8c22        none                null                local
```
这三种网络是内建于Docker中的。当你运行一个容器，你可以使用`--network`标记来指定你的容器将连接的网络。

`bridge`网络代表在Docker安装中存在的`docker0`网络，除非你使用`docker run --network=<NETWORK>`选项额外指定，Docker服务器（daemon）缺省会将这个容器连接到这个网络。在主机上使用`ip addr show`（或其简写形式`ip a`）可以看到`bridge`是网络堆栈的一部分。（ifconfig命令将被废弃。取决于你的系统，它可能工作，也可能给你一个`command not found`的错误。）
```
$ ip addr show

docker0   Link encap:Ethernet  HWaddr 02:42:47:bc:3a:eb
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:47ff:febc:3aeb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:17 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1100 (1.1 KB)  TX bytes:648 (648.0 B)
```
> **在Mac或Windows上运行Docker**：如果你在Mac上运行Docker（或者在Docker Windows上运行Linux容器），`docker network ls`命令将象上面描述的那样工作，但即使`ip addr show`或`ifconfig`存在，它仅仅给你本地机器的IP地址，而不是Docker容器网络。这是因为Docker利用网络接口运行在一层浅虚拟机上（a thin VM），而非宿主机本身。
> 
> 为了使用`ip addr show`或`ifconfig`浏览Docker网络，登录上一个[Docker机器](https://docs.docker.com/v17.09/machine/overview/)，比如一个本地虚拟机，或一个云提供商的[AWS上的Docker主机](https://docs.docker.com/v17.09/machine/examples/aws/)，或[数字海洋上的Docker主机](https://docs.docker.com/v17.09/machine/examples/ocean/)。你可以使用`docker-machine ssh <machine-name>`来登录一个本地或云提供商的主机，或如如云提供商网站所述，使用`ssh`直接登录。

`none`网络向特定容器的网络栈添加了一个容器，这个容器缺乏网络接口。附着到这个容器上查看其网络栈你可以看到：
```
$ docker attach nonenetcontainer

root@0cb243cd1293:/# cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters

root@0cb243cd1293:/# ip -4 addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever

root@0cb243cd1293:/#
```
> **注意**：你可以使用`CTRL-p CTRL-q`接触与容器的附着关系并让其保持运行状态。

`host`网络将向`host`网络栈添加一个容器。只要网络连接着，在宿主机和容器之间就没有隔离。比如，如果你启动一个容器，利用`host`网络在80端口运行一个网站（Web）服务器，网站服务器就在宿主机的80端口上可用。

`none`和`host`网络在Docker中并非直接可配，但是，你可以配置缺省的`bridge`网络，也可以配置自定义的bridge网络。
#### 缺省bridge网络（The default bridge network）
缺省的bridge网络在所有Docker主机上都存在。如果你不指定一个不同的网络，新的容器将自动连接到缺省bridge网络。

`docker network inspect`命令可用于返回关于网络的一些信息：
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "75fd510472216b1d00c56aaa277ea63d873811123e74ccbc0f8fd3a2fce10a1c",
        "Created": "2019-09-28T19:08:10.148911696+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```
运行下面的命令来启动两个busybox容器，每一个都连接到缺省bridge网络。
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run -itd --name=container1 busybox
[sudo] wangbb 的密码： 
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
7c9d20b9b6cd: Pull complete 
Digest: sha256:fe301db49df08c384001ed752dff6d52b4305a73a7f608f21528048e8a08b51e
Status: Downloaded newer image for busybox:latest
d171031f1fcdfe09a14df27c011503ed9b422d41b2ea8a679b1c8b0b8fb28b9b
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run -itd --name=container2 busybox
484c540f5767ec29d24f1314175cd1d3b1338b2ed94d2154bcd9ae74bf955169
```
启动两个容器后再次检视bridg网络。两个busybox容器都连接到bridge网络。注意它们的IP地址，它们在你的宿主机上可能与下面的例子不一样：
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "75fd510472216b1d00c56aaa277ea63d873811123e74ccbc0f8fd3a2fce10a1c",
        "Created": "2019-09-28T19:08:10.148911696+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "484c540f5767ec29d24f1314175cd1d3b1338b2ed94d2154bcd9ae74bf955169": {
                "Name": "container2",
                "EndpointID": "300d2766a103874c23af0d9ac26bad8dee993b66f663a3bc60a3f5bc6b88da88",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            },
            "d171031f1fcdfe09a14df27c011503ed9b422d41b2ea8a679b1c8b0b8fb28b9b": {
                "Name": "container1",
                "EndpointID": "df53dd7d0902ee33fb1881767f3e05b44a1d27e279447a687f8ce1ee3b079926",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```
连接到bridge网络的容器能够通过IP地址彼此通信。**Docker不支持在缺省bridge网络上的自动服务发现。如果你期望容器能够从容器名中解析出IP地址，你应该使用用户自定义网络**。你可以利用遗留`docker run --link`选项来连接两个容器，但是在大多数情况下这是不被推荐的（选项）。

你可以附着到一个运行的容器来从内部观察网络。你是以root账户登陆的，所以你的命令提示符是一个`#`字符：
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker attach 484c540f5767
/ # ip -4 addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
7: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
/ # 
```
从容器内部使用ping命令来测试到另一个容器的IP地址的连接。
```
/ # ping -w3 172.17.0.2
PING 172.17.0.2 (172.17.0.2): 56 data bytes
64 bytes from 172.17.0.2: seq=0 ttl=64 time=0.314 ms
64 bytes from 172.17.0.2: seq=1 ttl=64 time=0.199 ms
64 bytes from 172.17.0.2: seq=2 ttl=64 time=0.334 ms

--- 172.17.0.2 ping statistics ---
4 packets transmitted, 3 packets received, 25% packet loss
round-trip min/avg/max = 0.199/0.282/0.334 ms
```
使用cat命令来查看容器的/etc/hosts。它显示了容器能够识别的IP地址和主机名。
```
/ # cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.3	484c540f5767
```
使用按键序列`CTRL-p CTRL-q`可以解除与`conatiner1`的附着关系，并保持其运行状态。如果你愿意，你可以附着到`conatiner2`上并重复上面的命令。

缺省的docker0 bridge网络支持通过端口映射（port mapping）和docker run --link来允许容器在docker0网络中通讯。这种方式是不推荐的。只要可能，应尽可能使用[用户定义bridge网络](https://docs.docker.com/engine/userguide/networking/#user-defined-networks)。
#### 禁用缺省bridge网络（DISABLE THE DEFAULT BRIDGE NETWORK）
如果你根本不想缺省的bridge网络被创建，在daemon.json文件中加入下面的配置。这仅仅当Docker在Linux主机上运行时适用。
```
"bridge": "none",
"iptables": "false"
```
重启Docker以使修改生效。

你也可以手动以选项`--bridge=none --iptables=false`启动dockerd，但是，这可能与系统启动节本启动的dockerd环境不一样，因此其它的行为可能改变。

禁用缺省bridge网络属于高级选项，大多数用户不需要。
### 1.2 用户定义网络（User-defined networks）
建议使用用户自定义bridge网络来控制哪些容器能够互相通信，启用容器名字到IP地址解析的自动DNS解析。Docker提供了创建这些网络的缺省网络驱动。你能够创建**bridge网络**, **overlay网络**或**MACVLAN网络**。你也可以创建**网络插件**或**远程网络**来满足彻底的用户定制和控制。

你可以根据你的需要创建很多网络，你也可以在任何时间将容器连接到0个或多个网络。另外，你不需要重启容器便可以将容器联网或断网。当一个容器连接到多个网络时，它的外部链接有第一个（单词序）非内部网络提供。

下面的章节将详细描述每种Docker内建网络驱动。
#### 1.2.1 bridge网络（Bridge networks）
bridge网络是Docker世界使用最广泛的网络类型。bridge网络与缺省bridge网络相似，但添加了一些新特性，移除了一些老的功能。下面的例子创建了一些bridge网络，并对这些网络上的容器做了一些实验。
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network create --driver bridge isolated_nw
d5e9fc422bb6fafaba913fae73a460cde190a7e52dceabd61a605ac19ca0ded9
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network inspect isolated_nw
[
    {
        "Name": "isolated_nw",
        "Id": "d5e9fc422bb6fafaba913fae73a460cde190a7e52dceabd61a605ac19ca0ded9",
        "Created": "2019-09-29T10:04:13.598584747+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
wangbb@wangbb-ThinkPad-T420:~$ 
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
75fd51047221        bridge              bridge              local
083182596fb9        host                host                local
d5e9fc422bb6        isolated_nw         bridge              local
7c7b0d8f8c22        none                null                local
```
当你创建网络后，你可以使用`docker run --network=<NETWORK>`选项来在该网络上启动容器。
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run --network=isolated_nw -itd --name=container3 busybox
f3be9ee43844bf6358ce971f3169908574617dfc3a4546c9aac05212cb81acdf
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network inspect isolated_nw
[
    {
        "Name": "isolated_nw",
        "Id": "d5e9fc422bb6fafaba913fae73a460cde190a7e52dceabd61a605ac19ca0ded9",
        "Created": "2019-09-29T10:04:13.598584747+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "f3be9ee43844bf6358ce971f3169908574617dfc3a4546c9aac05212cb81acdf": {
                "Name": "container3",
                "EndpointID": "8c64c15f62ef16d03ad2c39db0441c80f643f2cd30c045464a358ce3ca5758a2",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```
你在这个网络上启动的容器必须驻留在同一Docker主机上。网络中的每台容器可以立即与网络中的其它容器通信。虽然，网络本身把容器与其它网络隔离。

![bridge_network](https://github.com/wbb1975/blogs/blob/master/container/images/bridge_network.png)

在一个用户定义bridge网络内部，链接是不支持的。在这个网络上你可以对容器[导出和发布容器端口](https://docs.docker.com/engine/userguide/networking/#exposing-and-publishing-ports)。如果你想使bridge网络的一部分对外部网络可用，这个特性是有用的。

![network_access](https://github.com/wbb1975/blogs/blob/master/container/images/network_access.png)

如果想在单个主机上运行一个相对小的网络，bridge网络是有用的。但是，你可以通过创建overlay网络创建重要的大型网络。
#### 1.2.2 docker_gwbridge网络（docker_gwbridge network）
docker_gwbridge是一个本地bridge网络，在两种场景下有Docker自动创建：
- 当你初始化或者加入swarm，Docker将创建docker_gwbridge网络，并将它用于跨主机的不同swarm节点间通讯。
- 当容器的网络没有一个可以提供外部连接，除了其他容器的网络，Docker还将容器连接到docker_gwbridge网络，如此，容器可以连接到外部网络或其他swarm节点。

如果你期待用户配置，你可以事先创建docker_gwbridge网络，不然Docker会在需要时创建。下面的例子使用一些额外选项创建了docker_gwbridge网络。
```
$ docker network create --subnet 172.30.0.0/16 \
                        --opt com.docker.network.bridge.name=docker_gwbridge \
			--opt com.docker.network.bridge.enable_icc=false \
			docker_gwbridge
```
当你使用overlay网络时docker_gwbridge网络总是存在。
#### 1.2.3 Overlay networks in swarm mode
你可以在一个运行在没有外部键值存储的swarm模式的管理节点上创建一个overlay网络。swarm使得overlay网络对swarm中需要它提供服务的节点可用。当你创建了一个使用overlay网络的服务，管理节点自动扩展overlay网络到运行服务任务的节点。

为了了解更多运行于swarm模式的Docker引擎，请参阅[swarm模式概览](https://docs.docker.com/v17.09/engine/swarm/)。

下面的例子显示了如何创建网络，以及如何在swarm模式中把它用于来自于管理节点的服务。
```
$ docker network create   --driver overlay   --subnet 10.0.9.0/24  my-multi-host-network
400g6bwzd68jizzdx5pgyoe95
$ docker service create --replicas 2 --network my-multi-host-network --name my-web nginx
716thylsndqma81j6kkkb5aus
```
只有swarm服务才能连接到overlay网络，孤立容器不能。关于swarms的更多信息，请参阅[Docker swarm模式下overlay网络安全模型](https://docs.docker.com/v17.09/engine/userguide/networking/overlay-security-model/)和[将服务附着到overlay网络](https://docs.docker.com/v17.09/engine/swarm/networking/)。
#### 1.2.4 Overlay networks without swarm mode
如果你不是在swarm模式下使用Docker引擎，overlay网络需要一个有效的键值存储服务。支持的键值存储包括Consul, Etcd, 和 ZooKeeper (分布式存储)。在以这种方式创建网络前，你需要安装和配置你选择的键值存储服务。Docker持有你将连接的网络和你必须通讯的服务。
> **注意**：运行于swarm模式的Docker引擎并不与一个拥有键值存储的网络兼容。

这种使用overlay网络的方式对大多数Docker用户是不推荐的。它可被用于孤立的swarms ，对于构建方案的系统开发者是有用的。将来可能被废弃。如果你认为你可能以这种方式使用overlay网络，参见[这篇指南](https://docs.docker.com/v17.09/engine/userguide/networking/get-started-overlay/)。
#### 1.2.5 定制网路插件
如果上面的网络机制还不能满足你的需求，你可以使用Docker的插件机制撰写你自己的网络驱动插件。插件将在Docker服务所在主机上以一个单独的进程运行。网络插件的使用是一个高级主题。

网络插件遵从和其它插件一样的限制和安装规则。所有的插件使用插件API，拥有同样的生命周期，包括：安装，启动，停止和激活。

一旦你创建并安装了自定义网络驱动，你可以在创建网络时使用--driver标记指定驱动。
```
$ docker network create --driver weave mynet
```
你可以检视你的网络，将容器连接到网络或从网络切断，以及移除网络。一个特定的网络插件可能有特定的使用需求。检查插件的文档来获取特定信息。关于撰写插件的更多信息，请参阅[扩展Docker](https://docs.docker.com/v17.09/engine/extend/legacy_plugins/)和[撰写网络插件](https://docs.docker.com/v17.09/engine/extend/plugins_network/)。
#### 1.2.6 嵌入式域名服务器
Docker服务器（Daemon）运行着一个嵌入式域名服务器，它可以提供连接到同一用户定义网络的容器间的域名解析，因此这些容器可以把域名解析为IP地址。如果嵌入式域名服务器不能解析请求，它将根据针对容器的配置将请求转发到外部域名服务器。当容器被创建时，为了帮助这个过程，这个嵌入式域名服务器将在127.0.0.11监听，并被添加到容器的resolv.conf文件中。有关自定义网络的嵌入式域名服务器的详细信息，请参见[自定义网络的嵌入式域名服务器](https://docs.docker.com/v17.09/engine/userguide/networking/configure-dns/)。
### 1.3 导出和发布端口（Exposing and publishing ports）
在Docker网络，涉及到网络端口有两种不同的机制：导出和发布端口。这适用于缺省bridge网络和用户定义bridge网络。
- 你早Dockfile中使用EXPOSE关键字，或者在docker run命令行中传递--expose来导出端口。导出端口属于某种记述：哪些端口将被使用，但并不实际映射或打开任何端口。导出端口是可选的。
- 你可以传递--publish或--publish-all标记给docker run命令行来发布端口。这告诉Docker在容器的网卡上哪些端口已经被打开。当一个端口被发布后，除非你指定了宿主机上的运行时端口，它被映射到宿主机上的可用高阶端口（大于30000）。你不能在创建镜像时（在Docker文件）指定端口到宿主机的映射，因为没有方法能够确保当你运行镜像时该端口在宿主机上可用。

下面的例子把容器中的80端口映射到宿主机的随机高阶端口（在这个例子中，32768）。-d 标记让容器在背景运行，因此你可以发布docker ps命令：
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run -it -d -p 80 nginx
...
Digest: sha256:aeded0f2a861747f43a01cf1018cf9efe2bdd02afd57d2b11fcc7fcadc16ccd1
Status: Downloaded newer image for nginx:latest
38a6d018aa4e040e0ceecd17ac0c91e3ce6e38e0192d279b3a49a4b61e66bc72
wangbb@wangbb-ThinkPad-T420:~$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS       NAMES
38a6d018aa4e        nginx               "nginx -g 'daemon of…"   20 seconds ago      Up 7 seconds       0.0.0.0:32768->80/tcp   laughing_bhabha
```

下一个例子指定容器80端口应该被映射到宿主机的8080 端口上。如果8080端口不可用，它将会失败。
```
$ docker run -it -d -p 8080:80 nginx

$ docker ps

b9788c7adca3        nginx               "nginx -g 'daemon ..."   43 hours ago        Up 3 seconds        80/tcp, 443/tcp, 0.0.0.0:8080->80/tcp   goofy_brahmagupta
```
### 1.4 将代理用于容器（Use a proxy server with containers）
如果你的容器需要使用TTP, HTTPS, 或FTP 代理服务器，你可以用不同的方式来配置它：
- 对Docker 17.07或更高版本，你可以配置Docker客户端把代理信息自动传递给容器
- 对Docker 17.06或跟低版本，你必须在容器内设置合适的环境变量。你可以在构建镜像时（这会使镜缺乏可移植性），或当你创建并运行容器时设置。
#### 1.4.1 配置Docker客户端
1. 在Docker客户端，在启动容器的用户的主目录下，创建或编辑~/.config.json。象下面一样添加JSON描述，如果必要，将代理类型替换为httpsProxy o或ftpProxy，并替换代理服务器的地址和端口。你可以同时配置多个代理服务器。
    
    你可以从代理服务器中排除一些主机或一些地址，方式是设置noProxy为一个或多个由逗号分隔的主机或地址。使用`*`作为通配符是支持的，如下例所示：
    ```
    {
        "proxies":
        {
            "default":
            {
            "httpProxy": "http://127.0.0.1:3001",
            "noProxy": "*.test.example.com,.example2.com"
            }
        }
    }
    ```
    保存该文件。
2. 当你创建或启动新的容器，环境变量将会在容器里自动设置。
#### 1.4.2 手动设置环境变量
当你构建镜像，或当你创建或运行容器时使用--env标记，你可以设置一个或多个下面的变量为合适的值。这种方法使镜像缺少可移植性，因此如果你拥有Docker 17.07或更高版本，你应该使用[配置Docker客户端](https://docs.docker.com/engine/userguide/networking/#configure-the-docker-client)。

Variable|Dockerfile example
--|--
HTTP_PROXY|ENV HTTP_PROXY "http://127.0.0.1:3001"	--env HTTP_PROXY "http://127.0.0.1:3001"
HTTPS_PROXY|ENV HTTPS_PROXY "https://127.0.0.1:3001"	--env HTTPS_PROXY "https://127.0.0.1:3001"
FTP_PROXY|ENV FTP_PROXY "ftp://127.0.0.1:3001"	--env FTP_PROXY "ftp://127.0.0.1:3001"
NO_PROXY|ENV NO_PROXY "*.test.example.com,.example2.com"	--env NO_PROXY "*.test.example.com,.example2.com"
### 1.5 链接
在Docker包含用户定义网络前，你可以使用Docker--link特性来允许一个容器将另一个容器的名字解析为IP地址，也使它可以访问链接容器的环境变量。只要可能，应避免使用--link标记。

当你创建链接（link）时，其行为与你创建缺省bridge网络或用户定义bridge网络时不一样。更多信息，参阅[遗留链接](https://docs.docker.com/v17.09/engine/userguide/networking/default_network/dockerlinks/)来获取bridge网络中的链接特性，以及在用户网络中事关连接功能的[用户定义网络中的链接特性](https://docs.docker.com/v17.09/engine/userguide/networking/work-with-networks/#linking-containers-in-user-defined-networks)。
### 1.6 Docker和防火墙（Docker and iptables）
Linux主机使用一个叫做iptables的模块管理对网络设备的访问，包括路由，端口转发，网络地址转换（NAT），以及其它功能。当你启动或停止发布端口的容器时，当你创建或修改容器附着的网络时，或者某些网络相关的操作时，Docker将会修改iptables

iptables的完整讨论超出了这个主题的讨论范围，任何时候，你可以使用iptables -L来查看那些iptables规则在起作用。如果有多个表存在，你可以使用iptables -t nat -L命令来打印一个特定表，别如nat, prerouting, 或 postrouting。关于iptables的完整文档，请参阅[netfilter/iptables](https://netfilter.org/documentation/)。

典型地，iptables规则由一个初始化脚本或一个服务进程如firewalld创建。这些规则不会跨越系统重启而存储，因此脚本或工具必须在系统启动时运行，典型地在运行级别3或网络初始化后。咨询你的Linux发行版的网络文档来获取使iptables规则持久化的合适方式。

Docker动态管理服务器的iptables规则，容器，服务和网络。在Docker 17.06或更高版本，你可以在一个新表DOCKER-USER中添加规则，并且这些规则会在DOcker自动创建的任何规则前加载。如果你需要在Docker运行前事先加载一些规则，这将是很有用的。

## 参考
- [Configure networking](https://docs.docker.com/v17.09/engine/userguide/networking/)
- [用网络命令行工作](https://docs.docker.com/v17.09/engine/userguide/networking/work-with-networks/)
- [多主机网络入门](https://docs.docker.com/v17.09/engine/userguide/networking/get-started-overlay/)
- [管理容器中数据](https://docs.docker.com/v17.09/engine/tutorials/dockervolumes/)
- [Docker及其概览](https://docs.docker.com/v17.09/machine)
- [Docker Swarm概览](https://docs.docker.com/v17.09/swarm)
- [libNetwork项目调查](https://github.com/docker/libnetwork)
  