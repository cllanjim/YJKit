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
#import "YJDelegateAndDataSourceCrashPrecaution.h"

@interface UITextField () <UIGestureRecognizerDelegate>
@end

@implementation UITextField (YJCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING(TextField)
        YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS
    });
}

YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_IMPLEMENTATION(TextField)

YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS

@end
