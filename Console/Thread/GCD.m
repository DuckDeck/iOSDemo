//
//  GCD.m
//  Console
//
//  Created by Stan Hu on 25/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "GCD.h"

@implementation GCD
-(void)testGCDGroup {
    dispatch_group_t g = dispatch_group_create();
    dispatch_queue_t q = dispatch_queue_create("com.test.queue", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"Will enter task1");
    dispatch_group_enter(g);
    dispatch_group_async(g, q, ^{
        [self task1];
        dispatch_group_leave(g);
    });
    NSLog(@"Will enter task2");
    dispatch_group_enter(g);
    dispatch_group_async(g, q, ^{
        [self task2];
        dispatch_group_leave(g);
    });
    
    NSLog(@"Come to notify");
    dispatch_group_notify(g, q, ^{
        NSLog(@"Enter notify");
        [self taskComplete];
    });
    NSLog(@"Pass notify");
}

-(void)task1 {
    NSLog(@"Enter sleep 10.");
    [NSThread sleepForTimeInterval:10];
    NSLog(@"Leave sleep 10.");
}

-(void)task2 {
    NSLog(@"Enter sleep 5.");
    [NSThread sleepForTimeInterval:5];
    NSLog(@"Leave sleep 5.");
}

-(void)taskComplete {
    NSLog(@"All task finished.");
}

@end
