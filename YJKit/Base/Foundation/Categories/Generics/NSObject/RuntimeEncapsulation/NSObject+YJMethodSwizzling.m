//
//  NSObject+YJMethodSwizzling.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJMethodSwizzling.h"

@implementation NSObject (YJMethodSwizzling)

static void _yj_swizzleMethodForClass(id class, SEL sel1, SEL sel2) {
    Method method1 = class_getInstanceMethod(class, sel1);
    Method method2 = class_getInstanceMethod(class, sel2);
    BOOL added = class_addMethod(class, sel1, method_getImplementation(method2), method_getTypeEncoding(method2));
    if (added) class_replaceMethod(class, sel2, method_getImplementation(method1), method_getTypeEncoding(method1));
    else method_exchangeImplementations(method1, method2);
}

+ (void)swizzleInstanceMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector {
    _yj_swizzleMethodForClass(self, selector, providedSelector);
}

+ (void)swizzleClassMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector {
    Class class = object_getClass((id)self);
    _yj_swizzleMethodForClass(class, selector, providedSelector);
}

@end
