---
title: "H指数"
description: "H指数"
keywords: "H指数"

date: 2023-10-30T20:02:05+08:00
lastmod: 2023-10-30T20:02:05+08:00

categories:
  - leetcode
tags:
  - 每日一题


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
#url: "h指数.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>🏞️ H指数

给你一个整数数组 `citations` ，其中 `citations[i]` 表示研究者的第 `i` 篇论文被引用的次数。计算并返回该研究者的 **`h` 指数**。

根据维基百科上 [h 指数的定义](https://baike.baidu.com/item/h-index/3991452?fr=aladdin)：`h` 代表“高引用次数” ，一名科研人员的 `h` **指数** 是指他（她）至少发表了 `h` 篇论文，并且每篇论文 **至少** 被引用 `h` 次。如果 `h` 有多种可能的值，**`h` 指数** 是其中最大的那个。

<!--more-->

## 思路

### 基本思想

#### 思路1

主要就是要理解符合条件的H指数的定义为：**至少发表了 `h` 篇论文，并且每篇论文 至少 被引用 `h` 次**。这代表H指数的大小不可能超过给定的论文篇数，因为前面的至少发表了h篇论文限制了H指数的范围，并且后面的限制条件为每篇论文至少被引用h次的意思是引用的次数有限制

> 这样分析不好理解，直接从答案的角度进行分析[3,0,6,1,5]这个数组

1. 当H指数为0时，代表至少发表了0篇论文，每篇论文至少被引用了0次：这个条件很好满足，空集就可以满足，给定的[3,0,6,1,5]这个数组肯定可以满足，符合条件的论文数为5。所以H指数至少为0
2. 当H指数为1时，代表至少发表了1篇论文，每篇论文至少被引用了1次，符合条件的论文数为4，分别是[3,6,1,5]，所以H指数可以为1
3. 当H指数为2时，代表至少发表了2篇论文，每篇论文至少被引用2次，符合条件的论文数为3，分别是[3,6,5]，所以H指数可以为2
4. 当H指数为3时，代表至少发表了3篇论文，每篇论文至少被引用3次，符合条件的论文数为3，分别是[3,6,5]，所以H指数可以为3
5. 当H指数为4时，代表至少发表了4篇论文，每篇论文至少被引用4次，符合条件的论文数为2，分别是[6,5]，所以H指数不可以为4，因为每篇论文引用数至少是4，这样的论文只有两篇，所以不符合条件，4都不符合条件，5更加不符合条件

根据上面的分析流程，可以直接写出代码，分别模拟n为1,2,3,4。。。等数时的情况，看符合条件的论文数是否超过当前的n，超过时就可以成为H指数的候选，最终选一个最大的数作为H指数

#### 思路2

题目的核心思想是为了找到超出引用数n的文章数count有多少，当对于某一个n来说，其对应的count大于等于n时，这个数就有可能成为H指数，所以干脆统计每一种引用数对应的文章数有多少。并且按照思路1的分析,H指数的大小不可能超过文章的发表数，也就是`citations.length`,所以对于超过这个长度的引用数，直接截断到n，也就是等价于引用次数为`citations.length`

统计出每种引用次数对应的文章数有多少之后，让引用次数从大到小的变化，然后开始统计大于等于引用次数的论文数有多少，一旦出现所有的论文数大于等于当前这个引用次数时，就找到了最大的H指数

### 执行流程

#### 思路1

1. 针对每一篇文章，都判断自己的引用数citations[i]是不是大于当前引用数n，大于的话，符合条件的文章数count+1。最后看符合条件的文章数是不是大于引用数，也就是count是否大于n，大于的话就可以更新H指数

#### 思路2

1. 统计恰好是当前引用次数的文章数。超过数组长度的引用次数截断到数组长度
2. 从后向前逐渐减小引用次数，然后累加大于等于当前引用次数的文章数
3. 当文章数真的大于等于当前引用次数是，就找到了H

## 代码

根据以上分析，得出以下代码：

#### 思路1

```java
class Solution {
    //统计出所有的数出现的次数，当某个数出现的次数大于等于自身的值
    //那么这个数就有可能成为H指数，从这里面选一个最大的成为最终的H指数
    public int hIndex(int[] citations) {
        int res=0;
        for(int n=1;n<=citations.length;++n){
            int count=0;
            for(int i=0;i<citations.length;++i){
                //文章的引用数够
                if(citations[i]>=n){
                    ++count;
                }
            }
            if(count>=n){
                res=n;
            }else{
                break;
            }
        }
        return res;
    }
}
```

#### 思路2

```java
class Solution {
    //统计出所有的数出现的次数，当某个数出现的次数大于等于自身的值
    //那么这个数就有可能成为H指数，从这里面选一个最大的成为最终的H指数
    public int hIndex(int[] citations) {
        int[] counts=new int[citations.length+1];
        //统计引用数恰好为num的文章由几篇
        for(int num:citations){
            counts[Math.min(num,citations.length)]++;
        }
        int i=citations.length,total=0;
        for(;i>=0;--i){
            total+=counts[i];
            if(total>=i)
                break;
        }
        return i;
    }
}
```

## 总结

核心就是判断大于引用次数n的文章数count有多少，最后判断count是否大于n，大于的话，这个引用数就可以当成H指数的候选，最后选一个最大的

第二种思路的核心就是统计出所有恰好引用次数为n的文章数，然后对于当前引用数n来说，引用次数至少是n的文章数就是后面所有的文章数的和，所以从后向前统计所有大于等于当前引用次数的文章数总和，当总和大于等于当前引用数时，就找到了H指数
