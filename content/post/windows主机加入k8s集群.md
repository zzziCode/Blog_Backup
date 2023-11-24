---
title: "Windows主机加入k8s集群"
description: "windows主机加入k8s集群"
keywords: "windows主机加入k8s集群"

date: 2023-07-10T19:32:59+08:00
lastmod: 2023-07-10T19:32:59+08:00

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
#url: "windows主机加入k8s集群.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>windows主机加入k8s集群

本文在[Kubernetes集群完整搭建步骤](https://zzzicode.github.io/post/kubernetes%E9%9B%86%E7%BE%A4%E5%AE%8C%E6%95%B4%E6%90%AD%E5%BB%BA%E6%AD%A5%E9%AA%A4/)的基础上，将windows主机当成工作节点加入到k8s集群中

<!--more-->

## 前言

k8s集群中现在已有一个master节点，两个工作节点，三个节点的linux系统版本为`Ubuntu 22.04.2 LTS`，windows主机加入集群之后，当成一个工作节点，主机规划如下：

| 主机名 |    主机ip    |   子网掩码    |
| :----: | :----------: | :-----------: |
| master | 192.168.1.24 | 255.255.255.0 |
| node1  | 192.168.1.25 | 255.255.255.0 |
| node2  | 192.168.1.27 | 255.255.255.0 |
| node3  | 192.168.1.26 | 255.255.255.0 |

linux节点中，docker版本为`v19.03.3`，kubenetes版本为`v1.23.10`

## 步骤

### 集群预处理

#### 改变已有配置

1. flannel开启ipv4流处理（所有节点）

本集群中使用flannel作为集群节点之间通信的网络插件，为了让windows加入已有的k8s集群，需要使用flannel需要为iptables开启IPv4流处理，现有集群中所有的节点都要操作：

```shell
# 为iptables开启IPv4流处理（集群搭建过程中已开启则略过此步骤）
sysctl net.bridge.bridge-nf-call-iptables=1
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149221.png" alt="image-20230710195746664" style="zoom: 50%;" />

2. 配置docker镜像源（所有节点）

之前搭建集群时，docker的镜像加速已经配置完成，所以这里不再配置：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149228.png" alt="image-20230710195907427" style="zoom:50%;" />

3. 修改kube_flannel.yaml文件中的配置（只在master节点）

   之前搭建集群时，从这里下载了对应的kube-flannel.yml文件，并向其中添加了指定网卡的参数，此时为了将windows节点加入集群中，并与windows中的flannel进行通信，需要再次配置文件中的参数

   > 具体修改的参数如下

```yaml
#修改的参数
net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan",
        "VNI": 4096, # 新增
        "Port": 4789 # 新增
      }
    }
    
#修改完参数之后，重新部署flannel
kubectl delete -f kube-flannel.yaml
kubectl apply -f kube-flannel.yaml
```

> 参数修改如下

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149230.png" alt="image-20230710200420211" style="zoom:50%;" />

> 重新部署flannel

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149231.png" alt="image-20230710200613821" style="zoom:50%;" />

#### 新增配置

1. 安装兼容windows的proxy，因为服务器无法连接外网，所以可以在自己的电脑上连接外网将对应文件下载下来，之后将文件上传到服务器即可，对应文件[点这里](https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/kube-proxy.yml)

   ```shell
   #如果服务器可以连接外网，那么使用下面的命令下载对应文件
   wget https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/kube-proxy.yml
   
   #修改kubernetes版本
   #部署proxy
   ```

   将kube-proxy.yml文件中的image参数修改为自己的kubenetes版本，这里修改为`v1.23.10`

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149232.png" alt="image-20230711221627153" style="zoom:50%;" />

   修改完之后，就可以部署proxy，命令为：`kubectl apply -f kube-proxy.yml`

   ![image-20230710202511227](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149233.png)

   > 注意文件后缀是yml，而不是yaml

   <font color=red>部署完成之后查看节点的变化</font>

   ```shell
   kubectl get daemonset -A
   kubectl get pod -A
   ```

   ![image-20230710202707806](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149234.png)

2. 安装部署flannel-overlay.yml，文件下载地址[点这里](https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/flannel-overlay.yml)

   如果可以服务器可以连接外网，可以直接使用下面的命令部署

   部署时需要注意集群节点之间通信的网卡是谁，flannel-overlay.yml文件默认通信的网卡为Ethernet，所以这里我们将windows对应的网卡修改为**Ethernet**

   ```shell
   #可连接外网时
   kubectl apply -f https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/flannel-overlay.yml
   
   #无法连接外网时，先下载文件，新建文件，复制粘贴文件的内容
   kubectl apply -f flannel-overlay.yml
   
   #对应通信网卡的代码如下，如果windows通信的网卡名称不是Ethernet，则需要修改：
   wins cli process run --path /k/flannel/setup.exe --args "--mode=overlay --interface=Ethernet" # 如果不是，需要修改为Windows的默认网卡名称
   wins cli route add --addresses 169.254.169.254
   wins cli process run --path /k/flannel/flanneld.exe --args "--kube-subnet-mgr --kubeconfig-file /k/flannel/kubeconfig.yml" --envs "POD_NAME=$env:POD_NAME POD_NAMESPACE=$env:POD_NAMESPACE"
   ```

修改网卡为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149235.png" alt="image-20230712202250539" style="zoom:50%;" />

### windows安装docker

1. 下载离线安装包，下载地址[点这里](https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-13.zip)

   下载完整之后解压到**C:\Program Files\Docker**中，没有Docker文件夹就新建，之后在C:\ProgramData\docker中创建一个config文件夹，文件夹中新建一个daemon.json文件，文件内容为：

   ```json
   {
   "insecure-registries":[]
   }
   ```

   最终的文件结构为：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149236.png" alt="image-20230712213240722" style="zoom:50%;" />

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149237.png" alt="image-20230711152214461" style="zoom: 50%;" />

2. 添加环境变量

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149238.png" alt="image-20230711144509139" style="zoom:50%;" />

点系统信息进入下一个页面

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149239.png" alt="image-20230711144547673" style="zoom: 33%;" />

点进高级系统设置，环境变量进入环境变量的配置

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149240.png" alt="image-20230711144637514" style="zoom:50%;" />

双击Path，新增如下内容：

```shell
C:\Program Files\Docker
```

3. 注册dockerd服务，使用管理员身份进入CMD

   ```shell
   cd C:\Program Files\Docker  # 进入dockerd.exe所在目录路径
   dockerd --register-service  # 将dockerd 注册为服务
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149241.png" alt="image-20230711144819840" style="zoom:50%;" />

4. 安装containers功能

   打开服务器管理器，如果桌面上没有服务器管理器，在开始菜单就能找到

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149242.png" alt="image-20230711145617811" style="zoom:33%;" />

   打开之后按下图选择，一路下一步即可，到了功能一栏需要<font color=red>暂停</font>，选择一个功能

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149243.png" alt="image-20230711145521928" style="zoom: 33%;" />

需要选中containers，之后选中**安装**即可，静待几分钟，可选中**自动重启**，让系统自动配置

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149244.png" alt="image-20230711145733217" style="zoom: 50%;" />

显示下图内容代表安装成功

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149245.png" alt="image-20230711150917678" style="zoom:33%;" />

5. 启动docker服务

   在运行面板中输入`services.msc`，即可打开服务管理

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149246.png" alt="image-20230711151225865" style="zoom:33%;" />

   之后打开docker服务，显示下面的内容说明服务正常运行

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149247.png" alt="image-20230711151339842" style="zoom: 33%;" />

   在powershell中输入docker info显示下面的内容证明docker安装成功

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149248.png" alt="image-20230711153233180" style="zoom:50%;" />

   6. 运行一个容器测试

      <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149249.png" alt="image-20230711152743814" style="zoom:50%;" />

### windows启动linux容器

1. 启用LinuxKit系统中的参数

   ```shell
   # powershell执行以下命令
   [Environment]::SetEnvironmentVariable("LCOW_SUPPORTED", "1", "Machine")
   ```

   ![image-20230711151727762](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149250.png)

2. 自动配置`daemon.json`文件

   ```shell
   #  powershell执行以下命令
   
   $configfile = @"
   {
       "experimental": true
   }
   "@
   
   $configfile|Out-File -FilePath C:\ProgramData\Docker\config\daemon.json -Encoding ascii -Force
   ```

   ![image-20230711152427267](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149251.png)

3. 手动配置镜像源，打开daemon.json文件，添加如下内容，注意有一个**逗号**，之后重启docker

   ```shell
   #向daemon.json添加如下内容
   "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://registry.docker-cn.com",
       "http://hub-mirror.c.163.com",
       "https://mirror.ccs.tencentyun.com"
   ]
   
   #重启docker
   Restart-Service docker
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149252.png" alt="image-20230711153513850" style="zoom:50%;" />

   4. 配置Linux Kernel，配置文件下载[点这里]( https://github.com/linuxkit/lcow/releases )，下载最新版即可，下载完成之后解压到`C:\Program Files\Linux Containers`，没有这个文件夹就新建，最终的文件结构为：

      <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149253.png" alt="image-20230711160834684" style="zoom:50%;" />

      之后可以正常在windows节点上运行linux的容器，下面做一个测试

      ```shell
      #在后台运行tomcat容器
      docker run -d -P --platform=linux --name tomcat01 tomcat
      ```

      <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149254.png" alt="image-20230711161943483" style="zoom:50%;" />

      可以看到在windows上可以进入linux环境，并且容器对外暴露的端口为50462

      使用127.0.0.1:50462可以访问到部署的tomcat容器：

      <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149255.png" alt="image-20230711162052829" style="zoom:50%;" />

### windows安装补丁

直接检查windows更新，自动更新即可

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149256.png" alt="image-20230711155010332" style="zoom:50%;" />

### windows安装k8s

1. 下载所需文件

   - PrepareNode.ps1部署脚本文件下载[点这里](https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/PrepareNode.ps1)
   - wins.exe下载[点这里](https://github.com/rancher/wins/releases/download/v0.0.4/wins.exe)
   - hns.psm1脚本文件下载[点这里](https://github.com/Microsoft/SDN/raw/master/Kubernetes/windows/hns.psm1)，之后显示一个代码页面，将页面中的内容复制到一个hns.psm1文件中即可
   - nssm-2.24.zip下载[点这里](https://k8stestinfrabinaries.blob.core.windows.net/nssm-mirror/nssm-2.24.zip)
   - Kubernetes二进制文件下载[点这里](https://dl.k8s.io/v1.23.10/kubernetes-node-windows-amd64.tar.gz)，解压之后只保留kubeadm.exe和kubelet.exe

   下载完成之后，新建文件夹C:\k，将上述文件先备份，安装错误时可以直接使用备份文件恢复，我备份到了C:\backup中，之后将上述文件分别存储好，形成的文件结构为：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149257.png" alt="image-20230711164743448" style="zoom:50%;" />

2. 处理文件

   - 编辑PrepareNode.ps1文件，将`DownloadFile`函数的调用代码全部用`#`注释掉

     这里注释的原因是因为我们已经手动下载了需要的文件，不再需要自动下载，防止报错

   - 将`nssm-2.24.zip`文件重命名为`nssm.zip`

   - 取出k8s二进制包解压之后的`kubeadm.exe`和`kubelet.exe`文件到当前目录下

   形成的文件结构为：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307122149258.png" alt="image-20230711165128004" style="zoom:50%;" />

3. 部署k8s

   ```shell
   # 1、以管理员运行PowerShell，并将路径切换到C:\k
   cd C:\k\
   
   # 2、执行部署脚本（如果版本不同，需要修改版本参数）
   .\PrepareNode.ps1 -KubernetesVersion v1.23.10
   
   ## 注意，PrepareNode.ps1是Powershell的一个执行脚本，Windows Server会对所有可执行脚本进行认证，这个脚本不是官方的，所以会提示"未对文件PrepareNode.ps1进行数字签名。无法在当前系统上运行该脚本。"，如果出现该提示，需要执行以下命令为脚本赋予权限，如下：
   
   Set-ExecutionPolicy -ExecutionPolicy UNRESTRICTED
   
   # 执行该命令后，会出现提示，输入"A"（全是）后，重新执行第2步命令
   # 如果执行过程中，出现错误，则需要按照文末的方式，重置Windows Server
   ```

4. 重新部署的代码

   ```shell
   #删除名称为host的docker network配置
   docker network rm host
   
   # 停止并删除kubelet
   sc.exe stop kubelet
   sc.exe delete kubelet
   
   # 停止并删除rancher-wins
   sc.exe stop rancher-wins
   sc.exe delete rancher-wins
   
   #重启docker服务
   Restart-Service docker
   
   #删除etc、run、var、opt文件夹，如果存在的话
   
   #将nssm.zip重新复制一份到k文件夹中，同时删除StartKubelet.ps1文件
   
   #重新运行命令
   ```
