//
//  _YJKVOAssemblingPorter.h
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOPorter.h"

FOUNDATION_EXTERN const NSInteger YJKeyValueFilteringTag;
FOUNDATION_EXTERN const NSInteger YJKeyValueConvertingTag;
FOUNDATION_EXTERN const NSInteger YJKeyValueAppliedTag;

@class YJObjectCombinator;

NS_ASSUME_NONNULL_BEGIN

/// The class for deliver the value changes.

__attribute__((visibility("hidden")))
@interface _YJKVOAssemblingPorter : _YJKVOPorter

/// Associate with subscribers's key path for applying changes directly.
@property (nullable, nonatomic, copy) NSString *subscriberKeyPath;

/// The value change callback block.
@property (nullable, nonatomic, copy) YJKVOValueHandler valueHandler;

/// Add handler block for handling value changes.
- (void)addKVOHandler:(id)handler forTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END