//
//  FFmpegVideoDecoder.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

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
#include "libavutil/hwcontext.h"
#ifdef __cplusplus
};
#endif


@protocol FFmpegVideoDecoderDelegate <NSObject>

@optional
- (void)getDecodeVideoDataByFFmpeg:(CMSampleBufferRef _Nullable )sampleBuffer;

@end
NS_ASSUME_NONNULL_BEGIN

@interface FFmpegVideoDecoder : NSObject
@property (weak, nonatomic) id<FFmpegVideoDecoderDelegate> delegate;

- (instancetype)initWithFormatContext:(AVFormatContext *)formatContext videoStreamIndex:(int)videoStreamIndex;
- (void)startDecodeVideoDataWithAVPacket:(AVPacket)packet;
- (void)stopDecoder;
@end

NS_ASSUME_NONNULL_END
