//
//  opencvTool.m
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/24.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "opencvTool.h"
using namespace cv;
@interface opencvTool ()

@end

@implementation opencvTool
static VideoCapture  cap;
static NSString* currentPath;
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

+(NSArray *)getVideoImage:(NSString *)path{
    
    if (![path isEqualToString:currentPath] && !cap.isOpened()){
        currentPath = path;
        cap.open(std::string(path.UTF8String));
    }
    if (cap.isOpened()){
        Mat originFrame, frame;
        if(cap.read(frame)){
            frame.copyTo(originFrame);
            cvtColor(frame, frame, CV_RGB2GRAY);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            adaptiveThreshold(frame, frame, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, 5, 2);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            threshold(frame, frame, 200, 255, THRESH_BINARY);
            bitwise_not(frame, frame);
            Mat ken = getStructuringElement(MORPH_RECT, cv::Size(3,3));
            morphologyEx(frame, frame, MORPH_OPEN, ken);
            ken.release();
            bitwise_not(frame, frame);
            GaussianBlur(frame, frame, cv::Size(5,5), 0);
            
            return @[MatToUIImage(originFrame),MatToUIImage(frame)];
        }
        else{
            cap.release();
        }
       
    }
    return NULL;
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
