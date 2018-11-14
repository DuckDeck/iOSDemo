//
//  Invoke.h
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Invkoe <NSObject>

@required
-(void)preInvoke:(NSInvocation*)inv withTarget:(id)target;
@optional
-(void)postInvkoe:(NSInvocation*)inv withTarget:(id)target;

@end


@interface AuditingInvoke : NSObject<Invkoe>

@end
