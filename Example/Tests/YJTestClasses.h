//
//  YJTestClasses.h
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Bar;

@interface Foo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *privateName;

@property (nonatomic, strong) Bar *friend;
@property (nonatomic) BOOL sleep;
@property (nonatomic) BOOL awake;
@property (nonatomic) CGRect frame;

+ (instancetype)foo;

- (void)sayHello;
+ (void)sayHello;
+ (void)sayHi;

- (void)addPrivateName;

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

- (void)block:(void(^)(id obj1, __kindof NSObject *obj2, id _Nullable obj3, __kindof NSObject * _Nullable obj4))block;

@end

NS_ASSUME_NONNULL_END