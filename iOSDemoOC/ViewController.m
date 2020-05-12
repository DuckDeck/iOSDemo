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
    
    [self test1];
    
    
    
    
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
