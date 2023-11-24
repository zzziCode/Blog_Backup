---
title: "Linux学习笔记"
description: "linux学习笔记"
keywords: "linux学习笔记"

date: 2023-05-28T21:01:03+08:00
lastmod: 2023-05-28T21:01:03+08:00

categories:
  - 学习笔记
tags:
  - linux

# 可选配置
# 原文作者
# Post's origin author name
author: zzzi
# 关闭文章目录功能
# Disable table of content
toc: true
# 开启数学公式渲染，可选值： mathjax, katex
# Support Math Formulas render, options: mathjax, katex
#math: mathjax


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
#url: "linux基础篇.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> linux学习笔记

linux系统的基本结构、编辑器、一些基本的配置以及linux的实操和扩展，包括文件管理、用户权限、磁盘管理、进程管理以及shell编程

<!--more-->

## linux安装

简单的东西只需要下一步即可，但是分区需要注意,以及安装时需要选择GUI的服务器，linux才带桌面，不能默认最小安装

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249735.png" alt="image-20230530133136126" style="zoom:50%;" />

### 分区

linux中磁盘分区称为挂载，一个分区就是一个挂载点

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305282153232.png" alt="image-20230528215327141" style="zoom: 67%;" />

之后进入分区界面，然后设置启动分区和其他分区

1. **启动分区**：`/boot`

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305282158229.png" alt="image-20230528215807161" style="zoom:67%;" />

   启动分区必须选择`/boot`挂载点，之后文件系统选择`xfs`，

2. **交换分区**：`swap`

当linux的内存占用率较高时，将内存中暂时不需要使用的应用程序移动到硬盘的交换区，然后将急需运行的程序调用到新空出来的空间

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305282203742.png" alt="image-20230528220308688" style="zoom:67%;" />

此时文件系统的格式直接指定为swap且不能修改

3.剩余分区：`/`

将硬盘剩余容量挂载到根上

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305282205804.png" alt="image-20230528220509748" style="zoom:67%;" />

配置完成之后，系统从`/boot`启动，文件存储在`/`下，内存容量不够时从`swap`中交换

## 基础篇

直接在终端中进行一系列操作，在/下有一系列的文件，文件中还有文件，形成一棵树状结构，linux中一切皆文件

### 系统结构

了解系统根目录下有哪些东西，都有什么用

切换到根目录：`cd /` 

bin目录中存放的全是可执行的命令，比如cd ls等

lib中存放的全是系统运行所必须的文件，类似于win中的System32

usr中包含用户所有的应用程序和所需要的数据

etc中存放的是系统管理所需要的配置文件

opt是给应用程序留的空间

srv是给系统提供服务的信息

sys是系统文件夹  

### 文本编辑器

当linux中需要修改文件时，需要使用文本编辑器取修改，也可以使用图形化界面编辑，但不够高效，linux中最著名的文本编辑器就是vim

切换输入法的快捷键：win+空格

输入时可以按tab自动补全

1. 使用vim编辑文件：vim+文件名
2. 退出编辑：`：q`

#### vim的三种模式

1. 一般模式：不能直接编辑文本，可以删除，复制，粘贴，按`esc`回到一般模式

   `num+yy`：复制num行

   `y+$`：复制从当前光标位置到行尾的内容

   `y+^`：复制当前光标到行头的内容

   `^：`到行头

   `$`：到行尾

   `y+w`：复制当前单词（光标到下一个空格之前）

   `num+p`：将剪切板中的内容粘贴num次

   `num+dd`：删除num行

   `u`：撤销操作，可以不停u一直撤销

   `x`：剪切当前光标的内容

   `gg`：跳转到第一行

   `L或G`：跳转到最后一行

   `num+G`：跳转到某一行

   **$ ^ w可以和删除配合使用**

2. 编辑模式：编辑文本，按一个小写的`i`

3. 命令模式：运行命令行，按一个`/`或者`：`

   `:set nu`#设置行号

 <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305290959844.png" alt="image-20230529095938781" style="zoom:50%;" />

在编辑模式下编辑，在命令模式下保存

### 网络配置

win查看网络ip地址：`ipconfig`

linux查看网络ip地址：`ifconfig`

之后互相ping看是否连通

#### 桥接模式

 Bridge  桥"就是一个主机，这个机器拥有两块网卡，分别处于两个局域网中，同时在"桥"上，运行着程序，让局域网A中的所有数据包原封不动的流入B，反之亦然。这样，局域网A和B就无缝的在链路层连接起来了，在桥接时，VMWare网卡和物理网卡应该处于**同一IP网段**，当然要保证两个局域网没有冲突的IP.   

VMWare 的桥也是同样的道理，只不过，本来作为硬件的一块网卡，现在由VMWare软件虚拟了！当采用桥接时，VMWare会虚拟一块网卡和真正的物理网卡就行桥接，这样，发到物理网卡的所有数据包就到了VMWare虚拟机，而由VMWare发出的数据包也会通过桥从物理网卡的那端发出。   所以，如果物理网卡可以上网，那么桥接的软网卡也没有问题了。其网络结构如下图所示：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306052227248.webp" alt="深入理解VMware虚拟机网络通信原理_深入理解VMware虚拟机网络通信原理_07" style="zoom:67%;" />

相当于虚拟机的请求通过物理主机发送到外部网络，VMware虚拟机的网卡与物理主机的网卡所对应的网络地址处在同一网段，这样才能保证虚拟机和物理主机之间互通

但是因为虚拟机和主机处于同一ip网段，所以相同网段内的其他物理主机也可以访问虚拟机

#### NAT模式

NAT技术应用在internet网关和路由器上，比如192.168.0.123这个地址要访问internet，它的数据包就要通过一个网关或者路由器，而网关或者路由器拥有一个能访问internet的ip地址，这样的网关和路由器就要在收发数据包时，对数据包的IP协议层数据进行更改（即  NAT），以使私有网段的主机能够顺利访问internet。此技术解决了IP地址稀缺的问题。同样的私有IP可以网关NAT  上网。  

VMWare的NAT上网也是同样的道理，它在主机和虚拟机之间用软件伪造出一块网卡，这块网卡和虚拟机的ip处于一个地址段。同时，在这块网卡和主机的网络接口之间进行NAT。虚拟机发出的每一块数据包都会经过虚拟网卡，然后NAT，然后由主机的接口发出。   虚拟网卡和虚拟机处于一个地址段，虚拟机和主机**不在同一个**地址段，主机相当于虚拟机的网关

![image-20230530095048963](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249743.png)

在图中看，所有的虚拟机处于一个网段，由DHCP服务器分配ip地址，访问网络时需要使用NAT地址转换ip地址 

此时VM虚拟机的网络地址与物理主机的网络地址不在同一网段中，虚拟机想访问外网，通过NAT服务器将其转化成物理主机的ip地址就可以，但是此时物理主机还无法访问虚拟机

所以解决办法就是给物理主机再分配一个网卡，此时这个分配的网卡与虚拟机处于同一个网段，在网络配置中成为`vmnet8`，此时物理主机通过这个网卡与虚拟机进行通信

此时由于与物理主机处于同一ip网段的其他主机与虚拟机不处于同一网段，所以无法访问虚拟机，但是当前物理主机由于有一个虚拟出的与虚拟机处于同一网段的网卡，所以可以相互访问

在本机中的配置如下：

![image-20230531121026829](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249744.png)

主机原有的ip地址是`192.168.2.1`，虚拟机的ip地址是192.168.78.255，不处于同一网段，主机为了访问虚拟机，虚拟出一个vmnet8网卡，地址为`192.168.78.1`，就是为了专门与虚拟机通信

虚拟机通过NAT网络地址转换，转换成与主机同一网段的IP地址，通过主机访问外网

#### 仅主机模式

相比于NAT模式，只是将NAT服务器换成了交换机，此时无法转换网络地址，物理主机模拟一张与虚拟机处于同一ip网段的网卡

此时虚拟机和物理主机之间可以通信，因为有一张虚拟网卡连接到了虚拟机所在的网段中，但是没有ip地址转换，所以无法访问外网

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061509204.webp" alt="img" style="zoom:67%;" />

#### 修改静态ip

虚拟机使用NAT模式时，默认使用DHCP自动分配ip地址，此时可能会出现虚拟机的ip'地址动态变化的问题，对于后期配置不太方便，所以我们可以指定一个静态ip，只要这个静态ip所处的网段与物理主机的`vmnet8`所处的网段在一起即可。

修改后虚拟机通过VMware虚拟的NAT地址转换服务访问物理主机，物理主机通过`vmnet8`访问虚拟机

1. 查看虚拟机所处的网段

   ![image-20230530105011520](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249745.png)

​		配置时将ip地址配置在同一个网段中即可

2. 配置静态ip，使用vim修改配置文件

   ![image-20230530105444939](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249746.png)

   将其修改为（不能保存提示只读的话就切换用户，`su root`）：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249747.png" alt="image-20230531121204463" style="zoom:67%;" />

   `dhcp`改为`static`，然后在后面添加几行，重启网络服务之后查看网络ip地址

   ![image-20230530114441348](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249748.png)

   修改成功，尝试`ping`
   
   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249749.png" alt="image-20230530135853282" style="zoom: 67%;" />
   
   ![image-20230530140054969](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249750.png)
   
   在物理主机中的hosts文件中增加：`192.168.78.100 centos`就可以使用别名访问虚拟机
### 远程登录

使用ssh指定登录的身份和主机名，确认之后输入密码就可以连接上，最后使用`exit`退出系统

![image-20230530142517369](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249751.png)

   还可以设置xshell登录，下载完成之后，配置好主机名和密码，之后就可以在xshell中远程连接linux

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249752.png" alt="image-20230530144128743" style="zoom:50%;" />

###    系统管理

linux中的守护进程在开机时就会启动，就像是windows中计算机管理下的服务，为系统的运行提供支持，并在后台运行，用户感觉不到他们的存在，也可以称为系统服务，这些额系统服务可以手动的控制开机自启动

在centos7中，启动服务的命令是：`systemctl start|stop|restart|status 服务名`

ccentos7所有的守护进程存在与：`/usr/lib/systemd/`中

![image-20230530150055541](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249753.png)

使用`systemctl`控制服务的开机自启动  ，使用`status`查看状态，使用`disable`停止服务的运行

例如，关闭系统的防火墙：`systemstl stop firewalld.service` 

### 关机 

```
shutdown//一分钟之后关机
shutdown -c//取消关机
shutdown now//立马关机
shutdown +时间//在指定时间关机
//关机之前执行sync命令，将缓存中的数据存入内存中
```

## 实操篇

本节介绍一些linux常用的命令，这些命令由shell进行解释，最终交给linux内核进行执行

### 帮助命令

#### man&help

`man[命令或配置文件]`就可以显示当前文件的帮助信息，但是这个文件或者命令必须是外部命令，内置命令的帮助信息由~给出

内置命令是在系统加载之后随着shell一起加载的命令，常驻在系统内存中，其他的都称为外部命令

使用`type+命令`判断当前命令属于内置命令还是外部命令

![image-20230531123834047](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249754.png)

`shell内嵌`代表当前命令是内置命令

给出帮助信息之后，主要看的就是显示出的描述信息，他给出所有参数的含义。

help是查看系统内置命令的指令，给出的帮助信息是英文版，并且只能给出内置命令的帮助信息

> 推荐使用`命令 --help`的方式查看外部命令的帮助信息，`help 命令`查看内置命令的帮助信息

####  快捷键

```
ctrl+c //停止进程
ctrl+l//将屏幕向上推，类似于清屏
tab//按两次可以查看提示信息
上下键//查看历史命令
```

### 文件目录类命令

对于文件的操作无非是查看路径，找到对应文件，找到之后进行修改（vim），或者复制文件，创建文件夹等。。。

#### pwd

打印当前的工作目录的绝对路径

![image-20230531130315122](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249755.png)

#### cd

进入一个给定路径，即使路径与当前路径不在文件树中的一条路径中，只要给定了绝对路径，就可以跳转，但是给定相对路径就不行，`../`代表上级目录

![image-20230531130516174](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249756.png)一个比较好用的指令是`cd -`,可以切换到上一次所在的目录，当需要在两个目录中来回跳转，同时两个目录的在文件树中的距离较远时，就可以使用这个命令

![image-20230531131128568](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249757.png)

可以在`/etc/sysconfig/network-scripts`和`/bin`目录中来回切换

#### ls

列举出当前目录中的所有文件

`ls -a`可以列举出所有的文件，包括隐藏文件（以`.`开头的），当前目录，上级目录

![image-20230531131615275](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249758.png)`ls -l（ll)`可以将所有文件的详细属性列出来

![image-20230531131939878](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249759.png)

#### mkdir&rmdir

`mkdir`是在当前目录下创建一个空文件夹，例如新建一个a，也可以直接指定路径，在指定路径下面创建一个文件夹

```bash
mkdir a		#在当前目录下创建一个文件夹
mkdir a b c	#在当前目录下创建三个文件夹
mkdir /a	#在根目录/下创建一个文件夹
mkdir d d/e d/e/f	#先创建一个d，在d下面创建e，然后在e下面创建f，一层一层向下
#上面的命令可以简化成下面的命令
mkdir -p d/e/f#指定路径下创建文件夹，没有指定路径的话就开辟一个，p是递归的进行
```

、<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249760.png" alt="image-20230531201001191" style="zoom:67%;" />

`rmdir`是删除指定的目录

```bash
rmdir a#删除a
rmdir d/e/f d/e d#一层一层向下删除，和一层一层向下创建相反
#上面的命令可以简化成下面的命令
rmdir -p d/e/f#先删除f，删除f之后e为空，就可以删除e，e不为空就无法删除，p是递归的进行
```

![image-20230531202720675](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249761.png)

#### touch

`touch`创建一个空文件，`mkdir`是创建一个空文件夹，创建时直接指定文件所在的路径和文件的名称即可，文件名不带后缀，默认是一个`txt`文件，演示在当前路径下创建文件和指定路径创建文件

```bash
touch hello#在当前路径下创建一个文件，等同于vim hello+:wq
touch /home/zzzi/hello#指定路径创建文件
```

![image-20230531203219718](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249762.png)

#### cp

`cp [选项] source dest`,将source中的文件以选项方式复制到dest中

```bash
cp anaconda-ks.cfg  /home/zzzi#将anaconda-ks.cfg文件复制到zzzi文件夹中
cp anaconda-ks.cfg  /home/zzzi/hello#将anaconda-ks.cfg文件复制到hello文件中并覆盖
\cp anaconda-ks.cfg  /home/zzzi/hello#复制文件时不会有提醒，因为\代表原生命令，
cp -r /home/zzzi /#将/home/zzzi文件夹中的所有内容复制到/目录下，-r代表递归复制 
```

![image-20230531204058181](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249763.png)

直接将当前目录下的`anaconda-ks.cfg`复制到`/home/zzzi/hello`文件中，也可以直接将文件复制到文件夹中，系统自动识别dest是文件还是文件夹，文件的话输入y代表同意覆盖

#### rm

rm [选项] filename 删除文件或者目录，有参数可选：

```bash
-r	#递归删除目录中的所有内容
-f	#强制执行删除，不用提示确认
-v	#显示命令执行的过程
rm a#无法删除一个文件夹
rm -r a#可以删除一个文件夹，但是删除每一个文件都要交互式确认
rm -rf a#删除文件夹下的所有文件，没有交互式确认
#可以搭配./ ../ *几个符号使用
#例如：
rm -rf ./*#递归删除当前目录下的所有内容，当目录变成一个空目录
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249764.png" alt="image-20230531205517397" style="zoom:67%;" />

无法直接删除目录，需要使用`rm -rf file`删除文件夹，`rm`只能删除文件

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249765.png" alt="image-20230531210121815" style="zoom:67%;" />

#### mv

`mv source dest`将文件移动到指定位置,指定位置可以是一个文件，相当于将文件移动并覆盖过去

```bash
mv file1.txt file2.txt#相当于给当前文件重命名的效果
```

![image-20230531211239775](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249766.png)

#### cat&more

`cat -n filename`查看文件的内容并显示行号，只是查看

`more filename`分屏全屏查看文件的内容

```bash
f#下一页
b#上一页
=#显示当前行号
q#直接退出
空格#向下翻页
```

#### less

`less filename`**分屏**查看文件的内容，与more类似，

```bash
f#下一页
b#上一页
=#显示当前行号
q#直接退出
空格#向下翻页
/字串#向下搜索字串 n向下 N向上 查看查找到的元素
?字串#向上搜索字串 n向上 N向下 查看查找到的元素
G#文件末尾
g#文件开头
```

#### echo & > & >>

输出内容到控制台，类似于`c++`中的`cout`，可以配合`-e`使用

配合>或者>>可以实现向文件中写信息或者追加信息的功能

```bash
> filename#向文件中写入信息
>> filename#向文件中追加信息
```

例如：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249767.png" alt="image-20230531214809013" style="zoom:67%;" />

`ls -l`的信息本应该输出到控制台上，但是现在将其写入文件`info`中

于是可以利用echo向文件中追加信息

例如：`echo "hello" > hello.txt`就是向`hello.txt`文件中写入指定的hello

不使用echo单独使用>或者>>,只能将命令中显示的信息写入文件，但是配合echo可以将自定义的信息写入文件

#### head&tail

`head filename`显示文件的前10行信息

`head -n x`显示文件前x行信息

`tail filename`显示文件最后10行信息

`tai -n x`显示文件最后x行信息

`tail -f filename`追踪文件的更新

#### ln

`ln -s source dest`创建一个link软链接，类似于windows中的快捷方式，创建的软链接保存的信息就是原文件的路径

> 不使用-s就是硬链接，不保存文件的路径，保存文件在内存中的id号，但是不推荐
>
> 软链接相当于一个另外的文件，只是保存当前文件的路径

```bash
#将/root/test文件夹链接到/home/zzzi/myfolder中
ln -s /root/test  /home/zzzi/myfolder
#将/root/test/test.txt连接到当前目录下的linktest中
ln -s /root/test/test.txt  linktest
#使用rm命令删除软链接，将其当成一个文件删除即可
rm -rf myfolder#删除文件夹的软链接
/#删除真实目录下的文件
rm -rf myfolder#此时软链接还在，但是真实目录下的文件被删了
#也就是说软链接还在，只是链接到了一个空文件
```

![image-20230531221330070](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249768.png)

将`/root/info`文件软链接到当前目录下，软链接名称为`myinfo`，此时操作`myinfo`就是操作`info`

![image-20230531223036213](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305312249770.png)将`/root/test`链接到`/home/zzzi/myfolder`中，指定绝对路径时前后都要使用绝对路径

#### history

`history`查看历史执行过的所有命令

`history x`查看最新执行过的x条命令

`history -c`删除所有历史执行过的文件

![image-20230601085738782](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308313.png)

执行`history`之后查看到了历史的所有二百多条命令，执行`history -c`命令删除所有的历史命令

### 时间日期类命令

#### date

`date`查看当前系统的时间

```bash
date#显示当前系统的时间
#有加号，y显示后两位，Y显示四位
date+ %Y#显示当前年份
#大写和小写显示的东西不一样
date +%m#显示当前月份
date +%M#显示当前月份
date +%d#显示当前天数
date +%Y-%m-%d-%H-%M-%S#显示当前系统的年月日时分秒
date +%s#显示当前系统时间的时间戳
#也就是说使用date + %[选项]就可以实现系统不同的显示
date -d "x days ago"#当前日期加上x天的时间
```

> 年月日一般都是小写，除了年份，时分秒都是大写

#### cal

`cal [选项]`直接获取出一个日历，可以指定年份，

```bash
cal -3#显示本月、前一月、后一月
cal -m#将周一放在前面
cal 2024#查看2024年的日历
cal -y#显示本年度的日历，注意是小写y
```

### 用户权限类命令

#### useradd

系统中所有的普通用户都在`/home`文件夹下

```bash
useradd username#创建一个username的用户，并在/home文件夹下创建了一个对应的文件夹
#创建一个用户，对应的文件不直接存放在/home中，而是/home/test中
useradd -d /home/test tony
#创建一个用户，和root一样使用，只是权限和对应的文件存放位置不一样
passwd username#给用户设置密码，弹出交互式提示，可以不管错误提示直接重新输入
id username#查看用户信息，没有此用户显示no such user
su username#切换用户
who am i#查询顶层用户是谁，whoami没有空格显示的是当前用户是谁
cat /etc/passwd#查看当前系统中所有用户的信息
```

#### usermod

修改用户的信息

```bash
usermod -g 用户组 用户名
usermod -g meifa tony#将tony加入meifa组
```

![image-20230601103002888](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308319.png)



#### sudo

只要将无权限执行的命令前面加上`sudo`，就可以实现临时赋予管理员权限

> 不是每个用户都可以执行`sudo`命令，需要`root`管理员配置`sudoers`文件
>
> 但是在wheel组中的用户默认可以直接执行sudo命令

![image-20230601100705883](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308320.png)

切换到`root`用户才能更改这个配置文件，增加一行：`username   ALL=(ALL)       ALL`

由于这个配置文件是只读文件，所以需要`wq!`强制保存退出

之后切换到普通用户，就可以临时执行管理员权限的命令

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308321.png" alt="image-20230601101017898" style="zoom:67%;" />

开始无法执行`ls`，变成`sudo ls`之后需要输入密码，然后验证成功之后就可以临时执行`ls`

#### userdel

删除一个用户

~~~bash
userdel username#删除指定的用户，但是保留他的文件，相当于只是删除用户的所有操作权限
userdel -r username#删除用户和对应的/home下的文件
~~~

### 用户组管理命令

默认创建一个用户时，每个用户自成一组，给用户指定了不同的组，就会有不同的权限

所有用户的组信息都在`/etc/group`文件下

![image-20230601102605353](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308322.png)

#### groupadd

`groupadd groupname`新建一个组

```bash
groupadd groupname#新建一个组

```

#### groupmod

修改组的信息

```bash
groupmod -n haircut meifa#修改组的名称
```

![image-20230601103141526](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308323.png)

修改之后tony的组变成了

![image-20230601103233414](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308324.png)

#### groupdel

删除一个用户组，由于之前的`tony`和`david`都加入了`haircut`组，所以他们之前默认的自称一组的信息就可以删掉，删除之后查看`/etc/group`配置文件中就没有了`tony`和`david`的组信息

![image-20230601104005686](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308325.png)![image-20230601104022420](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308326.png)

删除之后只剩下了`haircut`组，tony和david都属于这个组

### 文件权限类命令

`linux`对于不同的用户设置了不同的权限，甚至每一个文件对于不同的用户都设置了不同的管理权限

我们可以使用ls -l命令查看文件的属性以及其所属的用户和组

列出来的信息一共**十位**：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308328.png" alt="image-20230601110446965" style="zoom:67%;" />

可以分开看，首位、1-3位、4-6位、7-9位、11位，所属用户，所属用户组、文件大小、文件名

1. 第一位表示文件的属性：d(文件夹)、-(普通文件)、l(链接文件)、c(字符设备文件)、b(硬件块文件)、、、因为linux中一切皆文件

2. 剩下九位表示的信息为：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011308329.png" alt="image-20230601104830571" style="zoom:50%;" />

   - 1-3：该文件的创建者或者所有者，读、写、执行
   - 4-6：该文件属于哪个组，读、执行，但是不能写
   - 7-9：该文件对于其他用户的权限，读、执行，但是不能写

   3. 11位：代表当前文件的硬链接数，如果是文件夹，就指的是子文件夹的个数

      文件夹初始就有两个子文件夹：`.`和`..`，所以硬链接数初始位2

   4. 所属用户

   5. 所属用户组

   6. 文件名

> 删除文件相当于对当前文件所在的目录进行修改，所以需要有当前目录的修改权限

文件复制给当前用户之后，因为所属的原信息没有改变，所以文件属于原用户，对应的给当前用户访问权限不会改变

#### chmod

改变文件或者目录的权限，root用户有这个改变的权限

1. 第一种方式：`chmod [{ugoa}{+-=}{rwx}] 文件或目录`

   u:属主、g：属组、o：其他用户、a：u g o
   三个不同的属性对应九个不同的权限
   +-=就是对于后面的rwx权限进行增删赋值

2. 第二种方式：`chmod [mod=421] 文件或目录`

   也就是指定文件和目录的访问权限时，给定ugoa四个模式一个0-7之间的数字即可

   这个数字翻译成二进制代表的就是对应位的权限打开

   例如7->111，对应rwx三个权限都打开

~~~bash
chmod u=rwx anaconda-ks.cfg #将anaconda-ks.cfg 文件的属主权限改成rwx
#将initial-setup-ks.cfg文件的访问权限改成u=rw-,g=r--,o=-wx
chmod 643 initial-setup-ks.cfg
#常用的读写权限组合是644，也就是属主权限是rw-，属组权限是r--，其他用户权限是r--
chmod -R 644 /home/zzzi#zzzi文件夹下所有的文件和目录都递归的设置权限为777
~~~

使用第一种方法给文件的属组增加写权限

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012111960.png" alt="image-20230601211102892" style="zoom:50%;" />

使用第二种方式将文件的权限全部打开，但是常用的权限组合是`644`

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012112779.png" alt="image-20230601211243721" style="zoom:50%;" />

#### chown

`chown [][][-R] [最终用户] [文件或目录]`改变文件的所有者，其中的-R作用在目录上，递归的将目录中的所有文件和子目录的属主都改变成最终用户

将root所属的文件改成zzzi所属

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012120651.png" alt="image-20230601212012581" style="zoom: 50%;" />

将文件夹中的子文件夹和文件的属主递归的改成zzzi，增加一个-R属性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012123262.png" alt="image-20230601212315216" style="zoom:50%;" />

#### chgrp

`chgrp [-R][最终用户组] [文件或目录]`改变文件或者目录所属的组,-R作用在改变文件夹的所属组

将/root/test文件夹中的所有文件和子文件夹的属组递归的改成zzzi

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012126676.png" alt="image-20230601212628626" style="zoom:50%;" />

### 实战

对用户权限，用户组以及文件权限进行实战

1. 创建用户和组

   ~~~bash
   #添加两个组
   groupadd bigdata
   groupadd testing
   #查看是否添加成功
   cat /etc/group
   #添加xiaoming，属于bigdata组
   useradd -g bigdata xiaoming
   #查看xiaoming信息
   id xiaoming
   #添加xiaolinag，属于bigdata组
   useradd -g bigdata xiaoliang
   #查看xiaoliang信息
   id xiaoliang
   #添加xiaohong，属于testing组
   useradd -g testing xiaohong
   #添加xiaolan，属于testing组
   useradd -g testing xiaolan
   ~~~

2. xiaoming创建文件

   ```bash
   su xiaoming
   #创建文件
   touch imoportant_code.txt
   #vim编辑
   vim important_code.txt
   #查看文件的权限
   ll
   ```

3. 改变important_code.txt文件的权限

   ```bash
   #切换到root用户
   su root
   #在小明的文件加上给同组成员加上读写执行的权限
   chmod g=rwx /home/xiaoming
   #给同组成员加上对于important_code.txtde rwx权限
   chmod g=rwx /home/xiaoming/important_code.txt
   #可以对xiaoming文件夹下所有的东西递归设置rwx权限 
   chmod -R g=rwx /home/xiaoming
   #给其他组的成员访问important_code.txt的权限
   chmod 755 /home/xiaoming#755代表数组rwx，属组r-x，其他r-x
   ```

4. 修改xiaolan的组

   ```bash
   #修改xiaolan的组
   usermod -g bigdata xiaolan
   #由于xiaolan和xiaoming是同组，所以对xiaoming的文件有rwx权限
   cd /home/xiaoming
   vim important_code.txt#可修改
   ```

### 搜索查找类命令

#### find

`find[搜索范围] [选项]`可以查找范围内的指定内容

其中的选项主要有-name、-user、-size，分别表示指定文件名、指定属主、指定大小

```bash
#找出/etc文件夹下所有的txt文件
find /etc -name "*.txt"
find / -user xiaoming
```

#### locate

`locate filename`在locate数据库中查找文件所在路径，所以查找之前需要更新数据库

```bash
updatedb
#查找test.txt文件的路径
locate test.txt
```

#### grep & |

|是一个管道符，可以将管道符前面的命令执行的结果交给后面的命令进行进一步处理，一般搭配`grep`进行处理

`grep [选项] [查找内容] [源文件]`在源文件中查找对应的内容

一般对于查找内容过于庞大的命令就可以使用管道符加`grep`过滤出自己想要的文件

使用`grep`在`initial-setup-ks.cfg` 文件中查找出现`boot`关键字的所有行

![image-20230601222647736](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306012226815.png)

```bash
#对查询到的结果进行wc统计
grep -n "boot" initial-setup-ks.cfg  | wc
#对ls命令进行过滤
ls | grep .cfg
```

### 压缩解压缩命令

#### gzip & gunzip

将文件压缩成`.gz`格式的文件，并且只能压缩文件，不能压缩文件夹。压缩之后只剩下压缩包，同时压缩多个文件不会将多个文件压缩到一个文件夹中

将压缩文件包解压出来

~~~bash
cp /home/zzzi/测试.txt / #将/home/zzzi目录下的测试.txt拷贝到根目录下
gzip 测试.txt#将当前测试.txt文件压缩
gunzip 测试.txt#对文件解压缩
~~~

#### zip & unzip

`zip [选项] [压缩包名称] [文件或目录名称]`，将文件或目录压缩，压缩目录时使用`-r`递归的压缩文件中的所有内容，压缩包名称可以是一个路径名+压缩包名，这样就可以指定压缩包的存放路径

`unzip [选项] 压缩包名称`，将压缩包解压，可以指定解压之后存放的位置

~~~bash
#将 /home/zzzi下面的test文件夹递归的压缩，并将压缩包命名为zipfolder存放在根目录下
zip -r /zipfolder.zip /home/zzzi/test/
#使用-d参数将zipfolder.zip压缩包解压到指定目录
unzip -d /home/zzzi/ zipfolder.zip 
~~~

#### tar

 `tar [选项] xxx.tar.gz 要打包的内容`，可以对文件进行打包归档

~~~bash
#有以下几个选项
-c #产生.tar打包文件
-v #显示打包的详细信息
-f #指定压缩之后的文件名
-z #打包同时压缩
-x #解包.tar文件
-C #解压到指定目录 这里是大写
#一般都是zcvf，打包并压缩，指定压缩包的名字
~~~

测试

~~~bash
#将initial-setup-ks.cfg  anaconda-ks.cfg 打包并压缩到tartest.tar.gz压缩包中
tar -zcvf tartest.tar.gz initial-setup-ks.cfg  anaconda-ks.cfg 
#将压缩包文件解压缩到/home/zzzi文件夹下
tar -zxvf tartest.tar.gz  -C /home/zzzi
~~~

### 磁盘管理类命令

#### du

`du [选项]文件或目录`可以查看磁盘的占用情况，有以下几个选项，由于ll就可以查看文件的大小，所以du一般都作用在文件夹上，查看文件夹中所有内容的大小总和

~~~bash
-h #以bytes的格式显示，也就是显示文件的mb大小，而不是显示字节数
-a #不仅查看子目录，还要查看文件的大小
-c #显示文件和子目录以及他们的总和
-s #只显示总和
-max-depthn #指定最深统计几层子目录
~~~

测试

~~~bash
du -ah /home/zzzi#统计zzzi文件夹占用的内存，显示所有文件和子目录的大小
du --max-depth=1 -ah /home/zzzi#查看zzzi文件夹下一级菜单中的文件和目录的大小
#只是显示一级目录，但是更深层目录中占用的空间还是会统计
~~~

#### df

`df [选项]` 查看文件系统中空余挂载磁盘，选项一般加上-h，就会以mb的方式显示，而不是字节数的方式显示

```bash
[root@centos ~]# df -h
#会列出所有的信息
文件系统                   容量   已用  可用   已用% 	挂载点
devtmpfs                 2,0G     0  2,0G    0% 	/dev
tmpfs                    2,0G     0  2,0G    0% 	/dev/shm
tmpfs                    2,0G   13M  2,0G    1% 	/run
tmpfs                    2,0G     0  2,0G    0% 	/sys/fs/cgroup
/dev/mapper/centos-root   17G  4,9G   13G   29% 	/
/dev/sda1               1014M  172M  843M   17% 	/boot
tmpfs                    394M     0  394M    0% 	/run/user/0
tmpfs                    394M   28K  394M    1% 	/run/user/1000
#linux的镜像文件大小，使用光驱安装linux
/dev/sr0                 4,4G  4,4G     0  100% 	/run/media/zzzi/CentOS 7 
```

前四个选项对应的是系统的内存和swap分区的容量，第五个是根目录的分区，第六个是boot分区

> 类似的命令还可以使用free -h

#### lsblk

`lsblk [-h]可以查看当前块设备的挂载情况，加一个`-f`显示更更加详细的信息

![image-20230603103735702](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031037833.png)

#### mount

挂载指的是将一个文件夹映射到某一块磁盘中，这块磁盘中的空间就是为了这个文件夹服务，这种映射关系称为挂载

可以将挂载理解为给磁盘的分区取名字，当一个文件夹挂载到了某个磁盘分区，这个磁盘分区的名称就是文件夹的名称

为了测试挂载，我们将虚拟机的光盘弹出，之后将其手动挂载到Linux中

linux中所有的硬件都以文件的形式显示在`/dev`文件下，对应的光盘在`/dev/cdrom`中

```bash
mkdir /mnt/cdrom #创建一个cdrom文件夹。将光盘挂载到这里
#应该是一种双向绑定
mount /dev/cdrom  /mnt/cdrom/#将/dev/cdrom 光盘挂载到/mnt/cdrom中
```

挂载之后，系统块设备的情况从

```bash
[root@centos ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
 #最后一行的挂载点没有
sr0              11:0    1  4,4G  0 rom  
```

变成了

```bash
[root@centos media]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
  #最后一行的挂载点变成了/mnt/cdrom
sr0              11:0    1  4,4G  0 rom  /mnt/cdrom
```

#### umount

将硬件和文件的挂载映射删除，使用`umount /dev/cdrom`或`umount /mnt/cdrom`解除挂载

光盘的挂载信息从

```bash
[root@centos media]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
  #最后一行的挂载点变成了/mnt/cdrom
sr0              11:0    1  4,4G  0 rom  /mnt/cdrom
```

变成了

```bash
[root@centos dev]# umount /dev/cdrom
[root@centos dev]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part 
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
#最后一行的挂载信息消失
sr0              11:0    1  4,4G  0 rom  
```

可以修改配置文件，将块设备的挂载信息保存到对应的配置文件中，开机时就自动挂载

挂载的配置文件在：`/etc/fatab`中

在文件中新增一行：`/dev/cdrom       /mnt/cdrom       iso9660 defaults     0 0`

![image-20230603110436495](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031104567.png)

对应的`uuid`不用管

#### fdisk

`fdisk -l`可以查看磁盘的基本信息

`fdisk [设备名称]`可以对设备进行分区,之后按提示输入m即可获得帮助信息

linux系统中如何新增了硬盘,对应的硬盘文件会加入到`/dev`文件夹下,重启系统之后自动加入到`/dev`文件夹下

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306051953917.png" alt="image-20230605194710184" style="zoom:50%;" />

新增加的sdb没有任何挂载点

1. 使用`fdisk /dev/sdb`命令分区之后,将4G空间分成一个区:

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306051957357.png" alt="image-20230605195734288" style="zoom:50%;" />

sda和sdb代表不同的磁盘,sdb1,sdb2代表sdb磁盘中不同的分区,同一块磁盘可以分成四个主分区,主分区可以变成拓展分区,从而分成16个分区,即sdb1-sdb16

2. 分区之后指定文件系统:`mkfs -t xfs /dev/sdb1`

3. 磁盘准备完毕就开始挂载,将/home/zzzi挂载到sdb1新硬盘上

   ```bash
   将sdb1挂载到/home/zzzi/下
   mount /dev/sdb1 /home/zzzi/下
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306052002045.png" alt="image-20230605200246951" style="zoom:50%;" />

4. 使用`umount /home/zzzi`删除挂载信息

### 进程管理类命令

系统中正在执行的程序或者命令都被称为一个进程，linux中可以对这些进程进行管理

#### ps

`ps [选项]`查看当前系统进程和与用户相关进程的状态

```bash
ps aux | less#查看系统中所有用户的进程信息以及系统进程的信息
ps -ef | less#显示所有进程，和上面的命令等同
ps -ef |grep zzzi#查看和zzzi有关的所有进程的详细信息
```

两者的区别就是在显示进程信息略有不同，如果想要查看CPU占用率和内存占用率就可以使用`aux`，如果想要查看父进程的ID就可以使用`-ef`

正常的父子关系是一开始的systemd1号进程启动一个sshd进程，sshd创建一个远程登陆进程，远程登陆进程创建一个bash进程，就有了连接之后的界面

每一个终端界面都对应一个bash界面

#### kill

`kill [-9] [进程id]` 终止进程

```bash
kill -9 5102#-9代表强制执行
```

#### pstree

显示当前进程的结构树，以sshd进程树为例，加上-p可以显示进程id，加上-u显示进程的所属用户

![image-20230605212508744](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306052125842.png)

#### top

相比于ps，是将当前这一瞬间的系统中正在运行的进程信息显示出来，top可以实时的将系统中的进程信息进行展示，并且显示的信息会实时更新

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306052132811.png" alt="image-20230605213212735" style="zoom:50%;" />

可以看到系统中进程的实时信息

```bash
#top可以添加的选项
-d 秒数#指定多少秒刷新一次
-i#不显示闲置和僵尸进程
-p # 指定进程号来进行监控
```

#### netstat

显示网络状态和端口占用信息

```bash
netstat -anp |grep 进程号#查看进程的网络信息
netstat -nlp | grep 端口号#查看端口的占用情况
```

#### crontab

`* * * * * 任务命令`可以指定一个定时任务，前面五个*代表分钟、小时、天、月、星期

使用`crontab -e`打开一个vim界面，使用`* * * * * 任务命令`创建一个定时任务，使用`crontab -l`查看当前系统的定时任务，`crontab -r`删除系统定时任务

![image-20230605222319711](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306052223788.png)

### 软件包管理

#### rpm

是红帽系列操作系统的包管理工具，但是其它系统也可以使用，可以在Linux中对各种安装包进行管理，包括安装，更新，卸载等

```bash
rpm -qa#查询安装的所有包
rpm -qi firefox#查询firefox相关包的信息
rpm -e [软件包名] [--nodeps]#卸载软件包,后面的nodeps是卸载时不考虑依赖关系，强制卸载
#i是安装，v是显示详细信息，h是显示安装进度条
rpm -ivh [软件包名]#安装一个软件包
```

#### yum

改进版本的软件包管理工具，相比于rpm而言，可以自动处理软件包之间的依赖，不需要一层一层的安装，安装某个软件包时，如果其所需要的依赖并不存在，yum可以自动安装

`yum [选项] [参数]`

其中选项为-y，代表所有的提问都回答yes

参数一共有七个：install，update，check-update（检查是否有可用的更新），remove，list（显示软件包信息），clean（清除yum过期的缓存），deplist（显示yum软件包所有的依赖关系）

例如对`firefox`进行操作：

```bash
yum list |grep firefox#查看firefox的信息
yum -y remove firefox#删除firefox
yum -y install firefox#安装firefox
```

由于默认的镜像源在国外，所以我们可以通过修改配置文件来将镜像源更改到国内

镜像源所在的配置文件为：`/etc/yum.repos.d/CentOS-Base.repo`查看配置：

```bash
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
```

### 克隆虚拟机

虚拟机的克隆需要将原虚拟机关机，选择**创建完整克隆**即可，之后就是修改配置

1. 修改虚拟机的ip地址，不能和原虚拟机一样

   ip地址的配置文件在：`/etc/sysconfig/network-scripts/ifcfg-ens33`中

   修改完成之后进行网络的重启

   ```bash
   ifconfig#查看网络的ip地址
   vim /etc/sysconfig/network-scripts/ifcfg-ens33#修改网络配置
   systemctl stop network#停掉原始的网络服务
   systemctl restart NetworkManager #重启最新的网络服务
   ifconfig#查看网络的ip地址是否发生改变
   ```

2. 修改主机名

   ```bash
   hostnamectl set- hostname centos1#设置主机名
   ```

3. 配置windows的hosts文件，添加主机名和ip之间的映射，使XShell连接时可以使用主机名连接

   ```bash
   192.168.78.101 centos1
   ```

## Shell编程

linux最终的命令都会交给linux内核去执行，但是外层的应用程序不可能直接生成linux内核识别的语言，所以需要使用一个shell当成中间的桥梁，外部应用程序编写shell脚本，解析之后传递给linux内核，从而执行相应的命令

### 入门

#### 脚本格式

脚本以`#!/bin/bash`开头，指定shell的解析器

创建一个脚本文件：

```bash
cd /home/zzzi
mkdir scripts#创建一个存放脚本文件的文件夹
cd scripts
touch hello.sh
#编写shell命令
#!/bbi/bash
echo "hello"
```

脚本的执行：

1. `bash/sh`+脚本的相对路径或者绝对路径

2. 直接加路径，去掉bash/sh，此时需要脚本文件**有可执行权限****（常用）**

   ```bash
   chmod +x /home/zzzi/scripts/hello.sh#给所有的用户都加上可执行权限
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306082152548.png" alt="image-20230608215203367" style="zoom:67%;" />

   3. `source/.`+脚本的路径或者脚本名，如果当前路径下有脚本，可以直接使用脚本名执行

      这种方式就是在最外层的bash中执行这个脚本文件，当在一个bash中运行一个新的bash时，就会启动一个子shell，此时就会有父子shell的关系

   改变文件的访问权限之后，文件的颜色变成<font color=green>绿色</font>，可以直接执行

   第二种操作方式需要文件的可执行权限，所以一般使用`+x`直接给文件增加可执行权限

   第三种操作方式下如果脚本就在当前目录下就可以**直接使用文件名**，但是第二种不可以

   > 当前目录下有脚本文件时三种方式的区别：

   ```bash
   #第一种方式,可以使用文件名
   bash hello.sh
   sh hello.sh
   #第二种方式，必须加路径， 不加路径linux以为是一个内置的命令，会去bin目录下找
   ./hello.sh
   #第三种方式，可以使用文件名
   source hello.sh
   . hello.sh#注意有空格
   ```

#### 修改PATH

如果想要直接将脚本当成一个命令执行，不加任何路径和操作符，就需要将当前脚本存放的路径加入环境变量中，就像是windows中安装一个软件之后，将其加入环境变量中，这样在任何地方都可以直接使用这个文件

```bash
echo $PATH#查看当前系统环境变量
vim $PATH
```

### 变量

#### 系统变量

常见的系统环境变量：\$HOME,\$PWD,\$SHELL,\$USER

显示当前shell中的所有变量：set

使用或者获取某个变量的值，需要使用`$`

#### 自定义变量

直接变量名=变量值即可，定义之后可以使用$获得变量值，=号前后不能加空格，但是如果变量值中有空格，那么就需要加上引号

正常定义的变量是一个**局部变量**，无法在子bash中进行访问，所以可以将变量变成**全局变量**，使用`export`关键字即可，例如，export a，将a变成全局变量

但是子bash中对父bash的全局变量做修改是不可以的，修改无法传到父bash中 

如果想要定义常量，需要加上`readonly`修饰符

变量命名可以使用字母，数字，下划线，不能用数字开头

#### 撤销变量

`unset +变量名`直接撤销一个变量，常量无法使用unset撤销，set是查看系统中的所有变量和函数，包括局部变量，全局变量，常量

#### 特殊变量

1. 位置变量`$n`

当脚本中需要接收参数时，就可以在脚本中使用`$0-∞`来表示当前位置可以接受一个参数,类似占位符

其中`$0`代表当前脚本的名称，自动获取

`$1-9`可以正常输入，运行脚本时在运行的命令添加上对应的脚本名称即可

`${10}`以上需要使用{}将数字括起来，防止与1-9冲突

2. 统计参数个数`$#`

可以用来统计当前有多少个输入的参数，经常用在循环中，用来统计输入的参数个数是否合法，增强程序的健壮性

3. `$*`,`$@`

用来获取当前命令行中所有的参数，只是`$*`将所有的参数当成一个整体，`$@`将参数区分对待，当成一个参数的集合

```bash
#在parameter.sh脚本中添加几行命令
echo '============$n==========='
echo scrtpi name:$0
echo 1st parameter:$1
echo 2nd parameter:$2

#测试$#
echo '============$#==========='
echo $#

#测试$*
echo '============$*==========='
echo $*#直接接受参数

#测试$@
echo '============$@==========='
echo $@#直接接受参数
#之后给parameter.sh脚本加上可执行权限
chmod +x parameter.sh

#执行脚本，并且加上参数
./parameter.sh hello world
#输出结果为：
'============$n==========='
scrtpi name:./parameter.sh
1st parameter:hello
2nd parameter:world
'============$#==========='
2
'============$*==========='
hello world
'============$@==========='
hello world
#不使用双引号引用$*和$@时，二者没有任何区别
```

4. `$?`

捕获上一条命令执行之后的返回状态，如果返回`0`，说明上一条命令正确执行了，如果返回其他自定义的数字，就是出现了不同的错误

```bash
#在bash中直接输入一个脚本的名称，执行不了
parameter.sh
#查看命令的执行状态
echo $?#127,结果为127不为0，说明上一条命令并没有正确执行
```

### 运算符[]

不使用运算符的话，系统会将表达式认为是一个字符串，例如：

~~~BASh
a=1+3
echo $a#结果为1+3,系统将1+3当成一个字符串，而不是表达式
~~~

所以需要使用运算符让系统认识`1+3`是一个表达式，例如：

~~~bash
echo $[2*3]#结果为6
#等价于
a=$[2*3]
echo $a
~~~

编写一个加法脚本，在哪使用表达式的值就需要使用`$`：

```bash
vim add.sh
#加法脚本为：
#!/bin/bash
sum=$[$1+$2]#$1和$2相当于两个占位符，接收外部传递的参数
echo sum=$sum
#执行加法脚本
chmod +x add.sh
./add.sh 2 7
#结果为9
```

### 条件判断

可以使用test判断表达式的执行结果是否为真，也可以使用`[]`判断表达式的执行结果是否为真，执行完成之后使用`$?`来捕获返回值判断真假，但是[]使用时两端记得加上**空格**，判断的表达式也要加空格，使用[]的目的是为了将内部的表达式进行执行

```bash
a=hello
test $a=hello
echo $?#结果为0，说明表达式test $a=hello执行成功，结果为true
#等价于
[ $a = hello ]#[]两端要加空格，=两端也要加空格，$a代表取出a的值
echo $?#结果为0
```

使用运算符时，等于和不等于可以使用=，!=，大于小于不能使用>，<，可以将数学运算式放在`(())`中，双括号直接接收正常的数学表达式

常用的判断条件：

1. -eq，等于

2. -ne，不等于

3. -lt，小于

4. -le，小于等于

5. -gt，大于

6. -ge，大于等于

7. 表达式1 && 描述1 || 描述2，实现三目运算符的效果

   ```bash
   #例如
   [ 2 -gt 8 ] && echo "2大于8" || echo "2小于8"     #"2小于8"
   ```

### 流程控制

#### if判断

if判断的基本语法为：

1. 单分支

   ```bash
   if [ 条件判断 ]
   then
   #等价于   if [ 条件判断 ];then
   	程序
   fi	#if反过来当成if的结束
   ```

2. 多分支

   ```bash
   if [ 条件判断 ]
   then
   	程序
   elif [ 条件判断 ]
   then
   	程序
   else
   	程序
   fi	#if反过来当成if的结束
   ```

定义一个测试脚本`test.sh`

~~~bash
#!/bin/bash
#输入一个姓名，判断是不是zzzi
if [ "$1"x = "zzzi"x ]
then
        echo "欢迎$1"
fi

#输入一个年龄进行if else判断
if [ $2 -gt 18 ]
then
        echo "成年人"
else
        echo "未成年人"
fi
#执行test.sh
chmod +x test.sh
./test.sh zzzi 19#欢迎zzzi  \n 成年人
~~~

#### case

case的基本语法为：

```bash
case $变量名 in
"值1")
	程序1
;;#类似于break
"值2")
	程序2
;;
*)
	类似于switch case中的default中的代码
;;
esac#case反过来
```

创建一个case_test.sh脚本：

```bash
#!/bin/bash
case $1 in
"1")
        echo "输入了1"
;;
"2")
        echo "输入了2"
;;
"3")
        echo "输入了3"
;;
*)
        echo "输入了其他"
;;
esac
#执行
chmod +x case_test.sh
./case_test.sh 3#输入了3
```

#### for

1. <font color=red>for循环的基本语法1 为：</font>

```bash
for((初始值;循环控制变量;变量变化))
do
	程序
done
```

编写一个累加add.sh脚本：

```bash
#!/bin/bash
sum=0;
for((i=0;i<=$1;i++))#双小括号可以直接使用数学运算式
do#使用do和done将代码块包围，类似于{}包围
	sum=$[ $sum+$i ]#使用哪个的值就是用$取出哪个
done
echo $sum
#执行
chmod +x add.sh 100
./ add.sh#5050
```

2. <font color=red>for循环的基本语法2 为：</font>

```c++
for 变量 in 值1 值2 值3...#可以跟一个序列值，例如{1..100}，代表1到100
do
	程序
done	
```

测试脚本为：

```c++
#!/bin/bash
sum=0
for os in {1..100}#可以跟一个序列值或者一个序列列表，例如linux windows macos
    			  #中间没有逗号，使用空格分开
do
        sum=$[ $sum+$os ]
done
echo $sum
    
#执行
chmod +x add.sh
./ add.sh#5050
```

####  while

while语句的基本语法为:

```c++
while [ 条件判断式 ]
do
	程序
done
```

实现1加到100的脚本add.sh如下：

```bash
#!/bin/bash
i=1
sum=0
while [ $i -le $1 ]#接受一个参数，固定i的范围
do
        sum=$[ $sum+$i ]
        i=$[ $i+1 ]
done
echo $sum
#执行脚本的结果为：5050，需要传递一个参数
```

### read读取输入

read (选项)(参数)

1. 选项：-p 指定提示符，-t 指定等待时间，不加的话就一直等待
2. 参数：指定读取的变量名

例如：

```bash
#!/bin/bash
read -t 7 -p "请在七秒内输入姓名：" NN
echo "欢迎$NN"
```

运行之后不需要任何参数，控制台提示输入名字

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306122012108.png" alt="image-20230612201212968" style="zoom:67%;" />

### 函数

#### 系统函数

1. basename

   显示当前脚本的名称而不是全称，与$0不同

   ```bash
   basename /home/zzzi/read_test.sh#read_test.sh
   #脚本内的$0结果为/home/zzzi/read_test.sh
   #如果想去除文件的后缀，只需要在执行时指定去除的后缀即可
   basename /home/zzzi/read_test.sh .sh#read_test   指定去除后缀.sh
   ```

2.  dirname

   与basename相反，一个截取最后一个/之后的内容，一个截取最后一个/之前的内容

   ```bash
   dirname ../zzzi/read_test.sh#../zzzi
   ```

   脚本中调用系统命令的方式是加一个\$(命令)，括号中存放想要调用的命令，这种方式成为命令替换，先执行括号中的命令，返回的结果使用`$`取出

   ```bash
   echo $(basename $0)#显示当前脚本的名称
   ```

#### 自定义函数

自定义函数的基本语法：

```bash
[ function ] funcname[()]
{
    action;
    [return int;]#不加返回值，返回的就是最后一句命令执行的结果
}
#[]代表内容可以省略，也就是可以直接funcname{action;}
```

定义相加函数的脚本：

```bash
#!/bin/bash

function add()
{
	s=$[ $1+$2 ]
	echo $s
}
read -p "请输入第一个数：" a
read -p "请输入第二个数：" b
sum=$(add $a $b)#使用命令替换获取返回值
echo "和为："$sum
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306122109198.png" alt="image-20230612210910108" style="zoom:67%;" />

###  正则表达式

正则表达式使用单个字符进行描述，匹配符合要求的字符串

#### 常规匹配

没有任何特殊字符，系统就会匹配他自己，例如：

```bash
#在/etc/passwd文件中匹配含有zzzi的行
cat /etc/passwd |grep zzzi
```

#### 常用特殊字符

使用特殊字符进行模糊匹配

1. `^`

   匹配一行的开头，与vim一样

   ```bash
   #会匹配所有以a开头的行
   cat /etc/passwd |grep ^a
   ```

2. `$`

   匹配一行的结束

   ```bash
   #会匹配所有以a结尾的行
   cat /etc/passwd |grep a$#注意a在前面
   ```

3. `.`代表一个通配符，和sql语句中的通配符一样，`.`代表一个任意字符

   ```bash
   #统计r开头t结尾的四个字母的单词
   cat /etc/passwd |grep r..t#root,r/tt,rrtt都可以匹配到
   ```

4. `*`代表一个通配符，代表任意字符，与上一个字符配合使用

   ```bash
   #代表以r开头，t结尾，中间任意个o的单词，o可以不出现
   cat /etc/passwd |grep ro*t#rt,rot,root,roooot,roooooot都可以匹配到
   ```

   ```bash
   #匹配以a开头，bash结尾的任意字符串，中间可以是任意字符串
   cat /etc/passwd |grep ^a.*bash$
   ```

5. `[]`字符区间

   ```bash
   [6,8]#匹配6或者8
   [0-9]#匹配0-9
   [a-c,e-f]#匹配a-c或者e-f
   #例如
   cat /etc/passwd |grep r[a,b]t#匹配含有rat或者rbt的行
   ```

6.  `\`转义字符 

   ```bash
   cat /etc.passwd |grep '/\$'#匹配所有含有/$的行
   ```

## 总结

总结了linux中的一些基本知识，分为三个被大部分，基础篇介绍linux中的一些基础知识，包括linux系统结构，vim编辑器的基本使用，网络的配置以及远程登录等

实操篇中介绍了了linux的一些常见命令，可以用来操作文件，系统时间，用户，磁盘，进程，软件等，是linux最主要的部分

第三部分shell编程主要是介绍编程的基本语法，编写一些常见的脚本文件用来执行一些制定的任务



