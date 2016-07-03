//
//  NSObject+YJAssociatedIdentifier.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END