//
//  fmpegTool.m
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/25.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "ffmpegTool.h"

@implementation ffmpegTool
+(void)initProject{
    av_register_all();
}
- (AVFormatContext *)createFormatContextByFilePath:(NSString *)path{
    if (path == nil) {
        NSLog(@"the file path is null");
        return NULL;
    }
    AVFormatContext *formatContext = NULL;
    AVDictionary *opts = NULL;
    av_dict_set(&opts, "timeout", "1000000", 0);
    
    formatContext = avformat_alloc_context();
    BOOL isSuccess = avformat_open_input(&formatContext, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, &opts) < 0 ? NO : YES;
    av_dict_free(&opts);
    
    if (!isSuccess) {
        if(formatContext){
            avformat_free_context(formatContext);
        }
        return NULL;
    }
    if (avformat_find_stream_info(formatContext, NULL) < 0)  {
        avformat_close_input(&formatContext);
        return  NULL;
    }
    return formatContext;
}

-(int)getAVStreamIndexWithFormatContext:(AVFormatContext *) formatContext isVideoStream:(BOOL)isVideoStream{
    int avStreamIndex = -1;
    for (int i = 0; i<formatContext->nb_streams; i++) {
        if ((isVideoStream ? AVMEDIA_TYPE_VIDEO : AVMEDIA_TYPE_AUDIO ) == formatContext->streams[i]->codecpar->codec_type) {
            avStreamIndex = i;
        }
    }
    if (avStreamIndex == -1) {
        NSLog(@"the video stream do not find");
        return avStreamIndex;
    }else{
        return avStreamIndex;
    }

}
@end
