//
//  ViewController.m
//  FDanmakuDemo
//
//  Created by allison on 2018/5/17.
//  Copyright © 2018年 allison. All rights reserved.
//

#import "DanmuViewController.h"
#import "FDanmakuView.h"
#import "FDanmakuModel.h"

@interface DanmuViewController ()<FDanmakuViewProtocol>
@property(nonatomic,weak)FDanmakuView *danmakuView;
@end

@implementation DanmuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    FDanmakuView *danmaView = [[FDanmakuView alloc]initWithFrame:CGRectMake(100, 120, 250, 200)];
    danmaView.userInteractionEnabled = YES;
    danmaView.backgroundColor = [UIColor orangeColor];
    danmaView.delegate = self;
    self.danmakuView = danmaView;
    [self.view addSubview:danmaView];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    FDanmakuModel *model1 = [[FDanmakuModel alloc]init];
    model1.beginTime = 3;  //弹幕开始的时间
    model1.liveTime = 7;  //速度的时间
    model1.content = @"哈哈哈~😊🙂😎~~~";
    
    FDanmakuModel *model2 = [[FDanmakuModel alloc]init];
    model2.beginTime = 3.2;
    model2.liveTime = 8;
    model2.content = @"23322333";
    
    FDanmakuModel *model3 = [[FDanmakuModel alloc]init];
    model3.beginTime = 3.5;
    model3.liveTime = 9;
    model3.content = @"111😊🙂😎111";
    
    [self.danmakuView.modelsArr addObject:model1];
    [self.danmakuView.modelsArr addObject:model2];
    [self.danmakuView.modelsArr addObject:model3];
    
}



#pragma mark  danmakuView  delegate
-(NSTimeInterval)currentTime {
    //时间的懒加载
    static double time = 0;
    time += 0.1 ;
    return time;
}

//创建弹幕内容  lab
- (UIView *)danmakuViewWithModel:(FDanmakuModel*)model {
    
    UILabel *label = [UILabel new];
    label.text = model.content;
    [label sizeToFit];
    return label;
    
}

//点击弹幕
- (void)danmuViewDidClick:(UIView *)danmuView at:(CGPoint)point {
    NSLog(@"%@ %@",danmuView,NSStringFromCGPoint(point));
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
