//
//  PreviewView.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewView : UIView
@property (nonatomic,assign,getter=isFullScreen) BOOL fullScreen;
-(void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

NS_ASSUME_NONNULL_END
