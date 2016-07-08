//
//  _YJKVOKeyPathManager.h
//  YJKit
//
//  Created by huang-kun on 16/7/8.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Class for managing key paths associated with the KVO binding feature.
/// This class will be attached to observer.

__attribute__((visibility("hidden")))
@interface _YJKVOKeyPathManager : NSObject

/// designated initializer
- (instancetype)initWithObserver:(id)observer;

/// bind related key paths
- (void)bindTarget:(__kindof NSObject *)target
       withKeyPath:(NSString *)targetKeyPath
 toObserverKeyPath:(NSString *)observerKeyPath;

/// cancal binding related key paths
- (void)unbindTarget:(__kindof NSObject *)target
         withKeyPath:(NSString *)targetKeyPath;

/// get related binding key paths
- (NSArray *)keyPathsFromObserverForBindingTarget:(__kindof NSObject *)target
                                      withKeyPath:(NSString *)targetKeyPath;

@end

NS_ASSUME_NONNULL_END