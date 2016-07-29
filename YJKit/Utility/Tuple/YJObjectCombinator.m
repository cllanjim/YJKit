//
//  YJObjectCombinator.m
//  YJKit
//
//  Created by huang-kun on 16/7/29.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJObjectCombinator.h"

@implementation YJObjectCombinator

- (void)setObject:(nullable id)obj atIndexedSubscript:(NSUInteger)idx {
    yj_comb_set(self, obj, idx);
}

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return yj_comb_get(self, idx);
}

@end
