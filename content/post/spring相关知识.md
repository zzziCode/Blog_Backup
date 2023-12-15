---
title: "Spring相关知识"
description: "spring相关知识"
keywords: "spring相关知识"

date: 2023-12-11T15:23:51+08:00
lastmod: 2023-12-11T15:23:51+08:00

categories:
  - 面试
tags:
  - spring

# 原文作者
# Post's origin author name
author: zzzi
# 开启数学公式渲染，可选值： mathjax, katex
# Support Math Formulas render, options: mathjax, katex
math: mathjax
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
#toc: false
# 绝对访问路径
# Absolute link for visit
#url: "spring相关知识.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🤔 spring相关知识

本文总结了spring框架中的一些核心知识，由于是一个不连续的学习过程，笔记中的内容也不是连续的，但是每一个知识点都值得分析，后期会对新的知识点进行补充

<!--more-->

初始化前后的相关知识！！！

依赖注入的相关知识，**Resource**是先byName在byType，**Autowired**是先byType再byName，如果存在多个相同类型的bean，需要配合**Qualifier**一起使用

AOP的相关知识，对于代理对象本身，其属性都为空，但是内部的target，也就是真正被代理的对象本身的属性不为空。AOP要么是继承，要么是实现接口，代理对象内部都会有一个target属性保存了真正被代理的对象，然后有相同的方法，从而执行AOP的逻辑，不管是继承还是实现接口，目的都是为了得到被代理对象的结构，有了结构之后，可以在相同的结构中对被代理对象进行增强，外部无感知

代理对象本身的属性全部为空，但是代理对象内部的target保存了被代理对象，这个对象中的属性不为空

事务的执行流                         程

  
