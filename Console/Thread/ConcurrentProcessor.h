//
//  ConcurrentProcessor.h
//  Console
//
//  Created by Stan Hu on 2018/11/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConcurrentProcessor : NSObject
@property (readwrite) BOOL isFinished;
@property (readonly) NSInteger computeResult;
-(void)competeTask:(id)data;

+(void)testThis;

@end

NS_ASSUME_NONNULL_END
