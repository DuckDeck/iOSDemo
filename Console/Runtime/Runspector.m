//
//  Runspector.m
//  Console
//
//  Created by stanhu on 2018/11/13.
//  Copyright © 2018年 Stan Hu. All rights reserved.
//

#import "Runspector.h"
NSString *greeting(id self,SEL _cmd){
    NSLog(@"Invoke method with selector %@ on %@ instance",NSStringFromSelector(_cmd),[self className]);
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
    //添加一个实例变量 变量名为name 类型为id
    //class_addIvar(dynaClass, "name", sizeof(id), rint(log2(sizeof(id))), @encode(id)); 一般 name为String
    BOOL flag = class_addIvar(dynaClass, "name", sizeof(NSString*), log2(sizeof(NSString*)), @encode(NSString *));
    if (flag) {
        NSLog(@"name 属性添加成功");
    }
    
    flag = class_addIvar(dynaClass, "age", sizeof(int), sizeof(int), @encode(int));
    if (flag) {
        NSLog(@"age 属性添加成功");
    }
   
    
    
    //注册这个类
    objc_registerClassPair(dynaClass);
    //使用该类创建一个实例并发送一条消息
    id dynaObj = [dynaClass new];
    id result = objc_msgSend(dynaObj,NSSelectorFromString(@"greeting"));
    NSLog(@"the dynaClass test result is%@",result);
    
     //拷贝DynaClass类中的成员变量列表，打印出来
    unsigned int varCount;
    Ivar* varList = class_copyIvarList(dynaClass, &varCount);
    for (int i = 0; i<varCount; i++) {
        NSLog(@"DynaClass里的IVar成员%s",ivar_getName(varList[i]));
    }
    free(varList);
    
    //获取两个实例变量
    Ivar nameIvar = class_getInstanceVariable(dynaClass, "name");
    Ivar ageIvar = class_getInstanceVariable(dynaClass, "age");
    object_setIvar(dynaObj, nameIvar, @"ShadowEdge");
    object_setIvar(dynaObj, ageIvar, @30);
    NSLog(@"DynaClass这个类的name值%@",object_getIvar(dynaObj, nameIvar));
    NSLog(@"DynaClass这个类的age值%@",object_getIvar(dynaObj, ageIvar));
    
    //添加实例变量相对简单，但是对于属性就麻烦一些
    //属性的特性字符串 以 T@encode(type) 开头, 以 V实例变量名称 结尾,中间以特性编码填充,通过property_getAttributes即可查看
    
   //特性编码 具体含义
    //R readonly
    //C copy
    //& retain
    //N nonatomic
    //G(name) getter=(name)
    //S(name) setter=(name)
    //D @dynamic
    //W weak
    //P 用于垃圾回收机制

    objc_property_attribute_t attribute1;
    attribute1.name = "T";
    attribute1.value = @encode(NSString *); //以tT开头
    objc_property_attribute_t attribute2 = {"N",""}; //nonatomic
    objc_property_attribute_t attribute3 = {"C",""}; //copy
    objc_property_attribute_t attribute4 = {"V","_pname"}; //属性名 用于自动自成的，好像是name
    objc_property_attribute_t attrs[] ={attribute1,attribute2,attribute3,attribute4};
    class_addProperty(dynaClass, "pname", attrs, 4);//把这个property添加到DynaClass上
    //获取类中的属性列表
    unsigned int propertyCount ;
    objc_property_t* properties = class_copyPropertyList(dynaClass, &propertyCount);
    for (int i = 0; i<propertyCount; i++) {
        NSLog(@"属性的名称：%s",property_getName(properties[i]));
        NSLog(@"属性的特性字符串名称：%s",property_getAttributes(properties[i]));
    }
    free(properties);
    
//    Ivar proIVar = class_getInstanceVariable(dynaClass, "_pname");
//    object_setIvar(dynaObj, proIVar, @"_ShadowEdge");
//    NSLog(@"DynaClass这个类的_pname值%@",object_getIvar(dynaObj, proIVar));
    //这里没有调车ivar功能，可能能用_name来设置 打印出NULL，说明没有用
    //可能只能用KVC来设置
    //[dynaObj setValue:@"pNameShadowEdge" forKey:@"pame"];
    //NSLog(@"使用KVC来设置后属性pname的值为%@",[dynaObj valueForKey:@"pname"]);
    //KVC也不行
    objc_msgSend(dynaObj, NSSelectorFromString(@"greeting"));
    //注意这里是用实例峭是用类
    objc_setAssociatedObject(dynaObj, "hoby", @"fart", OBJC_ASSOCIATION_COPY);
    id res = objc_getAssociatedObject(dynaObj, "hoby");
    NSLog(@"DynaClas instance hoby = %@",res);
    
}
@end





@implementation testClass
@end
