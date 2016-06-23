//
//  YJObjcMacros.h
//  YJKit
//
//  Created by huang-kun on 16/4/16.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#ifndef YJObjcMacros_h
#define YJObjcMacros_h

// Reference: https://github.com/jspahrsummers/libextobjc

/* ------------------------------------------------------------------------------------------------------------ */

// @ keyword

#if __OPTIMIZE__
#ifndef _yj_keywordify
#define _yj_keywordify try {} @finally {}
#endif
#else
#ifndef _yj_keywordify
#define _yj_keywordify autoreleasepool {}
#endif
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// weakify & strongify

/**
 @code
 
 @weakify(self)
 self.completionBlock:^{
     @strongify(self)
     [self updateData];
 };
 
 @endcode
 */

#ifndef _weak_cast
#define _weak_cast(x) x##_weak_
#endif

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(object) _yj_keywordify __weak __typeof__(object) _weak_cast(object) = object;
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify(object) _yj_keywordify __strong __typeof__(_weak_cast(object)) object = _weak_cast(object);
#endif
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// keyPath

/**
 @code
 // It's not safe to use string literal for key path as method parameter. The reasons are:
 // 1. No compiler warning when key path is invalid.
 // 2. No compiler warning when property name get changed in the future.
 
 [foo setValue:@"Jack" forKeyPath:@"friend.name"];
 
 
 // The string literal key path is not recommended by Apple any more in WWDC 2016 
 // because Apple announced swift 3 would support #keyPath feature officially.
 // For objective c code, use @keyPath instead:
 
 [foo setValue:@"Jack" forKeyPath:@keyPath(foo.friend.name)];
 
 
 // Thanks to Justin Spahr-Summers for great extobjc with EXTKeyPathCoding and David Hart for introducing #keyPath in swift 3.
 // https://github.com/jspahrsummers/libextobjc/blob/master/extobjc/EXTKeyPathCoding.h
 // https://github.com/apple/swift-evolution/blob/master/proposals/0062-objc-keypaths.md
 @endcode
 */

#ifndef keyPath

// The @keyPath implementation is taking advantage of the "Comma operator".
// https://en.wikipedia.org/wiki/Comma_operator

#define _comma_operate(A, B) ((void)A, B) /* returns B */
#define _CStringKeyPathByTrimmingFirstPathComponent(Path) strchr(# Path, '.') + 1

#define _compile_check_key_path_validation(Path) _comma_operate(Path, "")
#define _get_valid_key_path_as_c_string(Path) _CStringKeyPathByTrimmingFirstPathComponent(Path)

#define keyPath(Path) (_comma_operate(_compile_check_key_path_validation(Path), _get_valid_key_path_as_c_string(Path)))

#endif

/* ------------------------------------------------------------------------------------------------------------ */

#endif /* YJObjcMacros_h */
