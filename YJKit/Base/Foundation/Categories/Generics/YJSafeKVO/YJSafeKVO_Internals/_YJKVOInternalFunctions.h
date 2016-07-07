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
                            NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOHandler handler);

 void _yj_registerKVO_binding(__kindof NSObject *observer, __kindof NSObject *target, NSString *keyPath,
                                  NSKeyValueObservingOptions options, NSOperationQueue *queue, YJKVOBindHandler bindHandler);

 void _yj_registerKVO_grouping(__kindof NSObject *observer,
                                     NSArray <__kindof NSObject *> *targets,
                                     NSArray <NSString *> *keyPaths,
                                     NSKeyValueObservingOptions options,
                                     NSOperationQueue *queue,
                                     YJKVOGroupHandler groupHandler);

 BOOL _yj_validatePackTuple(id targetAndKeyPath, id *target, NSString **keyPath);