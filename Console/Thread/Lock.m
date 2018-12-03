//
//  Lock.m
//  Console
//
//  Created by Stan Hu on 2018/12/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "Lock.h"

@implementation Lock{
    int ticketCount;
}
-(void)ticketTest{
    ticketCount = 50;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    for (NSInteger i = 0 ;i<5;i++) {
//        dispatch_async(queue, ^{
//            for (int j = 0; j<10; j++) {
//                NSLog(@"当前i=%ld;j=%d", (long)i,j);
//                [self sellintTicket];
//            }
//        });
//    }
    
    //不对啊，为什么每次执行得不到想要的结果
        dispatch_async(queue, ^{
            for (NSInteger j = 0; j<100; j++) {
                NSLog(@"当前j=%ld",(long)j);
                [self sellintTicket];
            }
        });
    
}
-(void)sellintTicket{
    int old = ticketCount;
   // sleep(.2);
    old -= 1;
    ticketCount = old;
    NSLog(@"当前剩余票数-> %d", old);
}
@end
