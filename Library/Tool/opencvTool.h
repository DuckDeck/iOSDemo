//
//  opencvTool.h
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/24.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface opencvTool : NSObject
+(UIImage *)getBinaryImage:(UIImage *)image;

/**
 生成一张用矩形框标记目标的图片
 
 @param rectColor 矩形的颜色
 @param size 图片大小，一般和视频帧大小相同
 @param rectArray 需要标记的CGRect数组
 @return 返回一张图片
 */
+ (UIImage *)imageWithColor:(UIColor *)rectColor size:(CGSize)size rectArray:(NSArray *)rectArray;



@end

NS_ASSUME_NONNULL_END
