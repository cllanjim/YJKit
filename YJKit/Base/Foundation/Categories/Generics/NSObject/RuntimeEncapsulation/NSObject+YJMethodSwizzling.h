//
//  NSObject+YJMethodSwizzling.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (YJMethodSwizzling)

/// Exchange the implementations between two given selectors.
/// @note If the class does not originally implements the method by given selector,
///       it will add the method to the class first, then switch the implementations.
+ (void)swizzleInstanceMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector;

/// Exchange the implementations between two given selectors.
/// @note If the class does not originally implements the method by given selector,
///       it will add the method to the class first, then switch the implementations.
+ (void)swizzleClassMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector;

@end
