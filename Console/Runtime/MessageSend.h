//
//  MessageSend.h
//  Console
//
//  Created by Stan Hu on 2019/10/22.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageSend : NSObject
-(void)test;
@end

NS_ASSUME_NONNULL_END

@interface Person : NSObject
@property (nonatomic, strong) NSString* _Nullable name;
@end
