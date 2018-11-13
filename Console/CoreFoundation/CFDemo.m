//
//  CFDemo.m
//  Console
//
//  Created by Stan Hu on 2018/11/13.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

#import "CFDemo.h"

@implementation CFDemo
+(void)test{
    CFStringRef cstr = CFStringCreateWithCString(NULL, "Stan Hu", kCFStringEncodingUTF8);
    NSArray* arrStr = [NSArray arrayWithObject:(__bridge_transfer id _Nonnull)(cstr)];
    //        __bridge_transfer 将CF对象转到ARC对象，并由ARC来管理，不用自己手动release
    //        __bridge并不会改变对像的所有权，如果是将CF对象转到ARC的Foundation，那么要自己管理，或者使用__bridge_transfer来让SARC管理
    //如果把Foundation对象转对CF对象，那么因为Foundation对象是ARC，那么转换后的CF对像也是ARC管理的
    //        __bridge_retained将Foundation对象转对CF对象，并且
    //        NSArray* arrStr = [NSArray arrayWithObject:(cstr)]; //不能隐式转换，要用__bridge显式转换
    //CFRelease(cstr);  如果用__bridge_transfer用不需要 自己手动release了
    NSString* nstr = @"Shadow edge";
    CFStringRef cftr = (__bridge_retained CFStringRef)(nstr); //__bridge后不要自己release,好像__bridge_retained也不用，Analyze没有季问题
    printf("strinf length = %ld \n",(long)CFStringGetLength(cftr));
    NSLog(@"%@",arrStr[0]);
    //        CFRelease(cftr);
}
@end
