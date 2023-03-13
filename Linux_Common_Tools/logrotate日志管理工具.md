## logrotate日志管理工具

### 一. 概述
logrotate是一个Linux系统默认安装了的日志文件管理工具，用来把旧文件轮转、压缩、删除，并且创建新的日志文件。我们可以根据日志文件的大小、天数等来转储，便于对日志文件管理。

logrotate 是基于 `crond` 服务来运行的，其 `crond` 服务的脚本是 `/etc/cron.daily/logrotate`，日志转储是系统自动完成的。实际运行时，logrotate会调用配置文件 `/etc/logrotate.conf`，可以在 `/etc/logrotate.d` 目录里放置自定义好的配置文件，用来覆盖 logrotate 的缺省值。

### 二. 配置文件详解

`/etc/logrotate.conf` 是主配置文件
`/etc/logrotate.d` 是一个目录，该目录下的所有文件都会被主动的读到 `/etc/logrotate.conf` 中执行

配置项说明：

配置项|说明
--------|--------
compress|通过 gzip 压缩转储旧的日志
nocompress|不需要压缩时，用这个参数
copytruncate|用于还在打开中的日志文件，把当前日志备份并截断，是先拷贝再清空的方式，拷贝和清空之间有一个时间差，可能会丢失部分日志数据
nocopytruncate|备份日志文件但是不截断
create mode owner group|使用指定的文件模式创建新的日志文件，如:create 0664 root utmp
nocreate|不建立新的日志文件
delaycompress|和 compress 一起使用时，转储的日志文件到下一次转储时才压缩
nodelaycompress|覆盖 delaycompress 选项，转储同时压缩
missingok|在日志转储期间,任何错误将被忽略
errors address|转储时的错误信息发送到指定的 Email 地址
ifempty|即使日志文件是空文件也转储，这个是 logrotate 的缺省选项
notifempty|如果日志文件是空文件的话，不转储
mail E-mail|把转储的日志文件发送到指定的 E-mail 地址
nomail|转储时不发送日志文件到 E-mail 地址
olddir directory|转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统
noolddir|转储后的日志文件和当前日志文件放在同一个目录下
prerotate/endscript|在转储之前需要执行的命令可以放入这个对中，这两个关键字必须单独成行
postrotate/endscript|在转储之后需要执行的命令可以放入这个对中，这两个关键字必须单独成行
sharedscripts|所有的日志文件都转储完毕后统一执行一次脚本
daily|指定转储周期为每天
weekly|指定转储周期为每周
monthly|指定转储周期为每月
rotate count|指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5个备份
size(minsize) logsize|当日志文件到达指定的大小时才转储，size 可以指定单位为k或M，如:size 500k,size 100M
dateext|指定转储后的日志文件以当前日期为格式结尾，如
dateformat dateformat|配合dateext使用，紧跟在下一行出现，定义日期格式，只支持%Y %m %d %s这4个参数，如:dateformat -%Y%m%d%s

### 三.实战案例

#### 1.nginx

```
cat > /etc/logrotate.d/nginx << eof
/usr/local/nginx/logs/*log {
    daily
    # 每天转储
    rotate 30
    # 保存30个备份
    missingok
    # 在日志转储期间,任何错误将被忽略
    notifempty
    # 文件为空时不转储
    compress
    # 通过 gzip 压缩
    dateext
    # 日志文件以当前日期为格式结尾
    sharedscripts
    # 所有日志文件转储完毕后执行一次脚本
    postrotate
    # 转储之后执行命令，和endscript成对使用
        /bin/kill -USR1 \$(cat /usr/local/nginx/logs/nginx.pid 2>/dev/null) 2>/dev/null || :
    endscript
    # 转储之后执行命令，和postrotate成对使用
}
eof
```

#### 2.rsyslog

```
cat > /etc/logrotate.d/syslog << eof
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
        sharedscripts
        dateext
        rotate 25
        size 40M
        compress
        dateformat  -%Y%m%d%s
        postrotate
                /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
        endscript
}
eof
```

#### 3.redis

```
cat > /etc/logrotate.d/redis << eof
/var/log/redis/*.log {
    weekly
    rotate 10
    copytruncate
    delaycompress
    compress
    notifempty
    missingok
}
eof
```

### 四.命令参数说明

使用 `man logrotate` 或者 `logrotate --help` 来查看相关命令参数

```
logrotate --help
Usage: logrotate [OPTION...] <configfile>
  -d, --debug              调试模式，输出调试结果，并不执行。隐式-v参数
  -f, --force              强制转储文件
  -m, --mail=command       发送邮件命令而不是用‘/bin/mail'发
  -s, --state=statefile    状态文件，对于运行在不同用户情况下有用
  -v, --verbose            显示转储过程的详细信息
```

如果等不及 cron 自动执行日志转储，可以强制转储文件（-f 参数） ，正式执行前最好使用调试模式（-d 参数）

```
/usr/sbin/logrotate -f /etc/logrotate.d/nginx
/usr/sbin/logrotate -d -f /etc/logrotate.d/nginx
```

### 五.自定义日志转储时间

现在需要将日志转储（切割）时间调整到每天的 `0` 点，即每天切割的日志是前一天的`0点-23点59分59秒`之间的内容。

1.日志转储流程

首先说一下基于crond服务，logrotate 转储日志的流程：

crond 服务加载 `/etc/cron.d/0hourly` --->在每小时的01分执行 `/etc/cron.hourly/0anacron` --->执行 anacron --->根据 `/etc/anacrontab` 的配置执行 `/etc/cron.daily`，`/etc/cron.weekly`，`/etc/cron.monthly` --->执行 `/etc/cron.daily/` 下的 logrotate 脚本 --->执行 logrotate --->根据 `/etc/logrotate.conf` 配置执行脚本 `/etc/logrotate.d/nginx` --->转储 nginx 日志成功

重点看一下 /etc/anacrontab

```
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45  # 随机的延迟时间，表示最大45分钟
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22 # 在3点-22点之间开始

#period in days   delay in minutes   job-identifier   command
1       5       cron.daily              nice run-parts /etc/cron.daily
7       25      cron.weekly             nice run-parts /etc/cron.weekly
@monthly 45     cron.monthly            nice run-parts /etc/cron.monthly
# period in days 是表示1天、7天、1个月执行一次
# delay in minutes 是延迟的分钟数
# nice设置优先级为10，范围为-20（最高优先级）到19（最低优先级）
# run-parts 是一个脚本，表示会执行它后面目录里的脚本
```

分析可以得出，如果机器没有关机，默认的 logrotate （配置文件里设置的是daily）一般会在每天的3点05分到3点45分之间执行。

2. 定义每天00点00分转储 `nginx` 日志

**方法一**

通过上面的分析，调整如下：
调整 `/etc/anacrontab` 配置文件，将 RANDOM_DELAY=0 ， START_HOURS_RANGE=0-22 ， delay in minutes 改为0。
调整 `/etc/cron.d/0hourly` 配置文件，将 `01` 改为 `00`（`/etc/cron.daily`那一行）。
这样logrotate就可以在每天00点00分转储日志（配置文件里设置的是daily）

**方法二**

上面的方法会影响到 /etc/cron.daily，/etc/cron.weekly，/etc/cron.monthly 下所有脚本的自动执行时间，影响范围有点大，如果我们仅仅需要nginx的日志转储在每天00点执行怎么办？

我们可以创建一个文件夹，如 `/etc/logrotate.daily.0/` ，放置每天0点需要执行的转储日志配置，然后设置计划任务，每天 00点00分 `logrotate -f` 强制执行。具体操作如下：

```
mkdir -p /etc/logrotate.daily.0/
mv /etc/logrotate.d/nginx /etc/logrotate.daily.0/ # 具体配置内容参照上文
crontab -e
#nginx log logrotate
00 00 * * * /usr/sbin/logrotate -f /etc/logrotate.daily.0/nginx >/dev/null 2>&1
```

注意：`/etc/logrotate.d/` 目录下相应的配置文件要删掉，否则每天会自动执行两次。

### 六.参考资料

### Reference

- [logrotate日志管理工具](https://www.cnblogs.com/wushuaishuai/p/9330952.html)
- [运维中的日志切割操作梳理（Logrotate/python/shell脚本实现）](https://www.cnblogs.com/kevingrace/p/6307298.html)
- [crontab和anacron和logrotate的关系详解](https://blog.csdn.net/damiaomiao666/article/details/72597731)