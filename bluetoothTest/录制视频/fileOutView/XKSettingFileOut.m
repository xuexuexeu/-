//
//  XKSettingFileOut.m
//  bluetoothTest
//
//  Created by apple on 2019/1/29.
//  Copyright © 2019年 apple. All rights reserved.
//

#import "XKSettingFileOut.h"
#import <AVFoundation/AVFoundation.h>
#import "XKFileOutView.h"
#import "UIView+EXTION.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface XKSettingFileOut ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, weak) XKFileOutView *superView; //展示的view界面

@property (nonatomic, strong) AVCaptureSession *session;//媒体（音、视频）捕获会话，负责把捕获的音视频数据输出到输出设备中
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer; //相机拍摄预览图层
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;  //视频设备输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;  //音频设备输出
@property (nonatomic, strong) AVCaptureMovieFileOutput *FileOutput; //文件输出

@property (strong,nonatomic)  UIImageView *focusCursorImg; //聚焦光标

@property (nonatomic, strong, readwrite) NSURL *videoUrl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat recordTime;//录制事件


//@property (nonatomic, assign) FMFlashState flashState; //闪光灯的设置

@end
@implementation XKSettingFileOut
//AVCapture 的一些懒加载
//媒体（音、视频）捕获会话，负责把捕获的音视频数据输出到输出设备中
-(AVCaptureSession *)session{
    // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
    // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
    // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
    // 只有高分辨率的视频才是全屏的，如果想要自定义长宽比，就需要先录制高分辨率，再剪裁，如果录制低分辨率，剪裁的区域不好控制
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        //设置分辨率
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}
//相机拍摄预览图层
-(AVCaptureVideoPreviewLayer *)previewlayer{
    if (_previewlayer == nil) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewlayer;
}

- (UIImageView *)focusCursorImg
{
    if (!_focusCursorImg) {
        _focusCursorImg = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
        _focusCursorImg.image = [UIImage imageNamed:@"focusImg"];
        _focusCursorImg.alpha = 0;
    }
    return _focusCursorImg;
}

//初始化对象
-(instancetype)initObjWithStatusType:(NSInteger)type withSuperView:(UIView *)superView{
    if (self = [super init]) {
        self.superView = (XKFileOutView*)superView;
        //创建各种控件
        [self setUpWithType:type];
    }
    return self;
}

//
-(void)setUpWithType:(NSInteger)type{
    //初始话设置  监听内容
    //程序进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //程序将要进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [self clearFile];
    _recordTime = 0;
//    _recordState = FMRecordStateInit;
    
    ///1. 设置视频的输入
//    1.1 获取视频输入设备(摄像头)
//    视频的输入 是通过摄像头来控制的  故先需要获取到摄像头的数组   来控制前后摄像头的视频输入
    AVCaptureDevice *videoDevice = nil;
    NSArray *cameraArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameraArr) {
        if ([camera position] == AVCaptureDevicePositionBack) {
            videoDevice = camera;
        }
    }
    // 1.2 创建视频输入源
    NSError *error=nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];
    // 1.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    //2.设置音频的输入  类似视频输入
    // 2.1 获取音频输入设备  音频设置只有一样 故可以通过AVCaptureDevice  直接获取到
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    // 2.2 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    ///3.添加写入文件的fileoutput  AVCaptureMovieFileOutput  直接输出一个录制的视频路径  所以需要设置路径
    // 3.1初始化设备输出对象，用于获得输出数据
    self.FileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // 3.2设置输出对象的一些属性
    AVCaptureConnection *captureConnection = [self.FileOutput connectionWithMediaType:AVMediaTypeVideo];
    //设置防抖
    //视频防抖 是在 iOS 6 和 iPhone 4S 发布时引入的功能。到了 iPhone 6，增加了更强劲和流畅的防抖模式，被称为影院级的视频防抖动。相关的 API 也有所改动 (目前为止并没有在文档中反映出来，不过可以查看头文件）。防抖并不是在捕获设备上配置的，而是在 AVCaptureConnection 上设置。由于不是所有的设备格式都支持全部的防抖模式，所以在实际应用中应事先确认具体的防抖模式是否支持：
    if ([captureConnection isVideoStabilizationSupported]) {
  captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
    }
    //预览图层和视频方向保持一致
    captureConnection.videoOrientation = [self.previewlayer connection].videoOrientation;
    // 3.3将设备输出添加到会话中
    if ([self.session canAddOutput:self.FileOutput]) {
        [self.session addOutput:self.FileOutput];
    }
    
    ///4. 视频的预览层  视频采集的界面设置
    self.previewlayer.frame = CGRectMake(0, 0, self.superView.width, self.superView.height);
    [self.superView.layer insertSublayer:self.previewlayer atIndex:0];
    
    
    ///5. 开始采集画面
    [self.session startRunning];
    
    /// 6. 将采集的数据写入文件（用户点击按钮即可将采集到的数据写入文件）
    
    /// 7. 增加聚焦功能（可有可无）
//    聚光功能  设置点击手势  记录坐标  设置图标
//    [self addFocus];
    [self.superView.bottomView addSubview:self.focusCursorImg];
    UITapGestureRecognizer *tagGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.superView.bottomView addGestureRecognizer:tagGesture];
}

#pragma mark  UITapGestureRecognizer  聚光点击事件
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:self.superView.bottomView];
    //获取点击的坐标后  就需要改变  聚光图标的frame了
    self.focusCursorImg.center=point;
    self.focusCursorImg.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursorImg.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursorImg.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImg.alpha=0;
        
    }];
    
    //改变采集的视频的  聚光效果
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewlayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
    
}

//设置聚焦点
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        //设置录制屏幕聚光视频的改变
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}
-(void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice= [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}
#pragma mark 控制视频的录制事件
-(void)startRecodingVideo{
    //录制视频  就是需要把采集到的视频数据  写入AVCaptureMovieFileOutput FileOutput 里面
    //然后通过  设置FileOutput的代理  来监听完成的的进度
    
    //存储视频路径
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videoName];
//    NSString *path = [ stringByAppendingPathComponent:videoName];
//    NSString *videoPath = [self createVideoFilePath];
    self.videoUrl = [NSURL fileURLWithPath:path];
    //开始视频的内容输出  并设置deleget
    [self.FileOutput startRecordingToOutputFileURL:self.videoUrl recordingDelegate:self];
}
-(void)stopRecodingVideo{
    //结束录制
    [self.FileOutput stopRecording];
    [self.session stopRunning];
    [self.timer invalidate];
    self.timer = nil;
}

//控制摄像头  切换
-(void)changeSwitchCameraWithStatus:(BOOL)status{
    //摄像头的切换  逻辑：1.首先需要停止视频的采集  因为需要 切换摄像头  然后在获取到  需要的那个摄像头来采集视频  设备的视频输入也需要跟换
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.videoInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device

    AVCaptureDevice *device = nil;
    NSArray *cameraArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameraArr) {
        if ([camera position] == position) {
            device = camera;
        }
    }
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];
    
}
//控制闪光灯 开关
-(void)changeSwitchFlashlightWithStatus:(BOOL)status{
    if (status) {
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOn];
            [self.videoInput.device unlockForConfiguration];

        }
    }else{
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOff];
            [self.videoInput.device unlockForConfiguration];
        }
    }

}
#pragma mark  AVCaptureFileOutputDelegate
//开始写入数据
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

//结束录制
- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    NSLog(@"结束录制时获取获取到的数据 地址%@ connections %@ error%@",outputFileURL,connections,error);
//    NSString* path = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    
    // 保存视频
    
    NSString *videopath = [NSString stringWithFormat:@"%@",[outputFileURL path] ];
//    if (videopath) {
//        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videopath path])) {
//            //保存相册核心代码
//            UISaveVideoAtPathToSavedPhotosAlbum([videopath path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        }
//        
//    }
    UISaveVideoAtPathToSavedPhotosAlbum(videopath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);


//    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//    [lib writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:nil];
    //结束录制视频采集  代理回调数据
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishRecordingVideoWith:)]) {
        [self.delegate finishRecordingVideoWith:outputFileURL];
    }
}
// 视频保存回调

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}
#pragma mark  NSNotificationCenter 事件
//进入后台的情况
-(void)enterBack{
    
}
//进入前台的情况
-(void)becomeActive{
    
}



@end
