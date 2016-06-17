//
//  UITextField+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextField+YJCategory.h"
#import "NSObject+YJRuntimeSwizzling.h"
#import "NSArray+YJCollection.h"
#import "YJClangMacros.h"

@interface UITextField () <UIGestureRecognizerDelegate>
@end

@implementation UITextField (YJCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodForSelector:@selector(layoutSubviews) toSelector:@selector(yj_textFieldLayoutSubviews)];
        [self swizzleInstanceMethodForSelector:@selector(removeFromSuperview) toSelector:@selector(yj_textFieldRemoveFromSuperview)];
    });
}

#pragma mark - handle auto resigning first responder tap gesture

- (void)setAutoResignFirstResponder:(BOOL)autoResignFirstResponder {
#if YJ_BOX_BOOL_SUPPORT
    objc_setAssociatedObject(self, @selector(autoResignFirstResponder), @(autoResignFirstResponder), OBJC_ASSOCIATION_COPY_NONATOMIC);
#else
    objc_setAssociatedObject(self, @selector(autoResignFirstResponder), (autoResignFirstResponder ? @1 : @0), OBJC_ASSOCIATION_COPY_NONATOMIC);
#endif
    if (!autoResignFirstResponder) {
        [self yj_removeResignFirstResponderTapAction];
    }
}

- (BOOL)autoResignFirstResponder {
#if YJ_BOX_BOOL_SUPPORT
    return [objc_getAssociatedObject(self, _cmd) boolValue];
#else
    return [objc_getAssociatedObject(self, _cmd) intValue] ? YES : NO;
#endif
}

- (UIView *)providedARFRView {
    UIView *view = self.superview;
    id <YJTextFieldDelegate> delegate = (id)self.delegate;
    if ([delegate respondsToSelector:@selector(viewForAutoResigningFirstResponderForTextField:)]) {
        UIView *tempView = [delegate viewForAutoResigningFirstResponderForTextField:self];
        if (tempView) view = tempView;
    }
    return view;
}

- (void)yj_textFieldLayoutSubviews {
    [self yj_textFieldLayoutSubviews];
    
    if (self.autoResignFirstResponder) {
        UIView *view = self.providedARFRView;
        UITapGestureRecognizer *tap = nil;
        NSArray *taps = [view.gestureRecognizers filtered:^BOOL(__kindof UIGestureRecognizer * _Nonnull obj) {
            return [obj isKindOfClass:[UITapGestureRecognizer class]];
        }];
        if (taps.count) {
            tap = taps.lastObject;
        } else {
            tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
            tap.delegate = self;
            [view addGestureRecognizer:tap];
        }
        [tap removeTarget:self action:@selector(yj_handleResignFirstResponderTap)];
        [tap addTarget:self action:@selector(yj_handleResignFirstResponderTap)];
    }
}

- (void)yj_textFieldRemoveFromSuperview {
    if (self.autoResignFirstResponder) {
        [self yj_removeResignFirstResponderTapAction];
    }
    [self yj_textFieldRemoveFromSuperview];
}

- (void)yj_removeResignFirstResponderTapAction {
    UIView *view = self.providedARFRView;
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [gesture removeTarget:self action:@selector(yj_handleResignFirstResponderTap)];
        }
    }
}

- (void)yj_handleResignFirstResponderTap {
    [self resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self isFirstResponder] ? YES : NO;
}

@end
