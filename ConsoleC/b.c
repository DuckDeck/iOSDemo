//
//  b.c
//  ConsoleC
//
//  Created by Stan Hu on 2019/8/14.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#include <stdio.h>
int global_var = 1;
void func(int a){
    global_var = a;
}
