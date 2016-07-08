//
//  _YJKVOKeyPathManager.m
//  YJKit
//
//  Created by huang-kun on 16/7/8.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOKeyPathManager.h"
#import "_YJKVOPorterTracker.h"
#import "NSObject+YJKVOExtension.h"

@implementation _YJKVOKeyPathManager {
    __unsafe_unretained id _observer;
    dispatch_semaphore_t _semaphore;
    NSMutableDictionary <NSString *, NSMutableArray <NSString *> *> *_keyPaths;
}

- (instancetype)initWithObserver:(id)observer {
    self = [super init];
    if (self) {
        _observer = observer;
        _semaphore = dispatch_semaphore_create(1);
        _keyPaths = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

- (NSString *)_targetKeyPathCombinedForTarget:(__kindof NSObject *)target keyPath:(NSString *)targetKeyPath {
    return [NSString stringWithFormat:@"%@<%p>.%@", NSStringFromClass([target class]), target, targetKeyPath];
}

- (void)bindTarget:(__kindof NSObject *)target withKeyPath:(NSString *)targetKeyPath toObserverKeyPath:(NSString *)observerKeyPath {
    
    NSString *combinedKeyPath = [self _targetKeyPathCombinedForTarget:target keyPath:targetKeyPath];
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableArray *observerKeyPaths = _keyPaths[combinedKeyPath];
    if (!observerKeyPaths) {
        observerKeyPaths = [NSMutableArray new];
        _keyPaths[combinedKeyPath] = observerKeyPaths;
    }
    
    [observerKeyPaths addObject:observerKeyPath];
    dispatch_semaphore_signal(_semaphore);
}

- (void)unbindTarget:(__kindof NSObject *)target withKeyPath:(NSString *)targetKeyPath {
    NSString *combinedKeyPath = [self _targetKeyPathCombinedForTarget:target keyPath:targetKeyPath];
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (_keyPaths[combinedKeyPath]) {
        [_keyPaths removeObjectForKey:combinedKeyPath];
        [self.yj_KVOTracker untrackRelatedPortersForKeyPath:targetKeyPath target:target];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (NSArray *)keyPathsFromObserverForBindingTarget:(__kindof NSObject *)target withKeyPath:(NSString *)targetKeyPath {
    NSString *combinedKeyPath = [self _targetKeyPathCombinedForTarget:target keyPath:targetKeyPath];
    return [_keyPaths[combinedKeyPath] copy];
}

@end
