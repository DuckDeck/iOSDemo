//
//  AboutKVC.m
//  Console
//
//  Created by Stan Hu on 2019/3/13.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import "AboutKVC.h"
@interface Address()
@property (nonatomic,copy)NSString* country;
@end
@implementation Address
@end

@interface People()
@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) Address* address;
@property (nonatomic,assign) NSInteger age;
@end
@implementation People
-(void)setNilValueForKey:(NSString *)key{
    NSLog(@"不能将%@设成nil",key);
}
@end
