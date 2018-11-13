//
//  Runspector.h
//  Console
//
//  Created by stanhu on 2018/11/13.
//  Copyright © 2018年 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
NS_ASSUME_NONNULL_BEGIN

@interface Runspector : NSObject
+(void)testClass;
+(void)dynaClass;
@end

NS_ASSUME_NONNULL_END


@interface testClass : NSObject{
@public int myInt;
}
@end
