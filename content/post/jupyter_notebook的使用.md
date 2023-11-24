---
title: "Jupyter_notebook的使用"
description: "jupyter_notebook的使用"
keywords: "jupyter_notebook的使用"

date: 2023-09-04T20:30:41+08:00
lastmod: 2023-09-04T20:30:41+08:00

categories:
  - 教程
tags:
  - jupyter


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
#url: "jupyter_notebook的使用.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>jupyter_notebook的使用

本教程旨在**不从零**开始搭建一个`jupyter notebook`的环境并用来学习，默认已经安装了`anaconda`，可以解决现有的项目导入`jupyter notebook`中时无法指定conda虚拟环境用来隔离python环境的问题，按照教程操作之后，可以实现一个`jupyter notebook`对应一个虚拟环境

<!--more-->

## 安装

需要现在虚拟环境中安装jupyter notebook，才能正常使用

1. 创建一个虚拟环境

   ```bash
   conda create -n d2l python==3.9
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055496.png" alt="image-20230904203640098" style="zoom:50%;" />

   此时anaconda的虚拟环境中就带上了这个d2l虚拟环境

2. 打开`anaconda`的`Navigator`：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055498.png" alt="image-20230904203437984" style="zoom:50%;" />

3. 在anaconda的对应的虚拟环境界面中安装jupyter notebook

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055499.png" alt="image-20230904203802265" style="zoom:50%;" />

   如果没有安装jupyter notebook，显示的是install，点击install即可安装，此时还无法在已有项目中使用对应的虚拟环境

4. 安装ipykernel

   需要先激活对应的虚拟环境

   ```bash
   conda activate d2l
   conda install ipykernel
   ```

   安装ipykerbel之后，才能在jupyter notebook中使用虚拟环境，对应的虚拟环境才会显示

   > 此时可以正常在浏览器中使用jupyter notebook并且指定虚拟环境

## 错误解决

1. 修改项目地址

上面的步骤执行完毕之后，jupyter notebook就可以运行并选择虚拟环境了，可是项目的地址还是在C盘中，此时想要将这个虚拟环境中的jupyter notebook的项目地址改成自己指定的位置，需要进行修改

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055500.png" alt="image-20230904204227970" style="zoom:50%;" />

选择打开对应的jupyter notebook的文件位置，然后修改其属性

右键对应jupyter notebook的属性，将目标中的`"%USERPROFILE%/"`修改成自己的项目地址，例如：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055501.png" alt="image-20230904204421530" style="zoom:50%;" />

我修改成了G:\D2L，后面打开jupyter notebook的时候，自动定位到这个项目中，并且可以查询到当前使用的虚拟环境是什么：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055502.png" alt="image-20230904204720140" style="zoom:50%;" />

2. Navigator中启动jupyter notebook无法自动弹出浏览器

   此时需要修改配置文件

   - 对应虚拟环境中执行下面的代码生成或者覆盖原有的配置文件

     ```bash
     jupyter notebook --generate-config
     ```

   - 在`C:\Users\zzzi\.jupyter`中找到对应的配置文件进行修改

     ![image-20230904205127431](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202309042055503.png)

     在`# c.NotebookApp.browser = ''`的下面添加三句代码

     ```python
     import webbrowser
     webbrowser.register("Chrome",None,webbrowser.GenericBrowser(u"C:\Program Files\Google\Chrome\Application\chrome.exe"))
     c.NotebookApp.browser = u'Chrome'
     ```

     这里我使用的浏览器是chrome，如果向使用其他的浏览器对应替换即可
     
     > 这一步只需要修改一次，后续的jupyter notebook都可以正常打开，不用重复配置

> 这一步之后，可以直接在Navigator中打开jupyter notebook，并且使用的环境是指定的虚拟环境，也可以自动弹出浏览器

3. 报错`500 : Internal Server Error`

   在虚拟环境中安装`nbconvert`

   ```bash
   pip install --upgrade --user nbconvert
   ```

## 总结

为了在jupyter notebook中使用指定的虚拟环境，达到一个项目一个虚拟环境的目的，提供了具体的步骤，并且可以修改项目地址，解决了jupyter notebook无法正常弹出的问题

按照教程操作之后，可以在开始菜单中直接一步打开jupyter notebook



