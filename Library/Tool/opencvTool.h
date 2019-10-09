//
//  opencvTool.h
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/24.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/video/video.hpp>
#import <opencv2/highgui/highgui_c.h>
#endif
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


typedef  void (^imageFrame)(UIImage *);

NS_ASSUME_NONNULL_BEGIN

@interface opencvTool : NSObject
+(UIImage *)getBinaryImage:(UIImage *)image;
+(NSArray *)getVideoImage:(NSString *)path;
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
