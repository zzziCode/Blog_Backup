---
title: "Git学习笔记"
description: "Git学习笔记"
keywords: "Git学习笔记"

date: 2023-05-25T21:18:49+08:00
lastmod: 2023-05-25T21:18:49+08:00

categories:
  - 学习笔记
tags:
  - Git

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
#url: "git学习笔记.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> :smile:Git学习笔记

Git的基本理论和使用

<!--more-->

## 版本控制

开发过程中项目不断更新迭代，此时使用Git就可以进行版本控制

版本控制总共分为三种：

1. 本地版本控制：个人用户在本地控制自己的项目
2. 集中版本控制（SVN）：多人协同开发一个项目，更新历史存放在服务器上
3. 分布式版本控制(Git)：版本信息同步到每个用户，本地可以看到所有的版本历史，理解为用户也相当于一个服务器，拥有所有版本信息

### 常用的版本控制器

目前使用最广泛的是**Git**与**SVN**。

**他们主要的区别**:

- SVN是**集中式**版本控制系统，版本库是集中放在中央服务器的，而干活的时候，用的都是自己的电脑，所以首先要从中央服务器哪里得到最新的版本，然后干活，干完后，需要把自己做完的活推送到中央服务器。集中式版本控制系统是必须联网才能工作，如果在局域网还可以，带宽够大，速度够快，如果在互联网下，如果网速慢的话，就完蛋了。
- Git是**分布式**版本控制系统，那么它就没有中央服务器的，每个人的电脑就是一个完整的版本库，这样，工作的时候就不需要联网了，因为版本都是在自己的电脑上。既然每个人的电脑都有一个完整的版本库，那多个人如何协作呢？比如说自己在电脑上改了文件A，其他人也在电脑上改了文件A，这时，你们两之间只需把各自的修改推送给对方，就可以互相看到对方的修改了。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305252202140.png" alt="image-20230525220257937" style="zoom:50%;" />

## Git配置

> 安装无脑下一步

### Git连接GitHub

```bash
git config --global user.name " GitHub 用户名 " 
例如：git config --global user.name "zzziCode"
git config --global user.email "github用户的邮箱"
例如：git config --global user.email "1980136696@qq.com"
```

运行之后Git就连接到了GitHub

系统配置文件在：`E:\Program Files\Git\etc\gitconfig`

```bash
[diff "astextplain"]
	textconv = astextplain
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[http]
	sslBackend = openssl
	sslCAInfo = e:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
[core]
	autocrlf = true
	fscache = true
	symlinks = false
[pull]
	rebase = false
[credential]
	helper = manager-core
[credential "https://dev.azure.com"]
	useHttpPath = true
[init]
	defaultBranch = master

```

用户配置文件在：`C:\Users\zzzi\.gitconfig`，git连接GitHub时，配置的用户名和邮箱就存储在这里

```bash
#下面的东西必须配置才能连接上GitHub
[user]
	name = zzziCode
	email = 1980136696@qq.com
[http]
	sslVerify = false
[https]
	proxy = https://127.0.0.1:7890
```

查看Git已有的配置信息

```bash
git config --list
```

### Git连接仓库

连接到GitHub之后，再使用命令连接到远程的仓库，才可以进行Git的操作，命令如下：

并且只需要**在最开始**连接一次

```bash
git remote add origin https://github.com/zzziCode/zzziCode.github.io.git
//其中里面的origin只是给你的远程仓库起了一个别名，以后在push的时候不用每次都输入仓库地址
//起了别名之后，系统就会记录别名和仓库地址之间的对应关系
```

起别名之后，对应的.git文件夹中的config文件中多出一条命令，代表系统知道别名代表的是哪个仓库：

```bash
[remote "origin"]
 	url = https://github.com/zzziCode/zzziCode.github.io.git
 	fetch = +refs/heads/*:refs/remotes/origin/*
```

==起别名==之后的push命令：

```bash
git push -f origin master
//代表push到仓库https://github.com/zzziCode/zzziCode.github.io.git中的master分支中
```

没起别名的push命令，每次都需要指定仓库的地址

```bash
git push -f https://github.com/zzziCode/zzziCode.github.io.git main:master
//代表将本地的main分支push给远程的master分支
```

## Git理论

### 工作区域

- **工作区**：平时存放项目代码的地方。

- **暂存区(Stage/Index)：**暂存区，用于临时存放你的改动，事实上它只是一个文件，保存即将提交的文件列表信息，使用`git add .`将所有东西加入暂存区，==.==代表当前目录下的所有文件

- **版本库：**又称本地仓库，这个不算工作区，而是 Git 的版本库，里面有你提交到所有版本的数据。`commit`到这里

- **远程仓库**：托管代码的服务器，`push`到这里

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261151185.png" alt="image-20230526115110083" style="zoom:50%;" />

### 工作流程

１、在工作目录中添加、修改文件，理解为本地开发；

２、将需要进行版本管理的文件放入暂存区域；

３、将暂存区域的文件提交到git仓库，commit是将项目提交到本地仓库中。本地仓库通过`git init`命令创建

因此，git管理的文件有三种状态：已修改（modified）,已暂存（staged）,已提交(committed)

![image-20230526115517755](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261155792.png)

### 创建项目

1. 使用git init将当前文件夹初始化为一个空仓库，之后就可以在当前文件夹下开发

![image-20230526115732546](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261157615.png)

2. 直接clone一个远程的仓库，不用init

   使用git clone [url]来将远程的仓库clone下来，当前文件夹下就会多出一个项目

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261200973.png" alt="image-20230526120057931" style="zoom:67%;" />

   ### Git文件操作

   版本控制就是对文件的版本控制，所以需要知道文件当前的状态，才知道是否是自己想要的

   使用`git status`查看当前文件夹下文件的状态

   - `Untracked`: 未跟踪, 此文件在文件夹中, 但并没有加入到git库, 不参与版本控制. 通过`git add` 状态变为`Staged`.
   - `Unmodify`: 文件已经入库, 未修改, 即版本库中的文件快照内容与文件夹中完全一致. 这种类型的文件有两种去处, 如果它被修改, 而变为Modified. 如果使用git rm移出版本库, 则成为`Untracked`文件
   - `Modified`: 文件已修改, 仅仅是修改, 并没有进行其他的操作. 这个文件也有两个去处, 通过`git add`可进入暂存`staged`状态, 使用`git checkout` 则丢弃修改过, 返回到`unmodify`状态, 这个`git checkout`即从库中取出文件, 覆盖当前修改 !
   - `Staged`: 暂存状态. 执行`git commit`则将修改同步到库中, 这时库中的文件和本地文件又变为一致, 文件为`Unmodify`状态. 执行`git reset HEAD filename`取消暂存, 文件状态为`Modified`， 也就是说本地修改的文件通过`git commit`就可以变成~状态

   总结来说，本地的文件最开始都是`Untracked`，修改一部份文件之后，修改的文件变成`Modified`，进行`git add`之后，变成`Staged`状态

   > 忽略某些文件

   在项目根目录下建立`.gitignore`文件，之后书写一些忽略的规则：

   ```bash
   #为注释
   *.txt        #忽略所有 .txt结尾的文件,这样的话上传就不会被选中！
   !lib.txt     #但lib.txt除外
   /temp        #仅忽略项目根目录下的TODO文件,不包括其它目录temp
   build/       #忽略build/目录下的所有文件
   doc/*.txt    #会忽略 doc/notes.txt 但不包括 doc/server/arch.txt
   ```
   
### 配置SSH公钥连接到仓库

在本地生成一个公钥，将其填入GitHub中，就可以实现免密登录

生成公钥的命令为：

```bash
ssh-keygen -t rsa//使用加密算法rsa生成公钥
```

生成的公钥存储在`C:\Users\zzzi\.ssh\id_rsa.pub`中，将文件中的内容配置到GitHub中即可

后续使用Git连接GitHub就不用输入密码，原理就是使用上述命令生成一个公钥和一个私钥，每次连接到远程仓库时，本地发送一个连接请求，之后远程仓库收到请求之后返回一个随机字符串，本地通过私钥加密字符串之后传递给远程仓库，仓库使用配置的公钥进行解密，如果与最开始生成的随机字符串一样就说明连接成功。

![image-20230526122957172](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261229230.png)

## Git分支

在开发软件时，可能有多人同时为同一个软件开发功能或修复BUG，可能存在多个Release版本，并且需要对各个版本进行维护。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261240051.png" alt="image-20230526124050009" style="zoom:50%;" />

开发时如果version1.1需要更新，就在`version1.1`这个时刻创建一个新分支，然后在新分支上进行开发，当新版本稳定之后，将其合并到`master`主分支上，形成新的`version1.2`，在新分支上的修改和提交不会影响`master`主分支，只有当合并分支之后，`master`分支才会变化

## 总结

将Git进行简单的配置之后，就可以连接到GitHub，之后再生成一个公钥，就可以实现免密登录。连接到GitHub之后，还需要连接到具体的仓库中，可以选择给仓库起别名。

准备工作完成之后，就可以使用git命令操作仓库进行开发，将本地的项目`push`到远程仓库或者将远程仓库的项目`clone`到本地，开发的过程中又会出现不同的分支。

