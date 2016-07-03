//
//  NSObject+YJSelectorChecking.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (YJSelectorChecking)

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
