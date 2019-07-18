//
//  AudioFileHandler.m
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import "AudioFileHandler.h"
static const NSString *kModuleName = @"Audio File";
@interface AudioFileHandler(){
    AudioFileID m_recordFile;
    SInt64 m_recordCurrentPacket;
}
@property (nonatomic,copy) NSString *recordFilePath;
@end
@implementation AudioFileHandler
SingletonH
#pragma mark - Init
+ (instancetype)getInstance {
    return [[self alloc] init];
}

#pragma mark - Public
-(void)startVoiceRecordByAudioUnitByAudioConverter:(nullable AudioConverterRef)audioConverter needMagicCookie:(BOOL)isNeedMagicCookie audioDesc:(AudioStreamBasicDescription)audioDesc {
    self.recordFilePath = [self createFilePath];
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,self.recordFilePath);
    
    // create the audio file
    m_recordFile = [self createAudioFileWithFilePath:self.recordFilePath
                                           AudioDesc:audioDesc];
    
    if (isNeedMagicCookie) {
        // add magic cookie contain header file info for VBR data
        [self copyEncoderCookieToFileByAudioConverter:audioConverter
                                               inFile:m_recordFile];
    }
}
-(void)stopVoiceRecordAudioConverter:(nullable AudioConverterRef)audioConverter needMagicCookie:(BOOL)isNeedMagicCookie {
    if (isNeedMagicCookie) {
        // reconfirm magic cookie at the end.
        [self copyEncoderCookieToFileByAudioConverter:audioConverter
                                               inFile:m_recordFile];
    }
    
    AudioFileClose(m_recordFile);
    m_recordCurrentPacket = 0;
}

-(void)startVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue isNeedMagicCookie:(BOOL)isNeedMagicCookie audioDesc:(AudioStreamBasicDescription)audioDesc {
    self.recordFilePath = [self createFilePath];
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,self.recordFilePath);
    
    // create the audio file
    m_recordFile = [self createAudioFileWithFilePath:self.recordFilePath
                                           AudioDesc:audioDesc];
    
    if (isNeedMagicCookie) {
        // add magic cookie contain header file info for VBR data
        [self copyEncoderCookieToFileByAudioQueue:audioQueue
                                           inFile:m_recordFile];
    }
}

-(void)stopVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue needMagicCookie:(BOOL)isNeedMagicCookie {
    if (isNeedMagicCookie) {
        // reconfirm magic cookie at the end.
        [self copyEncoderCookieToFileByAudioQueue:audioQueue
                                           inFile:m_recordFile];
    }
    
    AudioFileClose(m_recordFile);
    m_recordCurrentPacket = 0;
}

- (void)writeFileWithInNumBytes:(UInt32)inNumBytes ioNumPackets:(UInt32 )ioNumPackets inBuffer:(const void *)inBuffer inPacketDesc:(nullable const AudioStreamPacketDescription*)inPacketDesc {
    if (!m_recordFile) {
        return;
    }
    
    //    AudioStreamPacketDescription outputPacketDescriptions;
    OSStatus status = AudioFileWritePackets(m_recordFile,
                                            false,
                                            inNumBytes,
                                            inPacketDesc,
                                            m_recordCurrentPacket,
                                            &ioNumPackets,
                                            inBuffer);
    
    if (status == noErr) {
        m_recordCurrentPacket += ioNumPackets;  // 用于记录起始位置
    }else {
        NSLog(@"%@:%s - write file status = %d \n",kModuleName,__func__,(int)status);
    }
    
}

#pragma mark - Private
#pragma mark File Path
- (NSString *)createFilePath {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd__HH_mm_ss";
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *searchPaths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES);
    
    NSString *documentPath  = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"Voice"];
    
    // 先创建子目录. 注意,若果直接调用AudioFileCreateWithURL创建一个不存在的目录创建文件会失败
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentPath]) {
        [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fullFileName  = [NSString stringWithFormat:@"%@.caf",date];
    NSString *filePath      = [documentPath stringByAppendingPathComponent:fullFileName];
    return filePath;
}

- (AudioFileID)createAudioFileWithFilePath:(NSString *)filePath AudioDesc:(AudioStreamBasicDescription)audioDesc {
    CFURLRef url            = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)filePath, NULL);
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,filePath);
    
    AudioFileID audioFile;
    // create the audio file
    OSStatus status = AudioFileCreateWithURL(url,
                                             kAudioFileCAFType,
                                             &audioDesc,
                                             kAudioFileFlags_EraseFile,
                                             &audioFile);
    if (status != noErr) {
        NSLog(@"%@:%s - AudioFileCreateWithURL Failed, status:%d",kModuleName,__func__,(int)status);
    }
    
    CFRelease(url);
    
    return audioFile;
}

#pragma mark Magic Cookie
- (void)copyEncoderCookieToFileByAudioQueue:(AudioQueueRef)inQueue inFile:(AudioFileID)inFile {
    OSStatus result = noErr;
    UInt32 cookieSize;
    
    result = AudioQueueGetPropertySize (
                                        inQueue,
                                        kAudioQueueProperty_MagicCookie,
                                        &cookieSize
                                        );
    if (result == noErr) {
        char* magicCookie = (char *) malloc (cookieSize);
        result =AudioQueueGetProperty (
                                       inQueue,
                                       kAudioQueueProperty_MagicCookie,
                                       magicCookie,
                                       &cookieSize
                                       );
        if (result == noErr) {
            result = AudioFileSetProperty (
                                           inFile,
                                           kAudioFilePropertyMagicCookieData,
                                           cookieSize,
                                           magicCookie
                                           );
            if (result == noErr) {
                NSLog(@"%@:%s - set Magic cookie successful.",kModuleName,__func__);
            }else {
                NSLog(@"%@:%s - set Magic cookie failed.",kModuleName,__func__);
            }
        }else {
            NSLog(@"%@:%s - get Magic cookie failed.",kModuleName,__func__);
        }
        free (magicCookie);
        
    }else {
        NSLog(@"%@:%s - Magic cookie: get size failed.",kModuleName,__func__);
    }
    
}

-(void)copyEncoderCookieToFileByAudioConverter:(AudioConverterRef)audioConverter inFile:(AudioFileID)inFile {
    // Grab the cookie from the converter and write it to the destination file.
    UInt32 cookieSize = 0;
    OSStatus error = AudioConverterGetPropertyInfo(audioConverter, kAudioConverterCompressionMagicCookie, &cookieSize, NULL);
    
    if (error == noErr && cookieSize != 0) {
        char *cookie = (char *)malloc(cookieSize * sizeof(char));
        error        = AudioConverterGetProperty(audioConverter, kAudioConverterCompressionMagicCookie, &cookieSize, cookie);
        
        if (error == noErr) {
            error = AudioFileSetProperty(inFile, kAudioFilePropertyMagicCookieData, cookieSize, cookie);
            if (error == noErr) {
                UInt32 willEatTheCookie = false;
                error = AudioFileGetPropertyInfo(inFile, kAudioFilePropertyMagicCookieData, NULL, &willEatTheCookie);
                if (error == noErr) {
                    NSLog(@"%@:%s - Writing magic cookie to destination file: %u   cookie:%d \n",kModuleName,__func__, (unsigned int)cookieSize, willEatTheCookie);
                }else {
                    NSLog(@"%@:%s - Could not Writing magic cookie to destination file status:%d \n",kModuleName,__func__,(int)error);
                }
            } else {
                NSLog(@"%@:%s - Even though some formats have cookies, some files don't take them and that's OK,set cookie status:%d \n",kModuleName,__func__,(int)error);
            }
        } else {
            NSLog(@"%@:%s - Could not Get kAudioConverterCompressionMagicCookie from Audio Converter!\n status:%d ",kModuleName,__func__,(int)error);
        }
        
        free(cookie);
    }else {
        // If there is an error here, then the format doesn't have a cookie - this is perfectly fine as som formats do not.
        NSLog(@"%@:%s - cookie status:%d, %d \n",kModuleName,__func__,(int)error, cookieSize);
    }
}


@end
