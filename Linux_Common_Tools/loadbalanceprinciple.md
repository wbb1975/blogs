# LVS负载均衡之工作原理说明
说起lvs，不得不说说关于lvs的工作原理，通常来说lvs的工作方式有三种：nat模式（LVS/NAT),直接路由模式（ LVS/DR），ip隧道模式(LVS/TUN),不过据说还有第四种模式（FULL NAT），下面我们来介绍介绍关于lvs常用的三种工作模式说明
## 一. NAT模式（LVS/NAT）
## 二. DR模式（LVS/DR）
## 三. TUN模式（LVS/TUN）

## Reference
- [Virtual Server via NAT](http://www.linuxvirtualserver.org/VS-NAT.html)
- [Virtual Server via IP Tunneling](http://www.linuxvirtualserver.org/VS-IPTunneling.html)
- [Virtual Server via Direct Routing](http://www.linuxvirtualserver.org/VS-DRouting.html)
- [Linux高可用(HA)之LVS负载均衡三种工作模型原理、10种调度算法和实现](https://www.dwhd.org/20150808_175727.html)
- [linux负载均衡总结性说明（四层负载/七层负载](https://www.cnblogs.com/kevingrace/p/6137881.html)