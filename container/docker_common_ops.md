# docker常用操作汇总
## 1. 启动容器（docker）
```
Usage:	docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

Run a command in a new container

Options:
      --add-host list                  Add a custom host-to-IP mapping (host:ip)
  -a, --attach list                    Attach to STDIN, STDOUT or STDERR
      --blkio-weight uint16            Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
      --blkio-weight-device list       Block IO weight (relative device weight) (default [])
      --cap-add list                   Add Linux capabilities
      --cap-drop list                  Drop Linux capabilities
      --cgroup-parent string           Optional parent cgroup for the container
      --cidfile string                 Write the container ID to the file
      --cpu-period int                 Limit CPU CFS (Completely Fair Scheduler) period
      --cpu-quota int                  Limit CPU CFS (Completely Fair Scheduler) quota
      --cpu-rt-period int              Limit CPU real-time period in microseconds
      --cpu-rt-runtime int             Limit CPU real-time runtime in microseconds
  -c, --cpu-shares int                 CPU shares (relative weight)
      --cpus decimal                   Number of CPUs
      --cpuset-cpus string             CPUs in which to allow execution (0-3, 0,1)
      --cpuset-mems string             MEMs in which to allow execution (0-3, 0,1)
  -d, --detach                         Run container in background and print container ID   // 常用， 将容器放至后台运行
      --detach-keys string             Override the key sequence for detaching a container
      --device list                    Add a host device to the container
      --device-cgroup-rule list        Add a rule to the cgroup allowed devices list
      --device-read-bps list           Limit read rate (bytes per second) from a device (default [])
      --device-read-iops list          Limit read rate (IO per second) from a device (default [])
      --device-write-bps list          Limit write rate (bytes per second) to a device (default [])
      --device-write-iops list         Limit write rate (IO per second) to a device (default [])
      --disable-content-trust          Skip image verification (default true)
      --dns list                       Set custom DNS servers
      --dns-option list                Set DNS options
      --dns-search list                Set custom DNS search domains
      --entrypoint string              Overwrite the default ENTRYPOINT of the image
  -e, --env list                       Set environment variables
      --env-file list                  Read in a file of environment variables
      --expose list                    Expose a port or a range of ports
      --group-add list                 Add additional groups to join
      --health-cmd string              Command to run to check health
      --health-interval duration       Time between running the check (ms|s|m|h) (default 0s)
      --health-retries int             Consecutive failures needed to report unhealthy
      --health-start-period duration   Start period for the container to initialize before starting health-retries
                                       countdown (ms|s|m|h) (default 0s)
      --health-timeout duration        Maximum time to allow one check to run (ms|s|m|h) (default 0s)
      --help                           Print usage
  -h, --hostname string                Container host name
      --init                           Run an init inside the container that forwards signals and reaps processes
  -i, --interactive                    Keep STDIN open even if not attached               // 常用，开启输入终端
      --ip string                      IPv4 address (e.g., 172.30.100.104)
      --ip6 string                     IPv6 address (e.g., 2001:db8::33)
      --ipc string                     IPC mode to use
      --isolation string               Container isolation technology
      --kernel-memory bytes            Kernel memory limit
  -l, --label list                     Set meta data on a container
      --label-file list                Read in a line delimited file of labels
      --link list                      Add link to another container
      --link-local-ip list             Container IPv4/IPv6 link-local addresses
      --log-driver string              Logging driver for the container  // 常用，控制容器所用的日志驱动，默认为json-file。选项为syslog, none等
      --log-opt list                   Log driver options
      --mac-address string             Container MAC address (e.g., 92:d0:c6:0a:29:33)
  -m, --memory bytes                   Memory limit
      --memory-reservation bytes       Memory soft limit
      --memory-swap bytes              Swap limit equal to memory plus swap: '-1' to enable unlimited swap
      --memory-swappiness int          Tune container memory swappiness (0 to 100) (default -1)
      --mount mount                    Attach a filesystem mount to the container
      --name string                    Assign a name to the container     // 常用，给容器指定一个有意义的名字
      --network string                 Connect a container to a network (default "default")
      --network-alias list             Add network-scoped alias for the container
      --no-healthcheck                 Disable any container-specified HEALTHCHECK
      --oom-kill-disable               Disable OOM Killer
      --oom-score-adj int              Tune host's OOM preferences (-1000 to 1000)
      --pid string                     PID namespace to use
      --pids-limit int                 Tune container pids limit (set -1 for unlimited)
      --privileged                     Give extended privileges to this container
  -p, --publish list                   Publish a container's port(s) to the host
  -P, --publish-all                    Publish all exposed ports to random ports
      --read-only                      Mount the container's root filesystem as read only
      --restart string                 Restart policy to apply when a container exits (default "no")  // 有用， 控制容器自动重启，可用选项包括:always,on-failure,no等
      --rm                             Automatically remove the container when it exits
      --runtime string                 Runtime to use for this container
      --security-opt list              Security Options
      --shm-size bytes                 Size of /dev/shm
      --sig-proxy                      Proxy received signals to the process (default true)
      --stop-signal string             Signal to stop a container (default "SIGTERM")
      --stop-timeout int               Timeout (in seconds) to stop a container
      --storage-opt list               Storage driver options for the container
      --sysctl map                     Sysctl options (default map[])
      --tmpfs list                     Mount a tmpfs directory
  -t, --tty                            Allocate a pseudo-TTY         // 常用，为容器分配一个伪tty终端，从而可以提供一个交互式shell
      --ulimit ulimit                  Ulimit options (default [])
  -u, --user string                    Username or UID (format: <name|uid>[:<group|gid>])
      --userns string                  User namespace to use
      --uts string                     UTS namespace to use
  -v, --volume list                    Bind mount a volume
      --volume-driver string           Optional volume driver for the container
      --volumes-from list              Mount volumes from the specified container(s)
  -w, --workdir string                 Working directory inside the container
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run --restart=on-failure:5 -i -t ubuntu:19.10 /bin/bash
root@1d6986c6178d:/# wget
bash: wget: command not found
root@1d6986c6178d:/# apt install wget
Reading package lists... Done
Building dependency tree       
Reading state information... Done
E: Unable to locate package wget
root@1d6986c6178d:/# exit
exit
```
## 2. 附着到容器上（docker）
```
Usage:	docker attach [OPTIONS] CONTAINER

Attach local standard input, output, and error streams to a running container

Options:
      --detach-keys string   Override the key sequence for detaching a container
      --no-stdin             Do not attach STDIN
      --sig-proxy            Proxy all received signals to the process (default true)
```

**Example:**
```
# 在一个终端上
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run -i -t centos /bin/bash
[root@3fec81b59db4 /]# 

# 在另一个终端上
wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker ps
[sudo] wangbb 的密码： 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS            NAMES
3fec81b59db4        centos              "/bin/bash"         17 seconds ago      Up 5 seconds          elegant_varahamihira
wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker attach 3fec81b59db4
[root@3fec81b59db4 /]# 
```

**注意**
```
由三种方式可以唯一指代容器：短UUID(3fec81b59db4)，长UUID以及容器名（如gray_cat）。
```
## 3. 查看容器运行日志
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help logs
Usage:	docker logs [OPTIONS] CONTAINER

Fetch the logs of a container

Options:
      --details        Show extra details provided to logs
  -f, --follow         Follow log output        // 常用，跟踪容器的最新日志而非整个日志文件
      --since string   Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
      --tail string    Number of lines to show from the end of the logs (default "all")
  -t, --timestamps     Show timestamps  // 常用，为每条日志加上时间戳
      --until string   Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42
                       minutes)
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker logs -tf 3fec81b59db4
[root@3fec81b59db4 /]# exit
2019-09-02T23:21:29.735402684Z exit
[root@3fec81b59db4 /]# ls -l
2019-09-03T13:07:31.006119268Z total 12
2019-09-03T13:07:31.049015874Z -rw-r--r--   1 root root 12082 Mar  5 17:36 anaconda-post.log
2019-09-03T13:07:31.049055348Z lrwxrwxrwx   1 root root     7 Mar  5 17:34 bin -> usr/bin
2019-09-03T13:07:31.049069061Z drwxr-xr-x   5 root root   360 Sep  3 13:07 dev
2019-09-03T13:07:31.049080338Z drwxr-xr-x  47 root root    66 Sep  2 23:12 etc
2019-09-03T13:07:31.049090264Z drwxr-xr-x   2 root root     6 Apr 11  2018 home
2019-09-03T13:07:31.049100163Z lrwxrwxrwx   1 root root     7 Mar  5 17:34 lib -> usr/lib
2019-09-03T13:07:31.049110092Z lrwxrwxrwx   1 root root     9 Mar  5 17:34 lib64 -> usr/lib64
2019-09-03T13:07:31.049119902Z drwxr-xr-x   2 root root     6 Apr 11  2018 media
2019-09-03T13:07:31.049129545Z drwxr-xr-x   2 root root     6 Apr 11  2018 mnt
2019-09-03T13:07:31.049176074Z drwxr-xr-x   2 root root     6 Apr 11  2018 opt
2019-09-03T13:07:31.049186550Z dr-xr-xr-x 377 root root     0 Sep  3 13:07 proc
2019-09-03T13:07:31.049193363Z dr-xr-x---   2 root root    27 Sep  2 23:21 root
2019-09-03T13:07:31.049203318Z drwxr-xr-x  11 root root   148 Mar  5 17:36 run
2019-09-03T13:07:31.049212213Z lrwxrwxrwx   1 root root     8 Mar  5 17:34 sbin -> usr/sbin
2019-09-03T13:07:31.049222250Z drwxr-xr-x   2 root root     6 Apr 11  2018 srv
2019-09-03T13:07:31.049257994Z dr-xr-xr-x  13 root root     0 Sep  3 13:07 sys
2019-09-03T13:07:31.049269146Z drwxrwxrwt   7 root root   132 Mar  5 17:36 tmp
2019-09-03T13:07:31.049279273Z drwxr-xr-x  13 root root   155 Mar  5 17:34 usr
2019-09-03T13:07:31.049297938Z drwxr-xr-x  18 root root   238 Mar  5 17:34 var
```
## 4. 查看容器内的进程
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help top

Usage:	docker top CONTAINER [ps OPTIONS]

Display the running processes of a container
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker top 3fec81b59db4
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                7890                7871                0                   21:07               ?                   00:00:00            /bin/bash
```
## 5. 查看容器统计信息
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help stats

Usage:	docker stats [OPTIONS] [CONTAINER...]

Display a live stream of container(s) resource usage statistics

Options:
  -a, --all             Show all containers (default shows just running)
      --format string   Pretty-print images using a Go template
      --no-stream       Disable streaming stats and only pull the first result
      --no-trunc        Do not truncate output
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker stats 3fec81b59db4
```
## 6. 在容器内运行新进程
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help exec

Usage:	docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

Run a command in a running container

Options:
  -d, --detach               Detached mode: run command in the background
      --detach-keys string   Override the key sequence for detaching a container
  -e, --env list             Set environment variables
  -i, --interactive          Keep STDIN open even if not attached
      --privileged           Give extended privileges to the command
  -t, --tty                  Allocate a pseudo-TTY
  -u, --user string          Username or UID (format: <name|uid>[:<group|gid>])
  -w, --workdir string       Working directory inside the container
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker exec -d 3fec81b59db4 touch /etc/new_config_file
```
## 7. 停止容器
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help stop

Usage:	docker stop [OPTIONS] CONTAINER [CONTAINER...]

Stop one or more running containers

Options:
  -t, --time int   Seconds to wait for stop before killing it (default 10)

wangbb@wangbb-ThinkPad-T420:~$ sudo docker help kill

Usage:	docker kill [OPTIONS] CONTAINER [CONTAINER...]

Kill one or more running containers

Options:
  -s, --signal string   Signal to send to the container (default "KILL")
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker stop 3fec81b59db4
Error response from daemon: cannot stop container: 3fec81b59db4: Cannot kill container 3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2: unknown error after kill: docker-runc did not terminate sucessfully: container_linux.go:393: signaling init process caused "permission denied"
: unknown
```
## 8. 删除docker images
```
Usage:	docker rmi [OPTIONS] IMAGE [IMAGE...]

Remove one or more images

Options:
  -f, --force      Force removal of the image
      --no-prune   Do not delete untagged parents
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
wbb1975/tomcat7         latest              66b4aa67705a        2 months ago        447MB
<none>                  <none>              60fefef25bd9        2 months ago        208MB
wbb1975/fetcher         latest              776e991df81c        2 months ago        208MB
<none>                  <none>              b8d8cdaa12a5        2 months ago        208MB
<none>                  <none>              859a1b964ee1        2 months ago        447MB
<none>                  <none>              492cf4d18cd8        2 months ago        20伪
wbb1975/dockerjenkins   latest              483b7c1a6fd2        2 months ago        991MB
wbb1975/nginx_static    v2                  314bde3dc9bc        2 months ago        220MB
wbb1975/nginx           v2                  b79157a0498a        2 months ago        161MB
wbb1975/ubuntu          vim                 72c19dd55e99        2 months ago        155MB
ubuntu                  14.04               2c5e00d77a67        3 months ago        188MB
ubuntu                  19.10               3f269de19be1        3 months ago        76.1MB
ubuntu                  latest              7698f282e524        3 months ago        69.9MB
centos                  latest              9f38484d220f        5 months ago        202MB

wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker rmi b8d8cdaa12a5 859a1b964ee1 492cf4d18cd8
Deleted: sha256:b8d8cdaa12a526600a2dff40f019f9dd03e360b8bde701c39cc8a0130a9bb766
Deleted: sha256:9ec8af52c7fef3f633cdc20c6407a1f1f1aeea04bc63c28ec43240ba29df3035
```
## 9. 删除docker containers
```
Usage:	docker rm [OPTIONS] CONTAINER [CONTAINER...]

Remove one or more containers

Options:
  -f, --force     Force the removal of a running container (uses SIGKILL)
  -l, --link      Remove the specified link
  -v, --volumes   Remove the volumes associated with the container
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker ps -a
[sudo] wangbb 的密码： 
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                       PORTS                     NAMES
f519ee78f085        centos                    "/bin/bash"              2 minutes ago       Up About a minute                                      serene_goldstine
1d6986c6178d        ubuntu:19.10              "/bin/bash"              2 minutes ago       Exited (100) 2 minutes ago                             romantic_jones
932d79a8808c        ubuntu:19.10              "/bin/bash"              5 minutes ago       Exited (127) 2 minutes ago                             eager_mccarthy
069dab50eba9        wbb1975/tomcat7           "/usr/share/tomcat7/…"   2 months ago        Exited (255) 2 months ago    0.0.0.0:32769->8080/tcp   sample_app1
10af15d02baf        wbb1975/fetcher           "/bin/bash"              2 months ago        Exited (0) 2 months ago                                romantic_ptolemy
cce2164cc1e0        wbb1975/dockerjenkins     "/usr/local/bin/dock…"   2 months ago        Exited (130) 2 months ago                              stoic_poitras
9c81bb7ba4b2        6e8f97d7a8e7              "/bin/bash"              2 months ago        Exited (0) 2 months ago                                festive_bose
1d5d9f386063        wbb1975/tomcat7           "/usr/share/tomcat7/…"   2 months ago        Exited (255) 2 months ago    0.0.0.0:32768->8080/tcp   sample_app
27c494b51467        98447d5689ab              "/bin/sh -c 'apt -yq…"   2 months ago        Exited (0) 2 months ago                                condescending_montalcini
8846e14ba0c1        60fefef25bd9              "wget https://tomcat…"   2 months ago        Exited (0) 2 months ago                                sample
db78fe35a58c        ubuntu:19.10              "/bin/bash"              2 months ago        Exited (0) 2 months ago                                ubuntu
a9792fb03bb3        1109cc25984a              "/bin/sh -c 'apt ins…"   2 months ago        Exited (1) 2 months ago                                tender_vaughan
65186cae20e1        1109cc25984a              "/bin/sh -c 'apt ins…"   2 months ago        Exited (100) 2 months ago                              vibrant_kapitsa
73482458c2ed        1109cc25984a              "/bin/sh -c 'apt ins…"   2 months ago        Exited (100) 2 months ago                              wizardly_shockley
580835c04606        efcc2ed07cd4              "/bin/sh -c 'apt-key…"   2 months ago        Exited (255) 2 months ago                              jolly_northcutt
a74b96083aa1        wbb1975/nginx_static:v2   "/bin/bash"              2 months ago        Exited (0) 2 months ago                                wonderful_lamport
fe56d7809884        wbb1975/nginx_static:v2   "nginx -g 'daemon of…"   2 months ago        Exited (255) 2 months ago    0.0.0.0:32768->80/tcp     static_website_v2
f6e8811ec059        14c2e07ad936              "/bin/bash"              2 months ago        Exited (0) 2 months ago                                distracted_keller
fa3663f6fd29        14c2e07ad936              "nginx -g 'daemon of…"   2 months ago        Exited (255) 2 months ago    0.0.0.0:32770->80/tcp     static_website_v5
bdc0426530f1        7fd86884e4c8              "/bin/sh -c 'apt ins…"   2 months ago        Exited (100) 2 months ago                              sleepy_bassi
47eeb4d1dede        04623b341ef0              "nginx"                  2 months ago        Exited (0) 2 months ago                                static_website_v4
c0710594f0e3        309289ae59da              "/bin/sh -c 'apt -y …"   2 months ago        Exited (100) 2 months ago                              quirky_goldstine
f244269f5a68        72c19dd55e99              "/bin/bash"              2 months ago        Exited (0) 2 months ago                                brave_curran
00b04cde70d1        ubuntu                    "/bin/bash"              2 months ago        Exited (0) 2 months ago                                heuristic_hawking
13967e69d717        da49a654f2d7              "/app"                   3 months ago        Exited (255) 3 months ago                              app
902be4af4179        ubuntu:19.10              "/bin/bash"              3 months ago        Exited (100) 3 months ago                              ubuntu_19_10
8cceae8f8dd1        centos                    "/bin/bash"              3 months ago        Exited (0) 3 months ago                                unruffled_kilby

wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker rm 1d6986c6178d
1d6986c6178d

wangbb@wangbb-ThinkPad-T420:~/git/blogs/container$ sudo docker rm db9c07f4a74f
Error response from daemon: You cannot remove a running container db9c07f4a74fcdc5b64613b8f597a04097548903a3a1085ddcf799c1b6a02b00. Stop the container before attempting removal or force remove
```
## 10. 深入容器
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker help inspect

Usage:	docker inspect [OPTIONS] NAME|ID [NAME|ID...]

Return low-level information on Docker objects

Options:
  -f, --format string   Format the output using the given Go template
  -s, --size            Display total file sizes if the type is container
      --type string     Return JSON for specified type
```

**Example:**
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker inspect 3fec81b59db4
[
    {
        "Id": "3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2",
        "Created": "2019-09-02T23:12:20.749337956Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 7890,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2019-09-03T13:07:04.200974867Z",
            "FinishedAt": "2019-09-02T23:21:29.857528986Z"
        },
        "Image": "sha256:9f38484d220fa527b1fb19747638497179500a1bed8bf0498eb788229229e6e1",
        "ResolvConfPath": "/var/snap/docker/common/var-lib-docker/containers/3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2/resolv.conf",
        "HostnamePath": "/var/snap/docker/common/var-lib-docker/containers/3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2/hostname",
        "HostsPath": "/var/snap/docker/common/var-lib-docker/containers/3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2/hosts",
        "LogPath": "/var/snap/docker/common/var-lib-docker/containers/3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2/3fec81b59db44e4a068d31c2b0d9a7dfe2b6bc844f923a9b0468e73b6a4780c2-json.log",
        "Name": "/elegant_varahamihira",
        "RestartCount": 0,
        "Driver": "aufs",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "docker-default",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "shareable",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/asound",
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": null,
            "Name": "aufs"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "3fec81b59db4",
            "Domainname": "",
            "User": "",
            "AttachStdin": true,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": true,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/bash"
            ],
            "Image": "centos",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20190305",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "1df65639324448174b4762ee49f23a4b66cdc0578820e8463d3064adf2689c8e",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/snap/docker/384/run/docker/netns/1df656393244",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "44727d0fc1ea1ff76ea4bd219b79edc4a150bc21f87278d9c9f2758c7c18485b",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "23e36244df276e1e48db78473b13afef4fd4ef64c3367bcb8905fb8e759b0f2c",
                    "EndpointID": "44727d0fc1ea1ff76ea4bd219b79edc4a150bc21f87278d9c9f2758c7c18485b",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
```
## 11. 查看服务日志
```
wangbb@wangbb-ThinkPad-T420:~/git/blogs$ sudo docker service logs --help

Usage:	docker service logs [OPTIONS] SERVICE|TASK

Fetch the logs of a service or task

Options:
      --details        Show extra details provided to logs
  -f, --follow         Follow log output
      --no-resolve     Do not map IDs to Names in output
      --no-task-ids    Do not include task IDs in output
      --no-trunc       Do not truncate output
      --raw            Do not neatly format logs
      --since string   Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
      --tail string    Number of lines to show from the end of the logs (default "all")
  -t, --timestamps     Show timestamps
```

## 参考
- [Configure logging drivers](https://docs.docker.com/config/containers/logging/configure/)
- [Docker日志收集最佳实践](https://www.cnblogs.com/jingjulianyi/p/6637801.html)
- [Docker 生产环境之日志 - 配置日志驱动程序](https://blog.csdn.net/kikajack/article/details/79575286)