//
//  YJClangMacros.h
//  YJKit
//
//  Created by huang-kun on 16/5/22.
//  Copyright © 2016年 huang-kun. All rights reserved.
//
//  Reference: http://blog.sunnyxx.com/2016/05/14/clang-attributes/


#ifndef YJClangMacros_h
#define YJClangMacros_h

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

// onExit

static inline void YJBlockCleanUp(__strong void(^*block)(void)) { (*block)(); }

#ifndef onExit
#define onExit _yj_keywordify __strong void(^yj_block_)(void) __attribute__((cleanup(YJBlockCleanUp), unused)) = ^
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// constructor & destructor

#ifndef YJ_CONSTRUCTOR
#if __has_attribute(constructor)
#define YJ_CONSTRUCTOR __attribute__((constructor))
#endif
#endif


#ifndef YJ_DESTRUCTOR
#if __has_attribute(destructor)
#define YJ_DESTRUCTOR __attribute__((destructor))
#endif
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// boxable

#ifndef YJ_BOXABLE
#if __has_attribute(objc_boxable)
#define YJ_BOXABLE __attribute__((objc_boxable))
#endif
#endif


#ifndef YJ_BOX_NSVALUE_SUPPORT
#define YJ_BOX_NSVALUE_SUPPORT __has_feature(objc_boxed_expressions) && __has_feature(objc_boxed_nsvalue_expressions)
#endif

#ifndef YJ_BOX_BOOL_SUPPORT
#define YJ_BOX_BOOL_SUPPORT __has_feature(objc_bool)
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// overloadable

#ifndef YJ_OVERLOADABLE
#if __has_attribute(overloadable)
#define YJ_OVERLOADABLE __attribute__((overloadable))
#endif
#endif

/* ------------------------------------------------------------------------------------------------------------ */

// final class

#ifndef YJ_FINAL_CLASS
#if __has_attribute(objc_subclassing_restricted)
#define YJ_FINAL_CLASS __attribute__((objc_subclassing_restricted))
#endif
#endif

/* ------------------------------------------------------------------------------------------------------------ */

#endif /* YJClangMacros_h */
