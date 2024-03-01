---
title: "Spring面经"
description: "spring面经"
keywords: "spring面经"

date: 2024-02-28T09:26:12+08:00
lastmod: 2024-02-28T09:26:12+08:00

categories:
  - 面试
tags:
  - spring
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
#url: "spring面经.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> 🌸 spring面经

本文总结一些常见的spring面试题并自己做出总结，文章持续更新

<!--more-->

#### spring是什么

spring通常指的是spring framework，是一个**IOC**和**AOP**的容器框架，从广义来说指的是一个生态，可以构建java应用所需要的基础框架

#### spring的优缺点

spring有许多功能，每个功能都带来了一些优点

1. IOC：对程序进行**解耦**，将对象交给spring进行控制管理
2. AOP：程序**扩展**（不修改原代码）起来更加方便，减少重复代码
3. 事务：支持**声明式**事务管理，不用进行繁杂的事务配置
4. 在框架中封装了各种直接使用的功能，JDBCTemplate，RestTemplate等

由于有上面这些丰富的功能，导致spring**入门**比较困难，并且想深入挖掘很困难

#### IOC容器是什么

IOC既控制反转，可以将对象的控制权集中交给IOC容器来管理，将程序进行解耦，被管理的对象称为bean，整个bean的生命周期都由这个容器来管理，包括bean的**创建**，bean的**依赖注入**等

#### ioc的实现机制

工厂设计模式（getBean获取bean对象时）+反射（bean的实例化时利用传递的类名实例化）

#### IOC和DI的区别

IOC是**控制反转**，控制了对象的创建和使用，这是一种设计思想。DI是**依赖注入**，当我们需要一个bean对象时，必须要spring**注入**才能使用，或者说将一个对象所依赖的的其他对象自动注入到这个对象中，也就是DI是IOC的一种实现方式，二者并不能等同

#### 紧耦合和松耦合

紧耦合：类之间高度依赖，当依赖关系过多时，一个类修改，那么所有类都要跟着修改

松耦合：类之间的依赖关系较低，一个类修改时其余类可以不变，类的职责变得**单一**

**例如**多个service层依赖mapper层，紧耦合就是直接在service中new出这个maper的对象，当后期想要修改mapper时，每个类都需要改变，但是利用spring就可以实现松耦合，我们只需要将依赖的mapper对象进行改变即可，service中自动注入新的mapper对象

#### beanFactory的作用

用来生产bean，通过调用getBean传入一个标识来生产，内部有多种形式的getBean方法来生产bean

#### beanDefinition的作用

保存了bean的定义信息，或者说保存了bean在生产前的配置信息。后续在生产bean时就会以来这些信息来创建bean，例如类信息，是否单例，是否懒加载等

#### beanFactory和ApplicationContext的区别

beanFactory：使用时才会初始化bean，所以比较轻量级，

ApplicationContext：实现了beanFactory，在启动时就会初始化bean，并且相对于beanFactory拥有更多的功能，从而消耗的资源也会更多

#### IOC容器的加载过程（Bean的创建过程）

1. 实例化一个ApplicationContext的对象
2. 加载bean的定义信息，主要是解析xml配置文件或者解析注解来得到bean的定义信息，也就是beanDefinition
3. 将定义信息保存到容器中便于后期bean的实例化，这些信息包含bean的类名，依赖关系，作用域等
4. 实例化bean，根据bean的定义信息创建bean对象，此时的bean对象是一个空bean
5. 处理bean的依赖关系，进行属性的注入，在这里可能会出现循环依赖的问题
6. 执行bean的初始化方法，例如进行数据库连接的配置，初始化一些资源
7. 注册bean的销毁函数，在bean销毁时触发这些方法的执行，例如可以释放一些资源，防止内存泄漏等
8. 将实例化后的bean对象保存到容器中便于后期使用

#### IOC的扩展点有哪些

1. BeanPostProcessor：在实例化bean执行初始化**前后**进行额外的处理，例如进行AOP代理的创建（postProcessBeforeInitialization），属性的修改等
2. BeanFactoryPostProcessor：可以在bean定义后，实例化之前修改bean的定义，例如修改bean的作用域
3. 各种Aware回调：实现这些接口可以获取特定的资源，BeanFactoryAware可以获得BeanFactory的引用，ApplicationContextAware可以获得ApplicationContext的引用，BeanNameAware可以获得bean的名称等
4. FactoryBean：可以定制自己想要的bean

#### bean是什么

被spring的ioc容器管理的对象称为bean

#### bean的配置方式

1. xml文件
2. 注解（使用@Component注解配置的类，前提是需要配置包扫描路径ComponentScan）
3. javaConfig（@Bean）使用@Configuration来进行配置，内部将@Bean放置在方法上返回一个bean对象
4. @Import
   - 实现ImportSelector接口：返回一个字符串数组，内部保存了很多bean的类名称
   - ImportBeanDefinitionRegistrar：手动注入bean的定义信息，从而进行bean的配置
   - 直接导入其他的配置类或者bean的class文件

#### bean的作用域

1. 单例singleton（默认）
2. 多例prototype
3. web应用中独有的：
   - request：一个请求创建一个bean对象
   - session：一个session创建一个bean对象，一个会话可能包含多个请求

4. application：一个应用共享一个bean对象

#### 单例bean的优势

1. 不用每次创建bean对象，减小内存消耗
2. jvm不用每次都回收bean对象，所以程序运行时间变短
3. 获取bean更快，因为不用每次都重新创建

#### springboot中加载配置文件的方式

1. @value加载单个属性
2. @ConfigurationProperties加载整个前缀的属性到一个java对象中
3. @PropertySource加载**外部**的配置文件，也就是不在resources文件夹中的配置文件
4. 注入Environment对象，然后调用封装好的接口从而获取到配置文件中的属性

#### bean的线程安全

同时读写单例bean中的成员变量时就会出现线程不安全问题，例如单例的user中存在一个username，同时存在多个线程修改这个username，此时就会出现线程不安全问题

> 可以将成员变量声明在方法中，这样就可以解决线程不安全问题，因为方法的调用每次都会创建新的副本，相当于方法中的变量是**独立**的

#### spring如何处理线程并发问题导致bean出现问题

> 出现线程安全的问题主要是读写单例bean中的成员变量

1. 单例bean改为多例bean
2. 单例bean的成员变量声明在方法中（不同的线程访问的是不同的副本）
3. 单例bean的成员变量绑定到ThreadLocal中
4. 给读写成员变量的代码加上synchronized同步

#### 实例化bean的几种方式

1. 构造器（底层使用反射）
2. 静态工厂：配置bean时指定一个factory-method，实例化时自动调用这个方法获取bean的实例
3. 实例工厂：制定一个factory-method和factory-bean，利用这个来实例化
4. FactoryBean：实现一个FactoryBean接口，重写一个getObject方法，返回的对象就是实例化后的bean

> 第一种是spring控制bean的实例化，后三 种是**自己**控制

#### 自动装配的几种方式

1. no：不自动装配，此时需要手动指定
2. byName：根据set方法的名称来注入，去掉set，首字母小写
3. byType：按照set方法的形参类型来注入
4. 构造函数：按照构造函数的参数类型来注入

#### bean的生命周期回调方法

> 分为初始化和销毁两种回调

1. 使用@PostConstruct，@PreDestroy注解：最先执行
2. 实现InitializingBean和DisposableBean接口，随后执行
3. 使用xml或者@Bean配置init-mothod和destroy-method属性，最后执行

#### bean的生命周期

> 生命周期指的是bean从创建到销毁的过程

1. 实例化：构造函数，实例工厂，静态工厂
2. 属性赋值：自动装配（no，byname，bytype，construct），会出现**循环依赖**
3. 初始化：调用很多aware回调方法，得到想要的资源。调用初始化生命周期回调，**aop**
4. 销毁：容器关闭时调用销毁生命周期回调

#### 三级缓存如何解决[循环依赖](https://zzzicode.github.io/post/small_spring15/)

> 什么是三级缓存（三个map），什么是循环依赖

1. 一级缓存：存储完整的bean
2. 二级缓存：避免多重循环依赖的情况下重复创建动态代理
3. 三级缓存：主要存储一个lambda表达式，只有在被依赖时才会被调用，调用之后创建一个bean对象，将其放入二级缓存中。如果立即调用，那么不管是否出现循环依赖，aop都会提前

先创建A，然后将A放入三级缓存，主要是存放一个lambda表达式，然后进行属性填充，属性填充的过程中依赖B，于是新建B（假设B第一次创建），还是将B放入三级缓存并属性填充，此时依赖A，于是从一级缓存，二级缓存，三级缓存中查找A，从三级缓存中查找到A之后，判断其是否需要AOP，然后将其保存到二级缓存中，之后B完成创建，将其保存到一级缓存中，并从三级缓存中删除。B完成创建之后，A也可以完成创建

> 主要利用了三级缓存**提前暴露**没有创建完成的bean对象，**打破**循环依赖

#### 二级缓存是否可以解决循环依赖

可以，但是不使用三级缓存会导致所有的aop都会提前，不符合bean的生命周期特征

#### 多例bean存在循环依赖吗

存在，因为多例bean都不会存储在缓存中，所以会出现循环依赖，并且无法解决

#### spring中如何推断构造函数

1. 有默认先用默认
2. 没有默认就使用@Autowired指定的构造函数
3. 两者都没有就按照构造函数的参数类型使用
4. 都没有就报错

#### 如何避免并发情况下获取不完整的bean

1. 为什么会获取到不完整的bean：在中间还没有属性赋值或者aop时就获取到了bean，此时的bean是不完整的
2. 如何避免：双重检查锁（两个同步锁（一级缓存不加锁），两次检查一级缓存），在创建的过程中将二级缓存和三级缓存中不完整的bean锁住，其余想要访问（**第一次检查**一级缓存）的线程阻塞。创建完成之后放入一级缓存中才解锁（清理二级和三级中不完整的bean），此时被阻塞的线程去检查二级和三级缓存中发现没有，于是准备创建，在创建之前再次检查一级缓存（**第二次检查**），此时发现存在，于是直接获得

#### beanDefinition的加载过程

根据bean的配置信息将配置信息**加载**为一个beanDefinition的对象并放入容器中，容器中是键值对形式的数据，键就是bean的名称

加载时需要将所有的配置信息读取到，如果是xml配置文件，那么需要一层一层的解析读取，如果是注解或者配置类，就需要使用其他的方法（spring提供了api来进行读取）

#### bean实例化之后有哪些对外的扩展点

1. smartInitializingSingleton接口： 内部有一个afterSingletonInstantiated，进行自定义扩展
2. ApplicationListener接口可以监听事件，这里可以监听所有bean实例化后容器刷新时的事件，也算是一个扩展点

#### beanDefinition注册完之后有哪些对外的扩展点

1. BeanFactoryPostProcessor接口，可以在bean实例化之前对`beanFactory`进行修改
2. BeanDefinitionRegistryPostProcessor接口，在实例化之前调用，可以修改或者注册新的`beanDefinition`
3. ApplicationListener接口，可以在beanDefinition注册完之后发布一个事件，这个事件也算是一个扩展点

#### bean的实例化顺序和beanDefinition的注册顺序

1. bean的实例化顺序由beanDefinition的注册顺序决定，并且受到bean相互依赖的影响
2. beanDefinition的注册顺序由注解，配置的**解析顺序**来决定的
   1. @configuration最先
   2. BeanDefinitionRegistryPostProcessor接口注册的beanDefinition最后
   3. 剩下的不知道了

#### spring的配置方式

1. xml：最后按照层级结构解析读取到bean的配置并实例化
2. 注解：根据注解中配置的信息来实例化bean
3. java的配置：使用@configuration代替xml文件，@Bean代替`<bean>`的配置

#### javaConfig如何代替xml配置

1. 使用的应用上下文不一样（ClassPathApplicationContext，AnnotationConfigApplicationContext）
2. 使用@Configuration注解的配置类代替xml文件
3. 配置bean的各种属性都有对应的注解

> 解析的时候，使用beanDefinitionreader接口下不同的实现类来读取xml或者javaconfig类，之后使用不同的parser来解析得到beanDefinition

#### 自动注入属性时，如果没有或者找到多个bean，如何让其不报错

1. 没有找到：自动注入时，，默认必须注入，一旦找不到这个属性就会报错，我们可以将autowired中的一个**required属性设置为false**，此时找不到就不会报错
2. 找到多个：将想要的那个bean设置为primary，或者使用quelifier来给bean指定一个标签

#### autowired和resource的区别

1. autowired是spring提供的，resource是jdk提供的
2. autowired先bytype再byname，resource先byname再bytype

#### autowired自动装配过程

1. autowired使用bean的后置处理器进行解析，将要注入的属性的一些元信息（类型，名称）获取到
2. 在属性注入的过程中真正进行自动装配，根据上一步得到的信息去ioc容器中查找并注入
3. 先bytype再byname，其中还涉及到primary（指定主要的bean）和qualifier（指定bean的名称，注入时指定名称）的知识

#### @configuration的作用

1. 可以用来配置bean
2. 代替传统的xml文件
3. 没有configuration也可以配置bean，只要使用了@bean，spring就可以自动完成扫描，此时这个类不再是一个配置类，而是一个普通类
4. 增加configuration之后，该类会被cglib创建一个**动态代理**进行增强，执行被@bean修饰的方法时，会先从容器中找，**从而保证创建的bean都是单例的**

#### @bean的方法如何保证bean是单例

需要在类上加上configuration注解，此时会为这个类生成**cglib动态代理**，调用这些方法时会被增强，会先从容器中找bean，从而保证单例

#### 如何引入第三方的bean

1. 用@bean修饰方法，方法内手动new，可以干预实例化过程
2. 用@import直接导入类，无法干预实例化过程
3. 用import导入importselector：返回一个字符串数组
4. 用import导入importBeandefinitionregistrar：手动编写beanDefinition再完成实例化

#### aop常见名词 

面向切面编程，给现有代码进行批量增强时使用，底层原理使用了动态代理

1. 切面： 包含切点和通知，在项目中是一个类
2. 切点：决定哪些方法会被增强，通常由切点表达式实现
3. 通知：具体如何增强，何时何地增强原有代码，或者说就是想要增加的公共代码
4. 连接点：具体在哪应用通知，也就是被增强的方法
5. 代理：当出现连接点时由代理进行拦截并应用通知进行增强
6. 织入：通知加入到被增强的方法中的**过程**叫做织入，aspectj在连接点**编译期**就将通知植入进行增强，而spring aop是在**运行**的时候产生一个动态代理来将通知植入进行增强

#### spring aop的类型

1. 前置
2. 后置：在返回或者异常之后
3. 环绕：只有这个通知需要手动指定连接点的执行时机
4. 异常
5. 返回

#### spring AOP与AspectJ aop的区别

1. 织入时机不一样，spring在运行时使用动态代理织入，而AspectJ在编译时织入，直接修改class字节码文件来进行增强
2. spring的性能更好，不改字节码
3. AspectJ功能更强大
4. spring对被增强的代码影响较小，因为不修改字节码

#### JDK和Cglib动态代理的区别

> jdk生成动态代理类之后，根据通知的类型决定执行的顺序，并且利用**反射**执行原有方法
>
>  cglib在增强时是通过**子类调用父类**中的原有方法，在这个过程中执行增强的代码

1. jdk是基于**接口**的，要求被代理的类必须实现一个接口，cglib基于**继承**
2. jdk通过**反射**生成动态代理，cglib通过**字节码**库（ASM）来生成被代理类
3. jdk**性能更好**，jdk生成代码快，调用慢，cglib生成代码慢，调用快，并且jdk使用java自带的反射，而cglib使用了第三方库
4. jdk被代理的方法**必须是公开**的，因为它是基于接口的（<u>接口中的方法默认公开</u>），cglib没有限制

#### aop失效

1. 方法**内部自调用**会导致AOP失效，因为aop需要进行增强代码，如果被增强的方法内部调用了本类中的其他方法，那么就会直接使用this调用，这里的this指的是原始对象，也就是没有被增强的对象，从而会导致方法内部调用的这个方法aop失效
2. jdk动态代理中被增强的方法不是public
3. 被增强的类没有配置为bean，没有交给spring管理

解决方法：

1. 在方法内部调用的方法单独抽取出一个类来增强
2. 自己注入自己，此时注入的就是被增强的动态代理对象，然后通过**对象.**的方式调用
3. 将当前被增强的对象放入ThreadLocal中（exposeProxy属性设置为true），然后利用aopcontext来获取到当前被增强的对象，从而调用方法内部被调用的方法

#### spring AOP在哪里创建的动态代理

1. 初始化后，在beanPostProcessor中的一个方法中创建
2. 特殊情况：出现循环依赖时，有必要的话会进行提前AOP

#### spring AOP的实现流程

1. 启用：启用AOP时（EnableAspectJAutoProxy）会注册一个bean的**后置处理器**来处理AOP
2. 解析：创建bean时调用上面注册的后置处理器**解析切面**（切点和通知），将所有的通知解析并缓存起来
3. 创建：bean初始化之后，**判断**当前bean是否被之前缓存的切点表达式命中，命中则创建动态代理
4. 调用：调用时根据通知的类型决定通知和原始方法的**执行**顺序

#### spring中事务的类型

1. 编程式事务：需要手动编写事务开启提交回滚的代码，比较灵活但是难以管理
2. 声明式事务：只需要使用注解或者 xml就可以将事务管理交给spring处理

#### spring中实现事务的几种方式

> 内部使用aop帮助我们开启事务，提交事务，回滚事务

1. 基于接口的事务，不太建议
2. 基于xml配置文件的方式`<tx>,<aop>`
3. 基于@Transactional

#### spring中事务的传播行为

> 当一个事务B方法被另外一个事务方法A**互相调用**时，这个事务方法应该怎么做

1. required：A存在事务就加入，否则就新建
2. requires_new：B新建一个事务，A存在事务就**挂起**
3. mandatory：存在就加入，不存在报错，
4. never：存在事务报错，也就是不需要事务
5. support：支持事务，存在就加入，不存在**不新建**
6. not_support：不支持事务
7. nested：B新建一个事务，A事务正常运行不挂起

在调用时出现有**四种**事务的实现方式：

> 事务的信息存储在ThreadLocal中，总结起来有下面几种情况

1. 融入：此时不同的事务共享一个数据库连接，共同提交回滚
2. 创建新事务：外部的事务将会暂存到ThreadLocal中，内部事务执行完毕才执行外部事务
3. 正常执行：此时外部事务正常执行，内部不开启事务，正常操作数据库即可
4. 报错：外部事务出发内部事务的报错条件（存在事务报错，不存在事务报错），此时回滚

#### 事务隔离级别

1. 读未提交：脏读，不可重复读，幻读都无法解决
2. 读已提交：不可重复读，幻读无法解决
3. 可重复读（mysql默认）：幻读无法解决
4. 序列化：都可以解决，但是效率不高

#### 事务实现原理

> 主要是`AOP`（面向切面编程）+数据库自带的事务，步骤类似于开启了一个环绕通知

1. 使用了@transaction注解的bean就会创建动态代理（有接口使用jdk，没接口使用cglib）

2. 关闭数据库连接中的自动提交

3. 正常执行方法

4. 正确执行就手动提交，错误执行就手动回滚

   > 上面几步的代码放在了try_catch中

#### 多线程事务能否保证事务一致性

> 你说的是在一个事务中存在另外一个线程调用其他的事务方法吗?

不能，因为事务信息保存在ThreadLocal中，一个线程只能有一个事务，所以多线程无法保证事务一致性

但是可以通过编程式事务，自己控制事务的提交

#### 事务失效原因

> spring中的事务基于aop来实现，所以aop失效，事务也会失效，同时如果错误的使用了事务的传播行为也会导致事务的失效

1. 错误使用事务传播行为
2. 使用cglib创建动态代理，但是事务方法被final修饰
3. 使用jdk创建动态代理，但是事务方法不是public
4. 方法内部自调用
5. 事务类没有交给spring管理
6. 事务出现异常但是被catch住了，检测不到异常就会失效

#### spring事件监听机制

> 有三个核心部分，事件，监听器，**事件多播器**，事件和事件监听器之间解耦，从而提高代码的扩展能力，其实有方法能替代，就是使用MQ技术发布消息即可，常见的有kafka，rabbitMQ，rocketMQ等

1. 事件监听器**注册**到事件多播器中
2. 事件通过事件多播器**发布**（publishEvent）
3. 判断当前事件与哪些事件监听器**匹配**，也就是事件监听器是否监听的是当前事件
4. 匹配成功就**执行**事件监听器中定义的逻辑

#### beanFactory和factoryBean的区别

1. beanFactory是一个factory，可以通过传入bean的名称获取bean
2. factoryBean是一个bean，可以自定义创建管理更复杂的bean实例

#### spring中的设计模式

1. 单例
2. 简单工厂：beanFactory获取ioc容器中的bean时
3. 工厂方法：factoryBean自定义bean时
4. 观察者：事件监听中，多播器是被观察者，监听器时观察者
5. 代理：aop创建动态代理
6. 模版方法：spring对外扩展时采用
7. 责任链：aop中一个连接点有多个增强时，就形成了一个调用链

#### spring如何整合mybatis管理mapper接口

> 由于是接口，底层采用了jdk的动态代理，所有的框架都是这样加入spring的，将自己的所有bean手动注册（对外扩展）成功beanDefinition交给spring

1. mybatis实现了一个beanDefinition注册的后置处理器，将内部的所有bean进行注册成beanDefinition

2. 自定义了一个扫描器，将mybatis中的接口也注册成beanDefinition，接口不能实例化

3. 利用factoryBean的工厂设计模式，在内自定义这些beanDefinition的实例化，将接口的beanDefinition中的BeanClass换成动态代理的class，之后实现实例化

4. 这样就将mybatis中的所有bean交给spring管理

   > 总结起来就是手动将接口注册成beanDefinition，但是接口不能实例化，然后利用factoryBean自定义实例化过程，给接口创建动态代理就可以得到动态代理实例化后的对象

#### spring如何整合外部框架

外部框架使用spring的对外扩展点，将自己的所有bean手动注册成beanDefinition交给spring，之后自动完成实例化，对应内部的接口，采用jdk动态代理就可以实例化

#### get和post乱码

1. 文件本身格式
2. 设置一个编码的过滤器
3. tomcat的编码

#### spring mvc的工作流程（DispatchServlet的工作流程）

> 核心就是DispatchServlet（前端控制器，核心调度器）来控制请求的传递

1. 前端请求到达DispatchServlet，判断最终请求被转发到后端哪个mapping对应的方法
2. 请求通过拦截器之后，请求传递到后端对应的方法上 
3. 如果请求中有参数，就会将参数转换成java能够处理的格式
4. 后端方法执行处理之后，返回数据，此时数据可能会转换成json格式
5. 将响应的数据解析成视图
6. 将渲染好的视图响应给前端得到结果

> 请求、拦截、映射、执行、响应、返回

#### spring整合springmvc为什么需要父子容器

> 不一定需要父子容器（springboot中就没有父子容器）

1. 有父子容器是为了**划分职责**（单一职责），service，dao交给spring（父），controller交给springmvc（子）
2. **规范开发**，service和dao无法访问controller（父不能访问子），controller可以访问service和dao（子可以访问父）
3. 当我们想要**替换**springmvc时更加方便，例如我们可以使用struts（mvc框架，将软件分为model，view，controller）替换springmvc

#### springmvc中的bean是否可以放到spring中管理

不可以，因为在前端请求到达之后，我们会判断请求映射到了后端那个方法中，此时判断的逻辑就是从springmvc中的容器中**拿到这些判断mapping的映射规则的bean**（在springmvc中存储），之后完成判断，并不会从spring的容器中拿，

如果放到了spring容器中，那么就拿不到判断映射规则的bean，此时会认为这个请求找不到映射，前端会报**404**

#### spring中的bean是否可以放到springmvc中

可以，只要能够拿到解析前端请求的bean，前端解析并映射成功，后期 就可以正常执行了

#### springmvc的拦截器和过滤器的区别

1. 请求先经过过滤器再经过拦截器
2. 拦截器不依赖于servlet容器，过滤器依赖
3. 拦截器只能对action请求（dispatchservlet映射的请求）起作用，而过滤器对任何请求都起作用，甚至静态资源
4. 拦截器可以访问容器中的bean，过滤器不能访问
