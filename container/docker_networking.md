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
> **注意**：你可以使用`CTRL-p CTRL-q`接触与容器的附着关系并离开它。

`host`网络将向`host`网络栈添加一个容器。只要网络连接着，在宿主机和容器之间就没有隔离。比如，如果你启动一个容器，利用`host`网络在80端口运行一个网站（Web）服务器，网站服务器就在宿主机的80端口上可用。

`none`和`host`网络在Docker中并非直接可配，但是，你可以配置缺省的`bridge`网络，也可以配置自定义的bridge网络。
### 缺省bridge网络（The default bridge network）

## 参考
- [Configure networking](https://docs.docker.com/v17.09/engine/userguide/networking/)
  