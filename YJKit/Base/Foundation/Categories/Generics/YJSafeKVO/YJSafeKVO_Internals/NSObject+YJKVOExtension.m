//
//  NSObject+YJKVOExtension.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOPorterManager.h"
#import "_YJKVOPorterTracker.h"
#import "_YJKVOKeyPathManager.h"

/* ------------------------- */
//         YJKVOTarget
/* ------------------------- */

@implementation NSObject (YJKVOTarget)

- (void)setYj_KVOPorterManager:(_YJKVOPorterManager *)yj_KVOPorterManager {
    objc_setAssociatedObject(self, @selector(yj_KVOPorterManager), yj_KVOPorterManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOPorterManager *)yj_KVOPorterManager {
    return objc_getAssociatedObject(self, _cmd);
}

@end


/* ------------------------- */
//       YJKVOObserver
/* ------------------------- */

@implementation NSObject (YJKVOObserver)

- (void)setYj_KVOTracker:(_YJKVOPorterTracker *)yj_KVOTracker {
    objc_setAssociatedObject(self, @selector(yj_KVOTracker), yj_KVOTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOPorterTracker *)yj_KVOTracker {
    return objc_getAssociatedObject(self, _cmd);
}

@end


/* ------------------------- */
//        YJKVOBinding
/* ------------------------- */

@implementation NSObject (YJKVOBinding)

- (void)setYj_KVOKeyPathManager:(_YJKVOKeyPathManager *)yj_KVOKeyPathManager {
    objc_setAssociatedObject(self, @selector(yj_KVOKeyPathManager), yj_KVOKeyPathManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOKeyPathManager *)yj_KVOKeyPathManager {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYj_KVOTemporaryKeyPath:(NSString *)yj_KVOTemporaryKeyPath {
    objc_setAssociatedObject(self, @selector(yj_KVOTemporaryKeyPath), yj_KVOTemporaryKeyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)yj_KVOTemporaryKeyPath {
    return objc_getAssociatedObject(self, _cmd);
}

@end
