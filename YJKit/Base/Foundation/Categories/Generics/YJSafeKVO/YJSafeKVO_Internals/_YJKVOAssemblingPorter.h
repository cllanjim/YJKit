//
//  _YJKVOAssemblingPorter.h
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOPorter.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^YJKVOValueTakenHandler)(id subscriber, id target, id _Nullable newValue);

/// The class for deliver the value changes.

__attribute__((visibility("hidden")))
@interface _YJKVOAssemblingPorter : _YJKVOPorter

/// The value change callback block which only for converting changes.
@property (nonatomic, copy) YJKVOSubscriberTargetValueReturnHandler convertHandler;

/// The value change callback block which only for filtering changes.
@property (nonatomic, copy) YJKVOValueTakenHandler takenHandler;

/// The value change callback block which only called after applying changes.
@property (nonatomic, copy) YJKVOSubscriberTargetHandler afterHandler;

/// Handle changed value.
- (void)handleValue:(nullable id)value fromObject:(id)object keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END