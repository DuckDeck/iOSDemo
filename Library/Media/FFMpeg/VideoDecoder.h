//
//  VideoDecoder.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVParseHandler.h"
NS_ASSUME_NONNULL_BEGIN

@protocol VideoDecoderDelegate <NSObject>

@optional
- (void)getVideoDecodeDataCallback:(CMSampleBufferRef)sampleBuffer isFirstFrame:(BOOL)isFirstFrame;

@end

@interface VideoDecoder : NSObject
@property (weak, nonatomic) id<VideoDecoderDelegate> delegate;
/**
 Start / Stop decoder
 */
- (void)startDecodeVideoData:(struct ParseVideoDataInfo *)videoInfo;
- (void)stopDecoder;


/**
 Reset timestamp when you parse a new file (only use the decoder as global var)
 */
- (void)resetTimestamp;
@end

NS_ASSUME_NONNULL_END
