//
//  _YJKVOBindingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOBindingPorter.h"
#import "NSObject+YJKVOExtension.h"
#import "NSArray+YJSequence.h"
#import "_YJKVOKeyPathManager.h"
#import <objc/message.h>

@implementation _YJKVOBindingPorter {
    YJKVOReturnValueHandler _bindingHandler;
}

- (instancetype)initWithObserver:(__kindof NSObject *)observer
                           queue:(nullable NSOperationQueue *)queue
                     bindingHandler:(YJKVOReturnValueHandler)bindingHandler {
    self = [super initWithObserver:observer queue:queue handler:nil];
    if (self) {
        _bindingHandler = [bindingHandler copy];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    __kindof NSObject *observer = self->_observer;
    YJKVOReturnValueHandler bindingHandler = self->_bindingHandler;

    void(^kvoCallbackBlock)(void) = ^{
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        
        id convertedValue = newValue;
        if (bindingHandler) {
            convertedValue = bindingHandler(observer, object, newValue);
        }
        
        _YJKVOKeyPathManager *keyPathManager = observer.yj_KVOKeyPathManager;
        NSArray <NSString *> *observerKeyPaths = [keyPathManager keyPathsFromObserverForBindingTarget:object withKeyPath:keyPath];
        
        if (observer && observerKeyPaths.count) {
            for (NSString *observerKeyPath in observerKeyPaths) {
                // get observer's setter
                NSArray *components = [observerKeyPath componentsSeparatedByString:@"."];
                NSString *last = components.lastObject;
                NSString *prefixedKeyPath = [[components droppingLast] componentsJoinedByString:@"."];
                id obj = prefixedKeyPath.length ? [observer valueForKeyPath:prefixedKeyPath] : observer;
                
                NSString *setterStr = [NSString stringWithFormat:@"set%@:", last.capitalizedString];
                SEL sel = NSSelectorFromString(setterStr);
                if ([obj respondsToSelector:sel]) {
                    // call setter to trigger the KVO if needed (e.g. observer may be observed by other objects)
                    ((void (*)(id obj, SEL, id value)) objc_msgSend)(obj, sel, convertedValue);
                }
                // set value through keyPath to make result correctly for primitive value (e.g. BOOL, ...)
                [observer setValue:convertedValue forKeyPath:observerKeyPath];
            }
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
