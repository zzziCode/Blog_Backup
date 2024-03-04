---
title: "Elasticsearch学习笔记2"
description: "elasticsearch学习笔记2"
keywords: "elasticsearch学习笔记2"

date: 2024-03-01T20:51:31+08:00
lastmod: 2024-03-01T20:51:31+08:00

categories:
  - 学习笔记
tags:
  - 微服务
  - elasticsearch

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
#url: "elasticsearch学习笔记2.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🔍 elasticsearch学习笔记2

本节中主要介绍elasticsearch中的文档搜索功能，这也是它最重要的一个知识点

<!--more-->

# 1.DSL查询文档

elasticsearch的查询依然是基于JSON风格的`DSL`来实现的。

## 1.1.DSL查询分类

Elasticsearch提供了基于JSON的DSL（[Domain Specific Language](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)）来定义查询。常见的查询类型包括：

- **查询所有**：查询出所有数据，一般测试用。例如：match_all

- **全文检索（full text）查询**：利用分词器对用户输入内容分词，然后去倒排索引库中匹配。例如：
  - match_query
  - multi_match_query
- **精确查询**：根据精确词条值查找数据，一般是查找keyword、数值、日期、boolean等类型字段。例如：
  - ids
  - range
  - term
- **地理（geo）查询**：根据经纬度查询。例如：
  - geo_distance
  - geo_bounding_box
- **复合（compound）查询**：复合查询可以将上述各种查询条件**组合**起来，合并查询条件。例如：
  - bool
  - function_score

查询的语法基本一致：

```json
GET /indexName/_search
{
  "query": {
    "查询类型": {
      "查询条件": "条件值"
    }
  }
}
```

我们以查询所有为例，其中：

- 查询类型为match_all
- 没有查询条件，所以match_all中的花括号没有值

```json
// 查询所有
GET /indexName/_search
{
  "query": {
    "match_all": {
    }
  }
}
```

其它查询无非就是**查询类型**、**查询条件**的变化。

## 1.2.全文检索查询

### 1.2.1.使用场景

全文检索查询的基本流程如下：

- 对用户搜索的内容做**分词**，得到词条
- 根据词条去倒排索引库中匹配，得到文档id
- 根据文档id找到文档，返回给用户

> 相当于用户输入一个内容，elasticsearch将其进行分词，然后根据词条去查询匹配，根据所有查询匹配到的id找到文档返回给用户

比较常用的场景包括：

- 商城的输入框搜索
- 百度输入框搜索

例如京东：

![image-20210721165326938](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056925.png)

因为是拿着词条去匹配，因此参与搜索的字段也**必须是可分词**的text类型的字段。

### 1.2.2.基本语法

常见的全文检索查询包括：

- match查询：单字段查询
- multi_match查询：多字段查询，任意一个字段符合条件就算符合查询条件

match查询语法如下：

```json
GET /indexName/_search
{
  "query": {
    "match": {
      "FIELD": "TEXT"
    }
  }
}
```

mulit_match语法如下：

```json
GET /indexName/_search
{
  "query": {
    "multi_match": {
      "query": "TEXT",
      "fields": ["FIELD1", " FIELD12"]
    }
  }
}
```

### 1.2.3.示例

match查询示例：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056931.png" alt="image-20210721170455419" style="zoom: 50%;" />

这里的all字段是一个组合字段，将name，brand，business中所有的词条组合在一起形成的新字段

multi_match查询示例：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056932.png" alt="image-20210721170720691" style="zoom:50%;" />

可以看到，两种查询结果是一样的，为什么？

因为我们将brand、name、business值都利用copy_to复制到了all字段中。all一个字段包含了三个字段中的所有值。因此你根据三个字段搜索，和根据all字段搜索效果当然一样了。

但是，搜索字段越多，对查询性能影响越大，因此建议采用copy_to，然后单字段查询的方式。只是这一个字段中包含的值更多，查询时不用切换字段不会使得查询性能降低

> 这里得到一个启发，如果某些字段经常使用多字段查询，那么可以将这几个字段复制到一个新字段中，新字段本身没有任何意义，只是为了加快查询效率而将这些字段的值都包含了

### 1.2.4.总结

match和multi_match的区别是什么？

- match：根据**一个字段**查询
- multi_match：根据**多个字段**查询，参与查询字段越多，查询性能越差，所以可以将多字段copy到一个字段中

## 1.3.精准查询

精确查询一般是查找keyword、数值、日期、boolean等类型字段。所以**不会**对搜索条件分词。常见的有：

- term：根据词条精确值查询
- range：根据值的范围查询

### 1.3.1.term查询

因为精确查询的字段**搜索的是不分词的字段**，因此查询的条件也必须是**不分词**的词条。查询时，用户输入的内容跟自动值**完全匹配**时才认为符合条件。如果用户输入的内容过多，反而搜索不到数据。

语法说明：

```json
// term查询
GET /indexName/_search
{
  "query": {
    "term": {
      "FIELD": {
        "value": "VALUE"
      }
    }
  }
}
```

示例：

当我搜索的是精确词条时，能正确查询出结果：

![image-20210721171655308](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056933.png)

但是，当我搜索的内容不是词条，而是多个词语形成的短语时，反而搜索不到：

![image-20210721171838378](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056934.png)

因为此时是term精确查询，针对输入的内容不会进行分词，而索引库中没有一个文档的字段是“杭州上海”，从而导致搜索不到任何文档

### 1.3.2.range查询

范围查询，一般应用在对数值类型做范围过滤的时候。比如做价格范围过滤。

基本语法：

```json
// range查询
GET /indexName/_search
{
  "query": {
    "range": {
      "FIELD": {
        "gte": 10, // 这里的gte代表大于等于，gt则代表大于，其中的e代表equals
        "lte": 20 // lte代表小于等于，lt则代表小于
      }
    }
  }
}
```

示例：

![image-20210721172307172](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056936.png)

### 1.3.3.总结

精确查询常见的有哪些？

- term查询：根据词条精确匹配，一般搜索keyword类型、数值类型、布尔类型、日期类型字段
- range查询：根据数值范围查询，可以是数值、日期的范围

## 1.4.地理坐标查询

所谓的地理坐标查询，其实就是根据经纬度查询，官方文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/geo-queries.html

常见的使用场景包括：

- 携程：搜索我附近的酒店
- 滴滴：搜索我附近的出租车
- 微信：搜索我附近的人

附近的酒店：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056937.png" alt="image-20210721172645103" style="zoom: 50%;" />

附近的车：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056938.png" alt="image-20210721172654880" style="zoom:50%;" />

此时会根据经纬度算出附近的符合要求的文档然后返回

### 1.4.1.矩形范围查询

矩形范围查询，也就是geo_bounding_box查询，查询坐标落在某个矩形范围的所有文档：

![DKV9HZbVS6](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056939.gif)

查询时，需要指定矩形的**左上**、**右下**两个点的坐标，然后画出一个矩形，落在该矩形内的都是符合条件的点。

语法如下：

```json
// geo_bounding_box查询
GET /indexName/_search
{
  "query": {
    "geo_bounding_box": {
      "FIELD": {
        "top_left": { // 左上点
          "lat": 31.1,
          "lon": 121.5
        },
        "bottom_right": { // 右下点
          "lat": 30.9,
          "lon": 121.7
        }
      }
    }
  }
}
```

这种并不符合“附近的人”这样的需求，因为这种需要指定范围，所以我们就不做了。

### 1.4.2.附近查询

附近查询，也叫做距离查询（geo_distance）：查询到指定中心点小于某个距离值的所有文档。

换句话来说，在地图上找一个点作为圆心，以指定距离为半径，画一个圆，落在圆内的坐标都算符合条件：

![vZrdKAh19C](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056940.gif)

语法说明：

```json
// geo_distance 查询
GET /indexName/_search
{
  "query": {
    "geo_distance": {
      "distance": "15km", // 半径
      "FIELD": "31.21,121.5" // 圆心
    }
  }
}
```

这种查询只用指定圆心和半径就可以查询这个圆内的所有文档

示例：

我们先搜索陆家嘴附近15km的酒店：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056941.png" alt="image-20210721175443234" style="zoom:50%;" />

发现共有47家酒店。

然后把半径缩短到3公里：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056942.png" alt="image-20210721182031475" style="zoom:50%;" />

可以发现，搜索到的酒店数量减少到了5家。这种搜索更加符合附近的人，附近的车等搜索需求

## 1.5.复合查询

复合（compound）查询：复合查询可以**将简单查询组合**起来，实现更复杂的搜索逻辑。常见的有两种：

- fuction score：算分函数查询，可以控制文档相关性算分，控制文档排名
- bool query：布尔查询，利用逻辑关系组合多个其它的查询，实现复杂搜索

### 1.5.1.相关性算分

当我们利用match查询时，文档结果会根据与搜索词条的关联度**打分**（_score），返回结果时按照分值降序排列。

例如，我们搜索 "虹桥如家"，结果如下：

```json
[
  {
    "_score" : 17.850193,
    "_source" : {
      "name" : "虹桥如家酒店真不错",
    }
  },
  {
    "_score" : 12.259849,
    "_source" : {
      "name" : "外滩如家酒店真不错",
    }
  },
  {
    "_score" : 11.91091,
    "_source" : {
      "name" : "迪士尼如家酒店真不错",
    }
  }
]
```

在elasticsearch中，早期使用的打分算法是TF-IDF算法，公式如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056943.png" alt="image-20210721190152134" style="zoom: 50%;" />

在后来的5.1版本升级中，elasticsearch将算法改进为BM25算法，公式如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056944.png" alt="image-20210721190416214" style="zoom:50%;" />

TF-IDF算法有一个缺陷，就是词条频率越高，文档得分也会越高，单个词条对文档影响较大。而BM25则会让单个词条的算分有一个上限，曲线更加平滑：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056945.png" alt="image-20210721190907320" style="zoom:50%;" />

小结：elasticsearch会根据词条和文档的相关度做打分，算法由两种：

- TF-IDF算法
- BM25算法，elasticsearch5.1版本后采用的算法

### 1.5.2.算分函数查询

根据相关度打分是比较合理的需求，但**合理的不一定是产品经理需要**的。

以百度为例，你搜索的结果中，并不是相关度越高排名越靠前，而是谁掏的钱多排名就越靠前。如图，也就是在相关度更高的得分高的基础上，付费的广告得分更高：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056946.png" alt="image-20210721191144560" style="zoom:50%;" />

要想认为控制相关性算分，就需要利用elasticsearch中的function score 查询了。

#### 1）语法说明

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056947.png" alt="image-20210721191544750" style="zoom:50%;" />

function score 查询中包含四部分内容：

- **原始查询**条件：query部分，基于这个条件搜索文档，并且基于BM25算法给文档打分，最后得到**原始算分**（query score)
- **过滤条件**：filter部分，符合该条件的文档才会**重新算分**
- **算分函数**：符合filter条件的文档要根据这个**函数**做运算，得到的**函数算分**（function score），有四种函数
  - weight：函数结果是常量
  - field_value_factor：以文档中的某个字段值作为函数结果
  - random_score：以随机数作为函数结果
  - script_score：自定义算分函数算法
- **运算模式**：算分函数的结果、原始查询的相关性算分，两者之间的运算方式，包括：
  - multiply：相乘，用之前的原始算分乘以一个数
  - replace：用function score替换query score
  - 其它，例如：sum、avg、max、min

function score的运行流程如下：

- 1）根据**原始条件**查询搜索文档，并且计算相关性算分，称为**原始算分**（query score）
- 2）根据**过滤条件**，过滤文档
- 3）符合**过滤条件**的文档，基于**算分函数**运算，得到**函数算分**（function score）
- 4）将**原始算分**（query score）和**函数算分**（function score）基于**运算模式**做运算，得到最终结果，作为相关性算分。

因此，其中的关键点是：

- 过滤条件：决定**哪些**文档的算分被修改
- 算分函数：决定**函数算分**的算法
- 运算模式：决定**最终算分**结果

#### 2）示例

需求：给“如家”这个品牌的酒店排名靠前一些

翻译一下这个需求，转换为之前说的四个要点：

- 原始条件：不确定，可以任意变化，例如上海的酒店
- 过滤条件：brand = "如家"
- 算分函数：可以简单粗暴，直接给固定的算分结果，weight
- 运算模式：比如求和

因此最终的DSL语句如下：

```json
GET /hotel/_search
{
  "query": {
    "function_score": {
      "query": {
      	"match":{
          "all":"上海"
      	}
      }, // 原始查询，可以是任意条件
      "functions": [ // 算分函数
        {
          "filter": { // 满足的条件，品牌必须是如家
            "term": {
              "brand": "如家"
            }
          },
          "weight": 10 // 算分权重为2
        }
      ],
      "boost_mode": "sum" // 加权模式，求和
    }
  }
}
```

这个查询条件就会现将上海的所有酒店查询出来，然后针对如家重新算分，在原有分数的基础上+10

测试，在未添加算分函数时，如家得分如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056948.png" alt="image-20210721193152520" style="zoom:50%;" />

添加了算分函数后，如家得分就提升了：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056949.png" alt="image-20210721193458182" style="zoom: 50%;" />

#### 3）小结

function score query定义的三要素是什么？

- 过滤条件：哪些文档要加分
- 算分函数：如何计算function score
- 加权方式：function score 与 query score如何运算

### 1.5.3.布尔查询

布尔查询是一个或多个查询子句的组合，每一个子句就是一个**子查询**。子查询的组合方式有：

- must：必须匹配每个子查询，类似“与”
- should：选择性匹配子查询，类似“或”
- must_not：必须不匹配，**不参与算分**，类似“非”
- filter：必须匹配，**不参与算分**

比如在搜索酒店时，除了关键字搜索外，我们还可能根据品牌、价格、城市等字段做过滤：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056950.png" alt="image-20210721193822848" style="zoom:50%;" />

每一个不同的字段，其查询的条件、方式都不一样，必须是多个不同的查询，而要组合这些查询，就必须用bool查询了。

需要注意的是，搜索时，参与**打分的字段越多，查询的性能也越差**。因此这种多条件查询时，建议这样做：

- 搜索框的关键字搜索，是全文检索查询，使用must查询，**参与算分**
- 其它过滤条件，采用filter查询。**不参与算分**

这样有选择性的规定查询的类型可以提高查询效率

#### 1）语法示例：

```json
GET /hotel/_search
{
  "query": {
    "bool": {
      "must": [//城市必须在上海
        {"term": {"city": "上海" }}
      ],
      "should": [//酒店品牌可以是皇冠假日或者华美达
        {"term": {"brand": "皇冠假日" }},
        {"term": {"brand": "华美达" }}
      ],
      "must_not": [//酒店价格必须大于500
        { "range": { "price": { "lte": 500 } }}
      ],
      "filter": [//酒店评分必须在45及以上
        { "range": {"score": { "gte": 45 } }}
      ]
    }
  }
}
```

#### 2）示例

需求：搜索名字**包含**“如家”，价格**不高于**400，在坐标31.21,121.5周围10km**范围内**的酒店。

分析：

- 名称搜索，属于全文检索查询，应该参与算分。放到must中
- 价格不高于400，用range查询，属于过滤条件，不参与算分。放到must_not中
- 周围10km范围内，用geo_distance查询，属于过滤条件，不参与算分。放到filter中

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056951.png" alt="image-20210721194744183" style="zoom:50%;" />

#### 3）小结

bool查询有几种逻辑关系？

- must：必须匹配的条件，可以理解为“与”
- should：选择性匹配的条件，可以理解为“或”
- must_not：必须不匹配的条件，不参与打分
- filter：必须匹配的条件，不参与打分

## 1.6.小结

```json
GET /indexName/_search
{
  "query": {
    "function_score": {
      "query": {...}, // 原始查询，可以是任意条件
      "functions": [ // 算分函数
        {
          "filter": {...}, // 满足的条件，品牌必须是如家
          "weight": xxx // 算分权重为2
        }
      ],
      "boost_mode": "xxx" // 加权模式
    }
  }
}
```

基础的查询语句结构就是这样，只是查询类型不一样就导致了形成的DSL不一样，之后还会涉及到算分函数给满足条件的文档重新算分

# 2.搜索结果处理

当我们使用上一节的各种查询方式搜索到文档之后，得到的搜索的结果可以按照用户指定的方式去处理或展示。例如排序，分页，高亮等

## 2.1.排序

elasticsearch**默认**是根据相关度算分（_score）来排序，但是也支持自定义方式对搜索[结果排序](https://www.elastic.co/guide/en/elasticsearch/reference/current/sort-search-results.html)。可以排序字段类型有：keyword类型、数值类型、地理坐标类型、日期类型等。

### 2.1.1.普通字段排序

keyword、数值、日期类型排序的语法基本一致。

**语法**：

```json
GET /indexName/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "FIELD": "desc"  // 排序字段、排序方式ASC、DESC
    }
  ]
}
```

排序条件是一个数组，也就是可以写多个排序条件。按照声明的顺序，当第一个条件相等时，再按照第二个条件排序，以此类推

**示例**：

需求描述：酒店数据按照用户评价（score)降序排序，评价相同的按照价格(price)升序排序

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056952.png" alt="image-20210721195728306" style="zoom:50%;" />

写在前面的字段先进行排序，当前面的字段相等时才会针对后面的字段进行排序

### 2.1.2.地理坐标排序

地理坐标排序略有不同。

**语法说明**：

```json
GET /indexName/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "_geo_distance" : {
          "FIELD" : "纬度，经度", // 文档中geo_point类型的字段名、目标坐标点
          "order" : "asc", // 排序方式
          "unit" : "km" // 排序的距离单位
      }
    }
  ]
}
```

这个查询的含义是：

- 指定一个坐标，作为目标点
- 计算每一个文档中，指定字段（必须是geo_point类型）的坐标 到目标点的距离是多少
- 根据距离排序

**示例：**

需求描述：实现对酒店数据按照到你的位置坐标的距离升序排序

提示：获取你的位置的经纬度的方式：https://lbs.amap.com/demo/jsapi-v2/example/map/click-to-get-lnglat/

假设我的位置是：31.034661，121.612282，寻找我周围距离最近的酒店。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056953.png" alt="image-20210721200214690" style="zoom:50%;" />

## 2.2.分页

elasticsearch 默认情况下只返回`top10`的数据。而如果要查询更多数据就需要修改分页参数了。elasticsearch中通过修改from、size参数来控制要返回的分页结果：

- from：从第几个文档开始
- size：总共查询几个文档

类似于mysql中的`limit ?, ?`

### 2.2.1.基本的分页

分页的基本语法如下：

```json
GET /hotel/_search
{
  "query": {
    "match_all": {}
  },
  "from": 0, // 分页开始的位置，默认为0
  "size": 10, // 期望获取的文档总数
  "sort": [
    {"price": "asc"}
  ]
}
```

### 2.2.2.深度分页问题

现在，我要查询990~1000的数据，查询逻辑要这么写：

```json
GET /hotel/_search
{
  "query": {
    "match_all": {}
  },
  "from": 990, // 分页开始的位置，默认为0
  "size": 10, // 期望获取的文档总数
  "sort": [
    {"price": "asc"}
  ]
}
```

这里是查询990开始的数据，也就是 第990~第1000条 数据。

不过，elasticsearch内部分页时，必须**先查询** 0~1000条，**再截取**其中的990 ~ 1000的这10条：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056954.png" alt="image-20210721200643029" style="zoom:50%;" />



查询TOP1000，如果es是单点模式，这并无太大影响。

但是elasticsearch将来一定是集群，例如我集群有5个节点，我要查询TOP1000的数据，并不是每个节点查询200条就可以了。

因为节点A的TOP200，在另一个节点可能排到10000名以外了。

因此要想获取整个集群的TOP1000，必须先查询出每个节点的TOP1000，汇总结果后，重新排名，重新截取TOP1000。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056955.png" alt="image-20210721201003229" style="zoom:50%;" />

那如果我要查询9900~10000的数据呢？是不是要先查询TOP10000呢？那每个节点都要查询10000条？汇总到内存中？

当查询分页深度较大时，汇总数据过多，对内存和CPU会产生非常大的压力，因此elasticsearch会禁止from+ size 超过10000的请求。如果想要修改，可以修改search_after参数

针对深度分页，ES提供了两种解决方案，[官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html)：

- search after：分页时需要排序，原理是从上一次的排序值开始，查询下一页数据。官方推荐使用的方式。
- scroll：原理将排序后的文档id形成快照，保存在内存。官方已经不推荐使用。

### 2.2.3.小结

分页查询的常见实现方案以及优缺点：

- `from + size`：
  - 优点：支持随机翻页
  - 缺点：深度分页问题，默认查询上限（from + size）是10000
  - 场景：百度、京东、谷歌、淘宝这样的随机翻页搜索
- `after search`：
  - 优点：没有查询上限（单次查询的size不超过10000）
  - 缺点：只能**向后逐页**查询，不支持随机翻页，因为是从上一次分页的值向后继续查询
  - 场景：没有随机翻页需求的搜索，例如手机向下滚动翻页

- `scroll`：
  - 优点：没有查询上限（单次查询的size不超过10000）
  - 缺点：会有额外内存消耗，并且搜索结果是非实时的
  - 场景：海量数据的获取和迁移。从ES7.1开始不推荐，建议用 after search方案。

## 2.3.高亮

### 2.3.1.高亮原理

什么是高亮显示呢？

我们在百度，京东搜索时，关键字会变成红色，比较醒目，这叫高亮显示：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056956.png" alt="image-20210721202705030" style="zoom:50%;" />

高亮显示的实现分为两步：

- 1）给文档中的所有关键字都添加一个标签，例如`<em>`标签
- 2）页面给`<em>`标签编写CSS样式，样式决定了关键字的颜色以及字体大小，是否变粗等效果

### 2.3.2.实现高亮

**高亮的语法**：

```json
GET /hotel/_search
{
  "query": {
    "match": {
      "FIELD": "TEXT" // 查询条件，高亮一定要使用全文检索查询
    }
  },
  "highlight": {
    "fields": { // 指定要高亮的字段，当要高亮的字段不是搜索字段时需要加上一个属性
      "FIELD": {
        "pre_tags": "<em>",  // 用来标记高亮字段的前置标签
        "post_tags": "</em>" // 用来标记高亮字段的后置标签
      }
    }
  }
}
```

**注意：**

- 高亮是对关键字高亮，因此**搜索条件必须带有关键字**，而不能是范围这样的查询。
- 默认情况下，**高亮的字段，必须与搜索指定的字段一致**，否则无法高亮
- 如果要对**非搜索字段高亮**，则需要添加一个属性：`required_field_match=false`，例如搜索的是all字段，但是想要高亮的只是name字段，不想要所有的地方都高亮，此时就需要加上这个属性

**示例**：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056957.png" alt="image-20210721203349633" style="zoom:50%;" />

默认情况下，高亮自动添加的是`<em></em>`标签

## 2.4.总结

查询的DSL是一个大的JSON对象，包含下列属性：

- query：查询条件
- from和size：分页条件
- sort：排序条件
- highlight：高亮条件

示例：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056959.png" alt="image-20210721203657850" style="zoom:50%;" />

# 3.RestClient查询文档

使用java代码进行文档的查询同样适用昨天学习的 RestHighLevelClient对象，基本步骤包括：

- 1）准备Request对象
- 2）准备**请求参数**
- 3）发起请求
- 4）解析响应

## 3.1.快速入门

我们以match_all查询为例

### 3.1.1.发起查询请求

![image-20210721203950559](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056960.png)

代码解读：

- 第一步，创建`SearchRequest`对象，指定索引库名

- 第二步，利用`request.source()`构建 DSL，DSL中可以包含查询、分页、排序、高亮等
  - `query()`：代表查询条件，利用`QueryBuilders.matchAllQuery()`构建一个match_all查询的DSL
- 第三步，利用client.search()发送请求，得到响应

这里关键的API有两个，一个是`request.source()`，其中包含了查询、排序、分页、高亮等所有功能，之后利用这个方法进行文档的各种查询：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056961.png" alt="image-20210721215640790" style="zoom:50%;" />

另一个是`QueryBuilders`，其中包含match、term、function_score、bool等各种查询：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056962.png" alt="image-20210721215729236" style="zoom:50%;" />

拼接好之后利用client向elasticsearch发送查询请求并得到结果

### 3.1.2.解析响应

响应结果的解析：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056963.png" alt="image-20210721214221057" style="zoom:50%;" />

获取到最终查询到的string类型的文档之后，可以将其转换成java对象进行处理

elasticsearch返回的结果是一个JSON字符串，结构包含：

- `hits`：命中的结果
  - `total`：总条数，其中的value是具体的总条数值
  - `max_score`：所有结果中得分最高的文档的相关性算分
  - `hits`：搜索结果的文档数组，其中的每个文档都是一个json对象
    - `_source`：文档中的原始数据，也是json对象

因此，我们解析响应结果，就是**逐层解析**JSON字符串，流程如下：

- `SearchHits`：通过response.getHits()获取，就是JSON中的最外层的hits，代表命中的结果
  - `SearchHits#getTotalHits().value`：获取总条数信息
  - `SearchHits#getHits()`：获取SearchHit数组，也就是文档数组
    - `SearchHit#getSourceAsString()`：获取文档结果中的_source，也就是原始的json文档数据

### 3.1.3.完整代码

完整代码如下：

```java
@Test
void testMatchAll() throws IOException {
    // 1.准备Request
    SearchRequest request = new SearchRequest("hotel");
    // 2.准备DSL
    request.source()
        .query(QueryBuilders.matchAllQuery());
    // 3.发送请求
    SearchResponse response = client.search(request, RequestOptions.DEFAULT);

    // 4.解析响应
    handleResponse(response);
}

private void handleResponse(SearchResponse response) {
    // 4.解析响应
    SearchHits searchHits = response.getHits();
    // 4.1.获取总条数
    long total = searchHits.getTotalHits().value;
    System.out.println("共搜索到" + total + "条数据");
    // 4.2.文档数组
    SearchHit[] hits = searchHits.getHits();
    // 4.3.遍历
    for (SearchHit hit : hits) {
        // 获取文档source
        String json = hit.getSourceAsString();
        // 反序列化，将String类型的json数据转换成java对象
        HotelDoc hotelDoc = JSON.parseObject(json, HotelDoc.class);
        System.out.println("hotelDoc = " + hotelDoc);
    }
}
```

### 3.1.4.小结

查询的基本步骤是：

1. 创建SearchRequest对象

2. 准备Request.source()，也就是DSL。

   ① QueryBuilders来构建查询条件

   ② 传入Request.source() 的 query() 方法

3. 发送请求，得到结果

4. 解析结果（参考JSON结果，从外到内，逐层解析）

## 3.2.match查询

全文检索的match和multi_match查询与match_all的API基本一致。差别是查询条件，也就是query的部分。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056964.png" alt="image-20210721215923060" style="zoom:50%;" />

因此，Java代码上的差异主要是request.source().query()中的参数了。同样是利用QueryBuilders提供的方法：

![image-20210721215843099](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056965.png) 

而结果解析代码则完全一致，可以抽取并共享。

完整代码如下：

```java
@Test
void testMatch() throws IOException {
    // 1.准备Request
    SearchRequest request = new SearchRequest("hotel");
    // 2.准备DSL，如果是多字段查询，第一个参数是查询条件，后面的参数是查询字段
    request.source()
        .query(QueryBuilders.matchQuery("all", "如家"));
    // 3.发送请求
    SearchResponse response = client.search(request, RequestOptions.DEFAULT);
    // 4.解析响应
    handleResponse(response);

}
```

## 3.3.精确查询

精确查询主要是两者：

- term：词条精确匹配
- range：范围查询

与之前的查询相比，差异同样在查询条件，其它都一样。

查询条件构造的API如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056966.png" alt="image-20210721220305140" style="zoom:50%;" />

## 3.4.布尔查询

布尔查询是用must、must_not、filter等方式组合其它查询，代码示例如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056967.png" alt="image-20210721220927286" style="zoom:50%;" />

可以看到，API与其它查询的差别同样是在查询条件的构建，QueryBuilders，结果解析等其他代码完全不变。

完整代码如下：

```java
@Test
void testBool() throws IOException {
    // 1.准备Request
    SearchRequest request = new SearchRequest("hotel");
    // 2.准备DSL
    // 2.1.准备BooleanQuery
    //不再是直接用QueryBuilders进行拼接，而是使用BooleanQuery
    BoolQueryBuilder boolQuery = QueryBuilders.boolQuery();
    // 2.2.添加term
    boolQuery.must(QueryBuilders.termQuery("city", "杭州"));
    // 2.3.添加range
    boolQuery.filter(QueryBuilders.rangeQuery("price").lte(250));

    request.source().query(boolQuery);
    // 3.发送请求
    SearchResponse response = client.search(request, RequestOptions.DEFAULT);
    // 4.解析响应
    handleResponse(response);

}
```

## 3.5.排序、分页

搜索结果的排序和分页是与query同级的参数，因此同样是使用request.source()来设置。

对应的API如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056968.png" alt="image-20210721221121266" style="zoom:50%;" />

完整代码示例：

```java
@Test
void testPageAndSort() throws IOException {
    // 页码，每页大小
    int page = 1, size = 5;

    // 1.准备Request
    SearchRequest request = new SearchRequest("hotel");
    // 2.准备DSL，将所有的查询条件进行拼接
    // 2.1.query
    request.source().query(QueryBuilders.matchAllQuery());
    // 2.2.排序 sort
    request.source().sort("price", SortOrder.ASC);
    // 2.3.分页 from、size
    request.source().from((page - 1) * size).size(5);
    // 3.发送请求
    SearchResponse response = client.search(request, RequestOptions.DEFAULT);
    // 4.解析响应
    handleResponse(response);

}
```

## 3.6.高亮

高亮的代码与之前代码差异较大，有两点：

- 查询的DSL：其中除了查询条件，还需要添加高亮条件，同样是与query同级。
- 结果解析：结果除了要解析_source文档数据，还要解析高亮结果

### 3.6.1.高亮请求构建

高亮请求的构建API如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056969.png" alt="image-20210721221744883" style="zoom:50%;" />

上述代码省略了查询条件部分，但是大家不要忘了：高亮查询必须使用**全文检索查询**，并且要有搜索关键字，将来才可以对关键字高亮。

完整代码如下：

```java
@Test
void testHighlight() throws IOException {
    // 1.准备Request
    SearchRequest request = new SearchRequest("hotel");
    // 2.准备DSL
    // 2.1.query
    request.source().query(QueryBuilders.matchQuery("all", "如家"));
    // 2.2.高亮，因为要高亮的字段时非查询字段，所以要设置属性requireFieldMatch为false
    request.source().highlighter(new HighlightBuilder().field("name").requireFieldMatch(false));
    // 3.发送请求
    SearchResponse response = client.search(request, RequestOptions.DEFAULT);
    // 4.解析响应，此时响应得到的结果中，name字段就带上了<em></em>标签
    handleResponse(response);
}
```

### 3.6.2.高亮结果解析

**高亮的结果与查询的文档结果默认是分离**的，并不在一起。

因此解析高亮的代码需要额外处理：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056970.png" alt="image-20210721222057212" style="zoom:50%;" />

代码解读：

- 第一步：从结果中获取source。hit.getSourceAsString()，这部分是非高亮结果，json字符串。还需要反序列为HotelDoc对象
- 第二步：获取高亮结果。hit.getHighlightFields()，返回值是一个Map，key是高亮字段名称，值是HighlightField对象，代表高亮值，因为可能不止一个字段被高亮
- 第三步：从map中根据高亮字段名称，获取高亮字段值对象HighlightField
- 第四步：从HighlightField中获取Fragments，并且转为字符串。这部分就是真正的高亮字符串了
- 第五步：用高亮的结果**替换**HotelDoc中的非高亮结果

完整代码如下：

```java
private void handleResponse(SearchResponse response) {
    // 4.解析响应
    SearchHits searchHits = response.getHits();
    // 4.1.获取总条数
    long total = searchHits.getTotalHits().value;
    System.out.println("共搜索到" + total + "条数据");
    // 4.2.文档数组
    SearchHit[] hits = searchHits.getHits();
    // 4.3.遍历所有得到的文档结果并解析
    for (SearchHit hit : hits) {
        // 获取文档source
        String json = hit.getSourceAsString();
        // 反序列化
        HotelDoc hotelDoc = JSON.parseObject(json, HotelDoc.class);
        // 获取高亮结果
        Map<String, HighlightField> highlightFields = hit.getHighlightFields();
        if (!CollectionUtils.isEmpty(highlightFields)) {
            // 根据字段名获取高亮结果
            HighlightField highlightField = highlightFields.get("name");
            if (highlightField != null) {
                // 获取高亮值，第一个就是名字
                // 如果对all字段高亮，高亮结果数组中就有多个值，因为一个文档中的all字段拷贝了多个字段的内容，这些内容都可能高亮
                //如果对多个字段高亮，此时就会有多个高亮结果数组
                String name = highlightField.getFragments()[0].string();
                // 覆盖非高亮结果
                hotelDoc.setName(name);
            }
        }
        System.out.println("hotelDoc = " + hotelDoc);
    }
}
```

# 4.黑马旅游案例

下面，我们通过黑马旅游的案例来实战演练下之前学习的知识。

我们实现四部分功能：

- 酒店搜索和分页
- 酒店结果过滤
- 我周边的酒店
- 酒店竞价排名

启动我们提供的hotel-demo项目，其默认端口是8089，访问http://localhost:8090，就能看到项目页面了：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056971.png" alt="image-20210721223159598" style="zoom:50%;" />



## 4.1.酒店搜索和分页

案例需求：实现黑马旅游的酒店搜索功能，完成关键字搜索和分页

### 4.1.1.需求分析

在项目的首页，有一个大大的搜索框，还有分页按钮：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056972.png" alt="image-20210721223859419" style="zoom:50%;" />

点击搜索按钮，可以看到浏览器控制台发出了请求：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056973.png" alt="image-20210721224033789" style="zoom:50%;" />

请求参数如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056974.png" alt="image-20210721224112708" style="zoom:50%;" />

由此可以知道，我们这个请求的信息如下：

- 请求方式：POST
- 请求路径：/hotel/list
- 请求参数：JSON对象，包含4个字段：
  - key：搜索关键字
  - page：页码
  - size：每页大小
  - sortBy：排序，目前暂不实现
- 返回值：分页查询，需要返回分页结果`PageResult`，包含两个属性：
  - `total`：总条数
  - `List<HotelDoc>`：当前页的数据

> 请求参数的格式从请求中就能看出来，返回的结果只有在前端代码中才能看出来需要什么结构的数据

因此，我们实现业务的流程如下：

- 步骤一：定义实体类，接收请求参数的JSON对象
- 步骤二：编写controller，接收页面的请求
- 步骤三：编写业务实现，利用RestHighLevelClient实现搜索、分页

### 4.1.2.定义实体类

实体类有两个，一个是前端的请求参数实体，一个是服务端应该返回的响应结果实体。

1）请求参数

前端请求的json结构如下：

```json
{
    "key": "搜索关键字",
    "page": 1,
    "size": 3,
    "sortBy": "default"
}
```

因此，我们在`cn.itcast.hotel.pojo`包下定义一个实体类：

```java
package cn.itcast.hotel.pojo;

import lombok.Data;

@Data
public class RequestParams {
    private String key;
    private Integer page;
    private Integer size;
    private String sortBy;
}
```

2）返回值

分页查询，需要返回分页结果PageResult，包含两个属性：

- `total`：总条数
- `List<HotelDoc>`：当前页的数据

因此，我们在`cn.itcast.hotel.pojo`中定义返回结果：

```java
package cn.itcast.hotel.pojo;

import lombok.Data;

import java.util.List;

@Data
public class PageResult {
    //包含当前查询到了多少条文档以及所有的文档被存储到一个容器中返回
    private Long total;
    private List<HotelDoc> hotels;

    public PageResult() {
    }

    public PageResult(Long total, List<HotelDoc> hotels) {
        this.total = total;
        this.hotels = hotels;
    }
}
```

### 4.1.3.定义controller

定义一个HotelController，声明查询接口，满足下列要求：

- 请求方式：Post
- 请求路径：/hotel/list
- 请求参数：对象，类型为RequestParam
- 返回值：PageResult，包含两个属性
  - `Long total`：总条数
  - `List<HotelDoc> hotels`：酒店数据

因此，我们在`cn.itcast.hotel.web`中定义HotelController：

```java
@RestController
@RequestMapping("/hotel")
public class HotelController {

    @Autowired
    private IHotelService hotelService;
	// 搜索酒店数据
    @PostMapping("/list")
    public PageResult search(@RequestBody RequestParams params){
        return hotelService.search(params);
    }
}
```

### 4.1.4.实现搜索业务

我们在controller调用了IHotelService，并没有实现该方法，因此下面我们就在IHotelService中定义方法，并且去实现业务逻辑。

1）在`cn.itcast.hotel.service`中的`IHotelService`接口中定义一个方法：

```java
/**
 * 根据关键字搜索酒店信息
 * @param params 请求参数对象，包含用户输入的关键字 
 * @return 酒店文档列表
 */
PageResult search(RequestParams params);
```

2）实现搜索业务，肯定离不开RestHighLevelClient，我们需要把它注册到Spring中作为一个Bean。在`cn.itcast.hotel`中的`HotelDemoApplication`中声明这个Bean，之后spring自动将其注册为bean：

```java
@Bean
public RestHighLevelClient client(){
    return  new RestHighLevelClient(RestClient.builder(
        HttpHost.create("http://192.168.150.101:9200")
    ));
}
```

3）在`cn.itcast.hotel.service.impl`中的`HotelService`中实现search方法，向elasticsearch中发送DSL语句得到结果：

```java
@Override
public PageResult search(RequestParams params) {
    try {
        // 1.准备Request
        SearchRequest request = new SearchRequest("hotel");
        // 2.准备DSL
        // 2.1.query
        String key = params.getKey();
        if (key == null || "".equals(key)) {
            boolQuery.must(QueryBuilders.matchAllQuery());
        } else {
            boolQuery.must(QueryBuilders.matchQuery("all", key));
        }

        // 2.2.分页
        int page = params.getPage();
        int size = params.getSize();
        request.source().from((page - 1) * size).size(size);

        // 3.发送请求
        SearchResponse response = client.search(request, RequestOptions.DEFAULT);
        // 4.解析响应
        return handleResponse(response);
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
}

// 结果解析，主要是将查询到的json数据中的hits中的数据取出来并解析成java对象 
private PageResult handleResponse(SearchResponse response) {
    // 4.解析响应
    SearchHits searchHits = response.getHits();
    // 4.1.获取总条数
    long total = searchHits.getTotalHits().value;
    // 4.2.文档数组
    SearchHit[] hits = searchHits.getHits();
    // 4.3.遍历
    List<HotelDoc> hotels = new ArrayList<>();
    for (SearchHit hit : hits) {
        // 获取文档source
        String json = hit.getSourceAsString();
        // 反序列化
        HotelDoc hotelDoc = JSON.parseObject(json, HotelDoc.class);
		// 放入集合
        hotels.add(hotelDoc);
    }
    // 4.4.封装返回
    return new PageResult(total, hotels);
```

## 4.2.酒店结果过滤

需求：添加品牌、城市、星级、价格等过滤功能

### 4.2.1.需求分析

在页面搜索框下面，会有一些过滤项：

![image-20210722091940726](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056975.png)

传递的参数如图：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056976.png" alt="image-20210722092051994" style="zoom:50%;" />

 包含的过滤条件有：

- brand：品牌值
- city：城市
- minPrice~maxPrice：价格范围
- starName：星级

我们需要做两件事情：

- 修改请求参数的对象RequestParams，接收上述参数
- 修改业务逻辑，在搜索条件之外，添加一些过滤条件

### 4.2.2.修改实体类

修改在`cn.itcast.hotel.pojo`包下的实体类RequestParams：

```java
@Data
public class RequestParams {
    private String key;
    private Integer page;
    private Integer size;
    private String sortBy;
    // 下面是新增的过滤条件参数，这些参数可能为空
    private String city;
    private String brand;
    private String starName;
    private Integer minPrice;
    private Integer maxPrice;
}
```

### 4.2.3.修改搜索业务

在HotelService的search方法中，只有一个地方需要修改：requet.source().query( ... )其中的查询条件。

在之前的业务中，只有match查询，根据关键字搜索，现在要添加条件过滤，包括：

- 品牌过滤：是keyword类型，用term查询
- 星级过滤：是keyword类型，用term查询
- 价格过滤：是数值类型，用range查询
- 城市过滤：是keyword类型，用term查询

多个查询条件组合，肯定是boolean查询来组合：

- 关键字搜索放到must中，参与算分
- 其它过滤条件放到filter中，不参与算分

因为条件构建的逻辑比较复杂，这里先封装为一个函数：

![image-20210722092935453](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056977.png)

`buildBasicQuery`的代码如下，这里主要是拼接好request：

```java
private void buildBasicQuery(RequestParams params, SearchRequest request) {
    // 1.构建BooleanQuery
    BoolQueryBuilder boolQuery = QueryBuilders.boolQuery();
    //下面的参数真的传递了才会拼接查询条件
    // 2.关键字搜索
    String key = params.getKey();
    if (key == null || "".equals(key)) {
        boolQuery.must(QueryBuilders.matchAllQuery());
    } else {
        boolQuery.must(QueryBuilders.matchQuery("all", key));
    }
    //下面的条件都是不为空才拼接
    // 3.城市条件
    if (params.getCity() != null && !params.getCity().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("city", params.getCity()));
    }
    // 4.品牌条件
    if (params.getBrand() != null && !params.getBrand().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("brand", params.getBrand()));
    }
    // 5.星级条件
    if (params.getStarName() != null && !params.getStarName().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("starName", params.getStarName()));
    }
	// 6.价格
    if (params.getMinPrice() != null && params.getMaxPrice() != null) {
        boolQuery.filter(QueryBuilders
                         .rangeQuery("price")
                         .gte(params.getMinPrice())
                         .lte(params.getMaxPrice())
                        );
    }
	// 7.放入source
    request.source().query(boolQuery);
}
```

## 4.3.我周边的酒店

需求：我附近的酒店

### 4.3.1.需求分析

在酒店列表页的右侧，有一个小地图，点击地图的定位按钮，地图会找到你所在的位置：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056978.png" alt="image-20210722093414542" style="zoom:50%;" />

 并且，在前端会发起查询请求，将你的坐标发送到服务端：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056979.png" alt="image-20210722093642382" style="zoom:50%;" />

 我们要做的事情就是基于这个location坐标，然后按照距离对周围酒店排序。实现思路如下：

- 修改RequestParams参数，接收location字段
- 修改search方法业务逻辑，如果location有值，添加根据geo_distance排序的功能

### 4.3.2.修改实体类

修改在`cn.itcast.hotel.pojo`包下的实体类RequestParams：

```java
package cn.itcast.hotel.pojo;

import lombok.Data;

@Data
public class RequestParams {
    private String key;
    private Integer page;
    private Integer size;
    private String sortBy;
    private String city;
    private String brand;
    private String starName;
    private Integer minPrice;
    private Integer maxPrice;
    // 我当前的地理坐标，这是新增的字段
    private String location;
}

```

### 4.3.3.距离排序API

我们以前学习过排序功能，包括两种：

- 普通字段排序
- 地理坐标排序

我们只讲了普通字段排序对应的java写法。地理坐标排序只学过DSL语法，如下：

```json
GET /indexName/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "price": "asc"  
    },
    {
      "_geo_distance" : {
          "FIELD" : "纬度，经度",
          "order" : "asc",
          "unit" : "km"
      }
    }
  ]
}
```

对应的java代码示例：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056980.png" alt="image-20210722095227059" style="zoom:50%;" />

### 4.3.4.添加距离排序

在`cn.itcast.hotel.service.impl`的`HotelService`的`search`方法中，添加一个排序功能：

![image-20210722095902314](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056981.png)

完整代码：

```java
@Override
public PageResult search(RequestParams params) {
    try {
        // 1.准备Request
        SearchRequest request = new SearchRequest("hotel");
        // 2.准备DSL
        // 2.1.query
        buildBasicQuery(params, request);

        // 2.2.分页
        int page = params.getPage();
        int size = params.getSize();
        request.source().from((page - 1) * size).size(size);

        // 2.3.排序
        String location = params.getLocation();
        if (location != null && !location.equals("")) {
            request.source().sort(SortBuilders
                                  .geoDistanceSort("location", new GeoPoint(location))
                                  .order(SortOrder.ASC)
                                  .unit(DistanceUnit.KILOMETERS)
                                 );
        }

        // 3.发送请求
        SearchResponse response = client.search(request, RequestOptions.DEFAULT);
        // 4.解析响应
        return handleResponse(response);
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
}
```

### 4.3.5.排序距离显示

重启服务后，测试我的酒店功能：

![image-20210722100040674](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056982.png)



发现确实可以实现对我附近酒店的排序，不过并没有看到酒店到底距离我多远，这该怎么办？

排序完成后，页面还要**获取**我附近每个酒店的具体**距离**值，这个值在响应结果中是独立的：

![image-20210722095648542](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056983.png)

因此，我们在结果解析阶段，除了解析source部分以外，还要得到sort部分，也就是排序的距离，然后放到响应结果中。

我们要做两件事：

- 修改HotelDoc，添加排序距离字段，用于页面显示
- 修改HotelService类中的handleResponse方法，添加对sort值的获取

1）修改HotelDoc类，添加距离字段

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
    // 排序时的 距离值
    private Object distance;

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
        //地址等于经纬度拼接
        this.location = hotel.getLatitude() + ", " + hotel.getLongitude();
        tis.pic = hotel.getPic();
    }
}

```

2）修改HotelService中的handleResponse方法

![image-20210722100613966](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056984.png)

重启后测试，发现页面能成功显示距离了：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056985.png" alt="image-20210722100838604" style="zoom:50%;" />

## 4.4.酒店竞价排名

需求：让指定的酒店在搜索结果中排名置顶

### 4.4.1.需求分析

要让指定酒店在搜索结果中排名置顶，效果如图：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056986.png" alt="image-20210722100947292" style="zoom:50%;" />

页面会给指定的酒店添加**广告**标记

那怎样才能让指定的酒店排名置顶呢？

我们之前学习过的function_score查询可以影响算分，算分高了，自然排名也就高了。而function_score包含3个要素：

- 过滤条件：哪些文档要加分
- 算分函数：如何计算function score
- 加权方式：function score 与 query score如何运算

这里的需求是：让**指定酒店**排名靠前。因此我们需要给这些酒店添加一个标记，这样在过滤条件中就可以**根据这个标记来判断，是否要提高算分**。

比如，我们给酒店添加一个字段：isAD，Boolean类型：

- true：是广告
- false：不是广告

这样function_score包含3个要素就很好确定了：

- 过滤条件：判断isAD 是否为true，为true的才重新算分
- 算分函数：我们可以用最简单暴力的weight，固定加权值
- 加权方式：可以用默认的相乘，大大提高算分

因此，业务的实现步骤包括：

1. 给HotelDoc类添加isAD字段，Boolean类型

2. 挑选几个你喜欢的酒店，给它的文档数据添加isAD字段，值为true

3. 修改search方法，添加function score功能，给isAD值为true的酒店增加权重

### 4.4.2.修改HotelDoc实体

给`cn.itcast.hotel.pojo`包下的HotelDoc类添加isAD字段：

![image-20210722101908062](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056987.png)

这里添加广告标记的目的是为了前端给对应的记录打上广告标记

### 4.4.3.添加广告标记

接下来，我们挑几个酒店，添加isAD字段，设置为true：

```json
//给索引库中的几个文档添加一个isAD字段并设置为true，代表这几个文档投了广告
POST /hotel/_update/1902197537
{
    "doc": {
        "isAD": true
    }
}
POST /hotel/_update/2056126831
{
    "doc": {
        "isAD": true
    }
}
POST /hotel/_update/1989806195
{
    "doc": {
        "isAD": true
    }
}
POST /hotel/_update/2056105938
{
    "doc": {
        "isAD": true
    }
}
```

### 4.4.4.添加算分函数查询

接下来我们就要修改查询条件了。之前是用的boolean 查询，现在要改成function_socre查询。

function_score查询结构如下：

![image-20210721191544750](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056947.png)

对应的JavaAPI如下：

![image-20210722102850818](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202403012056988.png)



我们可以将之前写的boolean查询作为**原始查询**条件放到query中，接下来就是添加**过滤条件**、**算分函数**、**加权模式**了。所以原来的代码依然可以沿用。

修改`cn.itcast.hotel.service.impl`包下的`HotelService`类中的`buildBasicQuery`方法，添加算分函数查询：

```java
private void buildBasicQuery(RequestParams params, SearchRequest request) {
    // 1.构建BooleanQuery
    BoolQueryBuilder boolQuery = QueryBuilders.boolQuery();
    // 关键字搜索
    String key = params.getKey();
    if (key == null || "".equals(key)) {
        boolQuery.must(QueryBuilders.matchAllQuery());
    } else {
        boolQuery.must(QueryBuilders.matchQuery("all", key));
    }
    // 城市条件
    if (params.getCity() != null && !params.getCity().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("city", params.getCity()));
    }
    // 品牌条件
    if (params.getBrand() != null && !params.getBrand().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("brand", params.getBrand()));
    }
    // 星级条件
    if (params.getStarName() != null && !params.getStarName().equals("")) {
        boolQuery.filter(QueryBuilders.termQuery("starName", params.getStarName()));
    }
    // 价格
    if (params.getMinPrice() != null && params.getMaxPrice() != null) {
        boolQuery.filter(QueryBuilders
                         .rangeQuery("price")
                         .gte(params.getMinPrice())
                         .lte(params.getMaxPrice())
                        );
    }

    // 2.算分控制
    FunctionScoreQueryBuilder functionScoreQuery =
        QueryBuilders.functionScoreQuery(
        // 原始查询，相关性算分的查询
        boolQuery,
        // function score的数组
        new FunctionScoreQueryBuilder.FilterFunctionBuilder[]{
            // 其中的一个function score 元素
            new FunctionScoreQueryBuilder.FilterFunctionBuilder(
                // 过滤条件
                QueryBuilders.termQuery("isAD", true),
                // 算分函数，默认相乘
                ScoreFunctionBuilders.weightFactorFunction(10)
            )
        });
    request.source().query(functionScoreQuery);
}
```

此时在前端页面就会优先展示广告，这些广告文档的得分会变得更高，并且会打上广告标记









