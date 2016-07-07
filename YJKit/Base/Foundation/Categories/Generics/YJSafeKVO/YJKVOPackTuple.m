//
//  YJKVOPackTuple.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJKVOPackTuple.h"
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOInternalFunctions.h"

@interface YJKVOPackTuple ()
@property (nonatomic, strong) __kindof NSObject *object;
@property (nonatomic, strong) NSString *keyPath;
@end

@implementation YJKVOPackTuple

+ (instancetype)tupleWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    object.yj_KVOBindingKeyPath = keyPath;
    YJKVOPackTuple *tuple = [YJKVOPackTuple new];
    tuple.object = object;
    tuple.keyPath = keyPath;
    return tuple;
}

- (void)bind:(PACK)targetAndKeyPath {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        _yj_registerKVO_binding(self.object, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, nil);
    }
}

- (void)bind:(PACK)targetAndKeyPath convert:(id(^)(id observer, id target, id newValue))convert {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        _yj_registerKVO_binding(self.object, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, convert);
    }
}

@end