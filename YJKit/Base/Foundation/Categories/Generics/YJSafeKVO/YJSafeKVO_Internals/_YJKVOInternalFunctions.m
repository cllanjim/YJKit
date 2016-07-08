//
//  _YJKVOInternalFunctions.m
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOInternalFunctions.h"
#import "NSObject+YJIMPInsertion.h"
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOPorter.h"
#import "_YJKVOGroupingPorter.h"
#import "_YJKVOBindingPorter.h"
#import "_YJKVOPorterManager.h"
#import "_YJKVOPorterTracker.h"
#import "_YJKVOKeyPathManager.h"
#import "_YJKVODefines.h"
#import "YJKVOPackTuple.h"

#pragma mark - Register

void _yj_handlePorter(__kindof _YJKVOPorter *porter,
                             __kindof NSObject *observer,
                             __kindof NSObject *target,
                             NSString *keyPath,
                             NSKeyValueObservingOptions options) {
    
    // manage porter
    _YJKVOPorterManager *kvoManager = target.yj_KVOPorterManager;
    if (!kvoManager) {
        kvoManager = [[_YJKVOPorterManager alloc] initWithObservedTarget:target];
        target.yj_KVOPorterManager = kvoManager;
    }
    [kvoManager employPorter:porter forKeyPath:keyPath options:options];
    
    // track porter
    _YJKVOPorterTracker *tracker = observer.yj_KVOTracker;
    if (!tracker) {
        tracker = [[_YJKVOPorterTracker alloc] initWithObserver:observer];
        observer.yj_KVOTracker = tracker;
    }
    [tracker trackPorter:porter forKeyPath:keyPath target:target];
    
    // release porters before dealloc
    [target performBlockBeforeDeallocating:^(__kindof NSObject *target) {
        [target.yj_KVOPorterManager unemployAllPorters];
    }];
    [observer performBlockBeforeDeallocating:^(__kindof NSObject *observer) {
        [observer.yj_KVOTracker untrackAllRelatedPorters];
    }];
}

void _yj_registerKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                            NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOChangeHandler handler) {
    
    // generate a porter
    _YJKVOPorter *porter = [[_YJKVOPorter alloc] initWithObserver:observer queue:queue handler:handler];
    _yj_handlePorter(porter, observer, target, keyPath, options);
}

void _yj_presetKVOBindingKeyPath(__kindof NSObject *observer,  NSString *keyPath) {
    observer.yj_KVOTemporaryKeyPath = keyPath;
}

void _yj_registerKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                                  NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOReturnValueHandler bindingHandler) {
    // handle observer's key path binding
    if (!observer.yj_KVOTemporaryKeyPath)
        return;
        
    _YJKVOKeyPathManager *keyPathManager = observer.yj_KVOKeyPathManager;
    if (!keyPathManager) {
        keyPathManager = [[_YJKVOKeyPathManager alloc] initWithObserver:observer];
        observer.yj_KVOKeyPathManager = keyPathManager;
    }
    [keyPathManager bindTarget:target withKeyPath:keyPath toObserverKeyPath:observer.yj_KVOTemporaryKeyPath];
    observer.yj_KVOTemporaryKeyPath = nil;
    
    // generate a porter
    _YJKVOBindingPorter *porter = [[_YJKVOBindingPorter alloc] initWithObserver:observer queue:queue bindingHandler:bindingHandler];
    _yj_handlePorter(porter, observer, target, keyPath, options);
}

void _yj_registerKVO_grouping(__kindof NSObject *observer,
                                     NSArray <__kindof NSObject *> *targets,
                                     NSArray <NSString *> *keyPaths,
                                     NSKeyValueObservingOptions options,
                                     NSOperationQueue *queue,
                                     YJKVOTargetsHandler targetsHandler) {
    
    NSCAssert(targets.count == keyPaths.count, @"YJSafeKVO - targets and keyPaths are not paired.");
    
    // generate a porter
    _YJKVOGroupingPorter *porter = [[_YJKVOGroupingPorter alloc] initWithObserver:observer
                                                                          targets:targets
                                                                            queue:queue
                                                                     targetsHandler:targetsHandler];
    for (int i = 0; i < targets.count; i++) {
        __kindof NSObject *target = targets[i];
        NSString *keyPath = keyPaths[i];
        _yj_handlePorter(porter, observer, target, keyPath, options);
    }
}

#pragma mark - Unregister

void _yj_unregisterKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath) {
    if (target) [observer.yj_KVOTracker untrackRelatedPortersForKeyPath:keyPath target:target];
    else [observer.yj_KVOTracker untrackAllRelatedPorters];
}

void _yj_unregisterKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath) {
    [observer.yj_KVOKeyPathManager unbindTarget:target withKeyPath:keyPath];
}

#pragma mark - Validation

BOOL _yj_validatePackTuple(id targetAndKeyPath, id *object, NSString **keyPath) {
    if (![targetAndKeyPath isKindOfClass:[YJKVOPackTuple class]])
        return NO;
    
    YJKVOPackTuple *tuple = (YJKVOPackTuple *)targetAndKeyPath;
    
    if (object) {
        *object = tuple.object;
        NSCAssert(*object != nil, @"YJSafeKVO - Target can not be nil for Key value observing.");
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