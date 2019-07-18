//
//  AudioFileHandler.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "Singleton.h"
NS_ASSUME_NONNULL_BEGIN

@interface AudioFileHandler : NSObject

SingletonH

+ (instancetype)getInstance;
/**
 * Write audio data to file.
 */
- (void)writeFileWithInNumBytes:(UInt32)inNumBytes
                   ioNumPackets:(UInt32 )ioNumPackets
                       inBuffer:(const void *)inBuffer
                   inPacketDesc:(nullable const AudioStreamPacketDescription*)inPacketDesc;

#pragma mark - Audio Queue
/**
 * Start / Stop record By Audio Queue.
 */
-(void)startVoiceRecordByAudioQueue:(nullable AudioQueueRef)audioQueue
                  isNeedMagicCookie:(BOOL)isNeedMagicCookie
                          audioDesc:(AudioStreamBasicDescription)audioDesc;

-(void)stopVoiceRecordByAudioQueue:(nullable AudioQueueRef)audioQueue
                   needMagicCookie:(BOOL)isNeedMagicCookie;


/**
 * Start / Stop record By Audio Converter.
 */
-(void)startVoiceRecordByAudioUnitByAudioConverter:(nullable AudioConverterRef)audioConverter
                                   needMagicCookie:(BOOL)isNeedMagicCookie
                                         audioDesc:(AudioStreamBasicDescription)audioDesc;

-(void)stopVoiceRecordAudioConverter:(nullable AudioConverterRef)audioConverter
                     needMagicCookie:(BOOL)isNeedMagicCookie;

@end

NS_ASSUME_NONNULL_END
