## 系统日志
系统组件的日志记录集群中发生的事件，这对于调试非常有用。 你可以配置日志的精细度，以展示更多或更少的细节。 日志可以是粗粒度的，如只显示组件内的错误， 也可以是细粒度的，如显示事件的每一个跟踪步骤（比如 HTTP 访问日志、pod 状态更新、控制器动作或调度器决策）。
### Klog
klog 是 Kubernetes 的日志库。[klog](https://github.com/kubernetes/klog) 为 Kubernetes 系统组件生成日志消息。

有关 klog 配置的更多信息，请参见[命令行工具参考](https://kubernetes.io/docs/reference/command-line-tools-reference/)。

Kubernetes 正在简化其组件日志设施的过程中。从 Kubernetes 1.23 开始，下面的命令行参数将被视为[废弃](https://github.com/kubernetes/enhancements/tree/master/keps/sig-instrumentation/2845-deprecate-klog-specific-flags-in-k8s-components)的，并将在未来的版本里移除：
- `--add-dir-header`
- `--alsologtostderr`
- `--log-backtrace-at`
- `--log-dir`
- `--log-file`
- `--log-file-max-size`
- `--logtostderr`
- `--one-output`
- `--skip-headers`
- `--skip-log-headers`
- `--stderrthreshold`

输出将总是被写到 stderr，无论其输出格式。但调用 Kubernetes 组件的组件可能会将输出重定向，这可能是一个 `POSIX shell` 或者一个工具如 `systemd`。

咋某些情况下，例如，一个 distroless 容器或者 Windows 系统服务，这些选项并可具备。这种情况下Kubernetes [kube-log-runner]二进制文件(https://github.com/kubernetes/kubernetes/blob/d2a8a81639fcff8d1221b900f66d28361a170654/staging/src/k8s.io/component-base/logs/kube-log-runner/README.md) 可被用作一个Kubernetes 组件的包装器来重定向输出。好几个 Kubernetes 基础镜像都包含预构建的二进制文件，命名如 `/go-runner` 并且在服务器和节点发不上可见 `kube-log-runner`。

下面的表格展示了对应 shell 重定向的 kube-log-runner 调用：
用法|POSIX shell (例如bash)|kube-log-runner <options> <cmd>
--------|--------|--------
合并标准输出和错误输出，写到标准输出|2>&1|kube-log-runner (default behavior)
重定向两者到一个文件|1>>/tmp/log 2>&1|kube-log-runner -log-file=/tmp/log
拷贝到日志文件和标准输出|2>&1 \| tee -a /tmp/log|kube-log-runner -log-file=/tmp/log -also-stdout
重定向标准输出到日志文件|>/tmp/log|kube-log-runner -log-file=/tmp/log -redirect-stderr=false
#### klog 输出
一个传统 klog 原生格式的示例如下：
```
I1025 00:15:15.525108       1 httplog.go:79] GET /api/v1/namespaces/kube-system/pods/metrics-server-v0.3.1-57c75779f-9p8wg: (1.512ms) 200 [pod_nanny/v0.0.0 (linux/amd64) kubernetes/$Format 10.56.1.19:51756]
```
消息字符串可能含有回车换行符：
```
I1025 00:15:15.525108       1 example.go:79] This is a message
which has a line break.
```
#### 结构化日志
#### JSON 日志格式
#### 日志清理
#### 日志精细度级别
#### 日志位置

### Reference
- [System Logs](https://kubernetes.io/docs/concepts/cluster-administration/system-logs/)