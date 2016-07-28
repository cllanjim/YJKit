//
//  YJMutableUnsafeUnretainedTuple.h
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJMutableTuple.h"

#define YJMutableUnsafeUnretainedTuplePack(...) YJMutableTuple(YJMutableUnsafeUnretainedTuple, __VA_ARGS__)

@interface YJMutableUnsafeUnretainedTuple : NSObject <YJMutableTuple>

@property (nullable, nonatomic, assign) id first;
@property (nullable, nonatomic, assign) id second;
@property (nullable, nonatomic, assign) id third;
@property (nullable, nonatomic, assign) id fourth;
@property (nullable, nonatomic, assign) id fifth;
@property (nullable, nonatomic, assign) id sixth;
@property (nullable, nonatomic, assign) id seventh;
@property (nullable, nonatomic, assign) id eighth;
@property (nullable, nonatomic, assign) id ninth;
@property (nullable, nonatomic, assign) id tenth;

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
