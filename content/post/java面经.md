---
title: "Java面经"
description: "java面经"
keywords: "java面经"

date: 2024-04-17T22:33:00+08:00
lastmod: 2024-04-17T22:33:00+08:00

categories:
  - 面试
tags:
  - 面经
  - java

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
#url: "java面经.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> java面经

<!--more-->

#### 什么是JVM

1. 是java虚拟机，有了它java才有了跨平台的特性，他屏蔽了底层具体平台的差异，使得java可以跨平台
2. java编译成统一的.class文件，然后交给不同平台的虚拟机，解释成不同平台的机器指令完成跨平台
3. 任何可以通过java编译的语言都可以放到jvm上解释执行，例如Groovy，Kotlin

#### JDK，JRE，JVM的关系

1. JDK是java的开发包，内部包含JRE运行时环境
2. JRE是java的运行时环境，内部包含JVM
3. JVM编译java语言的字节码文件，屏蔽平台的差异性，使得java语言可以跨平台

#### JVM的结构

1. 类加载器：主要负责将.class文件加载到内存中，主要有四种：
   - 启动类加载器：用来加载java核心类库，无法被java程序直接引用
   - 扩展类加载器：加载java的扩展库，主要是从jvm提供的扩展库中加载java类
   - 系统类加载器：通过系统类路径加载本地化的文件，java应用的类都是由这个加载器加载的
   - 用户自定义类加载器：继承一个类实现自定义的类加载器
2. 运行时数据区：执行java代码时，需要在内存中处理各种类型的数据，这些内存区域主要分为：
   - 方法区
   - 堆
   - 栈
   - 程序计数器
   - 本地方法栈
3. 执行引擎：包含一个虚拟处理器，即时编译器（JIT），垃圾回收器（GC），用来执行字节码文件

#### 类加载器ClassLoader的工作过程

1. 加载：通过类的全限定名获取类的class文件的二进制字节流，为其创建一个class对象
2. 链接：
   - 验证：确保被加载的类的正确性，比如语法，语义等
   - 准备：给类中的静态变量分配内存并加上默认值
   - 解析：将类的符号引用转换成直接引用
