//
//  Runspector.m
//  Console
//
//  Created by stanhu on 2018/11/13.
//  Copyright © 2018年 Stan Hu. All rights reserved.
//

#import "Runspector.h"
NSString *greeting(id self,SEL _cmd){
    return [NSString stringWithFormat:@"Hello this is shadow edge"];
}
@implementation Runspector
+(void)testClass{
    testClass* a = [testClass new];
    a->myInt = 0x5a5a5a5;
    testClass* b = [testClass new];
    b->myInt = 0xc3c3c3c3;
    long aSize = class_getInstanceSize([a class]);
    NSData* aData = [NSData dataWithBytes:(__bridge const void*)a length:aSize];
    NSData* bData = [NSData dataWithBytes:(__bridge const void*)b length:aSize];
    NSLog(@"testclass object a constain %@",aData); //01550000 01801d00 a5a5a505 00000000
    NSLog(@"testclass object b constain %@",bData); //01550000 01801d00 c3c3c3c3 00000000
    //前面两项是isa指针，后面两项是实例变量的值 ，因为两个是同一个类b实例化的，所以isa指针是一样的
    NSLog(@"testclass memery address = %p",[testClass class]); //address = 0x100005500
    
    id testClz = objc_getClass("testClass");
    long tcSize = class_getInstanceSize([testClz class]);
    NSData* tcData = [NSData dataWithBytes:(__bridge const void*)testClz length:tcSize];
    NSLog(@"testClass class constain %@",tcData);//e9550000 01801d00 40212a89 ff7f0000 后面两个值是指向父类的地址，不过还是有点不一样
    NSLog(@"testClass superclass memory address = %p",[testClass superclass]);//0x7fff892a2140
}

+(void)dynaClass{
    //动态的方式创建一个类
    Class dynaClass = objc_allocateClassPair([NSObject class], "DynaClass", 0);
    //动以态的方式添加一个方法，使用已知的方法(description)获取一些信息
    Method description = class_getInstanceMethod([NSObject class], @selector(description));
    const char* types = method_getTypeEncoding(description);
    class_addMethod(dynaClass, @selector(greeting), (IMP)greeting, types);
    //注册这个类
    objc_registerClassPair(dynaClass);
    //使用该类创建一个实例并发送一条消息
    id dynaObj = [dynaClass new];
    id result = objc_msgSend(dynaObj,NSSelectorFromString(@"greeting"));
    NSLog(@"the dynaClass test result is%@",result);
}
@end





@implementation testClass
@end
