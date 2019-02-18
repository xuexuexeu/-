//
//  XKFileOutView.h
//  bluetoothTest
//
//  Created by apple on 2019/1/29.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XKFileOutViewDelegate <NSObject>
-(void)fileOutAndPlayWithUrl:(NSURL*)url;
@end
@interface XKFileOutView : UIView
@property(weak,nonatomic)id<XKFileOutViewDelegate>delegate;

@property(strong,nonatomic)UIView *topView;
@property(strong,nonatomic)UIView *bottomView;
@end
