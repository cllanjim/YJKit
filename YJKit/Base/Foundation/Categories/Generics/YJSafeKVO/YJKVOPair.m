//
//  YJKVOPair.m
//  YJKit
//
//  Created by huang-kun on 16/7/29.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJKVOPair.h"

@implementation YJKVOPair

- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    return [super initWithObjects:object, keyPath, nil];
}

+ (instancetype)pairWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    return [[self alloc] initWithObject:object keyPath:keyPath];
}

- (__kindof NSObject *)object {
    return self.first;
}

- (NSString *)keyPath {
    return self.last;
}

- (BOOL)isValid {
    if (![self isKindOfClass:[YJKVOPair class]]) return NO;
    NSAssert(self.object != nil, @"YJSafeKVO Exception - Target can not be nil for Key value observing.");
    NSAssert(self.keyPath.length > 0, @"YJSafeKVO Exception - KeyPath can not be empty for Key value observing.");
    return self.object && self.keyPath.length;
}

@end
