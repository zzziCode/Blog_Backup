---
title: "基于VSCode和CMake进行C++开发"
description: "基于VSCode和CMake进行C++开发"
keywords: "基于VSCode和CMake进行C++开发"

date: 2023-06-13T08:59:36+08:00
lastmod: 2023-06-13T08:59:36+08:00

categories:
  - 学习笔记
tags:
  - VSCode
  - CMake


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
#url: "基于vscode和cmake进行c++开发.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>:smile:基于VSCode和CMake进行C++开发

<!--more-->

## Linux介绍

linux中一切皆文件

### 目录结构

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306130908295.png" alt="image-20230613090835235" style="zoom:50%;" />

1. bin，含义是二进制，里面的文件都是可以被运行的，
2. dev，存放的都是外接设备，例如光盘，到这个目录之后不能直接使用，需要挂载到某个目录中才能正常使用
3. etc，存放系统配置文件
4. home，除了root用户之外其他用户的家目录
5. proc，存储linux运行时的一些进程
6. root，root用户自己的家目录
7. sbin，存放一些可被执行的二进制文件，执行需要管理员权限
8. tmp，存放临时文件
9. usr，存放用户自己安装的软件
10. var，存放系统或者程序的日志文件
11. mnt，添加外部设备时，将外部设备挂载到mnt目录下指定的文件夹下

## 开发环境

### 安装GCC,GDB

```bash
sudo yum update#更新软件包管理工具
#sudo是为了使用root权限
sudo yum -y install gdb	#调试程序的工具
yum -y install gcc-c++	#调用c++编译器的工具
yum -y install gcc		#调用c编译器的工具
#安装完成之后可以使用gcc --version查看gcc的版本号
```

### 安装CMake

```bash
yum -y install cmake#安装cmake
cmake --version	#查看版本
```

## GCC

对cpp文件进行编译，不再是使用IDE直接一键运行，而是使用命令控制cpp文件到最终的可执行文件的过程，并了解编译过程中发生了什么

### 编译过程

1. **预处理**，会将头文件的包含，宏定义以及内联函数展开，生成一个`.i`文件

   ```bash
   #-E参数指示编译器对输入文件进行预处理
   g++ -E test.cpp -o test.i
   ```

   对test.cpp文件进行预处理，生成test.i文件

2. **编译**  生成`.s`文件

   ```bash
   #-S参数指示g++在产生了汇编语言文件之后停止编译
   #产生的文件默认扩展名是.s
   g++ -S test.i -o test.s
   ```

   将预处理的test.i文件编译成test.s文件

3. **汇编 **  生成`.o`文件

   ```bash
   #-c参数指示g++将源代码汇编成机器语言的目标代码，c是小写
   #产生的文件默认扩展名是.o
   g++ -c test.s -o test.o
   ```

   将编译产生的test.s文件汇编成test.o

4. **链接**  生成`.out`文件

   ```bash
   #-o参数指示g++指定文件的名称
   g++ test.o -o test
   ```

   这一步会生成可执行文件

> 正常的编译过程只需要最后一步，可以直接将被cpp文件编译成可执行文件
>
> 编译指令：`g++ [-g] test.cpp -o test `，加上-g参数之后使得test可执行文件可以被调试
>
> 直接和运行脚本一样运行即可

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306131029047.png" alt="image-20230613102933989" style="zoom:50%;" />

按照详细的四步进行编译时，会生成test.i，test.s，test.o，test文件，可以使用vim查看内部文件

test.i将头文件进行了展开

test.s生成了汇编语言的代码

test.o生成了机器语言

test是可执行文件

按照**四步**生成的文件和**一步**生成的可执行文件大小一样

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306131043820.png" alt="image-20230613104344758" style="zoom:50%;" />

### 编译参数

1. `-g` 编译带调试信息的可执行文件

   ```bash
   #产生带调试信息的可执行文件test
   g++ -g test.cpp -o test
   ```

2. `-O[n]` 优化源代码

   ```bash
   #让系统对代码进行优化，去除从未使用的变量等冗余操作
   #-O1 默认优化
   #-O2 默认优化之后还会进行指令的调整
   #-O3 循环展开和其他一些优化工作
   #一般使用-O2就足够了
   g++ test.cpp -O2 -o test
   ```

3. -l和-L  指定库文件和库文件路径

   ```bash
   #链接，mytest库，并指定库文件
   g++ -L/home/zzzi/mytestlib -lmytest test.cpp -o test
   ```

4. -I  指定头文件 的搜索目录

   ```bash
   #如果自定义了头文件，那么就需要指定头文件的搜索目录
   g++ -I/home/zzzi/myinclude test.cpp -o test
   ```

5. -o  指定输出的可执行文件的名称，不加的话默认输出a.out

   ```bash
   #指定输出的可执行文件名称为test
   g++ test.cpp -o test
   ```

### 实战

实现一个分文件的c++文件运行，头文件是在include目录下的swap.h，源文件是src目录下的swap.cpp文件，主函数是当前目录下的main.cpp

`swap.cpp`文件如下：

```c++
#include"swap.h"
void swap(int &a,int &b)
{
        int temp=a;
        a=b;
        b=temp;
}
```

`swp.h`文件如下：

```c++
#include<iostream>
using namespace std;

void swap(int &a,int &b);
```

`main.cpp`文件如下：

```c++
#include<iostream>
#include"swap.h"

using namespace std;

int main()
{
        int a=10;
        int b=20;
        cout<<"交换之前："<<endl;
        cout<<a<<"     "<<b<<endl;

        cout<<"交换之后："<<endl;
        swap(a,b);
        cout<<a<<"     "<<b<<endl;
        return 0;
}
```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306131222616.png" alt="image-20230613122202570" style="zoom:50%;" />

> 编译方式一共有**三种**

1. 直接编译

   ```bash
   #直接编译main.cpp和src目录下的swap.cpp，之后指定库文件路径
   #main文件运行时会调用inlucde目录下的swap.h，swap.h文件会调用src目录下的swap文件
   g++ main.cpp src/swap.cpp -Iinclude -o normal_main
   #此时生成一个a.out文件，可以直接执行，执行结果为：
   #交换之前：
   #10     20
   #交换之后：
   #20     10
   ```

2. 静态链接，在src目录下进行两步静态链接，之后再执行main.cpp文件

   ```bash
   #将src目录下的swap.cpp文件编译成静态库文件
   
   #第一步，在src下将swap.cpp编译成swap.o目标文件
   g++ -c -I../include swap.cpp -o swap.o
   
   #第二步，在src下将swap.o目标文件编译成静态库文件
   ar rs libswap.a swap.o
   
   #第三步，生成可执行的static_main文件
   #-I指定头文件搜索目录，-L指定库文件路径，-l指定库文件，-o指定可执行文件名
   g++ main.cpp -Iinclude -Lsrc -lswap -o static_main
   ```

3. 动态链接

   ```bash
   #将src目录下的swap.cpp文件编译成动态库文件
   
   #第一步，在src下将swap.cpp编译成swap.o目标文件
   #-I../include代表头文件目录
   #-fPIC代表与路径无关，因为是动态链接，所以可能被加载到内存的任意地址
   g++ -c -I../include -fPIC swap.cpp  -o swap.o
   
   #第二步，在src下将swap.o目标文件编译成动态库文件
   g++ -shared swap.o -o libswao.so
   
   #第三步，生成可执行的dynamic_main文件
   #-I指定头文件搜索目录，-L指定库文件路径，-l指定库文件，-o指定可执行文件名
   g++ main.cpp -Iinclude -Lsrc -lswap -o dynamic_main
   ```

> 执行两个文件

```bash

#执行static_main，直接执行即可
./static_main

#执行dynamic_main，这里有所区别，需要加上动态链接的地址
LD_LIBRARY_PATH=src ./dynamic_main
```

>静态链接和动态链接的**区别**
>
>静态链接：在生成可执行文件之前完成所有链接操作
>
>动态链接：程序执行时才进行链接，所以需要加上位置无关参数-fPIC，这样才可以在任意地方进行动态链接，执行时需要加上**链接库的地址**才能动态链接上

最终形成的文件树结构如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306131309305.png" alt="image-20230613130736072" style="zoom:50%;" />

## GDB

了解了cpp文件到可执行文件的过程之后，需要进一步了解程序的调试流程，使用GDB可以用来跟踪程序的运行过程，从而清楚的知道错误产生的地点

VSCode底层也是调用GDB来实现对C++文件的调试工作

`gdb [需要调试的可执行文件名]`就可以进入GDB调试程序

> 前提是生成的可执行文件加上了-g参数才可以被调试
>
> 例如：g++ -g main.cpp -o main，此时main文件**才**可以被调试

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132034405.png" alt="image-20230613203411308" style="zoom:50%;" />

### 编译参数

GDB在使用时需要搭配参数来控制程序的运行

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

### 实战

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
   g++ -g debug.cpp -o debug
   ```

2. 进入gdb调试界面

   ```bash
   gdb debug_with_g
   ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132039097.png" alt="image-20230613203910026" style="zoom:50%;" />

   此时可以正常调试

3. 调试程序
   - display设置想要跟踪的变量
   - continue继续执行
   - list显示断点上下五行的代码

​	一个完整的调试步骤为：

```bash
gdb debug_with_g#调试debug_with_g	
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

## VSCode

> 使用xshell无法直接使用vscode连接centos，所以需要在windows下使用vscode远程连接centos，连接完成之后即可对centos中的文件进行操作

### 连接centos

此种方法不需要centos有vscode，只需要远程登录centos即可

- [使用vscode远程连接centos](https://www.cnblogs.com/zys2019/p/14810286.html)

- [设置免密登录](https://blog.csdn.net/qq_40477290/article/details/120260225)

- 出现以连接字样说明远程连接成功

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132301238.png" alt="image-20230613230125180" style="zoom:50%;" />

- 打开文件夹，直接输入路径即可

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132250802.png" alt="image-20230613225015733" style="zoom:50%;" />

- 对文件进行编辑

  <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306132307653.png" alt="image-20230613230722513" style="zoom: 33%;" />

  打开vscode可以看到主要分为以上几个部分，也可以打开linux中的**终端**进行常规linux操作

  > 此时可以在终端中使用code+路径在vscode中打开某一个文件夹进行开发

- **c++开发**还需要**配置环境**，具体的配置放在插件安装中介绍

### 插件安装

使用vscode在linux下进行开发，一下三款插件必须安装：

1. C/C++  开发时可以智能提示，并且可以调用GDB进行调试

2. CMake  编写CMake语言时进行智能提示

3. CMake Tools

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306140941741.png" alt="image-20230614094112544" style="zoom: 33%;" />

   > 插件使用出问题时可以尝试将插件版本降低

### 快捷键

列举vscode常用快捷键

| 功能         | 快捷键         | 功能              | 快捷键              |
| ------------ | -------------- | ----------------- | ------------------- |
| 转到文件     | `ctrl+p`       | 关闭文件          | `ctrl+w`            |
| 打开命令面板 | `ctrl+shift+p` | 当前行上移/下移   | `atl+up/down`       |
| 打开终端     | `ctrl+tab`     | 向上/向下复制一行 | `shift+alt+up/down` |
| 关闭侧边栏   | `ctrl+b`       | 转到定义          | `f12`               |
| 代码格式化   | `alt+w`        | 变量统一重命名    | `f2`                |

### 实战

#### hello

编写hello.cpp文件之后，不像windows下可以直接运行，linux下需要编译生成可执行文件才可运行

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306140951863.png" alt="image-20230614095110813" style="zoom:50%;" />

#### swap

实现一个**分文件**编写的项目，并进行编译生成可执行文件，编译的过程参考**GCC实战**中的编译

1. 编写好swap.h和swap.cpp文件实现对两个数的交换

2. 交换类写好之后编写main.cpp实现两个数的交换

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306141014834.png" alt="image-20230614101442728" style="zoom:33%;" />

3. 编译工程，不需要配置`.vscode`文件夹，直接使用`GCC`进行编译

   - 直接编译

     ```bash
     g++ main.cpp src/swap.cpp -Iinclude -o main_normal
     ```

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306141018507.png" alt="image-20230614101804456" style="zoom:50%;" />

   - 静态编译

     ```bash
     #将src目录下的swap.cpp文件编译成静态库文件
     
     #第一步，在src下将swap.cpp编译成swap.o目标文件
     g++ -c -I../include swap.cpp -o swap.o
     
     #第二步，在src下将swap.o目标文件编译成静态库文件
     ar rs libswap.a swap.o
     
     #第三步，生成可执行的main_static文件
     #-I指定头文件搜索目录，-L指定库文件路径，-l指定库文件，-o指定可执行文件名
     g++ main.cpp -Iinclude -Lsrc -lswap -o main_static
     
     #第四步，运行
     ./main_static
     ```

     <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306141027207.png" alt="image-20230614102739145" style="zoom:50%;" />

   - 动态编译

     ```bash
     #将src目录下的swap.cpp文件编译成动态库文件
     
     #第一步，在src下将swap.cpp编译成swap.o目标文件
     #-I../include代表头文件目录
     #-fPIC是位置无关编码，代表与路径无关
     #因为是动态链接，所以可能被加载到内存的任意地址
     g++ -c -I../include -fPIC swap.cpp  -o swap.o
     
     #第二步，在src下将swap.o目标文件编译成静态库文件
     g++ -shared swap.o -o libswao.so
     
     #第三步，生成可执行的main_dynamic文件
     #-I指定头文件搜索目录，-L指定库文件路径，-l指定库文件，-o指定可执行文件名
     g++ main.cpp -Iinclude -Lsrc -lswap -o main_dynamic
     
     #第四步，运行，这里有所区别，需要加上动态链接的地址
     LD_LIBRARY_PATH=src ./main_dynamic
     ```

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306141033177.png" style="zoom:50%;" />

> 最终形成的文件树为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306141036527.png" alt="image-20230614103618470" style="zoom:50%;" />

## CMake

### 介绍

 `cmake`是一个**跨平台**的安装编译工具，可以用简单的语句描述所有平台的编译过程

> 基本语法

基本语法格式：指令(参数1 参数2)

- 参数使用括号包含
- 参数之间使用空格或者分号隔开
- 指令**不区分**大小写
- 参数和变量**区分**大小写
- 变量使用`${}`取值，和shell编程一样，if语句中直接使用变量名取值

```cmake
set(HELLO hello.cpp)
add_executable(hello main.cpp hello.cpp)
ADD_EXECUTABLE(hello main.cpp ${HELLO})
```

### 指令和变量

#### 重要指令

1. `cmake_minimum_required`：指定cmake的最小版本要求

   ```cmake
   #指定最小版本为2.8.3
   cmake_minimum_required(VERSION 2.8.3)
   ```

2. `project`：定义工程名称，并且可以指定工程支持的语言

   ```cmake
   #指定工程名为HELLOWORLD
   project(HELLOWORLD [CXX][C])#后面的[]是可选项
   ```

3. `set`：显示的定义变量

   ```cmake
   #定义SRC变量的值为hello.cpp，main.cpp
   set(SRC hello.cpp main.cpp)
   ```

4. `include_directories`：添加工程编译时的头文件搜索路径

   ```cmake
   #将/usr/include/myfolder和./include两个路径加入工程的头文件搜索路径
   #头文件在这两个目录下查找
   include_directories(/usr/include/myfolder ./include)
   ```

5. `link_directories`：添加工程链接时的库文件搜索路径

   ```cmake
   #将/usr/lib/mylib 和./lib添加到工程的库文件搜索路径
   link_directories(/usr/lib/mylib  ./lib)
   ```

> 库文件和头文件的区别：库文件**链接**时使用，无法直接阅读，头文件**编译**时使用，可以直接阅读

6. `add_library`：生成动态链接库文件

   ```cmake
   #通过SRC路径生成一个libhello.so的动态链接库文件
   #SHARED表示动态链接，STATIC表示静态链接，hello是最后生成的库文件名称
   add_library(hello SHARED ${SRC})
   ```

7. `add_compile_options`：添加编译参数

   ```cmake
   #编译时产生警告信息，指定std版本，并对代码进行优化(-o2)
   add_compile_options(-wall -std=c++11 -o2)
   ```

8. `add_executable`：生成可执行文件

   ```cmake
   #编译main.cpp文件生成可执行的main文件
   ad_executable(main main.cpp)
   ```

9. `target_link_libraries`：为target添加需要链接的共享库，相当于-l参数

   ```cmake
   #将hello动态库文件连接到可执行文件main上
   target_link_libraries(main hello)
   ```

10. `add_subdirectory`：给工程添加存放源文件的子目录

    ```cmake
    #添加src子目录，src下面需要有CMakeLists.txt文件
    add_subdirectory(src)
    ```

11. `aux_source_directory`：将一个目录中的所有源文件存储在一个变量中，被用来临时构建源文件列表

    ```cmake
    #定义SRC变量，存放当前目录下的所有源文件，SRC指代当前目录下的所有源文件
    aux_source_directory(./ SRC)
    #编译SRC代表的全部源文件，这样就不用依次一个一个的编译源文件了
    #编译之后生成一个main可执行文件
    aux_source_directory(main ${SRC})
    ```

#### 常用变量

1. `CMAKE_C_FLAGS`：gcc编译选项

2. `CMAKE_CXX_FLAGS`：g++编译选项

   ```cmake
   #在CMAKE_CXX_FLAGS编译选项之后追加一个-std=c++11，并重新赋值给CMAKE_CXX_FLAGS
   set(CMAKE_CXX_FLAGS "CMAKE_CXX_FLAGS -std=c++11")
   ```

3. `CMAKE_BUILD_TYPE`：编译类型(debug,release)

   ```cmake
   #设定编译类型为debug，调试时需要选择debug
   set(CMAKE_BUILD_TYPE Debug)
   #设定编译类型为release，发布时需要选择release
   set(CMAKE_BUILD_TYPE Release)
   ```

4. `CMAKE_C_COMPILER`：指定C编译器
5. `CMAKE_CXX_COMPILER`：指定C++编译器
6. `EXECUTABLE_OUTPUT_PATH`：可执行文件输出的存放路径
7. `LIBRARY_OUTPUT_PATH`：库文件输出的存放路径

> 如果需要对项目尽进行有条件的编译时，需要用到if-else语句

### 编译工程

两种方式设置编译规则：

1. 包含源文件的子文件夹**包含**CMakeLists.txt文件，主目录的CMakeLists.txt通过add_subdirectory 添加子目录即可

   > 包含源文件的子文件夹自己写编译规则，在主文件下只需要简单添加子目录即可

2. 包含源文件的子文件夹**未包含**CMakeLists.txt文件，子目录编译规则体现在主目录的 CMakeLists.txt中；

   >包含源文件的子文件夹编译规则不自己写，全部交给主文件编写

> 对于每一个包含源文件的目录都可以编写一个CMakeLists.txt，最后在主文件中包含它们
>
> 编译主文件中的CMakeLists.txt就可以对**整个**工程进行编译

#### 编译过程

1. 自定义`CMakeLists.txt`文件，使用前面介绍的语法制定编译规则
2. 执行`cmake PATH`命令产生MakeFile(PATH是**主文件**下的CMakeLists.txt所在的路径)
3. 按照生成的MakeFile中规则执行`make`命令进行编译cpp文件，最终生成可执行文件

#### 构建方式

1. 内部构建：直接在当前目录下编译CMakeLists.txt文件生成MakeFile文件，这些所有的文件都会存放到当前目录下，变得臃肿

2. <font color=red>外部构建</font>：新建一个`build`文件夹，之后在这个build文件夹中译CMakeLists.txt文件生成MakeFile文件，这些所有文件都会存放到build文件夹中，使得项目变得清爽

   > 一个是将MakeFile**散落**放在当前目录下，一个是将MakeFile**打包**放在专门的build目录下

### 实战

基于hello和swap项目来进行实战，编写CMakeLists.txt文件，使用cmake PATH 生成MakeFile文件，最终使用make进行编译

最终的实现效果与执行g++命令是一样的

#### hello

单文件的项目直接编写CMakeLists.txt

1. 编写CMakeLists.txt

   ```bash
   #指定cmake的最小版本
   cmake_minimum_required(VERSION 2.8)
   #执行项目名称
   project(HELLOWORLD)
   #多文件项目指定头文件搜索路径
   #include_directories(./include)
   #编译指定的cpp文件
   add_executable(helloworld_cmake hello.cpp)
   ```

2. 生成MakeFile文件，使用外部构建方式，将生成的中间文件全部放到`build`文件夹中

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306172039385.png" alt="image-20230617203808540" style="zoom:33%;" />

2. 执行`make`命令生成可执行文件

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306172039366.png" alt="image-20230617203844171" style="zoom:33%;" />

#### swap

多文件的项目需要指定头文件的搜索路径，其余的步骤与hello项目中一样，指定项目名称，编译cpp文件生成可执行文件即可

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306172054853.png" alt="image-20230617205307343" style="zoom:50%;" />

## 实战

编写一个多文件的项目进行编译，项目的结构为：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306172132676.png" alt="image-20230617213212607" style="zoom:50%;" />

1. 直接编译

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306172136423.png" alt="image-20230617213628358" style="zoom:43%;" />

2. 使用CMakeLists.txt文件编译

   ```CMAKE
   cmake_minimum_required(VERSION 2.8)
   
   project(TEST)
   #添加编译参数，-g是为了生成可以调试的文件
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -g")
   
   include_directories(${CMAKE_SOURCE_DIR}/include)
   #设置变量
   set(
       SRC
       main.cpp
       src/gun.cpp
       src/soldier.cpp
   )
   add_executable(main_cmake ${SRC})
   ```

   最终形成的文件树为

```bash
[root@iZ0jl2zspvl2lcwsxfru86Z vscode_test]# tree .
.
├── build
│   ├── CMakeCache.txt
│   ├── CMakeFiles
│   │   ├── 2.8.12.2
│   │   │   ├── CMakeCCompiler.cmake
│   │   │   ├── CMakeCXXCompiler.cmake
│   │   │   ├── CMakeDetermineCompilerABI_C.bin
│   │   │   ├── CMakeDetermineCompilerABI_CXX.bin
│   │   │   ├── CMakeSystem.cmake
│   │   │   ├── CompilerIdC
│   │   │   │   ├── a.out
│   │   │   │   └── CMakeCCompilerId.c
│   │   │   └── CompilerIdCXX
│   │   │       ├── a.out
│   │   │       └── CMakeCXXCompilerId.cpp
│   │   ├── cmake.check_cache
│   │   ├── CMakeDirectoryInformation.cmake
│   │   ├── CMakeOutput.log
│   │   ├── CMakeTmp
│   │   ├── main_cmake.dir
│   │   │   ├── build.make
│   │   │   ├── cmake_clean.cmake
│   │   │   ├── CXX.includecache
│   │   │   ├── DependInfo.cmake
│   │   │   ├── depend.internal
│   │   │   ├── depend.make
│   │   │   ├── flags.make
│   │   │   ├── link.txt
│   │   │   ├── main.cpp.o
│   │   │   ├── progress.make
│   │   │   └── src
│   │   │       ├── gun.cpp.o
│   │   │       └── soldier.cpp.o
│   │   ├── Makefile2
│   │   ├── Makefile.cmake
│   │   ├── progress.marks
│   │   └── TargetDirectories.txt
│   ├── cmake_install.cmake
│   ├── main_cmake
│   └── Makefile
├── CMakeLists.txt
├── include
│   ├── gun.h
│   └── soldier.h
├── main.cpp
├── main_normal
└── src
    ├── gun.cpp
    └── soldier.cpp

10 directories, 39 files
```

3. 使用vscode进行调试

需要配置`launch.json`和`tasks.json`文件，其中launch.json文件中最重要的两个参数是program和preLaunchTask

其中`program`指向了想要调试和运行的可执行文件，一般存放在./build文件夹下

`preLaunchTask`指向了tasks.json文件中的某一个任务，在launch.json文件执行之前执行什么任务，一般设置一个cmake和make对项目进行重新编译，这样可以实时的进行调试，不用每次都手动编译

提供一个tasks.json供参考：

```json
{   
    "version": "2.0.0",
    "options": {
        "cwd": "${workspaceFolder}/build"
    },
    "tasks": [
        {
            "type": "shell",
            "label": "cmake",
            "command": "cmake",
            //相当于执行cmake..  对cpp文件编译生成MakeFile文件
            "args": [
                ".."
            ]
        },
        {
            "label": "make",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "command": "make",
            "args": [

            ]
        },
        {
            "label": "Build",
			"dependsOrder": "sequence", // 按列出的顺序执行任务依赖项
            //先进行cmake..在进行make，相当于写了一个自动化脚本
            "dependsOn":[
                "cmake",
                "make"
            ]
        }
    ]

}
```

配置好这两个文件之后，每次调试运行都会自动执行`cmake..`和`make`命令对项目进行重新编译，从而实时的对项目进行调试运行

## 总结

在linux中安装GCC和GDB之后就可以在linux中编写c++项目，对其运行和调试，其中GCC负责项目的**编译运行**，可以使用`g++`命令将cpp文件编译成可执行文件，GDB可以对项目进行**调试**

CMake可以编写编译的规则，将大型项目编译的管理**集成**到一个CMakeLists.txt文件中，实现自动化的编译

vscode中远程连接到linux中之后，可以直接用快捷键对其进行编译和调试，主要是需要配置launch.json和tasks.json文件，并且知道他们两个之间的关系，配置好后每次都实时的重新编译运行项目从而实现**直接**对项目进行调试
