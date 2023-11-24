---


title: "Kubernetes集群完整搭建步骤"
description: "kubernetes集群完整搭建步骤"
keywords: "kubernetes集群完整搭建步骤"

date: 2023-07-03T10:12:03+07:00
lastmod: 2023-07-09T10:17:52+08:00

categories:
  - 教程
tags:
  - k8s


# 原文作者
author: zzzi
# 开启数学公式渲染，可选值： mathjax, katex
# Support Math Formulas render, options: mathjax, katex
math: mathjax

# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1
# 关闭文章目录功能
# Disable table of content
#toc: false


# 原文链接
# Post's origin link URL
#link:
# 图片链接，用在open graph和twitter卡片上
# Image source link that will use in open graph and twitter card
#imgs:
# 在首页展开内容
# Expand content on the home page
#expand: true
# 外部链接地址，访问时直接跳转
# It's means that will redirecting to external links
#extlink:
# 在当前页面关闭评论功能
# Disabled comment plugins in this post
#comment:
#  enable: false

# 绝对访问路径
# Absolute link for visit
#url: "kubernetes集群完整搭建步骤.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>kubernetes集群完整搭建步骤

使用Ubuntu搭建k8s集群的完整步骤，包含常见错误解决办法

<!--more-->

## 前言

### k8s介绍

> 用于自动部署、扩展和管理“容器化应用程序”的开源系统

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307021520659.png" alt="image-20200406232838722" style="zoom:50%;" />

kubernetes，是一个全新的基于容器技术的分布式架构领先方案，是谷歌严格保密十几年的秘密武器----Borg系统的一个开源版本，于2014年9月发布第一个版本，2015年7月发布第一个正式版本。

kubernetes的本质是**一组服务器集群**，它可以在集群的每个节点上运行特定的程序，来对节点中的容器进行管理。目的是实现资源管理的自动化，主要提供了如下的主要功能：

- **自我修复**：一旦某一个容器崩溃，能够在1秒中左右迅速启动新的容器
- **弹性伸缩**：可以根据需要，自动对集群中正在运行的容器数量进行调整
- **服务发现**：服务可以通过自动发现的形式找到它所依赖的服务，想要什么服务就自动去寻找
- **负载均衡**：如果一个服务启动了多个容器，能够自动实现请求的负载均衡
- **版本回退**：如果发现新发布的程序版本有问题，可以立即回退到原来的版本
- **存储编排**：可以根据容器自身的需求自动创建存储卷

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307072040000.png" alt="img" style="zoom: 50%;" />

从上图中可以看出k8s的整体结构，一个k8s集群主要分为两类节点，一类是master节点，一类是工作节点，也就是主节点和从节点，具体的区别如下：

- 主节点主要用来管理集群，接受客户端的请求，安排容器的执行并且运行控制循环
- 从节点主要用来部署应用，听从主节点的调度

### 环境规划

#### 集群类型

kubernetes集群大体上分为两类：一主多从和多主多从

- 一主多从：一台master，多台node，搭建简单，但是master出现错误，整个集群不再可用
- 多主多从：多台master，多台node，搭建麻烦，但是容错率高

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307021520661.png" alt="image-20200404094800622" style="zoom:50%;" />

> 为了简单，本文中使用一主两从

#### 安装方式

目前生产部署Kubernetes 集群主要有两种方式：

**1.kubeadm（本文中采用）**

Kubeadm 是一个K8s 部署工具，提供kubeadm init 和kubeadm join，用于快速部署Kubernetes 集群。

官方地址：https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/

**2.二进制包**

从github 下载发行版的二进制包，手动部署每个组件，组成Kubernetes 集群。

Kubeadm 降低部署门槛，但屏蔽了很多细节，遇到问题很难排查。如果想更容易可控，推荐使用二进制包部署Kubernetes 集群，虽然手动部署麻烦点，期间可以学习很多工作原理，利于后期维护。

#### 主机规划

|    服务器ip    | 主机名 |    备注     |
| :------------: | :----: | :---------: |
| 222.27.255.211 | master | master node |
| 222.27.255.211 | node1  |  work node  |
| 222.27.255.211 | node2  |  work node  |

> 上面三台主机对外暴露端口不一样

## 安装步骤

### 连接服务器

为了部署一个kubernetes集群，首先需要通过远程工具连接集群中的每一个主机，下面提供master节点的连接方式，工作节点的连接方式类似：

1. 新建连接

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307100943125.png" alt="image-20230710094242869" style="zoom:50%;" />

> 按照服务器配置中的ip和端口号进行配置，之后点击用户身份验证

2. 配置用户名和密码

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307100943129.png" alt="image-20230710094323276" style="zoom:50%;" />

> 按照自己主机的用户名和密码连接到master主机上

3. 配置xshell

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031046702.png" alt="image-20230703104607658" style="zoom: 50%;" />

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031046769.png" alt="image-20230703104649715" style="zoom:50%;" />

> 按照如图方式配置xshell之后，实现左键选中，右键自动粘贴，提升效率

4. 连接成功

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916865.png" alt="image-20230703110826232" style="zoom:60%;" />

提示未知主机秘钥，点击"接受并保存"

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916871.png" alt="image-20230703105455606" style="zoom: 33%;" />

> 出现如图效果，证明连接成功

5. 配置主机名，方便辨认

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916872.png" alt="image-20230703110119090" style="zoom:50%;" />

> 至此master节点的基本配置完成，两个工作节点按照以上操作连接并修改自己的主机名

### 批量操作

为了简化操作步骤，避免重复输入，xshell提供了批量操作功能，实现一处输入，多处运行

1. 连接所有想要批量操作的主机

![image-20230703112104300](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916873.png)

2. 批量操作

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916874.png" alt="image-20230703112356694" style="zoom:50%;" />>

> 选择将发送键入到已连接的会话,此时可以批量管理k8s集群

3. 测试

> 将窗口**垂直**和**水平**分割之后，三个窗口可以显示在同一个屏幕中

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916876.png" alt="image-20230703112623950" style="zoom:50%;" />

> 确保所有主机的状态都是`off`，之后输入`hostname`查看之前的主机名配置是否生效，出现如图状态说明配置成功

4. 查看三台主机ip，输入`ifconfig`即可

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916877.png" alt="image-20230703124402502" style="zoom:50%;" />

> 可以看到三台主机处于同一个网段，子网掩码一致，后期节点通信时就是用下面的ip

| 主机名 |    主机ip    |   子网掩码    |
| :----: | :----------: | :-----------: |
| master | 192.168.1.24 | 255.255.255.0 |
| node1  | 192.168.1.25 | 255.255.255.0 |
| node2  | 192.168.1.27 | 255.255.255.0 |

### 环境初始化

为了安装k8s集群，将三台主机配置好后，还需要进行环境初始化

> 为了操作方便，以下操作全部都在root用户下进行，切换root用户的命令为：`su root` ，之后按照提示输入root用户的密码即可

1. 查看ubuntu版本

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916878.png" alt="image-20230703125722026" style="zoom:50%;" />

> 本次实验中采用`ubuntu 22.04.2 LTS`版本

2. 配置主机名解析，配置之后按照主机名即可访问对应主机

   > 主机的hosts文件路径在`/etc/hosts`中

~~~bash
#修改hosts文件
vim /etc/hosts

#在hosts文件中添加三项
192.168.1.24 master
192.168.1.25 node1 
192.168.1.27 node2

#vim中保存并退出
:wq
~~~

> 以上操作要确保hosts有写入权限
>
> 如果没有写入权限，执行`sudo chmod +w /etc/hosts`添加写入权限，或者直接切换到root用户，命令为`su root`，之后输入root用户的密码即可
>
> 在node1和node2中ping master出现下图中的效果说明配置成功

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916879.png" alt="image-20230703140650238" style="zoom:50%;" />

3. 同步系统时间，k8s要求集群中的节点时间必须一致，所以这里使用`chronyd`服务从网络同步时间

```bash
#启动chronyd服务
systemctl start chronyd
#设置服务开机自启
systemctl enable chronyd
#使用date验证节点的时间是否同步
date
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916880.png" alt="image-20230703134019481" style="zoom:50%;" />

4. 禁用`iptables`和`firewall`服务

   禁用iptables服务的原因是因为k8s和docker在运行的过程中会产生大量的iptables规则实现转发，为了不让这些规则与系统规则混淆，直接关闭iptables服务

   禁用firewall服务是为了节点之间通信时不会产生一些莫名其妙的错误

```BASH
#关闭firewall服务
systemctl stop firewall
systemctl disable firewall
#关闭iptables服务
systemctl stop iptables
systemctl disable iptables
```

5. 禁用selinux服务

```bash
#查看selinux的状态
getenforce
#如果输出结果为 "Enforcing"，则表示 SELinux 已启用
#如果为 "Permissive"，则表示 SELinux 处于宽容模式
#如果为 "Disabled"，则表示 SELinux 未启用。

#修改/etc/selinux/config
vim /etc/selinux/config
SELINUX=disabled
#重启系统
```

出现下图中的状态说明配置生效

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916881.png" alt="image-20230703141739168" style="zoom:50%;" />

6. 禁用swap分区

   启用swap分区会对系统的性能产生负面的影响，所以k8s要求禁用swap分区

```bash
#编辑/etc/fstab文件，注释掉其中的一行
vim /etc/fstab

#注释一行
#/swap.img      none    swap    sw      0       0
#vim中保存并退出
:wq
```

> 出现下图效果说明配置生效

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916882.png" alt="image-20230703142227517" style="zoom:50%;" />

7. 修改linux的内核参数

```shell
#修改linux的内核参数，添加网桥和地址转发功能

#新建/etc/sysctl.d/kubernetes.conf文件
vim /etc/sysctl.d/kubernetes.conf

#添加如下配置：
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1

#vim中保存并退出
:wq

#重新加载配置
sysctl -p

#加载网桥过滤模块
modprobe br_netfilter

#查看网桥过滤模块是否加载成功
lsmod | grep br_netfilter
```

出现以下效果说明配置成功

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916883.png" alt="image-20230703143437847" style="zoom:50%;" />

8. 配置ipvs功能

   在k8s中有两种代理模型，这里选择性能更高的ipvs

```shell
#安装ipset和ipvsadm
apt install -y ipset ipvsadmin

#添加需要加载的模块写入脚本文件
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF
#如果提示路径不存在，就需要先在此路径下创建ipvs.modules文件

#为脚本调价执行权限
chmod +x /etc/sysconfig/modules/ipvs.modules

#执行脚本文件
bash /etc/sysconfig/modules/ipvs.modules

#查看对应的模块是否加载成功
lsmod | grep -e ipvs -e nf_conntrack_ipv4
#如果修改了nf_conntrack_ipv4为nf_conntrack，这里也要修改
```

9. 重启服务器

   > 重启服务器查看selinux和swap配置是否生效

```shell
#立即重启
shutdown -r now

#查看selinux服务的状态
getenforce

#查看swap分区是否被禁用
free -m
```

出现下面的效果说明配置生效：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916884.png" alt="image-20230703153459146" style="zoom:50%;" />

### 安装必备组件

#### 安装docker

1. 切换镜像源

```shell
#指定国内镜像源
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#添加docker软件源
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

2. 安装docker

   > [彻底卸载docker旧版本](https://juejin.cn/s/ubuntu%20%E5%8D%B8%E8%BD%BDdocker)
   >
   > https://www.jianshu.com/p/688c677a281f

```shell
#卸载旧版本的docker，如果有的话
apt-get remove docker docker-engine docker-ce docker.io

#更新索引包
apt-get update

#安装以下包，以使 apt 可以通过 https 使用 repository
apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

#添加Docker官方的GPG密钥并更新索引包
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get update

#查看docker支持版本
apt-cache madison docker-ce

#安装docker,需要指定版本
apt-get install -y docker-ce=5:20.10.13~3-0~ubuntu-jammy docker-ce-cli=5:20.10.13~3-0~ubuntu-jammy  containerd.io=1.5.11-1

apt install 
#启动docker
systemctl start docker

#设置开机启动
systemctl enable docker
```

3. 添加一个配置文件

   docker默认使用cgroupfs作为Cgroup Drive，但是k8s推荐使用systemd，所以这里修改配置

```shell
#创建文件，如果不存在的话
mkdir /etc/docker

#添加配置
cat <<EOF > /etc/docker/daemon.json
{
	"exec-opts":["native.cgroupdrivers=systemd"],
	"registry-mirrors":["https://kn0t2bca.mirror.aliyuncs.com"]
}
EOF
```

使用`docker info | grep -i "Cgroup Driver"`查看配置是否生效

![image-20230703161654464](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916885.png)

使用`docker -v`查看docker版本

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307101923045.png" alt="image-20230710192304554" style="zoom:50%;" />

测试docker

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916887.png" alt="image-20230703185505255" style="zoom:50%;" />

#### 安装k8s组件

> [卸载k8s](https://blog.csdn.net/weixin_39589455/article/details/129160682)

1. 切换镜像源

```shell
#支持https传送
apt update && apt install -y apt-transport-https

#添加访问公钥
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 

#添加源
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

#更新缓存索引
apt update
```

2. 安装kubuadm、kubulet、kubuctl

```shell
#执行安装命令，需要指定版本
apt-get install -y kubelet=1.23.10-00 kubectl=1.23.10-00 kubeadm=1.23.10-00
```

3. 配置kubulet的cgroup

```shell
#编辑kubulet的cgroup，添加如下配置
vim /etc/sysconfig/kubelet

# 修改
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"
KUBE_PROXY_MODE="ipvs"

#开机自启
systemctl enable kubelet

#查看是否配置成功
systemctl list-unit-files --type=service|grep kubelet
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916888.png" alt="image-20230703164724593" style="zoom:50%;" />

<font color=red>**上面的步骤三台主机都需要操作**</font>

<font color=red>**上面的步骤三台主机都需要操作**</font>

<font color=red>**上面的步骤三台主机都需要操作**</font>

#### 集群初始化

<img src="https://raw.githubusercontent.com/BlackSunday001/mardown_blog_image/master/kubernetes/k8s-jiqun.png" alt="img" style="zoom:50%;" />

使用`kubeadm init`对集群初始化，kubeadm会自动下载apiserver，controller-manager等镜像，但是由于网络原因可能下载失败，所以提供一个其他的方法：

- 从阿里云下载对应镜像

1. 集群初始化（master节点操作）

```shell
#运行如下命令
# 由于默认拉取镜像地址k8s.gcr.io国内无法访问，这里需要指定阿里云镜像仓库地址
#新版才可以直接指定镜像仓库，旧版需要手动下载镜像，这里直接使用新版即可
kubeadm init \
  --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
  --apiserver-advertise-address=192.168.1.24 \
  --kubernetes-version v1.23.10\
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12 
  
#备注脚本，不用管
#!/bin/bash

images=(
    kube-apiserver:v1.27.3
    kube-controller-manager:v1.27.3
    kube-scheduler:v1.27.3
    kube-proxy:v1.27.3
    pause:3.9
    etcd:3.5.7-0
    coredns:1.10.1
)

for imageName in ${images[@]}
do
        docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
        docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
        docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done

```

出现如下效果证明集群初始化成功：

![image-20230706194515013](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235723.png)

2. 执行制定指令

   ```shell
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

3. 查看集群状态

   ![image-20230706194713757](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235724.png)

4. 配置主节点网络

   - 查看pod状态

     ![image-20230706205120539](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235725.png)

   - 新增kube-flannel.yml文件，文件下载地址[点这里](https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml)，这里的文件为k8s1.17+以上的版本使用的文件，具体安装方式[点这里](https://kubernetes.io/docs/concepts/cluster-administration/addons/)，选择`flannel`

     ![image-20230706204922808](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235726.png)

   > 由于github需要外网访问，所以手动下载，之后上传到服务器中
   >
   > 将文件放在/目录下即可
   >
   > 提供修改之后的文件

   ```shell
   apiVersion: v1
   kind: Namespace
   metadata:
     labels:
       k8s-app: flannel
       pod-security.kubernetes.io/enforce: privileged
     name: kube-flannel
   ---
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     labels:
       k8s-app: flannel
     name: flannel
     namespace: kube-flannel
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     labels:
       k8s-app: flannel
     name: flannel
   rules:
   - apiGroups:
     - ""
     resources:
     - pods
     verbs:
     - get
   - apiGroups:
     - ""
     resources:
     - nodes
     verbs:
     - get
     - list
     - watch
   - apiGroups:
     - ""
     resources:
     - nodes/status
     verbs:
     - patch
   - apiGroups:
     - networking.k8s.io
     resources:
     - clustercidrs
     verbs:
     - list
     - watch
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     labels:
       k8s-app: flannel
     name: flannel
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: flannel
   subjects:
   - kind: ServiceAccount
     name: flannel
     namespace: kube-flannel
   ---
   apiVersion: v1
   data:
     cni-conf.json: |
       {
         "name": "cbr0",
         "cniVersion": "0.3.1",
         "plugins": [
           {
             "type": "flannel",
             "delegate": {
               "hairpinMode": true,
               "isDefaultGateway": true
             }
           },
           {
             "type": "portmap",
             "capabilities": {
               "portMappings": true
             }
           }
         ]
       }
     net-conf.json: |
       {
         "Network": "10.244.0.0/16",
         "Backend": {
           "Type": "vxlan"
         }
       }
   kind: ConfigMap
   metadata:
     labels:
       app: flannel
       k8s-app: flannel
       tier: node
     name: kube-flannel-cfg
     namespace: kube-flannel
   ---
   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     labels:
       app: flannel
       k8s-app: flannel
       tier: node
     name: kube-flannel-ds
     namespace: kube-flannel
   spec:
     selector:
       matchLabels:
         app: flannel
         k8s-app: flannel
     template:
       metadata:
         labels:
           app: flannel
           k8s-app: flannel
           tier: node
       spec:
         affinity:
           nodeAffinity:
             requiredDuringSchedulingIgnoredDuringExecution:
               nodeSelectorTerms:
               - matchExpressions:
                 - key: kubernetes.io/os
                   operator: In
                   values:
                   - linux
         containers:
         - args:
           - --ip-masq
           - --kube-subnet-mgr
           - --iface=eno2 # master的ip在哪就写哪个
           command:
           - /opt/bin/flanneld
           env:
           - name: POD_NAME
             valueFrom:
               fieldRef:
                 fieldPath: metadata.name
           - name: POD_NAMESPACE
             valueFrom:
               fieldRef:
                 fieldPath: metadata.namespace
           - name: EVENT_QUEUE_DEPTH
             value: "5000"
           image: docker.io/flannel/flannel:v0.22.0
           name: kube-flannel
           resources:
             requests:
               cpu: 100m
               memory: 50Mi
           securityContext:
             capabilities:
               add:
               - NET_ADMIN
               - NET_RAW
             privileged: false
           volumeMounts:
           - mountPath: /run/flannel
             name: run
           - mountPath: /etc/kube-flannel/
             name: flannel-cfg
           - mountPath: /run/xtables.lock
             name: xtables-lock
         hostNetwork: true
         initContainers:
         - args:
           - -f
           - /flannel
           - /opt/cni/bin/flannel
           command:
           - cp
           image: docker.io/flannel/flannel-cni-plugin:v1.1.2
           name: install-cni-plugin
           volumeMounts:
           - mountPath: /opt/cni/bin
             name: cni-plugin
         - args:
           - -f
           - /etc/kube-flannel/cni-conf.json
           - /etc/cni/net.d/10-flannel.conflist
           command:
           - cp
           image: docker.io/flannel/flannel:v0.22.0
           name: install-cni
           volumeMounts:
           - mountPath: /etc/cni/net.d
             name: cni
           - mountPath: /etc/kube-flannel/
             name: flannel-cfg
         priorityClassName: system-node-critical
         serviceAccountName: flannel
         tolerations:
         - effect: NoSchedule
           operator: Exists
         volumes:
         - hostPath:
             path: /run/flannel
           name: run
         - hostPath:
             path: /opt/cni/bin
           name: cni-plugin
         - hostPath:
             path: /etc/cni/net.d
           name: cni
         - configMap:
             name: kube-flannel-cfg
           name: flannel-cfg
         - hostPath:
             path: /run/xtables.lock
             type: FileOrCreate
           name: xtables-lock
   
   ```

   - 运行下面的命令配置集群

     ```shell
     kubectl apply -f kube-flannel.yml
     ```

   ![image-20230706205931706](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235727.png)

   > 显示created和configured即可

   - 监控应用的进度

     ```shell
     watch kubectl get pods --all-namespaces
     ```

   ![image-20230706220233480](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235728.png)

5. 显示如下效果说明网络配置成功

   ![image-20230706221722496](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235729.png)

6. 将工作节点加入集群

![image-20230706195107562](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235730.png)

```shell
kubeadm join 192.168.1.24:6443 --token zn83su.rnsgtjxplhpzb94c \
	--discovery-token-ca-cert-hash sha256:c94a061c9716ed6f2ac65d0c8a4558efc7f0b25fd6684b13619e500d58dec16c
```

7. 显示如下效果证明节点加入成功

   ![image-20230707113652154](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235731.png)

看到节点的状态为NotReady，等待节点自动加载完毕，会显示Ready，约三分钟后，显示如下效果：

![image-20230707113848901](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235732.png)

#### 环境测试

1. 部署nginx

在集群中部署一个nginx，查看集群是否安装成功

> 操作时，只需要通过master执行即可，k8s自动管理工作节点

```shell
#部署nginx
kubectl create deployment nginx --image=nginx

#nginx的端口向外暴露
kubectl expose deployment nginx --port=80 --type=NodePort

#查看nginx是否启动成功
kubectl get pods
kubectl get service
```

![image-20230707114756123](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235733.png)

2. 查看nginx部署情况

```shell
#查看nginx被部署到了哪个节点上：kubectl get pod <pod-name> -o wide
kubectl get pod -o wide

#查看访问是否成功
```

> 查看nginx被部署到了**node2**节点上

![image-20230707121814038](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235734.png)

可以看到集群的变化，对外暴露端口为32737，也就是说，使用`node2`的ip+32737就可以访问到节点内部80端口对应的nginx，测试如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235735.png" alt="image-20230707122113771" style="zoom:50%;" />

> 至此k8s集群部署完毕

## 错误解决方法

1. 同步节点时间时使用chronyd服务显示以下错误

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916889.png" alt="image-20230703132932388" style="zoom:50%;" />

```shell
#首先查看服务列表中有没有这个服务
systemctl list-unit-files --type=service|grep chronyd
#如果有的话，执行下面的命令
systemctl daemon-reload
#如果没有的话，执行下面的命令,之后再次查看是否有这个服务
sudo apt install -y chrony
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916890.png" alt="image-20230703133459335" style="zoom:50%;" />

2. 查看selinux状态出现以下错误:

   ![image-20230703140821276](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916891.png)

   直接按照提示安装`selinux-utils`即可

3. 运行ipvs.modules脚本显示下面的错误

![image-20230703150206722](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307031916892.png)

> 版本出了问题，此时将脚本中的`nf_conntrack_ipv4`改成`nf_conntrack`即可

4. 集群初始化安装镜像时出现以下错误

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235736.png" alt="image-20230704151656475" style="zoom:50%;" />

> 确保当前用户是root，如果还是出现错误，重启docker服务即可：`systemctl restart docker`

5. 集群初始化使用kubeadm init出现以下错误

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235737.png" alt="image-20230704153749023" style="zoom:50%;" />

   > 更换`kubernetes-version`的版本

6. 如果kubeadm init提示如下信息

![image-20230704160510626](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235738.png)

说明docker版本不兼容，需要安装指定版本docker

7. kubeadm初始化时显示如下错误

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235739.png" alt="image-20230704204530312" style="zoom:50%;" />

> 依次执行下面的命令

```shell
#删除旧的containerd
apt remove containerd

#更新存储库
apt update

#安装新的containerd
apt install containerd.io

#删除默认配置文件
rm /etc/containerd/config.toml

#重新启动containerd
systemctl restart containerd
```

8. kubeadm init出现以下问题

![image-20230704224759111](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235740.png)

```shell
#执行下面的命令
kubeadm reset
```

9. kubeadm init出现以下问题

![image-20230705103616882](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235741.png)

直接删除对应的文件即可

10. k8s的多网卡节点之间通信出现问题

    存在多个网卡时，k8s不知道以哪个网卡进行通信，需要手动指定，在网卡配置时，需要在配置文件中更改参数，配置文件的下载地址[点这里](https://github.com/flannel-io/flannel#deploying-flannel-manually)

    ![image-20230710092306335](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307100943131.png)

    > iface指定通信的网卡

10. kubeadm init出现以下问题

![image-20230705123648049](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235742.png)

运行以下命令之后重新运行kubeadm init

```shell
rm -rf /etc/containerd/config.toml
systemctl restart containerd
```

> 如果还是不行，尝试重装k8s，确保之前的版本完全卸载，卸载教程[点这里](https://blog.csdn.net/weixin_39589455/article/details/129160682)

11. apt update一直连接的是google镜像源

![image-20230706193502767](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235743.png)

> 进入/etc/apt/sources.list.d目录下

查看目录结构

![image-20230706193552285](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235745.png)

只保留上面**两个**文件即可

12. 安装docker报错

![image-20230706193649928](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235746.png)

> 1.查看系统版本

![image-20230706193918087](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235747.png)

> 2. 发现系统的codename为jammy，此时下载的docker版本也需要有jammy后缀

![image-20230706194020883](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235748.png)

> 上述操作保证docker被完全卸载

13.初始化k8s集群报错，首先检查docker与k8s的版本[对应关系](https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG)，例如，以k8s  v1.21为例：

![img](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307061941226.png)

![img](https://img2020.cnblogs.com/blog/553409/202106/553409-20210615114639262-763119090.png)

> 发现支持的最新docker版本为20.10，所以不要超过这个版本

14. 安装docker指定不了版本，提供一个笨办法
    - 先安装docker-ce并指定版本，此时docker-ce-cli为最新版本
    - 之后使用aptitude降级

15. kubeadm join时卡在

    ![image-20230706195409905](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235749.png)

    > master的6443端口未开放，打开master的6443端口即可正常加入

16. kubectl get cs显示unhealthy

    ![image-20230706224949054](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235750.png)

    > 需要修改配置文件，文件路径为：`/etc/kubernetes/manifests`

分别将`kube-scheduler.yaml    kube-controller-manager.yaml`

文件中的`port=0`注释掉即可

![image-20230706225055887](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235751.png)

17. 无法通过ip+端口的方式访问部署的应用

    > 先查看部署的应用在哪个节点上，之后通过节点ip+端口的方式访问
    >
    > 以nginx为例，
    >
    > 1. 查看nginx的名称（nginx-65c4bffcb6-zphwj）
    >
    > 2. 找到nginx部署在哪个节点上（node2）
    >
    > 3. 访问（192.168.1.27:32737），这个端口号为集群内部端口号
    >
    >    可以通过`kubectl get service`获得

    ![image-20230707123038668](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235752.png)

    ![image-20230707123159437](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307071235753.png)

## 总结

k8s部署过程中存在诸多问题，最常见的问题如下：

1. docker无法指定版本，k8s与docker之间有版本对应关系
2. k8s节点之间通信对于多网卡设备来说需要指定网卡
3. k8s部署时卡在某一步不动

> 以上问题按照教程还不能完美解决，建议重装对应组件
