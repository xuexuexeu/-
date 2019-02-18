//
//  XKFileOutView.m
//  bluetoothTest
//
//  Created by apple on 2019/1/29.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "XKFileOutView.h"
#import "UIView+EXTION.h"
#import "XKSettingFileOut.h"
#define comonRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define comomScreenHeight   [UIScreen mainScreen].bounds.size.height
#define comomScreenWidth   [UIScreen mainScreen].bounds.size.width

//空字符串
#define     LocalStr_None           @""



@interface XKFileOutView()<XKSettingFileOutDelegate>
@property(strong,nonatomic)UIButton *camerSwitchBtn;
@property(strong,nonatomic)UIButton *flashlightSwitchBtn;
@property(strong,nonatomic)UIButton *startBtn;
@property(strong,nonatomic)XKSettingFileOut *settingObj;

@property(assign,nonatomic)BOOL cameraStatus;
@property(assign,nonatomic)BOOL flashlightStatus;
@end
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
@implementation XKFileOutView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //搭建界面
        [self settingFileOutUI];
    }
    return self;
}
//搭建界面
-(void)settingFileOutUI{
    //界面分成上下两部分
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
    topView.backgroundColor = comonRGBA(0, 0, 0, 0.3);
    [self addSubview:topView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.width, self.height-44)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];

    UIButton *camerSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerSwitchBtn setBackgroundImage:[UIImage imageNamed:@"listing_camera_lens"] forState:UIControlStateNormal];
    camerSwitchBtn.frame = CGRectMake(comomScreenWidth - 60 - 28, 11, 28, 22);
    [camerSwitchBtn addTarget:self action:@selector(changeCamerClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:camerSwitchBtn];
    
    UIButton *flashlightSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashlightSwitchBtn setBackgroundImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    flashlightSwitchBtn.frame = CGRectMake(comomScreenWidth - 22 - 15, 11, 22, 22);
    [flashlightSwitchBtn addTarget:self action:@selector(changeFlashlightClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:flashlightSwitchBtn];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setBackgroundColor:[UIColor grayColor]];
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    startBtn.frame = CGRectMake(comomScreenWidth*0.5-30, self.height-44-60-20, 60, 30);
    [startBtn addTarget:self action:@selector(startRecordingClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:startBtn];
    
    self.topView = topView;
    self.bottomView = bottomView;
    self.camerSwitchBtn = camerSwitchBtn;
    self.flashlightSwitchBtn = flashlightSwitchBtn;
    
    
    XKSettingFileOut *settingObj = [[XKSettingFileOut alloc] initObjWithStatusType:0 withSuperView:self];
    settingObj.delegate = self;
    self.settingObj = settingObj;
    
    //视频采集的对象  设置完成开始 录制视频  和各种按钮的点击事件

    
}
#pragma mark  按钮点击事件
//切换摄像头
-(void)changeCamerClick:(UIButton*)btn{
    self.cameraStatus = !self.cameraStatus;
    [self.settingObj changeSwitchCameraWithStatus:self.cameraStatus];
}
//切换闪光灯
-(void)changeFlashlightClick:(UIButton*)btn{
    self.flashlightStatus = !self.flashlightStatus;
    if (self.flashlightStatus) {
        [btn setBackgroundImage:[UIImage imageNamed:@"listing_flash_on"] forState:UIControlStateNormal];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"listing_flash_off"] forState:UIControlStateNormal];
    }
    [self.settingObj changeSwitchFlashlightWithStatus:self.flashlightStatus];
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
//录制视频按钮点击
-(void)startRecordingClick:(UIButton*)btn{
    //事件点击  分成开始 和结束
    if ([btn.titleLabel.text isEqualToString:@"开始"]) {
        //点击开始录制视频
        [btn setTitle:@"结束" forState:UIControlStateNormal];
        [self.settingObj startRecodingVideo];
    }else{
        //结束视频的录制
        [btn setTitle:@"开始" forState:UIControlStateNormal];
        [self.settingObj stopRecodingVideo];
    }
}

#pragma mark XKSettingFileOutDelegate 录制视频中产生的代理
-(void)finishRecordingVideoWith:(NSURL *)url{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileOutAndPlayWithUrl:)]) {
        [self.delegate fileOutAndPlayWithUrl:url];
    }
}

@end
