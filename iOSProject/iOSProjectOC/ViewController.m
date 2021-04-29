//
//  ViewController.m
//  iOSProjectOC
//
//  Created by chen liang on 2021/3/17.
//

#import "ViewController.h"
#import "diff.h"
@interface ViewController ()
@property (strong,nonatomic) UITextField* txt;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"差分" style:UIBarButtonItemStylePlain target:self action:@selector(createDiffPackage)],[[UIBarButtonItem alloc] initWithTitle:@"合并" style:UIBarButtonItemStylePlain target:self action:@selector(joinPackage)]];
    
     _txt = [UITextField new];
    _txt.frame = CGRectMake(10, 10, 200, 100);
    [self.view addSubview:_txt];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _txt.text = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)createDiffPackage{
    const char *argv[4];
    argv[0] = "bsdiff";
    // oldPath
    NSString *path1 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"old.zip"];
    argv[1] = [path1 UTF8String];
    // new path
    NSString *path2 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"new.zip"];
    argv[2] = [path2 UTF8String];
    argv[3] = [[self createFile:@"diff_Test"] UTF8String];
    int result = BsdiffUntils_bsdiff(4, argv);
    if (result == 0) {
        NSLog(@"成功生成差分文件,路径是%s",argv[3]);
    }
}

-(void)joinPackage{
    const char *argv[4];
    argv[0] = "bspatch";
    // oldPath
    NSString *path1 = [NSString stringWithFormat:@"/%@/%@",[NSBundle mainBundle].bundlePath, @"old.zip"];
    argv[1] = [path1 UTF8String];
    // patch new path
    argv[2] = [[self createFile:@"test.zip"] UTF8String];
    argv[3] = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"diff_Test"] UTF8String];
    int result = BsdiffUntils_bspatch(4, argv);
    if (result == 0) {
        NSLog(@"成功合并差分文件,路径是%s",argv[2]);
    }
}

-(NSString* )createFile:(NSString*)file{
    NSString* tem = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* filePath = [tem stringByAppendingPathComponent:file];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (!isExist) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return  filePath;
}

@end
