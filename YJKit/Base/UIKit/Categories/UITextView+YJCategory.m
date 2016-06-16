//
//  UITextView+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextView+YJCategory.h"
#import "NSObject+YJRuntimeSwizzling.h"
#import "NSObject+YJAssociatedIdentifier.h"
#import "NSArray+YJCollection.h"
#import "RGBColor.h"
#import "YJClangMacros.h"

static const void *YJTextViewAssociatedPlaceholderKey = &YJTextViewAssociatedPlaceholderKey;
static const void *YJTextViewAssociatedPlaceholderColorKey = &YJTextViewAssociatedPlaceholderColorKey;

@interface UITextView () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) RGBColor yj_originalTextColor;
@end

@implementation UITextView (YJCategory)

- (BOOL)_isEmpty {
    return !self.text.length && !self.attributedText.length;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // exchange init
        [self swizzleInstanceMethodForSelector:@selector(initWithFrame:) toSelector:@selector(yj_textViewInitWithFrame:)];
        [self swizzleInstanceMethodForSelector:@selector(initWithCoder:) toSelector:@selector(yj_textViewInitWithCoder:)];
        // exchange dealloc
        [self swizzleInstanceMethodForSelector:NSSelectorFromString(@"dealloc") toSelector:@selector(yj_textViewDealloc)];
        // exchange life cycle
        [self swizzleInstanceMethodForSelector:@selector(layoutSubviews) toSelector:@selector(yj_textViewLayoutSubviews)];
        [self swizzleInstanceMethodForSelector:@selector(removeFromSuperview) toSelector:@selector(yj_textViewRemoveFromSuperview)];
    });
}

#pragma mark - placeholder

- (void)setPlaceholder:(NSString *)placeholder {
    objc_setAssociatedObject(self, YJTextViewAssociatedPlaceholderKey, placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self _displayPlaceholderIfNeeded];
}

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, YJTextViewAssociatedPlaceholderKey);
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    objc_setAssociatedObject(self, YJTextViewAssociatedPlaceholderColorKey, placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)placeholderColor {
    UIColor *placeholderColor = objc_getAssociatedObject(self, YJTextViewAssociatedPlaceholderColorKey);
    if (!placeholderColor) placeholderColor = [UIColor lightGrayColor];
    return placeholderColor;
}

- (instancetype)yj_textViewInitWithFrame:(CGRect)frame {
    id textView = [self yj_textViewInitWithFrame:frame];
    [self yj_notificationObservingTextView:textView];
    return textView;
}

- (nullable instancetype)yj_textViewInitWithCoder:(NSCoder *)coder {
    id textView = [self yj_textViewInitWithCoder:coder];
    [self yj_notificationObservingTextView:textView];
    return textView;
}

- (void)yj_notificationObservingTextView:(UITextView *)textView {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(yj_beginTextEditing) name:UITextViewTextDidBeginEditingNotification object:textView];
    [nc addObserver:self selector:@selector(yj_endTextEditing) name:UITextViewTextDidEndEditingNotification object:textView];
}

- (void)yj_textViewDealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self yj_textViewDealloc];
}

- (void)yj_beginTextEditing {
    [self _hidePlaceholderIfPossible];
}

- (void)yj_endTextEditing {
    [self _displayPlaceholderIfNeeded];
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
    id <YJTextViewDelegate> delegate = (id)self.delegate;
    if ([delegate respondsToSelector:@selector(viewForAutoResigningFirstResponderForTextView:)]) {
        UIView *tempView = [delegate viewForAutoResigningFirstResponderForTextView:self];
        if (tempView) view = tempView;
    }
    return view;
}

- (void)yj_textViewLayoutSubviews {
    [self yj_textViewLayoutSubviews];
    
    if (self.autoResignFirstResponder) {
        UITapGestureRecognizer *tap = nil;
        NSArray *taps = [self.providedARFRView.gestureRecognizers filtered:^BOOL(__kindof UIGestureRecognizer * _Nonnull obj) {
            return [obj isKindOfClass:[UITapGestureRecognizer class]];
        }];
        if (taps.count) {
            tap = taps.lastObject;
        } else {
            tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
            tap.delegate = self;
            [self.superview addGestureRecognizer:tap];
        }
        [tap removeTarget:self action:@selector(yj_handleResignFirstResponderTap)];
        [tap addTarget:self action:@selector(yj_handleResignFirstResponderTap)];
    }
}

- (void)yj_textViewRemoveFromSuperview {
    if (self.autoResignFirstResponder) {
        [self yj_removeResignFirstResponderTapAction];
    }
    [self yj_textViewRemoveFromSuperview];
}

- (void)yj_removeResignFirstResponderTapAction {
    for (UIGestureRecognizer *gesture in self.providedARFRView.gestureRecognizers) {
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

#pragma mark - text attributes

- (void)_displayPlaceholderIfNeeded {
    if ([self _isEmpty]) {
        self.yj_originalTextColor = self.textColor ? [self.textColor RGBColor] : (RGBColor){0,0,0,1};
        self.attributedText = [self _attributedPlaceholder:self.placeholder];
    }
}

- (void)_hidePlaceholderIfPossible {
    if ([self.attributedText.string isEqualToString:self.placeholder]) {
        self.attributedText = nil;
        self.textColor = [UIColor colorWithRGBColor:self.yj_originalTextColor];
    }
}

- (NSAttributedString *)_attributedPlaceholder:(NSString *)placeholder {
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : self.placeholderColor,
                                  NSFontAttributeName : (self.font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]) };
    return [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
}

- (void)setYj_originalTextColor:(RGBColor)yj_originalTextColor {
#if YJ_BOX_NSVALUE_SUPPORT
    objc_setAssociatedObject(self, @selector(yj_originalTextColor), @(yj_originalTextColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#else
    objc_setAssociatedObject(self, @selector(yj_originalTextColor), [NSValue valueWithRGBColor:yj_originalTextColor], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#endif
}

- (RGBColor)yj_originalTextColor {
    return [objc_getAssociatedObject(self, _cmd) RGBColorValue];
}

@end
