//
//  _YJKVOBindingPorter.h
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOPorter.h"

NS_ASSUME_NONNULL_BEGIN

/// The class for deliver the value changes.

__attribute__((visibility("hidden")))
@interface _YJKVOBindingPorter : _YJKVOPorter

/// The designated initializer
- (instancetype)initWithObserver:(__kindof NSObject *)observer
                           queue:(nullable NSOperationQueue *)queue
                     bindingHandler:(YJKVOReturnValueHandler)bindingHandler;

@end

NS_ASSUME_NONNULL_END