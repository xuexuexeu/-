//
//  XKSettingFileOut.h
//  bluetoothTest
//
//  Created by apple on 2019/1/29.
//  Copyright © 2019年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//@protocol XKSettingFileOutDelegate <NSObject>
//
//- (void)updateFlashState:(FMFlashState)state;
//- (void)updateRecordingProgress:(CGFloat)progress;
//- (void)updateRecordState:(FMRecordState)recordState;
//
//@end
@protocol XKSettingFileOutDelegate <NSObject>
-(void)finishRecordingVideoWith:(NSURL*)url;
@end
@interface XKSettingFileOut : NSObject
@property(weak,nonatomic)id<XKSettingFileOutDelegate>delegate;
-(instancetype)initObjWithStatusType:(NSInteger)type withSuperView:(UIView *)superView;
-(void)startRecodingVideo;
-(void)stopRecodingVideo;

-(void)changeSwitchCameraWithStatus:(BOOL)status;
-(void)changeSwitchFlashlightWithStatus:(BOOL)status;
@end
