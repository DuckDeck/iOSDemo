//
//  AspectProxy.h
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invoke.h"


@interface AspectProxy : NSProxy
@property (strong) id proxyTarget;
@property (strong) id<Invkoe> invoke;
@property (readonly) NSMutableArray *selectors;
-(id)initWithObject:(id)object andInvoke:(id<Invkoe>)invoker;
-(id)initWithObject:(id)object selectors:(NSArray*)selectors andInvoke:(id<Invkoe>)invoker;
-(void)registerSelector:(SEL)selector;
+(void)testProxy;
@end

