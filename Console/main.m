//
//  main.m
//  Console
//
//  Created by Stan Hu on 19/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Test.h"
#import "GCD.h"
#import "Hydron.h"
#import <objc/runtime.h>
#import "CFDemo.h"
#import "SelDemo.h"
#import "Runspector.h"
#import "AspectProxy.h"
#import "ConcurrentProcessor.h"
#import "Lock.h"
#import "AboutKVC.h"
#import "CategoryDemo.h"
@interface Father : NSObject
@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* address;
@end
@implementation Father

@end
@interface Son : Father

@end
@implementation Son


-(id)init{
    self = [super init];
    if (self) {
        NSLog(@"%@",NSStringFromClass([self class]));
        NSLog(@"%@",NSStringFromClass([super  class]));
    }
    return self;
}

@end





int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        // insert code here...
      
        People* people1 = [People new];
        [people1 setValue:nil forKey:@"age"];
        
        NSLog(@"%zu",class_getInstanceSize([NSObject class]));
        
        Father* f = [Father new];
         NSLog(@"%zu",sizeof(f));
        
        
        
        dispatch_queue_t q = dispatch_get_main_queue();
        dispatch_async(q, ^{
            NSLog(@"Hello");
        });
        
        GCD* gcd = [GCD new];
        [gcd testGCDGroup];
        //不知道这个是干什么的
        
        //测试消息转发
        //Hydron* h1 = [[Hydron alloc] init];
        //NSString* result = [h1 hydronId];
        //NSLog(@"%@",result);
        
        
        
        //test CFBridge
        //[CFDemo test];
        
        //[SelDemo testSel];
        //[SelDemo testSelDynamic];
        //[SelDemo testSelString];
        //[zunspector testClass];
        //[Runspector dynaClass];
       // [AspectProxy testProxy];
        
        /*
        NSScanner* sca = [NSScanner scannerWithString:@"111"];
        int val;
        BOOL success = [sca scanInt:&val];
        if (success) {
            NSLog(@"scanner result %ld",(long)val);
        }
        
        int ten = 10;
        int *tenPtr = &ten;
        NSValue *valTen = [NSValue value:&tenPtr withObjCType:@encode(int *)];
        int resInt = *(int*)[valTen pointerValue]; //pointerValue是全void指针，需要转成有类型的指针(int*) 但还要在前面加个*转成普通变量
        NSLog(@"NSValue result %ld",(long)resInt);
        NSLog(@"tem address %d",&ten); //取地址
        NSLog(@"tem address %d",*tenPtr); //取值
        
        
        NSLog(@"Host name is %@",[[NSHost currentHost] name]);
        NSLog(@"163 host address is %@",[[NSHost hostWithName:@"www.163.com"] address]);
        */
        
        
        /*
        [ConcurrentProcessor testThis];
        
        [[Lock new] ticketTest];
        */
                
        
        /* test allc and init
        Father* p = [Father alloc];
        
        p.address = @"ShenZhen";
         NSLog(@"没有init的情况下看 address是啥%@",p.address);
        Father* p1 = [p init]; //没有做任何事情
        Father* p2 = [p init];
        
        NSLog(@"%@---%@",p1,p2);
        NSLog(@"%@",p.address);
        */
        
        [CategoryDemo cls_method1];
       
    }
    return 0;
}




