---
title: "代码托管到github"
description: "代码托管到github"
keywords: "代码托管到github"

date: 2023-07-16T20:38:51+08:00
lastmod: 2023-07-16T20:38:51+08:00

categories:
  - 教程
tags:
  - Git


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
#url: "代码托管到github.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>🏭 代码托管到github

如何将本地代码托管到github仓库中，前提已经安装了git，并且已经连接到了github，添加了公钥

<!--more-->

1. github创建存放的代码的仓库

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307162109190.png" alt="image-20230716205134196" style="zoom:50%;" />

   url就是访问仓库的地址

2. 初始化仓库

   ```bash
   git init
   ```

此时文件夹中会多出一个.git文件夹

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307162109197.png" alt="image-20230716205053754" style="zoom:50%;" />

其中config文件中存放的是关键的配置信息

3. 将本地仓库和远程github仓库连接起来

其中origin是远程仓库的别名，后期提交时使用origin就会自动解析为远程仓库的地址

```bash
git remote add origin  xxx
```

这里的xxx就是github中创建的仓库提供的url，此时config文件会发生变化

这里的origin相当于远程仓库的别名，如果想要把同一个本地仓库提交给不同的远程仓库，那么就可以修改这个命令，修改之后形成如下的映射：

![image-20230904202937268](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042029567.png)

4. 将项目文件添加到暂存区

```bash
git add .
```

5. 提交代码到本地仓库,引号中填写自己的描述

```bash
git commit -m "commit"
```

6. 将本地仓库中的代码提交到远程仓库

使用master分支提交，前提需要确保本地仓库和远程仓库的分支都是master

```bash
git push -f origin master
```

7. 显示如下效果表示完成推送

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307162109200.png" alt="image-20230716210614419" style="zoom:50%;" />

如果无法完成推送，查看当前分本地分支与远程仓库分支是否对应，下面是一些常见的git命令：

```bash
#查看当前本地分支名
git branch
#修改当前的本地分支
git checkout <branch_name>
#创建并切换到新分支
git checkout -b <branch_name>
#推送时显示Timeout
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy https://127.0.0.1:7890
git config --global http.proxy
```

> 总结起来就是以下几步：
>
> 1. 创建远程仓库
> 2. 初始化本地仓库
> 3. 远程仓库取别名
> 4. 代码添加到暂存区
> 5. 代码上传到本地仓库
> 6. 代码上传到远程仓库
