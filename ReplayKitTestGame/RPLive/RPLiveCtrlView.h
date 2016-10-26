//
//  RPLiveCtrlView.h
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPLiveVM.h"

typedef enum : NSUInteger {
    RPMenuLeftDirection,
    RPMenuRightDirection,
    RPMenuUpDirection,
    RPMenuDownDirection,
} RPMenuDirection;

@interface RPLiveCtrlView : UIView

@property(assign, nonatomic) RPMenuDirection menuDirection;     // 菜单的伸展方向，默认是向右

- (void)bindVM:(RPLiveVM *)liveVM;

@end
