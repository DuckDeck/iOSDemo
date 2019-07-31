//
//  CategoryDemo.h
//  Console
//
//  Created by Stan Hu on 2019/7/24.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryDemo : NSObject
- (void)ins_method1;
+ (void)cls_method1;
@end

NS_ASSUME_NONNULL_END

@interface CategoryDemo (AA)
- (void)ins_method2;
- (void)ins_method22;
+ (void)cls_method2;
@end

@interface CategoryDemo (BB)
- (void)ins_method3;
+ (void)cls_method3;

@end
