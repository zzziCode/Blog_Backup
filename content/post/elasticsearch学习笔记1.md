---
title: "Elasticsearch学习笔记1"
description: "elasticsearch学习笔记1"
keywords: "elasticsearch学习笔记1"

date: 2024-02-29T20:30:00+08:00
lastmod: 2024-02-29T20:30:00+08:00

categories:
  - 学习笔记
tags:
  - elasticsearch
  - 微服务

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
#url: "elasticsearch学习笔记.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🔍 elasticsearch学习笔记1

本节中主要介绍了elasticsearch中的一些基本概念，并于mysql中的一些概念进行了对比，分析了elasticsearch与mysql适用的场景。并且介绍了elasticsearch中索引库和文档的DSL语句的操作语法，主要是索引库的增删改查以及文档的增删改，关于文档如何进行查询，在下一节中介绍。之后还使用了java封装的RestAPI来使用java代码操作索引库和文档

<!--more-->

# 1.初识elasticsearch

## 1.1.了解ES

### 1.1.1.elasticsearch的作用

elasticsearch是一款非常强大的开源搜索引擎，具备非常多强大功能，可以帮助我们从海量数据中快速找到需要的内容

例如：

- 在GitHub搜索代码

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033785.png" alt="image-20210720193623245" style="zoom:50%;" />

- 在电商网站搜索商品

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033787.png" alt="image-20210720193633483" style="zoom:50%;" />

- 在百度搜索答案

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033788.png" alt="image-20210720193641907" style="zoom:50%;" />

- 在打车软件搜索附近的车

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033790.png" alt="image-20210720193648044" style="zoom:50%;" />

### 1.1.2.ELK技术栈

elasticsearch结合kibana、Logstash、Beats，也就是elastic stack（ELK）。被广泛应用在日志数据分析、实时监控等领域：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033791.png" alt="image-20210720194008781" style="zoom:50%;" />

而elasticsearch是elastic stack的核心，负责存储、搜索、分析数据。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033792.png" alt="image-20210720194230265" style="zoom:33%;" />

### 1.1.3.elasticsearch和lucene

elasticsearch底层是基于**lucene**来实现的。

**Lucene**是一个Java语言的搜索引擎类库，是Apache公司的顶级项目，由DougCutting于1999年研发。官网地址：https://lucene.apache.org/ 。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033793.png" alt="image-20210720194547780" style="zoom: 33%;" />

**elasticsearch**的发展历史：

- 2004年Shay Banon基于Lucene开发了Compass
- 2010年Shay Banon 重写了Compass，取名为Elasticsearch。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033794.png" alt="image-20210720195001221" style="zoom:33%;" />

### 1.1.4.为什么不是其他搜索技术？

目前比较知名的搜索引擎技术排名：

![image-20210720195142535](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033795.png)

虽然在早期，Apache Solr是最主要的搜索引擎技术，但随着发展elasticsearch已经渐渐超越了Solr，独占鳌头：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033796.png" alt="image-20210720195306484" style="zoom:33%;" />

### 1.1.5.总结

什么是elasticsearch？

- 一个开源的分布式**搜索**引擎，可以用来实现搜索、日志统计、分析、系统监控等功能

什么是elastic stack（ELK）？

- 是以elasticsearch为核心的技术栈，包括beats、Logstash、kibana、elasticsearch

什么是Lucene？

- 是Apache的开源搜索引擎类库，提供了搜索引擎的核心API

## 1.2.倒排索引

**倒排索引**的概念是基于MySQL这样的正向索引而言的。

### 1.2.1.正向索引

那么什么是正向索引呢？例如给下表（tb_goods）中的id创建索引：

![image-20210720195531539](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033797.png)

如果是根据id查询，那么直接走索引，查询速度非常快。这里的正排索引指的是根据id查询数据

但如果是基于title做模糊查询，只能是逐行扫描数据，流程如下：

1）用户搜索数据，条件是title符合`"%手机%"`

2）逐行获取数据，比如id为1的数据

3）判断数据中的title是否符合用户搜索条件

4）如果符合则放入结果集，不符合则丢弃。回到步骤1

逐行扫描，也就是全表扫描，随着数据量增加，其查询效率也会越来越低。当数据量达到数百万时，就是一场灾难。

### 1.2.2.倒排索引

倒排索引中有两个非常重要的概念：

- 文档（`Document`）：用来搜索的数据，其中的每一条数据就是一个文档。例如一个网页、一个商品信息
- 词条（`Term`）：对文档数据或用户搜索数据，利用某种算法分词，得到的具备含义的词语就是词条。例如：我是中国人，就可以分为：我、是、中国人、中国、国人这样的几个词条

**创建倒排索引**是对正向索引的一种特殊处理，流程如下：

- 将每一个文档的数据利用算法分词，得到一个个词条
- 创建表，每行数据包括词条、词条所在文档id、位置等信息
- 因为词条唯一性，可以给词条创建索引，例如hash表结构索引

如图：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033798.png" alt="image-20210720200457207" style="zoom:50%;" />

> 正向索引就是根据id查找到数据，而倒排索引是将数据进行分词，然后根据分词的结果查找数据的id，从而得到最终的搜索结果

倒排索引的**搜索流程**如下（以搜索"华为手机"为例）：

1）用户输入条件`"华为手机"`进行搜索。

2）对用户输入内容**分词**，得到词条：`华为`、`手机`。

3）拿着词条在**倒排索引**中查找，可以得到包含词条的文档id：1、2、3。

4）拿着文档id到**正向索引**中查找具体文档。

> 相当于想用elasticsearch搜索到想要的数据id，然后在mysql中使用数据id查询到想要的数据，倒排索引就是将数据中的信息进行分词，根据查询条件匹配到多个数据id

如图：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033799.png" alt="image-20210720201115192" style="zoom:50%;" />

虽然要**先查询倒排索引，再查询倒排索引**，但是无论是词条、还是文档id都建立了索引，查询速度非常快！无需全表扫描。看起来查询了两次，但是在海量数据面前，这种速度还是比全表扫描快

### 1.2.3.正向和倒排

那么为什么一个叫做正向索引，一个叫做倒排索引呢？

- **正向索引**是最传统的，**根据id索引**的方式。但根据词条查询时，必须先逐条获取每个文档，然后判断文档中是否包含所需要的词条，是**根据文档找词条的过程**。

  > 这种方式只适合按照id来搜索，当数据量过大并且想要搜索数据中的某个词条时，必须使用全表扫描，会大大降低搜索效率

- 而**倒排索引**则相反，是先找到用户要搜索的词条，根据词条得到词条的文档的id，然后根据id获取文档。是**根据词条找文档的过程**。这种设计使得从数据中找某一个词条非常方便，尤其是海量数据的情况下，当数据量很小时，倒排索引不如全表扫描的时间快

是不是恰好反过来了？

那么两者方式的优缺点是什么呢？

**正向索引**：

- 优点：
  - 可以给多个字段创建索引
  - 根据索引字段搜索、**排序**速度非常快
- 缺点：
  - 根据非索引字段，或者索引字段中的部分词条查找时，只能全表扫描。

**倒排索引**：

- 优点：
  - 根据词条搜索、**模糊搜索**时，速度非常快
- 缺点：
  - 只能给词条创建索引，而不是字段
  - 无法根据字段做排序

## 1.3.es的一些概念

elasticsearch中有很多独有的概念，与mysql中略有差别，但也有相似之处。

### 1.3.1.文档和字段

elasticsearch是面向**文档（Document）**存储的，可以是数据库中的一条商品数据，一个订单信息。**文档**数据会被序列化为**json格式**后存储在elasticsearch中：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033800.png" alt="image-20210720202707797" style="zoom: 33%;" />

而Json文档中往往包含很多的**字段（Field）**，类似于数据库中的列。

> 文档对应于数据库中的元组（一条记录），字段对应于数据库中的属性（列）

### 1.3.2.索引和映射

**索引（Index）**，就是相同类型的文档的集合。

例如：

- 所有用户文档，就可以组织在一起，称为用户的索引；
- 所有商品的文档，可以组织在一起，称为商品的索引；
- 所有订单的文档，可以组织在一起，称为订单的索引；

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033801.png" alt="image-20210720203022172" style="zoom:33%;" />

因此，我们可以把索引当做是数据库中的表。

数据库的表会有约束信息，用来定义表的结构、字段的名称、类型等信息。因此，索引库中就有**映射（mapping）**，是索引中文档的字段约束信息，类似表的结构约束。映射对应于数据库中的表结构

### 1.3.3.mysql与elasticsearch

我们统一的把mysql与elasticsearch的概念做一下对比：

| **MySQL** | **Elasticsearch** | **说明**                                                     |
| --------- | ----------------- | ------------------------------------------------------------ |
| Table     | Index             | 索引(index)，就是**文档的集合**，类似数据库的表(table)       |
| Row       | Document          | 文档（Document），就是一条条的数据，类似数据库中的行（Row），文档都是JSON格式 |
| Column    | Field             | 字段（Field），就是JSON文档中的字段，类似数据库中的列（Column） |
| Schema    | Mapping           | Mapping（映射）是索引中文档的约束，例如字段类型约束。类似数据库的表结构（Schema） |
| SQL       | DSL               | DSL是elasticsearch提供的JSON风格的请求语句，用来操作elasticsearch，实现CRUD，有点类似于Restful风格 |

是不是说，我们学习了elasticsearch就不再需要mysql了呢？

并不是如此，两者各自有自己的擅长之处：

- Mysql：擅长事务类型操作，可以确保数据的**安全和一致性**

- Elasticsearch：擅长海量数据的搜索、分析、计算，此时不太关注数据的一致性和安全性，主要关注查询性能

因此在企业中，往往是两者结合使用：

- 对**安全**性要求较高的写操作，使用mysql实现
- 对**查询**性能要求较高的搜索需求，使用elasticsearch实现
- 两者再基于某种方式，实现数据的同步，保证一致性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033802.png" alt="image-20210720203534945" style="zoom: 50%;" />

## 1.4.分词器

分词器的作用是什么？

- 创建倒排索引时对文档分词，便于后期搜索
- 用户搜索时，对输入的内容分词，分词之后再去文档中匹配

IK分词器有几种模式？

- ik_smart：智能切分，粗粒度
- ik_max_word：最细切分，细粒度

IK分词器如何拓展词条？如何停用词条？

- 利用config目录的IkAnalyzer.cfg.xml文件添加拓展词典和停用词典，有了词典之后，分词器就会知道某些词不需要划分，某些字会组成一个词
- 在词典中添加拓展词条或者停用词条

# 2.索引库操作

索引库就类似数据库表，mapping映射就类似表的结构。

我们要向es中存储数据，必须先创建“库”和“表”。建立之后才能向其中存储数据

## 2.1.mapping映射属性

mapping是对索引库中文档的约束，类似于mysql中的表结构约束，常见的mapping属性包括：

- type：字段数据类型，常见的简单类型有：
  - 字符串：text（可分词的文本）、keyword（精确值，例如：品牌、国家、ip地址）
  - 数值：long、integer、short、byte、double、float、
  - 布尔：boolean
  - 日期：date
  - 对象：object
- index：是否创建索引，默认为true，不参与搜索的字段就可以不创建索引
- analyzer：使用哪种分词器
- properties：该字段的子字段

例如下面的json文档：

```json
{
    "age": 21,
    "weight": 52.1,
    "isMarried": false,
    "info": "黑马程序员Java讲师",
    "email": "zy@itcast.cn",
    "score": [99.1, 99.5, 98.9],
    "name": {
        "firstName": "云",
        "lastName": "赵"
    }
}
```

对应的每个字段映射（mapping）：

- age：类型为 integer；参与搜索，因此需要index为true；无需分词器
- weight：类型为float；参与搜索，因此需要index为true；无需分词器
- isMarried：类型为boolean；参与搜索，因此需要index为true；无需分词器
- info：类型为字符串，需要分词，因此是text；参与搜索，因此需要index为true；分词器可以用ik_smart
- email：类型为字符串，但是不需要分词，因此是keyword；**不参与**搜索，因此需要index为`false`；无需分词器
- score：虽然是数组，但是我们只看元素的类型，类型为float；参与搜索，因此需要index为true；无需分词器
- name：类型为object，需要定义多个子属性
  - name.firstName；类型为字符串，但是不需要分词，因此是keyword；参与搜索，因此需要index为true；无需分词器
  - name.lastName；类型为字符串，但是不需要分词，因此是keyword；参与搜索，因此需要index为true；无需分词器

## 2.2.索引库的CRUD

这里我们统一使用Kibana编写DSL的方式来演示。

### 2.2.1.创建索引库和映射

#### 基本语法：

- 请求方式：PUT
- 请求路径：/索引库名，可以自定义
- 请求参数：mapping映射

格式：

```json
PUT /索引库名称
{
  "mappings": {
    "properties": {
      "字段名":{
        "type": "text",
        "analyzer": "ik_smart"
      },
      "字段名2":{
        "type": "keyword",
        "index": "false"
      },
      "字段名3":{
        "properties": {
          "子字段": {
            "type": "keyword"
          }
        }
      },
      // ...略
    }
  }
}
```

#### 示例：

```sh
PUT /heima
{
  "mappings": {
    "properties": {
      "info":{
        "type": "text",
        "analyzer": "ik_smart"
      },
      "email":{
        "type": "keyword",
        "index": "false"
      },
      "name":{
        "properties": {
          "firstName": {
            "type": "keyword"
          }
        }
      },
      // ... 略
    }
  }
}
```

> 这段DSL创建了一个名为heima的索引库，现在显示了三个字段，每个字段有什么类型，是否建立索引，是否分词都有规定，这个

### 2.2.2.查询索引库

**基本语法**：

- 请求方式：GET

- 请求路径：/索引库名

- 请求参数：无

**格式**：

```html
GET /索引库名
```

**示例**：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033804.png" alt="image-20210720211019329" style="zoom: 50%;" />

### 2.2.3.修改索引库

倒排索引结构虽然不复杂，但是一旦数据结构改变（比如改变了分词器），就需要重新创建倒排索引，这简直是灾难。因此索引库**一旦创建，无法修改mapping**。

虽然无法修改mapping中已有的字段，但是却允许**新增**字段到mapping中，因为不会对倒排索引产生影响。

> 只要不影响原有的索引库，那么就可以修改索引库，只有新增不影响原有的索引库

**语法说明**：

```json
PUT /索引库名/_mapping
{
  "properties": {
    "新字段名":{
      "type": "integer"
    }
  }
}
```

**示例**：

![image-20210720212357390](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033805.png)

### 2.2.4.删除索引库

**语法：**

- 请求方式：DELETE

- 请求路径：/索引库名

- 请求参数：无

**格式：**

```html
DELETE /索引库名
```

在kibana中测试：

![image-20210720212123420](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033806.png)

### 2.2.5.总结

索引库操作有哪些？这些操作都类似于Restful的风格

- 创建索引库：PUT /索引库名
- 查询索引库：GET /索引库名
- 删除索引库：DELETE /索引库名
- 添加字段：PUT /索引库名/_mapping

# 3.文档操作

## 3.1.新增文档

新增文档时要按照建立索引表的结构新增，并且类型也要对应

**语法：**

```json
POST /索引库名/_doc/文档id
{
    "字段1": "值1",
    "字段2": "值2",
    "字段3": {
        "子属性1": "值3",
        "子属性2": "值4"
    },
    // ...
}
```

**示例：**

```json
POST /heima/_doc/1
{
    "info": "黑马程序员Java讲师",
    "email": "zy@itcast.cn",
    "name": {
        "firstName": "云",
        "lastName": "赵"
    }
}
```

**响应：**

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033807.png" alt="image-20210720212933362" style="zoom:50%;" />

## 3.2.查询文档

根据rest风格，新增是post，查询应该是get，不过查询一般都需要条件，这里我们把**文档id**带上。

**语法：**

```json
GET /{索引库名称}/_doc/{id}
```

**通过kibana查看数据：**

```js
GET /heima/_doc/1
```

**查看结果（_source中是真实的数据）：**

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033808.png" alt="image-20210720213345003" style="zoom:50%;" />



## 3.3.删除文档

删除使用DELETE请求，同样，需要根据id进行删除：

**语法：**

```js
DELETE /{索引库名}/_doc/id值
```

**示例：**

```json
# 根据id删除数据
DELETE /heima/_doc/1
```

**结果：**

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033809.png" alt="image-20210720213634918" style="zoom:50%;" />



## 3.4.修改文档

修改有两种方式：

- 全量修改：直接**覆盖**原来的文档
- 增量修改：**修改**文档中的部分字段

### 3.4.1.全量修改

全量修改是覆盖原来的文档，其本质是：

- 根据指定的id删除文档
- 新增一个相同id的文档

**注意**：如果根据id删除时，id不存在，第二步的新增也会执行，也就从修改变成了新增操作了。

**语法：**

```json
PUT /{索引库名}/_doc/文档id
{
    "字段1": "值1",
    "字段2": "值2",
    // ... 略
}

```

**示例：**

```json
PUT /heima/_doc/1
{
    "info": "黑马程序员高级Java讲师",
    "email": "zy@itcast.cn",
    "name": {
        "firstName": "云",
        "lastName": "赵"
    }
}
```

### 3.4.2.增量修改

增量修改是只修改指定id匹配的文档中的部分字段。此时需要在POST后增加`_update`的标签

**语法：**

```json
POST /{索引库名}/_update/文档id
{
    "doc": {
         "字段名": "新的值",
    }
}
```

**示例：**

```json
POST /heima/_update/1
{
  "doc": {
    "email": "ZhaoYun@itcast.cn"
  }
}
```

## 3.5.总结

文档操作有哪些？

- 创建文档：POST /{索引库名}/_doc/文档id   { json文档 }
- 查询文档：GET /{索引库名}/_doc/文档id
- 删除文档：DELETE /{索引库名}/_doc/文档id
- 修改文档：
  - 全量修改：**PUT** /{索引库名}/_doc/文档id { json文档 }
  - 增量修改：**POST** /{索引库名}/**_update**/文档id { "doc": {字段}}

# 4.RestAPI

ES官方提供了各种不同语言的客户端，用来操作ES。这些客户端的本质就是**组装DSL**语句，通过http请求发送给ES。官方文档地址：https://www.elastic.co/guide/en/elasticsearch/client/index.html

其中的Java Rest Client又包括两种：

- Java **Low** Level Rest Client
- Java **High** Level Rest Client

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033810.png" alt="image-20210720214555863" style="zoom:50%;" />

我们学习的是Java HighLevel Rest Client客户端API，以一个现成的项目距离，主要学习的是lasticsearch如何操作索引库和文档

项目结构如图：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033813.png" alt="image-20210720220647541" style="zoom:50%;" />

酒店数据的表结构为：

```mysql
CREATE TABLE `tb_hotel` (
  `id` bigint(20) NOT NULL COMMENT '酒店id',
  `name` varchar(255) NOT NULL COMMENT '酒店名称；例：7天酒店',
  `address` varchar(255) NOT NULL COMMENT '酒店地址；例：航头路',
  `price` int(10) NOT NULL COMMENT '酒店价格；例：329',
  `score` int(2) NOT NULL COMMENT '酒店评分；例：45，就是4.5分',
  `brand` varchar(32) NOT NULL COMMENT '酒店品牌；例：如家',
  `city` varchar(32) NOT NULL COMMENT '所在城市；例：上海',
  `star_name` varchar(16) DEFAULT NULL COMMENT '酒店星级，从低到高分别是：1星到5星，1钻到5钻',
  `business` varchar(255) DEFAULT NULL COMMENT '商圈；例：虹桥',
  `latitude` varchar(32) NOT NULL COMMENT '纬度；例：31.2497',
  `longitude` varchar(32) NOT NULL COMMENT '经度；例：120.3925',
  `pic` varchar(255) DEFAULT NULL COMMENT '酒店图片；例:/img/1.jpg',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

来看下酒店数据的索引库结构:

```json
PUT /hotel
{
  "mappings": {
    "properties": {
      "id": {
        "type": "keyword"
      },
      "name":{
        "type": "text",
        "analyzer": "ik_max_word",
        "copy_to": "all"
      },
      "address":{
        "type": "keyword",
        "index": false
      },
      "price":{
        "type": "integer"
      },
      "score":{
        "type": "integer"
      },
      "brand":{
        "type": "keyword",
        "copy_to": "all"
      },
      "city":{
        "type": "keyword",
        "copy_to": "all"
      },
      "starName":{
        "type": "keyword"
      },
      "business":{
        "type": "keyword"
      },
      "location":{
        "type": "geo_point"
      },
      "pic":{
        "type": "keyword",
        "index": false
      },
      "all":{
        "type": "text",
        "analyzer": "ik_max_word"
      }
    }
  }
}
```

几个特殊字段说明：

- location：地理坐标，里面包含精度、纬度
- all：一个组合字段，其目的是将多字段的值 利用copy_to合并，提供给用户搜索

地理坐标说明：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033815.png" alt="image-20210720222110126" style="zoom:50%;" />

copy_to说明：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033816.png" alt="image-20210720222221516" style="zoom:50%;" />

> copy_to可以将多个字段中的内容拷贝到一个字段中进行整合，这样对于多字段搜索来说很方便

## 4.1.创建索引库

在elasticsearch提供的API中，与elasticsearch一切交互都封装在一个名为`RestHighLevelClient`的类中，必须先完成这个对象的初始化，建立与elasticsearch的连接，之后才可以操作索引库和文档

分为三步：

1）引入es的RestHighLevelClient依赖：

```xml
<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>elasticsearch-rest-high-level-client</artifactId>
</dependency>
```

2）因为SpringBoot默认的ES版本是7.6.2，所以我们需要覆盖默认的ES版本：

```xml
<properties>
    <java.version>1.8</java.version>
    <elasticsearch.version>7.12.1</elasticsearch.version>
</properties>
```

3）初始化RestHighLevelClient：

初始化的代码如下，这句代码就连接上了我们安装的elasticsearch：

```java
RestHighLevelClient client = new RestHighLevelClient(RestClient.builder(
        HttpHost.create("http://192.168.150.101:9200")
));
```

这里为了单元测试方便，我们创建一个测试类HotelIndexTest，然后将初始化的代码编写在@BeforeEach方法中：

```java
package cn.itcast.hotel;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestHighLevelClient;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

public class HotelIndexTest {
    //在每个单元测试执行之前，都将初始化这个Client
    //在每个单元测试执行完毕之后，都会关闭这个Client
    private RestHighLevelClient client;

    @BeforeEach
    void setUp() {
        this.client = new RestHighLevelClient(RestClient.builder(
                HttpHost.create("http://192.168.150.101:9200")
        ));
    }

    @AfterEach
    void tearDown() throws IOException {
        this.client.close();
    }
}
```

### 4.1.1.代码解读

创建索引库的API如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033817.png" alt="image-20210720223049408" style="zoom:50%;" />

代码分为三步：

- 1）创建Request对象。因为是创建索引库的操作，因此Request是CreateIndexRequest。
- 2）添加请求参数，其实就是DSL的JSON参数部分。因为json字符串很长，这里是定义了静态字符串常量MAPPING_TEMPLATE，让代码看起来更加优雅。
- 3）发送请求，client.indices()方法的返回值是IndicesClient类型，封装了所有与索引库操作有关的方法。

### 4.1.2.完整示例

在hotel-demo的cn.itcast.hotel.constants包下，创建一个类，定义mapping映射的JSON字符串常量：

> 这里将创建索引库的DSL语句中的`mappings`部分准备好，然后剩下的部分使用java代码来拼接

```java
package cn.itcast.hotel.constants;

public class HotelConstants {
    public static final String MAPPING_TEMPLATE = "{\n" +
            "  \"mappings\": {\n" +
            "    \"properties\": {\n" +
            "      \"id\": {\n" +
            "        \"type\": \"keyword\"\n" +
            "      },\n" +
            "      \"name\":{\n" +
            "        \"type\": \"text\",\n" +
            "        \"analyzer\": \"ik_max_word\",\n" +
            "        \"copy_to\": \"all\"\n" +
            "      },\n" +
            "      \"address\":{\n" +
            "        \"type\": \"keyword\",\n" +
            "        \"index\": false\n" +
            "      },\n" +
            "      \"price\":{\n" +
            "        \"type\": \"integer\"\n" +
            "      },\n" +
            "      \"score\":{\n" +
            "        \"type\": \"integer\"\n" +
            "      },\n" +
            "      \"brand\":{\n" +
            "        \"type\": \"keyword\",\n" +
            "        \"copy_to\": \"all\"\n" +
            "      },\n" +
            "      \"city\":{\n" +
            "        \"type\": \"keyword\",\n" +
            "        \"copy_to\": \"all\"\n" +
            "      },\n" +
            "      \"starName\":{\n" +
            "        \"type\": \"keyword\"\n" +
            "      },\n" +
            "      \"business\":{\n" +
            "        \"type\": \"keyword\"\n" +
            "      },\n" +
            "      \"location\":{\n" +
            "        \"type\": \"geo_point\"\n" +
            "      },\n" +
            "      \"pic\":{\n" +
            "        \"type\": \"keyword\",\n" +
            "        \"index\": false\n" +
            "      },\n" +
            "      \"all\":{\n" +
            "        \"type\": \"text\",\n" +
            "        \"analyzer\": \"ik_max_word\"\n" +
            "      }\n" +
            "    }\n" +
            "  }\n" +
            "}";
}
```

在hotel-demo中的HotelIndexTest测试类中，编写单元测试，实现创建索引：

```java
@Test
void createHotelIndex() throws IOException {
    // 1.创建Request对象
    CreateIndexRequest request = new CreateIndexRequest("hotel");
    // 2.准备请求的参数：DSL语句
    request.source(MAPPING_TEMPLATE, XContentType.JSON);
    // 3.发送请求，indices指索引库，create指新建
    client.indices().create(request, RequestOptions.DEFAULT);
}
```

## 4.2.删除索引库

删除索引库的DSL语句非常简单：

```json
DELETE /hotel
```

与创建索引库相比：

- 请求方式从PUT变为DELTE
- 请求路径不变
- 无请求参数

所以代码的差异，注意体现在Request对象上。依然是三步走：

- 1）创建Request对象。这次是DeleteIndexRequest对象
- 2）准备参数。这里是无参
- 3）发送请求。改用delete方法

在hotel-demo中的HotelIndexTest测试类中，编写单元测试，实现删除索引：

```java
@Test
void testDeleteHotelIndex() throws IOException {
    // 1.创建Request对象
    DeleteIndexRequest request = new DeleteIndexRequest("hotel");
    // 2.发送请求，indices指索引库，delete指删除，这里要指定索引库名称
    client.indices().delete(request, RequestOptions.DEFAULT);
}
```

## 4.3.判断索引库是否存在

判断索引库是否存在，本质就是查询，对应的DSL是：

```json
GET /hotel
```

因此与删除的Java代码流程是类似的。依然是三步走：

- 1）创建Request对象。这次是GetIndexRequest对象
- 2）准备参数。这里是无参
- 3）发送请求。改用exists方法

```java
@Test
void testExistsHotelIndex() throws IOException {
    // 1.创建Request对象
    GetIndexRequest request = new GetIndexRequest("hotel");
    // 2.发送请求
    boolean exists = client.indices().exists(request, RequestOptions.DEFAULT);
    // 3.输出
    System.err.println(exists ? "索引库已经存在！" : "索引库不存在！");
}
```

## 4.4.总结

JavaRestClient操作elasticsearch的流程基本类似。核心是**client.indices()方法**来获取索引库的操作对象。想要干什么就调用什么方法，例如create，delete，exists。。。

索引库操作的基本步骤：

- 初始化RestHighLevelClient
- 创建XxxIndexRequest。XXX是Create、Get、Delete
- 准备DSL（ Create时需要，其它是无参）
- 发送请求。调用RestHighLevelClient#indices().xxx()方法，xxx是create、exists、delete

# 5.RestClient操作文档

为了与索引库操作分离，我们再次参加一个测试类，做两件事情：

- 初始化RestHighLevelClient
- 我们的酒店数据在数据库，需要利用IHotelService去查询，所以注入这个接口

```java
package cn.itcast.hotel;

import cn.itcast.hotel.pojo.Hotel;
import cn.itcast.hotel.service.IHotelService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.io.IOException;
import java.util.List;

@SpringBootTest
public class HotelDocumentTest {
    @Autowired
    private IHotelService hotelService;
	//还是在每个测试之前初始化Client，测试完成之后关闭Client
    private RestHighLevelClient client;

    @BeforeEach
    void setUp() {
        this.client = new RestHighLevelClient(RestClient.builder(
                HttpHost.create("http://192.168.150.101:9200")
        ));
    }

    @AfterEach
    void tearDown() throws IOException {
        this.client.close();
    }
}

```

## 5.1.新增文档

我们要将数据库的酒店数据查询出来，写入elasticsearch中。

### 5.1.1.索引库实体类

数据库查询后的结果是一个Hotel类型的对象。结构如下，查询出来的酒店数据都将封装到这样一个实体中进行存储：

```java
@Data
@TableName("tb_hotel")
public class Hotel {
    @TableId(type = IdType.INPUT)
    private Long id;
    private String name;
    private String address;
    private Integer price;
    private Integer score;
    private String brand;
    private String city;
    private String starName;
    private String business;
    private String longitude;
    private String latitude;
    private String pic;
}
```

与我们的索引库结构存在**差异**：

- longitude和latitude需要合并为location

因此，我们需要定义一个**新的类型**，与索引库结构吻合，相当于要将数据库的实体结构转换成es中的文档结构：

```java
package cn.itcast.hotel.pojo;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class HotelDoc {
    private Long id;
    private String name;
    private String address;
    private Integer price;
    private Integer score;
    private String brand;
    private String city;
    private String starName;
    private String business;
    private String location;
    private String pic;
	//这个构造函数就可以将mysql中查询出来的实体结构转换成es中的索引库可以保存的文档结构
    public HotelDoc(Hotel hotel) {
        this.id = hotel.getId();
        this.name = hotel.getName();
        this.address = hotel.getAddress();
        this.price = hotel.getPrice();
        this.score = hotel.getScore();
        this.brand = hotel.getBrand();
        this.city = hotel.getCity();
        this.starName = hotel.getStarName();
        this.business = hotel.getBusiness();
        this.location = hotel.getLatitude() + ", " + hotel.getLongitude();
        this.pic = hotel.getPic();
    }
}

```

### 5.1.2.语法说明

新增文档的DSL语句如下：

```json
POST /{索引库名}/_doc/1
{
    "name": "Jack",
    "age": 21
}
```

对应的java代码如图：

![image-20210720230027240](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033818.png)

可以看到与创建索引库类似，同样是三步走：

- 1）创建Request对象
- 2）准备请求参数，也就是DSL中的JSON文档
- 3）发送请求

变化的地方在于，这里**直接使用**client.xxx()的API，不再需要client.indices()了。因为我们不再是操作索引库，而是直接操作文档，只需要指定好索引库名即可

### 5.1.3.完整代码

我们导入酒店数据，基本流程一致，但是需要考虑几点变化：

- 酒店数据来自于**数据库**，我们需要先查询出来，得到hotel对象
- hotel对象需要转为HotelDoc对象
- HotelDoc需要序列化为json格式

> 查询，转换，存储

因此，代码整体步骤如下：

- 1）根据id查询酒店数据Hotel
- 2）将Hotel封装为HotelDoc
- 3）将HotelDoc序列化为JSON
- 4）创建IndexRequest，指定索引库名和id
- 5）准备请求参数，也就是JSON文档
- 6）发送请求

在hotel-demo的HotelDocumentTest测试类中，编写单元测试：

```java
@Test
void testAddDocument() throws IOException {
    // 1.根据id查询酒店数据
    Hotel hotel = hotelService.getById(61083L);
    // 2.转换为文档类型
    HotelDoc hotelDoc = new HotelDoc(hotel);
    // 3.将HotelDoc转json
    String json = JSON.toJSONString(hotelDoc);

    // 1.准备Request对象，这里的文档id使用数据库中查询到的记录的id
    IndexRequest request = new IndexRequest("hotel").id(hotelDoc.getId().toString());
    // 2.准备Json文档
    request.source(json, XContentType.JSON);
    // 3.发送请求
    client.index(request, RequestOptions.DEFAULT);
}
```

## 5.2.查询文档

### 5.2.1.语法说明

查询的DSL语句如下：

```json
GET /hotel/_doc/{id}
```

非常简单，因此代码大概分两步：

- 准备Request对象
- 发送请求

不过查询的目的是得到结果，解析为HotelDoc，因此难点是结果的解析。完整代码如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033819.png" alt="image-20210720230811674" style="zoom:50%;" />

可以看到，结果是一个JSON，其中文档放在一个`_source`属性中，因此解析就是拿到`_source`，反序列化为Java对象即可。

与之前类似，也是三步走：

- 1）准备Request对象。这次是查询，所以是GetRequest
- 2）发送请求，得到结果。因为是查询，这里调用client.get()方法
- 3）解析结果，就是对JSON做反序列化

### 5.2.2.完整代码

在hotel-demo的HotelDocumentTest测试类中，编写单元测试：

```java
@Test
void testGetDocumentById() throws IOException {
    // 1.准备Request，只要指定了文档id就可以查询得到结果
    GetRequest request = new GetRequest("hotel", "61082");
    // 2.发送请求，得到响应
    GetResponse response = client.get(request, RequestOptions.DEFAULT);
    // 3.解析响应结果
    String json = response.getSourceAsString();

    HotelDoc hotelDoc = JSON.parseObject(json, HotelDoc.class);
    System.out.println(hotelDoc);
}
```

## 5.3.删除文档

删除的DSL为是这样的：

```json
DELETE /hotel/_doc/{id}
```

与查询相比，仅仅是请求方式从DELETE变成GET，可以想象Java代码应该依然是三步走：

- 1）准备Request对象，因为是删除，这次是DeleteRequest对象。要指定索引库名和id
- 2）准备参数，无参
- 3）发送请求。因为是删除，所以是client.delete()方法

在hotel-demo的HotelDocumentTest测试类中，编写单元测试：

```java
@Test
void testDeleteDocument() throws IOException {
    // 1.准备Request
    DeleteRequest request = new DeleteRequest("hotel", "61083");
    // 2.发送请求，发送完成就完成了删除工作
    client.delete(request, RequestOptions.DEFAULT);
}
```

## 5.4.修改文档

### 5.4.1.语法说明

修改我们讲过两种方式：

- **全量**修改：本质是先根据id删除，再新增
- **增量**修改：修改文档中的指定字段值

在RestClient的API中，全量修改**与新增的API完全一致**，判断依据是ID：

- 如果新增时，ID已经存在，则覆盖
- 如果新增时，ID不存在，则新增

这里不再赘述，我们主要关注增量修改。

代码示例如图：

![image-20210720231040875](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033820.png)

与之前类似，也是三步走：

- 1）准备Request对象。这次是修改，所以是UpdateRequest
- 2）准备参数。也就是JSON文档，里面包含要修改的字段
- 3）更新文档。这里调用client.update()方法

### 5.4.2.完整代码

在hotel-demo的HotelDocumentTest测试类中，编写单元测试：

```java
@Test
void testUpdateDocument() throws IOException {
    // 1.准备Request
    UpdateRequest request = new UpdateRequest("hotel", "61083");
    // 2.准备请求参数，这里主要是编写新增的字段是什么
    request.doc(
        "price", "952",
        "starName", "四钻"
    );
    // 3.发送请求
    client.update(request, RequestOptions.DEFAULT);
}
```

## 5.5.批量导入文档

案例需求：利用`BulkRequest`批量将数据库数据导入到索引库中。

步骤如下：

- 利用mybatis-plus查询所有的酒店数据

- 将查询到的酒店数据（Hotel）转换为文档类型数据（HotelDoc）

- 利用JavaRestClient中的BulkRequest批处理，实现批量新增文档

### 5.5.1.语法说明

批量处理BulkRequest，其本质就是将多个普通的CRUD**请求组合在一起发送**。

其中提供了一个add方法，用来添加其他请求：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033821.png" alt="image-20210720232105943" style="zoom:50%;" />

可以看到，能添加的请求包括：

- IndexRequest，也就是新增
- UpdateRequest，也就是修改
- DeleteRequest，也就是删除

> 也就是可以进行批量的增删改

因此Bulk中添加了多个IndexRequest，就是批量新增功能了。示例：

![](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202402292033822.png)

其实还是三步走：

- 1）创建Request对象。这里是BulkRequest
- 2）准备参数。批处理的参数，就是其它Request对象，这里就是多个IndexRequest
- 3）发起请求。这里是批处理，调用的方法为client.bulk()方法

我们在导入酒店数据时，将上述代码改造成**for循环**处理即可。

### 5.5.2.完整代码

在hotel-demo的HotelDocumentTest测试类中，编写单元测试：

```java
@Test
void testBulkRequest() throws IOException {
    // 批量查询酒店数据
    List<Hotel> hotels = hotelService.list();

    // 1.创建Request
    BulkRequest request = new BulkRequest();
    // 2.准备参数，添加多个新增的Request
    //这里是遍历所有得到的Hotel进行新增
    for (Hotel hotel : hotels) {
        // 2.1.转换为文档类型HotelDoc
        HotelDoc hotelDoc = new HotelDoc(hotel);
        // 2.2.创建新增文档的Request对象
        request.add(new IndexRequest("hotel")
                    .id(hotelDoc.getId().toString())
                    .source(JSON.toJSONString(hotelDoc), XContentType.JSON));
    }
    // 3.发送请求，利用批处理完成批量的新增
    client.bulk(request, RequestOptions.DEFAULT);
}
```

## 5.6.小结

文档操作的基本步骤：

- 初始化RestHighLevelClient
- 创建XxxRequest。XXX是Index、Get、Update、Delete、Bulk，此时就不需要使用indices函数了，因为这里操作的是文档，可以直接调用对应的函数即可
- 准备参数（Index、Update、Bulk时需要）
- 发送请求。调用RestHighLevelClient#.xxx()方法，xxx是index、get、update、delete、bulk
- 解析结果（Get时需要），查询到了json之后，可以进一步将其转换成想要的java对象

