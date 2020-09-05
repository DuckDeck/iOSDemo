//
//  AppDelegate.m
//  iOSDemoOC
//
//  Created by stan on 2020/5/12.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//     //! 创建一个信号量，保证同步操作
//       dispatch_semaphore_t dispatchSemaphore = dispatch_semaphore_create(0); //! Dispatch Semaphore保证同步
//        //! 创建一个观察者
//        CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
//     CFRunLoopObserverRef   runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
//                                                  kCFRunLoopAllActivities,
//                                                  YES,
//                                                  0,
//                                                  &runLoopObserverCallBack,
//                                                  &context);

    size_t t =  class_getInstanceSize([NSObject class]);
    
    [self doSomeThingForFlag:1 finish:^{
        
    }];
    
    [self doSomeThingForFlag:2 finish:^{
        
    }];
    
    [self doSomeThingForFlag:3 finish:^{
        
    }];
    
    [self doSomeThingForFlag:4 finish:^{
        
    }];
    return YES;
}


- (void)doSomeThingForFlag:(NSInteger)flag finish:(void(^)(void))finish {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"do:%ld",(long)flag);
        sleep(2+arc4random_uniform(4));
        NSLog(@"finish:%ld",flag);
        if (finish) finish();
    });
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
