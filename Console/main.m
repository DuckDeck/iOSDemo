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
@interface Father : NSObject
@property (nonatomic,copy) NSString* p1;
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
      
        
        GCD* gcd = [GCD new];
        [gcd testGCDGroup];
       //不知道这个是干什么的
        
        //测试消息转发
        Hydron* h1 = [[Hydron alloc] init];
        NSString* result = [h1 hydronId];
        NSLog(@"%@",result);
        
        
        
        [CFDemo test];
        //[SelDemo testSel];
        //[SelDemo testSelDynamic];
        //[SelDemo testSelString];
//        [Runspector testClass];
//        [Runspector dynaClass];
        [AspectProxy testProxy];
    }
    return 0;
}




