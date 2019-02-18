//
//  XKSrttingAVFoundationVideoViewController.m
//  bluetoothTest
//
//  Created by apple on 2019/1/28.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "XKSrttingAVFoundationVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import <a>
#import "XKFileOutView.h"
#import "UIView+EXTION.h"

@interface XKSrttingAVFoundationVideoViewController ()<XKFileOutViewDelegate>

@end

@implementation XKSrttingAVFoundationVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"AVAsset录制";
    self.view.backgroundColor = [UIColor whiteColor];
    //先设置界面
    XKFileOutView *fileoutView = [[XKFileOutView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
    fileoutView.delegate = self;
//    fileoutView.backgroundColor = [UIColor redColor];
    [self.view addSubview:fileoutView];
    //然后录制后返回播放
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  XKFileOutViewDelegate
//播放视频
-(void)fileOutAndPlayWithUrl:(NSURL *)url{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playAVFoundationLuZhiVideoWithUrl:)]) {
        [self.delegate  playAVFoundationLuZhiVideoWithUrl:url];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

@end
