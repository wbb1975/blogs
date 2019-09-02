# docker常用操作汇总
## 启动容器（docker）
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
  -d, --detach                         Run container in background and print container ID
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
      --log-driver string              Logging driver for the container
      --log-opt list                   Log driver options
      --mac-address string             Container MAC address (e.g., 92:d0:c6:0a:29:33)
  -m, --memory bytes                   Memory limit
      --memory-reservation bytes       Memory soft limit
      --memory-swap bytes              Swap limit equal to memory plus swap: '-1' to enable unlimited swap
      --memory-swappiness int          Tune container memory swappiness (0 to 100) (default -1)
      --mount mount                    Attach a filesystem mount to the container
      --name string                    Assign a name to the container     // 常用，给容器制定一个有意义的名字
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
      --restart string                 Restart policy to apply when a container exits (default "no")
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
wangbb@wangbb-ThinkPad-T420:~$ sudo docker run -i -t ubuntu:19.10 /bin/bash
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
## 附着到容器上（docker）
```
# CONTAINER可以使容器名字或者容器ID
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
## 删除docker images
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
## 删除docker containers
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
## 参考