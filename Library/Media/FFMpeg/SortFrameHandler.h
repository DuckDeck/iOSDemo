//
//  SortFrameHandle.h
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVParseHandler.h"
NS_ASSUME_NONNULL_BEGIN
@protocol SortFrameHandlerDelegate <NSObject>

@optional
- (void)getSortedVideoNode:(CMSampleBufferRef)videoDataRef;

@end
@interface SortFrameHandler : NSObject
@property (weak  , nonatomic) id<SortFrameHandlerDelegate> delegate;

- (void)addDataToLinkList:(CMSampleBufferRef)videoDataRef;
- (void)cleanLinkList;
@end

NS_ASSUME_NONNULL_END
