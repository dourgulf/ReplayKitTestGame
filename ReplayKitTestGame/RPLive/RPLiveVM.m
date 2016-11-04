//
//  RPLiveVM.m
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPLiveVM.h"
#import "JCDeallocMonitor.h"

@import ReplayKit;

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag
#endif

#define CheckStartTimeout 5

@interface RPLiveVM()<RPBroadcastActivityViewControllerDelegate, RPBroadcastControllerDelegate> {
}

@property (weak, nonatomic) UIViewController *ownerViewController;
@property (weak, nonatomic) RPBroadcastController *broadcastController;
@property (strong, nonatomic) RPBroadcastController *strongBC;  // 暂停的时候强引用
@property (copy, nonatomic) NSURL *chatURL;
@property (assign, nonatomic, getter=isPaused) BOOL paused;
@property (assign, nonatomic, getter=isLiving) BOOL living;

@property (weak, nonatomic) NSTimer *startCheckTimer;
@end

@implementation RPLiveVM

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        _ownerViewController = vc;
        [JCDeallocMonitor addMonitorToObj:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkLivingStatus)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkLivingStatus)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCameraEnabled:(BOOL)enable {
    if (enable) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self willChangeValueForKey:@"cameraEnabled"];
            if (granted) {
                [RPScreenRecorder sharedRecorder].cameraEnabled = YES;
            }
            else {
                NSLog(@"User not allow camera access");
            }
            [self didChangeValueForKey:@"cameraEnabled"];
        }];
    }
    else {
        [self willChangeValueForKey:@"cameraEnabled"];
        [RPScreenRecorder sharedRecorder].cameraEnabled = NO;
        [self didChangeValueForKey:@"cameraEnabled"];
    }
}

- (BOOL)isCameraEnabled {
    return [RPScreenRecorder sharedRecorder].isCameraEnabled;
}

- (BOOL)isMicrophoneEnabled {
    return [RPScreenRecorder sharedRecorder].isMicrophoneEnabled;
}

- (void)setMicrophoneEnabled:(BOOL)enable {
    if (enable) {
        [[AVAudioSession sharedInstance] requestRecordPermission: ^(BOOL granted){
            [self willChangeValueForKey:@"microphoneEnabled"];
            if (granted) {
                [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
            }
            else {
                NSLog(@"User not allow microphone access");
            }
            [self didChangeValueForKey:@"microphoneEnabled"];
        }];
    }
    else {
        [self willChangeValueForKey:@"microphoneEnabled"];
        [RPScreenRecorder sharedRecorder].microphoneEnabled = NO;
        [self didChangeValueForKey:@"microphoneEnabled"];
    }
}

- (void)start {
    if (self.broadcastController.isBroadcasting) {
        NSLog(@"It is broadcasting...");
        return ;
    }
    
    NSAssert(_ownerViewController, @"没有控制器玩不了...");
    
    @WeakObj(self)
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error)
    {
        @StrongObj(self);
        
        if (!error) {
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            NSLog(@"Selectting broadcast service");
            [self.ownerViewController presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }
        else {
            [self onStopped:error];
        }
    }];
}

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error
{
    @WeakObj(self)
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
        @StrongObj(self)
        if (!error) {
            // 如果之前竟然还有一个RPBroadcastController, 先解除上一个对象的代理
            if (self.broadcastController) {
                NSLog(@"There still a RPBroadcastController???");
                self.broadcastController.delegate = nil;
            }
            self.broadcastController = broadcastController;
            [JCDeallocMonitor addMonitorToObj:broadcastController];
            [self doStartBroadcast];
        }
        else {
            [self onStopped:error];
        }
    }];
}

- (void)doStartBroadcast {
    NSLog(@"Start broadcast:%@", self.broadcastController);
    self.broadcastController.delegate = self;
    @WeakObj(self)
    [self.broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        @StrongObj(self);
        if (!error) {
            [self onStarted];
        }
        else {
            [self onStopped:error];
        }
        [self releaseCheckStartTimer];
    }];
    [self createCheckStartTimer];
}

- (void)createCheckStartTimer {
    @WeakObj(self);
    _startCheckTimer = [NSTimer scheduledTimerWithTimeInterval:CheckStartTimeout repeats:NO block:^(NSTimer * _Nonnull timer) {
        @StrongObj(self);
        // auto retry
        NSLog(@"Start timeout, auto retry...");
        [self start];
    }];
}

- (void)releaseCheckStartTimer {
    if (_startCheckTimer) {
        [_startCheckTimer invalidate];
        _startCheckTimer = nil;
    }
}

- (BOOL)isLiving {
    return self.broadcastController.isBroadcasting;
}

-(UIView *)cameraPreview {
    return [RPScreenRecorder sharedRecorder].cameraPreviewView;
}

- (NSURL *)broadcastURL {
    return self.broadcastController.broadcastURL;
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError * __nullable)error{
    NSLog(@"broadcastController:didFinishWithError:%@", error);
    [self onStopped:error];
}

- (void)checkLivingStatus {
    BOOL isLiving = self.broadcastController.isBroadcasting;
    if (isLiving != self.living) {
        self.living = isLiving;
    }
    BOOL isPaused = self.broadcastController.paused;
    if (isPaused != self.paused) {
        self.paused = isPaused;
    }
}

// 一些私有协议
// updateServiceInfo的格式是一个固定的字典
// 通过RPInfo_EventKey得到通知的类型
// 通过RPInfo_EventValue得到通知类型对应的值
#define RPInfo_EventKey     @"InfoEventKey"
#define RPInfo_EventValue   @"InfoEventValue"

// RPInfo_EventKey如下:
// 聊天URL, 对应的值是一个URL字符串(不是NSURL)
#define RPInfo_EventChatURL     @"InfoEventChatURL"
// 直播结束, 对应的值是结束原因
#define RPInfo_EventLiveStop    @"InfoEventLiveStopped"
// 直播错误, 对应的值是一个错误信息的字符串
#define RPInfo_EventLiveError   @"InfoEventLiveError"
// 统计数据, 对应的值是一个字典, 字典内容就不再一一介绍了
#define RPInfo_EventLiveStat   @"InfoEventLiveStat"

// Watch for service info from broadcast service
- (void)broadcastController:(RPBroadcastController *)broadcastController
       didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo
{
    NSLog(@"didUpdateServiceInfo: %@", serviceInfo);
    NSString *event = (NSString *)serviceInfo[RPInfo_EventKey];
    if ([event isEqualToString:RPInfo_EventChatURL]) {
        NSString *chatUrl = (NSString *)serviceInfo[RPInfo_EventValue];
        self.chatURL = [NSURL URLWithString:chatUrl];
    }
    else if ([event isEqualToString:RPInfo_EventLiveError]) {
        // ERROR handler
        NSLog(@"broadcasting service report error");
        [self stop];
    }
    else if ([event isEqualToString:RPInfo_EventLiveStop]) {
        // STOPPED handler
        NSLog(@"broadcasting service report stopped");
        [self stop];
    }
}

- (void)onStarted {
    NSLog(@"Live started:%@", self.broadcastController.broadcastURL);
    
    if ([self.delegate respondsToSelector:@selector(rpliveStarted)]) {
        [self.delegate rpliveStarted];
    }
    self.living = YES;
}

- (void)onStopped:(NSError *)error {
    if (error) {
        NSLog(@"Live stopped with error:%@", error);
    }
    else {
        NSLog(@"Live stopped normally");
    }
    
    if ([self.delegate respondsToSelector:@selector(rpliveStoppedWithError:)]) {
        [self.delegate rpliveStoppedWithError:error];
    }
    self.living = NO;
}

- (void)pause {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not living, how pause???");
        return ;
    }
    
    if (self.broadcastController.paused) {
        NSLog(@"Already paused!!!");
        return ;
    }
    // 强引用, 防止对象在paused之后被释放
    self.strongBC = self.broadcastController;
    
    [self.broadcastController pauseBroadcast];
    self.paused = self.broadcastController.paused;
}

-(void)setPaused:(BOOL)paused {
    _paused = paused;
    
    if ([self.delegate respondsToSelector:@selector(rplivePaused)]) {
        [self.delegate rplivePaused];
    }
}

- (void)resume {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not living, how resume???");
        return ;
    }
    if (!self.broadcastController.paused) {
        NSLog(@"Not paused!!!");
        return ;
    }
    // 始终使用弱引用的对象来进行操作, strongBC只用来保持对象的生命周期.
    [self.broadcastController resumeBroadcast];
    
    self.strongBC = nil;
    
    self.paused = self.broadcastController.paused;
}

- (void)stop {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not broadcasting, how stop???");
        return;
    }
    
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            // Normal stop
            [self onStopped:nil];
        }
        else {
            NSLog(@"finishBroadcastWithHandler error:%@", error);
            [self onStopped:error];
        }
        self.broadcastController = nil;
    }];
}

@end
