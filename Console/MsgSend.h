//
//  MsgSend.h
//  DemoConsole
//
//  Created by Stan Hu on 18/1/2017.
//  Copyright © 2017 StanHu. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
@protocol MyProtocal <NSObject>

-(void)doSOmeThing;

@end
@interface MsgSend : NSObject
-(id)initWithProtocal:(Protocol*)protocal observers:(NSSet*)observers;
-(void)addObserver:(id)observer;
-(void)removeObserver:(id)observer;
@end
