//
//  Invoke.m
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "Invoke.h"

@implementation AuditingInvoke

-(void)preInvoke:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"Creating audit log before sending message with selector %@ to %@ object"
          ,NSStringFromSelector(_cmd),[target class]);
}

-(void)postInvkoe:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"Creating audit log after sending message with selector %@ to %@ object"
          ,NSStringFromSelector(_cmd),[target class]);
}
@end
