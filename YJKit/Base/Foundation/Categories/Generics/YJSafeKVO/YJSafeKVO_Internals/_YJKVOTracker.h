//
//  _YJKVOTracker.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _YJKVOPorter;

NS_ASSUME_NONNULL_BEGIN

/// The class for tracking porters for observer

__attribute__((visibility("hidden")))
@interface _YJKVOTracker : NSObject

- (instancetype)initWithObserver:(__kindof NSObject *)observer;

- (void)trackPorter:(_YJKVOPorter *)porter forKeyPath:(NSString *)keyPath target:(__kindof NSObject *)target;

- (void)untrackRelatedPortersForKeyPath:(NSString *)keyPath target:(__kindof NSObject *)target;

- (void)untrackAllRelatedPorters;

@end

NS_ASSUME_NONNULL_END