//
//  YJDelegateAndDataSourceCrashPrecaution.h
//  YJKit
//
//  Created by huang-kun on 16/7/26.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#ifndef YJDelegateAndDataSourceCrashPrecaution_h
#define YJDelegateAndDataSourceCrashPrecaution_h

#import "NSObject+YJDelegateWeakChecking.h"
#import "NSObject+YJMethodSwizzling.h"
#import "NSObject+YJIMPInsertion.h"
#import <objc/runtime.h>

static const void *YJDelegateAssociationKey = &YJDelegateAssociationKey;
static const void *YJDataSourceAssociationKey = &YJDataSourceAssociationKey;


/* Swizzling setDelegate: and setDataSource: */
#define YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS \
    \
    if ([self instancesRespondToSelector:@selector(delegate)] && ![self isWeakDelegateByDefault]) { \
        [self swizzleInstanceMethodsBySelector:@selector(setDelegate:) andSelector:@selector(yj_setSafeDelegate:)]; \
    } \
    if ([self instancesRespondToSelector:@selector(dataSource)] && ![self isWeakDataSourceByDefault]) { \
        [self swizzleInstanceMethodsBySelector:@selector(setDataSource:) andSelector:@selector(yj_setSafeDataSource:)]; \
    } \


/* Implementing yj_setSafeDelegate: and yj_setSafeDataSource: */
#define YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS \
\
- (void)yj_setSafeDelegate:(__kindof NSObject *)delegate {  \
    /* forward */  \
    [self yj_setSafeDelegate:delegate];  \
    /* validation */  \
    if (!delegate) return;  \
    /* association */  \
    objc_setAssociatedObject(delegate, YJDelegateAssociationKey, self, OBJC_ASSOCIATION_ASSIGN);  \
    /* protection */  \
    [delegate performBlockBeforeDeallocating:^(id  _Nonnull delegate) {  \
        id source = objc_getAssociatedObject(delegate, YJDelegateAssociationKey);  \
        objc_setAssociatedObject(delegate, YJDelegateAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);  \
        [source yj_setSafeDelegate:nil]; \
    }];  \
}  \
\
- (void)yj_setSafeDataSource:(__kindof NSObject *)dataSource {  \
    /* forward */  \
    [self yj_setSafeDataSource:dataSource];  \
    /* validation */  \
    if (!dataSource) return;  \
    /* association */  \
    objc_setAssociatedObject(dataSource, YJDataSourceAssociationKey, self, OBJC_ASSOCIATION_ASSIGN);  \
    /* protection */  \
    [dataSource performBlockBeforeDeallocating:^(id  _Nonnull dataSource) {  \
        id source = objc_getAssociatedObject(dataSource, YJDataSourceAssociationKey);  \
        objc_setAssociatedObject(dataSource, YJDataSourceAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);  \
        [source yj_setSafeDataSource:nil]; \
    }];  \
}  \


/* Making safe delegate and dataSource for class */
#define YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_FOR_CLASS(CLASS) \
@implementation CLASS (YJDelegateAndDataSourceCrashPrecaution) \
\
+ (void)load { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS \
    }); \
} \
\
YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS \
\
@end

#endif /* YJDelegateAndDataSourceCrashPrecaution_h */
