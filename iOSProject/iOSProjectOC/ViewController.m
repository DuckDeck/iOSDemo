//
//  ViewController.m
//  iOSProjectOC
//
//  Created by chen liang on 2021/3/17.
//

#import "ViewController.h"
#include "bsdiff.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"差分" style:UIBarButtonItemStylePlain target:self action:@selector(createDiffPackage)];
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
    int result = makeDiff(4, argv);
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
