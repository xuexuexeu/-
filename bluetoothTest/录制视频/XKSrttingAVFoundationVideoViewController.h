//
//  XKSrttingAVFoundationVideoViewController.h
//  bluetoothTest
//
//  Created by apple on 2019/1/28.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XKSrttingAVFoundationVideoViewControllerDelegate <NSObject>
-(void)playAVFoundationLuZhiVideoWithUrl:(NSURL*)videoUrl;
@end
@interface XKSrttingAVFoundationVideoViewController : UIViewController
@property(weak,nonatomic)id<XKSrttingAVFoundationVideoViewControllerDelegate>delegate;
@end
