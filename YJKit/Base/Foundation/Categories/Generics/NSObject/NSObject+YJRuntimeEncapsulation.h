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
//     NSObject (YJRuntimeExtension)
/* ----------------------------------- */

OBJC_EXPORT bool yj_objc_isClass(id obj);

@interface NSObject (YJRuntimeExtension)

/// Check if the current class has the selector,
/// not responds from its superclass.
- (BOOL)containsSelector:(SEL)selector;

@end


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

/// Exchange the implementations between two given selectors.
/// @note If the class does not own the method by given selector originally,
/// it will add the method first, then switch the implementation.
+ (void)swizzleInstanceMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;

/// Exchange the implementations between two given selectors.
/// @note If the class does not own the method by given selector originally,
/// it will add the method first, then switch the implementation.
+ (void)swizzleClassMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;

@end


/* ----------------------------------- */
//   NSObject (YJMethodImpModifying)
/* ----------------------------------- */

@interface NSObject (YJMethodImpModifying)

/// Insert blocks of code which will be executed before (or after)
/// the default implementation of given selector.
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
/// @warning If the class does not own the method by given selector originally, it will
/// go up the chain and check its super's. If this case is not what you expected, you should
/// use -swizzleInstanceMethodForSelector:toSelector: to add method to current class first,
/// then calling this will prevent you modifying the method implementation from its superclass.
- (void)insertImplementationBlocksIntoInstanceMethodForSelector:(SEL)selector
                                                     identifier:(nullable NSString *)identifier
                                                         before:(nullable void(^)(id receiver))before
                                                          after:(nullable void(^)(id receiver))after;

/// Insert blocks of code which will be executed before (or after)
/// the default implementation of given selector.
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
/// @warning If the class does not own the method by given selector originally, it will
/// go up the chain and check its super's. If this case is not what you expected, you should
/// use -swizzleClassMethodForSelector:toSelector: to add method to current class first,
/// then calling this will prevent you modifying the method implementation from its superclass.
+ (void)insertImplementationBlocksIntoClassMethodForSelector:(SEL)selector
                                                  identifier:(nullable NSString *)identifier
                                                      before:(nullable void(^)(id receiver))before
                                                       after:(nullable void(^)(id receiver))after;

@end

NS_ASSUME_NONNULL_END