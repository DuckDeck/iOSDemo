//
//  UIImage+OpenCV.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/10/8.
//  Copyright © 2019 Stan Hu. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (OpenCV)
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithCVMat:(const cv::Mat&)cvMat;

    //UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // no alpha channel
- (cv::Mat)CVGrayscaleMat;

@end

NS_ASSUME_NONNULL_END
