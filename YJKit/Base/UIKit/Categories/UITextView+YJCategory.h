//
//  UITextView+YJCategory.h
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* -------------------- */
//  YJTextViewDelegate
/* -------------------- */

@protocol YJTextViewDelegate <UITextViewDelegate>
@optional
/// Provide a view. When user taps on it, the text view will resign first responder.
- (UIView *)viewForAutoResigningFirstResponderForTextView:(UITextView *)textView;
@end

/* -------------------- */
//      UITextView
/* -------------------- */

@interface UITextView (YJCategory)

/// The receiver’s delegate.
@property (nullable, nonatomic, weak) id <YJTextViewDelegate> delegate;

/// Whether resign first responder when user taps the background (textView's superview). Default is NO.
/// If you implementing -viewForAutoResigningFirstResponderForTextView:, the provided view will handle
/// the auto resigning first responder when user taps on it.
@property (nonatomic) IBInspectable BOOL autoResignFirstResponder;

/// The placeholder text for displaying when text view has no content.
/// @note Setting the placeholder text is actually setting the textView.attributedText
@property (nullable, nonatomic, copy) IBInspectable NSString *placeholder;

/// The color for placeholder text, default is [UIColor lightGrayColor].
@property (null_resettable, nonatomic, strong) IBInspectable UIColor *placeholderColor;

@end

NS_ASSUME_NONNULL_END