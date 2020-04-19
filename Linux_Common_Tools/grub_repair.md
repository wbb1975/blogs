# ubuntu18.0+win10 grub2修复与启动项管理
## 1. boot-repair修复grub
### 1.1 第一步：启动ubuntu live
### 1.2 第二步：
```
sudo add-apt-repository ppa:yannubuntu/boot-repair && sudo apt-get update
```
### 1.3 第三步：
```
sudo apt-get install -y boot-repair && boot-repair
```
### 1.4 第四步：
点击Recommended repair，等待修复完成（过程中可能会提示是否上传日志，yes or no 均可）

**add-apt-repository: command not found**
```
sudo apt-get install software-properties-common python-software-properties
```

grub 修复完成，重启即可，此时引导菜单会出现多余的启动项，使用Grub Customizer来管理这些启动项。 
## 2. Grub Customizer管理启动项
### 2.1 第一步：启动ubuntu
### 2.2 第二步：
```
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo apt-get update
sudo apt-get install grub-customizer
```
### 2.3 第三步：启动Grub Customizer，配置启动列表，保存退出重启。

## Reference
- [ubuntu18.0+win10 grub2修复与启动项管理](https://blog.csdn.net/zero_hzz/article/details/79205422)