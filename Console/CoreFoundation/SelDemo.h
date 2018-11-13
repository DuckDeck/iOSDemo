//
//  SelDemo.h
//  Console
//
//  Created by stanhu on 2018/11/13.
//  Copyright © 2018年 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelDemo : NSObject
-(NSNumber *) sumAddend1:(NSNumber *)addre1 addend2:(NSNumber*)adder2;
-(NSNumber *) sumAddend1:(NSNumber *)addre1 :(NSNumber*)adder2;
+(void)testSel;
+(void)testSelDynamic;
+(void)testSelString;
@end

NS_ASSUME_NONNULL_END
