//
//  YJMutableUnsafeUnretainedTuple.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJMutableUnsafeUnretainedTuple.h"

@interface YJMutableUnsafeUnretainedTuple () 

@end

@implementation YJMutableUnsafeUnretainedTuple

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx {
    yj_tupleM_set(self, obj, idx);
}

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return yj_tupleM_get(self, idx);
}

@end
