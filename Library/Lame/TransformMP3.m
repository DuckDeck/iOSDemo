//
//  TransformMP3.m
//  RecordToMP3
//
//  Created by 周鑫 on 2017/9/25.
//  Copyright © 2017年 周鑫. All rights reserved.
//

#import "TransformMP3.h"
#import "lame.h"

@implementation TransformMP3

+ (NSDictionary *)transformCAFToMP3:(NSString *)recordFilePath {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yy-MM-dd_HH:mm:ss";
    NSString *nowTime = [format stringFromDate:[NSDate date]];    //保存到Document中
    NSString *fileName = [NSString stringWithFormat:@"/%@.mp3", nowTime];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:fileName];
    
    NSDictionary *dict = @{@"fileName" : fileName, @"filePath" : filePath};
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([recordFilePath cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR);//删除头，否则在前一秒钟会有杂音
        FILE *mp3 = fopen([filePath cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"error = %@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功!!!");
        return dict;
       
    }
}

- (NSString *)nowTime {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yy-MM-dd_HH:mm:ss";
    NSString *nowTime = [format stringFromDate:[NSDate date]];
    return nowTime;
}

@end
