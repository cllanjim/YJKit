//
//  YJKVOPair.h
//  YJKit
//
//  Created by huang-kun on 16/7/29.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJTuple.h"

#define YJKVOPair(OBJECT, KEYPATH) \
    [YJKVOPair pairWithObject:OBJECT keyPath:KEYPATH]

NS_ASSUME_NONNULL_BEGIN

@interface YJKVOPair : YJTuple

- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath;
+ (instancetype)pairWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath;

@property (nonatomic, readonly, strong) __kindof NSObject *object;
@property (nonatomic, readonly, strong) NSString *keyPath;
@property (nonatomic, readonly) BOOL isValid;

@end

NS_ASSUME_NONNULL_END