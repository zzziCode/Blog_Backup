---
title: "JDK中的动态代理"
description: "JDK中的动态代理"
keywords: "JDK中的动态代理"

date: 2024-05-10T10:21:12+08:00
lastmod: 2024-05-10T10:21:12+08:00

categories:
  - 学习笔记
tags:
  - 动态代理


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
#url: "jdk中的动态代理.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>🐇 JDK中的动态代理

本文主要介绍JDK中的代理是如何实现的，从基本的例子出发，先介绍简单的静态代理，然后重点介绍动态代理，开始分析源码，之后展示JDK动态生成的代理类长什么样，是如何实现代理的，最后总结整个代理的流程

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202406051704957.png" alt="Understanding the Proxy Design Pattern | by Mithun Sasidharan | Medium" style="zoom: 67%;" />

<!--more-->

## 静态代理

所谓的代理，就是在原有方法的基础上进行增强，并且不侵入源代码，下面介绍一个静态代理的例子：

> UserService接口的代码

```java
public interface UserService {
    public void select();

    public void update();
}
```

> UserServiceImpl类的代码，就是UserService接口的实现类

```java
public class UserServiceImpl implements UserService {
    public void select() {
        System.out.println("查询 selectById");
    }

    public void update() {
        System.out.println("更新 update");
    }
}
```

>UserServiceProxy类的代码，就是代理类，用来增强UserServiceImpl类的功能

```java
public class UserServiceProxy implements UserService{

    //保存需要被代理的对象
    private UserServiceImpl target;

    public UserServiceProxy(UserServiceImpl target) {
        this.target = target;
    }

    //调用被代理的方法，对原始方法进行增强，对外暴露代理对象Proxy的接口
    //使得用户对增强无感
    @Override
    public void select() {
        before();
        //调用被代理对象的方法
        target.select();
        after();
    }

    @Override
    public void update() {
        before();
        //调用被代理对象的方法
        target.update();
        after();
    }

    private void before() {     // 在执行方法之前执行
        System.out.println(String.format("开始时间[%s] ", new Date()));
    }
    private void after() {      // 在执行方法之后执行
        System.out.println(String.format("结束时间 [%s] ", new Date()));
    }

}
```

> main函数的代码

```java
public static void main(String[] args) {
    UserService userServiceImpl = new UserServiceImpl();
    UserService proxy = new UserServiceProxy(userServiceImpl);

    proxy.select();
    proxy.update();
}
```

可以看出，静态代理就是将代理对象封装到了一个代理类中，对外直接使用代理类提供的接口访问，功能增强对用户无感，因为代理类的接口名与被代理对象的接口名一样，在代理类的内部调用被代理对象的方法，相当于**套了一个壳子**，套壳子的方法就是实现被代理对象实现的接口，通过实现接口，代理类和被代理对象的结构变得一样

这种方法很简便，但是不利于后期扩展，当被代理对象变多之后，有两种解决方法：

1. 代理类实现多个接口，会使得代理类很庞大
2. 实现多个代理类，会让代理类变得很多

> 以上这些工作都是手工实现的，而动态代理的技术是将代理类的创建交给系统，利用反射创建适合自己的代理类，虽然是一个被代理对象一个代理类，但是代理类不用手写了，取而代之的是手写一个Handler类，用来描述如何增强被代理类对象，当要增强的方法足够多时，这种方法就有了优势

## 动态代理

### InvocationHandler

在这个类中描述被代理对象的增强方式，比如在方法执行的前后打印方法执行的耗时，核心就是`invoke`方法，在这个方法中会对被代理对象中的方法进行增强。类的实现如下：

```java
public class LogHandler implements InvocationHandler {

    //保存被代理的对象
    Object target;
    public LogHandler(Object target) {
        this.target = target;
    }
    /**@author zzzi
     * @date 2024/05/09 10:33
     * 主要是利用反射，对传递来的方法调用其invoke方法，在调用前后进行增强
     */
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        before();
        //利用反射的知识触发method的执行
        Object res = method.invoke(target, args);
        after();
        return res;
    }
    //对原始方法如何增强
    private void before() {
        System.out.println(String.format("动态增强日志开始执行 [%s] ", new Date()));
    }
    // 调用invoke方法之后执行
    private void after() {
        System.out.println(String.format("动态增强日志结束执行 [%s] ", new Date()));
    }
}
```

这个类中只是定义了如何对被代理对象增强，并不是真正的代理类，当调用代理类中的方法时，内部会调用这里的`invoke`方法，最终实现增强，所以说最核心的就是`invoke`方法，这个类最后会配合代理类实现对被代理对象的增强

### 创建代理类

刚才描述，代理类的创建不再交给用户，而是让系统利用反射来创建，那么是如何创建的呢，只需要几行代码，用户就可以得到一个代理类：

```java
//创建被代理的对象
UserServiceImpl userService = new UserServiceImpl();
ClassLoader classLoader = userService.getClass().getClassLoader();
Class<?>[] interfaces = userService.getClass().getInterfaces();
InvocationHandler handler = new LogHandler(userService);

/**@author zzzi
* @date 2024/05/09 22:14
* 重点就是在这个代理对象的创建上，传入了代理对象的各种信息，以及如何代理
* 系统就会创建对应的代理类
*/
UserService proxy = (UserService) Proxy.newProxyInstance(classLoader, interfaces, handler);
```

甚至上面的代码可以简化为一行：

```java
UserService proxy = (UserService)Proxy.newProxyInstance(UserService.class.getClassLoader(),new Class<?>[]{UserService.class},handler);
```

那么底层是如何根据传递来的这些参数来创建一个代理类的呢，既然外部使用了`newProxyInstance`这个方法创建代理类，那么显然核心代码就在这个方法中，我们需要查看`newProxyInstance`这个方法的源码：

> newProxyInstance方法的源码：

```java
//创建代理对象的方法
public static Object newProxyInstance(ClassLoader loader,
                                      Class<?>[] interfaces,
                                      InvocationHandler h)
        throws IllegalArgumentException {
    //定义如何增强的InvocationHandler不能为空
    Objects.requireNonNull(h);

    final Class<?>[] intfs = interfaces.clone();
    final SecurityManager sm = System.getSecurityManager();
    if (sm != null) {
        checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
    }
    //动态生成代理类的类文件
    //根据传递的接口得到代理类的结构，根据传递的增强方式得到代理类如何增强
    Class<?> cl = getProxyClass0(loader, intfs);
    try {
        if (sm != null) {
            checkNewProxyPermission(Reflection.getCallerClass(), cl);
        }
        //得到构造函数
        final Constructor<?> cons = cl.getConstructor(constructorParams);
        final InvocationHandler ih = h;
        if (!Modifier.isPublic(cl.getModifiers())) {
            AccessController.doPrivileged(new PrivilegedAction<Void>() {
                public Void run() {
                    cons.setAccessible(true);
                    return null;
                }
            });
        }
        //创建一个代理类对象
        return cons.newInstance(new Object[]{h});
    } catch (IllegalAccessException | InstantiationException e) {
        throw new InternalError(e.toString(), e);
    } catch (InvocationTargetException e) {
        Throwable t = e.getCause();
        if (t instanceof RuntimeException) {
            throw (RuntimeException) t;
        } else {
            throw new InternalError(t.toString(), t);
        }
    } catch (NoSuchMethodException e) {
        throw new InternalError(e.toString(), e);
    }
}
```

重点就是代码中增加注释的几句，根据传递来的接口和增强方式handler来动态创建代理类的类文件，之后调用构造函数创建一个代理类的对象返回，这些操作都借助了java中的反射

接下来我们查看一下生成的代理类到底长什么样子，为了简化代码量，这里只展示与本文有关的部分：

```java
public final class UserServiceProxy extends Proxy implements UserService {
    private static Method m4;
    private static Method m3;

    //把传递来的loader传递给父类Proxy
    public UserServiceProxy(InvocationHandler var1) throws  {
        super(var1);
    }

    static {
        try {
            m4 = Class.
                forName("proxy.UserService").getMethod("select");
            m3 = Class.
                forName("proxy.UserService").getMethod("update");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
    /**@author zzzi
     * @date 2024/05/10 10:47
     * 在代理类中调用上面定义的Handler中的invoke方法实现对被代理对象的增强
     */
    public final void select() throws  {
        try {
            super.h.invoke(this, m4, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final void update() throws  {
        try {
            //拿到loader，调用他的invoke方法，传递此时调用哪个方法
            super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }
}

```

可以看出代码的结构主要分为几个部分：

1. 将创建代理类中传递的handler传递给了父类Proxy，也就是在这里得到了如何对被代理对象增强，代码在**第6行**

2. 根据接口的结构得到被代理对象中的所有方法，用**m+数字**的方式标记这些方法

3. 在代理类中尝试调用被代理对象的方法，实际上调用的是handler中的invoke方法，这是**最关键的一步**，这一步的调用传递的参数包括**代理类对象**，**当前执行的方法**，**方法的参数**，这些东西会被传递到handler中，我们再次查看invoke方法的结构：

   ```java
   @Override
   public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
       before();
       Object res = method.invoke(target, args);
       after();
       return res;
   }
   ```

   可以看出，当代理类中调用这个invoke方法时，内部使用反射触发原始的被代理方法的执行，但是在执行前后对被代理对象的方法进行了增强

所以整体经历了以下几步：

1. 创建handler，核心是里面的invoke方法，决定了被代理对象如何被增强
2. 创建代理类，只需要传递几个参数就可以得到一个代理类对象
3. 调用代理类对象的方法select或者update，内部会调用handler的invoke方法，而invoke方法在触发被代理对象的方法select或者update时，会在执行前后执行增强的逻辑
4. 经历以上几步之后就完成了对被代理对象的增强，对外暴露的是代理类的接口，对用户无感，整体的流程可以总结为一个图：
   ![JDK动态代理执行方法调用过程](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202310311058251.webp)

## 总结

本文中总结了静态代理和动态代理的实现步骤，对于静态代理来说，代理类需要自己书写，被代理对象中的每一个方法都需要手动增强，对于动态代理来说，代理类不需要自己书写，取而代之的是一个`Handler`类，这个类中描述了被代理对象中的方法如何增强，统一定义在`invoke`方法中

对于动态代理来说，根据传递的三个参数`classLoader`, `interfaces`, `handler`来创建一个代理类对象，代理类对象内部会调用handler中的invoke方法，invoke最终才调用被代理对象的方法，相比于静态代理的套**一层壳子**，动态代理套了**两层壳子**
