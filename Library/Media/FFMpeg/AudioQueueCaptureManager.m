//
//  AudioQueueCaptureManager.m
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import "AudioQueueCaptureManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioFileHandler.h"
#import "AudioDecoder.h"
#define kXDXAudioPCMFramesPerPacket 1
#define kXDXAudioPCMBitsPerChannel  16

static const int kNumberBuffers = 3;

struct RecorderInfo {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
};

typedef struct RecorderInfo *RecorderInfoType;

static RecorderInfoType m_audioInfo;

@interface AudioQueueCaptureManager()
@property (nonatomic, assign, readwrite) BOOL isRunning;

@property (nonatomic, strong) AudioDecoder *audioDecoder;

@end
@implementation AudioQueueCaptureManager
SingletonM
#pragma mark - Callback
static void CaptureAudioDataCallback(void *                                 inUserData,
                                     AudioQueueRef                          inAQ,
                                     AudioQueueBufferRef                    inBuffer,
                                     const AudioTimeStamp *                 inStartTime,
                                     UInt32                                 inNumPackets,
                                     const AudioStreamPacketDescription*    inPacketDesc) {
    
    AudioQueueCaptureManager *instance = (__bridge AudioQueueCaptureManager *)inUserData;
    
    /*  Test audio fps
     static Float64 lastTime = 0;
     Float64 currentTime = CMTimeGetSeconds(CMClockMakeHostTimeFromSystemUnits(inStartTime->mHostTime))*1000;
     NSLog(@"Test duration - %f",currentTime - lastTime);
     lastTime = currentTime;
     */
    
    /*  Test size
     if (inPacketDesc) {
     NSLog(@"Test data: %d,%d,%d,%d",inBuffer->mAudioDataByteSize,inNumPackets,inPacketDesc->mDataByteSize,inPacketDesc->mVariableFramesInPacket);
     }else {
     NSLog(@"Test data: %d,%d",inBuffer->mAudioDataByteSize,inNumPackets);
     }
     */
    
    [instance.audioDecoder decodeAudioWithSourceBuffer:inBuffer->mAudioData
                                      sourceBufferSize:inBuffer->mAudioDataByteSize
                                       completeHandler:^(AudioBufferList * _Nonnull destBufferList, UInt32 outputPackets, AudioStreamPacketDescription * _Nonnull outputPacketDescriptions) {
                                           if (instance.isRecordVoice) {
                                               [[AudioFileHandler getInstance] writeFileWithInNumBytes:destBufferList->mBuffers->mDataByteSize
                                                                                             ioNumPackets:outputPackets
                                                                                                 inBuffer:destBufferList->mBuffers->mData
                                                                                             inPacketDesc:outputPacketDescriptions];
                                           }
                                           
                                           free(destBufferList->mBuffers->mData);
                                       }];
    
    if (instance.isRunning) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}



#pragma mark - Init
+ (void)initialize {
    m_audioInfo = malloc(sizeof(struct RecorderInfo));
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super init];
        
        // Note: Audio Convert need 1024 audio packet. so buffer size must set 1024. otherwise, the demo can't work.
        // Set audio queue capture aac data so that we will decode it later.
        [self configureAudioCaptureWithAudioInfo:m_audioInfo
                                        formatID:kAudioFormatMPEG4AAC // kAudioFormatLinearPCM
                                      sampleRate:44100
                                    channelCount:1
                                     durationSec:0.02
                                      bufferSize:1024
                                       isRunning:&self->_isRunning];
        
        // audio decode: aac->pcm
        self.audioDecoder = [[AudioDecoder alloc] initWithSourceFormat:m_audioInfo->mDataFormat
                                                             destFormatID:kAudioFormatLinearPCM
                                                               sampleRate:48000
                                                      isUseHardwareDecode:YES];
    });
    return _instace;
}

+ (instancetype)getInstance {
    return [[self alloc] init];
}

-(AudioStreamBasicDescription)getAudioFormatWithFormatID:(UInt32)formatID sampleRate:(Float64)sampleRate channelCount:(UInt32)channelCount {
    AudioStreamBasicDescription dataFormat = {0};
    
    UInt32 size = sizeof(dataFormat.mSampleRate);
    // Get hardware origin sample rate. (Recommended it)
    Float64 hardwareSampleRate = 0;
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
                            &size,
                            &hardwareSampleRate);
    // Manual set sample rate
    dataFormat.mSampleRate = sampleRate;
    
    size = sizeof(dataFormat.mChannelsPerFrame);
    // Get hardware origin channels number. (Must refer to it)
    UInt32 hardwareNumberChannels = 0;
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels,
                            &size,
                            &hardwareNumberChannels);
    dataFormat.mChannelsPerFrame = channelCount;
    
    // Set audio format
    dataFormat.mFormatID = formatID;
    
    // Set detail audio format params
    if (formatID == kAudioFormatLinearPCM) {
        dataFormat.mFormatFlags     = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        dataFormat.mBitsPerChannel  = kXDXAudioPCMBitsPerChannel;
        dataFormat.mBytesPerPacket  = dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel / 8) * dataFormat.mChannelsPerFrame;
        dataFormat.mFramesPerPacket = kXDXAudioPCMFramesPerPacket;
    }else if (formatID == kAudioFormatMPEG4AAC) {
        dataFormat.mFormatFlags = kMPEG4Object_AAC_Main;
    }
    
    NSLog(@"Audio Recorder: starup PCM audio encoder:%f,%d",sampleRate,channelCount);
    return dataFormat;
}

#pragma mark - Public
- (void)startAudioCapture {
    [self startAudioCaptureWithAudioInfo:m_audioInfo
                               isRunning:&_isRunning];
}

- (void)pauseAudioCapture {
    [self pauseAudioCaptureWithAudioInfo:m_audioInfo
                               isRunning:&_isRunning];
}

- (void)stopAudioCapture {
    [self stopAudioQueueRecorderWithAudioInfo:m_audioInfo
                                    isRunning:&_isRunning];
}

- (void)freeAudioCapture {
    [self freeAudioQueueRecorderWithAudioInfo:m_audioInfo
                                    isRunning:&_isRunning];
    
    [self.audioDecoder freeDecoder];
}

- (void)startRecordFile {
    [[AudioFileHandler getInstance] startVoiceRecordByAudioQueue:nil
                                                  isNeedMagicCookie:NO
                                                          audioDesc:self.audioDecoder->mDestinationFormat];
    self.isRecordVoice = YES;
    NSLog(@"Audio Recorder: Start record file.");
}

- (void)stopRecordFile {
    [[AudioFileHandler getInstance] stopVoiceRecordByAudioQueue:nil
                                                   needMagicCookie:NO];
    self.isRecordVoice = NO;
    NSLog(@"Audio Recorder: Stop record file.");
}

#pragma mark - Private
- (void)configureAudioCaptureWithAudioInfo:(RecorderInfoType)audioInfo formatID:(UInt32)formatID sampleRate:(Float64)sampleRate channelCount:(UInt32)channelCount durationSec:(float)durationSec bufferSize:(UInt32)bufferSize isRunning:(BOOL *)isRunning {
    // Get Audio format ASBD
    audioInfo->mDataFormat = [self getAudioFormatWithFormatID:formatID
                                                   sampleRate:sampleRate
                                                 channelCount:channelCount];
    
    // Set sample time
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:durationSec error:NULL];
    
    // New queue
    OSStatus status = AudioQueueNewInput(&audioInfo->mDataFormat,
                                         CaptureAudioDataCallback,
                                         (__bridge void *)(self),
                                         NULL,
                                         kCFRunLoopCommonModes,
                                         0,
                                         &audioInfo->mQueue);
    
    if (status != noErr) {
        NSLog(@"Audio Recorder: audio queue new input failed status:%d \n",(int)status);
    }
    
    // Set audio format for audio queue
    UInt32 size = sizeof(audioInfo->mDataFormat);
    status = AudioQueueGetProperty(audioInfo->mQueue,
                                   kAudioQueueProperty_StreamDescription,
                                   &audioInfo->mDataFormat,
                                   &size);
    if (status != noErr) {
        NSLog(@"Audio Recorder: get ASBD status:%d",(int)status);
    }
    
    // Set capture data size
    UInt32 maxBufferByteSize;
    if (audioInfo->mDataFormat.mFormatID == kAudioFormatLinearPCM) {
        int frames = (int)ceil(durationSec * audioInfo->mDataFormat.mSampleRate);
        maxBufferByteSize = frames*audioInfo->mDataFormat.mBytesPerFrame*audioInfo->mDataFormat.mChannelsPerFrame;
    }else {
        // AAC durationSec MIN: 23.219708 ms
        maxBufferByteSize = durationSec * audioInfo->mDataFormat.mSampleRate;
        
        if (maxBufferByteSize < 1024) {
            maxBufferByteSize = 1024;
        }
    }
    
    if (bufferSize > maxBufferByteSize || bufferSize == 0) {
        bufferSize = maxBufferByteSize;
    }
    
    // Allocate and Enqueue
    for (int i = 0; i != kNumberBuffers; i++) {
        status = AudioQueueAllocateBuffer(audioInfo->mQueue,
                                          bufferSize,
                                          &audioInfo->mBuffers[i]);
        if (status != noErr) {
            NSLog(@"Audio Recorder: Allocate buffer status:%d",(int)status);
        }
        
        status = AudioQueueEnqueueBuffer(audioInfo->mQueue,
                                         audioInfo->mBuffers[i],
                                         0,
                                         NULL);
        if (status != noErr) {
            NSLog(@"Audio Recorder: Enqueue buffer status:%d",(int)status);
        }
    }
}

- (BOOL)startAudioCaptureWithAudioInfo:(RecorderInfoType)audioInfo isRunning:(BOOL *)isRunning {
    if (*isRunning) {
        NSLog(@"Audio Recorder: Start recorder repeat");
        return NO;
    }
    
    OSStatus status = AudioQueueStart(audioInfo->mQueue, NULL);
    if (status != noErr) {
        NSLog(@"Audio Recorder: Audio Queue Start failed status:%d \n",(int)status);
        return NO;
    }else {
        NSLog(@"Audio Recorder: Audio Queue Start successful");
        *isRunning = YES;
        return YES;
    }
}
- (BOOL)pauseAudioCaptureWithAudioInfo:(RecorderInfoType)audioInfo isRunning:(BOOL *)isRunning {
    if (!*isRunning) {
        NSLog(@"Audio Recorder: audio capture is not running !");
        return NO;
    }
    
    OSStatus status = AudioQueuePause(audioInfo->mQueue);
    if (status != noErr) {
        NSLog(@"Audio Recorder: Audio Queue pause failed status:%d \n",(int)status);
        return NO;
    }else {
        NSLog(@"Audio Recorder: Audio Queue pause successful");
        *isRunning = NO;
        return YES;
    }
}

-(BOOL)stopAudioQueueRecorderWithAudioInfo:(RecorderInfoType)audioInfo isRunning:(BOOL *)isRunning {
    if (*isRunning == NO) {
        NSLog(@"Audio Recorder: Stop recorder repeat \n");
        return NO;
    }
    
    if (audioInfo->mQueue) {
        OSStatus stopRes = AudioQueueStop(audioInfo->mQueue, true);
        
        if (stopRes == noErr){
            NSLog(@"Audio Recorder: stop Audio Queue success.");
            return YES;
        }else{
            NSLog(@"Audio Recorder: stop Audio Queue failed.");
            return NO;
        }
    }else {
        NSLog(@"Audio Recorder: stop Audio Queue failed, the queue is nil.");
        return NO;
    }
}

-(BOOL)freeAudioQueueRecorderWithAudioInfo:(RecorderInfoType)audioInfo isRunning:(BOOL *)isRunning {
    if (*isRunning) {
        [self stopAudioQueueRecorderWithAudioInfo:audioInfo isRunning:isRunning];
    }
    
    if (audioInfo->mQueue) {
        for (int i = 0; i < kNumberBuffers; i++) {
            AudioQueueFreeBuffer(audioInfo->mQueue, audioInfo->mBuffers[i]);
        }
        
        OSStatus status = AudioQueueDispose(audioInfo->mQueue, true);
        if (status != noErr) {
            NSLog(@"Audio Recorder: Dispose failed: %d",status);
        }else {
            audioInfo->mQueue = NULL;
            *isRunning = NO;
            NSLog(@"Audio Recorder: free AudioQueue successful.");
            return YES;
        }
    }else {
        NSLog(@"Audio Recorder: free Audio Queue failed, the queue is nil.");
    }
    
    return NO;
}


#pragma mark Other
-(int)computeRecordBufferSizeFrom:(const AudioStreamBasicDescription *)format audioQueue:(AudioQueueRef)audioQueue durationSec:(float)durationSec {
    int packets = 0;
    int frames  = 0;
    int bytes   = 0;
    
    frames = (int)ceil(durationSec * format->mSampleRate);
    
    if (format->mBytesPerFrame > 0)
        bytes = frames * format->mBytesPerFrame;
    else {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0){   // CBR
            maxPacketSize = format->mBytesPerPacket;    // constant packet size
        }else { // VBR
            // AAC Format get kAudioQueueProperty_MaximumOutputPacketSize return -50. so the method is not effective.
            UInt32 propertySize = sizeof(maxPacketSize);
            OSStatus status     = AudioQueueGetProperty(audioQueue,
                                                        kAudioQueueProperty_MaximumOutputPacketSize,
                                                        &maxPacketSize,
                                                        &propertySize);
            if (status != noErr) {
                NSLog(@"%s: get max output packet size failed:%d",__func__,status);
            }
        }
        
        if (format->mFramesPerPacket > 0)
            packets = frames / format->mFramesPerPacket;
        else
            packets = frames;    // worst-case scenario: 1 frame in a packet
        if (packets == 0)        // sanity check
            packets = 1;
        bytes = packets * maxPacketSize;
    }
    
    return bytes;
}

- (void)printASBD:(AudioStreamBasicDescription)asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}

- (void)dealloc {
    free(m_audioInfo);
}
@end
