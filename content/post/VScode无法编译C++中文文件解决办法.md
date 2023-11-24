---
title: "VSCode无法编译C++中文文件解决办法"
description: "VSCode无法编译C++中文文件解决办法"
keywords: "VSCode无法编译C++中文文件解决办法"

date: 2023-05-24T16:01:29+08:00
lastmod: 2023-05-24T16:01:29+08:00

categories:
  - 教程
tags:
  - VSCode
  - 中文编码
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
#url: "vscode无法编译c++中文文件解决办法.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> :smile:VSCode无法编译C++中文文件解决办法

更新`.vscode`文件夹中的配置文件

<!--more-->

直接更换`launch.json`和`tasks.json`文件中的配置

改变`launch.json`：

![image-20230524160333287](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305241603341.png)

改变`tasks.json`：

![image-20230524160402893](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305241604944.png)
