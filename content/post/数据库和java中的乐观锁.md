---
title: "数据库和java中的乐观锁"
description: "数据库和java中的乐观锁"
keywords: "数据库和java中的乐观锁"

date: 2023-10-28T14:38:13+08:00
lastmod: 2023-10-28T14:38:13+08:00

categories:
  - 学习笔记
tags:
  - 乐观锁


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
#url: "数据库和java中的乐观锁.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>数据库和java中的乐观锁

本文介绍`mybatis plus`和java代码中的乐观锁使用的不同，主要是针对代码层面进行分析

先介绍`mybatis plus`实现乐观锁的流程，然后介绍传统java代码中乐观锁的执行流程

<!--more-->

本文主要介绍乐观锁，乐观锁认为，不是所有的并发操作都会出现问题，只有极少数的并发操作会出现丢失更新等风险，于是没有必要对于所有的请求进行加锁排队，这样大大浪费了资源，而对所有的请求都加锁的操作成为悲观锁，这种技术比较粗暴

乐观锁先放任所有的请求都执行，然后在更新的过程中执行CAS算法，也就是先进行操作，操作之后将这个值与更新前的值进行对比，如果没有变化就真的操作更新，如果这个值发生了变化，此时说明这个值被别人修改过了，当前这次更新需要作废，也就是`Compare And Swap`

另外一种乐观锁的机制是版本号机制

## 数据库

数据库为了防止出现并发操作带来的问题，实现了一个乐观锁，这个乐观锁是基于**版本号**机制的 

- 取出记录时，获取当前`version`
- 更新时，带上这个`version`
- 执行更新时， `set version = newVersion where version = oldVersion`
- 如果`version`不对，就更新失败

### 执行流程

1. 数据库添加一个字段，一般名称为`version`，初始值为1：

   ![image-20231028144747390](C:/Users/zzzi/AppData/Roaming/Typora/typora-user-images/image-20231028144747390.png)

2. java代码中的`pojo`实体类中添加一个属性，名称与数据库中的字段名保持一致，并且添加`@Version`注解，代表这个属性受到乐观锁的控制：

   ```java
   @Data
   public class User {
      	@TableId(type = IdType.ASSIGN_ID)
       private Long id;
       private String name;
       @TableField(value = "pwd",select = false)
       private String password;
       private Integer age;
       private String tel;
       @TableField(exist = false)
       private Integer online;
      	@TableLogic(value = "0" ,delval = "1")
       private Integer deleted;
       //添加数据库同名属性，并且加上@Version注解
       @Version
       private Integer version;
   }
   ```

3. 给mybatis plus设置乐观锁拦截器，将这个类设置为配置类，这样springboot就可以扫描到这个配置：

   ```java
   @Configuration
   public class MpConfig {
       @Bean
       public MybatisPlusInterceptor mpInterceptor() {
           //1.定义Mp拦截器
           MybatisPlusInterceptor mpInterceptor 
               = new MybatisPlusInterceptor();
           //2.添加具体的拦截器
           mpInterceptor.addInnerInterceptor(new PaginationInnerInterceptor());
           //3.添加乐观锁拦截器
           mpInterceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
           return mpInterceptor;
       }
   }
   ```

经过以上三步之后就可以实现一个乐观锁，对数据的操作不会出现并发问题，那么这样实现的原理是什么呢？

### 原理

为了实现这个乐观锁，经历了上面三步，第一步是为了将让乐观锁控制数据的并发更新增加的字段，有了这一步才能执行下面的操作。第二步和第三步是为了让乐观锁对版本进行控制，每次更新前拿到version的最新值，例如是3，然后对这条记录进行更新的时候，将version的值+1；

如果此时有两个请求同时访问同一条记录，此时拿到的version都会是3，当其中有一个先更新完成之后，version的值为4，此时第二条记录还拿着version=3的条件去表中搜索，就压根搜索不到这条想要修改的数据。就自然更新不了

在代码中来看：

```java
@Test
void testUpdate(){

    //1.先通过要修改的数据id将当前数据查询出来
    //都拿到的是version=3
    User user = userDao.selectById(3L);     //version=3
    User user2 = userDao.selectById(3L);    //version=3
	//2.第一个请求尝试更新数据
    user2.setName("Jock aaa");
    userDao.updateById(user2);              //version=>4
	//3.第二个请求尝试继续更新数据
    user.setName("Jock bbb");
    userDao.updateById(user);               //verion=3?条件还成立吗？
}
```

从代码分析来看，有两个更新的操作，这两个更新的操作都拿到了version=3，之后第一个请求尝试更新，`mybatis plus`拼接出的SQL代码为：

```java
==>  Preparing: UPDATE user SET name=?, password=?, age=?, version=? WHERE id=? AND version=? AND deleted=0
==> Parameters: Jock aaa(String), 4325345(String), 56(Integer), 4(Integer), 3(Long), 3(Integer)
<==    Updates: 1
```

> 可以看出最核心的就是筛选条件一共有三个，分别是id，version和deleted，此时的version还是3，于是可以查询到数据，更新之后将version设置为4

第一个请求更新完毕之后，第二个请求尝试更新，`mybatis plus`拼接出的SQL代码为：

```java
==>  Preparing: UPDATE user SET name=?, password=?, age=?, version=? WHERE id=? AND version=? AND deleted=0
==> Parameters: Jock bbb(String), 4325345(String), 56(Integer), 4(Integer), 3(Long), 3(Integer)
<==    Updates: 0
```

> 此时拼接出的SQL语句中，筛选条件中的`version`还是3，而第一个请求将version更新为了4，相当于这个SQL语句没有办法查询到对应的数据，自然无法更新

### 总结

分析上述的执行流程来看。为了实现乐观锁，`mybatis plus`主要是在原有的SQL代码的基础上拼接了一个新的筛选条件`version=？`，如果拿到的`version`被别人更新了，那么自己的更新条件就不会执行，或者说执行了也没有效果

实现拼接的效果是乐观锁拦截器实现的，关键在于每次更新记录都将version更新

## Java

java中为了实现乐观锁，使用的是CAS机制，这里以修改整型为例介绍CAS机制的乐观锁

### 原理

1. 修改时不加锁，正常对代码中的数据或者变量进行修改，修改时调用的是原子类提供的方法：

   ```java
   public class AtomicDemo {
   
       public static void main(String[] args) {
           //定义原子类
           AtomicInteger atomicInteger = new AtomicInteger(1);
           //定义线程池
           ExecutorService service = Executors.newFixedThreadPool(10);
           //使用线程对这个数修改100次
           for (int i = 0; i < 100; i++) {
               service.submit(()->{
                   //调用原子类的方法进行修改
                   atomicInteger.incrementAndGet();
               });
           }
           try {
               TimeUnit.SECONDS.sleep(1);
           } catch (InterruptedException e) {
               e.printStackTrace();
           }
           System.out.println(atomicInteger.get());
       }
   }
   ```

   > 主要的操作就是调用原子类实现的方法进行修改，这样就实现了乐观锁

2. 原子类的方法`atomicInteger.incrementAndGet();`又调用了其中一个方法：

   ```java
   // AtomicInteger.java
   public final int incrementAndGet() {
       //this代表当前要累加的原子对象
       //valueOffset代表当前原子对象的值存在的地址
       //1代表每次累加1
       //unsafe.getAndAddInt(this, valueOffset, 1)的返回值是修改之前的值
       //+1之后向上返回，得到更新后的值
       return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
   }
   // UnSafe.java
   //var1=this
   //var2=valuePffset
   //var4=1
   public final int getAndAddInt(Object var1, long var2, int var4) {
       int var5;
       do {
           //得到原子对象中的真实值，
           var5 = this.getIntVolatile(var1, var2);
           //尝试真的去修改var5，将其+1，只有底层的var5还是旧的var5时才会更新
           //底层的var5被别人修改过了，说明修改失败返回false，取反实现while循环一直执行，代表继续尝试更新
           //修改成功返回true，取反实现跳出while循环
       } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));
   	//到这里就说明更新成功，返回原始的未更新的var5
       return var5;
   }
   ```

主要是调用了一个`CAS`算法，只有`var5`的值没有变化，才说明当前记录没有被别人更新，此时才会更新，否则`while`循环一直执行，直到更新成功

### 总结

总结起来就是java代码中要实现乐观锁，需要使用一个原子类，并且调用原子类内部的指定方法，在内部对要修改的数据进行修改，只有修改成功才会返回，没修改成功就放弃这次修改，重新开始修改

为什么修改之后返回的是旧值呢，这是因为防止修改之后，另外的线程也对这个值进行了修改，如果都返回最新的修改值，那么就会出现每个线程返回值一样，都只+1，但是表现出来的好像加了好几次一样，于是返回的是当前线程想要增加之前的值，然后在外部+1，每个线程自己看到的就是在原先的基础上加了1，即使最新的值已经被很多线程加了很多次

## 总结

乐观锁有两种实现机制，分别是`CAS`机制和版本号机制，`java`代码中使用的是`CAS`机制，为了实现原子类，需要使用原子类中指定的方法，只有要修改的`var5`值没有被修改才能更新。`mybatis plus`中使用的是版本号机制，每次`SQL`查询时都拼接一个`version`的查询条件，只有`version`版本号对了才能查询到数据从而完成更新
