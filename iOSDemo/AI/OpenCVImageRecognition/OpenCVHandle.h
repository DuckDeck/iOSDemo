//
//  OpenCVHandle.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/2/27.
//  Copyright © 2019 Stan Hu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenCVHandle : NSObject

-(UIImage *) RegImage:(CMSampleBufferRef)buff;
-(UIImage *) RegImage2:(UIImage* )img;
@end

NS_ASSUME_NONNULL_END
