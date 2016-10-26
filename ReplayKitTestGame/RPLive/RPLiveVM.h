//
//  RPLiveVM.h
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPLiveVM;

@protocol RPLiveVMDelegate<NSObject>

@optional

- (void)rpliveStarted;                              // 直播开启了的事件
- (void)rpliveStoppedWithError:(NSError *)error;    // 直播结束了的事件
- (void)rplivePaused;                               // 直播已暂停

@end

@interface RPLiveVM : NSObject

// start前可以设置的属性
@property (weak, nonatomic) id<RPLiveVMDelegate> delegate;                          // 代理方法
@property (assign, nonatomic, getter=isCameraEnabled) BOOL cameraEnabled;           // 开启摄像头(内部自动提示获取权限)
@property (assign, nonatomic, getter=isMicrophoneEnabled) BOOL microphoneEnabled;   // 开启麦克风(内部自动提示获取权限)

// start之后可以访问的属性、可以监听的状态变化
@property (readonly, weak, nonatomic) UIView *cameraPreview;            // 摄像头的预览画面
@property (readonly, copy, nonatomic) NSURL *broadcastURL;              // 用来分享的直播地址
@property (readonly, copy, nonatomic) NSURL *chatURL;                   // 用来展示聊天的URL地址，支持KVO
@property (readonly, assign, nonatomic, getter=isLiving) BOOL living;   // 查询是否正在直播，支持KVO
@property (readonly, assign, nonatomic, getter=isPaused) BOOL paused;   // 直播是否暂停了(注意：只有正在直播才有是否暂停的状态)，支持KVO


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithViewController:(UIViewController *)vc NS_DESIGNATED_INITIALIZER;

- (void)start;                                                      // 开启直播

- (void)pause;                                                      // 暂停直播
- (void)resume;                                                     // 恢复直播

- (void)stop;                                                       // 停止直播

@end
