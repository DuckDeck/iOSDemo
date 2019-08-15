//
//  a.c
//  ConsoleC
//
//  Created by Stan Hu on 2019/8/14.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#include <stdio.h>

extern int global_var;
void func(int a);
int main(){
    int a = 100;
    func(a + global_var);
    return 0;
}


//生成a.o b.o
//xcrun -sdk iphoneos clang -c a.c b.c -target arm64-apple-ios12.2
// a.o和b.o链接成可执行文件ab
//xcrun -sdk iphoneos clang a.o b.o -o ab -target arm64-apple-ios12.2
