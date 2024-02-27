---
title: "Springcloud学习笔记"
description: "springcloud学习笔记"
keywords: "springcloud学习笔记"

date: 2023-12-26T13:08:01+08:00
lastmod: 2023-12-26T13:08:01+08:00

categories:
  - 学习笔记
tags:
  - springcloud
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
#toc: true
# 绝对访问路径
# Absolute link for visit
#url: "springcloud学习笔记.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🦓 springcloud学习笔记

主要介绍`springcloud`集成的一些关于微服务的技术，例如`eureka`，`ribbon`，`nacos`，`feign`，`gateway`㩐技术，并初步介绍这些技术的使用方式

<!--more-->

## 微服务

微服务的架构特征：

- 单一职责：微服务拆分粒度更小，每一个服务都对应唯一的业务能力，做到单一职责
- 自治：团队独立、技术独立、数据独立，独立部署和交付
- 面向服务：服务提供统一标准的接口，与语言和技术无关
- 隔离性强：服务调用做好隔离、容错、降级，避免出现级联问题

![image-20210713203753373](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317863.png)

微服务的上述特性其实是在给分布式架构制定一个标准，进一步降低服务之间的**耦合度**，提供服务的独立性和灵活性。做到高内聚，低耦合。

因此，可以认为**微服务**是一种经过良好架构设计的**分布式架构方案** ，可以将项目中的服务进行拆分。

但方案该怎么落地？选用什么样的技术栈？全球的互联网公司都在积极尝试自己的微服务落地方案。

其中在Java领域最引人注目的就是SpringCloud提供的方案了。

### SpringCloud

SpringCloud是目前国内使用最广泛的微服务框架。官网地址：https://spring.io/projects/spring-cloud。

SpringCloud**集成**了各种微服务功能组件，并基于SpringBoot实现了这些组件的自动装配，从而提供了良好的开箱即用体验。

其中常见的组件包括：

![image-20210713204155887](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317864.png)

另外，SpringCloud底层是依赖于SpringBoot的，并且有版本的兼容关系，如下：

![image-20210713205003790](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317865.png)

> 针对springcloud有以下几点总结

- 单体架构：简单方便，高度耦合，扩展性差，适合小型项目。例如：学生管理系统

- 分布式架构：松耦合，扩展性好，但架构复杂，难度大。适合大型互联网项目，例如：京东、淘宝

- 微服务：一种良好的分布式架构方案

  ①优点：拆分粒度更小、服务更独立、耦合度更低

  ②缺点：架构非常复杂，运维、监控、部署难度提高

- SpringCloud是微服务架构的一站式解决方案，集成了各种优秀微服务功能组件

## 服务拆分和远程调用

任何分布式架构都离不开服务的拆分，微服务也是一样，上面介绍了为什么引入微服务，这一节介绍引入微服务之后，服务是如何拆分的，以及拆分之后服务与服务之间通信怎么办的问题。

### 2.1.服务拆分原则

这里我总结了微服务拆分时的几个原则：

- 不同微服务，不要重复开发相同业务
- 微服务数据独立，不要访问其它微服务的数据库
- 微服务可以将自己的业务暴露为接口，供其它微服务调用，这个主要是服务之间通信用的

![image-20210713210800950](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317866.png)

### 2.2.服务拆分示例

以微服务cloud-demo为例，其结构如下：

![image-20210713211009593](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317868.png)

cloud-demo：父工程，管理依赖的版本

- order-service：订单微服务，负责订单相关业务
- user-service：用户微服务，负责用户相关业务

要求：

- 订单微服务和用户微服务都必须有各自的数据库，相互独立
- 订单服务和用户服务都对外暴露Restful风格的接口
- 订单服务如果需要查询用户信息，只能调用用户服务的Restful接口，不能查询用户数据库

### 2.3.实现远程调用案例

在order-service服务中，有一个根据id查询订单的接口：

![image-20210713212749575](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317878.png)

根据id查询订单，返回值是Order对象，如图：

![image-20210713212901725](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317879.png)

其中的user为null，这显然不符合常理

在user-service中有一个根据id查询用户的接口：

![image-20210713213146089](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317880.png)

查询的结果如图：

![image-20210713213213075](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317881.png)

### 2.3.1.案例需求：

修改order-service中的根据id查询订单业务，要求在查询订单的同时，根据订单中包含的userId查询出用户信息，一起返回，相当于外部访问的是订单的微服务，但是订单微服务内部调用了用户的微服务，但是对外部用户无感。

![image-20210713213312278](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317882.png)



因此，我们需要在order-service中 向user-service发起一个http的请求，调用http://localhost:8081/user/{userId}这个接口，这是最原始的服务之间通信的方式。

大概的步骤是这样的：

- 注册一个`RestTemplate`的实例到Spring容器
- 修改order-service服务中的OrderService类中的queryOrderById方法，根据Order对象中的userId查询User
- 将查询的User填充到Order对象，一起返回

> 总结起来就是在合适的位置模拟浏览器的行为发送一个http的请求，然后得到返回值之后，将其封装到Order对象中返回，外部一次调用，内部实际上有两次调用

### 2.3.2.注册RestTemplate

首先，我们在order-service服务中的OrderApplication启动类中，注册RestTemplate实例，将其加入ioc容器中：

```java
package cn.itcast.order;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@MapperScan("cn.itcast.order.mapper")
@SpringBootApplication
public class OrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
	
    //在工程中引入RestTemplate的Bean的对象
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

### 2.3.3.实现远程调用

修改order-service服务中queryOrderById方法，在内部注入RestTemplate的bean对象，然后利用这个对象模拟浏览器发出http请求并接收请求的结果：

![image-20210713213959569](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317883.png)

### 2.4.提供者与消费者

在上面的服务调用关系中，会有两个不同的角色：

**服务提供者**：一次业务中，被其它微服务调用的服务。（提供接口给其它微服务）

**服务消费者**：一次业务中，调用其它微服务的服务。（调用其它微服务提供的接口）

![image-20210713214404481](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317884.png)

但是，服务提供者与服务消费者的角色并不是绝对的，而是相对于业务而言。

如果服务A调用了服务B，而服务B又调用了服务C，服务B的角色是什么？

- 对于A调用B的业务而言：A是服务消费者，B是服务提供者
- 对于B调用C的业务而言：B是服务消费者，C是服务提供者

因此，服务B既可以是服务提供者，也可以是服务消费者，我们需要一个管理中心来管理这些服务。

## Eureka注册中心

假如我们的服务提供者user-service部署了多个实例，如图：

![image-20210713214925388](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317885.png)

那么现在存在几个问题：

- order-service在发起远程调用的时候，该如何得知user-service实例的ip地址和端口？
- 有多个user-service实例地址，order-service调用时该如何选择？
- order-service如何得知某个user-service实例是否依然健康，是不是已经宕机？

### Eureka的结构和作用

这些问题都需要利用SpringCloud中的注册中心来解决，其中最广为人知的注册中心就是Eureka，其结构如下：

![image-20210713220104956](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317886.png)

回答之前的各个问题。

问题1：order-service如何得知user-service实例地址？

获取地址信息的流程如下：

- user-service服务实例启动后，将自己的信息注册到eureka-server（Eureka服务端）。这个叫服务注册
- eureka-server保存服务名称到服务实例地址列表的映射关系
- order-service想要使用别的服务时，根据服务名称，拉取实例地址列表。这个叫服务发现或服务拉取，此时就可以知道目标服务的地址从而进行通信

问题2：order-service如何从多个user-service实例中选择具体的实例？

- order-service从实例列表中利用**负载均衡算法**选中一个实例地址
- 向该实例地址发起远程调用

问题3：order-service如何得知某个user-service实例是否依然健康，是不是已经宕机？

- user-service会每隔一段时间（默认30秒）向eureka-server发起请求，报告自己状态，称为心跳
- 当超过一定时间没有发送心跳时，eureka-server会认为微服务实例故障，将该实例从服务列表中剔除
- order-service拉取服务时，就能将故障实例排除了

> 注意：一个微服务，既可以是服务提供者，又可以是服务消费者，因此eureka将服务注册、服务发现等功能统一封装到了eureka-client端，谁想要服务谁就去拿目标服务，其本身也是一个服务

> 下面介绍搭建eureka-server的步骤：

### 搭建eureka-server

首先大家注册中心服务端：eureka-server，这必须是一个独立的微服务，服务启动需要引入一些依赖，引入SpringCloud为eureka提供的starter依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

给eureka-server服务编写一个启动类，一定要添加一个@EnableEurekaServer注解，开启eureka的注册中心功能：

```java
package cn.itcast.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaApplication.class, args);
    }
}
```

编写一个application.yml文件，内容如下，主要是为了让别的微服务知道这个地址，然后将自身注册到eureka中进行维护：

```yaml
server:
  port: 10086
spring:
  application:
    name: eureka-server
eureka:
  client:
    service-url: 
      defaultZone: http://127.0.0.1:10086/eureka
```

启动微服务，然后在浏览器访问：http://127.0.0.1:10086

![image-20210713222157190](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317891.png)

### 服务注册

有了eureka服务注册中心之后，其余的微服务要注册到eureka中才能使用服务注册发现的相关功能

#### 1）引入依赖

在user-service的pom文件中，引入下面的eureka-client依赖，这个让当前微服务注册到eureka中：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

#### 2）配置文件

在user-service中，修改application.yml文件，添加服务名称、eureka地址，这个主要是让当前服务指导eureka服务的地址在哪，之后可以将自身注册到eureka中，并且使用心跳确认自己的存在：

```yaml
spring:
  application:
    name: userservice
eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:10086/eureka
```

启动两个user-service实例，查看eureka-server管理页面，发现运行的服务已经注册到了eureka中，并且eureka自身也是一个服务：

![image-20210713223150650](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317896.png)

### 服务发现

当一个微服务想要使用另外一个微服务的接口时，需要知道对应微服务的地址，这就是服务发现，eureka的服务发现需要引入一个依赖，而这个以来与服务注册的依赖是一样的

#### 1）引入依赖

之前说过，服务发现、服务注册统一都封装在eureka-client依赖，因此这一步与服务注册时一致。

在order-service的pom文件中，引入下面的eureka-client依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

#### 2）配置文件

服务发现也需要知道eureka地址，因此第二步与服务注册一致，都是配置eureka信息：

在order-service中，修改application.yml文件，添加服务名称、eureka地址：

```yaml
spring:
  application:
    name: orderservice
eureka:
  client:
    service-url:
      defaultZone: http://127.0.0.1:10086/eureka
```

#### 3）服务拉取和负载均衡

最后，我们要去eureka-server中拉取user-service服务的实例列表，并且实现负载均衡。

不过这些动作不用我们去做，只需要添加一些注解即可。

1. 在order-service的OrderApplication中，给RestTemplate这个Bean添加一个@LoadBalanced注解：

![image-20210713224049419](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317898.png)

2. 修改queryOrderById方法。修改访问的url路径，用服务名代替ip、端口：

![image-20210713224245731](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317899.png)

spring会自动帮助我们从eureka-server端，根据userservice这个服务名称，获取userservice的服务，而后完成负载均衡实现服务之间的通信。

总体来说，使用eureka来进行服务注册和发现需要现将eureka启动成一个微服务，然后再其余的微服务中声明需要注册到哪个eureka中，并且指定自己的服务名称，这样服务之间的调用就可以使用服务名称，服务地质变化并不影响服务之间的调用


## Ribbon负载均衡

上一节中，我们添加了@LoadBalanced注解，即可实现负载均衡功能，这是什么原理呢？

#### 负载均衡原理

SpringCloud底层其实是利用了一个名为Ribbon的组件，来实现负载均衡功能的。

![image-20210713224517686](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317900.png)

那么我们发出的请求明明是http://userservice/user/1，怎么变成了http://localhost:8081的呢？

#### 源码跟踪

为什么我们只输入了service名称就可以访问了呢？之前还要获取ip和端口。

显然有人帮我们根据service名称，获取到了服务实例的ip和端口。它就是`LoadBalancerInterceptor`，这个类会在对RestTemplate的请求进行拦截，然后从Eureka根据服务id获取服务列表，随后利用负载均衡算法得到真实的服务地址信息，替换服务id。

我们进行源码跟踪：

###### 1）LoadBalancerIntercepor

![1525620483637](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317901.png)

可以看到这里的intercept方法，拦截了用户的HttpRequest请求，然后做了几件事：

- `request.getURI()`：获取请求uri，本例中就是 http://user-service/user/8
- `originalUri.getHost()`：获取uri路径的主机名，其实就是服务id，`user-service`
- `this.loadBalancer.execute()`：处理服务id，和用户请求。

这里的`this.loadBalancer`是`LoadBalancerClient`类型，我们继续跟入。

###### 2）LoadBalancerClient

继续跟入execute方法：

![1525620787090](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317902.png)

代码是这样的：

- getLoadBalancer(serviceId)：根据服务id获取ILoadBalancer，而ILoadBalancer会拿着服务id去eureka中获取**服务列表**并保存起来，这里的服务列表中保存了服务对应的地址。
- getServer(loadBalancer)：利用内置的负载均衡算法，从服务列表中选择一个。本例中，可以看到获取了8082端口的服务

放行后，再次访问并跟踪，发现获取的是8081：

 ![1525620835911](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317903.png)

果然实现了负载均衡。

###### 3）负载均衡策略IRule

在刚才的代码中，可以看到获取服务使通过一个`getServer`方法来做负载均衡:

 ![1525620835911](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317903.png)

我们继续跟入：

![1544361421671](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317904.png)

继续跟踪源码chooseServer方法，发现这么一段代码：

 ![1525622652849](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317905.png)

我们看看这个rule是谁：

 ![1525622699666](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317906.png)

这里的rule默认值是一个`RoundRobinRule`，看类的介绍：

 ![1525622754316](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317907.png)

这不就是轮询的意思嘛。

到这里，整个负载均衡的流程我们就清楚了。

###### 4）总结

SpringCloudRibbon的底层采用了一个**拦截器**，拦截了RestTemplate发出的请求，对地址做了修改。用一幅图来总结一下：

![image-20210713224724673](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317908.png)



基本流程如下：

- 拦截我们的RestTemplate请求http://userservice/user/1
- RibbonLoadBalancerClient会从请求url中获取服务名称，也就是user-service
- DynamicServerListLoadBalancer根据user-service到eureka拉取服务列表
- eureka返回列表，localhost:8081、localhost:8082
- IRule利用内置负载均衡规则，从列表中选择一个，例如localhost:8081
- RibbonLoadBalancerClient修改请求地址，用localhost:8081替代userservice，得到http://localhost:8081/user/1，发起真实请求

总结起来就是根据服务名称获取到真实的地址列表，根据负载均衡策略选择一个地址替换请求中的服务名称得到真正的请求地址，然后再进行通信

#### 负载均衡策略

###### 负载均衡策略

负载均衡的规则都定义在IRule接口中，而IRule有很多不同的实现类：

![image-20210713225653000](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317909.png)

不同规则的含义如下：

| **内置负载均衡规则类**    | **规则描述**                                                 |
| ------------------------- | ------------------------------------------------------------ |
| RoundRobinRule            | 简单轮询服务列表来选择服务器。它是Ribbon默认的负载均衡规则。 |
| AvailabilityFilteringRule | 对以下两种服务器进行忽略：   （1）在默认情况下，这台服务器如果3次连接失败，这台服务器就会被设置为“短路”状态。短路状态将持续30秒，如果再次连接失败，短路的持续时间就会几何级地增加。  （2）并发数过高的服务器。如果一个服务器的并发连接数过高，配置了AvailabilityFilteringRule规则的客户端也会将其忽略。并发连接数的上限，可以由客户端的<clientName>.<clientConfigNameSpace>.ActiveConnectionsLimit属性进行配置。 |
| WeightedResponseTimeRule  | 为每一个服务器赋予一个权重值。服务器响应时间越长，这个服务器的权重就越小。这个规则会随机选择服务器，这个权重值会影响服务器的选择。 |
| **ZoneAvoidanceRule**     | 以区域可用的服务器为基础进行服务器的选择。使用Zone对服务器进行分类，这个Zone可以理解为一个机房、一个机架等。而后再对Zone内的多个服务做轮询。 |
| BestAvailableRule         | 忽略那些短路的服务器，并选择并发数较低的服务器。             |
| RandomRule                | 随机选择一个可用的服务器。                                   |
| RetryRule                 | 重试机制的选择逻辑                                           |

默认的实现就是ZoneAvoidanceRule，是一种轮询方案

###### 自定义负载均衡策略

通过定义IRule实现可以修改负载均衡规则，有两种方式：

1. 代码方式：在order-service中的OrderApplication类中，定义一个新的IRule：

```java
@Bean
public IRule randomRule(){
    return new RandomRule();
}
```

2. 配置文件方式：在order-service的application.yml文件中，添加新的配置也可以修改规则：

```yaml
userservice: ## 给某个微服务配置负载均衡规则，这里是userservice服务
  ribbon:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule ## 负载均衡规 
```

> **注意**，一般用默认的负载均衡规则，不做修改。

#### 饥饿加载

Ribbon默认是采用懒加载，即第一次访问时才会去创建LoadBalanceClient，这导致第一次请求时间会很长。

而饥饿加载则会在项目启动时创建，降低第一次访问的耗时，通过下面配置开启饥饿加载：

```yaml
ribbon:
  eager-load:
    enabled: true # 开启饥饿加载
    clients: userservice
```

## Nacos注册中心

国内公司一般都推崇阿里巴巴的技术，比如注册中心，SpringCloudAlibaba也推出了一个名为Nacos的注册中心，该注册中心的功能相比于eureka更加强大。

[Nacos](https://nacos.io/)是阿里巴巴的产品，现在是[SpringCloud](https://spring.io/projects/spring-cloud)中的一个组件。相比[Eureka](https://github.com/Netflix/eureka)功能更加丰富，在国内受欢迎程度较高。

![image-20210713230444308](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317910.png)

#### 服务注册到nacos

Nacos是SpringCloudAlibaba的组件，而SpringCloudAlibaba也遵循SpringCloud中定义的服务注册、服务发现规范。因此使用Nacos和使用Eureka对于微服务来说，**并没有太大区别**。

主要差异在于：

- **依赖不同**
- **服务地址不同**
- **不用单独给nacos定义一个模块**，直接在服务中指定nacos的地址既可以完成服务注册

###### 1）引入依赖

在cloud-demo父工程的pom文件中的`<dependencyManagement>`中引入SpringCloudAlibaba的依赖进行版本的管理：

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>2.2.6.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

然后在user-service和order-service中的pom文件中引入nacos-discovery依赖：

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

> **注意**：不要忘了注释掉eureka的依赖。

###### 2）配置nacos地址

在user-service和order-service的application.yml中添加nacos地址，这一步是为了部署nacos的服务，后期的服务通过这个地址就可以注册到nacos中：

```yaml
spring:
  cloud:
    nacos:
      server-addr: localhost:8848
```

> **注意**：不要忘了注释掉eureka的地址

###### 3）重启

重启微服务后，登录nacos管理页面，可以看到微服务信息：

![image-20210713231439607](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317911.png)

#### 服务分级存储模型

一个**服务**可以有多个**实例**，例如我们的user-service，可以有:

- 127.0.0.1:8081
- 127.0.0.1:8082
- 127.0.0.1:8083

假如这些实例分布于全国各地的不同机房，例如：

- 127.0.0.1:8081，在上海机房
- 127.0.0.1:8082，在上海机房
- 127.0.0.1:8083，在杭州机房

Nacos就将同一机房内的实例 划分为一个**集群**。

也就是说，user-service是服务，一个服务可以包含多个集群，如杭州、上海，每个集群下可以有多个实例，形成分级模型，如图：

![image-20210713232522531](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317912.png)

微服务互相访问时，应该尽可能访问**同集群实例**，因为本地访问速度更快。当本集群内不可用时，才访问其它集群。例如：![image-20210713232658928](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317913.png)

杭州机房内的order-service应该优先访问同机房的user-service。

###### 给user-service配置集群

修改user-service的application.yml文件，添加集群配置：

```yaml
spring:
  cloud:
    nacos:
      server-addr: localhost:8848
      discovery:
        cluster-name: HZ ## 集群名称
```

重启两个user-service实例后，我们可以在nacos控制台看到下面结果：

![image-20210713232916215](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317914.png)

我们再次复制一个user-service启动配置，添加属性：

```sh
-Dserver.port=8083 -Dspring.cloud.nacos.discovery.cluster-name=SH
```

配置如图所示：

![image-20210713233528982](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317915.png)

启动UserApplication3后再次查看nacos控制台：

![image-20210713233727923](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317916.png)

###### 同集群优先的负载均衡

默认的`ZoneAvoidanceRule`并不能实现根据同集群优先来实现负载均衡。

因此Nacos中提供了一个`NacosRule`的实现，可以优先从同集群中挑选实例。

1）给order-service配置集群信息

修改order-service的application.yml文件，添加集群配置，将其加入到HZ集群中，之后设置成有限访问HZ集群中的user-service：

```sh
spring:
  cloud:
    nacos:
      server-addr: localhost:8848
      discovery:
        cluster-name: HZ ## 集群名称
```

2）修改负载均衡规则

修改order-service的application.yml文件，修改负载均衡规则：

```yaml
userservice:
  ribbon:
  	## 负载均衡规则，这样就可以优先使用同集群中的服务
    NFLoadBalancerRuleClassName: com.alibaba.cloud.nacos.ribbon.NacosRule 
```

#### 权重配置

实际部署中会出现这样的场景：

服务器设备性能有差异，部分实例所在机器性能较好，另一些较差，我们希望性能好的机器承担更多的用户请求。

但默认情况下NacosRule是同集群内随机挑选，不会考虑机器的性能问题。

因此，Nacos提供了权重配置来控制访问频率，权重越大则访问频率越高。

在nacos控制台，找到user-service的实例列表，点击编辑，即可修改权重：

![image-20210713235133225](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317917.png)

在弹出的编辑窗口，修改权重：

![image-20210713235235219](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317918.png)

> **注意**：权重修改为0，则该实例永远不会被访问，这个功能可以用来维护某个机器上的微服务

#### 环境隔离

Nacos提供了namespace来实现环境隔离功能。

- nacos中可以有多个namespace
- namespace下可以有group、service等
- 不同namespace之间相互隔离，例如不同namespace的服务互**相不可见**，也不能相互访问

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317919.png" alt="image-20210714000101516" style="zoom:33%;" />

###### 5.5.1.创建namespace

默认情况下，所有service、data、group都在同一个namespace，名为public：

![image-20210714000414781](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317920.png)

我们可以点击页面新增按钮，添加一个namespace：

![image-20210714000440143](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317921.png)

然后，填写表单：

![image-20210714000505928](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317922.png)

就能在页面看到一个新的namespace：

![image-20210714000522913](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317923.png)

###### 5.5.2.给微服务配置namespace

给微服务配置namespace只能通过修改配置来实现。

例如，修改order-service的application.yml文件：

```yaml
spring:
  cloud:
    nacos:
      server-addr: localhost:8848
      discovery:
        cluster-name: HZ
        namespace: 492a7d5d-237b-46a1-a99a-fa8e98e4b0f9 ## 命名空间，填ID
```

重启order-service后，访问控制台，可以看到下面的结果：

![image-20210714000830703](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317924.png)



![image-20210714000837140](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317925.png)

此时访问order-service，因为namespace不同，会导致找不到userservice，控制台会报错：

![image-20210714000941256](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317926.png)

#### Nacos与Eureka的区别

Nacos的服务实例分为两种类型：

- 临时实例：如果实例宕机超过一定时间，会从服务列表剔除，默认的类型。

- 非临时实例：如果实例宕机，不会从服务列表剔除，服务恢复之后列表中的服务重新恢复，也可以叫永久实例。

配置一个服务实例为永久实例：

```yaml
spring:
  cloud:
    nacos:
      discovery:
        ephemeral: false ## 设置为非临时实例
```

Nacos和Eureka整体结构类似，服务注册、服务拉取、心跳等待，但是也存在一些差异：

![image-20210714001728017](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261317927.png)

- Nacos与eureka的共同点
  - 都支持服务注册和服务拉取
  - 都支持服务提供者**心跳**方式做健康检测
- Nacos与Eureka的区别
  - Nacos支持服务端主动检测提供者状态：临时实例采用心跳模式，非临时实例采用主动检测模式（类似于非临时实例更加在乎，服务端会主动进行检测）
  - 临时实例心跳不正常会被剔除，非临时实例则不会被剔除
  - Nacos支持服务列表变更的消息推送模式（主动），服务列表更新更及时

## Nacos配置管理

Nacos除了可以做注册中心，同样可以做配置管理来使用，这样可以进一步增加管理服务的方式，使得微服务的实现变得更加便捷。

#### 统一配置管理

当微服务部署的实例越来越多，达到数十、数百时，逐个修改微服务配置就会让人抓狂，而且很容易出错。我们需要一种统一配置管理方案，可以**集中管理所有实例的配置**。

![image-20210714164426792](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409428.png)

Nacos一方面可以将配置集中管理，另一方可以在配置变更时，及时通知微服务，实现配置**热更新**。也就是说需要热更新的配置才有存放到nacos中的必要，不经常变化的配置就不用存储到nacos中了

###### 1.1.1.在nacos中添加配置文件

如何在nacos中管理配置呢？

![image-20210714164742924](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409430.png)

然后在弹出的表单中，填写配置信息：

![image-20210714164856664](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409431.png)

> 注意：项目的**核心配置**，需要热更新的配置才有放到nacos管理的必要。基本不会变更的一些配置还是保存在微服务本地比较好。

###### 1.1.2.从微服务拉取配置

微服务要拉取nacos中管理的配置，并且与本地的application.yml配置合并，才能完成项目启动。

但如果尚未读取application.yml，又如何得知nacos地址呢？

因此spring引入了一种新的配置文件：bootstrap.yaml文件，会在application.yml之前被读取，流程如下：

![img](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409432.png)

有了这种设置方式，就可以实现nacos来管理一些必要的服务配置信息，这样nacos配置+本地配置的方式就可以完全管控微服务

1）引入nacos-config依赖

首先，在user-service服务中，引入nacos-config的客户端依赖，这个依赖可以实现依赖管理：

```xml
<!--nacos配置管理依赖-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
</dependency>
```

2）添加bootstrap.yaml

然后，在user-service中添加一个bootstrap.yaml文件，内容如下，微服务启动时会优先服务这个配置，得到nacos的地址，然后就可以读取nacos中的配置文件，之后读取本地的配置， 有了这些配置信息之后，微服务就可以启动了：

```yaml
spring:
  application:
    name: userservice ## 服务名称
  profiles:
    active: dev ##开发环境，这里是dev，还可以指定为test，run等环境
  cloud:
    nacos:
      server-addr: localhost:8848 ## Nacos地址
      config:
        file-extension: yaml ## 文件后缀名
```

这里会根据spring.cloud.nacos.server-addr获取nacos地址，再根据

`${spring.application.name}-${spring.profiles.active}.${spring.cloud.nacos.config.file-extension}`作为文件id，来读取nacos中配置的文件。

本例中，就是去读取`userservice-dev.yaml`：

![image-20210714170845901](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409433.png)

> 由这三个地方组成配置文件的名称，从而读取配置信息，如果nacos中还配置了userservice.yaml也会读取

3）读取nacos配置

在user-service中的UserController中添加业务逻辑，读取pattern.dateformat配置：

![image-20210714170337448](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409434.png)

完整代码：

```java
package cn.itcast.user.web;

import cn.itcast.user.pojo.User;
import cn.itcast.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Value("${pattern.dateformat}")
    private String dateformat;
    
    @GetMapping("now")
    public String now(){
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern(dateformat));
    }
    // ...略
}
```

在页面访问，可以看到效果：

![image-20210714170449612](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409435.png)



#### 配置热更新

我们最终的目的，是修改nacos中的配置后，微服务中无需重启即可让配置生效，也就是**配置热更新**。

要实现配置热更新，可以使用两种方式：

###### 方式一

在@Value注入的变量所在类上添加注解@RefreshScope，这样就可以在配置更新时作用到使用了这个注解的类上：

![image-20210714171036335](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409436.png)

###### 方式二

使用@ConfigurationProperties注解代替@Value注解，这种方式只需要。指定配置文件中的前缀，然后springboot自动将配置文件中的属性按照名称注入到类中的变量上，相当于将配置文件中的属性一次性注入给java中的对象

在user-service服务中，添加一个类，读取patterrn.dateformat属性：

```java
package cn.itcast.user.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@Data
//这个代码可以将配置文件中的pattern属性加载到这个类中
@ConfigurationProperties(prefix = "pattern")
public class PatternProperties {
    private String dateformat;
}
```

在UserController中使用这个类代替@Value，然后使用get方法得到需要的属性：

![image-20210714171316124](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409437.png)

完整代码：

```java
package cn.itcast.user.web;

import cn.itcast.user.config.PatternProperties;
import cn.itcast.user.pojo.User;
import cn.itcast.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private PatternProperties patternProperties;

    @GetMapping("now")
    public String now(){
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern(patternProperties.getDateformat()));
    }

    // 略
}
```

#### 配置共享

其实微服务启动时，会去nacos读取多个配置文件，例如：

- `[spring.application.name]-[spring.profiles.active].yaml`，例如：userservice-dev.yaml
- `[spring.application.name].yaml`，例如：userservice.yaml，这个就类似于springboot多环境开发时的公共环境配置`application.yaml`

而`[spring.application.name].yaml`不包含环境，因此可以被多个环境共享。

下面我们通过案例来测试配置共享

###### 1）添加一个环境共享配置

我们在nacos中添加一个userservice.yaml文件：

![image-20210714173233650](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409439.png)



###### 2）在user-service中读取共享配置

在user-service服务中，修改PatternProperties类，读取新添加的属性：

![image-20210714173324231](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409440.png)

在user-service服务中，修改UserController，添加一个方法：

![image-20210714173721309](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409441.png)

###### 3）运行两个UserApplication，使用不同的profile

访问http://localhost:8081/user/prop，结果：

![image-20210714174313344](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409444.png)

访问http://localhost:8082/user/prop，结果：

![image-20210714174424818](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409445.png)

可以看出来，不管是dev，还是test环境，**都**读取到了envSharedValue这个属性的值。

###### 4）配置共享的优先级

当nacos、服务本地同时出现相同属性时，优先级有高低之分：

![image-20210714174623557](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409446.png)

相当于优先级最高的是本环境下的配置，接下来是公共的服务名配置，最后才是本地配置，也就是更新**本环境**中的配置即可实现配置的热更新

## Feign远程调用

先来看我们以前利用RestTemplate发起远程调用的代码：

![image-20210714174814204](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409448.png)

存在下面的问题：

•代码可读性差，编程体验不统一

•参数复杂URL难以维护，一旦一个请求中多个参数或者多种调用方式，这种调用方式就变得繁琐

于是我们引入了Feign，Feign是一个声明式的http客户端，官方地址：https://github.com/OpenFeign/feign，其作用就是帮助我们优雅的实现http请求的发送，解决上面提到的问题。

![image-20210714174918088](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409449.png)

#### Feign替代RestTemplate

Fegin的使用步骤如下：

###### 1）引入依赖

我们在order-service服务的pom文件中引入feign的依赖，相当于谁要使用别的服务谁就引入这个依赖，或者说谁想远程调用谁就引入这个依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

###### 2）添加注解

在order-service的启动类添加注解开启Feign的功能：

![image-20210714175102524](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409450.png)

###### 3）编写Feign的客户端

在order-service中新建一个**接口**，内容如下：

```java
package cn.itcast.order.client;

import cn.itcast.order.pojo.User;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient("userservice")
public interface UserClient {
    //实现一个user-service中类似的接口方法，在order-service中调用就可以发起远程请求
    @GetMapping("/user/{id}")
    User findById(@PathVariable("id") Long id);
}
```

这个客户端主要是基于SpringMVC的注解来声明远程调用的信息，比如：

- 服务名称：userservice
- 请求方式：GET
- 请求路径：/user/{id}
- 请求参数：Long id
- 返回值类型：User

这样，Feign就可以帮助我们发送http请求，无需自己使用RestTemplate来发送了。

###### 4）测试

修改order-service中的OrderService类中的queryOrderById方法，使用Feign客户端代替RestTemplate：

![image-20210714175415087](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409451.png)

调用这个方法会自动去nacos中找到userservice的服务中的地址，发起一个请求，得到相应的返回值

###### 5）总结

使用Feign的步骤：

① 引入依赖

② 添加@EnableFeignClients注解

③ 编写FeignClient接口

④ 使用FeignClient中定义的方法代替RestTemplate

以上这些操作都是在order-service内部进行的，与user-service模块无关

#### 自定义配置

Feign可以支持很多的自定义配置，如下表所示：

| 类型                   | 作用             | 说明                                                   |
| ---------------------- | ---------------- | ------------------------------------------------------ |
| **feign.Logger.Level** | 修改日志级别     | 包含四种不同的级别：NONE、BASIC、HEADERS、FULL         |
| feign.codec.Decoder    | 响应结果的解析器 | http远程调用的结果做解析，例如解析json字符串为java对象 |
| feign.codec.Encoder    | 请求参数编码     | 将请求参数编码，便于通过http请求发送                   |
| feign. Contract        | 支持的注解格式   | 默认是SpringMVC的注解                                  |
| feign. Retryer         | 失败重试机制     | 请求失败的重试机制，默认是没有，不过会使用Ribbon的重试 |

一般情况下，默认值就能满足我们使用，如果要自定义时，只需要创建自定义的@Bean覆盖默认Bean即可。

下面以日志为例来演示如何自定义配置。

###### 配置文件方式

基于配置文件修改feign的日志级别可以针对单个服务：

```yaml
feign:  
  client:
    config: 
      userservice: ## 针对某个微服务的配置
        loggerLevel: FULL ##  日志级别 
```

也可以针对所有服务：

```yaml
feign:  
  client:
    config: 
      default: ## 这里用default就是全局配置，如果是写服务名称，则是针对某个微服务的配置
        loggerLevel: FULL ##  日志级别 
```

而日志的级别分为四种：

- NONE：不记录任何日志信息，这是默认值。
- BASIC：仅记录请求的方法，URL以及响应状态码和执行时间
- HEADERS：在BASIC的基础上，额外记录了请求和响应的头信息
- FULL：记录所有请求和响应的明细，包括头信息、请求体、元数据。

###### Java代码方式

也可以基于Java代码来修改日志级别，先声明一个类，然后声明一个Logger.Level的对象：

```java
public class DefaultFeignConfiguration  {
    @Bean
    public Logger.Level feignLogLevel(){
        return Logger.Level.BASIC; // 日志级别为BASIC
    }
}
```

如果要**全局生效**，将其放到启动类的@EnableFeignClients这个注解中，指定配置类的class文件，这样就实现了全局生效：

```java
@EnableFeignClients(defaultConfiguration = DefaultFeignConfiguration .class) 
```

如果是**局部生效**，则把它放到对应的@FeignClient这个注解中：

```java
@FeignClient(value = "userservice", configuration = DefaultFeignConfiguration .class) 
```

> 相当于要么加到启动类上，就是全局，要么加到某一个Feign客户端上，这样只有这个服务生效

#### Feign使用优化

Feign底层发起http请求，依赖于其它的框架。其底层客户端实现包括：

•URLConnection：默认实现，不支持连接池

•Apache HttpClient ：支持连接池

•OKHttp：支持连接池

因此提高Feign的性能主要手段就是使用**连接池**代替默认的URLConnection，这样就不用每次都创建新的连接，减少三次握手四次挥手的时间就提高了性能。

这里我们用Apache的HttpClient来演示。

1）引入依赖

在order-service的pom文件中引入Apache的HttpClient依赖：

```xml
<!--httpClient的依赖 -->
<dependency>
    <groupId>io.github.openfeign</groupId>
    <artifactId>feign-httpclient</artifactId>
</dependency>
```

2）配置连接池

在order-service的application.yml中添加配置：

```yaml
feign:
  client:
    config:
      default: ## default全局的配置
        loggerLevel: BASIC ## 日志级别，BASIC就是基本的请求和响应信息
  httpclient:
    enabled: true ## 开启feign对HttpClient的支持
    max-connections: 200 ## 最大的连接数
    max-connections-per-route: 50 ## 每个路径的最大连接数
```

接下来，在FeignClientFactoryBean中的loadBalance方法中打断点：

![image-20210714185925910](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409452.png)

Debug方式启动order-service服务，可以看到这里的client，底层就是Apache HttpClient：

![image-20210714190041542](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409453.png)

总结，Feign的优化：

1.日志级别尽量用basic

2.使用HttpClient或OKHttp代替URLConnection

①  引入feign-httpClient依赖

②  配置文件开启httpClient功能，设置连接池参数

#### 最佳实践

所谓最近实践，就是使用过程中总结的经验，最好的一种使用方式。

自习观察可以发现，Feign的客户端与服务提供者的controller代码非常相似：

feign客户端：

![image-20210714190542730](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409454.png)

UserController：

![image-20210714190528450](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409455.png)

有没有一种办法简化这种重复的代码编写呢？

###### 继承方式

一样的代码可以通过继承来共享：

1）定义一个API接口，利用定义方法，并基于SpringMVC注解做声明。

2）Feign客户端和Controller都继承该接口

![image-20210714190640857](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409456.png)

优点：

- 简单
- 实现了代码共享

缺点：

- 服务提供方、服务消费方**紧耦合**

- 参数列表中的注解映射并不会继承，因此Controller中必须再次声明方法、参数列表、注解

###### 抽取方式

将Feign的Client抽取为**独立模块**，并且把接口有关的POJO、默认的Feign配置都放到这个模块中，提供给所有消费者使用。

例如，将UserClient、User、Feign的默认配置都抽取到一个feign-api包中，所有微服务引用该依赖包，即可直接使用。

![image-20210714214041796](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409457.png)

###### 实现基于抽取的最佳实践

1）抽取

首先抽取一个module，命名为feign-api，项目结构为：

![image-20210714204656214](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409459.png)

在feign-api中然后引入feign的starter依赖，这样就可以定义Feign的客户端

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

然后，order-service中编写的UserClient、User、DefaultFeignConfiguration都复制到feign-api项目中

![image-20210714205221970](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409460.png)

2）在order-service中使用feign-api

首先，删除order-service中的UserClient、User、DefaultFeignConfiguration等类或接口。

在order-service的pom文件中引入feign-api的依赖：

```xml
<dependency>
    <groupId>cn.itcast.demo</groupId>
    <artifactId>feign-api</artifactId>
    <version>1.0</version>
</dependency>
```

修改order-service中的所有与上述三个组件有关的导包部分，包括userClient的来源和user的来源，改成导入feign-api中的包

3）重启测试

重启后，发现服务报错了：

![image-20210714205623048](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409461.png)

这是因为UserClient现在在cn.itcast.feign.clients包下，

而order-service的@EnableFeignClients注解是在cn.itcast.order包下，不在同一个包，无法扫描到UserClient。

 4）解决扫描包问题

方式一：

指定Feign应该扫描的包，这样会一次导入多个客户端：

```java
@EnableFeignClients(basePackages = "cn.itcast.feign.clients")
```

方式二：

指定需要加载的Client接口，这样一次只会导入一个客户端：

```java
@EnableFeignClients(clients = {UserClient.class})
```

## Gateway服务网关

Spring Cloud Gateway 是 Spring Cloud 的一个全新项目，该项目是基于 Spring 5.0，Spring Boot 2.0 和 Project Reactor 等响应式编程和事件流技术开发的网关，它旨在为微服务架构提供一种简单有效的统一的 API 路由管理方式。

#### 为什么需要网关

Gateway网关是我们服务的守门神，所有微服务的统一入口，所有的服务都会经过网关。

网关的**核心功能特性**：

- 请求路由
- 权限控制
- 限流

架构图：

![image-20210714210131152](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409462.png)

**权限控制**：网关作为微服务入口，需要校验用户是是否有请求资格，如果没有则进行拦截。

**路由和负载均衡**：一切请求都必须先经过gateway，但网关不处理业务，而是根据某种规则，把请求转发到某个微服务，这个过程叫做路由。当然路由的目标服务有多个时，还需要做负载均衡。

**限流**：当请求流量过高时，在网关中按照下流的微服务能够接受的速度来放行请求，避免服务压力过大。

在SpringCloud中网关的实现包括两种：

- gateway
- zuul

Zuul是基于Servlet的实现，属于**阻塞式编程**。而SpringCloudGateway则是基于Spring5中提供的WebFlux，属于**响应式编程**的实现，具备更好的性能。

阻塞相当于**干等**，而响应相当于好了再**抽空**回来

#### gateway快速入门

下面，我们就演示下网关的基本路由功能。基本步骤如下：

1. 创建SpringBoot工程gateway，引入网关依赖
2. 编写启动类
3. 编写基础配置和路由规则
4. 启动网关服务进行测试

###### 1）创建gateway服务，引入依赖

创建服务并在这个单独的模块中引入依赖：

```xml
<!--网关-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<!--nacos服务发现依赖-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

###### 2）编写启动类

```java
package cn.itcast.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class GatewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(GatewayApplication.class, args);
	}
}
```

###### 3）编写基础配置和路由规则

创建当前模块的application.yml文件，内容如下：

```yaml
server:
  port: 10010 ## 网关端口
spring:
  application:
    name: gateway ## 服务名称
  cloud:
    nacos:
      server-addr: localhost:8848 ## nacos地址
    gateway:
      routes: ## 网关路由配置
        - id: user-service ## 路由id，自定义，只要唯一即可
          ## uri: http://127.0.0.1:8081 ## 路由的目标地址 http就是固定地址
          uri: lb://userservice ## 路由的目标地址 lb就是负载均衡，后面跟服务名称
          predicates: ## 路由断言，也就是判断请求是否符合路由规则的条件
            - Path=/user/** ## 这个是按照路径匹配，只要以/user/开头就符合要求
```

当前网关服务也加入了nacos的服务注册中心中

我们将符合`Path` 规则的一切请求，都代理到 `uri`参数指定的地址。

本例中，我们将 `/user/**`开头的请求，也就是路由断言中匹配成功的请求，代理到`lb://userservice`，lb是负载均衡，根据服务名拉取服务列表，实现负载均衡。

###### 4）重启测试

重启网关，访问http://localhost:10010/user/1时，符合`/user/**`规则，请求**转发**到uri：http://userservice/user/1，然后从nacos中得到userservice 的服务，最终请求得到了结果：

![image-20210714211908341](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409464.png)

这里有点类似于反向代理的意思，外部不知道userservice服务的地址，但是依然可以通过网关访问userservice的服务，隐藏了userservice的真实地址

###### 5）网关路由的流程图

整个访问的流程如下：

![image-20210714211742956](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409465.png)

主要是路由规则的判断，根据请求的路由决定将请求转发给哪个服务，确定服务名之后，再从nacos中挑选服务并执行请求

总结：

网关搭建步骤：

1. 创建项目，引入nacos服务发现和gateway依赖

2. 配置application.yml，包括服务基本信息、nacos地址、路由

路由配置包括：

1. 路由id：路由的唯一标示

2. 路由目标（uri）：路由的目标地址，http代表固定地址，lb代表根据服务名负载均衡

3. 路由断言（predicates）：判断路由的规则，确定请求地址最终转发给哪个服务

4. 路由过滤器（filters）：对请求或响应做处理

接下来，就重点来学习路由断言和路由过滤器的详细知识

#### 断言工厂

我们在配置文件中写的断言规则只是字符串，这些字符串会被Predicate Factory读取并处理，转变为路由判断的条件

例如`Path=/user/**`是按照路径匹配，这个规则是由

`org.springframework.cloud.gateway.handler.predicate.PathRoutePredicateFactory`类来

处理的，像这样的断言工厂在SpringCloudGateway还有十几个:

| **名称**   | **说明**                       | **示例**                                                     |
| ---------- | ------------------------------ | ------------------------------------------------------------ |
| After      | 是某个时间点后的请求           | -  After=2037-01-20T17:42:47.789-07:00[America/Denver]       |
| Before     | 是某个时间点之前的请求         | -  Before=2031-04-13T15:14:47.433+08:00[Asia/Shanghai]       |
| Between    | 是某两个时间点之前的请求       | -  Between=2037-01-20T17:42:47.789-07:00[America/Denver],  2037-01-21T17:42:47.789-07:00[America/Denver] |
| Cookie     | 请求必须包含某些cookie         | - Cookie=chocolate, ch.p                                     |
| Header     | 请求必须包含某些header         | - Header=X-Request-Id, \d+                                   |
| Host       | 请求必须是访问某个host（域名） | -  Host=**.somehost.org,**.anotherhost.org                   |
| Method     | 请求方式必须是指定方式         | - Method=GET,POST                                            |
| Path       | 请求路径必须符合指定规则       | - Path=/red/{segment},/blue/**                               |
| Query      | 请求参数必须包含指定参数       | - Query=name, Jack或者-  Query=name                          |
| RemoteAddr | 请求者的ip必须是指定范围       | - RemoteAddr=192.168.1.1/24                                  |
| Weight     | 权重处理                       |                                                              |

我们只需要掌握Path这种路由工程就可以了。符合该请求的请求就会被转发给相应的服务，从而实现网关的功能，起到过滤转发的作用

#### 过滤器工厂

GatewayFilter是网关中提供的一种**过滤器**，可以对进入网关的请求和微服务返回的响应**做处理**：

![image-20210714212312871](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409466.png)

###### 路由过滤器的种类

Spring提供了31种不同的路由过滤器工厂。例如：

| **名称**             | **说明**                     |
| -------------------- | ---------------------------- |
| AddRequestHeader     | 给当前请求添加一个请求头     |
| RemoveRequestHeader  | 移除请求中的一个请求头       |
| AddResponseHeader    | 给响应结果中添加一个响应头   |
| RemoveResponseHeader | 从响应结果中移除有一个响应头 |
| RequestRateLimiter   | 限制请求的流量               |

###### 请求头过滤器

下面我们以AddRequestHeader 为例来讲解。

> **需求**：给所有进入userservice的请求添加一个请求头：Truth=itcast is freaking awesome!

只需要修改gateway服务的application.yml文件，添加路由过滤即可：

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: user-service 
        uri: lb://userservice 
        predicates: 
        - Path=/user/** 
        filters: ## 过滤器
        - AddRequestHeader=Truth, Itcast is freaking awesome! ## 添加请求头
```

当前过滤器写在userservice路由下，因此仅仅对访问userservice的请求有效。也就是访问userservice的请求都会被增加一个请求头

###### 默认过滤器

如果要对所有的路由都生效，则可以将过滤器工厂写到default下，这样所有的路由请求都有效。格式如下：

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: user-service 
        uri: lb://userservice 
        predicates: 
        - Path=/user/**
      default-filters: ## 默认过滤项
      - AddRequestHeader=Truth, Itcast is freaking awesome! 
```

###### 总结

过滤器的作用是什么？

① 对路由的请求或响应做**加工处理**，比如添加请求头

② 配置在路由下的过滤器只对当前路由的请求生效

defaultFilters的作用是什么？

① **对所有路由都生效**的过滤器

相当于过滤器可以添加给某一个特定的服务，或者添加给所有的服务

#### 全局过滤器

上一节学习的过滤器，网关提供了31种，但每一种过滤器的作用都是固定的。如果我们希望拦截请求，做**自己的业务逻辑**则没办法实现，所以提供了自己定义过滤器的接口，实现程序的扩展。

###### 全局过滤器作用

全局过滤器的作用也是处理一切进入网关的请求和微服务响应，与GatewayFilter的作用一样。区别在于GatewayFilter通过配置定义，处理逻辑是固定的；而GlobalFilter的逻辑需要自己写代码实现。

定义方式是**实现GlobalFilter接口**。

```java
public interface GlobalFilter {
    /**
     *  处理当前请求，有必要的话通过{@link GatewayFilterChain}将请求交给下一个过滤器处理
     *
     * @param exchange 请求上下文，里面可以获取Request、Response等信息
     * @param chain 用来把请求委托给下一个过滤器 
     * @return {@code Mono<Void>} 返回标示当前过滤器业务结束
     */
    Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain);
}
```

在filter中编写自定义逻辑，可以实现下列功能：

- 登录状态判断
- 权限校验
- 请求限流等

###### 过滤器执行顺序

请求进入网关会碰到三类过滤器：当前路由的过滤器、DefaultFilter、GlobalFilter

请求路由后，会将当前路由过滤器和DefaultFilter、GlobalFilter，合并到一个过滤器链（集合）中，**排序**后依次执行每个过滤器：

![image-20210714214228409](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409467.png)

排序的规则是什么呢？

- 每一个过滤器都必须指定一个int类型的order值，**order值越小，优先级越高，执行顺序越靠前**。
- GlobalFilter通过实现Ordered接口，或者添加@Order注解来指定order值，由我们自己指定
- 路由过滤器和defaultFilter的order由Spring指定，默认是按照声明顺序从1递增。
- 当过滤器的order值一样时，会按照 defaultFilter > 路由过滤器 > GlobalFilter的顺序执行。

详细内容，可以查看源码：

`org.springframework.cloud.gateway.route.RouteDefinitionRouteLocator##getFilters()`方法是先加载defaultFilters，然后再加载某个route的filters，然后合并。

`org.springframework.cloud.gateway.handler.FilteringWebHandler##handle()`方法会加载全局过滤器，与前面的过滤器合并后根据order排序，组织过滤器链

#### 跨域问题

###### 什么是跨域问题

跨域：域名不一致就是跨域，主要包括：

- 域名不同： www.taobao.com 和 www.taobao.org 和 www.jd.com 和 miaosha.jd.com

- 域名相同，端口不同：localhost:8080和localhost:8081

跨域问题：浏览器禁止请求的发起者与服务端发生跨域ajax请求，请求被浏览器拦截的问题

> 这类问题在gateway中得到了妥善的解决

###### 解决跨域问题

在gateway服务的application.yml文件中，添加下面的配置，类似于哪些跨域请求不拦截，放入**白名单**中，这样跨域的访问也可以成功：

```yaml
spring:
  cloud:
    gateway:
      ## 。。。
      globalcors: ## 全局的跨域处理
        add-to-simple-url-handler-mapping: true ## 解决options请求被拦截问题
        corsConfigurations:
          '[/**]':
            allowedOrigins: ## 允许哪些网站的跨域请求，这里相当于白名单 
              - "http://localhost:8090"
            allowedMethods: ## 允许的跨域ajax的请求方式
              - "GET"
              - "POST"
              - "DELETE"
              - "PUT"
              - "OPTIONS"
            allowedHeaders: "*" ## 允许在请求中携带的头信息
            allowCredentials: true ## 是否允许携带cookie
            maxAge: 360000 ## 这次跨域检测的有效期
```

## 总结

本节中介绍了`springcloud`中集成的一些微服务的组件，并且从单体结构的项目引入为什么出现了微服务，微服务拆分之后出现了一系列的问题，比如微服务变得很多，管理可以使用`eureka`或者`nacos`，访问时负载均衡可以使用`ribbon`，同一个服务下的多个实例进行配置管理可以使用`nacos`，服务之间的远程调用可以使用`Feign`，外部请求微服务时经过的`gateway`网关技术也做了一定的介绍，算是对微服务有了一个初步的认识，每一个功能都可以成为一个微服务，但是并不是任何项目都需要拆分成微服务的结构







