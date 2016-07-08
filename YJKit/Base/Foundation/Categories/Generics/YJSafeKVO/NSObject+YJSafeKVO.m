//
//  NSObject+YJSafeKVO.m
//  YJKit
//
//  Created by huang-kun on 16/4/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "_YJKVOInternalFunctions.h"
#import "NSObject+YJSafeKVO.h"

#pragma mark - YJSafeKVO implementations

YJKVOValueHandler (^yj_convertedKVOValueHandler)(YJKVOChangeHandler) = ^YJKVOValueHandler(YJKVOChangeHandler changeHandler) {
    void(^valueHandler)(id,id,id) = ^(id receiver, id target, id _Nullable newValue) {
        if (changeHandler) changeHandler(receiver, target, newValue, nil);
    };
    return valueHandler;
};

YJKVOChangeHandler (^yj_convertedKVOChangeHandler)(YJKVOValueHandler) = ^YJKVOChangeHandler(YJKVOValueHandler valueHander) {
    void(^changeHandler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
        if (valueHander) valueHander(receiver, target, newValue);
    };
    return changeHandler;
};


@implementation NSObject (YJSafeKVO)

- (void)observe:(PACK)targetAndKeyPath updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        YJKVOChangeHandler changeHandler = yj_convertedKVOChangeHandler(updates);
        _yj_registerKVO(self, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, changeHandler);
    }
}

- (void)observes:(NSArray <PACK> *)targetsAndKeyPaths updates:(void(^)(id receiver, NSArray *targets))updates {
    
    NSMutableArray *targets = [NSMutableArray arrayWithCapacity:targetsAndKeyPaths.count];
    NSMutableArray *keyPaths = [NSMutableArray arrayWithCapacity:targetsAndKeyPaths.count];
    
    for (YJKVOPackTuple *tuple in targetsAndKeyPaths) {
        __kindof NSObject *target; NSString *keyPath;
        if (_yj_validatePackTuple(tuple, &target, &keyPath)) {
            [targets addObject:target];
            [keyPaths addObject:keyPath];
        }
    }
    
    _yj_registerKVO_grouping(self, targets, keyPaths, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, updates);
}

- (void)observe:(PACK)targetAndKeyPath
        options:(NSKeyValueObservingOptions)options
          queue:(nullable NSOperationQueue *)queue
        changes:(void(^)(id receiver, id target, NSDictionary *change))changes {
    
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        
        void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
            if (changes) changes(receiver, target, change);
        };
        
        _yj_registerKVO(self, target, keyPath, options, queue, handler);
    }
}

- (void)unobserve:(PACK)targetAndKeyPath {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        _yj_unregisterKVO(self, target, keyPath);
    }
}

- (void)observeTarget:(__kindof NSObject *)target
              keyPath:(NSString *)keyPath
              updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    YJKVOChangeHandler changeHandler = yj_convertedKVOChangeHandler(updates);
    _yj_registerKVO(self, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, changeHandler);
}

- (void)observeTarget:(__kindof NSObject *)target
              keyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
                queue:(nullable NSOperationQueue *)queue
              changes:(void(^)(id receiver, id target, NSDictionary *change))changes {
    
    void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
        if (changes) changes(receiver, target, change);
    };
    _yj_registerKVO(self, target, keyPath, options, queue, handler);
}

- (void)unobserveTarget:(__kindof NSObject *)target keyPath:(NSString *)keyPath {
    _yj_unregisterKVO(self, target, keyPath);
}

- (void)unobserveAll {
    _yj_unregisterKVO(self, nil, nil);
}

@end
