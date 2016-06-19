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
 @keyPath(foo.name) // @"name"
 @endcode
 */

#ifndef keyPath

#define _UTF8StringByTrimmingFirstPathComponent(Path) strchr(# Path, '.') + 1
#define _return_last(A, B) ((void)A, B)

#define _compile_check_key_path_validation(Path) _return_last(Path, "")
#define _return_key_path_c_string(Path) _UTF8StringByTrimmingFirstPathComponent(Path)

#define keyPath(Path) (_return_last(_compile_check_key_path_validation(Path), _return_key_path_c_string(Path)))

#endif

/* ------------------------------------------------------------------------------------------------------------ */

#endif /* YJObjcMacros_h */
