//
//  UITextView+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextView+YJCategory.h"
#import "NSObject+YJRuntimeEncapsulation.h"
#import "RGBColor.h"
#import "_YJResignFirstResponderDefaultImp.h"

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
        [self swizzleInstanceMethodsBySelector:@selector(initWithFrame:) withSelector:@selector(yj_textViewInitWithFrame:)];
        [self swizzleInstanceMethodsBySelector:@selector(initWithCoder:) withSelector:@selector(yj_textViewInitWithCoder:)];
        // exchange dealloc
        [self swizzleInstanceMethodsBySelector:NSSelectorFromString(@"dealloc") withSelector:@selector(yj_textViewDealloc)];
        // exchange life cycle
        YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING(TextView)
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

#pragma mark - handle auto resigning first responder tap gesture

YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_IMPLEMENTATION(TextView)

@end
