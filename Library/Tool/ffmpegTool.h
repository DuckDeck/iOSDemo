//
//  fmpegTool.h
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/25.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ffmpegTool : NSObject
+(void)initProject;
-(AVFormatContext *)createFormatContextByFilePath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
