//
//  ImageLoader.h
//  ReplayKitTestGame
//
//  Created by jinchu darwin on 26/10/2016.
//  Copyright © 2016 JCLive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageLoader : NSObject

+ (nullable UIImage *)imageNamed:( NSString * _Nonnull )name;      // load from current bundle
+ (nullable UIImage *)imageNamed:( NSString * _Nonnull )name inBundle:(nullable NSBundle *)bundle;

@end
