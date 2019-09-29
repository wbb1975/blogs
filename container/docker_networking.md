# 容器联网
## Docker容器联网（Docker container networking）
本节提供Docker缺省联网行为的综述，包括创建网络的缺省类型，以及如何创建用户自定义网络。它也描述了在单个主机上或跨主机集群上创建网络所需资源。

关于在Linux主机上Docker与iptables交互的细节，请参阅[Docker and iptables](https://docs.docker.com/engine/userguide/networking/#docker-and-iptables)。
### 缺省网络（Default networks）
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
### 用户定义网络（User-defined networks）
建议使用用户自定义bridge网络来控制哪些容器能够互相通信，启用容器名字到IP地址解析的自动DNS解析。Docker提供了创建这些网络的缺省网络驱动。你能够创建**bridge网络**, **overlay网络**或**MACVLAN网络**。你也可以创建**网络插件**或**远程网络**来满足彻底的用户定制和控制。

你可以根据你的需要创建很多网络，你也可以在任何时间将容器连接到0个或多个网络。另外，你不需要重启容器便可以将容器联网或断网。当一个容器连接到多个网络时，它的外部链接有第一个（单词序）非内部网络提供。

下面的章节将详细描述每种Docker内建网络驱动。
#### bridge网络（Bridge networks）
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
#### docker_gwbridge网络（docker_gwbridge network）
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
#### Overlay networks in swarm mode

## 参考
- [Configure networking](https://docs.docker.com/v17.09/engine/userguide/networking/)
  