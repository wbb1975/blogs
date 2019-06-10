## Linux服务管理的两种方式
- service命令：service命令其实是去/etc/init.d目录下，去执行相关程序
```
# service命令启动redis脚本
service redis start
# 直接启动redis脚本
/etc/init.d/redis start
# 开机自启动
update-rc.d redis defaults
```
- systemctl命令：systemd 是 Linux 下的一款系统和服务管理器，兼容 SysV 和 LSB 的启动脚本。
## Systemd简介
Systemd是由红帽公司一名叫做Lennart Poettering的员工开发，systemd是Linux系统中最新的初始化系统（init）,它主要的设计目的是克服Sys V 固有的缺点，提高系统的启动速度。从CentOS 7.x开始，CentOS开始使用systemd服务来代替daemon，原来管理系统启动和管理系统服务的相关命令全部由systemctl命令来代替。
## Systemd新特性
- 系统引导时实现服务并行启动
- 按需启动守护进程
- 自动化的服务依赖关系管理
- 同时采用socket式与D-Bus总线式激活服务
- 系统状态快照和恢复
- 利用Linux的cgroups监视进程
- 维护挂载点和自动挂载点
- 各服务间基于依赖关系进行精密控制
## Systemd核心概念
- Unit: 表示不同类型的sytemd对象，通过配置文件进行标识和配置，文件中主要包含了系统服务，监听socket、保存的系统快照以及其他与init相关的信息
- 配置文件：
  1. /usr/lib/systemd/system：每个服务最主要的启动脚本设置，类似于之前的/etc/initd.d
  2. /run/system/system：系统执行过程中所产生的服务脚本，比上面的目录优先运行。
  3. /etc/system/system：管理员建立的执行脚本，类似于/etc/rc.d/rcN.d/Sxx类的功能，比上面目录优先运行，在三者之中，此目录优先级最高。
## Unit类型
- systemctl -t help ：查看unit类型
- service unit：文件扩展名为.service，用于定义系统服务
- target unit：文件扩展名为.target，用于模拟实现“运行级别”
- device unit: .device,用于定义内核识别的设备
- mount unit ：.mount，定义文件系统挂载点
- socket unit ：.socket,用于标识进程间通信用的socket文件，也可以在系统启动时，延迟启动服务，实现按需启动
- snapshot unit：.snapshot，关系系统快照
- swap unit：.swap，用于表示swap设备
- automount unit：.automount，文件系统的自动挂载点如：/misc目录
- path unit：.path，用于定义文件系统中的一个文件或目录使用，常用于当文件系统变化时，延迟激活服务，如spool目录
- time：.timer由systemd管理的计时器
## Systemd基本工具
### 相关命令
```
wangbb@wangbb-ThinkPad-T420:~$ systemctl --version
systemd 237
+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid
wangbb@wangbb-ThinkPad-T420:~$ whereis systemctl
systemctl: /bin/systemctl /usr/share/man/man1/systemctl.1.gz
wangbb@wangbb-ThinkPad-T420:~$ whereis systemd
systemd: /usr/lib/systemd /bin/systemd /etc/systemd /lib/systemd /usr/share/systemd /usr/share/man/man1/systemd.1.gz
```
### 管理服务
daemon命令|systemctl命令|说明
--|--|--
service service_name start|systemctl start [unit type]|启动服务
service service_name stop|systemctl stop [unit type]|停止服务
service service_name restart|systemctl restart [unit type]|重启服务
service service_name status|systemctl status [unit type]|查看服务状态

此外还有一个systemctl参数没有与service命令参数对应:
- reload：重新加载服务，加载更新后的配置文件（并不是所有服务都支持这个参数，比如network.service）
### 设置开机启动/不启动
daemon命令|systemctl命令|说明
--|--|--
chkconfig [服务] on|systemctl enable [unit type]|设置服务开机启动
chkconfig [服务] off|systemctl disable [unit type]|设备服务禁止开机启动
### 查看系统上上所有的服务
>systemctl [command] [–type=TYPE] [–all]

systemctl命令|说明
--|--
systemctl|列出所有的系统服务
systemctl list-units|列出所有启动unit
systemctl list-unit-files|列出所有启动文件
systemctl list-units –type=service –all|列出所有service类型的unit
systemctl list-units –type=service –all grep cpu|列出 cpu电源管理机制的服务
systemctl list-units –type=target –all|列出所有target
### systemctl特殊的用法
systemctl命令|说明|例子
--|--|--
systemctl is-active [unit type]|查看服务是否运行|systemctl is-active network.service
systemctl is-enable [unit type]|查看服务是否设置为开机启动|systemctl is-enable network.service
systemctl mask [unit type]|注销指定服务|systemctl mask cups.service
systemctl unmask [unit type]|取消注销指定服务|systemctl unmask cups.service
> systemctl mask name.service
> 执行此条命令实则创建了一个链接 ln -s '/dev/null' '/etc/systemd/system/sshd.service'
### 系统相关命令
init命令|systemctl命令|说明
--|--|--
init 0|systemctl poweroff|系统关机
init 6|systemctl reboot|重新启动

与开关机相关的其他命令：
systemctl命令|说明
--|--
systemctl suspend|进入睡眠模式
systemctl hibernate|进入休眠模式
systemctl rescue|强制进入救援模式
systemctl emergency|强制进入紧急救援模式
### 设置系统运行级别
#### 运行级别对应表
init级别|systemctl target
--|--
0|shutdown.target
1|emergency.target
2|rescure.target
3|multi-user.target
4|无
5|graphical.target
6|无
#### 设置运行级别
> systemctl [command] [unit.target]

systemctl命令|说明
--|--
systemctl get-default|获得当前的运行级别
systemctl set-default multi-user.target|设置默认的运行级别为mulit-user
systemctl isolate multi-user.target|在不重启的情况下，切换到运行级别mulit-user下
systemctl isolate graphical.target|在不重启的情况下，切换到图形界面下
### 使用systemctl分析各服务之前的依赖关系
> systemctl list-dependencies [unit] [–reverse]

–reverse是用来检查寻哪个unit使用了这个unit
## misc
- 查看启动失败的单元
  ```
  systemctl -failed -t service
  ```
- 杀死进程
  ```
  systemctl kill process_name
  ```
- 设定默认运行级别
  ```
  systemctl set-default muti-user.target
  ls –l /etc/system/system/default.target
  ```
- 进入紧急救援模式
- ```
  systemctl rescue
  ```
- 切换至emergency模式
  ```
  systemctl emergency
  ```
  