//
//  _YJKVOExecutiveOfficer.h
//  YJKit
//
//  Created by huang-kun on 16/7/9.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _YJKVOPorter;

/// This class is responsible for organizing the internal objects,
/// including assigning duty to each class.

__attribute__((visibility("hidden")))
@interface _YJKVOExecutiveOfficer : NSObject

/// singleton object
+ (instancetype)officer;

/// register KVO and organize internal objects into KVO chain.
- (void)organizeTarget:(__kindof NSObject *)target
            subscriber:(__kindof NSObject *)subscriber
                porter:(__kindof _YJKVOPorter *)porter;

/// dismiss target from KVO chain.
- (void)dismissTarget:(__kindof NSObject *)target;

/// dismiss specified internal objects from KVO chain.
- (void)dismissSubscriber:(__kindof NSObject *)subscriber
               fromTarget:(__kindof NSObject *)target
            targetKeyPath:(NSString *)targetKeyPath;

/// dismiss specified subscriber from KVO chain.
- (void)dismissSubscriber:(__kindof NSObject *)subscriber;

@end
