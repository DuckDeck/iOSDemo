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

@end
