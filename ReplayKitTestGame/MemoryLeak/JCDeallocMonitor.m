//
//  FXDeallocMonitor.h
//
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import "JCDeallocMonitor.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag
#endif

@interface JCDeallocMonitor ()

@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) JCDeallocBlock deallocBlock;

@end

@implementation JCDeallocMonitor

#pragma mark - Public Class Methods

+ (void)addMonitorToObj:(id)obj {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc {
    [self addMonitorToObj:obj withDesc:desc deallocBlock:nil];
}

+ (void)addMonitorToObj:(id)obj withDeallocBlock:(JCDeallocBlock)deallocBlock {
    [self addMonitorToObj:obj withDesc:nil deallocBlock:deallocBlock];
}

+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(JCDeallocBlock)deallocBlock {
#ifdef DEBUG
    if (obj) {
        JCDeallocMonitor *monitor = [[JCDeallocMonitor alloc] init];
        if (desc.length > 0) {
            monitor.desc = [NSString stringWithFormat:@"%@(%@) deallocated", NSStringFromClass(((NSObject *)obj).class), desc];
        }
        else {
            monitor.desc = [NSString stringWithFormat:@"%@ has been deallocated", obj];
        }
        if (deallocBlock) {
            monitor.deallocBlock = deallocBlock;
        }
        
        int randomKey;
        
        // It is true that swizzle method of dealloc in NSObject Category can do the same thing, but that will cause method polluted!
        objc_setAssociatedObject(obj, &randomKey, monitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
#endif
}

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"%@", _desc);
    if(_deallocBlock) {
        _deallocBlock();
    }
}

@end
