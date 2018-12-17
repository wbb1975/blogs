# awk入门教程
awk是处理文本文件的一个应用程序，对于处理结构化的文本尤其有效。基本上，awk其实不仅仅是工具软件，还是一种编程语言。
一、基本用法
\# 格式
$awk 动作 文件名

\# 示例
$awk '{print $0}' README.md　＃处理动作print $0代表打印当前行

awk会根据空格和制表符，将每一行分成若干字段，依次用$1、$2、$3代表第一个字段、第二个字段、第三个字段等等.
$echo 'this is a test' | awk '{print $3}'
a

/etc/passwd的字段分隔符是冒号（:），所以要用-F参数指定分隔符为冒号。然后，才能提取到它的第一个字段。
$awk -F ':' '{ print $1 }' /etc/passwd
root
daemon
bin
sys
sync
games
...

二、变量
除了$ + 数字表示某个字段，awk还提供其他一些变量。
变量NF表示当前行有多少个字段，因此$NF就代表最后一个字段。

$echo 'this is a test' | awk '{print $NF}'
test
$(NF-1)代表倒数第二个字段。
变量NR表示当前处理的是第几行。
$awk -F ':' '{print NR ") " $1}' /etc/passwd
1) root
2) daemon
3) bin
4) sys
5) sync
6) games
...

awk的其他内置变量如下：
FILENAME：当前文件名
FS：字段分隔符，默认是空格和制表符。
RS：行分隔符，用于分割每一行，默认是换行符。
OFS：输出字段的分隔符，用于打印时分隔字段，默认为空格。
ORS：输出记录的分隔符，用于打印时分隔记录，默认为换行符。
OFMT：数字输出的格式，默认为％.6g。

三、函数
awk还提供了一些内置函数，方便对原始数据的处理。
函数toupper()用于将字符转为大写。
$awk -F ':' '{ print toupper($1) }' /etc/passwd
ROOT
DAEMON
BIN
SYS
SYNC
GAMES
...

其他常用函数如下：
tolower()：字符转为小写。
length()：返回字符串长度。
substr()：返回子字符串。
sin()：正弦。
cos()：余弦。
sqrt()：平方根。
rand()：随机数。

四、条件
awk允许指定输出条件，只输出符合条件的行，输出条件要写在动作的前面。
$awk '条件 动作' 文件名
$awk -F ':' '/usr/ {print $1}' /etc/passwd
daemon
bin
sys
games
man
...
上面代码中，print命令前面是一个正则表达式，只输出包含usr的行。

\# 输出奇数行
$ awk -F ':' 'NR % 2 == 1 {print $1}' /etc/passwd

下面的例子输出第一个字段等于指定值的行。
$awk -F ':' '$1 == "root" || $1 == "bin" {print $1}' /etc/passwd
root
bin

五、if语句
awk提供了if结构，用于编写复杂的条件。
$awk -F ':' '{if ($1 > "m") print $1}' /etc/passwd
root
sys
sync
man
mail
...

if结构还可以指定else部分：
$awk -F ':' '{if ($1 > "m") print $1; else print "less"}' /etc/passwd
root
less
less
sys
sync

六、参考链接
[An Awk tutorial by Example](https://gregable.com/2010/09/why-you-should-know-just-little-awk.html), Greg Grothaus
[30 Examples for Awk Command in Text Processing](https://likegeeks.com/awk-command/), Mokhtar Ebrahim
