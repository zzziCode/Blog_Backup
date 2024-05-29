---
title: "Java的移位操作符"
description: "Java的移位操作符"
keywords: "Java的移位操作符"

date: 2024-05-15T19:40:38+08:00
lastmod: 2024-05-15T19:40:38+08:00

categories:
  - 学习笔记
tags:
  - Java


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
#url: "java的移位操作符.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>🧢 Java的移位操作符

介绍Java中的移位操作符,一共有三种,从数据底层的存储开始介绍

<!--more-->

## 数据在底层的存储

数据在计算机的底层统一采用补码的二进制形式存储,而Java的移位操作符只能作用于`long`,`int`,`short`,`char`四种基本整数类型上,所以这里用`int`进行介绍,其余的差别就是在所占的字节数上,这里总结Java中所有基本数据类型的占位情况

| 数据类型  | 位数 | 字节数 | 默认值  |
| :-------: | :--: | :----: | :-----: |
| `boolean` |  1   |   -    |  false  |
|  `byte`   |  8   |   1    |    0    |
|  `short`  |  16  |   2    |    0    |
|  `char`   |  16  |   2    | 'u0000' |
|   `int`   |  32  |   4    |    0    |
|  `float`  |  32  |   4    |   0f    |
|  `long`   |  64  |   8    |   0L    |
| `double`  |  64  |   8    |   0d    |

### 正数

正数的补码就是其自身,例如整数5的二进制形式为`00000000 00000000 00000000 00000101`,补码也是`00000000 00000000 00000000 00000101`,对正数进行移位操作很简单

### 负数

负数的补码略微复杂一些,需要现将负数的原码表示出来,然后转换成反码,最后转换成补码,首先负数转换成原码需要注意,最高位是一个符号位

例如-5的原码是`10000000 00000000 00000000 00000101`,最高位是一个符号位

之后将原码转换成反码,除了符号位,剩下的每一位取反即可,-5的反码是`11111111 11111111 11111111 11111010`

最后将反码转换成补码,就是在反码的基础上对反码加1即可,-5的补码是`11111111 11111111 11111111 11111011`

## 移位操作符

### 左移

左移没有什么特殊的地方,高位直接覆盖,包括负数的符号位也直接覆盖,低位补零即可,例如-5的计算机存储形式为`11111111 11111111 11111111 11111011`,左移两位变成`11111111 11111111 11111111 11101100`,这是一个数的补码形式,将其转换成反码(补码`-1`)为`11111111 11111111 11111111 11101011`,进一步将其转换成原码(除了符号位都取反)为`10000000 00000000 00000000 00010100`,可以看出这是-20的原码,也就是说-5左移两位变成了-20

代码测试为:

```java
public static void main(String[] args) {
    int i = -5;
    System.out.println("移动之前:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
    i <<= 2;
    System.out.println("移动之后:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
}
```

### 带符号右移

带符号右移顾名思义就是向右移动时带着自己的符号位,对于-5来说,计算机中存储形式为`11111111 11111111 11111111 11111011`,向右带符号移动两位变成`11111111 11111111 11111111 11111110`,这是一个数的补码形式,将其转换成反码为`11111111 11111111 11111111 11111101`,进一步将其转换成原码为`10000000 00000000 00000000 00000010`,这是-2的原码表示,也就是说,-5带符号右移两位变成了-2

代码测试为:

```java
public static void main(String[] args) {
    int i = -5;
    System.out.println("移动之前:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
    i >>= 2;
    System.out.println("移动之后:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
}
```

### 无符号右移

无符号右移就是不带上高位的符号位,向右移动时,高位一直补零即可,负数被移动之后,很大可能上会变得很大,例如-5的计算机存储形式为`11111111 11111111 11111111 11111011`,无符号右移两位为`00111111 11111111 11111111 11111110`,看最高位变成了0,也就是变成了一个正数,此时这个补码就是原码,转换之后变成了1073741822,成为了一个很大的数

测试程序为

```java
public static void main(String[] args) {
    int i = -5;
    System.out.println("移动之前:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
    i >>>= 2;
    System.out.println("移动之后:" + i);
    System.out.println("补码为:" + Integer.toBinaryString(i));
}
```

## 总结

对于整数来说,分为两种,正数不管怎么移动,因为没有符号位,或者说符号位为0不影响最终的结果,所以较为简单,但是负数本身在计算机中的存储方式就有一些变化,需要计算出原码,然后除符号位取反加一得到最终的补码表示之后再开始移动,左移正常移动,带符号右移时左边加1,无符号右移时左边加0
