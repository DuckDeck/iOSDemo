//
//  AspectProxy.m
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "AspectProxy.h"
#import "SelDemo.h"
@implementation AspectProxy
-(id)initWithObject:(id)object andInvoke:(id<Invkoe>)invoker{
    return [self initWithObject:object selectors:nil andInvoke:invoker];
}
-(id)initWithObject:(id)object selectors:(NSArray*)selectors andInvoke:(id<Invkoe>)invoker{
    _proxyTarget = object;
    _invoke = invoker;
    _selectors = [selectors mutableCopy];
    return self;
}
-(void)registerSelector:(SEL)selector{
    NSValue* selValue = [NSValue valueWithPointer:selector];
    [self.selectors addObject:selValue];
}
-(NSMethodSignature*)methodSignatureForSelector:(SEL)sel{
    return [self.proxyTarget methodSignatureForSelector:sel];
}
-(void)forwardInvocation:(NSInvocation *)invocation{
    if ([self.invoke respondsToSelector:@selector(preInvoke:withTarget:)]) {
        if (self.selectors != nil) {
            SEL methodSel = [invocation selector];
            for (NSValue *selValue in self.selectors) {
                if (methodSel == [selValue pointerValue]) {
                    [[self invoke] preInvoke:invocation withTarget:self.proxyTarget];
                    break;
                }
            }
        }
        else{
            [[self invoke] preInvoke:invocation withTarget:self.proxyTarget];
        }
    }
    [invocation invokeWithTarget:self.proxyTarget];
    
    if ([self.invoke respondsToSelector:@selector(postInvkoe:withTarget:)]) {
        if (self.selectors != nil) {
            SEL methodSel = [invocation selector];
            for (NSValue *selValue in self.selectors) {
                if (methodSel == [selValue pointerValue]) {
                    [[self invoke] postInvkoe:invocation withTarget:self.proxyTarget];
                    break;
                }
            }
        }
        else{
            [[self invoke] postInvkoe:invocation withTarget:self.proxyTarget];
        }
    }
}
+(void)testProxy{
    SelDemo * sel = [SelDemo new];
    NSNumber* n1 = @(22);
    NSNumber* n2 = @(12);
    NSNumber* n3 = @(9);
    
    NSValue *selValue1 = [NSValue valueWithPointer:@selector(sumAddend1:addend2:)];
    NSArray* selValues = @[selValue1];
    AuditingInvoke* invoke = [AuditingInvoke new];
    id calProxy = [[AspectProxy alloc] initWithObject:sel selectors:selValues andInvoke:invoke];
    [calProxy sumAddend1:n1 addend2:n2];
    
    [calProxy sumAddend1:n2 :n3]; //不会调用
    
    [calProxy registerSelector:@selector(sumAddend1::)];
    [calProxy sumAddend1:n2 :n3];
}

@end
