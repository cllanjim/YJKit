//
//  NSObject+YJKVOExtension.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+YJKVOExtension.h"
#import "NSArray+YJSequence.h"
#import "_YJKVOPorterManager.h"
#import "_YJKVOPorterTracker.h"
#import "_YJKVOPipeIDKeeper.h"

@implementation NSObject (YJKVOExtension)

- (void)setYj_KVOPorterManager:(_YJKVOPorterManager *)yj_KVOPorterManager {
    objc_setAssociatedObject(self, @selector(yj_KVOPorterManager), yj_KVOPorterManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOPorterManager *)yj_KVOPorterManager {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYj_KVOPorterTracker:(_YJKVOPorterTracker *)yj_KVOPorterTracker {
    objc_setAssociatedObject(self, @selector(yj_KVOPorterTracker), yj_KVOPorterTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOPorterTracker *)yj_KVOPorterTracker {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYj_KVOPipeIDKeeper:(_YJKVOPipeIDKeeper *)yj_KVOPipeIDKeeper {
    objc_setAssociatedObject(self, @selector(yj_KVOPipeIDKeeper), yj_KVOPipeIDKeeper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_YJKVOPipeIDKeeper *)yj_KVOPipeIDKeeper {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setYj_KVOPackerString:(NSString *)yj_KVOPackerString {
    objc_setAssociatedObject(self, @selector(yj_KVOPackerString), yj_KVOPackerString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)yj_KVOPackerString {
    return objc_getAssociatedObject(self, _cmd);
}

@end
