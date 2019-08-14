//
//  main.c
//  ConsoleC
//
//  Created by Stan Hu on 2019/8/14.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#include <stdio.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    printf("Hello, World!\n");
    return 0;
}
/*
预处理（预编译Prepressing）
  clang -E main.c -o main.i
处理源代码文件中的以"#"开头的预编译指令。规则如下：

"#define"删除并展开对应宏定义。
处理所有的条件预编译指令。如#if/#ifdef/#else/#endif。
"#include/#import"包含的文件递归插入到此处。
删除所有的注释"//或/**/
/*
添加行号和文件名标识。如“# 1 "main.m"”,编译调试会用到。
*/

/*
编译（Compilation）
clang -S main.i -o main.s
编译就是把上面得到的.i文件进行：词法分析、语法分析、静态分析、优化生成相应的汇编代码，得到.s文件。

词法分析：源代码的字符序列分割成一个个token（关键字、标识符、字面量、特殊符号），比如把标识符放到符号表（静态链接那篇，重点讲符号表）。
语法分析：生成抽象语法树 AST，此时运算符号的优先级确定了；有些符号具有多重含义也确定了，比如“*”是乘号还是对指针取内容；表达式不合法、括号不匹配等，都会报错。
静态分析：分析类型声明和匹配问题。比如整型和字符串相加，肯定会报错。
中间语言生成：CodeGen根据AST自顶向下遍历逐步翻译成 LLVM IR，并且在编译期就可以确定的表达式进行优化，比如代码里t1=2+6，可以优化t1=8。（假如开启了bitcode，）
目标代码生成与优化：根据中间语言生成依赖具体机器的汇编语言。并优化汇编语言。这个过程中，假如有变量且定义在同一个编译单元里，那给这个变量分配空间，确定变量的地址。假如变量或者函数不定义在这个编译单元，得链接时候，才能确定地址。
*/
/*
汇编（Assembly）
 clang -c main.s -o main.o
汇编就是把上面得到的.s文件里的汇编指令一一翻译成机器指令。得到.o文件，也就是目标文件，后面会重点讲的Mach-O文件。
*/

/*
链接（Linking）
clang main.o -o main

远古时代，一个程序只有一个源代码文件，导致程序的维护非常困难。现在程序都是分模块组成，比如一个App，对应有多个源代码文件。每个源代码文件汇编成目标文件，根据上面流程A目标文件访问B目标文件的函数或者变量，是不知道地址的，链接就是要解决这个问题。链接过程主要包括地址和空间分配、符号决议和重定位。
链接就是把目标文件（一个或多个）和需要的库（静态库/动态库）链接成可执行文件。后面会分别讲静态链接和动态链接。
*/
/*
Stans-MacBook-Pro:ConsoleC stanhu$ ./main
Hello, World!
Stans-MacBook-Pro:ConsoleC stanhu$


Stans-MacBook-Pro:ConsoleC stanhu$ file main
main: Mach-O 64-bit executable x86_64
 Stans-MacBook-Pro:ConsoleC stanhu$ file main.o
 main.o: Mach-O 64-bit object x86_64
 Stans-MacBook-Pro:ConsoleC stanhu$ file main.i
 main.i: c program text, ASCII text
 Stans-MacBook-Pro:ConsoleC stanhu$ file main.s
 main.s: assembler source text, ASCII text
*/
