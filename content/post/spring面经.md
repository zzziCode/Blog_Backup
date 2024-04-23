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

#### 依赖注入的方式

1. 属性注入，也就是使用@AutoWired或者@Resource直接注入属性对象，
   1. 前者先byType后byName，一个类型存在多个bean就需要使用@quelifier或者@primary指定先注入谁，并且autowired还可以作用在构造方法上用来推断构造函数
   2. 后者先byName再byType，指定name之后只按照name注入
2. setter注入，给每个属性编写对应的setter方法，符合单一职责，但是在setter方法中可以随时修改，因为setter可能被调用多次
3. 构造器注入，只可能被修改一次，可以注入final修饰的对象，在不支持ioc的框架中也可以使用

#### spring中如何推断构造函数

1. 只有一个就只能用这个，根据形参列表区IOC容器中找到对应的bean，有一个包含两种情况：
   - 只有一个默认的无参
   - 有一个有参构造函数，此时java不提供无参

2. 有多个时：
   - 先使用@Autowired指定的构造函数，@Autowired只能加到其中一个构造方法中，加多个会报错，相当于没加
   - 没有@Autowired指定，就先用自定义的无参
   - 都没有就报错，说`NoSuchMethodException`
3. 选好构造方法后，如果是选择的是有参构造，此时需要根据形参列表先byType再byName，找不到匹配的bean就会报没有唯一的bean的错误

#### 紧耦合和松耦合

> 描述的是类之间的关系

紧耦合：类之间高度依赖，当依赖关系过多时，一个类修改，那么所有类都要跟着修改

松耦合：类之间的依赖关系较低，一个类修改时其余类可以不变，类的职责变得**单一**

**例如**多个service层依赖mapper层，紧耦合就是直接在service中new出这个maper的对象，当后期想要修改mapper时，每个类都需要改变，但是利用spring就可以实现松耦合，我们只需要将依赖的mapper对象进行改变即可，service中自动注入新的mapper对象

#### beanFactory的作用

1. 用来生产bean
2. 通过调用内部的getBean方法，传入一个标识来获取需要的bean
3. 内部有多种形式的getBean方法来生产bean

#### beanDefinition的作用

1. 保存了bean的定义信息，或者说保存了bean在生产前的配置信息。
2. 后续在生产bean时就会以来这些信息来创建bean，例如类信息，是否单例，是否懒加载等
3. bean实例化之前需要先注册形成beanDefinition

#### beanFactory和ApplicationContext的区别

> 都可以理解为bean的容器

1. beanFactory：使用时才会初始化bean，所以比较轻量级，

2. ApplicationContext：实现了beanFactory，在启动时就会初始化bean，并且相对于beanFactory拥有更多的功能，从而消耗的资源也会更多，相当于在beanFactory的基础上进行了扩展，比如说事件机制
3. 如果说beanFactory是心脏，那么ApplicationContext就是整个躯体
4. beanFactory是懒加载，用到的时候才调用getBean方法创建，项目启动更快
5. applicationContext在容器创建时不管是否用到都创建，后续用到的时候直接拿，更加会计

#### IOC容器的加载过程（Bean的创建过程）

1. 实例化一个ApplicationContext的对象，内部调用refresh方法
2. 加载bean的定义信息，主要是解析xml配置文件或者解析注解来得到bean的定义信息，也就是beanDefinition
3. 将定义信息保存到容器中便于后期bean的实例化，这些信息包含bean的类名，依赖关系，作用域等
4. 执行实例化前的修改逻辑，BeanFactoryPostProcessor
5. 保存实例化后的修改逻辑到一个容器中，便于bean实例化后调用
6. 实例化bean，根据bean的定义信息创建bean对象，此时的bean对象是一个空bean
7. 处理bean的依赖关系，进行属性的注入，在这里可能会出现循环依赖的问题
8. 执行bean的初始化方法，例如进行数据库连接的配置，初始化一些资源
9. 触发实例化后的修改逻辑，注册销毁逻辑到一个容器中，便于bean销毁时调用
10. 注册bean的销毁函数，在bean销毁时触发这些方法的执行，例如可以释放一些资源，防止内存泄漏等
11. 将实例化后的bean对象保存到容器中便于后期使用

#### IOC的扩展点有哪些

1. BeanPostProcessor：在实例化bean执行初始化**前后**进行额外的处理，例如进行AOP代理的创建（postProcessBeforeInitialization，postProcessAfterInitialization），属性的修改等
2. BeanFactoryPostProcessor：可以在bean定义后，实例化之前修改bean的定义，例如修改bean的作用域
3. 各种Aware回调：实现这些接口可以获取特定的资源，BeanFactoryAware可以获得BeanFactory的引用，ApplicationContextAware可以获得ApplicationContext的引用，BeanNameAware可以获得bean的名称等
4. FactoryBean：可以定制自己想要的bean
5. BeanDefinitionRegistryPostProcessor：实现这个接口可以注册自己的beanDefinition，将外部代码整合到spring中就可以通过这个接口来将自己项目中需要用到的bean全部注册成功beanDefinition进一步交给spring管理
6. 事件监听器：发布事件之后，对应的事件监听器就可以收到消息，做一定的扩展

#### bean是什么

被spring的ioc容器管理的对象称为bean

#### bean的配置方式

1. xml文件，在文件中使用bean标签
2. 注解（使用@Component**及其子注解**配置的类，前提是需要配置包扫描路径ComponentScan，springboot默认扫描当前包及其子包）
3. javaConfig（@Bean）使用@Configuration来进行配置，内部将@Bean放置在方法上返回一个bean对象
4. @Import
   - 直接导入其他的配置类或者bean的class文件，较为繁琐
   - 实现ImportSelector接口：返回一个**字符串数组**，内部保存了很多bean的类名称
   - ImportBeanDefinitionRegistrar：手动注入bean的定义信息，从而进行bean的配置，也就是自己new一个beanDefinition放到容器中，实现了bean的引入

#### bean的作用域

1. 单例singleton（默认）
2. 多例prototype
3. web应用中独有的（springmvc中独有）：
   - request：一个请求创建一个bean对象
   - session：一个session创建一个bean对象，一个会话可能包含多个请求，一个session中可以包含用户登录信息

4. application：一个应用共享一个bean对象

#### 单例bean的优势

1. 不用每次创建bean对象，减小内存消耗
2. bean对象无状态，也就是不会经常修改
3. jvm不用每次都回收bean对象，所以程序运行时间变短
4. 获取bean更快，因为不用每次都重新创建

#### springboot中读取配置文件的方式

1. @value加载单个属性

2. @ConfigurationProperties加载整个前缀的属性到一个java对象中

   ![image-20240416195157558](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202404161956574.png)

3. **注入**Environment对象，然后调用封装好的接口从而获取到配置文件中的属性

4. @PropertySource加载**指定**的配置文件

   ![image-20240416195634625](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202404161956667.png)

   - 这种一般是想要将框架之间的配置分开，比如mysql一个，redis一个，nacos一个
   - 因为springboot启动时会加载自己的application.yml，如果将某些启动属性放到了自己的配置文件中，可能导致加载顺序的问题导致出错

#### springboot配置文件加载顺序

1. resources下的配置文件文件
2. resources下的config目录中的配置文件
3. 项目根目录下的配置文件
4. 根目录下config子目录中的配置文件
5. 相同的yml和properties文件，先加载yml，相同的配置后面的覆盖前面
6. 也就是相同的配置，properties最终生效

#### bean的线程安全

1. 同时读写单例bean中的成员变量时就会出现线程不安全问题
2. 例如单例的user中存在一个username，同时存在多个线程修改这个username，此时就会出现线程不安全问题

> 可以将成员变量声明在方法中，这样就可以解决线程不安全问题，因为方法的调用每次都会创建新的副本，相当于方法中的变量是**独立**的

#### spring如何处理线程并发问题导致bean出现问题

> 出现线程安全的问题主要是读写单例bean中的成员变量

1. 单例bean改为多例bean
2. 单例bean的成员变量声明在方法中（不同的线程访问的是不同的副本）
3. 单例bean的成员变量绑定到ThreadLocal中
4. 给读写成员变量的代码加上synchronized同步，使其序列化执行

#### 实例化bean的几种方式

1. 构造器，调用bean的构造函数就可以实例化一个bean
2. 静态工厂：配置bean时指定一个factory-method，实例化时自动调用这个方法获取bean的实例，这个方法是静态的
3. 实例工厂：制定一个factory-method和factory-bean，利用这个来实例化，也就是指定调用哪个bean的哪个方法
4. FactoryBean：实现一个FactoryBean接口，重写一个getObject方法，返回的对象就是实例化后的bean，内部自己控制bean的实例化，灵活度更高

> 第一种是spring控制bean的实例化，后三 种是**自己**控制

#### 自动装配的几种方式（DI的方式）

1. no：不自动装配，此时需要使用`<property>`标签显式设置依赖项。
2. byName：根据bean的名称获取到对应的bean、
3. byType：按照bean的类型获取对应的bean
4. 构造函数：按照构造函数的形参类型来注入

#### bean的初始化实现方式

> 分为初始化和销毁两种回调，先注解，再接口，最后xml

1. 使用@PostConstruct，@PreDestroy注解：最先执行
2. 实现InitializingBean和DisposableBean接口，随后执行
3. 使用xml或者@Bean配置init-mothod和destroy-method属性，最后执行
4. 执行顺序是代码中决定的，按照顺序判断

#### bean的生命周期

> 生命周期指的是bean从创建到销毁的过程

1. 准备阶段：主要是形成实例化需要的beanDefinition
2. 实例化：读取到beanDefinition之后，触发BeanFactoryPostProcessor，这里主要是对bean的定义信息进行修改，然后保存BeanPostProcessor的修改逻辑，后期实例化后调用
3. 属性赋值：自动装配（no，byname，bytype，construct），会出现**循环依赖**
4. 初始化：调用很多aware回调方法，得到想要的资源。调用初始化生命周期回调，**aop**，这里会触发之前保存的BeanPostProcessor的逻辑
5. 销毁：容器关闭时调用销毁生命周期回调

#### 三级缓存如何解决[循环依赖](https://zzzicode.github.io/post/small_spring15/)

> 先说什么是循环依赖，之后说什么是三级缓存（三个map）

1. 一级缓存：存储完整的bean
2. 二级缓存：避免多重循环依赖的情况下重复创建动态代理，也就是保持单例性
3. 三级缓存：主要存储一个lambda表达式，只有在被依赖时才会被调用，调用之后创建一个bean对象，将其放入二级缓存中。一旦调用，那么不管是否出现循环依赖，aop都会提前

先创建A，然后将A放入三级缓存，主要是存放一个lambda表达式，然后进行属性填充，属性填充的过程中依赖B，于是新建B（假设B第一次创建），还是将B放入三级缓存并属性填充，此时依赖A，于是从一级缓存，二级缓存，三级缓存中查找A，从三级缓存中查找到A之后调用getObject方法，判断其是否需要AOP，然后将其保存到二级缓存中，之后B拿到这个A才能完成创建，将其保存到一级缓存中，并从三级缓存中删除。B完成创建之后，A也可以完成创建

> 主要利用了三级缓存**提前暴露**没有创建完成的bean对象，**打破**循环依赖

#### 二级缓存是否可以解决循环依赖

可以，但是不使用三级缓存会导致所有的aop都会提前，不符合bean的生命周期特征

因为有了三级缓存，此时不出现循环依赖的bean正常经过aop

出现循环依赖的bean才会提前aop，主要是为了属性填充时填充的是尝试aop之后的对象，只有二级缓存时，为了保持单例性，所有的bean都会提前aop

#### ~~多例bean存在循环依赖吗~~

1. 存在，此时这个循环依赖无法通过三级缓存解决，因为多例bean都不会保存到缓存中，而循环依赖的解决办法就是通过三级缓存
2. 要解决多例bean的循环依赖问题，可以使用@lazy注解延迟加载
3. 或者将多例bean改成单例bean

#### 如何避免并发情况下获取不完整的bean

1. 为什么会获取到不完整的bean：在中间还没有属性赋值或者aop时就获取到了bean，此时的bean是不完整的，或者说出现循环依赖的时候就容易获取到不完整的bean（第二级缓存）
2. 如何避免：**双重检查锁**
   - 两个同步锁（一级缓存不加锁），两次检查一级缓存，一级缓存不加锁是为了避免已经创建好的Bean阻塞等待
   - 在创建的过程中将二级缓存和三级缓存中不完整的bean锁住，其余想要访问（**第一次检查**一级缓存）的线程阻塞。创建完成之后放入一级缓存中才解锁
   - 解锁之前清理二级和三级中不完整的bean
   - 此时被阻塞的线程去检查二级和三级缓存中发现没有，于是准备创建，在创建之前再次检查一级缓存（**第二次检查**），此时发现存在，于是直接获得
   - 既避免了多次创建bean，又可以避免获取到不完整的bean

#### beanDefinition的加载过程

1. 根据xml文件或者注解形成对应bean的beanDefinition，内部包含bean的类型，bean是否单例，bean的属性列表等信息
2. 将所有的bean及其对应的beanDefinition保存到一个map中便于后期实例化时使用
3. 创建bean时，先读取到beanDefinition中保存的类型信息，创建空bean
4. 然后对空bean进行属性注入，使用到beanDefinition中的属性列表
5. 根据beanDefinition中保存的是否单例决定实例化后的bean是否保存到单例池中
6. 甚至还可以配置初始化方法或者销毁方法，这些也会在对应的地方加载。
7. 初始化是在实例化后保存到单例池前触发的，这里有个初始化前的逻辑，主要是尝试注入applicationContext这个容器资源，然后就是初始化，初始化后一般进行aop
8. 销毁逻辑一般是先保存，bean销毁时才使用钩子函数调用

#### bean实例化之后有哪些对外的扩展点

1. smartInitializingSingleton接口： 内部有一个afterSingletonInstantiated，进行自定义扩展
2. ApplicationListener接口可以监听事件，这里可以监听所有bean实例化后容器刷新时的事件，也算是一个扩展点
3. beanPostProcessor
4. 初始化方法

#### beanDefinition注册完之后有哪些对外的扩展点

1. BeanFactoryPostProcessor接口，可以在bean实例化之前对`beanFactory`进行修改
2. BeanDefinitionRegistryPostProcessor接口，在实例化之前调用，可以修改或者注册新的`beanDefinition`，部分框架整合spring就是实现了这个接口，在内部将框架自身的bean注入到spring框架中
3. ApplicationListener接口，可以在beanDefinition注册完之后发布一个事件，这个事件也算是一个扩展点

#### bean的实例化顺序和beanDefinition的注册顺序

1. bean的实例化顺序由beanDefinition的注册顺序决定，并且受到bean相互依赖的影响
2. 因为refresh方法中会将所有的beanDefinition对应的bean进行一遍实例化，也就是容器创建时初始化，不像beanFactory懒加载
3. beanDefinition的注册顺序由注解，配置的**解析顺序**来决定的
   1. @configuration最先
   2. BeanDefinitionRegistryPostProcessor接口注册的beanDefinition最后
   3. 剩下的不知道了
   4. 这是由代码中的顺序决定的，和初始化方法的执行逻辑一样

#### spring的配置方式

1. xml：最后按照层级结构解析读取到bean的配置并实例化
2. 注解：根据注解中配置的信息来实例化bean
3. java的配置：使用@configuration代替xml文件，@Bean代替`<bean>`的配置

#### BeanFactoryPostProcessor 和 BeanPostProcessor的区别

> 按照名称可以发现一个操作factory，一个操作bean

1. beanFactory的方法是在bean实例化之前调用从而修改bean的定义等信息
2. 而后者是在bean实例化之后调用，可以进行资源的预加载，创建aop
3. 比如要使用容器资源，实现一个applicatioContextAware接口，就会在初始化方法之前调用
4. aop会在初始化方法之后调用
5. 前者可以修改beanFactory中的所有bean，后者只能修改当前bean

#### javaConfig如何代替xml配置

1. 使用的应用上下文不一样（ClassPathApplicationContext，AnnotationConfigApplicationContext），也就是new的时候类不一样
2. 使用@Configuration注解的配置类代替xml文件
3. 配置bean的各种属性都有对应的注解
4. 解析得到beanDefinition的时候，调用的是不同的资源加载器

> 解析的时候，使用beanDefinitionreader接口下不同的实现类来读取xml或者javaconfig类，之后使用不同的parser来解析得到beanDefinition
>
> 最终的目的都是为了得到beanDefinition，然后创建bean

#### 自动注入属性时，如何让其不报错

1. 没有找到：自动注入时，，默认必须注入，一旦找不到这个属性就会报错，我们可以将autowired中的一个**required属性设置为false**，此时找不到就不会报错
2. 找到多个：将想要的那个bean设置为primary，或者使用quelifier来指定注入哪个bean

#### autowired和resource的区别

1. autowired是spring提供的，resource是jdk提供的
2. autowired先bytype再byname，resource先byname再bytype
3. autowired时spring框架的，在不使用spring框架的项目中无法使用

#### autowired属性填充过程

1. @Value：根据占位符中的内容从配置文件中拿到具体的值进行填充
2. @autowired。先判断当前属性是不是使用了这个注解，
3. 是的话判断这个属性的类型，从ioc容器中按照类型查找
4. byType找到一个直接注入
5. 找到多个再按照名称注入
6. 名称匹配不上看有没有使用qualifier或者primary注解
7. 都没有就报错


#### @configuration的作用

1. 可以用来配置bean，@bean修饰一个方法
2. 代替传统的xml文件
3. 没有configuration也可以配置bean，只要使用了@bean，spring就可以自动完成扫描，此时这个类不再是一个配置类，而是一个普通类
4. 增加configuration之后，该类会被cglib创建一个**动态代理**进行增强
5. 执行被@bean修饰的方法时，会**先从容器**中找，**从而保证创建的bean都是单例的**

#### @bean的方法如何保证bean是单例

> 单例说明bean保存到容器中

1. 需要在类上加上@configuration注解，此时会为这个类生成**cglib动态代理**，子类重写@bean修饰的方法
2. 调用这些方法时会被增强，会**先从**容器中找bean，从而保证单例

#### 如何引入第三方的bean

1. 用@bean修饰方法，方法内手动new，可以干预实例化过程
2. 用@import直接导入类，无法干预实例化过程
3. 用import导入importselector：返回一个字符串数组
4. 用import导入importBeandefinitionregistrar：手动编写beanDefinition再完成实例化

#### aop常见名词，概念 

面向切面编程，给现有代码进行批量增强时使用，底层原理使用了动态代理

1. 切面： 包含切点和通知，在项目中是一个类
2. 切点：决定哪些方法会被增强，通常由切点表达式实现，是一种**匹配规则**
3. 通知：具体如何增强，何时何地增强原有代码，或者说就是想要增加的公共代码
4. 连接点：具体**在哪**应用通知，也就是被增强的方法
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
2. jdk动态代理中被增强的方法不是public，此时就无法完成基于接口的增强，因为非public无法访问，也没有意义
3. 被增强的类没有配置为bean，没有交给spring管理
4. cglib中使用final修饰，导致无法继承
5. 没有开启注解的支持

解决方法：

1. 在方法内部调用的方法单独抽取出一个类来增强
2. 自己注入自己，此时注入的就是被增强的动态代理对象，然后通过**对象.**的方式调用
3. 将当前被增强的对象放入ThreadLocal中（exposeProxy属性设置为true），然后利用aopcontext来获取到当前被增强的对象，从而调用方法内部被调用的方法

#### spring AOP在哪里创建的动态代理

1. 正常：初始化后，在beanPostProcessor中的一个方法中创建，应该是初始化后的方法
2. **特殊**情况：出现循环依赖时，有必要的话会进行提前AOP，因为要确保属性注入时注入的是尝试aop之后的类

#### spring AOP的实现流程

> 自己理解的**五步**

1. 启用：启用AOP时（EnableAspectJAutoProxy）会注册一个bean的**后置处理器**来处理AOP
2. 解析：创建bean时调用上面注册的后置处理器**解析切面**（切点和通知），将所有的通知解析并缓存起来
3. 创建：bean初始化之后，**判断**当前bean是否被之前缓存的切点表达式命中，命中则创建动态代理，内部保存属性填充过的原始对象
4. 判断：创建动态代理之后还会对对应的方法进行拦截，判断当前方法是否需要增强
5. 调用：调用时根据通知的类型决定通知和原始方法的**执行**顺序

#### JDK和cglib动态代理的区别

1. jdk动态代理基于**接口**，生成的代理类是实现了一个接口并增强其中的方法
2. jdk调用被增强对象的方法时是通过**反射**
3. 某个类没有实现接口，此时不能通过jdk进行动态代理
4. cglib通过**继承**，在运行时通过ASM字节码框架直接生成一个子类，增强父类中的方法，同时还会生成一些其他类，主要是为了增强调用时的效率
5. cglib调用被增强对象的方法时是直接调用父类的方法
6. 某个类标记为final，此时不能通过cglib进行动态代理
7. jdk动态代理生成快，但是调用慢，需要经过反射
8. cglib动态代理生成慢，但是调用快，因为是使用字节码直接生成的类，但是jdk动态代理在后续的优化中性能逐渐变好，但是cglib止步不前

#### spring中事务的类型

1. 编程式事务：需要手动编写事务开启提交回滚的代码，比较灵活但是难以管理
2. 声明式事务：只需要使用注解~~或者 xml~~就可以将事务管理交给spring处理

#### spring中实现事务的几种方式

> 内部使用aop帮助我们开启事务，提交事务，回滚事务

1. 编程式事务，手动提交，回滚
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
4. 报错：外部事务触发内部事务的报错条件（存在事务报错，不存在事务报错），此时回滚

#### 事务隔离级别

1. 读未提交：脏读，不可重复读，幻读都无法解决
2. 读已提交：不可重复读，幻读无法解决，读的过程中允许别的事务修改当前数据
3. 可重复读（mysql默认）：幻读无法解决
4. 序列化：都可以解决，但是效率不高

#### 并发访问带来的数据读取问题

> 并发访问时，多个事务可能对相同的数据进行操作从而导致出现一些问题

1. 脏读：A读取B尚未提交的数据，但是B出现问题后当前数据回滚失效，A读到的数据就是脏数据，原因是事务的隔离级别是读未提交导致的
2. 不可重复读：事务在执行过程中，多次读取相同的数据，内容不一样，主要是因为事务隔离级别小于可重复读，在读取数据的过程中允许别的事务修改**当前**数据
3. 幻读：前后两次读取到的结果集数量不一致，这是因为事务在执行的过程中允许别的事务也操作**数据库**，从而导致可能新增或者删减了数据导致幻读

#### 事务实现原理

> 主要是`AOP`（面向切面编程）+数据库自带的事务，步骤类似于开启了一个环绕通知

1. 使用了@transaction注解的bean就会创建动态代理（有接口使用jdk，没接口使用cglib）

2. 关闭数据库连接中的自动提交

3. 正常执行方法

4. 正确执行就手动提交，错误执行就手动回滚

5. 相当于spring主动控制事务的提交和回滚，对原始代码做了增强

   > 上面几步的代码放在了try_catch中

#### 多线程事务能否保证事务一致性

> 你说的是在一个事务中存在另外一个线程调用其他的事务方法吗?

1. **不能**
2. 事务信息保存在ThreadLocal中，一个线程只能有一个事务
3. 多线程无法保证事务一致性
4. 但是可以通过编程式事务，自己控制事务的提交，或者使用分布式事务，将多个线程的事务统一交给TC事务协调者管理，主流的有XA和AT两种模式：
   - XA：利用数据库本身两阶段提交的特点，只有所有分支事务都成功才提交，有一个失败就都回滚
   - AT：分支事务执行时记录undo-log，然后就先提交不等待，有分支事务失败，就将提交的分支事务按照undo-log恢复

#### 事务失效原因

> spring中的事务基于aop来实现，所以aop失效，事务也会失效，同时如果错误的使用了事务的传播行为也会导致事务的失效

1. **数据库底层引擎是否支持事务**，myisam不支持事务，
2. 错误使用事务传播行为，比如not_support不支持事务，此时事务肯定不生效
3. 没有成功创建动态代理
   - 使用cglib创建动态代理，但是事务方法被final修饰
   - 使用jdk创建动态代理，但是事务方法不是public

4. **方法内部自调用**
5. 事务类没有交给spring管理，spring就无法帮忙AOP增强代码，帮助我们回滚或者提交
6. 事务出现异常但是被catch住了，检测不到异常就会失效
7. 事务中出现的异常不是RuntimeException，因为事务默认捕捉到RuntimeException类型的异常才会回滚，想要捕捉到其他异常类型也回滚就要配置rollbackFor属性

#### spring事件监听机制

> 有三个核心部分，事件，监听器，**事件多播器**，事件和事件监听器之间**解耦**，从而提高代码的扩展能力，其实有方法能替代，就是使用MQ技术发布消息即可，常见的有kafka，rabbitMQ，rocketMQ等

1. 事件监听器**注册**到事件多播器中的一个容器中，监听器需要在容器启动时就配置好
2. 事件必须通过事件多播器**发布**（publishEvent），相当于事件多播器是二者之间的桥梁
3. 判断当前事件与哪些事件监听器**匹配**，也就是事件监听器是否监听的是当前事件，关键词就是isAssignableFrom判断监听器监听的事件类型是否与当前事件匹配
4. 匹配成功就**执行**事件监听器中定义的逻辑
5. 有两个关键点：
   - 事件监听器必须注册到多播器中保存
   - 事件发布必须经过多播器


#### 事件监听中的isAssignableFrom

利用`isAssignableFrom`来判断当前监听器是否监听的是当前事件，一共有几步：

1. 拿到事件监听器监听的泛型
2. 拿到泛型真实的类型
3. 利用`isAssignableFrom`判断当前监听器监听的类型与当前发生事件的关系：
   - 为true代表当前事件监听器监听的事件要么是当前发生的事件的子事件，要么就是当前事件，此时可以触发当前监听器的监听逻辑
   - 为false说明当前监听器监听的事件与当前发生的事件没关系，直接跳过

#### beanFactory和factoryBean的区别

1. beanFactory是一个factory，内部有详细的bean的生命周期处理过程，从而产生各种bean
2. factoryBean是一个工厂类型的bean，内部可以自定义创建管理更复杂的bean实例，bean的创建过程更多的控制权在自己手中

#### spring中的设计模式

1. 单例：bean的单例遵循单例设计模式
2. 简单工厂：beanFactory调用getBean获取ioc容器中的bean时
3. 工厂方法：factoryBean自定义bean时
4. 观察者：事件监听中，多播器是发布者，监听器是观察者，事件本身是事件角色
5. 代理：aop创建动态代理
6. 模版方法：spring对外扩展时采用，父类中编写公共代码，子类中编写独有代码，或者说是在父类中定义骨架，将某些骨架的实现延迟到子类中
7. ~~责任链：aop中一个连接点有多个增强时，就形成了一个调用链~~
8. 适配器：使得不兼容的类可以在一起工作，bean销毁逻辑执行时，可以分为使用注解，实现接口以及xml配置，这几种方式导致bean的类型不一样，从而无法**统一**的完成销毁逻辑的注册保存，此时定义了一个适配器来进行适配，内部封装不同类型的销毁逻辑，项目中的binlog4J就是采用了适配器的设计模式，。。。监听日志变化的类被**统一**封装

#### 原型模式的bean没有销毁方法

1. 因为原型bean的特点就是即用既删，每当bean使用结束之后java自动销毁，所以不用创建销毁方法
2. 并且原型bean不被spring容器管理，所以无法通过容器的销毁方法销毁
3. 想要销毁只能通过手动销毁

#### spring如何整合mybatis管理mapper接口

> 由于是接口，底层采用了jdk的动态代理，所有的框架都是这样加入spring的，将自己的所有bean手动注册（对外扩展）成功beanDefinition交给spring

1. mybatis实现了一个beanDefinition注册的后置处理器，将内部的所有bean进行注册成beanDefinition放到spring中的beanDefinition的map中，交给spring管理

2. 利用factoryBean的**工厂设计模式**，在内自定义这些beanDefinition的实例化，将接口的beanDefinition中的BeanClass换成动态代理的class，之后实现实例化

3. 相当于将mapper接口换成真正的实现类，这样才能创建bean，外部使用时按照接口类型注入即可使用到真正的bean

4. 这样就将mybatis中的所有bean交给spring管理

   > **总结**起来就是手动将接口注册成beanDefinition，但是接口不能实例化，然后利用factoryBean自定义实例化过程，给接口创建动态代理就可以得到动态代理实例化后的对象

#### spring如何整合外部框架

1. 外部框架使用spring的对外扩展点
2. 将自己框架中的所有bean手动注册成beanDefinition交给spring
3. 之后自动完成实例化，对应内部的接口，采用jdk动态代理就可以实例化

#### get和post乱码

1. 文件本身格式
2. 设置一个编码的过滤器
3. tomcat的编码

#### spring mvc的工作流程（DispatchServlet的工作流程）

> 核心就是DispatchServlet（前端控制器，核心调度器）来控制请求的传递

1. 前端请求到达DispatchServlet，判断最终请求被转发到后端哪个mapping对应的方法
2. 具体是根据一个处理器映射器来判断请求映射到哪个方法中，没找到映射会报404
3. 请求通过拦截器之后，请求传递到后端对应的方法上 ，执行对应的接口方法
4. 如果请求中有参数，就会将参数转换成java能够处理的格式
5. 后端方法执行处理之后，返回数据，此时数据可能会转换成json格式
6. 将响应的数据解析成视图
7. 将渲染好的视图响应给前端得到结果

> 请求、拦截、映射、执行、响应、返回

#### spring整合springmvc为什么需要父子容器

> 不一定需要父子容器（springboot中就没有父子容器）

1. 有父子容器是为了**划分职责**（单一职责），service，dao交给spring（父），controller交给springmvc（子）

2. **规范开发**，service和dao无法访问controller（父不能访问子），controller可以访问service和dao（子可以访问父）

3. 当我们想要**替换**springmvc时更加方便，例如我们可以使用struts（mvc框架，将软件分为model，view，controller）替换springmvc

4. 相当于解耦，单一职责

5. springboot只提供一个容器，没有父子容器的概念，规定拿bean统一从这个容器中拿

6. springcloud又有父子容器是因为组件过多，将公共的bean放到父容器中，让职责变得单一

   例如启动的时候可以先读取公共的配置（nacos配置中心的bootstrap），然后再加载自己的容器

#### springmvc中的bean是否可以放到spring中管理

1. **不可以**，
2. 在前端请求到达之后，我们会判断请求映射到了后端那个方法中
3. 此时判断的逻辑就是拿到一个**处理器映射器**
4. 之后按照配置的@requestMapping来映射从而执行对应的方法
5. 这些有@requestMapping映射的bean保存到springmvc容器中
6. 相当于会从springmvc容器中拿到这些bean才能处理对应的请求
7. 如果放到了spring的容器中，那就找不到这个 bean，此时会认为没有这个接口，报404

#### spring中的bean是否可以放到springmvc中

1. **可以**
2. 只要能够拿到解析前端请求的bean，前端解析并映射成功，后期就可以正常执行了
3. 但是这样违反单一职责，并且容器中的bean比较混乱

#### spring中存在多个相同的bean

1. 如果是在同一个xml文件中，不能出现相同的bean的id，此时会报错
2. 在不同的xml文件中可以出现相同的bean的id，但是后期加载解析BeanDefinition时会覆盖
3. 对于Configuration注解内部使用@Bean修饰的方法这种形式，在上面的会注册，后面相同id的bean就不会注册了

#### springmvc的拦截器和过滤器的区别

1. 请求先经过过滤器再经过拦截器
2. 拦截器不依赖于servlet容器，过滤器依赖
3. 拦截器只能对action请求（dispatchservlet映射的请求）起作用
4. 过滤器对任何请求都起作用，甚至静态资源
5. 拦截器可以访问容器中的bean，过滤器不能访问
6. 拦截器依赖于java的反射机制

#### springboot及其特性（优点）

> springboot是**快速开发**spring应用的一个**脚手架**，目的是为了简化spring应用的开发流程

1. 主流框架无配置集成，开箱即用（内置了很多了starter结合自动配置，会自动读取spring.factories文件从而完成bean的实例化）
2. 采用javaconfig的方式，使得不再需要xml进行配置，项目从启动类开始运行
3. 内置web容器，使得应用可以直接启动
4. 可以管理第三方的依赖

#### spring和springboot的关系和区别

1. springboot是spring生态中的产品
2. springboot是一个脚手架，可以加速spring应用的开发

#### springboot的核心注解

1. @SpringBootApplication：一般在启动类中，内部有三个注解；
   - @SpringBootConfiguraton（标记启动类为配置类），可以在启动类内部使用@Bean注入一些bean对象
   - @EnableAutoConfiguration（启动自动配置）：主要是返回一个字符串数组，内部包含
   - @ComponentScan（自动扫描当前包及其子包），得到内部所有的bean

2. @ConditionalXXX：当出现什么条件才启用，OnBean，OnClass，OnException等等
3. @EnableXXX：开启各种功能，例如事务管理，远程调用，aop等等

#### springboot自动配置原理

> 自动将第三方的bean装配到spring容器中

1. 使用@SpringBootApplication内部的@EnableAutoConfiguration**启动**自动配置的功能
2. 其内部有一个**@Import** 注解，导入的XXXImportSelector类实现了ImportSelector接口，~~这个类应该是延迟加载的，先等项目中的bean加载完了再加载，因为有一个ConditionalOnxxx注解~~
3. 内部读取META-INF/spring.factories下配置的所有信息
4. 返回一个string[]数组，包含所有的自动配置类的类名
5. 通过@ConditionalOnXXX注解**过滤**掉无用（不符合条件）的自动配置类
6. 知道项目中有哪些自动配置类，就可以进行自动配置了
7. 后期自动配置时，只需要引入一个对应的starter，内部就会有需要的spring.factories文件，springboot就会自动读取这个文件

> 一般是自己项目中定义的bean先实例化，原理和一个deferredImportSelector有关，这样自动配置类中的@ConditionalOnXxX才能起到作用，将其放到最后，出现某些条件才执行

#### springboot中的jar包为什么可以直接运行

1. 内部有一个maven-plugin插件可以将程序打包成 可运行的jar包，否则会报没有主清单错误
2. 插件打包后，使得jar包内部包含应用依赖的jar以及springboot相关的类，变成Fat jar
3. java -jar会去找jar包里面的**manifest**文件，从而找到启动类并运行，普通jar包没有这个文件
4. 这个启动类创建一个ClassLoader来加载所依赖的所有jar包，并启动应用的main函数，由一个叫JarLauncher来启动
5. 读取到了所依赖的jar包，启动了main函数，项目自动启动了

#### springboot的启动原理

> 注解：得到需要的bean

1. 根据启动类上的注解来扫描当前包及其子包并注册其中的bean
2. 根据注解来读取所有依赖的`META-INF/spring.factories`文件，该文件指明了哪些依赖可以被自动加载。
3. 根据`importSelector`类选择加载哪些依赖，使用`conditionOn`系列注解排除掉不需要的配置文件
4. 将剩余的配置文件所代表的bean加载到IOC容器中。

> run方法：启动项目

1. 之后运行启动类中的run方法，内部读取环境信息，配置信息
2. 创建一个springApplication上下文并初始化
3. 加载ioc容器并发布各种事件便于外部扩展（外部监听对应的事件就可以完成扩展）

#### springboot内置tomcat启动原理

1. 添加一个web的starter依赖，之后springboot中会有一个servlet容器工厂的自动配置类
2. 在自动配置类中会导入一个web容器工厂，默认采用tomcat（这个根据@ConditionalOnxxx这个注解决定使用哪个web容器）
3. 内部有一个关于tomcat的bean，在springboot启动时会创建tomcat并启动，之后挂起tomcat等待用户请求

> 核心就是一个starter的依赖，有了这个依赖之后就完成了tomcat的自动配置

#### springboot结合外部tomcat

1. 项目打包方式设置为war
2. 排除内置的tomcat（exclusions）
3. 自定义一个类继承SpringBootServletInitializer 
4. 重写内部的 configure方法
5. 将项目的启动类传入到configure方法中
6. 之后tomcat就会运行这个启动类

#### springboot自定义stater

1. 在自定义的starter中新建一个META-INF文件夹，内部存放一个spring.factories文件
2. 里面的内容存放的键值对，主要是当前**自动配置类**的类名
3. 自动配置类中定义当前程序中所需要的一些bean
4. 如果需要一些配置属性，还可以提供一个属性配置文件
5. 打包发布

#### springboot读取配置文件的原理，配置文件加载顺序

> 核心就是事件监听的机制

1. springboot发布一个环境准备的**事件**
2. 对应监听器（配置文件监听器）监听到之后开始读取配置文件，主要加载后缀为properties和yml的配置文件
3.  将配置文件中的内容读取并封装供程序调用

> 配置文件优先级，相同配置下，优先级高的覆盖优先级低的

1. jar包同级目录下的config目录里的配置文件
2. config目录的子目录里面的配置文件
3. jar包同级目录下的配置文件
4. 类路径（resources文件夹下的资源）下的config目录里的配置文件
5. 类路径下的配置文件

#### 如何在springboot上做扩展

1. 由于springboot的自动配置特性，想要扩展什么，就要看哪个的自动配置类
2. 例如要将aop创建动态代理的技术进行修改（有接口用jdk，没接口用cglib），就要看aop的自动配置类
3. 看懂自动配置类之后才能在上面进一步扩展
4. 自动配置类中无非写的就是当前框架需要哪些bean，知道自动配置类的运行流程才知道怎么扩展

#### 微服务架构的优缺点

1. 开发效率快，拆分之后单一职责，单个服务启动也快
2. 由于功能进行拆分，维护起来也更加方便
3. 弱依赖的服务出现故障可以进行熔断，并不影响其余主线业务
4. 新增的业务不会影响现有业务的运行

> 缺点

1. 远程调用速度慢，影响项目运行效率
2. 微服务过多，保持系统中数据的一致性有些困难
3. 服务之间的关系复杂导致运维困难

#### SOA，分布式，微服务之间的关系

1. 分布式：将应用拆分成多块进行分布式的部署
2. SOA：是一种面向服务的架构，所有服务注册在总线上，从总线上查找服务信息
3. 微服务：也是一个面向服务的架构，功能拆分的粒度更细
4. 分布式会将项目拆分部署在不同的地方，分散压力，而微服务是将系统按照功能拆分，可以部署在一起，将项目的能力分散

#### 微服务拆分

1. 高内聚低耦合，保证服务的单一职责，尽量减少服务之间的依赖关系，服务拆分不要太细
2. 渐进式拆分，刚开始不要拆分太细，项目推进过程中逐步拆分

#### 微服务常用组件及其作用

1. 注册中心：eureka，nacos：服务以服务名的形式注册到注册中心
2. 负载均衡：ribbon，loadBalancer：一种服务有多个时，通信时要讲究负载均衡
3. 服务调用：Feign，OpenFeign：服务之间远程调用更加方便优雅
4. 配置中心：nacos，springcloud config：主要是完成配置的热更新
5. 服务保护：sentinel：保证系统高可用，防止雪崩，流量激增
6. 网关：springcloud gateway：为客户端提供统一服务，鉴权，过滤，修改请求
7. 搜索：elasticsearch：针对用户搜索的记录分析海量数据得出结果
8. 消息队列：RabbitMQ，RocketMQ，kafka：服务之间的异步通信

#### nacos注册中心核心功能原理

1. 微服务一旦启动，就会将自己的信息传递给注册中心一份
2. 其余微服务要使用其他的微服务只需要去注册中心请求就可以得到对应的微服务列表
3. 微服务本身会固定向注册中心发送一个心跳证明自己还正常运行
4. nacos注册中心对于非临时实例还会定期主动判断服务是否存活

#### nacos配置中心

1. 统一配置管理

2. 配置文件的名称有要求

3. 项目中要增加一个bootstrap.yml文件标记nacos的地址，这样才能从配置中心中拉取配置

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202312261409432.png" alt="img" style="zoom:50%;" />

4. 最好只将经常热更新的配置放到配置中心，其余不变的配置放到本地
5. 对于一个微服务，可以在不同的环境中（开发，测试，上线）共享配置文件，只要配置中心中的配置文件名不带环境名即可，就类似于本地的公共环境配置

#### 服务网关gateway可以做什么

1. 权限控制：登录鉴权
2. 限流：加上sentinel
3. 统一跨域实现：在网关层面允许跨域，解决跨域问题
4. 对外透明：访问网关就可以得到响应，不用了解内部的细节

#### 服务雪崩

由于某个微服务挂掉，导致剩下的微服务逐渐都挂掉了，这种逐渐放大的过程就叫做服务雪崩

#### 服务限流

为了保护系统，对访问服务的请求进行数量上的限制，保证系统不被大量的请求压垮

#### 服务熔断

当服务A调用服务B时，服务B出现了问题导致不可用，此时服务A为了保证自己不受影响就**切断**与服务B的通信，从而防止服务雪崩

#### 服务降级

提前规定好的一 种**兜底措施**，可以进行后期补救，直到服务B恢复，此时再恢复和B的通信

#### Ribbon负载均衡的策略

> 所有实现了IRule接口的类都是一种负载均衡的策略

1. 随机选择：在一个服务列表中随机选一个
2. 轮询：在一个服务列表的多个实例中按顺序轮
3. 重试：如果选到了正常的服务就按轮询，如果当前服务没有正常运行或者还没运行，此时就在一定的时间内不断重试
4. 默认跟地区有关的策略：默认先选择一个地区中的可用实例

