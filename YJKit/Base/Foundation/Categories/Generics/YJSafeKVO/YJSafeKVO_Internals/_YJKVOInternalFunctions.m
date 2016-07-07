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
#import "_YJKVOManager.h"
#import "_YJKVOTracker.h"
#import "_YJKVODefines.h"
#import "YJKVOPackTuple.h"

  void _yj_handlePorter(__kindof _YJKVOPorter *porter,
                             __kindof NSObject *observer,
                             __kindof NSObject *target,
                             NSString *keyPath,
                             NSKeyValueObservingOptions options) {
    
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
    [target performBlockBeforeDeallocating:^(__kindof NSObject *target) {
        [target.yj_KVOManager unemployAllPorters];
    }];
    [observer performBlockBeforeDeallocating:^(__kindof NSObject *observer) {
        [observer.yj_KVOTracker untrackAllRelatedPorters];
    }];
}

  void _yj_registerKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                            NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOHandler handler) {
    
    // generate a porter
    _YJKVOPorter *porter = [[_YJKVOPorter alloc] initWithObserver:observer queue:queue handler:handler];
    _yj_handlePorter(porter, observer, target, keyPath, options);
}

  void _yj_registerKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                                  NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOBindHandler bindHandler) {
    
    // generate a porter
    _YJKVOBindingPorter *porter = [[_YJKVOBindingPorter alloc] initWithObserver:observer queue:queue bindHandler:bindHandler];
    _yj_handlePorter(porter, observer, target, keyPath, options);
}

  void _yj_registerKVO_grouping(__kindof NSObject *observer,
                                     NSArray <__kindof NSObject *> *targets,
                                     NSArray <NSString *> *keyPaths,
                                     NSKeyValueObservingOptions options,
                                     NSOperationQueue *queue,
                                     YJKVOGroupHandler groupHandler) {
    
    NSCAssert(targets.count == keyPaths.count, @"YJSafeKVO - targets and keyPaths are not paired.");
    
    // generate a porter
    _YJKVOGroupingPorter *porter = [[_YJKVOGroupingPorter alloc] initWithObserver:observer
                                                                          targets:targets
                                                                            queue:queue
                                                                     groupHandler:groupHandler];
    for (int i = 0; i < targets.count; i++) {
        __kindof NSObject *target = targets[i];
        NSString *keyPath = keyPaths[i];
        _yj_handlePorter(porter, observer, target, keyPath, options);
    }
}

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