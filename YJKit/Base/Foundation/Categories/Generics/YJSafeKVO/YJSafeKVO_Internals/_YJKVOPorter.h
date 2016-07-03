//
//  _YJKVOPorter.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_YJKVODefines.h"

NS_ASSUME_NONNULL_BEGIN

/// The class for deliver the value changes.

__attribute__((visibility("hidden")))
@interface _YJKVOPorter : NSObject

/// The designated initializer
- (instancetype)initWithObserver:(__kindof NSObject *)observer
                           queue:(nullable NSOperationQueue *)queue
                         handler:(YJKVOHandler)handler;

/// The observer for each porter.
@property (nonatomic, weak, readonly) __kindof NSObject *observer;

@end

NS_ASSUME_NONNULL_END