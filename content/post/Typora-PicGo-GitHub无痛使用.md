---
title: "Typora PicGo GitHub无痛使用"
description: "Typora-PicGo-GitHub无痛使用"
keywords: "Typora,PicGo,GitHub无痛使用"

date: 2023-05-22T22:34:28+08:00
lastmod: 2023-05-22T22:34:28+08:00

categories:
  - 教程
tags:
  - 图床配置


# 原文作者
# Post's origin author name
author: zzzi
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
# 关闭文章目录功能
# Disable table of content
toc: true
# 绝对访问路径
# Absolute link for visit
#url: "typora-picgo-github无痛使用.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 2
# 开启数学公式渲染，可选值： mathjax, katex
# Support Math Formulas render, options: mathjax, katex
#math: mathjax
# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> Typora-PicGo-GitHub无痛使用

**[PicGo](https://picgo.github.io/PicGo-Doc/zh/guide/#picgo-is-here): 一个用于快速上传图片并获取图片 URL 链接的工具**

使用PicGo解决了Typora书写md文档时插入本地图片之后，部署到GitHub中图片无法显示的问题

<!--more-->

## 安装PicGo

在GitHub仓库中进行安装，[安装链接点这里](https://github.com/Molunerfinn/PicGo/releases)，其中选择2.3.1稳定版

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231640443.png" alt="image-20230523164018405" style="zoom:50%;" />

安装完成之后，打开PicGo

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231640847.png" alt="image-20230523164031796" style="zoom:50%;" />

## 配置GitHub

### 创建仓库

设置仓库名，选公开

![image-20230523163853921](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231638964.png)

### 设置token

找到头像，点击`settings`，之后翻到最下面，找到`Developer settings`

![image-20230523164109708](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231641764.png)

选择`classic`的`Tokens`，然后创建，我选择永不到期，记住这个tokens

![image-20230523164135163](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231641208.png)

### 配置PicGo

#### 图床设置

设置图床时，主要是分支的问题，查看自己图床仓库的分支是什么就填什么

我的是`master`，所以我填`master`

![image-20230523164154424](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231641465.png)

之后就是`token`，填写刚才生成的`token`

最后是设置自定义域名，我的设置为：

```bash
https://cdn.jsdelivr.net/gh/zzziCode/PicGoImg@master
//将gh之后的部分改成自己的仓库名和分支即可
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231642080.png" alt="image-20230523164229033" style="zoom:67%;" />

#### PicGo设置

主要是设置快捷键，触发快捷键会将剪切板中的最新图像上传到图床中

![image-20230523164251193](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231642244.png)

之后的配置按需求配置

---

> 此时PicGo与GitHub的配置基本结束，如果出现上传失败的情况，可以修改`hosts`文件

![image-20230523164333617](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231643655.png)

打开之后在最后加上，保存即可

如果出现保存失败，将`hosts`中所有数据复制一份，存储到其他路径下的`hosts`文件中，覆盖当前目录下的`hosts`即可

```bash
140.82.113.3      github.com
140.82.114.20     gist.github.com
151.101.184.133    assets-cdn.github.com
151.101.184.133    raw.githubusercontent.com
151.101.184.133    gist.githubusercontent.com
151.101.184.133    cloud.githubusercontent.com
151.101.184.133    camo.githubusercontent.com
151.101.184.133    avatars0.githubusercontent.com
199.232.68.133     avatars0.githubusercontent.com
199.232.28.133     avatars1.githubusercontent.com
151.101.184.133    avatars1.githubusercontent.com
151.101.184.133    avatars2.githubusercontent.com
199.232.28.133     avatars2.githubusercontent.com
151.101.184.133    avatars3.githubusercontent.com
199.232.68.133     avatars3.githubusercontent.com
151.101.184.133    avatars4.githubusercontent.com
199.232.68.133     avatars4.githubusercontent.com
151.101.184.133    avatars5.githubusercontent.com
199.232.68.133     avatars5.githubusercontent.com
151.101.184.133    avatars6.githubusercontent.com
199.232.68.133     avatars6.githubusercontent.com
151.101.184.133    avatars7.githubusercontent.com
199.232.68.133     avatars7.githubusercontent.com
151.101.184.133    avatars8.githubusercontent.com
199.232.68.133     avatars8.githubusercontent.com
```

## 配置腾讯云COS

### 对象存储

直接进入[腾讯云](https://console.cloud.tencent.com/)主页，搜索对象存储

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231644961.png" alt="image-20230523164435913" style="zoom:50%;" />

### 创建存储桶

创建存储桶之后填写基本信息，访问权限设置为公有读私有写，之后的选项默认，创建好存储桶之后，开始配置`PicGo`

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231646724.png" alt="image-20230523164638687" style="zoom:67%;" />

重要的三个信息需要设置好，其余的默认

### 新建密钥

进入[腾讯云](https://console.cloud.tencent.com/)官网，搜索访问密钥，进入控制页面，之后新建密钥，保存好`APPID`、`SecretId`、`SecretKey`三个东西

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231647433.png" alt="image-20230523164742396" style="zoom:67%;" />

### PicGo的配置

进入PicGo，打开图床设置，依次填入以下信息：

```bash
设定SecretKey：腾讯云的SecretId
设定SecretKey：腾讯云的SecretKey
设定Bucket：填写自己的bucket名称，就是新建存储桶时填写的名称
设定APPid：创建密钥时的APPID
设定存储区域：新建存储桶时的所属地域，例如ap-shanghai 
设定存储路径：上传的文件存储在什么路径下，例如img/
剩下两个没有就不填
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231648462.png" alt="image-20230523164829413" style="zoom:50%;" />

之后即可使用腾讯云COS的服务上传图片

### 防盗链设置

设置防盗链之后，可以避免其他人非法引用存储桶中的数据，造成流量消耗过大

首先进入存储桶列表中的配置管理

![image-20230523165250859](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231652914.png)

之后选择防盗链设置，将允许访问存储同的地址放入白名单中

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231655285.png" alt="image-20230523165554232" style="zoom:60%;" />

其中，`空refer`是在本地Typora中编写博客时访问存储桶

头两个是博客地址，不能加通配符，否则会出现错误

中间的localhost是为了本地渲染博客也可以实现显示图片的效果，端口根据自己设定的端口而定

例如：

```bash
helloworld.github.io
```

## 配置Typora

typora可以实现粘贴复制的图像自动进行上传，并将粘贴的图像路径改为图床中的路径

演示效果如下：

![](https://cdn.jsdelivr.net/gh/zzziCode/PicGoImg@master/202305222310076.png)

上传成功为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305231648432.png" alt="image-20230523164851341" style="zoom:67%;" />

### 配置过程

打开文件中的偏好设置，路径选择PicGo的安装路径即可

![](https://cdn.jsdelivr.net/gh/zzziCode/PicGoImg@master/202305222318931.png)

## 总结

配置完成即可无痛使用Typora+GitHub+PicGo编写博客，但是GitHub会出现上传失败的问题，于是也提供了腾讯云COS的配置

