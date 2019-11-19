//
//  BlockChain.m
//  Console
//
//  Created by Stan Hu on 2019/11/19.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import "BlockChain.h"

@implementation BlockChain
- (BlockChain *)chain1{
    NSLog(@"我是第一条链");
    return self;
}
- (void)chain2{
   NSLog(@"我是第二条链");
}
- (void (^)(NSString *))chain3{
    NSLog(@"我是第三条链");
    void (^block)(NSString *) = ^(NSString *word){
        NSLog(@"%@",word);
    };
    return block;
}
@end
