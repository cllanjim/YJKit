//
//  YJKVOPackTuple.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJKVOPackTuple.h"
#import "_YJKVOInternalFunctions.h"
#import "_YJKVOBindingPorter.h"

@interface YJKVOPackTuple ()
@property (nonatomic, strong) __kindof NSObject *object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) _YJKVOBindingPorter *bindingPorter;
@end

@implementation YJKVOPackTuple

+ (instancetype)tupleWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    // preset binding key path
    _yj_presetKVOBindingKeyPath(object, keyPath);
    // create tuple box
    YJKVOPackTuple *tuple = [YJKVOPackTuple new];
    tuple.object = object;
    tuple.keyPath = keyPath;
    return tuple;
}

- (id)bind:(PACK)targetAndKeyPath {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        id porter = _yj_registerKVO_binding(self.object, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil);
        [targetAndKeyPath setBindingPorter:porter];
    }
    return targetAndKeyPath;
}

- (void)unbind:(PACK)targetAndKeyPath {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        _yj_unregisterKVO_binding(self.object, target, keyPath);
    }
}

- (id)convert:(id(^)(id observer, id target, id newValue))convert {
    self.bindingPorter.convertHandler = convert;
    return self;
}

- (id)after:(void(^)(id observer, id target))after {
    self.bindingPorter.afterHandler = after;
    return self;
}

@end