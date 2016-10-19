//
//  FXDeallocMonitor.h
//
//
//  Created by ShawnFoo on 9/16/15.
//  Copyright © 2015年 ShawnFoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Weak/Strong 宏

#if DEBUG
#define rac_keywordify autoreleasepool {}
#else
#define rac_keywordify try {} @catch (...) {}
#endif

// weakself宏定义
#define WS(weakObj) __weak __typeof(self) weakSelf = weakObj;

// Weak对象 以及 Strong对象的配套使用, 需要在其前加@ (注:使用Xcode Snippet添加快捷式, 然后按@W就会出现自动补全啦), 若需要单独使用, 建议使用上方的WS即可
#define WeakObj(o) rac_keywordify __weak typeof(o) o##Weak = o;
#define StrongObj(o) rac_keywordify __strong typeof(o) o = o##Weak;

typedef void (^JCDeallocBlock)(void);

/**
 *  This class can be used to monitor an object's release, to check memory leak(especially when you are using ReactiveCocoa, too many strong weak dances, nested blocks, etc...Xcode Instrument can't detect all retain cycles every time, but FXDeallocMonitor is capable to do it).
 *  Inspired by my mentor DarwinRie(达文哥) 😁
 */
@interface JCDeallocMonitor : NSObject

/**
 *  Print object when it is being deallocated(before object_dispose())
 */
+ (void)addMonitorToObj:(id)obj;

/**
 *  Print object with description when it is being deallocated
 *
 *  @param obj  object
 *  @param desc description
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc;

/**
 *  Print object and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param deallocBlock a block will run when object is being deallocated. For example, remove KVO in this block
 */
+ (void)addMonitorToObj:(id)obj withDeallocBlock:(JCDeallocBlock)deallocBlock;

/**
 *  Print object with description and and excute deallocBlock when it is being deallocated
 *
 *  @param obj          object
 *  @param desc         description
 *  @param deallocBlock a block will run when object is being deallocated
 */
+ (void)addMonitorToObj:(id)obj withDesc:(NSString *)desc deallocBlock:(JCDeallocBlock)deallocBlock;

@end
