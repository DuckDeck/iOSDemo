//
//  AudioQueueCaptureManager.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "Singleton.h"
NS_ASSUME_NONNULL_BEGIN

@interface AudioQueueCaptureManager : NSObject
SingletonH
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, assign) BOOL isRecordVoice;

+ (instancetype)getInstance;


/**
 * Start / Stop Audio Queue
 */
- (void)startAudioCapture;
- (void)stopAudioCapture;


/**
 * Start / Pause / Stop record file
 */
- (void)startRecordFile;
- (void)pauseAudioCapture;
- (void)stopRecordFile;


/**
 * free related resources
 */
- (void)freeAudioCapture;
@end

NS_ASSUME_NONNULL_END
