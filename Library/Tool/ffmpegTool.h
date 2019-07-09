//
//  fmpegTool.h
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/25.
//  Copyright © 2018 Stan Hu. All rights reserved.
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



NS_ASSUME_NONNULL_BEGIN

@interface ffmpegTool : NSObject
+(void)initProject;
-(AVFormatContext *)createFormatContextByFilePath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
