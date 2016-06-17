//
//  NSObject+YJRuntimeEncapsulation.h
//  YJKit
//
//  Created by huang-kun on 16/5/13.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* ----------------------------------- */
//         Class type checking
/* ----------------------------------- */

OBJC_EXPORT bool yj_objc_isClass(id obj);


/* ----------------------------------- */
//  NSObject (YJAssociatedIdentifier)
/* ----------------------------------- */

FOUNDATION_EXTERN const NSInteger YJAssociatedTagInvalid;
FOUNDATION_EXTERN const NSInteger YJAssociatedTagNone;

@interface NSObject (YJAssociatedIdentifier)
@property (nonatomic, copy, nullable) NSString *associatedIdentifier; // Maybe returns nil
@property (nonatomic, assign) NSInteger associatedTag; // Maybe returns YJAssociatedTagNone or YJAssociatedTagInvalid
@end


@interface NSArray <ObjectType> (YJAssociatedIdentifier)
- (BOOL)containsObjectWithAssociatedIdentifier:(NSString *)associatedIdentifier;
- (BOOL)containsObjectWithAssociatedTag:(NSInteger)associatedTag;
- (void)enumerateAssociatedObjectsUsingBlock:(void (^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;
@end


/* ----------------------------------- */
//        NSObject (YJSwizzling)
/* ----------------------------------- */

@interface NSObject (YJSwizzling)

+ (void)swizzleInstanceMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;
+ (void)swizzleClassMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;

@end


/* ----------------------------------- */
//   NSObject (YJMethodImpModifying)
/* ----------------------------------- */

@interface NSObject (YJMethodImpModifying)

/// Insert blocks of code which will be executed before (or after)
/// the default implementation of given selector.
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
- (void)insertImplementationBlocksIntoInstanceMethodForSelector:(SEL)selector
                                                     identifier:(nullable NSString *)identifier
                                                         before:(nullable void(^)(id receiver))before
                                                          after:(nullable void(^)(id receiver))after;

/// Insert blocks of code which will be executed before (or after)
/// the default implementation of given selector.
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
+ (void)insertImplementationBlocksIntoClassMethodForSelector:(SEL)selector
                                                  identifier:(nullable NSString *)identifier
                                                      before:(nullable void(^)(id receiver))before
                                                       after:(nullable void(^)(id receiver))after;

@end

NS_ASSUME_NONNULL_END