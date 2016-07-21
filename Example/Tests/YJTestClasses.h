//
//  YJTestClasses.h
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Bar;

@interface Foo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Bar *friend;
@property (nonatomic) BOOL sleep;
@property (nonatomic) BOOL awake;
@property (nonatomic) CGRect frame;

+ (instancetype)foo;

- (void)sayHello;
+ (void)sayHello;
+ (void)sayHi;

@end


@interface Bar : NSObject

+ (instancetype)sharedBar;
+ (instancetype)bar;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger age;
@property (nonatomic) CGRect frame;

- (void)sayYoo;
+ (void)sayYoo;

@end


@interface Clown : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) CGSize size;

@end