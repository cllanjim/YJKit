//
//  UIAlertView+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/4/1.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+YJCategory.h"

static void *YJAlertViewAssociatedDelegateKey = &YJAlertViewAssociatedDelegateKey;

@interface _YJAlertViewDelegate : NSObject <UIAlertViewDelegate>
@property (nonatomic, copy) void(^actionBlock)(NSInteger);
@end

@implementation _YJAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.actionBlock) self.actionBlock(buttonIndex);
}

@end

@interface UIAlertView ()
@property (nonatomic, strong) _YJAlertViewDelegate *yj_delegate;
@end

@implementation UIAlertView (YJCategory)

- (void)setYj_delegate:(_YJAlertViewDelegate *)yj_delegate {
    objc_setAssociatedObject(self, YJAlertViewAssociatedDelegateKey, yj_delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJAlertViewDelegate *)yj_delegate {
    return objc_getAssociatedObject(self, YJAlertViewAssociatedDelegateKey);
}

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message actionBlock:(nullable void(^)(NSInteger buttonIndex))actionBlock cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    self.yj_delegate = [[_YJAlertViewDelegate alloc] init];
    if (actionBlock) self.yj_delegate.actionBlock = actionBlock;
    NSMutableArray *titles = @[].mutableCopy;
    va_list args;
    va_start(args, otherButtonTitles);
    static BOOL canAdd = NO;
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        if (canAdd) [titles addObject:arg];
        canAdd = YES;
    }
    canAdd = NO;
    va_end(args);
    switch (titles.count) {
        case 0: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
        case 1: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], nil];
        case 2: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], nil];
        case 3: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], nil];
        case 4: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], nil];
        case 5: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], titles[4], nil];
        case 6: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], titles[4], @"...", nil];
    }
    return nil;
}

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    self.yj_delegate = [[_YJAlertViewDelegate alloc] init];
    NSMutableArray *titles = @[].mutableCopy;
    va_list args;
    va_start(args, otherButtonTitles);
    static BOOL canAdd = NO;
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        if (canAdd) [titles addObject:arg];
        canAdd = YES;
    }
    canAdd = NO;
    va_end(args);
    switch (titles.count) {
        case 0: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
        case 1: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], nil];
        case 2: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], nil];
        case 3: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], nil];
        case 4: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], nil];
        case 5: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], titles[4], nil];
        case 6: return [self initWithTitle:title message:message delegate:self.yj_delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, titles[0], titles[1], titles[2], titles[3], titles[4], @"...", nil];
    }
    return nil;
}

- (void)setActionBlock:(void(^)(NSInteger buttonIndex))actionBlock {
    if (actionBlock) self.yj_delegate.actionBlock = actionBlock;
}

@end