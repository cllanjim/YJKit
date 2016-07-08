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

@implementation _YJKVOBindingPorter

- (instancetype)initWithObserver:(__kindof NSObject *)observer
                           queue:(nullable NSOperationQueue *)queue {
    return [super initWithObserver:observer queue:queue handler:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    __block id initialCall = objc_getAssociatedObject(self, _cmd);
    if (!initialCall) initialCall = @YES;
    
    __kindof NSObject *observer = self->_observer;
    YJKVOReturnValueHandler convertHandler = self.convertHandler;
    YJKVOObjectsHandler afterHandler = self.afterHandler;
    
    void(^kvoCallbackBlock)(void) = ^{
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        
        id convertedValue = newValue;
        if (convertHandler) {
            convertedValue = convertHandler(observer, object, newValue);
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
                // here using a lousy protection to avoid setNilValueForKey: crash from NSKeyValueObservingOptionInitial callback.
                if (!([initialCall isEqualToNumber:@YES] && !convertedValue)) {
                    [observer setValue:convertedValue forKeyPath:observerKeyPath];
                }
                
                if (afterHandler) afterHandler(observer, object);
            }
        }
        
        if ([initialCall isEqualToNumber:@YES]) {
            initialCall = @NO;
            // no retain cycle for capturing self after block is released.
            objc_setAssociatedObject(self, _cmd, initialCall, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
