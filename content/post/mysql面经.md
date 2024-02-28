---
title: "Mysql面经"
description: "mysql面经"
keywords: "mysql面经"

date: 2024-02-28T09:56:32+08:00
lastmod: 2024-02-28T09:56:32+08:00

categories:
  - 面试
tags:
  - mysql
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
#url: "mysql面经.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 📈 mysql面经

本文中主要介绍一些mysql的面试笔记，文章持续更新

<!--more-->

#### sql语句执行的流程

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402280956296.png" alt="查询语句执行流程" style="zoom: 50%;" />

1. 连接器：建立连接（TCP），之后所有的查询操作都会先判断当前用户的权限，长时间（28800）不用的连接会被释放，并且连接数不能超过151

2. 查询缓存：select会查询缓存，看是否曾经执行过，对于更新频繁的表，缓存基本无用

3. 解析SQL：主要是词法分析和语法分析，分析成功就会得到一个SQL**语法树**

4. 执行SQL：

   - 预处理SQL：替换*，判断字段和表是否存在

   - 优化SQL：使得SQL执行的效率变高，例如存在主键索引（id）和普通索引（其余字段加索引）时，会判断使用哪个索引的效率更高

   - 执行SQL：与存储引擎交互查询数据

     - 主键索引查询：直接利用主键索引查询

     - 全表扫描：全表扫描一遍

     - 索引下推：将索引的判断工作交给存储引擎端，减少回表操作，这里涉及到一个联合索引的操作，由于存在最左匹配原则，当出现范围查询时，联合索引的范围查询可以使用索引，但是剩下的字段无法使用索引（因为局部无序），所以剩下的字段需要进行回表，将存储引擎查询到的数据在服务端再进行筛选，索引下推可以使得这个筛选工作在存储引擎端完成，从而减小回表操作，提高效率，**举例**：

       > `select * from t_table where a > 1 and b = 2`，联合索引（a, b）
       >
       > 此时联合索引会先按照a排序，然后存储引擎找到所有a>1的数据的id，在这些数据里，b没有进行排序，所以联合索引失效，这些数据需要进行回表进一步筛选，索引下推可以将筛选的工作交给存储引擎端，减小数据传输的事件

#### mysql一行记录如何存储

> 数据存储由行，页，区，段组成，每一行数据分为额外信息和真实数据，额外信息包含变长字段的长度以及NULL值列表（二者可能不存在），真实数据包含三个隐藏字段（隐藏自增id，事务id，上一个版本指针）以及真实值

一旦建立数据库中的一张表，那么就会在`/var/lib/mysql/` 中建立一个对应的数据库，内部新增三个文件：

```mysql
db.opt  
表名.frm  
表名.ibd
```

1. db.opt：存储数据库的默认字符集和校验规则
2. 表名.frm ：存储表结构信息
3. 表名.ibd：存储表中的数据，默认存储在这个**独占表空间文件**（.ibd文件）中，但是一个参数可以控制数据存放在**共享表空间文件**（.ibdata1文件）中

mysql中数据存储按照**段，区，页，行**来组织，双向链表中连续的页在物理上也连续，一个区有1mb，区内有64个连续的页，而多个区组成一个

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402281055554.png" alt="img" style="zoom:43%;" />

对于一行数据，现在默认采用`dynamic`，这是从`compact`改进得到的

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402281055841.png" alt="img" style="zoom:50%;" />

1. 变长字段就存储了行记录中变长字段的具体长度，**逆序**存放（读指针指向额外信息和真实数据之间，向左读可以读到额外信息，向右读可以读到真实数据）

2. NULL值使用一个**二进制位**记录，也是逆序存放，一行记录的某一列为NULL，二进制位的对应位置就为1，字段不足八位高位补0

> 上面两位都不是必须的，表结构中有变长或者允许为空时才存在这两个信息

3. 记录头信息中存放当前行记录是否被删除，下一条记录的位置等信息
4. 真实数据存在三个隐藏列：
   - row_id：数据没有主键以及非空的唯一字段时增加这个隐藏的自增id
   - trx_id：事务id，标记由哪个事务生成
   - roll_pointer：上一个版本的指针

#### mysql中数据页的格式

数据页（默认16kb）中存放的是一行一行的数据，是最小的查询单位，多行数据之间进行分组并建立页目录，页目录中的一个槽指向一个分组中的最大记录，相当于数据页中的行数据还进行了分组，查询时是二分+顺序的方式

数据页之间的组织方式是双向链表，数据页内部的行数据组织方式是按主键顺序单向链表

#### 聚簇索引和二级索引的区别

1. 聚簇索引：通常是主键索引，或者是非空的唯一字段索引，极端情况为隐式的自增id索引，聚簇索引中叶子结点存放的是数据
2. 二级索引：非主键字段的索引，叶子结点存放的是主键id，所以查询到id之后还会进一步利用聚簇索引查询到真实的数据，这一操作叫做回表

#### varchar(n)中的n最大取值是多少

保证真实数据+变长字段所需字节+NULL值列表<=65535字节

#### 行溢出怎么处理

一页大小为16kb，也就是16384字节，而一行数据最大为65535字节，如果一页存储不了一行数据，那么多余的数据就会存储在**溢出页**中，存放真实数据的地址中会分配一部分指向溢出页的地址

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402281056468.png" alt="img" style="zoom:33%;" />
