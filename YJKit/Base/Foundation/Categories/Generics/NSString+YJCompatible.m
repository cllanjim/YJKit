//
//  NSString+YJCompatible.m
//  YJKit
//
//  Created by huang-kun on 16/8/5.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "NSObject+YJMethodSwizzling.h"

/**
 
 Make -containsString: compatible under iOS 8.
 
 */
@implementation NSString (YJCompatible)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0) {
            [self swizzleInstanceMethodsBySelector:@selector(containsString:)
                                       andSelector:@selector(yj_containsString:)];
        }
    });
}

bool _yj_streq(const char *str1, const char *str2, size_t length) {
    for (size_t i = 0; i < length; i++) {
        if (*str1++ != *str2++) {
            return false;
        }
    }
    return true;
}

- (BOOL)yj_containsString:(NSString *)string {
    
    NSAssert(string != nil, @"*** -[%@ containsString:] can not use nil argument.", [self class]);
    
    size_t len1 = (size_t)self.length;
    size_t len2 = (size_t)string.length;
    
    if (len1 == 0 || len2 == 0 || len1 < len2) {
        return NO;
    }
    
    const char *str1 = self.UTF8String;
    const char *str2 = string.UTF8String;
    
    for (size_t i = 0; i <= len1 - len2; i++) {
        const char *substr1 = str1 + i;
        if (_yj_streq(substr1, str2, len2)) {
            return YES;
        } else {
            continue;
        }
    }

    return NO;
}

@end
