//
//  OpenCVHandle.m
//  iOSDemo
//
//  Created by Stan Hu on 2019/2/27.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVHandle.h"
#import "opencvTool.h"
@interface OpenCVHandle (){
    cv::CascadeClassifier icon_cascade;//分类器
    BOOL isSuccessLoadXml;
}


@end

@implementation OpenCVHandle

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"lbpcascade_frontalface" ofType:nil];
        cv::String fileName = [bundlePath cStringUsingEncoding:NSUTF8StringEncoding];
        
        BOOL isSuccessLoadFile = icon_cascade.load(fileName);
        isSuccessLoadXml = isSuccessLoadFile;
        if (isSuccessLoadFile) {
            NSLog(@"Load success.......");
        }else{
            NSLog(@"Load failed......");
        }
    }
    return self;
}


- (UIImage *)RegImage:(CMSampleBufferRef)buff{
    if(!isSuccessLoadXml){
        return nil;
    }
    
    [NSThread sleepForTimeInterval:0.5];
    cv::Mat imgMat;
    imgMat = [opencvTool bufferToMat:buff]
    
    cv::cvtColor(imgMat, imgMat, cv::COLOR_BGR2GRAY);
    UIImage *tempImg = MatToUIImage(imgMat);
    
    //获取标记的矩形
    NSArray *rectArr = [self getTagRectInLayer:imgMat];
    //转换为图片
    UIImage *rectImg = [opencvTool imageWithColor:[UIColor redColor] size:tempImg.size rectArray:rectArr];
    
   
    
    return rectImg;
}

-(NSArray *)getTagRectInLayer:(cv::Mat) inputMat{
    if (inputMat.empty()) {
        return nil;
    }
    //图像均衡化
    cv::equalizeHist(inputMat, inputMat);
    //定义向量，存储识别出的位置
    std::vector<cv::Rect> glassess;
    //分类器识别
    icon_cascade.detectMultiScale(inputMat, glassess, 1.1, 3, 0);
    //转换为Frame，保存在数组中
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:glassess.size()];
    for (NSInteger i = 0; i < glassess.size(); i++) {
        CGRect rect = CGRectMake(glassess[i].x, glassess[i].y, glassess[i].width,glassess[i].height);
        NSValue *value = [NSValue valueWithCGRect:rect];
        [marr addObject:value];
    }
    return marr.copy;
}


@end
