//
//  TransformMP3.h
//  RecordToMP3
//
//  Created by 周鑫 on 2017/9/25.
//  Copyright © 2017年 周鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransformMP3 : NSObject

+ (NSDictionary *)transformCAFToMP3:(NSString *)recordFilePath;
@end
