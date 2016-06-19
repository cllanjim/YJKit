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
//              Debugging
/* ----------------------------------- */

@interface NSObject (YJRuntimeDebugging)

/// Print out all instance methods into console.
/// @note The result will not include any method that inherits from it's superclass,
/// but includes non-official methods provided by YJKit and other developers.
+ (void)debugDumpingInstanceMethodList;

/// Print out all class methods into console.
/// @note The result will not include any method that inherits from it's superclass,
/// but includes non-official methods provided by YJKit and other developers.
+ (void)debugDumpingClassMethodList;

@end


/* ----------------------------------- */
//          Runtime Extension
/* ----------------------------------- */

/// Returns whether an object is a class object.
/// YES means if the object is a class or metaclass, NO means otherwise.
/// @note The reason for using yj_object_isClass() instead of object_isClass()
///       is object_isClass() is only support iOS 8 and above.
/// @see object_isClass() in <objc/runtime.h>
OBJC_EXPORT BOOL yj_object_isClass(id obj);


@interface NSObject (YJRuntimeExtension)

/// @brief Check if receiver's class dispatch table contains the selector, which means the selector
///        is not inherited from its superclass.
/// @discussion e.g. NSArray object implements method -containsObject:, NSMutableArray inherits
///             from NSArray, which doesn't override the -containsObject:, so -containsObject:
///             is not part of NSMutableArray's own selector.
/// @code
/// NSMutableArray *mutableArray = @[].mutableCopy;
/// BOOL b1 = [mutableArray respondsToSelector:@selector(containsObject:)]; // YES
/// BOOL b2 = [mutableArray containsSelector:@selector(containsObject:)]; // NO
/// @endcode
- (BOOL)containsSelector:(SEL)selector;

/// @brief Check if receiver's meta class dispatch table contains the selector, which means the selector
///        is not inherited from its superclass.
/// @discussion e.g. NSArray class implements method +arrayWithArray:, NSMutableArray inherits
///             from NSArray, which doesn't override the +arrayWithArray:, so +arrayWithArray:
///             is not part of NSMutableArray's own selector.
/// @code
/// BOOL b1 = [NSMutableArray respondsToSelector:@selector(arrayWithArray:)]; // YES
/// BOOL b2 = [NSMutableArray containsSelector:@selector(arrayWithArray:)]; // NO
/// @endcode
+ (BOOL)containsSelector:(SEL)selector;

/// @brief Check if receiver's dispatch table contains the selector for its instance to responds,
///        which means the selector is not inherited from its superclass.
/// @discussion e.g. NSArray object implements method -containsObject:, NSMutableArray inherits
///             from NSArray, which doesn't override the -containsObject:, so -containsObject:
///             is not part of NSMutableArray's own selector.
/// @code
/// BOOL b1 = [NSMutableArray instancesRespondToSelector:@selector(containsObject:)]; // YES
/// BOOL b2 = [NSMutableArray containsInstanceMethodBySelector:@selector(containsObject:)]; // NO
/// @endcode
+ (BOOL)containsInstanceMethodBySelector:(SEL)selector;

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
/// @note If the class does not originally implements the method by given selector,
///       it will add the method to the class first, then switch the implementations.
+ (void)swizzleInstanceMethodsBySelector:(SEL)selector withSelector:(SEL)providedSelector;

/// Exchange the implementations between two given selectors.
/// @note If the class does not originally implements the method by given selector,
///       it will add the method to the class first, then switch the implementations.
+ (void)swizzleClassMethodsBySelector:(SEL)selector withSelector:(SEL)providedSelector;

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
///   2. Use +[classObj swizzleInstanceMethodsBySelector:withSelector:] to add method to current class first,
///      then call this. It will prevent you modifying the method implementation from its superclass.
///
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
- (void)insertImplementationBlocksIntoInstanceMethodBySelector:(SEL)selector
                                                    identifier:(nullable NSString *)identifier
                                                        before:(nullable void(^)(id receiver))before
                                                         after:(nullable void(^)(id receiver))after;

/// @brief Insert blocks of code which will be executed before or after
///        the default implementation of given selector.
/// @discussion If the class does not own the method by given selector originally, it will go up the
///             chain and check its super's. If this case is not what you expected, you could:
///
///   1. Use +[classObj containsSelector:] to determine if selector is from super before you call this.
///   2. Use +[classObj swizzleClassMethodsBySelector:withSelector:] to add method to current class first,
///      then call this. It will prevent you modifying the method implementation from its superclass.
///
/// @note Specify an identifier will prevent same repeated insertion. Highly recommanded.
+ (void)insertImplementationBlocksIntoClassMethodBySelector:(SEL)selector
                                                identifier:(nullable NSString *)identifier
                                                    before:(nullable void(^)(id receiver))before
                                                     after:(nullable void(^)(id receiver))after;

@end

NS_ASSUME_NONNULL_END