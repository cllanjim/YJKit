//
//  NSBundle+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/3/20.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "NSBundle+YJCategory.h"
#import "YJRuntimeEncapsulation.h"
#import "YJUIMacros.h"

@implementation NSBundle (YJCategory)

//  Reference: Scaled resources in bundle
//  https://github.com/ibireme/YYKit/blob/master/YYKit/Base/Foundation/NSBundle%2BYYAdd.m

+ (NSArray <NSNumber *> *)preferredScales {
    static NSArray *scales = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (scale <= 1) {
            scales = @[@1, @2, @3];
        } else if (scale <= 2) {
            scales = @[@2, @3, @1];
        } else {
            scales = @[@3, @2, @1];
        }
    });
    return scales;
}

#pragma mark - Returns a bundle object

+ (nullable NSBundle *)bundleWithName:(nullable NSString *)name {
    return [self bundleWithName:name inBundle:nil];
}

+ (nullable NSBundle *)bundleWithName:(nullable NSString *)name inBundle:(nullable NSBundle *)bundle {
    if (!bundle) bundle = [NSBundle mainBundle];
    if (!name.length) return bundle;
    NSString *bundlePath = [bundle pathForResource:name ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

#pragma mark - Returns a bundle path

+ (nullable NSString *)pathForScaledResource:(nullable NSString *)name ofType:(nullable NSString *)ext inDirectory:(NSString *)bundlePath {
    return _yj_pathForScaledResouce(self, name, ext, bundlePath);
}

- (nullable NSString *)pathForScaledResource:(nullable NSString *)name ofType:(nullable NSString *)ext inDirectory:(nullable NSString *)subpath {
    return _yj_pathForScaledResouce(self, name, ext, subpath);
}

- (nullable NSString *)pathForScaledResource:(nullable NSString *)name ofType:(nullable NSString *)ext {
    return _yj_pathForScaledResouce(self, name, ext, nil);
}

static NSString *_yj_pathForScaledResouce(id object, NSString *name, NSString *ext, NSString *dir) {
    NSString *path = nil;
    BOOL objectIsClass = yj_object_isClass(object);
    if (objectIsClass && !dir.length) return nil;
    if (!name.length) return [object pathForResource:name ofType:ext inDirectory:dir];
    /* -[NSString containsString:] is compatible under iOS 8 by loading "NSString+YJCompatible.m" */{
        if ([name containsString:@"."]) return [object pathForResource:name ofType:nil inDirectory:dir];
        if ([name containsString:@"@"]) return [object pathForResource:name ofType:ext inDirectory:dir];
    }
    NSArray *preferredScales = objectIsClass ? [object preferredScales] : [[object class] preferredScales];
    for (int i = 0; i < preferredScales.count; i++) {
        NSString *scaledName = [NSString stringWithFormat:@"%@@%@x", name, preferredScales[i]];
        path = [object pathForResource:scaledName ofType:ext inDirectory:dir];
        if (path) break;
    }
    if (!path) path = [object pathForResource:name ofType:ext inDirectory:dir];
    return path;
}

@end
