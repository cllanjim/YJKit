//
//  YJKVOPackTuple.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YJKVOPackTuple;

#ifndef keyPath
#define keyPath(KEYPATH) \
    (((void)(NO && ((void)KEYPATH, NO)), strchr(#KEYPATH, '.') + 1))
#endif

#define KEYPATH_OBJECTIFY(OBJECT, KEYPATH) \
    @(((void)(NO && ((void)OBJECT.KEYPATH, NO)), #KEYPATH))

#define PACK(OBJECT, KEYPATH) \
    [YJKVOPackTuple tupleWithObject:OBJECT keyPath:KEYPATH_OBJECTIFY(OBJECT, KEYPATH)]


/// PACK(OBJECT, KEYPATH) is a macro to wrap object and its key path to a YJKVOPackTuple.
/// e.g. PACK(foo, name) or PACK(foo, friend.name)
typedef YJKVOPackTuple * PACK;


NS_ASSUME_NONNULL_BEGIN

/// The class for wrapping observed target and it's key path

@interface YJKVOPackTuple : NSObject

+ (instancetype)tupleWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath;

@property (nonatomic, readonly, strong) __kindof NSObject *object;
@property (nonatomic, readonly, strong) NSString *keyPath;
@property (nonatomic, readonly) BOOL isValid;

@end


/// Binding Extension

@interface YJKVOPackTuple (YJKVOBinding)


/**
 @brief Bind observer with target for receiving value changes. This will receive value immediately.
 @warning Using this for single direction. If [A bind:B] then [B bind:A], you will get infinite loop.
 @param targetAndKeyPath    The target and its key path to observe. Using PACK(target, keyPath) to wrap them.
 */
- (void)bind:(PACK)targetAndKeyPath;


/**
 @brief Making a pipe between observer and target for receiving value changes.
 @discussion Calling [[A piped:B] ready] will get same results as [A bind:B]
 @warning Using this for single direction. If [A piped:B] then [B piped:A], you will get infinite loop.
 @param targetAndKeyPath    The target and its key path to observe. Using PACK(target, keyPath) to wrap them.
 @return It returns BIND that can be nested with additional calls.
 */
- (PACK)piped:(PACK)targetAndKeyPath;


/**
 @brief Set value from target's keyPath immediately.
 @discussion e.g. You can call [[[[A piped:B] convert:..] after:..] ready]
 */
- (void)ready;


/**
 @brief If the new changes should be taken (meaning accepted by observer).
 @param The taken block for deciding if new changes should be applied to observer.
 */
- (PACK)taken:(BOOL(^)(id observer, id target, id _Nullable newValue))taken;


/**
 @brief Convert the newValue to other kind of object as new returned value.
 @param The convert block for value convertion.
 */
- (PACK)convert:(nullable id(^)(id observer, id target, id _Nullable newValue))convert;


/**
 @brief Get called after each pipe finished.
 @param The after block for additional callback.
 */
- (PACK)after:(void(^)(id observer, id target))after;

@end

NS_ASSUME_NONNULL_END