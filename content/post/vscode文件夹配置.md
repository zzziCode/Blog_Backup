---
title: "Vscode文件夹配置"
description: "vscode文件夹配置"
keywords: "vscode文件夹配置"

date: 2023-06-07T21:26:34+08:00
lastmod: 2023-06-07T21:26:34+08:00

categories:
  - 教程
tags:
  - vscode配置


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
#url: "vscode文件夹配置.html"


# 开启各种图渲染，如流程图、时序图、类图等
# Enable chart render, such as: flow, sequence, classes etc
#mermaid: true
---

>:smile:vscode文件夹配置

配置`.vscode`文件夹之后，实现cpp文件的编译和调试

<!--more-->

## **配置方案**

### 第一种

自行创建`.vscode`文件夹，添加`tasks.json`和`launch.json`文件，此时直接编译文件

### 第二种

1. 先创建**英文**`cpp`文件，之后`ctrl+f5`进行编译，选择`GDB`和`G++`

2. 自动生成`tasks.json`和`launch.json`,自动跳转到`launch.json`文件中
3. 改变`program`和`externalConsole`两个配置
4. 改变`tasks.json`文件中的`args`配置

### 配置文件

> **tasks.json**

```json
{
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: g++.exe 生成活动文件",
            "command": "E:\\x86_64-8.1.0-release-posix-seh-rt_v6-rev0\\mingw64\\bin\\g++.exe",//自己的路径
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                //新增如下两项
                "-fexec-charset=GBK",   // 处理mingw中文编码问题
                "-finput-charset=UTF-8",// 处理mingw中文编码问题
                "${file}",
                "-o",
                //"${fileDirname}\\${fileBasenameNoExtension}.exe"
                "${fileDirname}\\test.exe"//更改这一项
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "调试器生成的任务。"
        }
    ],
    "version": "2.0.0"
}
```

> **launch.json**

```json
{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [

        {
            "name": "g++.exe - 生成和调试活动文件",
            "type": "cppdbg",
            "request": "launch",
           // "program": "${fileDirname}\\${fileBasenameNoExtension}.exe"
            //指向项目生成的可执行文件才可以进行调试运行
            "program": "${fileDirname}\\test.exe",//修改这一项
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            //在窗口显示
            "externalConsole": true,//false改为true
            "MIMode": "gdb",
            "miDebuggerPath": "E:\\x86_64-8.1.0-release-posix-seh-rt_v6-rev0\\mingw64\\bin\\gdb.exe",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            //在执行launch文件之前执行什么
            "preLaunchTask": "C/C++: g++.exe 生成活动文件"
        }
    ]
}
```

## 总结

确保编译器的路径正确，之后文件可以自动生成，并且可以运行中文文件，但是**无法调试中文文件**

如果控制台窗口一闪而过，自动关闭的话，在main函数最后`return 0`的前面加上一句`systemctl("pause")`即可
