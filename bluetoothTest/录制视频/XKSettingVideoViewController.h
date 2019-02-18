//
//  XKSettingVideoViewController.h
//  bluetoothTest
//
//  Created by apple on 2019/1/25.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XKSettingVideoViewControllerDelegate <NSObject>
-(void)playLuZhiVideoWithUrl:(NSURL*)videoUrl;
@end
@interface XKSettingVideoViewController : UIViewController
@property(weak,nonatomic)id<XKSettingVideoViewControllerDelegate>delegate;

@end
