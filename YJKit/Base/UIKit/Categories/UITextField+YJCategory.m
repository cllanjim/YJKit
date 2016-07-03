//
//  UITextField+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextField+YJCategory.h"
#import "YJRuntimeEncapsulation.h"
#import "_YJResignFirstResponderDefaultImp.h"

@interface UITextField () <UIGestureRecognizerDelegate>
@end

@implementation UITextField (YJCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING(TextField)
    });
}

#pragma mark - handle auto resigning first responder tap gesture

YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_IMPLEMENTATION(TextField)

@end
