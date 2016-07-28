//
//  _YJKVOBindingPorter.h
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOAssemblingPorter.h"

__attribute__((visibility("hidden")))
@interface _YJKVOBindingPorter : _YJKVOAssemblingPorter

/// The designated initializer
- (instancetype)initWithTarget:(__kindof NSObject *)target
                    subscriber:(__kindof NSObject *)subscriber
                 targetKeyPath:(NSString *)targetKeyPath
             subscriberKeyPath:(NSString *)subscriberKeyPath NS_DESIGNATED_INITIALIZER;

/// Associate with subscribers's key path for applying changes directly.
@property (nonatomic, readonly, copy) NSString *subscriberKeyPath;

@end
