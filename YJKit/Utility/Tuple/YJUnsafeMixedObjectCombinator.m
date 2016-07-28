//
//  YJUnsafeMixedObjectCombinator.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJUnsafeMixedObjectCombinator.h"

@implementation YJUnsafeMixedObjectCombinator

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx {
    yj_comb_set(self, obj, idx);
}

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return yj_comb_get(self, idx);
}

@end
