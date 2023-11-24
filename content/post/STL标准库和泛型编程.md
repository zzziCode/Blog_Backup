---
title: "STL标准库和泛型编程"
description: "STL标准库和泛型编程"
keywords: "STL标准库和泛型编程"

date: 2023-05-31T18:07:27+08:00
lastmod: 2023-05-31T18:07:27+08:00

categories:
  - 学习笔记
tags:
  - STL
  - 泛型编程
# 可选配置
# 原文作者
# Post's origin author name
author: zzzi
# 关闭文章目录功能
# Disable table of content
toc: true
# 开启数学公式渲染，可选值： mathjax, katex
# Support Math Formulas render, options: mathjax, katex
#math: mathjax


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
#url: "stl标准库和泛型编程.html"
# 开启文章置顶，数字越小越靠前
# Sticky post set-top in home page and the smaller nubmer will more forward.
#weight: 1

# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

> :no_mouth:STL标准库和泛型编程

STL标准库和泛型编程的学习笔记，记录了STL中六大部件之间的关系和部件的实现细节，以及泛型编程的相关知识，逻辑稍微有点乱，后期再修改

<!--more-->

## 引言

STL六大部件分别是：容器、算法、迭代器、仿函数、适配器、分配器

其中容器、算法、迭代器是最基本的，迭代器是算法和容器之间的桥梁

仿函数就是一个重载了()的类，使用该类生成的对象调用()方法，看起来就像函数调用，所以称为仿函数，仿函数主要与算法配合使用，作为参数传递，解锁算法高级用法

适配器可以作用在容器上，改造容器形成容器适配器。作用在仿函数上就形成了仿函数适配器，但是这个放仿函数必须[继承](https://blog.csdn.net/zishuijing_dd/article/details/109299497)一元或者二元谓词。作用在迭代器上就形成了迭代器适配器

适配器的作用就是对STL的基础部件进行改造，使其更加符合自己的需求

最后的分配器就是服务于容器，每个容器底层的内存分配就是分配器负责

六大部件具体的关系如下：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306121237943.png" alt="在这里插入图片描述" style="zoom: 75%;" />

## 第一部分

相当于一个基本的介绍，介绍容器的使用

### 容器测试

**总结**：在泛型编程中，支持随机访问的容器不需要自定义sort，但是STL中的sort需要容器支持随机访问，所以不支持随机访问的迭代器需要自定义sort

#### vector

vector**自身不存在**sort函数， 需要使用c标准库中的qsort

因为vector可以随机访问，所以根据泛型编程的思想，需要将算法分离来，

也就是自身不存在sort

并且vector扩充空间时扩充的很多，如果没有用到就会造成内存浪费

#### list

list是一个双向链表，头部和尾部都可以操作，扩充内存时是**一个一个**扩充，使用指针进行连接

并且list容器**自带**sort函数

因为list不支持随机访问，所以无法使用STL中的sort，所以需要单独定义sort排序算法

#### forward_list

前向链表只可以在头部进行操作，并且没有size函数，只有max_size函数

容器**自带**sort函数

#### deque

双端队列可以在两端进行操作，相当于连续版的双向链表，并且扩充内存时是**一块一块**扩充，也就是外部看起来像是连续空间，但是内部并不是连续的，而是多个连续的小内存块组成deque的空间

容器**自身不带s**ort函数

##### stack

stack默认是将deque进行改造形成的容器适配器，但是也可以指定使用其他容器改造

可以实现后进先出操作，具体的改造就是封闭push_front和pop_front函数，使其只能在deque尾部操作，实现后进先出的效果

底层并没有自己的数据结构实现，而是借用了其他的容器，所以称为容器适配器

不支持随机访问，没有迭代器

```c++
stack<string> s1;//默认底层使用deque实现
stack<string, list<string>> s2;//底层指定使用list实现
stack<string, vector<string>> s3;//底层指定使用vector实现
stack<string, set<string>> s4;//底层指定使用set实现
```

##### queue

queue底层默认使用deque进行改造，但是也可以指定其他的容器进行改造

改造之后实现了容器的先进先出，也就是头部只可以出队，尾部只可以入队

底层并没有自己的数据结构实现，而是借用了其他的容器，所以称为容器适配器

不支持随机访问，没有迭代器

```c++
queue<string> q1;//默认底层使用deque实现
queue<string, list<string>> s2;//底层指定使用list实现
queue<string, vector<string>> s3;//底层指定使用vector实现
queue<string, set<string>> s4;//底层指定使用set实现
```

#### multi_set

关联式容器，底层使用红黑树实现，并且可以存放相同的元素，元素存入时会进行排序

插入元素不使用push，而是使用insert，插入元素时会找到元素对应的位置，使其有序

顺序容器和关联容器区别就是在插入和查找上，顺序容器的插入相对很快，查找相对很慢

关联容器的插入相对很慢，但是查找相对很快

#### multi_map

关联式容器map，容器中的元素是一个对组pair，键值对，multi_map的key可以重复，但是map的key不允许重复

插入时，multi_map不允许使用重载运算符[]进行插入，因为根据一个key可能找到多个对组，不知道对那个对组进行操作，会造成歧义，但是map就可以使用[]

#### unordered_multiset

使用哈希表做实现，元素无序

哈希表使用链地址法解决冲突

#### unordered_multimap

就是存储一些无序的key_value对组，并且使用**哈希表**进行管理

插入时需要注意的与multimap一样，不可以使用重载运算符[]操作元素，因为multimap可以允许重复的key，所以使用[]可能找到多个对组，会出现歧义

#### set

重复的元素无法插入，自带find函数

#### map

重复的key所对应的对组无法插入，并且可以使用重载运算符[]操作对组，因为重复的key无法插入

所以使用[]操作对组是唯一的，不会产生歧义，但是如果map中不存在以key为键的对组，就会创建一个新的对组，例如：

```c++
map<string, string> m1;
//  修改关键码为LiXing的值
//  注意，这里的关键码在map里面并不存在，所以会创建一个新的对组
if (m1[" LiXing "] == " 13913131313 ")
{
    m1[" LiXing "] = " 13513131313 ";
}
//  输出
cout << " The cellhone number of LiXing is:  " << m1[" LiXing "] << endl;
```

由于不存在以Lixing为key的对组，所以会创建一个对组

新的对组`key="Lixing"`，`value=""`，因为string的默认值为""

#### unordered_set

不可以存放相同的元素，元素不有序

#### unordered_map

不可以存放相同的元素，元素不有序

### 分配器测试

容器的背后需要分配器（allocator）的支持来实现内存的使用

分配器在定义容器时，第二个参数就可以指定分配器

每一次push_back都会使用分配器

分配器也可以单独使用，不搭配容器

```c++
int* p;
allocator<int> alloc1;
p = alloc1.allocate(1);//分配空间
alloc1.deallocate(p, 1);//归还空间，并且需要记住归还几个单元
```

分配器分配一个单元，那么最后归还就需要归还一个单元

相比于new搭配delete，malloc搭配free来说，分配器单独使用并不好用

## 第二部分

相当与更加详细的介绍，介绍容器底层的实现，迭代器是如何工作，以及适配器是如何工作

每个容器都有自己的迭代器，但是由于性质不同，所以迭代器的操作也不同，这也造成了迭代器的定义不同，但是都有五个属性，有萃取器提供这五个属性，有了迭代器和容器以及适配器，就可以对容器和适配器操作了，具体的操作称为函数，在第三部分

所有的容器都有一个迭代器，迭代器返回容器的五个属性，算法获取这五个属性操作容器，对于迭代器来说，分为类类型的迭代器和指针类型的迭代器，为了返回五个属性，同时兼容指针迭代器的情况，提供了一个萃取器，不论迭代器是什么类型，都可以返回五个属性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261510972.png" alt="image-20230526151026897" style="zoom: 67%;" />

### 泛型编程

泛型编程与面对对象编程的区别：

**泛型编程**将对象与算法分离开，对于容器来说，也就是将容器与算法分离开，中间使用迭代器联系

这样可以减少代码量，一次定义多次使用，如果将算法全部定义到容器内部时，容器的代码就会变得很庞大，并且冗余度很高，部分容器中的算法完全一样，所以没必要重复编写，这也是算法和容器分开的一个原因

**面对对象编程**变成是将对象与算法全部封装到类内

**函数模板**调用时可以不指定类型，编译器自动推导，也可以使用显式指定

```c++
template<class T>//告诉编译器T是一个通用的数据类型，
//使用通用数据类型创建交换函数
void Myswap(T& a, T& b)
{
	T temp = a;
	a = b;
	b = temp;
}
int main()
{
	int a = 1;
	int b = 2;
	char c = 'c';
	//利用函数模板交换数据
	//第一种方式：自动推导
	Myswap(a, b);//自动推导时，T推导的参数必须一致才可以使用函数模板
	cout << "a=" << a << endl;
	cout << "b=" << b << endl;
//第二种方式：显示指定类型，告诉编译器传入的数据是什么类型,这个时候相当于一个普通函数，可以发生隐式类型转换
	Myswap<int>(a, c);
	cout << "a=" << a << endl;
	cout << "b=" << b << endl;
	return 0;
}
```

**类模板**调用**必须**指定类型，类模板主要是类中的成员使用模板

```c++
template<class NameType,class AgeType>
class Person
{
public:
	NameType Name;
	AgeType Age;
	Person(NameType name,AgeType age)
	{
		this->Name = name;
		this->Age = age;
	}
	void Show()
	{
		cout << "name:" << this->Name << endl;
		cout << "age:" << this->Age << endl;
		return;
	}
};

void test1()
{
	//使用书写的类模板创建类对象，必须指定类型
	Person<string, int> p1("张三", 10);
	Person<string, int> p2("李四", 20);
	p1.Show();
	p2.Show();
}
```

类模板的泛化和特化：

也就是将模板参数进行指定，全部指定叫做全特化，部分指定叫做偏特化

### 分配器

#### malloc的缺点

malloc要求分配内存的大小是**size**，但是malloc不仅分配了size大小的内存块，前后还有各种调试信息，填充和cookie，增加了内存开销，也就是说，每一次malloc，都会额外使用这些内存存储不想要的信息

如果想要的空间很少，那么无用的信息所占空间比例就会很大，相当于无用开销很多

对于分配器分配内存来说，最终到了底层都会调用new，new内部调用malloc

对于分配器回收内存来说，最终到了底层都会调用delete，delete内部调用free

没有任何新东西，底层就是调用c的函数对内存进行操作

后期使用的分配器不再直接调用malloc，新的分配器叫做**alloc**，这样的好处是减少了malloc的调用，也就是减少了无用空间的开销，一个节点中的内存块是一次malloc得来的，无用信息占用的内存就会变少

链表中的节点使用malloc一次分配，所以携带的cookie很少，不像是每次都是用malloc，然后每次申请的内存都携带cookie，浪费很多内存

先在这16个节点的链表中找到内存块，每一个链表节点负责的内存块大小不一样，0号节点负责八字节的内存块，一号节点负责16字节的内存块，15号节点负责128字节的内存块

如果这个链表中没有想要的内存块，此时再去malloc

后期新版本也不再使用这种版本，这种版本变成了扩充的分配器，可以在使用容器中**指定分配器**的版本

### 容器之间的关系

 缩进关系表示衍生的关系，例如`stack`和`queue`底层使用`deu   qe`实现 

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305241103426.png" alt="image-20230524110330304" style="zoom:67%;" />

### 容器适配器

适配器作用在容器中形成了不同的容器适配器，例如：

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322353.png" alt="image-20230531170251172" style="zoom: 50%;" />

### List深度探索

`STL`中的`list`是一个双向链表，在尾部添加了一个**空白节点**，这样就能符合`end()`指向空的特点，分配内存时，不止分配自身元素所占的内存，还会分配指针域的内存

 链表内部使用的迭代器是经过 `typedef`的，主要有iterator，const_iterator，const_reverse_iterator，reverse_iterator，不同的迭代器有不同用法，迭代器的实现在容器的内部

list的定义如下: 

```c++
template<typename _Tp, typename _Alloc = std::allocator<_Tp> >
    class list : protected _List_base<_Tp, _Alloc>
```

使用了函数模板，所以使用list时必须指定类型，不能自动推导，并且list的迭代器`iterator`是一个类

```c++
typedef _List_iterator<_Tp>			 iterator;
```

传递进来的_Tp会用来命名三个参数，为了模拟指针的行为，内部实现了大量的运算符重载，运算符重载时是对里面的node指针进行操作，但是返回值是整个iterator

```
typedef _Tp				value_type;
typedef _Tp*				pointer;
typedef _Tp&				reference;
```

### vector深度探索

vector可以理解为一个动态扩充内存的数组，正常的数组定义完成之后无法扩充内存，因为他是连续空间，无法知道数组最后的空间是否被使用

vector之所以可以动态扩充是因为它可以重新申请一块连续的内存空间，新空间的大小是原空间的两倍，也就是二倍增长

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261311423.png" alt="image-20230526131154331" style="zoom:50%;" />

#### 基本属性

size是vector中实际元素的个数，capacity是vector的最大容量  

使用三个迭代器就可以得到容器的各种属性

```
iterator start//容器第一个元素的位置
iterator finish//容器最后一个元素的下一的位置
iterator end_of_storage//容器所占空间的最后一个位置
```

size属性可以通过finish-start获得

capacity属性可以通过end_of_storage-start获得

empty属性可以通过finish==start获得

[n]运算符重载可以通过start+n获得

front可以通过start获得

back可以通过finish-1获得

。。。。

#### 动态增长

插入元素时判断vector是否有剩余空间，如果没有的话就调用扩充空间的函数进行动态增长，

扩充空间的函数首先需要判断是否还有剩余空间，没有备用空间就会进行增长

增长时如果容器一个元素都没有，就先扩充成一个元素的空间大小，如果有空间，那么就扩充成原来的两倍，计算出需要扩充空间的大小之后，就可以使用分配器分配内存，之后将原有元素移动过来，形成新的vector

扩充的过程中，会调用拷贝构造函数复制原来的元素到新的内存中，并且原有空间的元素需要调用析构函数删除

获取五个属性使用迭代器，迭代器又实用萃取器判断迭代器的类型是类还是指针，从而间接获得五个属性

### array深度探索

容器在初始化时必须指定大小，因为他无法扩充内存，其余实现与上面类似，使用萃取器得到五个属性，返回给迭代器，外部使用迭代器就可以访问五个属性

### deque深度探索

deque对外号称连续，其实内部是分段连续的，使用vector存储每一段的指针，扩充内存时，前面不够就在前面申请一块新的连续空间，并将指向这块内存的指针加入中控器，后面不够就在后面申请一块连续的空间，并将指向这块内存的指针加入中控器,具体的中控器是由map实现的，每一个map中的节点指向一块缓存区，也就是一块连续空间

其中开始和结束迭代器有九个属性，五个是最开始介绍的其余容器也有的五个，剩下四个分别是cur、first、last、node。node指向存放所有分段的vector，node移动说明访问的分段不同，而first和last指向node所指分段的开始和接触，cur指向当前的元素

分段中的每一段称为一个缓冲区，那么deque是如何将这些分段的缓冲区联系起来，让人以为他是连续的呢

将node进行移动，就可以在不同的分段之间移动

主要是元素的移动，cur移动一次，看是不是到了当前分段的末尾，是的话就将node移动一次，切换到下一分段，之后让cur指向下一分段的first，就可以实现连续的访问，其余的访问逻辑相似，实际上是在分段的连续空间中移动

以自增和自减为例，可以清楚的看到迭代器的移动

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305261632364.png" alt="image-20230526163238262" style="zoom:67%;" />

将分段连续的空间变得看起来一致连续，主要是node的移动和cur的移动在起作用

> stack和queue底层的实现都是deque，只不过对于deque做了一定限制

所以stack和queue底层也是分段连续，只不过 node和cur的巧妙移动，使得外部看起来像是一致连续的

stack和queue的操作函数就是简单的调用deque的操作函数，并且对于deque的某些操作函数封闭，例如stack只能push_back和pop_back，queue只能push_back和pop_front

对deque进行限制就是对他的迭代器进行了限制，进行限制之后形成的东西称为容器适配器，satck和queue就是容器适配器

需要注意的是，stack和queue都不支持遍历，所以没有提供迭代器，或者说deque的迭代器他们无法使用，这是他们的数据结构特性决定的

### RBTree深度探索

#### 红黑树的底层原理

红黑树可以看作是一个平衡二叉树，但是他不是用平衡因子衡量此树是否平衡，而是使用黑色节点的数量，从任意节点出发，到达任意叶子节点的路径上，黑色节点的数量都是一样的，这是最主要的平衡性质，其余的几条性质加起来一起约束，形成了红黑树

把红黑树中所有的红色节点删除之后，剩下的黑色节点形成了一个满二叉树，是平衡的

红黑树就是一个高度平衡的二叉树，并且提供迭代器进行中序遍历，红黑树不应该修改节点的值， 否则会破坏红黑树的结构，但是在编程层面是可以修改的，因为红黑树是给set和map提供服务的，所以应该提供修改的服务

红黑树在插入时提供两种版本，第一种是不允许重复，对应set和map，第二种是允许重复，对应multiset和multimap

使用红黑树的迭代器访问得到的序列是一个有序序列，也就是说迭代器的访问是中序遍历 

当map使用红黑树实现时，使用key创建红黑树，并且key不能被修改，而value由key链接，value可以修改，相当于使用key当作节点的身份，节点内部是value

红黑树在STL中就是一个容器，但是STL中并没有提供使用方法，红黑树创建来是给关联式容器使用的，他们的底层实现就是红黑树

相当于queue、stack和deque的关系，queue、stack底层实现就是deque，只不过对deque进行了一定的修改

map和set底层实现是红黑树，也对其做了一定修改，使其符合自己的需求

![image-20230528151540239](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305281515308.png)

红黑树有五个属性，第一个属性是key，第二个属性是value，是key和data合成在一起形成的树，第三个属性是keyofvalue，告诉用户如何从value中取出data，之后是一个比较函数

有了这些属性才能更好的操作红黑树

### set深度探索

set底层就是使用了红黑树，如果使用insert_unique插入元素，形成的就是set，如果使用insert_equal插入元素，那么形成的就是multiset，也就是从是否可以存储相同元素区分

对于set来说，不允许更改元素，因为set只存储一个元素，相当于key就是value，那么在底层红黑树中如何限制set不能修改呢：要修改肯定需要拿到set的迭代器，红黑树提供给set的红黑树是一个const类型，所以不允许修改，这样限制之后就符合规定了

相当于红黑树套壳，set的操作底层全都调用了红黑树的操作

类似于queue和stack一样，所以set也可以理解为一个容器适配器

对于set来说，key和vaue一样，因为他没有data，所以**key直接形成了value**，keyofvalue告诉用户，直接将key拿到就是对应的data

由于红黑树插入元素时会将元素排序，所以set中的元素也是有序的

### map深度探索

map底层也使用了红黑树 ，所以插入元素时也是默认有序的，并且map有两个元素，其中key无法修改，允许修改data，那么是如何做到的呢

并且map中的key不允许重复，data允许重复

multimap中key和data都允许重复，这些是如何做到的

首先。定义map时会指定key和data的类型，底层红黑树为了实现map，将map的key作为自己的key，然后将ket和data组合在一起形成一个对组，之后作为自己的value，然后告诉用户，如何取出map的key和data，取出的第一个元素是key，返回的迭代器是一个const类型，取出的第二个元素是data，返回的是普通的迭代器，也就是说可以修改

红黑树将map的key和data组合在一起形成一个对组，取key时返回的迭代器为const，取value时返回的迭代器是一个普通类型

插入时map需要把元素包装成一个对组传毒给红黑树，红黑树将其存放在value中

由于map不允许key重复，所以允许进行下标访问，和数组一样

而multimap允许key重复，所以不能使用下标访问，不然就会造成冲突

> value是key和data的融合，map知道如何将value中的data取出来

map**插入**时的返回值是一个pair，`pair.first`返回map的迭代器，`pair.second`返回插入的状态，代表是否插入成功：

```c++
auto ret=map.insert(make_pair(1,"张三"));
//等价于
pair<map<int,string>::iterator,bool> ret=map.insert(make_pair(1,"张三"));
```

从代码中可以清晰的知道返回值是一个`pair`，并且`first`和`second`的值也很清楚

map使用下标运算符时，当元素不存在时会自动添加，所以只想查找不想添加时，就不能使用下标运算符，而是使用find函数

### set和map都可以使用RB-tree的原因

set是一个单key的容器，map是key-value形式的容器，他们为什么可以使用同一个RB-tree呢

在set和map的源码中，set将key重复了两次传递给RB-tree分别作为key_type和value_type，map将key传递给RB-tree作为key_type，然后将队组pair作为value_type传递给RB-tree，具体看图：

![img](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306201443378.png)

> RB-tree插入时，不管是单独的一个元素，还是一个复合的对组，**都**当做一个`value_type`处理

所以set和map都可以将RB-tree当成自己的底层容器

map的源码

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306201458862.png" alt="image-20230620145843789" style="zoom:50%;" />

set的源码

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306201500550.png" alt="image-20230620150036436" style="zoom:50%;" />

### hashtable深度探索

c++中 哈希表存入元素时，使用链地址法解决冲突，哈希表的好处就是可以利用闲散的空间

哈希表中有一个bucket的概念，也就是散列表的长度，当元素的个数超过了bucket的长度，系统就认为出现危险情况，此时就再哈希，扩大bucket的大小（每次扩到的容量都是一个质数，因为质数除了自己和1没有因子），所有的元素重新计算哈希地址

也就是说bucket的个数永远大于元素的个数 

与红黑树一样，哈希表中存储的元素有一个key和value，value是由key和data组合而成的，所以还需要在提供方法告诉用户如何拿到哈希表中的key和data，之后还需要给定一个比较函数，有了key之后，如何比较是否匹配，才能找到key对应的位置，因为key可能不是系统内置的类型

使用哈希表定义之时指定的哈希函数确定元素放在哪个位置，

哈希表和红黑树，deque一样，更像红黑树，都是给其他容器提供底层操作，哈希表给无序容器unordered_set（multi）和unordered_map（multi）提供底层支持，而红黑树给关联容器map和set提供底层支持

unordered_set底层的操作全部是调用hashtable的操作，因为底层是使用hashtable实现的

## 第三部分

有了上面提到的容器、适配器以及操作他们的迭代器，第三部分就介绍使用迭代器进行花式操作容器以及适配器的方法，也就是建立在容器和适配器之上的算法

 在语言的层面上，容器和适配器都是一个类模板，传入不同的参数实现不同数据的存储，而算法是一个函数模板，传入不同的容器和迭代器就对不同的容器进行处理

因为一个函数可以操作很多容器，所以传递的参数形式不同，但是定义一个函数模板，当传递不同的参数时，就会形成不同的特化版本，从而实现对容器的操作

并且有的算法还支持传入一个仿函数，这个仿函数就是重载了()运算符的类，比如排序算法需要比较大小，此时就可以传入一个仿函数作为排序算法的参数

而谓词就是返回值为bool类型的全局函数或者仿函数，所以这是他们的区别

算法看不到操作的容器，只能通过迭代器提供的权限去操作容器，也就是说，迭代器不同，所提供的权限也不同

### 迭代器的分类

由萃取器得到迭代器的种类，从而知道可以使用迭代器进行什么样的操作  

1. 输入迭代器
2. 输出迭代器
3. 前向迭代器
4. 双向迭代器
5. 随机访问迭代器

分类对于算法的影响很大，比如随机访问的迭代器在查找时可以通过二分法（前提需要有序），而不支持随机访问的迭代器只能顺序查找，如果目标元素在末尾，就需要遍历整个容器

算法内部根据迭代器的种类决定调用哪种特化版本的算法

基本步骤就是调用萃取器获得当前传入的迭代器是什么种类，之后再调用另一个函数

举例：

distance计算迭代器之间的举例，distance内部先获得迭代器的分类，之后调用一个_distance函数，增加一个迭代器分类的参数，不同的分类调用不同的 _distance函数

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322354.png" alt="image-20230529145243324" style="zoom:67%;" />

最下面的distance函数暴力给外部，用户调用此distance就可以得到举例，并不用关系内部的实现，但是内部是先调用了萃取器获得了迭代器的分类，之后再将分类信息和迭代器一起传入_distance函数，对于不同的种类会有不同的处理方式,之后distance返回 _disnatce的返回值，这样外部使用起来无感，不知道内部其实调用了其他的函数，但是不同的迭代器效率不同

所以说迭代器的分类会对算法产生很大的影响，算法必须判断出当前迭代器的种类，之后采取适合当前迭代器的最高效的操作

并且对于输出迭代器而言，他无法想普通的迭代器一样读元素，所以如果传递进来的迭代器版本是输出迭代器，那么还需要单独设计一个函数，例如单独设计一个_distance函数来对容器进行操作，这里进一步体现出容器的种类对于算法的影响

并且由于有的算法只能再特定类型的迭代器上运行，例如sort函数只能在随机访问的迭代器上操作，所以一旦传入不支持随机访问的迭代器就会出现问题，但是语法检查并不检查这个错误，所以只能尽可能避免

### 迭代器适配器

迭代器适配器对迭代器进行一系列的改造，使其符合自己的需求，最终形成了不同的迭代器适配器

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322355.png" alt="image-20230531170405521" style="zoom:50%;" />

### 各种算法

STL中的算法肯定是先接收迭代器，之后的参数可能是多个，也可能没有，有了迭代器和可能的附加参数之后对容器进行操作

```c++ 
//常用的拷贝替换算法
//copy，容器之间的拷贝，拷贝之前记得声明容器的大小
//replace，容器中指定元素替换成新元素,
//如果是自定义数据类型，需要重载运算符==，才能判断何时找到了指定需要替换的元素
//replace_if 满足条件的所有元素替换成新元素
//swap 交换两个容器中的元素

////常见的排序算法
////sort
////random——shuffle
////merge
////reverse，与容器预先申请容量的reserve不同

////常用查找算法：
////find：查找元素，返回迭代器，找不到返回end()
////find_if：按条件查找元素
////adjacent_find:查找相邻重复元素
////binary_find：二分查找
////count：统计元素个数
////count_if：按条件统计元素个数

////accumulate,将容器范围内的值相加并返回，但是需要传递一个参数用来存储累加和
////fill算法，将容器中指定范围内填充成指定元素

////常用集合算法，常见的注意事项
//// 1.两个集合必须有序
//// 2.目标容器的大小是两个集合中较小的
//// 3.集合运算结束返回的是实际元素的下一个位置的迭代器，使用这个迭代器当作遍历的尾
////set_intersection:交集
////set_union:并集
////set_difference:差集
```

由于部分容器的迭代器属性不同，所以STL算法有可能无法作用到某些容器中，但是该容器又想拥有这些功能，所以会在容器的内部定义一个与STL中同名的算法，这样也可以实现相同的功能，但是在调用时，STL中的算法相当于全局函数，直接可以调用，容器内部的同名算法需要使用对象调用，这是一个区别，例如list由于其特性就无法使用STL中的sort函数，所以他内部自己是实现了一个sort，调用时的语法也和STL中不一样

```c++
#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
#include<functional>
using namespace std;
int main()
{
    vector<int> v1 = {1, 7, 5, 9, 2, 6, 4};
    list<int> l1 = {1, 7, 5, 9, 2, 6, 4};
    //两个容器都需要sort，但是调用sort函数的方式不同
    //vector调用STL中的sort
    sort(v1.begin(), v1.end(),greater<int>());
    //由于list不支持随机访问，所以sort函数不能在list上运行，但是语法检查上不会出现错误
    //只会在编译阶段出现错误，所以list排序只能通过自身的sort函数
    //list调用自身的sort
    l1.sort();
}
```

所以当容器自身有同名算法时，优先调用同名算法，

#### count

![image-20230529161230266](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322356.png)

#### sort

![image-20230529161720647](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322357.png)

#### find

![image-20230529161328503](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322359.png)

。。。还有很多算法，但是基本结构与上述几个算法类似，算法不是每个容器中都带有

### 仿函数

仿函数只为算法服务，在调用时和函数一样，但是他不是函数，所以起名仿函数

仿函数是一个重载了`()`运算符的类，传递参数时传递类生成的对象，之后就可以使用类对象调用重载的`()`运算符

STL中内置了一些仿函数（函数对象），主要有三种：算术仿函数，关系仿函数，逻辑仿函数

算术仿函数就是加减乘除之类的仿函数，关系仿函数就是大于小于之类的。逻辑仿函数就是与或非

举一个使用仿函数的例子

```c++
void test()
{
	vector<int> v;
	v.push_back(10);
	v.push_back(30);
	v.push_back(20);
	v.push_back(50);
	v.push_back(40);

	for (auto it = v.begin(); it != v.end(); ++it)
	{
		cout << (*it) << endl;
	}

	//使用内置的关系仿函数实现vector中元素的降序排列
	//大于才返回真，相当于降序
	//greater中就是判断大于
	//greater<>相当于一个内置的使用类模板的类，创建一个函数对象 greater<int>()
	sort(v.begin(), v.end(), greater<int>());
	cout << "--------" << endl;
	for (auto it = v.begin(); it != v.end(); ++it)
	{
		cout << (*it) << endl;
	}

}
```

仿函数和谓词之间还有一定的联系

谓词就是返回值为bool类型的函数或者仿函数，所以当仿函数返回值类型为bool时，就可以将其当成一个谓词使用，拿上面的例子举例来说，就是将`greater<>()`改成自定义的仿函数即可

```c++
//定义一个仿函数
class Comp{
public:
    //将较大的值放前面
    bool operator()(int a,int b){
        return a>b;
    }
};
void test()
{
	vector<int> v;
	v.push_back(10);
	v.push_back(30);
	v.push_back(20);
	v.push_back(50);
	v.push_back(40);

	for (auto it = v.begin(); it != v.end(); ++it)
	{
		cout << (*it) << endl;
	}

	//使用自定义的仿函数进行元素的降序
	sort(v.begin(), v.end(), Comp());
	cout << "--------" << endl;
	for (auto it = v.begin(); it != v.end(); ++it)
	{
		cout << (*it) << endl;
	}
}
```

STL中的仿函数继承了 binary_function(二元谓词)或者unary_function（一元谓词）这个类 

继承这个类之后就拥有了相应的属性,每次调用这个仿函数时，就会多出这几个属性，有了这几个属性，就可以被配接形成仿函数适配器，例如下面的less

~~~C++
// less的定义
template<typename _Tp> struct less : public binary_function<_Tp, _Tp, bool> {
      bool operator()(const _Tp& __x, const _Tp& __y) const
      { return __x < __y; }
};
~~~

继承binary_function之后，就会有三个属性，第一参数类型，第二参数类型，返回值类型

这些属性是为了后期给适配器使用，只有适配器知道了less的参数类型和返回值，才能知道怎么改造

所以说没有继承下面这两个类的仿函数无法被适配器改造

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322360.png" alt="image-20230531165019209" style="zoom:50%;" />

其中binary_function三个属性，unary_function两个属性，对应一元谓词和二元谓词

如果希望自己定义的仿函数有配接能力，就需要继承二者之一，提供一些属性，仿函数适配器才知道怎么改造

### 仿函数适配器

将仿函数进行一定的改造，使其符合自己的需求，例如将两个仿函数组合形成一个新的仿函数等适配操作

### 适配器

适配器内含一个仿函数成为了仿函数适配器，内含了一个迭代器成为了迭代器适配器，内含了一个容器变成了容器适配器

#### 仿函数适配器

当仿函数继承了一元谓词或者二元谓词这个类时，就会拥有他们的属性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011322360.png" alt="image-20230531165019209" style="zoom:50%;" />

有了这些属性之后，仿函数适配器内含一个仿函数，通过调用他们的属性对仿函数进行改造

仿函数适配器对于仿函数的改造之后，最终的操作还是需要仿函数实现

1. <font color=red>bind2nd</font>

    代表着将仿函数的第二实参进行绑定 ，举一个例子：

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452816.png" alt="image-20230601150145619" style="zoom:67%;" />

   bind2nd将less的第二参数变成了固定的四十，本来countif中不能直接使用less，因为less需要传递两个参数，countif的目的就是传递一个参数，如果满足条件结果数就加一

   所以bind2nd对less进行改造，将less的第二参数进行绑定，现在less就可以只传递一个参数

   bind2nd内部调用了binder2nd这个类，将传递进来的less和绑定的第二参数进行保存，保存之前要校验类型是否匹配或者可以转化

   之后countif内部调用的pred其实是调用的改造后的less

   所以调用顺序是：countif->operator()->less()

   这里count调用pred（仿函数当谓词）时，其实是调用了一个操作符重载，然后再操作符重载的内部调用less，第一参数就是pred传递的参数，第二参数就是绑定的参数，这个参数记录在binder2nd类中

   而内部对于less的改造的顺序是

   **bind2nd将传递进来的仿函数less和value传递给binder2nd，binder2nd记录这个仿函数less和value，并重载()运算符，接收一个参数x，内部调用记录的仿函数less，less传递的两个参数一个是接受的参数x，一个是记录的绑定参数value，暴露在外部时只用传递一个参数就可以实现对less的调用**

   > bind2nd作为countif的参数就是一个类对象，因为他是inline，再加上返回值类型是个类对象，之后向类对象传递参数就是调用重载运算符()

   -----------------------------------

   正常的仿函数适配器的改造流程就是定义一个类模板，里面将传递进来的仿函数和一系列参数进行记录，之后重载()运算符，内部调用记录的仿函数，对参数进行修改，或者对结果进行修改

   将这个类封装好之后，**由于参数类型推导的问题，定义一个辅助函数，推导出参数的类型之后，内部调用这个类模板**

   想要使用仿函数适配器时直接调用这个辅助函数即可

   > 辅助函数的模板中的参数与传递进来的仿函数类型保持一致，外部看来辅助函数就是这个仿函数的一个别名,外部调用时会直接调用重载运算符()
   
   > 改造仿函数的过程中涉及到参数的类型，此时继承的那两个类就起了作用
   >
   > 知道了less的两个参数的类型，以及返回值的类型，改造的过程中就不会出现类型冲突

```c++
// less的定义
template<typename _Tp> 
struct less : public binary_function<_Tp, _Tp, bool> {
      bool operator()(const _Tp& __x, const _Tp& __y) const
      { return __x < __y; }
};
```

因为仿函数适配器内部重载了()运算符，所以外部看起来也像是一个仿函数

这个binder2nd本身又继承了unary_function，相当于他也可以被配接

2. <font color=red>not1</font>

   这个仿函数适配器就是将仿函数（谓词）的结果取反，具体的运行逻辑与bind2nd一样，定义的not1也是一个辅助函数，真正的仿函数类叫做unary_nagate，not1的作用就是推导出传递而来的谓词的类型，并将其传递给unary-negate,在unary_negate中，由于知道了仿函数（谓词）的参数类型，在重载（）运算符时，直接调用此仿函数（谓词），将返回结果取反再返回即可

3. <font color=red>bind</font>

   bind就是加强版的bind2nd，可以绑定函数，仿函数，成员函数，使用占位符（_1、 _2、 _3）表示当前的参数不绑定，给一个确定的参数就表示这个参数绑定给对应的函数，可以是普通函数，仿函数，成员函数等

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452647.png" alt="image-20230601153621570" style="zoom:67%;" />

   bind可以绑定很多东西，绑定的第一参数返回什么就返回什么

   bind可以代替bind2nd，代码的可读性更好，使用占位符表示哪些参数没被绑定。后期调用时就需要填补

   对于最后一行，bind将less的第二参数绑定为50，第一参数不绑定使用占位符防止语法错误，

   countif内部调用会调用这个bind函数，传递一个参数，填补第一参数，与绑定的第二参数作比较

#### 容器适配器

适配器内涵一个容器，然后将容器的部分方法封闭或者加以改造，就形成了自己独有的方法，

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452648.png" alt="image-20230601132533305" style="zoom:50%;" />

可以看出stack底层的实现就是deque，但是他将deque的部分函数舍弃，部分函数改名，删除和插入都是在尾部，去掉了头部的操作。。。

#### 迭代器适配器

迭代器适配器一般都是对= ++ --运算符重载，然后实现在内部调用其他的迭代器实现相应的功能

因为迭代器适配器一般都与copy函数连用，改变copy中的这三个操作，就可以实现特殊的功能

而仿函数迭代器一般都是对()运算符重载，然后再内部调用其他的仿函数实现相应的功能

1. <font color=red>reverse_iterator</font>

    定义一个reverse_iterator类，其中对iterator进行操作，将头尾互换，从容器的尾部向头部移动，所以++和--的操作也会相反

   逆向迭代器和普通的迭代器一样，也有五个属性，由萃取器提供，

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452649.png" alt="image-20230601160000790" style="zoom: 50%;" />

2. <font color=red>inserter</font>

     inserter也是一个辅助函数，内部调用insert_iterator迭代器类，辅助函数的作用也是为了推导出容器和迭代器的类型，之后调用调用insert_iterator迭代器类，和bind2nd的思想类似

   但是重载的不再是()运算符，而是=运算符，目的就是将copy中的=进行重写

   ![image-20230601163103539](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452650.png)

   foo的it迭代器进行插入时有两次++，第一次++在=操作符重载内，为了指向新元素，第二次++在copy内，为了移动到下一个位置，插入的时候在当前位置的前面插入

   整体流程就是调用copy函数，第三个参数传递的是一个使用inserter处理过的迭代器，类型与普通迭代器一样，只是重载了=运算符

   copy内部执行到赋值=时，调用迭代器重载的=运算符，内部将传递来的容器进行插入，插入之后移动迭代器，返回这个插入类型的迭代器，看起来就像是普通的赋值，其实上是插入

   > 就是重载=运算符，类似于仿函数迭代器中重载()运算符一样

3. <font color=red>ostream_iterator</font>

   将迭代器中的内容输出到屏幕

   ![image-20230601164747141](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306061452651.png)

   调用copy函数，然后copy的第三参数是一个迭代器适配器，类型与普通迭代器一样，只是重载了=运算符，copy内部运行到*result=\*first时,自动调用重载的=运算符版本，从而实现对元素的打印，将first中的值传递给result，result中传递给输出流对象实现打印

   这都是写好的东西，可以直接用，主要是运算符进行了重载

4. <font color=red>istream_iterator</font>

   将输入的内容传递给迭代器，然后取出迭代器的内容就可以得到输入值

   ![image-20230601182152433](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011821556.png)

   执行流程是定义两个istream_iterator迭代器，之后调用对应的构造函数，无参构造将迭代器变成一个eos标志，有参构造函数将其变成一个接受输入的迭代器，调用++实现接受输入，将输入存放在this中，也就是迭代器中，将这个迭代器的值取出来放到value1中，之后++再调用++运算符重载函数，再次接受输入

   相当与调用了两次++，第一次在构造函数中调用，第二次是主动调用  

   <img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306011841502.png" alt="image-20230601184118385" style="zoom:67%;" />

   这个结合inserter一起，使用istream_iterator接收输入，使用inserter将输入插入到容器c中

   inserter因为内部重载了=，所以在copy时，调用重载运算符=，内部将调用容器的插入函数，将值插入到容器中

   istream_iterator重载了++，可以接收输入，将输入通过*取出来之后，进行插入

   > 核心就是while代码中的三个运算符重载，使得copy的功能变得强大
   >
   > 将copy改头换面  接受输入，插入到容器c中

## 第四部分

前三部分介绍了STL的六大部分，第四部分介绍除此之外剩下的部分

### 哈希函数

> 如何对自定义类型进行哈希

当使用unordered_map和unordered_set时，底层会调用哈希表来对元素进行哈希确定存储的位置，这就涉及到一个问题，系统可能对整数，字符已经定义了哈希函数，但是对自定义的类型肯定是没有给出哈希函数的，此时就需要我们指定

就像是对元素进行排序一样，系统对整型或者字符串给出了比较的函数，从而可以直接进行排序，但是对于自定义的数据类型是没有给定的，此时就需要自定义一个比较函数

此时这个比较函数可以使用全局函数，也可以使用仿函数，只要可以比较大小并且返回值是bool即可

----------------

类比排序自定义类型时的操作，对自定义数据类型进行哈希也可以使用[四种](https://blog.csdn.net/qq_45311905/article/details/121488048)方式定义哈希函数：

1. 全局函数做哈希
2. 仿函数做哈希
3. 自定义哈希函数
4. 特化hash函数

对于前三种，在使用时将哈希函数当成一个参数传递给对应的容器即可，假设定义的哈希类名叫做Hasher，并且使用unordered_set存储Person自定义类型，此时传递的格式为：

```c++
unordered_set<Person,Hasher> uset;
```

在参数列表指定哈希函数

对于第四种，相当于不传递哈希函数，在容器调用哈希函数时，传递的元素类型时Person，所以会调用偏特化版本的hash函数，实现自定义数据类型的哈希

#### 变长参数

**系统给我们提供了一个万用的哈希函数**

系统认为自定义的数据类型也是由普通数据类型拼接而成，例如人这种类型由年龄（int），姓名（string）等基本类型组成

基于这个原理，系统提供了三种不同的万用哈希函数

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031456647.png" alt="image-20230603145604538" style="zoom:67%;" />

上图的执行流程如下：

1. 首先调用哈希函数1，传递三个参数，哈希函数1创建一个seed

   将seed和三个参数传递给哈希函数2，

2. 哈希函数2首先接收到哈希函数1传来的seed和三个参数，将三个参数拿出来一个，也就是val

   拿seed和val做combine，得到一个新的seed，传递的是引用，不需要返回值，

   有了新的seed，调用自身，将这个seed和剩下的两个参数传递给自己

   然后从两个参数中拿一个，与seed再次combine，得到新的seed

   此时只剩下一个参数，调用哈希函数3，在哈希函数3中调用combine，将seed和最后一个参数combine，形成最终的seed

3. 处理完参数之后，哈希函数1将seed返回当作hashcode

总结：外层调用哈希函数1，内层调用哈希函数2，每次拿一个参数和seed做combine，内部调用hash函数单独处理这个参数，参数越来越少，剩下一个参数时与哈希函数3做combine，最终的hashcode保存在seed中，由哈希函数1返回

> 对于参数列表的处理由哈希函数2完成，哈希函数3做收尾工作

当需要自定义哈希函数时，内部将自定义属性拆分成单个的系统属性传递给`hash_val`函数即可

使用容器是将哈希函数作为参数传递，系统就知道如何进行哈希

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031511822.png" alt="image-20230603151152762" style="zoom: 80%;" />

这样就可以使用哈希表实现的容器对自定义类型数据进行存放

### Tuple

tuple可以存放任意类型的数据， 只要指定好数据类型即可

![image-20230603153906110](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031539170.png)

存放三个元素，使用get\<i> 容器名获得其中的某个元素

tuple之间可以比较大小，赋值，取元素（tie(int,float,string)可以一次性将t1中的三个元素取出来）

实现存放不同元素的原理就是指定元素的类型，由于类型个数可能会变化，所以这里使用参数可变的模板，处理可变的参数时，借鉴哈希函数中的思想，`hash_val1`对外提供接口，hash_val2处理参数，`hash_val3`善后

#### 变长参数

tuple处理变长参数关键就是**递归继承**自己，哈希函数处理变长参数关键是`hash_val2`**递归调用**自己

tuple每继承一次自己都减少一个参数，减少的参数存放在head中，当tuple为空是不再继承，定义一个空的tuple作为终止条件

相当于tuple中有一个小一级的tuple，小一级的tuple中有一个更小一级的tuple

取出tuple的头部就是第一参数的值，取出tuple的尾部就是少一个参数的新tuple

在程序中返回的是this指针。this原本应该代表没有减少参数的tuple，为什么最后会代表减少一个参数的tuple呢，因为做了类型转换

返回值类型inherited是一个去掉了头部的tuple类型，所以this会被强制类型转换，变成减少一个参数的tuple

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031620066.png" alt="image-20230603161959925" style="zoom:67%;" />

> 传递进来一系列参数，自动将其分成head和tail

### type traits

可以提取到类型的各个属性，使用该属性时有需要的话就可以使用type traits得到他的一些属性，与迭代器的traits类似

#### 使用

将其理解为一个类型的萃取器，决定了类型的属性是否重要，主要有五个属性：

1. 默认构造是否重要
2. 拷贝构造是否重要
3. 赋值运算符是否重要
4. 析构函数是否重要
5. 是不是兼容c的类型

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031633426.png" alt="image-20230603163313486" style="zoom: 67%;" />

每个类型都可以对` `进行特化，决定五个属性哪些是重要的

基本上不是指针的类型这些属性都是不重要的

 在算法中，使用`type_traits`得到类型的这些属性是否重要，从而进行不同的操作

**后期还出现了更多的`type traits`**，都是为了得到类型的不同属性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306031641869.png" alt="image-20230603164104784" style="zoom:67%;" />

调用<font color=blue>蓝色</font>的这些函数就可以得到类型的属性

#### 实现

当想要知道某一个类型的某些属性时，外部直接调用上述中的一个<font color=blue>蓝色</font>的函数，并将这个类型作为一个参数传递即可，底层收到这个参数，将可能存在的 const属性去掉，之后调用helper函数，满足条件就返回true，其余的一律返回false，如下图所示：

![image-20230603204731854](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202306032047927.png)

1. 参数传递给helper函数
2. 去除掉影响判断的部分
3. 符合要求的返回true，其余的一律返回false

编译器在对这些类型编译时，肯定知道这些类型都有哪些属性，所以有时候获得属性的方法就是交给编译器

###  iterator包含的五个typedef

容器中的每一个迭代器都带有这五种属性，算法使用迭代器操作容器时，不同的容器由于属性不同，所以操作的方式不同，例如vector支持随机访问，就可以使用STL自带的sort函数，而list不支持随机访问，所以自身需要增加一个sort函数

1. iterator_category：迭代器的种类，可随机访问还是顺序访问
2. difference_type：迭代器之间的距离
3. value_type：迭代器中元素的类型，int还是string

后面的两种预留在后面使用

1. reference：
2. pointer:

### 补充萃取器 Iterator Traits

 主要为了得到容器中的几个属性，传递给算法之后才能进行一系列的操作

当iterator是一个类时，算法可以很轻易的得到上述的五个属性，但是如果iterator是一个指针呢，此时就需要使用iterator traits，他可以区分迭代器是一个类还是一个指针

---

当想要使用容器中的几个属性，例如存储元素的类型，如果直接使用*it得到的是元素的值，并不是元素的地址，所以想到了封装一层参数，参数传递时编译器帮我们推导出类型，但是函数的返回值也无法推导，所以又想到了内嵌类型，应用之后发现如果迭代器是一个原生指针，又会出现无法定义内嵌类型的情况根据以上分析，最终设计出了萃取器

> 以上参考了侯捷STL源码剖析P84中3.3和P85中3.4的分析

---

可以想象成一个函数，传递进去一个迭代器，返回迭代器的类型，区分的方式就是通过**函数重载**，不同的参数列表调用不同的traits，得到不同的结果

上面说的**函数重载**，类比使用模板定义的traits中被称为**偏特化**

总结来说，就是增加一个中间层，如果迭代器是类，直接使用类名加`::`的方式得到五个属性，如果是指针，就不能使用类名加`::`的方式得到五个属性，此时traits直接返回五个属性

<img src="https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305251414509.png" alt="image-20230525141449364" style="zoom:67%;" />

### 补充重载运算符

前置运算符++和后置运算符++重载的区别：例如i=3，`++i`之后i=4,此时直接使用i得到的结果为4，而i=3，`i++`之后需要分为两步，第一步使用i得到的结果为3，使用完成之后i才会变成4，这也导致了`++i`得到的结果是一个左值，`i++`的结果是一个右值，使用完成之后才会完成自增

重载运算符时，前置自增没有参数列表，且返回值是一个当前对象的引用，后置自增有参数列表，返回值是一个右值，调用后置递增时，编译器自动提供一个为0的实参，没有任何作用，只是为了区分前置和后置，所以看到后置运算有一个`int`类型的形参

显式调用时需要加上这个实参进行区分：

```c++
p.operator++();			//等价于++p
p.operator++(0);		//等价于p++，需要显式指定实参才能区分
```

示例代码如下：

```c++
#include<iostream>

using namespace std;

class Person
{
public:
    string Name;
    int Age;
    Person(){}
    Person(string name,int age)
    {
        this->Name=name;
        this->Age=age;
    }
    //拷贝构造函数
    Person(const Person &p)
    {
        this->Name=p.Name;
        this->Age=p.Age;
    }
    Person & operator++()
    {
        this->Age++;
        return *this;
    }
    //增加一个参数为了区分
    Person operator++(int)
    {
        Person temp(this->Name,this->Age);
        this->Age++;
        return temp;
    }
};

int main()
{
    Person p1("aaa",13);
    Person p2("bbb",13);
    Person p11(++p1);
    cout<<p11.Age<<endl;//14
    Person p22(p2++);
    cout<<p22.Age<<endl;//13
    system("pause");
    return 0;
}

```

具体list中的++运算符重载如图所示：

![image-20230524162038127](https://zzzi-img-1313100942.cos.ap-beijing.myqcloud.com/img/202305241620193.png)

由于c++操作符的右结合性，所以后置递增两次是不被允许的

```C++
i++++//非法
++++i//合法
```



