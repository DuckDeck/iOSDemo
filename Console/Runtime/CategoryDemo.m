//
//  CategoryDemo.m
//  Console
//
//  Created by Stan Hu on 2019/7/24.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

#import "CategoryDemo.h"

@implementation CategoryDemo
-(void)ins_method1{
    NSLog(@"%s", __func__);
}
+(void)cls_method1{
    NSLog(@"%s", __func__);
}
@end

@implementation CategoryDemo(AA)

-(void)ins_method2{
    NSLog(@"%s", __func__);
}
-(void)ins_method22{
    NSLog(@"%s", __func__);
}
+(void)cls_method2{
    NSLog(@"%s", __func__);
}
@end

@implementation CategoryDemo (BB)

-(void)ins_method3{
    NSLog(@"%s", __func__);
}
+(void)cls_method3{
    NSLog(@"%s", __func__);
}

@end
