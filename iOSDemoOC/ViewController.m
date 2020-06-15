//
//  ViewController.m
//  iOSDemoOC
//
//  Created by stan on 2020/5/12.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSThread *thread;
@property (nonatomic) NSRunLoop *runloop;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    
   // [self test1];
    
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"1--------");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         NSLog(@"2--------");
//        [self performSelector:@selector(test) withObject:nil];  //1243
//        [self performSelector:@selector(test) withObject:nil afterDelay:0]; //123 ,selector 不执行了
 //       [self performSelector:@selector(test) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO]; //123
        [self performSelector:@selector(test) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES]; //1234

         NSLog(@"3--------");
    });
    
}


-(void)test{
    NSLog(@"4--------");

}

-(void)test1{
    [self.thread setName:@"StopRunloopThread"];
    self.runloop = [NSRunLoop currentRunLoop];
    [self performSelector:@selector(testSelect) withObject:nil afterDelay:2];
    [self.runloop run];
    NSLog(@"有没有跑到这");
}

-(void)testSelect{
    NSLog(@"%s",__func__);
}
@end
