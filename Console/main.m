//
//  main.m
//  Console
//
//  Created by Stan Hu on 19/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Father : NSObject

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
    @autoreleasepool {
        // insert code here...
        Son* son = [Son new];
        int i = 1;
        blk_t block = ^{
            printf("I'm just a block\n");
        };
        
        NSLog(@"------------------------------------this is the seprate line-------------------------------------");
        
    
        block();
    }
    return 0;
}
