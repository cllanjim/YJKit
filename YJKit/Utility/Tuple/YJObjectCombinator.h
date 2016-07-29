//
//  YJObjectCombinator.h
//  YJKit
//
//  Created by huang-kun on 16/7/29.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJObjectCombination.h"

#define YJObjectCombinator(...) YJObjectCombination(YJObjectCombinator, __VA_ARGS__)

@interface YJObjectCombinator : NSObject <YJObjectCombination>

@property (nullable, nonatomic, strong) id first;
@property (nullable, nonatomic, strong) id second;
@property (nullable, nonatomic, strong) id third;
@property (nullable, nonatomic, strong) id fourth;
@property (nullable, nonatomic, strong) id fifth;
@property (nullable, nonatomic, strong) id sixth;
@property (nullable, nonatomic, strong) id seventh;
@property (nullable, nonatomic, strong) id eighth;
@property (nullable, nonatomic, strong) id ninth;
@property (nullable, nonatomic, strong) id tenth;

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
