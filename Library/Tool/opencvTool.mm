//
//  opencvTool.m
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/24.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "opencvTool.h"

@interface opencvTool ()

@end

@implementation opencvTool

+(UIImage*)getBinaryImage:(UIImage *)image{
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    cv::Mat bin;
    cv::threshold(gray, bin, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    UIImage *binImg = MatToUIImage(bin);
    return binImg;
}

+ (UIImage *)imageWithColor:(UIColor *)rectColor size:(CGSize)size rectArray:(NSArray *)rectArray{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    // 1.开启图片的图形上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    // 2.获取
    CGContextRef cxtRef = UIGraphicsGetCurrentContext();
    
    // 3.矩形框标记颜色
    //获取目标位置
    for (NSInteger i = 0; i < rectArray.count; i++) {
        NSValue *rectValue = rectArray[i];
        CGRect targetRect = rectValue.CGRectValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:5];
        //加路径添加到上下文
        CGContextAddPath(cxtRef, path.CGPath);
        [rectColor setStroke];
        [[UIColor clearColor] setFill];
        //渲染上下文里面的路径
        /**
         kCGPathFill,   填充
         kCGPathStroke, 边线
         kCGPathFillStroke,  填充&边线
         */
        CGContextDrawPath(cxtRef,kCGPathFillStroke);
    }
    
    //填充透明色
    CGContextSetFillColorWithColor(cxtRef, [UIColor clearColor].CGColor);
    
    CGContextFillRect(cxtRef, rect);
    
    // 4.获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5.关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 6.返回图片
    return img;
}


@end
