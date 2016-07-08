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


/// Using PACK macro.
/// e.g. If foo wants to observe bar's name property change when a new name applys to bar, then use:
/// @code
/// [foo observe:PACK(bar, name) ...]
/// @endcode
typedef YJKVOPackTuple * PACK;


NS_ASSUME_NONNULL_BEGIN

/// The class for wrapping observed target and it's key path

@interface YJKVOPackTuple : NSObject

+ (instancetype)tupleWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath;

@property (nonatomic, readonly, strong) __kindof NSObject *object;
@property (nonatomic, readonly, strong) NSString *keyPath;


/**
 @brief Bind the object and its key path for receiving value changes.
 @param targetAndKeyPath    The YJKVOPackTuple object for wrapping object and its key path, using PACK(target, keyPath).
 */
- (void)bind:(PACK)targetAndKeyPath;


/**
 @brief Bind the object and its key path for receiving value changes.
 @param targetAndKeyPath    The YJKVOPackTuple object for wrapping object and its key path, using PACK(target, keyPath).
 @param convert             The block for converting the newValue to other type of object.
 */
- (void)bind:(PACK)targetAndKeyPath convert:(id(^)(id observer, id target, id _Nullable newValue))convert;


/**
 @brief Cancel receiving value changes from binded object with its key path.
 @param targetAndKeyPath    The YJKVOPackTuple object for wrapping object and its key path, using PACK(target, keyPath).
 */
- (void)unbind:(PACK)targetAndKeyPath;

@end

NS_ASSUME_NONNULL_END