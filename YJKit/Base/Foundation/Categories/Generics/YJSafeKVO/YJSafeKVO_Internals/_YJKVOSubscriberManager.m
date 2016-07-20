//
//  _YJKVOSubscriberManager.m
//  YJKit
//
//  Created by huang-kun on 16/7/20.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOSubscriberManager.h"

@implementation _YJKVOSubscriberManager {
    NSHashTable <__kindof NSObject *> *_subscribers;
    dispatch_semaphore_t _semaphore;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _subscribers = [NSHashTable weakObjectsHashTable];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addSubscriber:(__kindof NSObject *)subscriber {    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_subscribers addObject:subscriber];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeSubscriber:(__kindof NSObject *)subscriber {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_subscribers removeObject:subscriber];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeSubscribers:(NSArray <__kindof NSObject *> *)subscribers {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    for (__kindof NSObject *subscriber in subscribers) {
        [_subscribers removeObject:subscriber];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeAllSubscribers {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_subscribers removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}

- (void)enumerateSubscribersUsingBlock:(void (^)(__kindof NSObject *subscriber, BOOL *stop))block {
    id obj = nil; BOOL stop = NO;
    NSEnumerator *enumerator = [_subscribers objectEnumerator];
    while (obj = [enumerator nextObject]) {
        if (block) block(obj, &stop);
        if (stop) break;
    }
}

- (NSUInteger)numberOfSubscribers {
    return _subscribers.count;
}

@end
