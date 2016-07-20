//
//  _YJKVOPorterManager.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOPorterManager.h"
#import "_YJKVOPorter.h"
#import "_YJKVODefines.h"

@implementation _YJKVOPorterManager {
    NSMutableArray *_porters;
    dispatch_semaphore_t _semaphore;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _porters = [[NSMutableArray alloc] initWithCapacity:50];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addPorter:(_YJKVOPorter *)porter {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_porters addObject:porter];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removePorter:(_YJKVOPorter *)porter {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_porters removeObject:porter];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removePorters:(NSArray <_YJKVOPorter *> *)porters {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_porters removeObjectsInArray:porters];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeAllPorters {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_porters removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}

- (void)enumeratePortersUsingBlock:(void (^)(_YJKVOPorter *porter, BOOL *stop))block {
    id obj = nil; BOOL stop = NO;
    NSEnumerator *enumerator = [_porters objectEnumerator];
    while (obj = [enumerator nextObject]) {
        if (block) block(obj, &stop);
        if (stop) break;
    }
}

- (NSUInteger)numberOfPorters {
    return _porters.count;
}

#if YJ_KVO_DEBUG
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}
#endif

@end
