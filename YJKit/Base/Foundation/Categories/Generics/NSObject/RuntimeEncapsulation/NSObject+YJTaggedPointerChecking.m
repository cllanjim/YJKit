//
//  NSObject+YJTaggedPointerChecking.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "NSObject+YJTaggedPointerChecking.h"

// Reference:
// https://github.com/opensource-apple/objc4/blob/master/runtime/objc-config.h
// https://github.com/opensource-apple/objc4/blob/master/runtime/objc-internal.h

#ifndef SUPPORT_TAGGED_POINTERS
    #if !(__OBJC2__  &&  __LP64__)
        #define SUPPORT_TAGGED_POINTERS 0
    #else
        #define SUPPORT_TAGGED_POINTERS 1
    #endif
#endif

#ifndef SUPPORT_MSB_TAGGED_POINTERS
    #if !SUPPORT_TAGGED_POINTERS  ||  !TARGET_OS_IPHONE /* --- I'm not sure for apple watch and apple TV --- */
        #define SUPPORT_MSB_TAGGED_POINTERS 0
    #else
        #define SUPPORT_MSB_TAGGED_POINTERS 1
    #endif
#endif

@implementation NSObject (YJTaggedPointerChecking)

- (BOOL)isTaggedPointer {
    #if SUPPORT_TAGGED_POINTERS
        #if SUPPORT_MSB_TAGGED_POINTERS
            return (intptr_t)self < 0; /* TARGET_OS_IPHONE */
        #else
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wdeprecated-objc-pointer-introspection\"") \
            return (uintptr_t)self & 1;
            _Pragma("clang diagnostic pop")
        #endif
    #else
        return NO;
    #endif
}

@end

