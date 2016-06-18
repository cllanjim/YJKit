//
//  UITextField+YJCategory.h
//  YJKit
//
//  Created by huang-kun on 16/5/25.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* --------------------- */
//  YJTextFieldDelegate
/* --------------------- */

@protocol YJTextFieldDelegate <UITextFieldDelegate>
@optional
/// Provide a view. When user taps on it, the text field will resign first responder.
/// If you enable textField.autoResignFirstResponder and never implementing this method,
/// the textField's superview will be handle the resigning first responder case.
- (UIView *)viewForAutoResigningFirstResponderForTextField:(UITextField *)textField;
@end

/* -------------------- */
//      UITextField
/* -------------------- */

@interface UITextField (YJCategory)

/// The receiver’s delegate.
@property (nullable, nonatomic, weak) id <YJTextFieldDelegate> delegate;

/// Whether resign first responder when user tap the background (textField's superview). Default is NO.
/// If you implementing -viewForAutoResigningFirstResponderForTextField:, the provided view will handle
/// the auto resigning first responder when user taps on it instead of it's superview.
@property (nonatomic) IBInspectable BOOL autoResignFirstResponder;

@end

NS_ASSUME_NONNULL_END