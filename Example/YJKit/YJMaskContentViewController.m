//
//  YJMaskContentViewController.m
//  YJKit
//
//  Created by huang-kun on 16/5/19.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJMaskContentViewController.h"
#import "UITextView+YJCategory.h"
#import "UITextField+YJCategory.h"

@interface YJTextField : UITextField
@end

@implementation YJTextField

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

@end

@interface YJMaskContentViewController () <YJTextViewDelegate, YJTextFieldDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) YJTextField *textField;
@property (nonatomic, strong) UIView *redView;
@end

@implementation YJMaskContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YJTextField *textField = [[YJTextField alloc] initWithFrame:CGRectMake(50, 30, 200, 20)];
    textField.delegate = self;
    textField.autoResignFirstResponder = YES;
    textField.placeholder = @"hello";
    [self.view addSubview:textField];
    self.textField = textField;
    
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(50,80,200,200)];
//    textView.delegate = self;
//    textView.autoResignFirstResponder = YES;
//    textView.placeholder = @"hello";
//    [self.view addSubview:textView];
//    
//    self.textView = textView;
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hello)];
//    [self.view addGestureRecognizer:tap];
    
    UIView *redView = [[UIView alloc] initWithFrame:(CGRect){150,10,100,80}];
    redView.backgroundColor = [UIColor redColor];
//    UITapGestureRecognizer *anotherTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTextField)];
//    [redView addGestureRecognizer:anotherTap];
    [self.view addSubview:redView];
    self.redView = redView;
}

//- (UIView *)viewForAutoResigningFirstResponderForTextView:(UITextView *)textView {
//    return nil;//self.redView;
//}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"begin");
}

- (UIView *)viewForAutoResigningFirstResponderForTextField:(UITextField *)textField {
    return self.redView;
}

- (void)hello {
    NSLog(@"hello");
}

- (void)removeTextField {
    if (self.textField.superview) {
        [self.textField removeFromSuperview];
    } else {
        [self.view addSubview:self.textField];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
