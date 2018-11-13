//
//  Hydron.m
//  
//
//  Created by Stan Hu on 2018/11/12.
//

#import "Hydron.h"
#import "HydronForward.h"
@implementation Hydron{
    @private HydronForward* forawrd;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"hydron";
        forawrd = [[HydronForward alloc] init];
    }
    return self;
}
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if ([forawrd respondsToSelector:aSelector]) {
        return forawrd;
    }
    return nil;
}

@end
