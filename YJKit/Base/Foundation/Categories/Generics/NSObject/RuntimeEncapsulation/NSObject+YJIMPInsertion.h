//
//  NSObject+YJIMPInsertion.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YJIMPInsertion)

/*
 
 @interface Foo : NSObject
 
 - (void)hello;
 + (void)hello;
 
 @end
 
 
 Foo *foo = [Foo new];
 [foo insertBlocksIntoMethodBySelector:@selector(hello) ... // it will change the default IMP of instance method -hello
 [Foo insertBlocksIntoMethodBySelector:@selector(hello) ... // it will change the default IMP of class method +hello
 
 
 // To summerize:
 
 // .If the receiver is an instance, it will change the default IMP of method by the given selector which represents an intance method.
 // .If the receiver is a class, it will change the default IMP of method by the given selector which represents an class method.
 
 */

/// @brief Insert blocks of code which will be executed before and after the default implementation of
///        receiver's instance method by given selector.
///
/// @discussion If the class does not own the method by given selector originally, it will go up the
///             chain and check its super's.
///
/// @param selector   The selector for receiver (which responds to) for locating target method. If the
///                   selector is not responded by receiver, it will not crash but returns NO.
/// @param identifier Specify an identifier will prevent insertion with same identifier in same class.
/// @param before     The block of code which will be executed before the method implementation.
/// @param after      The block of code which will be executed after the method implementation.
///
/// @return Whether insertion is success or not.
///
- (BOOL)insertBlocksIntoMethodBySelector:(SEL)selector
                              identifier:(nullable NSString *)identifier
                                  before:(nullable void(^)(id receiver))before
                                   after:(nullable void(^)(id receiver))after;


/// @brief Insert blocks of code which will be executed before and after the default implementation of
///        receiver's class method by given selector.
///
/// @discussion If the class does not own the method by given selector originally, it will go up the
///             chain and check its super's.
///
/// @param selector   The selector for receiver (which responds to) for locating target method. If the
///                   selector is not responded by receiver, it will not crash but returns NO.
/// @param identifier Specify an identifier will prevent insertion with same identifier in same class.
/// @param before     The block of code which will be executed before the method implementation.
/// @param after      The block of code which will be executed after the method implementation.
///
/// @return Whether insertion is success or not.
///
+ (BOOL)insertBlocksIntoMethodBySelector:(SEL)selector
                              identifier:(nullable NSString *)identifier
                                  before:(nullable void(^)(id receiver))before
                                   after:(nullable void(^)(id receiver))after;


/// @brief Convenience method for clean-up before dealloc
/// @note  Can not perform different block for objects that have same class.
- (void)performBlockBeforeDeallocating:(void(^)(id receiver))block;

@end

NS_ASSUME_NONNULL_END