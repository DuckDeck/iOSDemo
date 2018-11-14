//
//  ConcurrentProcessor.m
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "ConcurrentProcessor.h"
@interface ConcurrentProcessor()
    @property (readwrite) NSInteger computeResult;
@end

@implementation ConcurrentProcessor{
    NSString* computeID; //@synchronoze指令锁定的唯一对象
    NSUInteger computeTasks; //并行计算任务的计v数
    NSLock* computeLock; //锁对象
}

-(id)init{
    if (self = [super init]) {
        _isFinished = NO;
        _computeResult = 0;
        computeLock = [NSLock new];
        computeID = @"1";
        computeTasks = 0;
    }
    return self;
}
-(void)competeTask:(id)data{
    NSAssert([data isKindOfClass:[NSNumber class]], @"Not an NSNumber Instance");
    NSUInteger computations = [data unsignedIntegerValue];
    @autoreleasepool {
        @try {
            //获取锁并增加活动任务计数
            if ([[NSThread currentThread] isCancelled]) {
                return;
            }
            @synchronized (computeID) {
                computeTasks++;
            }
            //获取锁并执行关键代码部分中的计算操作
            [computeLock lock];
            if ([[NSThread currentThread] isCancelled]) {
                [computeLock unlock];
                return;
            }
            NSLog(@"Performing computations");
            NSLog(@"current thread id %@", [NSThread currentThread]);
            for (int ii = 0; ii<computations; ii++) {
                self.computeResult = self.computeResult + 1;
            }
            [computeLock unlock];
            //模拟额外对j处理时间(在关键部分之外)
            [NSThread sleepForTimeInterval:1.0];
            //减少活动任务次数，如果数量为0，则更新标志位
            @synchronized (computeID) {
                computeTasks--;
                if (!computeTasks) {
                    self.isFinished = YES;
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        } @finally {
            //do nothing
        }
    }
}
+(void)testThis{
    ConcurrentProcessor* processor = [ConcurrentProcessor new];
    [processor performSelectorInBackground:@selector(competeTask:) withObject:[NSNumber numberWithUnsignedInteger:5]];
    [processor performSelectorInBackground:@selector(competeTask:) withObject:[NSNumber numberWithUnsignedInteger:10]];
    [processor performSelectorInBackground:@selector(competeTask:) withObject:[NSNumber numberWithUnsignedInteger:20]];
    while (!processor.isFinished) {
        //do nothing
    }
    NSLog(@"Computation result = %ld",processor.computeResult);
}
@end
