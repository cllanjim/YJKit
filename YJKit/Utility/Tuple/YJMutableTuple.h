//
//  YJMutableTuple.h
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YJMutableTuple(CLASS, ...) yj_tupleM_new([CLASS class], __VA_ARGS__, nil)

#define YJ_MUTABLE_TUPLE_MAX_NUMBER_OF_VALUES 10

NS_ASSUME_NONNULL_BEGIN

@protocol YJMutableTuple <NSObject>

- (void)setFirst:(nullable id)first;
- (void)setSecond:(nullable id)second;
- (void)setThird:(nullable id)third;
- (void)setFourth:(nullable id)fourth;
- (void)setFifth:(nullable id)fifth;
- (void)setSixth:(nullable id)sixth;
- (void)setSeventh:(nullable id)seventh;
- (void)setEighth:(nullable id)eighth;
- (void)setNinth:(nullable id)ninth;
- (void)setTenth:(nullable id)tenth;

- (nullable id)first;
- (nullable id)second;
- (nullable id)third;
- (nullable id)fourth;
- (nullable id)fifth;
- (nullable id)sixth;
- (nullable id)seventh;
- (nullable id)eighth;
- (nullable id)ninth;
- (nullable id)tenth;

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

id yj_tupleM_new(Class cls, id first, ...);

id yj_tupleM_get(id tuple, NSUInteger idx);

void yj_tupleM_set(id tuple, id object, NSUInteger idx);

NS_ASSUME_NONNULL_END
