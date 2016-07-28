//
//  YJUnsafeMixedObjectCombinator.h
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJObjectCombination.h"

#define YJUnsafeMixedObjectCombinatorPack(...) YJObjectCombination(YJUnsafeMixedObjectCombinator, __VA_ARGS__)

@interface YJUnsafeMixedObjectCombinator : NSObject <YJObjectCombination>

@property (nullable, nonatomic, assign) id first;
@property (nullable, nonatomic, strong) id second;
@property (nullable, nonatomic, assign) id third;
@property (nullable, nonatomic, strong) id fourth;
@property (nullable, nonatomic, assign) id fifth;
@property (nullable, nonatomic, strong) id sixth;
@property (nullable, nonatomic, assign) id seventh;
@property (nullable, nonatomic, strong) id eighth;
@property (nullable, nonatomic, assign) id ninth;
@property (nullable, nonatomic, strong) id tenth;

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
