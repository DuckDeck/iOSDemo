//
//  FFmpegVideoDecoder.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

// FFmpeg Header File
#ifdef __cplusplus
extern "C" {
#endif
    
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libavutil/avutil.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/opt.h"
    
#ifdef __cplusplus
};
#endif


@protocol FFmpegVideoDecoderDelegate <NSObject>

@optional
- (void)getDecodeVideoDataByFFmpeg:(CMSampleBufferRef)sampleBuffer;

@end
NS_ASSUME_NONNULL_BEGIN

@interface FFmpegVideoDecoder : NSObject

@end

NS_ASSUME_NONNULL_END
