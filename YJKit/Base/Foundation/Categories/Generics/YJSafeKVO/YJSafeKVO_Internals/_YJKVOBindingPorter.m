//
//  _YJKVOBindingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOBindingPorter.h"
#import "NSObject+YJKVOExtension.h"

@implementation _YJKVOBindingPorter {
    YJKVOBindHandler _bindHandler;
}

- (instancetype)initWithObserver:(__kindof NSObject *)observer
                           queue:(nullable NSOperationQueue *)queue
                     bindHandler:(YJKVOBindHandler)bindHandler {
    self = [super initWithObserver:observer queue:queue handler:nil];
    if (self) {
        _bindHandler = [bindHandler copy];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    id observer = self->_observer;
    YJKVOBindHandler bindHandler = self->_bindHandler;

    void(^kvoCallbackBlock)(void) = ^{
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        
        NSString *keyPath = [observer yj_KVOBindingKeyPath];
        id convertedValue = newValue;
        
        if (bindHandler) {
            convertedValue = bindHandler(observer, object, newValue);
        }
        
        if (observer && keyPath) {
            [observer setValue:convertedValue forKeyPath:keyPath];
        }
    };
    
    if (self->_queue) {
        [self->_queue addOperationWithBlock:kvoCallbackBlock];
    } else {
        kvoCallbackBlock();
    }
}

#if DEBUG_YJ_SAFE_KVO
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}
#endif


@end
