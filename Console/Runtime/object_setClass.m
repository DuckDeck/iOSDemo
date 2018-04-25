//
//  object_setClass.m
//  Console
//
//  Created by Stan Hu on 25/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import <Foundation/Foundation.h>

//让我们来看看object_setClass
//object_setClass将一个对象设置为别的类类型，返回原来的Class

/*
 
 
Father* p1 = [Father new];
NSLog(@"p1 - %@",[p1 class]);

Class c1 = object_setClass(p1, [Son class]);
NSLog(@"c1 - %@",[c1 class]); // 返回原来的class
NSLog(@"p1 - %@",[p1 class]);  //设置新的class
Class d1 = object_setClass(p1, [NSString class]);
NSLog(@"d1 - %@",[d1 class]);  //返回原来的class
NSLog(@"p1 - %@",[p1 class]);  //设置新的class
NSLog(@"%@",p1); // 打出了这个错误信息，<invalid NS/CF object> ，但是不会挂。看来最还是转到子类
 
 */
