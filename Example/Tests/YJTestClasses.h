//
//  YJTestClasses.h
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bar;

@interface Foo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Bar *friend;
@property (nonatomic) BOOL sleep;
@property (nonatomic) BOOL awake;

- (void)sayHello;
+ (void)sayHello;
+ (void)sayHi;

@end


@interface Bar : NSObject

+ (instancetype)bar;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger age;

- (void)sayYoo;
+ (void)sayYoo;

@end


@interface Clown : NSObject

@property (nonatomic, copy) NSString *name;

@end