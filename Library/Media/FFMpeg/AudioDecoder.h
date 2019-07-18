//
//  AudioDecoder.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioDecoder : NSObject
{
    @public
    AudioConverterRef mAudioConverter;
    AudioStreamBasicDescription mDestinationFormat;
    AudioStreamBasicDescription mSourceFormat;
}

/**
Init Audio Encoder
@param sourceFormat source audio data format
@param destFormatID destination audio data format
@param isUseHardwareDecode Use hardware / software encode
@return object.
*/
- (instancetype)initWithSourceFormat:(AudioStreamBasicDescription)sourceFormat
                        destFormatID:(AudioFormatID)destFormatID
                          sampleRate:(float)sampleRate
                 isUseHardwareDecode:(BOOL)isUseHardwareDecode;



/**
 Encode Audio Data
 @param sourceBuffer source audio data
 @param sourceBufferSize source audio data size
 @param completeHandler get audio data after encoding
 */
- (void)decodeAudioWithSourceBuffer:(void *)sourceBuffer
                   sourceBufferSize:(UInt32)sourceBufferSize
                    completeHandler:(void(^)(AudioBufferList *destBufferList, UInt32 outputPackets, AudioStreamPacketDescription *outputPacketDescriptions))completeHandler;


- (void)freeDecoder;

@end

NS_ASSUME_NONNULL_END
