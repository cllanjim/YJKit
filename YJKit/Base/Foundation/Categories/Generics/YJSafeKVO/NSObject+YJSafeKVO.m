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
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOTracker.h"

#pragma mark - YJSafeKVO implementations

@implementation NSObject (YJSafeKVO)

- (void)observe:(PACK)targetAndKeyPath updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_validatePackTuple(targetAndKeyPath, &target, &keyPath)) {
        
        void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
            if (updates) updates(receiver, target, newValue);
        };
        
        _yj_registerKVO(self, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, handler);
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
        [self.yj_KVOTracker untrackRelatedPortersForKeyPath:keyPath target:target];
    }
}

- (void)observeTarget:(__kindof NSObject *)target
              keyPath:(NSString *)keyPath
              updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    
    void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
        if (updates) updates(receiver, target, newValue);
    };
    
    _yj_registerKVO(self, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, handler);
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
    [self.yj_KVOTracker untrackRelatedPortersForKeyPath:keyPath target:target];
}

- (void)unobserveAll {
    [self.yj_KVOTracker untrackAllRelatedPorters];
}

@end
