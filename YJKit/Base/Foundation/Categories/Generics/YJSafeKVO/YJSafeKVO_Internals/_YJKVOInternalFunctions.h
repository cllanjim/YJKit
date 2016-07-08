//
//  _YJKVOInternalFunctions.h
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_YJKVODefines.h"

@class _YJKVOPorter;

 void _yj_registerKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                            NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOChangeHandler handler);

void _yj_presetKVOBindingKeyPath(__kindof NSObject *observer,  NSString *keyPath);
 void _yj_registerKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                                  NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOReturnValueHandler bindingHandler);

 void _yj_registerKVO_grouping(__kindof NSObject *observer,
                                     NSArray <__kindof NSObject *> *targets,
                                     NSArray <NSString *> *keyPaths,
                                     NSKeyValueObservingOptions options,
                                     NSOperationQueue *queue,
                                     YJKVOTargetsHandler targetsHandler);

 BOOL _yj_validatePackTuple(id targetAndKeyPath, id *target, NSString **keyPath);

void _yj_unregisterKVO(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath);
void _yj_unregisterKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath);