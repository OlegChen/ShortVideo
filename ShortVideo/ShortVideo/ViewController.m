//
//  ViewController.m
//  ShortVideo
//
//  Created by apple on 2017/3/22.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import "ViewController.h"

#import "IDCaptureSessionPipelineViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
        
    UIButton *btn = [[UIButton alloc]init];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(100, 100, 100, 35);
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)click{


//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IDCaptureSessionPipelineViewController *viewController = [[IDCaptureSessionPipelineViewController alloc] init]; //[storyboard instantiateViewControllerWithIdentifier:@"captureSessionVC"];
    [viewController setupWithPipelineMode:PipelineModeAssetWriter];
    [self presentViewController:viewController animated:YES completion:nil];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
