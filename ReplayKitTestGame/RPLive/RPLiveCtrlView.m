//
//  RPLiveCtrlView.m
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPLiveCtrlView.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"
#import "ImageLoader.h"

@interface RPLiveCtrlView()

@property (strong, nonatomic) RPLiveVM *liveVM;
@property (strong, nonatomic) UIButton *liveButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *stopButton;

@property (assign, nonatomic) BOOL menuOpen;

@end

@implementation RPLiveCtrlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}

- (void)commonSetup {
    _menuDirection = RPMenuRightDirection;
    _menuOpen = NO;
    [self setupViews];
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *backImage = [ImageLoader imageNamed:@"background"];
    UIImageView *back = [[UIImageView alloc] initWithImage:backImage];
    [self addSubview:back];
    [back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
     self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setupCloseMenu];
}

- (void)setupVMObserver {
    @weakify(self);
    
    [[RACObserve(self.liveVM, cameraEnabled) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isCameraEnabled) {
            [self.cameraButton setImage:[ImageLoader imageNamed:@"camera_on"] forState:UIControlStateNormal];
        }
        else {
            [self.cameraButton setImage:[ImageLoader imageNamed:@"camera_off"] forState:UIControlStateNormal];
        }
    }];
    [[self.cameraButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.liveVM.cameraEnabled = !self.liveVM.isCameraEnabled;
    }];
    
    [[RACObserve(self.liveVM, microphoneEnabled) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isMicrophoneEnabled) {
            [self.micButton setImage:[ImageLoader imageNamed:@"mic_on"] forState:UIControlStateNormal];
        }
        else {
            [self.micButton setImage:[ImageLoader imageNamed:@"mic_off"] forState:UIControlStateNormal];
        }
    }];
    [[self.micButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.liveVM.microphoneEnabled = !self.liveVM.isMicrophoneEnabled;
    }];
    
    [[RACObserve(self.liveVM, living) deliverOnMainThread]  subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isLiving) {
            UIImage *liveImage = [UIImage animatedImageNamed:@"living" duration:1];
            [self.liveButton setImage:liveImage forState:UIControlStateNormal];
        }
        else {
            [self.liveButton setImage:[ImageLoader imageNamed:@"live_off"] forState:UIControlStateNormal];
        }
    }];
    
    [[self.liveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.liveVM.isLiving) {
            [self.liveButton setImage:[ImageLoader imageNamed:@"live_on"] forState:UIControlStateNormal];
            [self.liveVM start];
        }
        else {
            [self.stopButton setImage:[ImageLoader imageNamed:@"stop"] forState:UIControlStateNormal];
            if (self.menuOpen) {
                [self setupCloseMenu];
            }
            else {
                [self setupOpenMenu];
            }
        }
    }];
    
    [[RACObserve(self.liveVM, paused) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isPaused) {
            [self.pauseButton setImage:[ImageLoader imageNamed:@"resume"] forState:UIControlStateNormal];
        }
        else {
            [self.pauseButton setImage:[ImageLoader imageNamed:@"pause"] forState:UIControlStateNormal];
        }
    }];
    [[self.pauseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isPaused) {
            [self.liveVM resume];
        }
        else {
            [self.liveVM pause];
        }
    }];
    
    [[self.stopButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.liveVM.isLiving) {
            [self.liveVM stop];
        }
        if (self.menuOpen) {
            [self setupCloseMenu];
        }
    }];
}

- (void)bindVM:(RPLiveVM *)liveVM {
    self.liveVM = liveVM;
    [self setupVMObserver];
}

- (NSArray<UIButton *>*)openMenus {
    return @[self.liveButton, self.pauseButton, self.stopButton];
}

- (NSArray<UIButton *>*)closeMenus {
    return @[self.liveButton];
}

- (void)setupOpenMenu {
    for (UIView *view in [self closeMenus]) {
        if (view.superview) {
            [view removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setupMenus:[self openMenus]];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = YES;
    }];
}

- (void)setupCloseMenu {
    for (UIView *view in [self openMenus]) {
        if (view.superview) {
            [view removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setupMenus:[self closeMenus]];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = NO;
    }];
}

// 为了支持方向，代码搞复杂了：（
- (void)setupMenus:(NSArray<UIView *>*)menus {
    UIView *firstView = menus.firstObject;
    if (!firstView) {
        return ;
    }
    [self addSubview:firstView];
    [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.menuDirection == RPMenuRightDirection ||
            self.menuDirection == RPMenuLeftDirection)
        {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(firstView.mas_height);
            if (self.menuDirection == RPMenuRightDirection) {
                make.left.equalTo(self);
                if (menus.count == 1) {
                    make.right.equalTo(self);
                }
            }
            else {
                make.right.equalTo(self);
                if (menus.count == 1) {
                    make.left.equalTo(self);
                }
            }
        }
        else if (self.menuDirection == RPMenuUpDirection ||
                 self.menuDirection == RPMenuDownDirection)
        {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(firstView.mas_width);
            if (self.menuDirection == RPMenuUpDirection) {
                make.bottom.equalTo(self);
                if (menus.count == 1) {
                    make.top.equalTo(self);
                }
            }
            else {
                make.top.equalTo(self);
                if (menus.count == 1) {
                    make.bottom.equalTo(self);
                }
            }
        }
    }];
    UIView *lastView = menus.lastObject;
    if (firstView == lastView) {
        return ;
    }
    
    UIView *prevView = firstView;
    for (NSInteger i=1; i<menus.count-1; i++) {
        UIView *nextView = menus[i];
        [self addSubview:nextView];
        [nextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.menuDirection == RPMenuRightDirection ||
                self.menuDirection == RPMenuLeftDirection)
            {
                make.top.equalTo(self);
                make.bottom.equalTo(self);
                make.width.equalTo(nextView.mas_height);
                if (self.menuDirection == RPMenuRightDirection) {
                    make.left.equalTo(prevView.mas_right);
                }
                else {
                    make.right.equalTo(prevView.mas_left);
                }
            }
            else if (self.menuDirection == RPMenuUpDirection ||
                     self.menuDirection == RPMenuDownDirection)
            {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.height.equalTo(nextView.mas_width);
                if (self.menuDirection == RPMenuUpDirection) {
                    make.bottom.equalTo(prevView.mas_top);
                }
                else {
                    make.top.equalTo(prevView.mas_bottom);
                }
            }
        }];
        prevView = nextView;
    }
    [self addSubview:lastView];
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.menuDirection == RPMenuRightDirection ||
            self.menuDirection == RPMenuLeftDirection)
        {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(lastView.mas_height);
            if (self.menuDirection == RPMenuRightDirection) {
                make.left.equalTo(prevView.mas_right);
                make.right.equalTo(self);
            }
            else {
                make.right.equalTo(prevView.mas_left);
                make.left.equalTo(self);
            }
        }
        else if (self.menuDirection == RPMenuUpDirection ||
                 self.menuDirection == RPMenuDownDirection)
        {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(lastView.mas_width);
            if (self.menuDirection == RPMenuUpDirection) {
                make.bottom.equalTo(prevView.mas_top);
                make.top.equalTo(self);
            }
            else {
                make.top.equalTo(prevView.mas_bottom);
                make.bottom.equalTo(self);
            }
        }
    }];
}

@end
