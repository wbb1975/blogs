## wget
wget是linux上的命令行的下载工具。这是一个GPL许可证下的自由软件。wget支持HTTP和FTP协议，支持代理服务器和断点续传功能，
能够自动递归远程主机的目录，找到合乎条件的文件并将其下载到本地硬盘上；如果必要，wget将恰当地转换页面中的超级连接以在本地
生成可浏览的镜像。由于没有交互式界面，wget可在后台运行，截获并忽略HANGUP信号，因此在用户推出登录以后，仍可继续运行。通常，
wget用于成批量地下载Internet网站上的文件，或制作远程网站的镜像。wget工具体积小但功能完善，同时支持FTP和HTTP下载方式，支持代理服务器和设置起来方便简单。
1. 使用wget下载单个文件
   > wget http://cn.wordpress.org/wordpress-3.1-zh_CN.zip

   这才命令会从网络下载一个文件并保存在当前目录：在下载的过程中会显示进度条，包含（下载完成百分比，已经下载的字节，当前下载速度，剩余下载时间）。 
2. 使用wget -O下载并以不同的文件名保存

   wget默认会以最后一个符合”/”的后面的字符来命名保存的文件名，对于动态链接的下载通常文件名会不正确。

   错误：下面的例子会下载一个文件并以名称download.php?id=1080保存
   > wget http://www.centos.bz/download?id=1

   正确：为了解决这个问题，我们可以使用参数-O来指定一个文件名： 
   > wget -O wordpress.zip http://www.centos.bz/download.php?id=1080 
3. 使用wget –limit -rate限速下载
   
   当你执行wget的时候，它默认会占用全部可能的宽带下载。但是当你准备下载一个大文件，而你还需要下载其它文件时就有必要限速了。
   > wget –limit-rate=300k http://cn.wordpress.org/wordpress-3.1-zh_CN.zip
4. 使用wget -c断点续传
   > wget -c http://cn.wordpress.org/wordpress-3.1-zh_CN.zip

   对于我们下载大文件时突然由于网络等原因中断非常有帮助，我们可以继续接着下载而不是重新下载一个文件。需要继续中断的下载时可以使用-c参数
5. 使用wget -b后台下载
   
   对于下载非常大的文件的时候，我们可以使用参数-b进行后台下载。
   > wget -b http://cn.wordpress.org/wordpress-3.1-zh_CN.zip

   你可以使用以下命令来察看下载进度 
   > tail -f wget-log
6. 伪装代理名称下载

   有些网站能通过根据判断代理名称不是浏览器而拒绝你的下载请求。不过你可以通过–user-agent参数伪装。 
   > wget –header=”User-Agent: Mozilla/4.0 (compatible; MSIE 5.0;Windows NT; DigExt)” http://msie.only.url/here
7. 使用wget –spider测试下载链接
   
   > 测试是否能正常访问：wget --spider http://www.baidu.com
8. 使用wget –tries增加重试次数
   > wget –tries=40 URL
9. 使用wget -i下载多个文件
    
    首先，保存一份下载链接文件
    ```
    cat > filelist.txt 
    url1 
    url2 
    url3 
    url4
   ```
   接着使用这个文件和参数-i下载： 
   > wget -i filelist.txt
10. 使用wget –mirror镜像网站
    > wget –mirror -p –convert-links -P ./LOCAL URL 
    - –miror:开户镜像下载 
    - -p:下载所有为了html页面显示正常的文件 
    - -convert-links:下载后，转换成本地的链接 
    - -P ./LOCAL：保存所有文件和目录到本地指定目录 
11. 使用wget –reject过滤指定格式下载
    
    你想下载一个网站，但你不希望下载图片，你可以使用以下命令。
    wget –reject=gif url
12. 使用wget FTP下载
    > wget –ftp-user=USERNAME –ftp-password=PASSWORD url

## curl
cURL是一个利用URL语法在命令行下工作的文件传输工具，1997年首次发行。它支持文件上传和下载，所以是综合传输工具，但按传统，习惯称cURL为下载工具。cURL还包含了用于程序开发的libcurl。

cURL支持的通信协议有FTP、FTPS、HTTP、HTTPS、TFTP、SFTP、Gopher、SCP、Telnet、DICT、FILE、LDAP、LDAPS、IMAP、POP3、SMTP和RTSP。

curl还支持SSL认证、HTTP POST、HTTP PUT、FTP上传, HTTP form based upload、proxies、HTTP/2、cookies、用户名+密码认证(Basic, Plain, Digest, CRAM-MD5, NTLM, Negotiate and Kerberos)、file transfer resume、proxy tunneling
```
在以下选项中，(H) 表示仅适用 HTTP/HTTPS ，(F) 表示仅适用于 FTP
    --anyauth       选择 "any" 认证方法 (H)
-a, --append        添加要上传的文件 (F/SFTP)
    --basic         使用HTTP基础认证（Basic Authentication）(H)
    --cacert FILE   CA 证书，用于每次请求认证 (SSL)
    --capath DIR    CA 证书目录 (SSL)
-E, --cert CERT[:PASSWD] 客户端证书文件及密码 (SSL)
    --cert-type TYPE 证书文件类型 (DER/PEM/ENG) (SSL)
    --ciphers LIST  SSL 秘钥 (SSL)
    --compressed    请求压缩 (使用 deflate 或 gzip)
-K, --config FILE   指定配置文件
    --connect-timeout SECONDS  连接超时设置
-C, --continue-at OFFSET  断点续转
-b, --cookie STRING/FILE  Cookies字符串或读取Cookies的文件位置 (H)
-c, --cookie-jar FILE  操作结束后，要写入 Cookies 的文件位置 (H)
    --create-dirs   创建必要的本地目录层次结构
    --crlf          在上传时将 LF 转写为 CRLF
    --crlfile FILE  从指定的文件获得PEM格式CRL列表
-d, --data DATA     HTTP POST 数据 (H)
    --data-ascii DATA  ASCII 编码 HTTP POST 数据 (H)
    --data-binary DATA  binary 编码 HTTP POST 数据 (H)
    --data-urlencode DATA  url 编码 HTTP POST 数据 (H)
    --delegation STRING GSS-API 委托权限
    --digest        使用数字身份验证 (H)
    --disable-eprt  禁止使用 EPRT 或 LPRT (F)
    --disable-epsv  禁止使用 EPSV (F)
-D, --dump-header FILE  将头信息写入指定的文件
    --egd-file FILE  为随机数据设置EGD socket路径(SSL)
    --engine ENGINGE  加密引擎 (SSL). "--engine list" 指定列表
-f, --fail          连接失败时不显示HTTP错误信息 (H)
-F, --form CONTENT  模拟 HTTP 表单数据提交（multipart POST） (H)
    --form-string STRING  模拟 HTTP 表单数据提交 (H)
    --ftp-account DATA  帐户数据提交 (F)
    --ftp-alternative-to-user COMMAND  指定替换 "USER [name]" 的字符串 (F)
    --ftp-create-dirs  如果不存在则创建远程目录 (F)
    --ftp-method [MULTICWD/NOCWD/SINGLECWD] 控制 CWD (F)
    --ftp-pasv      使用 PASV/EPSV 替换 PORT (F)
-P, --ftp-port ADR  使用指定 PORT 及地址替换 PASV (F)
    --ftp-skip-pasv-ip 跳过 PASV 的IP地址 (F)
    --ftp-pret      在 PASV 之前发送 PRET (drftpd) (F)
    --ftp-ssl-ccc   在认证之后发送 CCC (F)
    --ftp-ssl-ccc-mode ACTIVE/PASSIVE  设置 CCC 模式 (F)
    --ftp-ssl-control ftp 登录时需要 SSL/TLS (F)
-G, --get           使用 HTTP GET 方法发送 -d 数据  (H)
-g, --globoff       禁用的 URL 队列 及范围使用 {} 和 []
-H, --header LINE   要发送到服务端的自定义请求头 (H)
-I, --head          仅显示响应文档头
-h, --help          显示帮助
-0, --http1.0       使用 HTTP 1.0 (H)
    --ignore-content-length  忽略 HTTP Content-Length 头
-i, --include       在输出中包含协议头 (H/F)
-k, --insecure      允许连接到 SSL 站点，而不使用证书 (H)
    --interface INTERFACE  指定网络接口／地址
-4, --ipv4          将域名解析为 IPv4 地址
-6, --ipv6          将域名解析为 IPv6 地址
-j, --junk-session-cookies 读取文件中但忽略会话cookie (H)
    --keepalive-time SECONDS  keepalive 包间隔
    --key KEY       私钥文件名 (SSL/SSH)
    --key-type TYPE 私钥文件类型 (DER/PEM/ENG) (SSL)
    --krb LEVEL     启用指定安全级别的 Kerberos (F)
    --libcurl FILE  命令的libcurl等价代码
    --limit-rate RATE  限制传输速度
-l, --list-only    只列出FTP目录的名称 (F)
    --local-port RANGE  强制使用的本地端口号
-L, --location      跟踪重定向 (H)
    --location-trusted 类似 --location 并发送验证信息到其它主机 (H)
-M, --manual        显示全手动
    --mail-from FROM  从这个地址发送邮件
    --mail-rcpt TO  发送邮件到这个接收人(s)
    --mail-auth AUTH  原始电子邮件的起始地址
    --max-filesize BYTES  下载的最大文件大小 (H/F)
    --max-redirs NUM  最大重定向数 (H)
-m, --max-time SECONDS  允许的最多传输时间
    --metalink      处理指定的URL上的XML文件
    --negotiate     使用 HTTP Negotiate 认证 (H)
-n, --netrc         必须从 .netrc 文件读取用户名和密码
    --netrc-optional 使用 .netrc 或 URL; 将重写 -n 参数
    --netrc-file FILE  设置要使用的 netrc 文件名
-N, --no-buffer     禁用输出流的缓存
    --no-keepalive  禁用 connection 的 keepalive
    --no-sessionid  禁止重复使用 SSL session-ID (SSL)
    --noproxy       不使用代理的主机列表
    --ntlm          使用 HTTP NTLM 认证 (H)
-o, --output FILE   将输出写入文件，而非 stdout
    --pass PASS     传递给私钥的短语 (SSL/SSH)
    --post301       在 301 重定向后不要切换为 GET 请求 (H)
    --post302       在 302 重定向后不要切换为 GET 请求 (H)
    --post303       在 303 重定向后不要切换为 GET 请求 (H)
-#, --progress-bar  以进度条显示传输进度
    --proto PROTOCOLS  启用/禁用 指定的协议
    --proto-redir PROTOCOLS  在重定向上 启用/禁用 指定的协议
-x, --proxy [PROTOCOL://]HOST[:PORT] 在指定的端口上使用代理
    --proxy-anyauth 在代理上使用 "any" 认证方法 (H)
    --proxy-basic   在代理上使用 Basic 认证  (H)
    --proxy-digest  在代理上使用 Digest 认证 (H)
    --proxy-negotiate 在代理上使用 Negotiate 认证 (H)
    --proxy-ntlm    在代理上使用 NTLM 认证 (H)
-U, --proxy-user USER[:PASSWORD]  代理用户名及密码
     --proxy1.0 HOST[:PORT]  在指定的端口上使用 HTTP/1.0 代理
-p, --proxytunnel   使用HTTP代理 (用于 CONNECT)
    --pubkey KEY    公钥文件名 (SSH)
-Q, --quote CMD     在传输开始前向服务器发送命令 (F/SFTP)
    --random-file FILE  读取随机数据的文件 (SSL)
-r, --range RANGE   仅检索范围内的字节
    --raw           使用原始HTTP传输，而不使用编码 (H)
-e, --referer       Referer URL (H)
-J, --remote-header-name 从远程文件读取头信息 (H)
-O, --remote-name   将输出写入远程文件
    --remote-name-all 使用所有URL的远程文件名
-R, --remote-time   将远程文件的时间设置在本地输出上
-X, --request COMMAND  使用指定的请求命令
    --resolve HOST:PORT:ADDRESS  将 HOST:PORT 强制解析到 ADDRESS
    --retry NUM   出现问题时的重试次数
    --retry-delay SECONDS 重试时的延时时长
    --retry-max-time SECONDS  仅在指定时间段内重试
-S, --show-error    显示错误. 在选项 -s 中，当 curl 出现错误时将显示
-s, --silent        Silent模式。不输出任务内容
    --socks4 HOST[:PORT]  在指定的 host + port 上使用 SOCKS4 代理
    --socks4a HOST[:PORT]  在指定的 host + port 上使用 SOCKSa 代理
    --socks5 HOST[:PORT]  在指定的 host + port 上使用 SOCKS5 代理
    --socks5-hostname HOST[:PORT] SOCKS5 代理，指定用户名、密码
    --socks5-gssapi-service NAME  为gssapi使用SOCKS5代理服务名称
    --socks5-gssapi-nec  与NEC Socks5服务器兼容
-Y, --speed-limit RATE  在指定限速时间之后停止传输
-y, --speed-time SECONDS  指定时间之后触发限速. 默认 30
    --ssl           尝试 SSL/TLS (FTP, IMAP, POP3, SMTP)
    --ssl-reqd      需要 SSL/TLS (FTP, IMAP, POP3, SMTP)
-2, --sslv2         使用 SSLv2 (SSL)
-3, --sslv3         使用 SSLv3 (SSL)
    --ssl-allow-beast 允许的安全漏洞，提高互操作性(SSL)
    --stderr FILE   重定向 stderr 的文件位置. - means stdout
    --tcp-nodelay   使用 TCP_NODELAY 选项
-t, --telnet-option OPT=VAL  设置 telnet 选项
     --tftp-blksize VALUE  设备 TFTP BLKSIZE 选项 (必须 >512)
-z, --time-cond TIME  基于时间条件的传输
-1, --tlsv1         使用 => TLSv1 (SSL)
    --tlsv1.0       使用 TLSv1.0 (SSL)
    --tlsv1.1       使用 TLSv1.1 (SSL)
    --tlsv1.2       使用 TLSv1.2 (SSL)
    --trace FILE    将 debug 信息写入指定的文件
    --trace-ascii FILE  类似 --trace 但使用16进度输出
    --trace-time    向 trace/verbose 输出添加时间戳
    --tr-encoding   请求压缩传输编码 (H)
-T, --upload-file FILE  将文件传输（上传）到指定位置
    --url URL       指定所使用的 URL
-B, --use-ascii     使用 ASCII/text 传输
-u, --user USER[:PASSWORD]  指定服务器认证用户名、密码
    --tlsuser USER  TLS 用户名
    --tlspassword STRING TLS 密码
    --tlsauthtype STRING  TLS 认证类型 (默认 SRP)
    --unix-socket FILE    通过这个 UNIX socket 域连接
-A, --user-agent STRING  要发送到服务器的 User-Agent (H)
-v, --verbose       显示详细操作信息
-V, --version       显示版本号并退出
-w, --write-out FORMAT  完成后输出什么
    --xattr        将元数据存储在扩展文件属性中
-q                 .curlrc 如果作为第一个参数无效
```
> **语法：# curl [option] [url]**
1. 抓取页面内容到一个文件中
   > curl -o home.html  http://www.sina.com.cn

   用 -O（大写的），后面的url要具体到某个文件，不然抓不下来。我们还可以用正则来抓取东西
   > curl -O http://www.mydomain.com/linux/index.html
2. 模拟表单信息，模拟登录，保存cookie信息
   > curl -c ./cookie_c.txt -F log=aaaa -F pwd=****** http://blog.mydomain.com/login.php
3. 模拟表单信息，模拟登录，保存头信息
   > curl -D ./cookie_D.txt -F log=aaaa -F pwd=****** http://blog.mydomain.com/login.php

   -c(小写)产生的cookie和-D里面的cookie是不一样的。
4. 使用cookie文件
   > curl -b ./cookie_c.txt  http://blog.mydomain.com/wp-admin

5. 断点续传，-C(大写的)
   > curl -C -O http://www.sina.com.cn
6. 传送数据
   
   最好用登录页面测试，因为你传值过去后，回抓数据，你可以看到你传值有没有成功
   > curl -d log=aaaa  http://blog.mydomain.com/login.php
7. 显示抓取错误 -f
   ```
   curl -f http://www.sina.com.cn/asdf
   curl: (22) The requested URL returned error: 404
   curl http://www.sina.com.cn/asdf
   ```
8. 伪造来源地址，有的网站会判断，请求来源地址-e
   > curl -e http://localhost http://www.sina.com.cn
9. 当我们经常用curl去搞人家东西的时候，人家会把你的IP给屏蔽掉的,这个时候,我们可以用代理
    > curl -x 10.10.90.83:80 -o home.html http://www.sina.com.cn
10. 不显示下载进度信息 -s
    > curl -s -o aaa.jpg
11. 显示下载进度条 -#
    > curl -# -O  http://www.mydomain.com/linux/25002_3.html
12. 通过ftp下载文件
    > curl -u 用户名:密码 -O http://blog.mydomain.com/demo/curtain/bbstudy_files/style.css
13. 通过ftp上传
    > curl -T xukai.php ftp://xukai:test@192.168.242.144:21/www/focus/enhouse/

