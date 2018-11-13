//
//  SelDemo.m
//  Console
//
//  Created by stanhu on 2018/11/13.
//  Copyright © 2018年 Stan Hu. All rights reserved.
//

#import "SelDemo.h"
#import <objc/runtime.h>
@implementation SelDemo
//_cmd 是当前的Sel
-(NSNumber *)sumAddend1:(NSNumber *)addre1 :(NSNumber *)adder2{
    NSLog(@"Invoking method on %@ object with selector %@",[self className],NSStringFromSelector(_cmd));
    //sumAddend1::
    return [NSNumber numberWithInteger:(addre1.integerValue + adder2.integerValue)];
}
-(NSNumber*)sumAddend1:(NSNumber *)addre1 addend2:(NSNumber *)adder2{
    NSLog(@"Invoking method on %@ object with selector %@",[self className],NSStringFromSelector(_cmd));
    //sumAddend1:addend2:
    return [NSNumber numberWithInteger:(addre1.integerValue + adder2.integerValue)];
}

//动态地解析方法
+(BOOL)resolveInstanceMethod:(SEL)sel{
    NSString* method = NSStringFromSelector(sel);
    if ([method hasPrefix:@"absoluteValue"]) {
        class_addMethod([self class], sel, (IMP)absuluteValue, "@@:@");
        //动态添加一个方法
        NSLog(@"Dynamiclly added instance method %@ to class %@",method,[self className]);
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

id absuluteValue(id self,SEL _cmd,id value){
    NSInteger intval = [value integerValue];
    if(intval < 0){
        return [NSNumber numberWithInteger:(intval * -1)];
    }
    return value;
}

+(void)testSel{
    SelDemo * sel = [SelDemo new];
    NSNumber* n1 = @(22);
    NSNumber* n2 = @(12);
    NSNumber* n3 = @(9);
    NSLog(@"Sum of %@ + %@ = %@",n1,n2,[sel sumAddend1:n1 :n2]);
    NSLog(@"Sum of %@ + %@ = %@",n1,n3,[sel sumAddend1:n1 addend2:n3]);
}
#pragma clang disgnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//pragmaclang diagnostic ignored可以用来禁用编译器警告
+(void)testSelDynamic{
    SelDemo * sel = [SelDemo new];
    NSNumber* n1 = @(22);
    NSNumber* n2 = @(12);
    NSNumber* n3 = @(9);
    SEL sel1 = @selector(sumAddend1::);
    id sum1 = [sel performSelector:sel1 withObject:n1 withObject:n2];
    NSLog(@"Sum of %@ + %@ = %@",n1,n2,sum1);
    SEL sel2 = @selector(sumAddend1:addend2:);
    id sum2 = [sel performSelector:sel2 withObject:n1 withObject:n3];
    NSLog(@"Sum of %@ + %@ = %@",n1,n3,sum2);
}
+(void)testSelString{
    SelDemo * sel = [SelDemo new];
    NSNumber* n1 = @(22);
    NSNumber* n2 = @(12);
    NSNumber* n3 = @(9);
    SEL sel1 = NSSelectorFromString(@"sumAddend1::");
    id sum1 = [sel performSelector:sel1 withObject:n1 withObject:n2];
    NSLog(@"Sum1 of %@ + %@ = %@",n1,n2,sum1);
    SEL sel2 = NSSelectorFromString(@"sumAddend1:addend2:");
    id sum2 = [sel performSelector:sel2 withObject:n1 withObject:n3];
    NSLog(@"Sum2 of %@ + %@ = %@",n1,n3,sum2);
    SEL sel3 = NSSelectorFromString(@"absoluteValue:");
        NSLog(@"Invoking instance method %@ on object of class %@",NSStringFromSelector(sel3),[sel className]);
    n3 = @(-99);
    id  sum3 = [sel performSelector:sel3 withObject:n3];
    NSLog(@"Absolute Value of %@ is %@",n3,sum3);
    
}
#pragma clang diagnostic pop
//push和pop可以用来保存和恢复编译吕当前的诊断设计，后面或者其他的文件编译器会正常显示警告
@end
