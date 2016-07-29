//
//  YJKVOPort.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YJKVOPort, YJKVOPair;

#define _OBJECTIFY_KEYPATH(OBJECT, KEYPATH) \
    @(((void)(NO && ((void)OBJECT.KEYPATH, NO)), #KEYPATH))

#ifndef keyPath
#define keyPath(KEYPATH) \
    (((void)(NO && ((void)KEYPATH, NO)), strchr(#KEYPATH, '.') + 1))
#endif

#define PACK(OBJECT, KEYPATH) \
    [YJKVOPort portWithObject:OBJECT \
                      keyPath:_OBJECTIFY_KEYPATH(OBJECT, KEYPATH) \
                           on:self]

/// PACK(OBJECT, KEYPATH) is a macro to wrap object and its key path to a YJKVOPort.
/// e.g. PACK(foo, name) or PACK(foo, friend.name)
typedef YJKVOPort * PACK;


/// The class for wrapping observed source and it's key path.
/// DO NOT USE "YJKVOPort" directly, use PACK(OBJECT, KEYPATH) macro for objective c and use PACK( object, "keyPath" ) for swift.
@interface YJKVOPort : NSObject

/// The designated initializer, and do not call it directly, use PACK.
- (instancetype)initWithObject:(__kindof NSObject *)object
                       keyPath:(NSString *)keyPath
                        NS_DESIGNATED_INITIALIZER
                        NS_SWIFT_NAME(init(_:_:));

/// The factory method initializer, and do not call it directly, use PACK.
+ (instancetype)portWithObject:(__kindof NSObject *)object
                       keyPath:(NSString *)keyPath
                            on:(nullable __kindof NSObject *)on
                            NS_SWIFT_UNAVAILABLE("Use init(_:_:) instead.");

/// The object and keyPath pair.
@property (nonatomic, readonly, strong) YJKVOPair *pair;

@end


/* --------------------------------------------------------------------------------------------- */
//                                          Subscribing
/* --------------------------------------------------------------------------------------------- */

@interface YJKVOPort (YJKVOSubscribing)


/**
 @brief Bind source to subscriber for posting value changes.
 @discussion After calling [A bindTo:B], the data flow will come from A to B.
 @param subscriberAndKeyPath    The subscriber and its key path for receiving changes. Using PACK(source, keyPath) to wrap them.
 @return It returns PACK object that can be nested with additional calls.
 */
- (PACK)bindTo:(PACK)subscriberAndKeyPath;


/**
 @brief Make subscriber bound to source for receiving value changes.
 @discussion After calling [A boundTo:B], the data flow will come from B to A.
 @param sourceAndKeyPath    The source and its key path to get changes from. Using PACK(source, keyPath) to wrap them.
 @return It returns PACK object that can be nested with additional calls.
 */
- (PACK)boundTo:(PACK)sourceAndKeyPath;


/**
 @brief Receive value from source's keyPath immediately.
 */
- (void)now;


/**
 @brief If the new changes should be taken (meaning accepted by subscriber).
 @param The taken block for deciding if new changes should be applied to subscriber.
 */
- (PACK)filter:(BOOL(^)(id _Nullable value))filter;


/**
 @brief Convert the newValue to other kind of object as new returned value.
 @param The convert block for value convertion.
 */
- (PACK)convert:(id _Nullable(^)(id _Nullable value))convert;


/**
 @brief Get called after each pipe finished.
 @param The after block for additional callback.
 */
- (PACK)applied:(void(^)(void))applied;


/**
 @brief Receiving changes from multiple sources with keyPaths.
 @param reduce The block for reducing the result, then returns a result for setting subscriber's keyPath.
 */
- (void)combineLatest:(NSArray <PACK> *)sourcesAndKeyPaths
               reduce:(id _Nullable(^)(/* id _Nullable newValue1, id _Nullable newValue2, ... */))reduce;


/**
 @brief Cutting off the binding relationship between subscriber's keyPath and source's keyPath.
 @discussion This is for cutting off -bounds: or -piped:
 @discussion After calling this, the subscriber with its key path will not receive the value changes
             from specified source with its key path.
 */
- (void)cutOff:(PACK)sourceAndKeyPath;

@end


/* --------------------------------------------------------------------------------------------- */
//                                            posting
/* --------------------------------------------------------------------------------------------- */

@interface YJKVOPort (YJKVOPosting)

/**
 @brief Post the value changes from sender's key path.
 @param The post block will be called immediately and for each time when new value is being set.
 */
- (PACK)post:(void(^)(id _Nullable value))post NS_SWIFT_UNAVAILABLE("Use observe() instead.");

/**
 @brief Stop posting the value changes.
 @discussion After calling this, the post block will be released.
 */
- (void)stopPosting NS_SWIFT_UNAVAILABLE("Use observe() and unobserve() instead.");

@end

NS_ASSUME_NONNULL_END
