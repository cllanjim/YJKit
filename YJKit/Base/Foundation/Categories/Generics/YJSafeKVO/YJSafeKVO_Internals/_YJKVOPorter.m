//
//  _YJKVOPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOPorter.h"

@implementation _YJKVOPorter

- (instancetype)initWithTarget:(__kindof NSObject *)target subscriber:(__kindof NSObject *)subscriber targetKeyPath:(NSString *)targetKeyPath {
    self = [super init];
    if (self) {
        _target = target;
        _subscriber = subscriber;
        _targetKeyPath = [targetKeyPath copy];
        _observingOptions = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    }
    return self;
}

- (instancetype)init {
    [NSException raise:NSGenericException format:@"Do not call init directly for %@.", self.class];
    return [self initWithTarget:(id)[NSNull null] subscriber:(id)[NSNull null] targetKeyPath:(id)[NSNull null]];
}

- (void)signUp {
    [self.target addObserver:self forKeyPath:self.targetKeyPath options:self.observingOptions context:NULL];
}

- (void)resign {
    [self.target removeObserver:self forKeyPath:self.targetKeyPath context:NULL];
}

- (BOOL)isEqual:(id)object {
    return self == object;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    void(^kvoCallbackBlock)(void) = ^{
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        if (self.changeHandler) {
            self.changeHandler(self.subscriber, object, newValue, change);
        }
    };
    
    if (self.queue) {
        [self.queue addOperationWithBlock:kvoCallbackBlock];
    } else {
        kvoCallbackBlock();
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (target <%@: %p>, subscriber <%@: %p>, targetKeyPath: %@)", self.class, self, self.target.class, self.target, self.subscriber.class, self.subscriber, self.targetKeyPath];
}

#if YJ_KVO_DEBUG
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}
#endif

@end
