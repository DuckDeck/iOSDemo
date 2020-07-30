//
//  ViewController.m
//  iOSDemoOC
//
//  Created by stan on 2020/5/12.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

#import "ViewController.h"
#import "RerangeBinaryViewController.h"
@interface ViewController ()
@property (nonatomic,strong) NSThread *thread;
@property (nonatomic) NSRunLoop *runloop;
@property (nonatomic) UITableView* tb;
@property (nonatomic,strong) NSArray* arr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    
   // [self test1];
    self.arr = @[@"二进制重排"];
    self.tb = [UITableView new];
    self.tb.frame = CGRectMake(0, 64, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    [self.view addSubview:self.tb];
    self.tb.dataSource = self;
    self.tb.delegate = self;
    self.tb.tableFooterView = [UIView new];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.arr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[RerangeBinaryViewController new] animated:YES];
            break;
            
        default:
            break;
    }
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
