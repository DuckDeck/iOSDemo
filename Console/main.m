//
//  main.m
//  Console
//
//  Created by Stan Hu on 19/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Test.h"
#import <objc/runtime.h>
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
typedef void (^blk_t)();
int main(int argc, const char * argv[]) {
    NSMutableSet *objs = [NSMutableSet new];
    @autoreleasepool {
        // insert code here...
        Son* son = [Son new];
        int i = 1;
        blk_t block = ^{
            printf("I'm just a block\n");
        };
        
        NSLog(@"------------------------------------this is the seprate line-------------------------------------");
        
    
        block();
        
        
        
        
        
        for (int i = 0; i < 1000; ++i) {
            Test *obj = [Test new];
            [objs addObject:obj];
        }
        sleep(100000);
        
        //不知道这个是干什么的
        
        
     
    }
    return 0;
}



