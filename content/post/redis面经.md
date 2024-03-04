---
title: "Redis面经"
description: "redis面经"
keywords: "redis面经"

date: 2024-03-04T12:57:25+08:00
lastmod: 2024-03-04T12:57:25+08:00

categories:
  - 面试
tags:
  - redis
  - 面经

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
toc: false
# 绝对访问路径
# Absolute link for visit
#url: "redis面经.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🛅 redis面经

本文主要介绍一些redis的常见面试题，文章长期更新

<!--more-->

#### redis定义

redis是一种基于内存的数据库，数据读写都在内存中完成，因此读写速度很快，常用语缓存，消息队列，分布式锁等场景

#### redis和Memcached的区别

1. 都是基于内存的数据库，常用来作缓存
2. 都有过期策略，性能都很高

> 区别

1. redis支持的数据类型更丰富，Memcached只支持key-value
2. redis支持数据持久化，可以将内存中的数据同步到磁盘中
3. redis原生就支持集群，Memcached只能通过客户端来实现集群
4. redis功能更强大

#### 为什么使用redis做mysql的缓存

1. redis具备高性能：数据经过redis缓存在内存中，访问速度会大大加快
2. redis具备高并发：针对请求量来说，redis每秒能够处理的请求量是mysql的十倍以上

所以我们使用redis作缓存，这样mysql中的一部分数据缓存在了redis中，可以减小数据访问的事件，提高系统的运行效率

#### redis的数据类型

1. String：可存储字符串，整数，浮点数，<u>常用来缓存对象，技术，和一些共享信息</u>
2. Hash：键值对形式的散列表，<u>常用来缓存对象</u>
3. List：链表，每个节点都是一个字符串，<u>常用来做消息队列，要自己实现全局唯一消息id</u>
4. Set：字符串的无序集合：<u>常用来做集合之间的聚合计算（交并差）</u>
5. Zset：字符串的不允许重复的集合，每个元素带一个分数，<u>常用来进行排序</u>

> 随着版本更新，后面又新增了一些数据类型

1. BitMap：二进制状态的场景，签到，判断是否登录
2. HyperLoglog：数据统计，比如网页访问计数
3. GEO：存储地理位置信息
4. Stream：消息队列，相比于List实现的消息队列，Stream可以自动生成全局唯一消息id

#### redis中数据类型的实现原理

<img src="https://cdn.xiaolincoding.com//mysql/other/9fa26a74965efbf0f56b707a03bb9b7f.png" alt="img" style="zoom: 43%;" />

1. String：SDS(简单动态字符串)，不仅可以保存文本数据，还可以保存二进制数据，内部提供很多方便且安全的api(获取字符串长度，拼接字符串)
   1. List：当元素个数小于512个且每个元素值都小于64字节时使用压缩列表，否则使用双向链表，**新版本**中使用quickList（节点是压缩列表，并将链表分段，段间使用双向链表）
   2. Hash：当元素个数小于512个且每个元素值都小于64字节时使用压缩链表，否则使用哈希表，新版本中使用listpack（紧凑列表）**代替**压缩列表
   3. Set：元素个数小于512使用整数列表，否则使用哈希表
   4. ZSet：元素个数小于128且元素大小小于64字节使用压缩列表，否则使用跳表（给有序链表的节点加上索引，使得有序链表可以随机访问），新版本使用listpack代替压缩链表
