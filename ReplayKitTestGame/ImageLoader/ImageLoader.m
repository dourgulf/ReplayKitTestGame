//
//  ImageLoader.m
//  ReplayKitTestGame
//
//  Created by jinchu darwin on 26/10/2016.
//  Copyright © 2016 JCLive. All rights reserved.
//

#import "ImageLoader.h"

@implementation ImageLoader

+ (nullable UIImage *)imageNamed:( NSString * _Nonnull )name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (nullable UIImage *)imageNamed:( NSString * _Nonnull )name inBundle:(nullable NSBundle *)bundle {
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
