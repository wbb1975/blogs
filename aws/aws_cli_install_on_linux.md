### 在 Linux 上安装 AWS CLI
> **重要**：从2020-01-10起，AWS CLI 1.17及其以后版本将不再支持Python 2.6 或 Python 3.3。那个日期之后，AWS CLI 的安装器将要求Python 2.7, Python 3.4及其以后版本来安装。更多信息，请参看借助[Python 2.6 或 Python 3.3来使用AWS CLI](https://docs.amazonaws.cn/en_us/cli/latest/userguide/deprecate-python-26-33.html)，以及[这篇博客中的废弃声明](https://aws.amazon.com/blogs/developer/deprecation-of-python-2-6-and-python-3-3-in-botocore-boto3-and-the-aws-cli/)。

您可以使用 pip（一种适用于 Python 的程序包管理器）在大多数 Linux 发行版上安装 AWS Command Line Interface (AWS CLI) 及其依赖项。
> **重要**：awscli 程序包可在其他程序包管理器（如 apt 和 yum）的存储库中可用，但除非您通过 pip 或使用[捆绑安装程序](https://docs.amazonaws.cn/cli/latest/userguide/install-bundle.html)获得该程序包，否则不保证您获得最新版本。

如果您已有 pip，请按照主要[安装主题](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html)中的说明执行操作。运行 pip --version 可查看您的 Linux 版本是否已包含 Python 和 pip。如果您安装了 Python 3+ 版本，我们建议您使用 pip3 命令。
```
$ pip3 --version
```

如果您还没有安装 pip，请检查以查看安装的是哪个版本的 Python。
```
$ python --version
```

或
```
$ python3 --version
```
如果还没有 Python 2 版本 2.6.5+ 或 Python 3 版本 3.3+，则首先必须[安装 Python](https://docs.amazonaws.cn/cli/latest/userguide/install-linux-python.html)。如果已安装 Python，可继续安装 pip 和 AWS CLI。
#### 安装 pip
如果尚未安装 pip，可以使用 Python 打包权威机构提供的脚本进行安装。
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
        ```
        $ ls -a ~
        .  ..  .bash_logout  .bash_profile  .bashrc  Desktop  Documents  Downloads
        ```
        + Bash – .bash_profile、.profile 或 .bash_login
        + Zsh – .zshrc
        + Tcsh – .tcshrc、.cshrc 或 .login。
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
#### 通过 pip 安装 AWS CLI
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
如果出现错误，请参阅排查 [AWS CLI 错误](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-troubleshooting.html)。
#### 升级到最新版本的 AWS CLI
我们建议您定期检查以查看是否有新的 AWS CLI 版本，并尽可能升级到该版本。

使用 pip list -o 命令来检查哪些程序包已“过时”：
```
$ aws --version
aws-cli/1.16.170 Python/3.7.3 Linux/4.14.123-111.109.amzn2.x86_64 botocore/1.12.160

$ pip3 list -o
Package    Version  Latest   Type 
---------- -------- -------- -----
awscli     1.16.170 1.16.198 wheel
botocore   1.12.160 1.12.188 wheel
```

由于前一个命令显示有较新版本的 AWS CLI 可用，您可以运行 pip install --upgrade 以获取最新版本：
```
$ pip3 install --upgrade --user awscli
Collecting awscli
  Downloading https://files.pythonhosted.org/packages/dc/70/b32e9534c32fe9331801449e1f7eacba6a1992c2e4af9c82ac9116661d3b/awscli-1.16.198-py2.py3-none-any.whl (1.7MB)
     |████████████████████████████████| 1.7MB 1.6MB/s 
Collecting botocore==1.12.188 (from awscli)
  Using cached https://files.pythonhosted.org/packages/10/cb/8dcfb3e035a419f228df7d3a0eea5d52b528bde7ca162f62f3096a930472/botocore-1.12.188-py2.py3-none-any.whl
Requirement already satisfied, skipping upgrade: docutils>=0.10 in ./venv/lib/python3.7/site-packages (from awscli) (0.14)
Requirement already satisfied, skipping upgrade: rsa<=3.5.0,>=3.1.2 in ./venv/lib/python3.7/site-packages (from awscli) (3.4.2)
Requirement already satisfied, skipping upgrade: colorama<=0.3.9,>=0.2.5 in ./venv/lib/python3.7/site-packages (from awscli) (0.3.9)
Requirement already satisfied, skipping upgrade: PyYAML<=5.1,>=3.10; python_version != "2.6" in ./venv/lib/python3.7/site-packages (from awscli) (3.13)
Requirement already satisfied, skipping upgrade: s3transfer<0.3.0,>=0.2.0 in ./venv/lib/python3.7/site-packages (from awscli) (0.2.0)
Requirement already satisfied, skipping upgrade: jmespath<1.0.0,>=0.7.1 in ./venv/lib/python3.7/site-packages (from botocore==1.12.188->awscli) (0.9.4)
Requirement already satisfied, skipping upgrade: urllib3<1.26,>=1.20; python_version >= "3.4" in ./venv/lib/python3.7/site-packages (from botocore==1.12.188->awscli) (1.24.3)
Requirement already satisfied, skipping upgrade: python-dateutil<3.0.0,>=2.1; python_version >= "2.7" in ./venv/lib/python3.7/site-packages (from botocore==1.12.188->awscli) (2.8.0)
Requirement already satisfied, skipping upgrade: pyasn1>=0.1.3 in ./venv/lib/python3.7/site-packages (from rsa<=3.5.0,>=3.1.2->awscli) (0.4.5)
Requirement already satisfied, skipping upgrade: six>=1.5 in ./venv/lib/python3.7/site-packages (from python-dateutil<3.0.0,>=2.1; python_version >= "2.7"->botocore==1.12.188->awscli) (1.12.0)
Installing collected packages: botocore, awscli
  Found existing installation: botocore 1.12.160
    Uninstalling botocore-1.12.160:
      Successfully uninstalled botocore-1.12.160
  Found existing installation: awscli 1.16.170
    Uninstalling awscli-1.16.170:
      Successfully uninstalled awscli-1.16.170
Successfully installed awscli-1.16.198 botocore-1.12.188
```
### 将 AWS CLI 可执行文件添加到命令行路径
在使用 pip 进行安装后，可能需要将 aws 可执行文件添加到操作系统的 PATH 环境变量中。

您可以运行以下命令验证 pip 已将 AWS CLI 安装到哪个文件夹中。
```
$ which aws
/home/username/.local/bin/aws
```

您可以将此路径 ~/.local/bin/ 作为参考，因为在 Linux 中 /home/username 对应于 ~。

如果您忽略了 --user 开关且未在用户模式下安装，可执行文件可能位于 Python 安装的 bin 文件夹中。如果您不知道 Python 的安装位置，请运行此命令。
```
$ which python
/usr/local/bin/python
```
输出可能是符号链接的路径，而不是实际的可执行文件。运行 ls -al 以查看所指向的路径。
```
$ ls -al /usr/local/bin/python
/usr/local/bin/python -> ~/.local/Python/3.6/bin/python3.6
```
如果这是在[安装 pip](https://docs.amazonaws.cn/cli/latest/userguide/install-linux.html#install-linux-pip)的步骤 3 中添加到路径的相同文件夹，则不必再执行任何操作。否则，请再次执行步骤 3a 到 3c 将该附加文件夹添加到路径中。
#### 在 Linux 上安装 Python
如果您的分发没有随 Python 提供，或者提供的是较早的版本，请在安装 pip 和 AWS CLI 之前安装 Python。

在 Linux 上安装 Python 3：

1. 检查是否已安装 Python。
   
     ```
     $ python --version
     ```
     或
     ```
     $ python3 --version
     ```
     > **注意** 如果您的 Linux 分发版本附带了 Python，则可能需要安装 Python 开发人员程序包以获取编译扩展和安装 AWS CLI 时需要的头文件和库。使用程序包管理器安装开发人员程序包（名称通常为 python-dev 或 python-devel）。
2. 如果尚未安装 Python 2.7 或Python 3.4或更高版本，请使用分发版本的程序包管理器来安装 Python。命令和程序包名称会有所不同：
   + 在 Debian 衍生系统（如 Ubuntu）上，请使用 apt。检查适用于您的 Python 版本的 apt 存储库。然后，运行如下命令（替换为正确的程序包名称）：
      ```
      $ sudo apt-get install python3
      ```
   + 在 Red Hat 及其衍生系统上，请使用 yum。检查适用于您的 Python 版本的 yum 存储库。然后，运行如下命令（替换为正确的程序包名称）：
       ```
      $ sudo yum install python36
      ```
   + 在 SUSE 及其衍生系统上，请使用 zypper。检查适用于您的 Python 版本的存储库。然后，运行如下命令（替换为正确的程序包名称）：
      ```
      $ sudo apt-get install python3
      ```

   有关程序包的安装位置以及使用方法的详细信息，请参阅适用于您系统的程序包管理器和 [Python](https://www.python.org/doc/) 的文档。
3. 打开命令提示符或 shell，并运行以下命令验证 Python 是否已正确安装。
    ```
    $ python3 --version
    Python 3.6.8
    ```
#### 在 Amazon Linux 上安装 AWS CLI
该 AWS Command Line Interface (AWS CLI) 预装在 Amazon Linux 和 Amazon Linux 2 上。使用以下命令检查当前安装的版本。
```
$ aws --version
aws-cli/1.16.116 Python/3.6.8 Linux/4.14.77-81.59.amzn2.x86_64 botocore/1.12.106
```
> **重要**

> 使用 sudo 完成一个命令，向该命令授予对您的系统的完全访问权限。我们建议仅在不再存在安全选项时使用该命令。对于诸如 pip 之类的命令，我们建议您避免使用 sudo，方式是使用 [Python 虚拟环境 (venv)](https://docs.python.org/3/library/venv.html)；或者通过指定 --user 选项，在用户文件夹而不是系统文件夹中安装。

如果您使用 yum 程序包管理器，您可以使用以下命令安装 AWS CLI：yum install aws-cli。您可以使用命令 yum update 获取 yum 存储库中可用的最新版本。
> **注意**

> yum 存储库不归 Amazon 所有或维护，因此可能不包含最新版本。我们建议您使用 pip 来获取最新版本。
##### 先决条件
验证 Python 和 pip 是否均已安装。有关更多信息，请参阅 在 Linux 上安装 AWS CLI。

在 Amazon Linux 上安装或升级 AWS CLI（用户）：
1. 使用 pip3 install 安装最新版本的 AWS CLI。如果您安装了 Python 3+ 版本，我们建议您使用 pip3。如果您在 [Python 虚拟环境 (venv) ](https://docs.python.org/3/library/venv.html)中运行命令，则不需要使用 --user 选项。

```
$ pip3 install --upgrade --user awscli
```
2. 将安装位置添加到 PATH 变量的开头。

```
$ export PATH=/home/ec2-user/.local/bin:$PATH
```

       将此命令添加到配置文件的启动脚本（例如，~/.bashrc）的末尾，以在命令行会话之间保留更改。

3. 使用 aws --version 验证您正在运行新版本。
```
$ aws --version
aws-cli/1.16.116 Python/3.6.8 Linux/4.14.77-81.59.amzn2.x86_64 botocore/1.12.106
```

## Reference
- [在 Linux 上安装 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/install-linux.html)