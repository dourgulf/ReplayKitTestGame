//
//  RPLiveVM.h
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPLiveVM : NSObject

@property (readonly, copy, nonatomic) NSURL *broadcastURL;              // 用来分享的直播地址
@property (readonly, copy, nonatomic) NSURL *chatURL;                   // 用来展示聊天的URL地址
@property (readonly, assign, nonatomic, getter=isLiving) BOOL living;   // 查询是否正在直播
@property (readonly, assign, nonatomic, getter=isPaused) BOOL paused;   // 直播是否暂停了(正在直播可以是暂停状态)

@property (assign, nonatomic, getter=isCameraEnabled) BOOL cameraEnabled;   // 开启摄像头(内部自动提示获取权限)
@property (assign, nonatomic, getter=isMicrophoneEnabled) BOOL microphoneEnabled;   // 开启麦克风(内部自动提示获取权限)

@property (readonly, weak, nonatomic) UIView *cameraPreview;            // 摄像头的预览画面

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithViewController:(UIViewController *)vc NS_DESIGNATED_INITIALIZER;

- (void)start;                                                      // 开启直播

- (void)onStarted;                                                  // 直播开启了的事件
- (void)onStopped:(NSError *)error;                                 // 直播结束了的事件

- (void)pause;                                                    // 暂停直播
- (void)resume;                                                   // 恢复直播

- (void)stop;                                                       // 停止直播

@end
