//
//  YJTuple.h
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YJTuple(...) \
    [YJTuple tupleWithObjects:__VA_ARGS__, nil]

NS_ASSUME_NONNULL_BEGIN

@interface YJTuple : NSObject <NSFastEnumeration>

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArray:(NSArray *)array;

+ (instancetype)tupleWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)tupleWithArray:(NSArray *)array;

@property (nullable, nonatomic, readonly, strong) id first;
@property (nullable, nonatomic, readonly, strong) id second;
@property (nullable, nonatomic, readonly, strong) id third;
@property (nullable, nonatomic, readonly, strong) id fourth;
@property (nullable, nonatomic, readonly, strong) id fifth;
@property (nullable, nonatomic, readonly, strong) id last;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END