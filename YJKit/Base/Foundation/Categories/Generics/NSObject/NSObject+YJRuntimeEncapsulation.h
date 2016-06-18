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
//          Runtime Extension
/* ----------------------------------- */

/// Check if the object is an instance or a class object.
OBJC_EXPORT bool yj_objc_isClass(id obj);


@interface NSObject (YJRuntimeExtension)

/// @brief Check if the current class owns the method by given selector, which is not inherited
///        from its superclass.
/// @discussion e.g. NSArray class has selector -containsObject:, NSMutableArray inherits from NSArray,
///             which doesn't override the -containsObject:, so -containsObject: is not part of
///             NSMutableArray's own method list.
/// @code
/// NSMutableArray *mutableArray = @[].mutableCopy;
/// BOOL b1 = [mutableArray respondsToSelector:@selector(containsObject:)]; // YES
/// BOOL b2 = [mutableArray containsSelector:@selector(containsObject:)];   // NO
/// @endcode
- (BOOL)containsSelector:(SEL)selector;

@end


/* ----------------------------------- */
//     Associated Identifier / Tag
/* ----------------------------------- */

FOUNDATION_EXTERN const NSInteger YJAssociatedTagInvalid;
FOUNDATION_EXTERN const NSInteger YJAssociatedTagNone;

@interface NSObject (YJAssociatedIdentifier)

/// Add a associated unique identifier string related to object itself.
/// @warning It will not effective if object is a tagged pointer. If you
///          set value to a tagged pointer, you will get nil result.
@property (nullable, nonatomic, copy) NSString *associatedIdentifier;

/// Add a associated unique number as a tag related to object itself.
/// @warning It will not effective if object is a tagged pointer. If you
///          set value to a tagged pointer, you will get YJAssociatedTagInvalid
///          as result. 0 is considered as YJAssociatedTagNone.
@property (nonatomic, assign) NSInteger associatedTag;

@end


@interface NSArray <ObjectType> (YJAssociatedIdentifier)

/// Check if NSArray contains object with specified identifier.
- (BOOL)containsObjectWithAssociatedIdentifier:(NSString *)associatedIdentifier;

/// Check if NSArray contains object with specified tag.
- (BOOL)containsObjectWithAssociatedTag:(NSInteger)associatedTag;

/// Only enumerate objects in the array which either has an associated identifier or a valid associated tag.
- (void)enumerateAssociatedObjectsUsingBlock:(void (^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

@end


/* ----------------------------------- */
//           Method Swizzling
/* ----------------------------------- */

@interface NSObject (YJSwizzling)

/// Exchange the implementations between two given selectors.
/// @note If the class does not own the method by given selector originally,
///       it will add the method first, then switch the implementation.
+ (void)swizzleInstanceMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;

/// Exchange the implementations between two given selectors.
/// @note If the class does not own the method by given selector originally,
///       it will add the method first, then switch the implementation.
+ (void)swizzleClassMethodForSelector:(SEL)selector toSelector:(SEL)toSelector;

@end


/* ----------------------------------- */
//       Method IMP Modification
/* ----------------------------------- */

@interface NSObject (YJMethodImpModifying)

/// @brief Insert blocks of code which will be executed before or after
///        the default implementation of given selector.
/// @discussion If the class does not own the method by given selector originally, it will go up the
///             chain and check its super's. If this case is not what you expected, you could:
///
///   1. Use -[obj containsSelector:] to determine if selector is from super before you call this.
///   2. Use -[obj swizzleInstanceMethodForSelector:toSelector:] to add method to current class first,
///      then call this. It will prevent you modifying the method implementation from its superclass.
///
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
- (void)insertImplementationBlocksIntoInstanceMethodForSelector:(SEL)selector
                                                     identifier:(nullable NSString *)identifier
                                                         before:(nullable void(^)(id receiver))before
                                                          after:(nullable void(^)(id receiver))after;

/// @brief Insert blocks of code which will be executed before or after
///        the default implementation of given selector.
/// @discussion If the class does not own the method by given selector originally, it will go up the
///             chain and check its super's. If this case is not what you expected, you could:
///
///   1. Use -[obj containsSelector:] to determine if selector is from super before you call this.
///   2. Use +[classObj swizzleClassMethodForSelector:toSelector:] to add method to current class first,
///      then call this. It will prevent you modifying the method implementation from its superclass.
///
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
+ (void)insertImplementationBlocksIntoClassMethodForSelector:(SEL)selector
                                                  identifier:(nullable NSString *)identifier
                                                      before:(nullable void(^)(id receiver))before
                                                       after:(nullable void(^)(id receiver))after;

@end

NS_ASSUME_NONNULL_END