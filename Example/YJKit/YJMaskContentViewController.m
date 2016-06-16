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

@interface YJMaskContentViewController () <YJTextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *redView;
@end

@implementation YJMaskContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 30, 200, 20)];
    textField.autoResignFirstResponder = YES;
    textField.placeholder = @"hello";
    [self.view addSubview:textField];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(50,80,200,200)];
    textView.delegate = self;
    textView.autoResignFirstResponder = YES;
    textView.placeholder = @"hello";
    [self.view addSubview:textView];
    
    self.textView = textView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hello)];
    [self.view addGestureRecognizer:tap];
    
    UIView *redView = [[UIView alloc] initWithFrame:(CGRect){150,10,100,80}];
    redView.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *anotherTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hi)];
    [redView addGestureRecognizer:anotherTap];
    [self.view addSubview:redView];
    self.redView = redView;
}

- (UIView *)viewForAutoResigningFirstResponderForTextView:(UITextView *)textView {
    return self.redView;
}

- (void)hello {
    NSLog(@"hello");
}

- (void)hi {
    NSLog(@"hi");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
