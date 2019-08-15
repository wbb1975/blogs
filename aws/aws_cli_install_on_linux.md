## 在 Linux 上安装 AWS CLI
您可以使用 pip（一种适用于 Python 的程序包管理器）在大多数 Linux 发行版上安装 AWS Command Line Interface (AWS CLI) 及其依赖项。

如果您已有 pip，请按照主要安装主题中的说明执行操作。运行 pip --version 可查看您的 Linux 版本是否已包含 Python 和 pip。如果您安装了 Python 3+ 版本，我们建议您使用 pip3 命令。
```
$ pip3 --version
```

如果您还没有安装 pip，请检查以查看安装的是哪个版本的 Python。
```
$ python --version
$ python3 --version
```
如果还没有 Python 2 版本 2.6.5+ 或 Python 3 版本 3.3+，则首先必须[安装 Python](https://docs.amazonaws.cn/cli/latest/userguide/install-linux-python.html)。如果已安装 Python，可继续安装 pip 和 AWS CLI。
####安装 pip
如果尚未安装 pip，可以使用 Python 打包权威机构 提供的脚本进行安装。
1. 使用 curl 命令下载安装脚本。
    ```
    $ curl  https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    ```
2. 使用 Python 运行脚本以下载并安装最新版本的 pip 和其他必需的支持包。
    ```
    $ python get-pip.py --user
    ```
    或
    ```
    $ python3 get-pip.py --user
    ```

    当您包含 --user 开关时，脚本将 pip 安装到路径 ~/.local/bin。
3. 确保包含 pip 的文件夹是您的 PATH 变量的一部分。
    + 在您的用户文件夹中查找 Shell 的配置文件脚本。如果您不能确定所使用的 Shell，请运行 echo $SHELL。
    + 在配置文件脚本末尾添加与以下示例类似的导出命令。
        ```
        export PATH=~/.local/bin:$PATH
        ```
    + 将配置文件重新加载到当前会话中，以使更改生效。
       ```
       $ source ~/.bash_profile
       ```
4. 接下来，可以进行测试，以验证是否正确安装了 pip。
   ```
   $ pip3 --version
   pip 19.0.3 from ~/.local/lib/python3.7/site-packages (python 3.7)
   ```
### 通过 pip 安装 AWS CLI
使用 pip 安装 AWS CLI。
```
$ pip3 install awscli --upgrade --user
```

当您使用 --user 开关时，pip 将 AWS CLI 安装到 ~/.local/bin。

验证 AWS CLI 是否已正确安装。
```
$ aws --version
aws-cli/1.16.116 Python/3.6.8 Linux/4.14.77-81.59-amzn2.x86_64 botocore/1.12.106
```

要升级到最新版本，请重新运行安装命令。
```
pip3 install awscli --upgrade --user
```
### 将 AWS CLI 可执行文件添加到命令行路径
在使用 pip 进行安装后，可能需要将 aws 可执行文件添加到操作系统的 PATH 环境变量中。

您可以运行以下命令验证 pip 已将 AWS CLI 安装到哪个文件夹中。
```
$ which aws
/home/username/.local/bin/aws
```
## 在虚拟环境中安装 AWS CLI
您可以通过在虚拟环境中安装 AWS Command Line Interface (AWS CLI)，避免所需版本与其他 pip 程序包冲突。
1. 使用 pip 安装 virtualenv。
   ```
   $ pip install --user virtualenv
   ```
2. 创建虚拟环境并命名它。
   ```
   $ virtualenv ~/cli-ve
   ```
3. 激活新虚拟环境。
   ```
   $ source ~/cli-ve/bin/activate
   ```
4. 将 AWS CLI 安装到虚拟环境中。
   ```
   (cli-ve)~$ pip install --upgrade awscli
   ```
5. 验证 AWS CLI 是否已正确安装。
   ```
   $ aws --version
  aws-cli/1.16.116 Python/3.6.8 Linux/4.14.77-81.59-amzn2.x86_64 botocore/1.12.106
   ```

您可以使用 deactivate 命令退出虚拟环境。不管何时启动新会话，都必须重新激活环境。

要升级到最新版本，请重新运行安装命令。

```
(cli-ve)~$ pip install --upgrade awscli
```

## Reference
- [在 Linux 上安装 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/install-linux.html)