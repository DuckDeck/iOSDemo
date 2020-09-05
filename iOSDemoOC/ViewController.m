//
//  ViewController.m
//  iOSDemoOC
//
//  Created by stan on 2020/5/12.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

#import "ViewController.h"
#import "RerangeBinaryViewController.h"
#import <objc/runtime.h>

@interface Person : NSObject
@property (nonatomic,strong) NSString* name;
-(NSString *)getName;
@end
@implementation Person

- (NSString *)getName{
    return @"superstar";
}

@end

@interface Man : Person

@end
@implementation Man

- (id)init
   {
       self = [super init];
       if (self) {
           NSLog(@"%@", NSStringFromClass([self class]));
           NSLog(@"%@", NSStringFromClass([super class]));
       }
       return self;
   }


@end

@interface ViewController ()
@property (nonatomic,strong) NSThread *thread;
@property (nonatomic) NSRunLoop *runloop;
@property (nonatomic) UITableView* tb;
@property (nonatomic,strong) NSArray* arr;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *pe;
    
    NSLog(@"Pe 是不是nil: %@",pe);
    
    NSString* name = [pe getName];
    
    NSLog(@"在p是nil的情况下获取name : %@",name);
    
    NSLog(@"Pe 的大小是 %lu", sizeof(pe));
     
    pe = [Person new];
    NSLog(@"Pe在实例化后的大小是 %lu", sizeof(pe));
    
    Man* m = [Man new];
    
    
    
    
    
    NSLog(@"任务1");
               dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
               dispatch_queue_t queue2 = dispatch_queue_create("myQueue2", DISPATCH_QUEUE_CONCURRENT);
               dispatch_async(queue, ^{
                   NSLog(@"任务2");
                   dispatch_sync(queue2, ^{
                       NSLog(@"任务3");
                   });
                   NSLog(@"任务4");
               });
               NSLog(@"任务5");
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
   __block int a = 0;
    while (a < 5) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            a++;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"a的值是：%d",a);

  
    
    
    
    Person* p = [Person new];
    p.name = @"我是无微不至";
    {
        Person* p2 = [Person new];
        objc_setAssociatedObject(p,@"test",p2,OBJC_ASSOCIATION_RETAIN);
        //使用  OBJC_ASSOCIATION_ASSIGN 关联的是这个指针，出了作用域这个变量就没了，所以在外面再用就会出错。 其实因为使用OBJC_ASSOCIATION_ASSIGN并没有对p2 引用 计数加1，所以出了作用域这个变量就没了
        //使用 OBJC_ASSOCIATION_COPY 因为没有实现copywithzone会报错
        //使用 OBJC_ASSOCIATION_RETAIN 这样这个变量引用计算就加1了，外面还可以访问
    }
    
    
    NSLog(@"%@",objc_getAssociatedObject(p, @"test"));
    
    [p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    [p setValue:@"张" forKey:@"name"];
    
   // [self test1];
    self.arr = @[@"二进制重排"];
    self.tb = [UITableView new];
    self.tb.frame = CGRectMake(0, 64, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    [self.view addSubview:self.tb];
    self.tb.dataSource = self;
    self.tb.delegate = self;
    self.tb.tableFooterView = [UIView new];
    
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"kvc trigger kvo");
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
