//
//  NSObject+YJSafeKVO.m
//  YJKit
//
//  Created by huang-kun on 16/4/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJSafeKVO.h"
#import "YJRuntimeEncapsulation.h"
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOPorter.h"
#import "_YJKVOManager.h"
#import "_YJKVOTracker.h"

#pragma mark - internal functions

/* -------------------------- */
//  YJKVO Internal Functions
/* -------------------------- */

static void _yj_registerKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                            NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOHandler handler) {
    
    // generate a porter
    _YJKVOPorter *porter = [[_YJKVOPorter alloc] initWithObserver:observer queue:queue handler:handler];
    
    // manage porter
    _YJKVOManager *kvoManager = target.yj_KVOManager;
    if (!kvoManager) {
        kvoManager = [[_YJKVOManager alloc] initWithObservedTarget:target];
        target.yj_KVOManager = kvoManager;
    }
    [kvoManager employPorter:porter forKeyPath:keyPath options:options];
    
    // track porter
    _YJKVOTracker *tracker = observer.yj_KVOTracker;
    if (!tracker) {
        tracker = [[_YJKVOTracker alloc] initWithObserver:observer];
        observer.yj_KVOTracker = tracker;
    }
    [tracker trackPorter:porter forKeyPath:keyPath target:target];
    
    // release porters before dealloc
    [observer performBlockBeforeDeallocating:^(__kindof NSObject *observer) {
        [observer.yj_KVOManager unemployAllPorters]; // In case if observer is also a target
        [observer.yj_KVOTracker untrackAllRelatedPorters];
    }];
    [target performBlockBeforeDeallocating:^(__kindof NSObject *target) {
        [target.yj_KVOManager unemployAllPorters];
        [target.yj_KVOTracker untrackAllRelatedPorters]; // In case if target is also an observer
    }];
}

static BOOL _yj_KVOMacroParse(id targetAndKeyPath, id *target, NSString **keyPath) {
    if (![targetAndKeyPath isKindOfClass:[YJOBSVTuple class]])
        return NO;
    
    YJOBSVTuple *tuple = (YJOBSVTuple *)targetAndKeyPath;
    
    if (target) {
        *target = tuple.target;
        NSCAssert(*target != nil, @"YJSafeKVO - Target can not be nil for Key value observing.");
    } else {
        return NO;
    }
    
    if (keyPath) {
        *keyPath = tuple.keyPath;
        NSCAssert((*keyPath).length > 0, @"YJSafeKVO - KeyPath can not be empty for Key value observing.");
    } else {
        return NO;
    }
    
    return YES;
}


#pragma mark - YJSafeKVO implementations

/* ------------------------- */
//          YJSafeKVO
/* ------------------------- */

@implementation NSObject (YJSafeKVO)

- (void)observe:(OBSV)targetAndKeyPath updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_KVOMacroParse(targetAndKeyPath, &target, &keyPath)) {
        
        void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
            if (updates) updates(receiver, target, newValue);
        };
        
        _yj_registerKVO(self, target, keyPath, (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew), nil, handler);
    }
}

- (void)observe:(OBSV)targetAndKeyPath
        options:(NSKeyValueObservingOptions)options
          queue:(nullable NSOperationQueue *)queue
        changes:(void(^)(id receiver, id target, NSDictionary *change))changes {
    
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_KVOMacroParse(targetAndKeyPath, &target, &keyPath)) {
        
        void(^handler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
            if (changes) changes(receiver, target, change);
        };
        
        _yj_registerKVO(self, target, keyPath, options, queue, handler);
    }
}

- (void)unobserve:(OBSV)targetAndKeyPath {
    __kindof NSObject *target; NSString *keyPath;
    if (_yj_KVOMacroParse(targetAndKeyPath, &target, &keyPath)) {
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

@end
