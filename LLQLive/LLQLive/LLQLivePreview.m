//
//  LLQLivePreview.m
//  LLQLive
//
//  Created by LLQ on 2017/3/28.
//  Copyright © 2017年 LLQ. All rights reserved.
//

#import "LLQLivePreview.h"
#import <LFLiveKit.h>
#import "UIView+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "UIView+ViewController.h"

@interface LLQLivePreview () <LFLiveSessionDelegate>

@property (nonatomic, strong) LFLiveSession *session;  //会话
@property (nonatomic, strong) UIButton *beautyButton;  //美颜按钮
@property (nonatomic, strong) UIButton *cameraButton;  //切换摄像头按钮
@property (nonatomic, strong) UIButton *closeButton;   //关闭
@property (nonatomic, strong) UIButton *startLiveButton;  //开始直播
@property (nonatomic, strong) UIView *containerView;  //放置控件的背景view
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) UILabel *stateLabel;  //连接状态

@end

@implementation LLQLivePreview

//初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.startLiveButton];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
    }
    return self;
}

//获取相机权限
- (void)requestAccessForVideo{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
            
        case AVAuthorizationStatusNotDetermined:{
            //允许对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            //已经获得授权
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            //用户拒绝访问相机
            break;
            
        default:
            break;
    }
    
}

//获取麦克风权限
- (void)requestAccessForAudio{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
            
        case AVAuthorizationStatusNotDetermined:
            //授权对话没有出现，进行授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
            break;
        
        case AVAuthorizationStatusAuthorized:
            //已经获得授权
            break;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            //用户拒绝访问麦克风
            
        default:
            break;
    }
    
}


#pragma mark ------ lazy

- (LFLiveSession *)session{
    if (!_session) {
        LFLiveVideoConfiguration *videoConfiguration = [[LFLiveVideoConfiguration alloc] init];
        videoConfiguration.videoSize = CGSizeMake(360, 640);
        videoConfiguration.videoBitRate = 800*1024;  //码率
        videoConfiguration.videoMaxBitRate = 1000*1024;  //最大码率
        videoConfiguration.videoMinBitRate = 500*1024;  //最小码率
        videoConfiguration.videoFrameRate = 24;  //fps
        videoConfiguration.videoMaxKeyframeInterval = 48;  //最大关键帧间隔，一般设为fps的两倍
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;  //竖屏输出
        videoConfiguration.autorotate = NO;
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        _session.delegate = self;
        _session.showDebugInfo = self;
        _session.preView = self;
    }
    return _session;
}

//背景view
- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.frame = CGRectMake(0, 0, kScreenW, kScreenH);
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

//链接状态label
- (UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

//关闭按钮
- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.top = 20;
        _closeButton.left = self.width - 10 - _closeButton.width;
        [_closeButton setImage:[UIImage imageNamed:@"close_preview"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.viewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _closeButton;
}

//切换前后摄像头
- (UIButton *)cameraButton{
    if (!_cameraButton) {
        _cameraButton = [[UIButton alloc] init];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_cameraButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            __strong typeof(self) strongSelf = weakSelf;
            AVCaptureDevicePosition devicePosition = strongSelf.session.captureDevicePosition;
            strongSelf.session.captureDevicePosition = (devicePosition == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        }];
    }
    return _cameraButton;
}

//美颜按钮
- (UIButton *)beautyButton{
    if (!_beautyButton) {
        _beautyButton = [[UIButton alloc] init];
        _beautyButton.size = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width, 20);
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        __weak typeof(self) weakSelf = self;
        [_beautyButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.session.beautyFace = !strongSelf.session.beautyFace;
            strongSelf.beautyButton.selected = !strongSelf.beautyButton.selected;
        }];
    }
    return _beautyButton;
}

//开始直播按钮
- (UIButton *)startLiveButton{
    if (!_startLiveButton) {
        _startLiveButton = [[UIButton alloc] init];
        _startLiveButton.size = CGSizeMake(self.width - 60, 44);
        _startLiveButton.left = 30;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _startLiveButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        __weak typeof(self) weakSelf = self;
        [_startLiveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.startLiveButton.selected = !strongSelf.startLiveButton.selected;
            if (strongSelf.startLiveButton.selected) {
                [strongSelf.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
                LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
                stream.url = @"rtmp://106.75.107.156:1935/live/test";
                [strongSelf.session startLive:stream];
            } else {
                [strongSelf.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
                [strongSelf.session stopLive];
            }
        }];
    }
    return _startLiveButton;
}

#pragma mark ------ LFLiveSessionDelegate

//链接状态发生改变
- (void)liveSession:(LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    
    NSLog(@"liveStateDidChange:  %ld",state);
    switch (state) {
            
        case LFLiveReady:
            _stateLabel.text = @"未连接";
            break;
            
        case LFLivePending:
            _stateLabel.text = @"连接中";
            break;
        
        case LFLiveStart:
            _stateLabel.text = @"已连接";
            break;
            
        case LFLiveError:
            _stateLabel.text = @"链接错误";
            break;
            
        case LFLiveStop:
            _stateLabel.text = @"未连接";
            break;
            
        default:
            break;
    }
}

//
- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo{
    
}

//
- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode{
    NSLog(@"errorCode: %ld",errorCode);
}

@end
