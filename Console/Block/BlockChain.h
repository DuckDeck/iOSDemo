//
//  BlockChain.h
//  Console
//
//  Created by Stan Hu on 2019/11/19.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlockChain : NSObject
-(BlockChain *)chain1;
-(void)chain2;

-(void (^)(NSString *))chain3;

@end

NS_ASSUME_NONNULL_END
