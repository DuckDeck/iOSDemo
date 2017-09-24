//
//  MsgSend.m
//  DemoConsole
//
//  Created by Stan Hu on 18/1/2017.
//  Copyright © 2017 StanHu. All rights reserved.
//

#import "MsgSend.h"
@interface MsgSend()
@property  (nonatomic,readonly,strong) NSMutableSet* observers;
@property (nonatomic,readonly,strong) Protocol* protocal;
@end
@implementation MsgSend
-(id)initWithProtocal:(Protocol *)protocal observers:(NSSet *)observers{
    if (self = [super init]) {
        _protocal = protocal;
        _observers = [NSMutableSet setWithSet:observers];
    }
    return self;
}
-(void)addObserver:(id)observer{
    NSAssert([observer conformsToProtocol:self.protocal], @"Observer must confirm the protocal");
    [self.observers addObject:observer];
}
-(void)removeObserver:(id)observer{
    [self.observers removeObject:observer];
}
-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature* result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    struct objc_method_description desc = protocol_getMethodDescription(self.protocal, aSelector, YES, YES);
    if (desc.name == NULL) {
        desc = protocol_getMethodDescription(self.protocal, aSelector, NO, YES);
    }
    if (desc.name == NULL) {
        [self doesNotRecognizeSelector:aSelector];
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:desc.types];
}
-(void)forwardInvocation:(NSInvocation *)anInvocation{
    SEL selector = [anInvocation selector];
    for (id responder in self.observers) {
        if ([responder respondsToSelector:selector]) {
            [anInvocation setTarget:responder];
            [anInvocation invoke];
        }
    }
}

@end


