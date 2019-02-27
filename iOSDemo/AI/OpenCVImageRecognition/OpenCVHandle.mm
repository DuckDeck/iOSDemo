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
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"lbpcascade_frontalface.xml" ofType:nil];
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
    
    
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(buff);
    
    //锁定内存
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    // get the address to the image data
    void *imgBufAddr = CVPixelBufferGetBaseAddress(imgBuf);
    
    // get image properties
    int w = (int)CVPixelBufferGetWidth(imgBuf);
    int h = (int)CVPixelBufferGetHeight(imgBuf);
    
    // create the cv mat
    cv::Mat mat(h, w, CV_8UC4, imgBufAddr, 0);
    //    //转换为灰度图像
    //    cv::Mat edges;
    //    cv::cvtColor(mat, edges, CV_BGR2GRAY);
    
    //旋转90度
    cv::Mat transMat;
    cv::transpose(mat, transMat);
    
    //翻转,1是x方向，0是y方向，-1位Both
   
    cv::flip(transMat, imgMat, 1);
    
    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
    
    
    
    cv::cvtColor(imgMat, imgMat, cv::COLOR_BGR2GRAY);
    UIImage *tempImg = MatToUIImage(imgMat);
    
    //获取标记的矩形
    NSArray *rectArr = [self getTagRectInLayer:imgMat];
    
    NSLog(@"识别到%lu个目标",(unsigned long)[rectArr count]);
    
    //转换为图片
    UIImage *rectImg = [opencvTool imageWithColor:[UIColor redColor] size:tempImg.size rectArray:rectArr];
    
    return rectImg;
}


-(UIImage *) RegImage2:(UIImage* )img{
    if(!isSuccessLoadXml){
        return nil;
    }
    
    [NSThread sleepForTimeInterval:0.5];
    cv::Mat imgMat;
    
    UIImageToMat(img, imgMat);
        
    cv::cvtColor(imgMat, imgMat, cv::COLOR_BGR2GRAY);
    UIImage *tempImg = MatToUIImage(imgMat);
    
    //获取标记的矩形
    NSArray *rectArr = [self getTagRectInLayer:imgMat];
    
    NSLog(@"识别到%lu个目标",(unsigned long)[rectArr count]);
    
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
