---
title: "Linux高并发服务器开发"
description: "linux高并发服务器开发"
keywords: "linux高并发服务器开发"

date: 2023-07-18T13:38:37+08:00
lastmod: 2023-07-18T13:38:37+08:00

categories:
  - 学习笔记
tags:
  - linux
  - 服务器
  - 项目


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
#url: "linux高并发服务器开发.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>🌆 linux高并发服务器开发

牛客的服务器开发[项目](https://www.nowcoder.com/courses/cover/live/504)学习开发笔记

<!--more-->

## 系统编程入门

### 环境搭建

在linux下进行开发，需要有linux系统，xshell远程连接服务器，xftp给服务器远程传输文件，vscode安装插件之后远程连接服务器，在本机开发，代码自动同步到远程服务器上

vscode远程连接服务器非常简单，只需要在config文件中新增一条信息即可：

![image-20230718135229099](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924878.png)

之后再config文件中新增主机的配置即可：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924886.png" alt="image-20230718135352944" style="zoom:50%;" />

之后再vscode就可以看到远程连接的服务器

免密登录vscode需要使用公钥和私钥配对，需要将本机的公钥复制给服务器的`authorized_keys`文件，具体存放地址为当前用户的home目录下的.ssh文件夹下，服务器保存了本机的公钥之后，拿这个公钥与本机的私钥进行对比，对比成功即可免密登录，具体流程为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261229230.png" alt="image-20230526122957172" style="zoom:50%;" />

> 如果显示过程试图写入的管道不存在，应该是本机的**known_hosts**中保存的是旧的连接信息，根据ip地址删除旧的信息即可，文件在 **C:\Users\你的用户名\.ssh\known_hosts**

### GCC

GCC是GNU编译套件，可以编译写好的c语言或者c++语言，编译的过程为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924887.png" alt="image-20230718151559768" style="zoom:50%;" />

GCC常见的编译选项为： 

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924888.png" alt="image-20230718151920049" style="zoom:50%;" />

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924889.png" alt="image-20230718153309056" style="zoom:50%;" />

### 静态库制作和使用

库文件可以看作是一个代码仓库，程序调用这个库文件，就可以使用库文件中定义的功能

 库文件有两种，分为静态库和动态库，静态库在程序的链接阶段被展开到程序中，动态库在运行时才由系统动态的加载到内存中供程序调用

> 静态库的制作

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924891.png" alt="image-20230718154001722" style="zoom:50%;" />

> 自己制作静态库，文件下载地址[点这里](https://uploadfiles.nowcoder.com/files/20201201/999991343_1606792586768/1.4%E8%AF%BE%E4%BB%B6%E4%BB%A3%E7%A0%81.7z)，将calc文件夹下的加减乘除文件制作成静态库

1. 生成加减乘除文件的.o文件

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924892.png" alt="image-20230718154757086" style="zoom:50%;" />

2. 创建静态库，其中`calc`代表库的名称，`libcalc.a`代表库文件的名称

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924893.png" alt="image-20230718154925392" style="zoom:50%;" />

3. 静态库的使用

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924894.png" alt="image-20230718155857502" style="zoom:50%;" />

   - 参数1代表指定编译器搜索的头文件路径
   - 参数2代表指定编译器搜索的库文件名称
   - 参数3代表制定编译器搜索的库文件路径

4. 程序执行

> 最终执行成功

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924895.png" alt="image-20230718160028211" style="zoom:50%;" />

### 动态库制作和使用

> 动态库的规则

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924896.png" alt="image-20230718160710462" style="zoom:50%;" />‘

其中fpic代表与路径无关，因为是动态库文件

> 工作原理：

- 静态库：GCC 进行链接时，会把静态库中代码打包到可执行程序中 

- 动态库：GCC 进行链接时，动 态库的代码**不会**被打包到可执行程序中

1. 生成加减乘除的.o文件

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924897.png" alt="image-20230718161444029" style="zoom:50%;" />

   需要加上位置无关编码

2. 得到动态库文件，后缀名为.so

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924898.png" alt="image-20230718162657654" style="zoom:50%;" />

3. 使用动态库

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924899.png" alt="image-20230718162031327" style="zoom:50%;" />

   编译出可执行文件的步骤与制作静态库的步骤一样

4. 程序执行，**需要指定共享库的路径**

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924900.png" alt="image-20230718162302810" style="zoom:50%;" />

   > 这里与静态库的使用不同，运行时需要指定动态库的存储路径，为什么呢？
   >
   > **指定动态库路径的原因：**

- 程序启动之后，动态库会被动态加载到内存中，通过 `ldd` （list dynamic dependencies）命令检查动态库依赖关系

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924901.png" alt="image-20230718163020904" style="zoom:50%;" />

  > 发现动态链接的可执行文件依赖的动态库文件找不到，所以需要指定动态库文件路径

- 如何定位共享库文件呢？ 

  当系统加载可执行代码时候，能够知道其所依赖的库的名字，但是还需要知道绝对路径。此时就需要系统的**动态载入器**来获取该绝对路径

  对于elf格式的可执行程序，是由`ld-linux.so`来完成的

  它先后搜索elf文件的 `DT_RPATH`段 ——> 环境变量 `LD_LIBRARY_PATH` ——> `/etc/ld.so.cache`文件列表 ——> `/lib/`，`/usr/lib` 目录

  找到库文件后将其载入内存

> 可以直接配饰LD_LIBRARY_PATH变量，使其保存动态库的绝对路径

1. 添加环境变量，这个环境变量是临时的，一旦终端关闭，环境变量就清空

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924902.png" alt="image-20230718164340338" style="zoom:50%;" />

2. 查看动态库文件是否能查找到

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924903.png" alt="image-20230718164420998" style="zoom:50%;" />

3. 运行程序，配置环境变量之后，就可以和正常可执行文件一样运行了

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307181924904.png" alt="image-20230718164555628" style="zoom:50%;" />

   > <font color=red>除了配置`LD_LIBRARY_PATH` ，还可以配置`/etc/ld.so.cache`，具体步骤如下：</font>

1. 在`/etc/ld.so.conf`文件中添加动态库文件所在的目录

2. 使用`ldconfig`更新配置

3. 使用`ldd main`查看动态库文件是否能被找到


### 静态库动态库对比

程序执行的过程：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105479.png" alt="image-20230718202429229" style="zoom:50%;" />

只有链接时，静态和动态才有区别

1. 静态库的制作

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105481.png" alt="image-20230718202636055" style="zoom:50%;" />

2. 静态库的优缺点

   有几个程序用到静态库，就加载几份文件到内存中

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105482.png" alt="image-20230718210508206" style="zoom:50%;" />

3. 动态库的制作

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105483.png" alt="image-20230718202656186" style="zoom:50%;" />

4. 动态库的优缺点

   动态库只有在需要时才加载到内存中，所以加载时不知道加载到了哪，故生成动态库文件是，需要加上位置无关编码`-fpic`

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105485.png" alt="image-20230718210452887" style="zoom: 50%;" />

### Makefile

​	`Makefile`文件中定义了一系列的规则，这些规则控制了项目的编译，就像是一个脚本，写好`Makefile`文件之后，只需要使用`make`就能将项目自动编译，程序更新之后，只需要将`Makefile`文件进行修改，不用考虑其他因素

Makefile的格式：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105486.png" alt="image-20230718205636270" style="zoom:50%;" />

当依赖的创建时间比目标的创建时间晚时，说明依赖被修改过，此时被修改过的依赖以及目标都需要重新生成

后面的规则都是为第一条规则服务的，当第一条规则中的依赖没有找到，那么Makefile就会到后面的规则中查找有没有一条规则是生成这个依赖的

1. 变量

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182105487.jpg" alt="Snipaste_2023-07-18_21-02-13" style="zoom:50%;" />

2. 模式匹配

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182107378.png" alt="image-20230718210702428" style="zoom:50%;" />

3. 函数 

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182108487.png" alt="image-20230718210734032" style="zoom:50%;" />

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182108139.jpg" alt="Snipaste_2023-07-18_21-07-46" style="zoom:50%;" />

   如果想要在生成可执行文件之后，将文件夹中不再需要的`*.o`文件删除，可以制定一个clean规则，具体的规则命令如下：

   ```makefile
   #.PHONY代表伪目标，不生成文件，所以当前文件夹下有clean文件也没事
   .PHONY:clean
   clean:
   	rm $(objs) -f
   ```

> 详细的Makefile教程[点这里](http://www.zhaixue.cc/makefile/makefile-intro.html)

### GDB

了解了cpp文件到可执行文件的过程之后，需要进一步了解程序的调试流程，使用GDB可以用来跟踪程序的运行过程，从而清楚的知道错误产生的地点

VSCode底层也是调用GDB来实现对C++文件的调试工作

`gdb [需要调试的可执行文件名]`就可以进入GDB调试程序

> 前提是生成的可执行文件加上了-g参数才可以被调试
>
> 例如：g++ -g main.cpp -o main，此时main文件**才**可以被调试

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132034405.png" alt="image-20230613203411308" style="zoom:50%;" />

#### 编译参数

GDB在使用时需要搭配参数来控制程序的运行

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182210579.png" alt="image-20230718215238864" style="zoom:50%;" />

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182210580.png" alt="image-20230718215257649" style="zoom:50%;" />

```bash
## 以下命令后括号内为命令的简化使用，比如run（r），直接输入命令 r 就代表命令run
$(gdb)help(h) # 查看命令帮助，具体命令查询在gdb中输入help + 命令

$(gdb)run(r) # 重新开始运行文件（run-text：加载文本文件，run-bin：加载二进制文件）

$(gdb)start # 单步执行，运行程序，停在第一行执行语句

$(gdb)list(l) # 查看原代码（list-n,从第n行开始查看代码。list+ 函数名：查看具体函数）

$(gdb)set # 设置变量的值

$(gdb)next(n)   # 单步调试（逐过程，函数直接执行,不会进入）

$(gdb)step(s) # 单步调试（逐语句：跳入自定义函数内部执行）

$(gdb)backtrace(bt) # 查看函数的调用的栈帧和层级关系

$(gdb)frame(f) # 切换函数的栈帧

$(gdb)info(i) # 查看函数内部局部变量的数值

$(gdb)finish # 结束当前函数，返回到函数调用点

$(gdb)continue(c) # 继续运行

$(gdb)print(p) # 打印值及地址

$(gdb)quit(q) # 退出gdb

$(gdb)break+num(b) # 在第num行设置断点

$(gdb)info breakpoints # 查看当前设置的所有断点

$(gdb)delete breakpoints num(d) # 删除第num个断点

$(gdb)display # 追踪查看具体变量值，每一步都会显示这个变量

$(gdb)undisplay # 取消追踪观察变量

$(gdb)watch # 被设置观察点的变量发生修改时，打印显示

$(gdb)i watch # 显示观察点

$(gdb)enable breakpoints # 启用断点

$(gdb)disable breakpoints # 禁用断点

$(gdb)x # 查看内存x/20xw 显示20个单元，16进制，4字节每单元

$(gdb)run argv[1] argv[2] #调试时命令行传参

$(gdb)set follow-fork-mode child#MakeFile项目管理，选择跟踪父子进程（fork()）
```

> :smile:以上命令运行时输入回车代表重复上一命令，例如输入s单步调试，回车代表继续单步调试

#### 实战

给出一个了`debug.cpp`文件用来做GDB调试

``` c++
#include<iostream>
using namespace std;

int main(int argc,char **argv)
{
        int N=100;
        int sum=0;
        int i=1;
        //计算1加到100
        while(i<=N)
        {
                sum=sum+i;
                i=i+1;
        }
        cout<<"sum="<<sum<<endl;
        cout<<"程序结束！"<<endl;
        return 0;
}
```

1. 首先对debug.cpp文件进行编译生成可执行文件

   ```bash
   #必须加上-g，才能使用GDB调试
   g++ -g debug.cpp -o debug
   ```

2. 进入gdb调试界面

   ```bash
   gdb debug_with_g
   #也可以使用下面的命令
   gdb 可执行程序名
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132039097.png" alt="image-20230613203910026" style="zoom:50%;" />

   此时可以正常调试

3. 调试程序

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307182210581.jpg" alt="Snipaste_2023-07-18_22-10-00" style="zoom:50%;" />

   - display设置想要跟踪的变量
   - continue继续执行
   - list显示断点上下五行的代码

​	一个完整的调试步骤为：

```bash
gdb 可执行程序名 	#进入调试
b 12			#在12行增加一个断点
run				#开始运行代码
display i		#显示跟踪i的值
display sum		#显示跟踪sum的值
continue		#持续执行
#回车		       #继续上一条continue指令
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132102793.png" alt="image-20230613210258719" style="zoom:50%;" />

可以追踪`sum`和`i`的变化情况

在vscode中配置好`launch.json`和`tasks.json`文件之后，就可以使用vscode辅助调试

### 文件I/O

#### c和linux中I/O的区别

这里说的文件I/O是linux中的文件I/O，而不是c语言中的文件I/O，使用C语言的I/O函数时，会返回一个文件指针，文件指针包含三个部分：

- 文件描述符，代表了对应的磁盘文件
- 文件读写指针，可以操作文件中的数据
- I/O缓存区，可以作为程序和文件之间的桥梁

下图可以清晰的看到文件I/O函数的调用过程，缓冲区可以减少读写磁盘的次数

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633727.jpg" alt="Snipaste_2023-07-19_16-13-43" style="zoom:50%;" />

正常程序调用C语言的I/O函数之后，**底层会调用**linux内核中的I/O函数，此I/O函数没有缓冲区，每次读写都是在与磁盘打交道

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633732.png" alt="image-20230719161855722" style="zoom:50%;" />

> 下面介绍文件I/O函数涉及到的**文件描述符**：

linux中一切皆文件，所以每个文件都有一个文件描述符，windows中称为句柄，文件对应的文件描述符存储于虚拟地址空间中的内核区，由内核进行管理

一个进程运行的过程中涉及到诸多数据，操作系统为进程创建了PCB，其中PCB管理并保存了需要管理的数据，其中PCB中有一个数组，称为文件描述符表，保存了进程涉及到的所有文件描述符，大小默认1024

一个文件可以被打开多次，每次被打开时返回的文件描述符都**不同**

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633733.jpg" alt="Snipaste_2023-07-19_16-47-31" style="zoom:50%;" />

使用linux底层的open函数可以打开或者创建文件并得到一个文件描述符：

```c
/*
	//下面的手册可以使用：man 2 open查看
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>

    // 打开一个已经存在的文件
    int open(const char *pathname, int flags);
        参数：
            - pathname：要打开的文件路径
            - flags：对文件的操作权限设置还有其他的设置
              O_RDONLY,  O_WRONLY,  O_RDWR  这三个设置是互斥的
        返回值：返回一个新的文件描述符，如果调用失败，返回-1

    errno：属于Linux系统函数库，库里面的一个全局变量，记录的是最近的错误号。

    #include <stdio.h>
    void perror(const char *s);作用：打印errno对应的错误描述
        s参数：用户描述，比如hello,最终输出的内容是  hello:xxx(实际的错误描述)

    // 创建一个新的文件
    int open(const char *pathname, int flags, mode_t mode);
*/
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main() {

    // 打开一个文件
    int fd = open("a.txt", O_RDONLY);
	//代表打开文件失败
    if(fd == -1) {
        perror("open");
    }
    // 到这里就得到了文件描述符，打开文件成功，可以执行读写操作

    // 读写操作完成之后关闭文件
    close(fd);

    return 0;
}
```

#### 虚拟地址空间

虚拟地址空间在磁盘中并不存在，而是程序员想象出来的

每一个程序运行起来之后，都会拥有自己的虚拟地址空间，虚拟地址与CPU的位数有关，32为的机器，虚拟地址空间为4GB，其中3GB是用户区，1GB是内核区，操作系统中的MMU将虚拟地址和物理内存之间进行转换

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633734.jpg" alt="Snipaste_2023-07-19_16-31-06" style="zoom:50%;" />

> 详细的虚拟内存介绍[点这里](https://maodanp.github.io/2019/06/02/linux-virtual-space/)

### read&write

> read和write函数的使用

```c
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t count);
参数：
    - fd：文件描述符，open得到的，通过这个文件描述符操作某个文件
    - buf：需要读取数据存放的地方，数组的地址（传出参数）
    - count：指定的数组的大小
    返回值：
    - 成功：
    >0: 返回实际的读取到的字节数
        =0：文件已经读取到末尾，没有读取到数据
        - 失败：-1 ，并且设置errno

        #include <unistd.h>
        ssize_t write(int fd, const void *buf, size_t count);
参数：
    - fd：文件描述符，open得到的，通过这个文件描述符操作某个文件
    - buf：要往磁盘写入的数据，数据
    - count：要写的数据的实际的大小
    当count大于缓冲区大小时，会将缓冲区后面的数据写入内存，这些数据我们不确定是什么，是野内存
    返回值：
    成功：实际写入的字节数
    失败：返回-1，并设置errno
```

read和write中间的桥梁是一个缓冲区，通过缓冲区来交换数据

### lseek

> lseek函数的使用，可以移动文件指针

```c
标准C库的函数
    #include <stdio.h>
    int fseek(FILE *stream, long offset, int whence);

Linux系统函数
    #include <sys/types.h>
    #include <unistd.h>
    off_t lseek(int fd, off_t offset, int whence);
参数：
    - fd：文件描述符，通过open得到的，通过这个fd操作某个文件
    - offset：偏移量
    - whence:
	SEEK_SET
    设置文件指针的偏移量
    SEEK_CUR
    设置偏移量：当前位置 + 第二个参数offset的值
    SEEK_END
    设置偏移量：文件大小 + 第二个参数offset的值
       
返回值：
        返回当前文件指针的位置


作用：
    1.移动文件指针到文件头
    lseek(fd, 0, SEEK_SET);

    2.获取当前文件指针的位置
        lseek(fd, 0, SEEK_CUR);

    3.获取文件长度
        lseek(fd, 0, SEEK_END);

    4.拓展文件的长度，当前文件10b, 110b, 增加了100个字节
        lseek(fd, 100, SEEK_END)
        注意：需要写一次空数据，否则扩展失败
```

c语言中是`fseek`，linux中是`lseek`

- `fseek`用于在标准I/O文件流中进行定位，适用于C语言中的文件操作。
- `lseek`用于在文件描述符中进行定位，适用于Linux/Unix系统调用层面的文件操作。可以将文件的读写位置指针移动到指定位置，从而可以在指定位置进行读取或写入数据。

### stat&lstat

> stat和lstat函数的使用，获取文件的基本信息，lstat获取的是软连接文件的本身信息

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int stat(const char *pathname, struct stat *statbuf);
	作用：
        获取一个文件相关的一些信息
    参数:
    	- pathname：操作的文件的路径
        - statbuf：结构体变量，传出参数，用于保存获取到的文件的信息
        返回值：
        成功：返回0
        失败：返回-1 设置errno

int lstat(const char *pathname, struct stat *statbuf);
    参数:
    	- pathname：操作的文件的路径
        - statbuf：结构体变量，传出参数，用于保存获取到的文件的信息
        返回值：
        成功：返回0
        失败：返回-1 设置errno
```

具体的stat结构体结构为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633735.png" alt="image-20230722153846624" style="zoom:50%;" />

`st_mode`保存文件类型和权限的方式与linux一致，都是按位保存，对应位为1代表有这个权限或者是这个类型：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633736.jpg" alt="Snipaste_2023-07-22_15-41-18" style="zoom:50%;" />

对应的位下面的解释就是所拥有的属性，例如`-S_IROTH`代表其他人拥有读权限，第三位r为1，也就是十进制的4，这些宏分别代表不同的操作权限和文件类型

要判断文件是否有某种操作权限，使用`st_mode`与对应宏值做与操作看结果是否为1即可

要判断文件的类型，需要与掩码做与操作，因为文件类型一共有7种，对应的位是高四位，而掩码的二进制只有高四位为1，所以刚好可以得到文件的类型

> 可以使用stat来实现linux中`ll`命令的效果

```c

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <string.h>

// 模拟实现 ls -l 指令
// -rw-rw-r-- 1 root root 12 12月  3 15:48 a.txt
int main(int argc, char * argv[]) {

    // 判断输入的参数是否正确
    if(argc < 2) {
        printf("%s filename\n", argv[0]);
        return -1;
    }

    // 通过stat函数获取用户传入的文件的信息
    struct stat st;
    int ret = stat(argv[1], &st);
    if(ret == -1) {
        perror("stat");
        return -1;
    }

    // 获取文件类型和文件权限
    char perms[11] = {0};   // 用于保存文件类型和文件权限的字符串

    switch(st.st_mode & S_IFMT) {
        case S_IFLNK:
            perms[0] = 'l';
            break;
        case S_IFDIR:
            perms[0] = 'd';
            break;
        case S_IFREG:
            perms[0] = '-';
            break; 
        case S_IFBLK:
            perms[0] = 'b';
            break; 
        case S_IFCHR:
            perms[0] = 'c';
            break; 
        case S_IFSOCK:
            perms[0] = 's';
            break;
        case S_IFIFO:
            perms[0] = 'p';
            break;
        default:
            perms[0] = '?';
            break;
    }

    // 判断文件的访问权限

    // 文件所有者
    perms[1] = (st.st_mode & S_IRUSR) ? 'r' : '-';
    perms[2] = (st.st_mode & S_IWUSR) ? 'w' : '-';
    perms[3] = (st.st_mode & S_IXUSR) ? 'x' : '-';

    // 文件所在组
    perms[4] = (st.st_mode & S_IRGRP) ? 'r' : '-';
    perms[5] = (st.st_mode & S_IWGRP) ? 'w' : '-';
    perms[6] = (st.st_mode & S_IXGRP) ? 'x' : '-';

    // 其他人
    perms[7] = (st.st_mode & S_IROTH) ? 'r' : '-';
    perms[8] = (st.st_mode & S_IWOTH) ? 'w' : '-';
    perms[9] = (st.st_mode & S_IXOTH) ? 'x' : '-';

    // 硬连接数
    int linkNum = st.st_nlink;

    // 文件所有者
    char * fileUser = getpwuid(st.st_uid)->pw_name;

    // 文件所在组
    char * fileGrp = getgrgid(st.st_gid)->gr_name;

    // 文件大小
    long int fileSize = st.st_size;

    // 获取修改的时间
    char * time = ctime(&st.st_mtime);

    char mtime[512] = {0};
    strncpy(mtime, time, strlen(time) - 1);

    char buf[1024];
    sprintf(buf, "%s %d %s %s %ld %s %s", perms, linkNum, fileUser, fileGrp, fileSize, mtime, argv[1]);

    printf("%s\n", buf);

    return 0;
}
```

最终的结果为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307221633737.png" alt="image-20230722163319259" style="zoom:50%;" />

### 操作文件属性

操作文件属性的函数一共有四个：

1. `access`，检查进程对文件的访问权限

   ```c
   #include <unistd.h>
   int access(const char *pathname, int mode);
   作用：判断某个文件是否有某个权限，或者判断文件是否存在
       参数：
           - pathname: 判断的文件路径
           - mode:
           R_OK: 判断是否有读权限
           W_OK: 判断是否有写权限
           X_OK: 判断是否有执行权限
           F_OK: 判断文件是否存在
       返回值：
       	成功返回0， 失败返回-1
   ```

2. `chmod`，修改文件的权限

   ```c
   #include <sys/stat.h>
   int chmod(const char *pathname, mode_t mode);
   	作用： 修改文件的权限
       参数：
           - pathname: 需要修改的文件的路径
           - mode:需要修改的权限值，八进制的数
       返回值：
       	成功返回0，失败返回-1
   ```

3. `chown`，修改文件的属主

   ```c
   #include <unistd.h>
   int chown(const char *path, uid_t owner, gid_t group);
   	作用：修改文件的属主
       参数：
       	-path：需要修改的文件路径
       	-owner：需要修改的文件所有者
       	-group：需要修改的文件所在组
      	返回值：
       	成功返回0，失败返回-1
   ```

4. `truncate`

   ```c
   #include <unistd.h>
   #include <sys/types.h>
   int truncate(const char *path, off_t length);
   	作用：缩减或者扩展文件的尺寸至指定的大小
       参数：
       	- path: 需要修改的文件的路径
           - length: 需要最终文件变成的大小
        返回值：
            成功返回0， 失败返回-1
   ```

### 目录操作

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307251344431.png" alt="image-20230723142418300" style="zoom:50%;" />

1. `rename`，改变目录的名称，成功返回0，失败返回-1

   ```c
   #include <stdio.h>
   //newpath是新路径名
   int rename(const char *oldpath, const char *newpath);
   ```

2. `chdir`

   ```c
   #include <unistd.h>
   int chdir(const char *path);
   	作用：修改进程的工作目录
   	比如在/home/nowcoder 启动了一个可执行程序a.out, 进程的工作目录 	    /home/nowcoder
   	参数：
   		path : 需要修改的工作目录
   ```

3. `getcwd`，获取当前程序的工作目录，类似于`linux`中的`pwd`

   ```c
   #include <unistd.h>
   char *getcwd(char *buf, size_t size);
   	作用：获取当前工作目录
   	参数：
           - buf : 存储的路径，指向的是一个数组（传出参数）
   		- size: 数组的大小
   	返回值：
   		返回的指向的一块内存，这个数据就是第一个参数
   ```

4. `mkdir`，创建一个目录

   ```c
   #include <sys/stat.h>
   #include <sys/types.h>
   int mkdir(const char *pathname, mode_t mode);
   	作用：创建一个目录
   	参数：
   		pathname: 创建的目录的路径
   		mode: 权限，八进制的数
   	返回值：
   		成功返回0， 失败返回-1
   ```

5. `rmdir`，删除一个目录，并且只能删除**空**目录

   ```c
   #include <unistd.h>
   int rmdir(const char *pathname);//删除pathname代表的目录
   ```

### 目录遍历

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307251344438.png" alt="image-20230723144154491" style="zoom:50%;" />

1. `opendir`，用来打开一个目录

   ```c
   #include <sys/types.h>
   #include <dirent.h>
   DIR *opendir(const char *name);
       参数：
           - name: 需要打开的目录的名称
       返回值：
           DIR * 类型，理解为目录流
           错误返回NULL
   ```

2. `readdir`，用来读取目录中的数据，一般与`opendir`配合使用，先使用`opendir`打开目录，之后使用打开目录的返回值作为参数传递给`readdir`来读文件

   每次调用函数读取指定文件中的数据都会有一个返回值，返回值是结构体，结构如下：

   ```c
   #include <dirent.h>
   struct dirent *readdir(DIR *dirp);
       - 参数：dirp是opendir返回的结果
       - 返回值：
           struct dirent，代表读取到的文件的信息
           读取到了末尾或者失败了，返回NULL
   ```

3. `closedir`，关闭目录

   ```c
   #include <sys/types.h>
   #include <dirent.h>
   int closedir(DIR *dirp);
   ```

## 多进程开发

### 进程概述

程序运行之后，就变成了进程，而一个系统中，不止运行一个进程，为了管理进程，内核需要为每个进程分配一个`pcb`，用来管理进程

在`linux`中，进程控制块`pcb`是一个`task_struct`结构体，存放于`/usr/src/linux-headers-xxx/include/linux/sched.h`下，主要的结构体成员有：

- 进程id：系统中每个进程有唯一的 id，用 pid_t 类型表示，其实就是一个非负整数
- 进程的状态：有就绪、运行、挂起、停止等状态
- 进程切换时需要保存和恢复的一些CPU寄存器
- 描述虚拟地址空间的信息
- 描述控制终端的信息
- 当前工作目录（Current Working Directory）
- umask 掩码
- 文件描述符表，包含很多指向 file 结构体的指针
- 和信号相关的信息
- 用户 id 和组 id
- 会话（Session）和进程组
- 进程可以使用的资源上限（Resource Limit）

### 状态转换

进程在执行过程中会发生状态的变化，这些状态随着进程的执行和外界条件的变化而转换。 在三态模型中，进程状态分为三个基本状态，即就绪态，运行态，阻塞态。在五态模型 中，进程分为新建态、就绪态，运行态，阻塞态，终止态。

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127229.png" alt="image-20230725140212298" style="zoom:50%;" />

- 运行态：进程占有处理器正在运行
- 就绪态：进程具备运行条件，等待系统分配处理器以便运行。当进程已分配到**除CPU以外**的所有必要资源后，**只要再获得CPU**，便可立即执行。在一个系统中处于就绪状态的进 程可能有多个，通常将它们排成一个队列，称为就绪队列
- 阻塞态：又称为等待(wait)态或睡眠(sleep)态，指进程 不具备运行条件，正在等待某个事件的完成

阻塞态和就绪态 都是未运行的状态，但是不运行的原因不同，状态切换需要遵守一定的规则

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127230.png" alt="image-20230725140525945" style="zoom:50%;" />

- 新建态：进程**刚被创建**时的状态，尚未进入就绪队列
- 终止态：进程完成任务到达**正常结束**点，或出现无法克服的错误而**异常终止**，或被操作系统及有终止权的进程所终止时所处的状态。进入终止态的进程以后不再执行，但依然保留在操作系统中**等待善后**。一旦其他进程完成了对终止态进程的信息抽取之后，操作系统将删除该进程。

linux中可以使用`ps`指令查看系统中的进程信息，使用`top`可以实时动态的显示进程信息

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127232.png" alt="image-20230725141902270" style="zoom:50%;" />

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127233.png" alt="image-20230725141919451" style="zoom:50%;" />

### 进程创建

`linux`中创建进程的一种办法是使用`fork`函数

```c
#include <sys/types.h>
#include <unistd.h>

pid_t fork(void);
    函数的作用：用于创建子进程。
    返回值：
        fork()的返回值会返回两次。一次是在父进程中，一次是在子进程中。
        在父进程中返回创建的子进程的ID,
        在子进程中返回0
        如何区分父进程和子进程：通过fork的返回值。
        在父进程中返回-1，表示创建子进程失败，并且设置errno

    父子进程之间的关系：
    区别：
        1.fork()函数的返回值不同
            父进程中: >0 返回的子进程的ID
            子进程中: =0
        2.pcb中的一些数据
            当前的进程的id pid
            当前的进程的父进程的id ppid
            信号集

    共同点：
        某些状态下：子进程刚被创建出来，还没有执行任何的写数据的操作
            - 用户区的数据
            - 文件描述符表
    
    父子进程对变量是不是共享的？
        - 刚开始的时候，是一样的，共享的。如果修改了数据，不共享了。
        - 读时共享（子进程被创建，两个进程没有做任何的写的操作），写时拷贝。
```

其实父子进程在创建开始是共享内存的，只有在写入数据时才会进行复制，之前读数据时，都是共享内存，这种方式称为**写时复制，读时共享**

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127234.jpg" alt="Snipaste_2023-07-25_15-02-39" style="zoom:50%;" />

多进程开发时，有时需要使用gdb进行多进程的调试，gdb默认跟踪父进程，所以调试时子进程直接被执行，调试控制的是父进程，想要跟踪子进程时，需要设置一下

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127235.png" alt="image-20230725153057801" style="zoom:50%;" />

设置调试父进程或子进程：

```shell
set follow-fork-mode [parent(默认) | child]
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127236.png" alt="image-20230725153142788" style="zoom:50%;" />

如果想要在调试一个进程的时候，另外一个进程正常执行，或者想要调试一个进程时，另外一个进程挂起等待，需要改变调试的模式

```shell
#设置调试模式，on代表分离，一个进程调试时，另外一个进程正常执行
#off代表一个进程执行时，另外一个进程等待，被挂起
set detach-on-fork [on | off]

#查看调试的进程
info inferios

#切换当前调试的进程
inferior id

#使进程脱离gdb调试
detach inferiors id
```

比如当前正在调试父进程，使用inferiors可以切换到子进程进行调试，还可以使用detach让正在调试的子进程直接执行完毕，不参与调试

### exec函数族

exec 函数族的作用是根据指定的文件名找到可执行文件，并用它来**取代**调用进程的内容，换句话说，就是在调用进程内部执行一个可执行文件。

一旦某个进程中调用了这个函数想要执行其他的可执行文件，那么当前进程的数据就会被替换成这个可执行文件的数据，外部看起来还是当前的进程，内部已经变成了可执行文件的数据

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202307252127237.jpg" alt="Snipaste_2023-07-25_16-00-54" style="zoom:50%;" />

七个函数的区别就是在名称上，具体的区别就是exec后加上了不同含义的字母，例如：

```c
int execv(const char *path, char *const argv[]);
//argv是需要的参数的一个字符串数组
char * argv[] = {"ps", "aux", NULL};
execv("/bin/ps", argv);

int execve(const char *filename, char *const argv[], char *const envp[]);
//exvp指定了搜索的环境变量地址
char * envp[] = {"/home/nowcoder", "/home/bbb", "/bin"};
execve("ps", argv,envp);
```

> 注意传递参数时，最后一个参数一定是`NULL`，代表参数传递完成，是一个标志

其中前六个exec函数是标准c库中的函数，第七个函数才是linux中的exec函数，前六个只是将第七个函数进行简单的封装，从而实现exec的函数，常用的是前两个

1. `execl`函数，在给定的路径中查找可执行文件

```c
#include <unistd.h>
int execl(const char *path, const char *arg, ...);
    - 参数：
        - path:需要指定的执行的文件的路径或者名称
            a.out /home/nowcoder/a.out 推荐使用绝对路径
            ./a.out hello world

        - arg:是执行可执行文件所需要的参数列表
            第一个参数一般没有什么作用，为了方便，一般写的是执行的程序的名称
            从第二个参数开始往后，就是程序执行所需要的的参数列表。
            参数最后需要以NULL结束（哨兵）

    - 返回值：
        只有当调用失败，才会有返回值，返回-1，并且设置errno
        如果调用成功，没有返回值。
```

2. `execlp`函数，在环境变量中查找可执行文件

```c
#include <unistd.h>
int execlp(const char *file, const char *arg, ... );
    - 会到环境变量中查找指定的可执行文件，如果找到了就执行，找不到就执行不成功。
    - 参数：
        - file:需要执行的可执行文件的文件名
            a.out
            ps

        - arg:是执行可执行文件所需要的参数列表
            第一个参数一般没有什么作用，为了方便，一般写的是执行的程序的名称
            从第二个参数开始往后，就是程序执行所需要的的参数列表。
            参数最后需要以NULL结束（哨兵）

    - 返回值：
        只有当调用失败，才会有返回值，返回-1，并且设置errno
        如果调用成功，没有返回值。
```



## 多线程开发

## 网络编程

## 项目实战

