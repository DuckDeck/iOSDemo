//
//  block相关.m
//  Console
//
//  Created by Stan Hu on 25/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 NSLog(@"\n--------------------block调用 基本数据类型---------------------\n");
 int a = 10;
 NSLog(@"block定义前a地址=%p", &a);
 void (^aBlock)(void) = ^(){
 NSLog(@"block定义内部a地址=%p", &a);
 };
 NSLog(@"block定义后a地址=%p", &a);
 aBlock();
 */
/* 结果
 2017-11-07 10:57:18.303161+0800 Console[25107:2135283] block定义前a地址=0x7fff5fbff664
 2017-11-07 10:57:18.303174+0800 Console[25107:2135283] block定义后a地址=0x7fff5fbff664
 2017-11-07 10:57:18.303184+0800 Console[25107:2135283] block定义内部a地址=0x100500130
 流程：
 1. block定义前：a在栈区
 2. block定义内部：里面的a是根据外面的a拷贝到堆中的，不是一个a
 3. block定义后：a在栈区
 */


/*
 NSLog(@"\n--------------------block调用 __block修饰的基本数据类型---------------------\n");
 
 __block int b = 10;
 NSLog(@"block定义前b地址=%p", &b);
 void (^bBlock)() = ^(){
 b = 20;
 NSLog(@"block定义内部b地址=%p", &b);
 };
 NSLog(@"block定义后b地址=%p", &b);
 NSLog(@"调用block前 b=%d", b);
 bBlock();
 NSLog(@"调用block后 b=%d", b);
 */

/*
 2017-11-07 10:59:19.187267+0800 Console[25148:2137844] block定义前b地址=0x7fff5fbff660
 2017-11-07 10:59:19.187284+0800 Console[25148:2137844] block定义后b地址=0x100703fc8
 2017-11-07 10:59:19.187294+0800 Console[25148:2137844] 调用block前 b=10
 2017-11-07 10:59:19.187304+0800 Console[25148:2137844] block定义内部b地址=0x100703fc8
 2017-11-07 10:59:19.187313+0800 Console[25148:2137844] 调用block后 b=20
 
 结果：
 1. 声明 b 为 __block （__block 所起到的作用就是只要观察到该变量被 block 所持有，就将“外部变量”在栈中的内存地址放到了堆中。）
 2. block定义前：b在栈中。
 3. block定义内部： 将外面的b拷贝到堆中，并且使外面的b和里面的b是一个。
 4. block定义后：外面的b和里面的b是一个。
 5. block调用前：b的值还未被修改。
 6. block调用后：b的值在block内部被修改。
 */

/*
 
 NSLog(@"\n--------------------block调用 指针---------------------\n");
 
 NSString *c = @"ccc";
 NSLog(@"block定义前：c=%@, c指向的地址=%p, c本身的地址=%p", c, c, &c);
 void (^cBlock)() = ^{
 NSLog(@"block定义内部：c=%@, c指向的地址=%p, c本身的地址=%p", c, c, &c);
 };
 NSLog(@"block定义后：c=%@, c指向的地址=%p, c本身的地址=%p", c, c, &c);
 cBlock();
 NSLog(@"block调用后：c=%@, c指向的地址=%p, c本身的地址=%p", c, c, &c);
 */
/*
 2017-11-07 11:01:25.135726+0800 Console[25200:2139663] block定义前：c=ccc, c指向的地址=0x100002178, c本身的地址=0x7fff5fbff660
 2017-11-07 11:01:25.135751+0800 Console[25200:2139663] block定义后：c=ccc, c指向的地址=0x100002178, c本身的地址=0x7fff5fbff660
 2017-11-07 11:01:25.135780+0800 Console[25200:2139663] block定义内部：c=ccc, c指向的地址=0x100002178, c本身的地址=0x10060bfd0
 2017-11-07 11:01:25.135792+0800 Console[25200:2139663] block调用后：c=ccc, c指向的地址=0x100002178, c本身的地址=0x7fff5fbff660
 
 c指针本身在block定义中和外面不是一个，但是c指向的地址一直保持不变。
 1. block定义前：c指向的地址在堆中， c指针本身的地址在栈中。
 2. block定义内部：c指向的地址在堆中， c指针本身的地址在堆中（c指针本身和外面的不是一个，但是指向的地址和外面指向的地址是一样的）。
 3. block定义后：c不变，c指向的地址在堆中， c指针本身的地址在栈中。
 4. block调用后：c不变，c指向的地址在堆中， c指针本身的地址在栈中。
 */


/*
 NSLog(@"\n--------------------block调用 指针并修改值---------------------\n");
 
 NSMutableString *d = [NSMutableString stringWithFormat:@"ddd"];
 NSLog(@"block定义前：d=%@, d指向的地址=%p, d本身的地址=%p", d, d, &d);
 void (^dBlock)() = ^{
 NSLog(@"block定义内部：d=%@, d指向的地址=%p, d本身的地址=%p", d, d, &d);
 d.string = @"dddddd";
 };
 NSLog(@"block定义后：d=%@, d指向的地址=%p, d本身的地址=%p", d, d, &d);
 dBlock();
 NSLog(@"block调用后：d=%@, d指向的地址=%p, d本身的地址=%p", d, d, &d);
 */
/*
 2017-11-07 11:04:19.664820+0800 Console[25245:2141906] block定义前：d=ddd, d指向的地址=0x100516fe0, d本身的地址=0x7fff5fbff660
 2017-11-07 11:04:19.664860+0800 Console[25245:2141906] block定义后：d=ddd, d指向的地址=0x100516fe0, d本身的地址=0x7fff5fbff660
 2017-11-07 11:04:19.664872+0800 Console[25245:2141906] block定义内部：d=ddd, d指向的地址=0x100516fe0, d本身的地址=0x100618890
 2017-11-07 11:04:19.664885+0800 Console[25245:2141906] block调用后：d=dddddd, d指向的地址=0x100516fe0, d本身的地址=0x7fff5fbff660
 和上面一样
 d指针本身在block定义中和外面不是一个，但是d指向的地址一直保持不变。
 在block调用后，d指向的堆中存储的值发生了变化。
 */

/*
 NSLog(@"\n--------------------block调用 __block修饰的指针---------------------\n");
 
 __block NSMutableString *e = [NSMutableString stringWithFormat:@"eee"];
 NSLog(@"block定义前：e=%@, e指向的地址=%p, e本身的地址=%p", e, e, &e);
 void (^eBlock)() = ^{
 NSLog(@"block定义内部：e=%@, e指向的地址=%p, e本身的地址=%p", e, e, &e);
 e = [NSMutableString stringWithFormat:@"new-eeeeee"];
 };
 NSLog(@"block定义后：e=%@, e指向的地址=%p, e本身的地址=%p", e, e, &e);
 eBlock();
 NSLog(@"block调用后：e=%@, e指向的地址=%p, e本身的地址=%p", e, e, &e);
 */
/*
 2017-11-07 11:05:35.209013+0800 Console[25273:2143334] block定义前：e=eee, e指向的地址=0x100540ad0, e本身的地址=0x7fff5fbff660
 2017-11-07 11:05:35.209044+0800 Console[25273:2143334] block定义后：e=eee, e指向的地址=0x100540ad0, e本身的地址=0x100540c58
 2017-11-07 11:05:35.209062+0800 Console[25273:2143334] block定义内部：e=eee, e指向的地址=0x100540ad0, e本身的地址=0x100540c58
 2017-11-07 11:05:35.209083+0800 Console[25273:2143334] block调用后：e=new-eeeeee, e指向的地址=0x100540d90, e本身的地址=0x100540c58
 和前面例子一样
 从block定义内部使用__block修饰的e指针开始，e指针本身的地址由栈中改变到堆中，即使出了block，也在堆中。
 在block调用后，e在block内部重新指向一个新对象,e指向的堆中的地址发生了变化。
 */

/*
 NSLog(@"\n--------------------block的存储域 全局块---------------------\n");
 
 void (^blk)(void) = ^{
 NSLog(@"Global Block");
 };
 blk();
 NSLog(@"%@", [blk class]);
 */

/*
 2017-11-07 11:33:20.863525+0800 Console[26211:2188462] Global Block
 2017-11-07 11:33:20.863552+0800 Console[26211:2188462] __NSGlobalBlock__
 结论：
 全局块：这种块不会捕捉任何状态（外部的变量），运行时也无须有状态来参与。块所使用的整个内存区域，在编译期就已经确定。
 全局块一般声明在全局作用域中。但注意有种特殊情况，在函数栈上创建的block，如果没有捕捉外部变量，block的实例还是会被设置在程序的全局数据区，而非栈上。
 */


/*
 NSLog(@"\n--------------------block的存储域 堆块---------------------\n");
 
 int p = 1;
 void (^blk)(void) = ^{
 NSLog(@"Malloc Block, %d", p);
 };
 blk();
 NSLog(@"%@", [blk class]);
 */

/*
 2017-11-07 11:35:23.688668+0800 Console[26242:2191566] Malloc Block, 1
 2017-11-07 11:35:23.688693+0800 Console[26242:2191566] __NSMallocBlock__
 
 结论：
 堆块：解决块在栈上会被覆写的问题，可以给块对象发送copy消息将它拷贝到堆上。复制到堆上后，块就成了带引用计数的对象了。
 
 在ARC中，以下几种情况栈上的Block会自动复制到堆上：
 - 调用Block的copy方法
 - 将Block作为函数返回值时（MRC时此条无效，需手动调用copy）
 - 将Block赋值给__strong修饰的变量时（MRC时此条无效）
 - 向Cocoa框架含有usingBlock的方法或者GCD的API传递Block参数时
 
 上述代码就是在ARC中，block赋值给__strong修饰的变量，并且捕获了外部变量，block就会自动复制到堆上。
 */

/*
 
 NSLog(@"\n--------------------block的存储域 栈块---------------------\n");
 int l = 1;
 __weak void (^blk)(void) = ^{
 NSLog(@"Stack Block, %d", l);
 };
 blk();
 NSLog(@"%@", [blk class]);
 */


/*
 2017-11-07 11:36:46.774002+0800 Console[26282:2192835] Stack Block, 1
 2017-11-07 11:36:46.774029+0800 Console[26282:2192835] __NSStackBlock__
 
 结论：
 栈块：块所占内存区域分配在栈中，编译器有可能把分配给块的内存覆写掉。
 在ARC中，除了上面四种情况，并且不在global上，block是在栈中。
 */

/*
 
 在block内部，栈是红灯区，堆是绿灯区。
 在block内部使用的是将外部变量的拷贝到堆中的（基本数据类型直接拷贝一份到堆中，对象类型只将在栈中的指针拷贝到堆中并且指针所指向的地址不变。）
 __block修饰符的作用：是将block中用到的变量，拷贝到堆中，并且外部的变量本身地址也改变到堆中。
 循环引用：分析实际的引用关系，block中直接引用self也不一定会造成循环引用。
 __block不能解决循环引用，需要在block执行尾部将变量设置成nil（但问题很多，比如block永远不执行，外面变量变了里面也变，里面变了外面也变等问题）
 __weak可以解决循环引用，block在捕获weakObj时，会对weakObj指向的对象进行弱引用。
 使用__weak时，可在block开始用局部__strong变量持有，以免block执行期间对象被释放。
 块的存储域：全局块、栈块、堆块
 全局块不引用外部变量，所以不用考虑。
 堆块引用的外部变量，不是原始的外部变量，是拷贝到堆中的副本。
 栈块本身就在栈中，引用外部变量不会拷贝到堆中。
 
 */
