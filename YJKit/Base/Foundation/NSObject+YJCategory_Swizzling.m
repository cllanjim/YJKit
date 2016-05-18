//
//  NSObject+YJCategory_Swizzling.m
//  YJKit
//
//  Created by huang-kun on 16/5/13.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJCategory_Swizzling.h"

@implementation NSObject (YJCategory_Swizzling)

- (void)swizzleInstanceMethodForSelector:(SEL)selector toSelector:(SEL)toSelector {
    Class class = [self class];
    Method method = class_getInstanceMethod(class, selector);
    Method toMethod = class_getInstanceMethod(class, toSelector);
    BOOL added = class_addMethod(class, selector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod));
    if (added) class_replaceMethod(class, toSelector, method_getImplementation(method), method_getTypeEncoding(method));
    else method_exchangeImplementations(method, toMethod);
}

@end
