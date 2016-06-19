//
//  NSObject+YJBlockBasedKVO.m
//  YJKit
//
//  Created by huang-kun on 16/4/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+YJBlockBasedKVO.h"
#import "NSObject+YJRuntimeEncapsulation.h"
#import "YJDebugMacros.h"

static const void *YJKVOAssociatedObserversKey = &YJKVOAssociatedObserversKey;

typedef void(^YJKVOChangeHandler)(id object, id oldValue, id newValue);
typedef void(^YJKVOSetupHandler)(id object, id newValue);

__attribute__((visibility("hidden")))
@interface _YJKeyValueObserver : NSObject
@property (nonatomic, copy) YJKVOChangeHandler changeHandler;
@property (nonatomic, copy) YJKVOSetupHandler setupHandler;
@end

@implementation _YJKeyValueObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (change[NSKeyValueChangeNotificationIsPriorKey]) return;
    
    if (self.setupHandler) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        self.setupHandler(object, newValue);
    } else if (self.changeHandler) {
        id oldValue = change[NSKeyValueChangeOldKey];
        if (oldValue == [NSNull null]) oldValue = nil;
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        self.changeHandler(object, oldValue, newValue);
    }
}

#if YJ_DEBUG
- (void)dealloc {
    NSLog(@"%@ <%p> dealloc", self.class, self);
}
#endif

@end

@interface NSObject ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet <_YJKeyValueObserver *> *> *yj_observers;
@end

@implementation NSObject (YJBlockBasedKVO)

- (void)setYj_observers:(NSMutableDictionary<NSString *,NSMutableSet<_YJKeyValueObserver *> *> *)yj_observers {
    objc_setAssociatedObject(self, YJKVOAssociatedObserversKey, yj_observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Avoid lazy instantiation here
- (NSMutableDictionary<NSString *,NSMutableSet<_YJKeyValueObserver *> *> *)yj_observers {
    return objc_getAssociatedObject(self, YJKVOAssociatedObserversKey);
}

static void _yj_registerKVO(NSObject *self, NSString *keyPath, NSKeyValueObservingOptions options, YJKVOSetupHandler setupHandler, YJKVOChangeHandler changeHandler) {
    
    _YJKeyValueObserver *observer = [[_YJKeyValueObserver alloc] init];
    if (setupHandler) observer.setupHandler = setupHandler;
    if (changeHandler) observer.changeHandler = changeHandler;
    
    NSMutableDictionary *observers = [self yj_observers];
    if (!observers) {
        observers = [NSMutableDictionary new];
        self.yj_observers = observers;
    }
    NSMutableSet *observersForKeyPath = observers[keyPath];
    if (!observersForKeyPath) {
        observersForKeyPath = [NSMutableSet new];
        observers[keyPath] = observersForKeyPath;
    }
    [observersForKeyPath addObject:observer];
    [self addObserver:observer forKeyPath:keyPath options:options context:NULL];
}

// Reference: Modify method IMP from BlocksKit
// https://github.com/zwaldowski/BlocksKit/blob/master/BlocksKit/Core/NSObject%2BBKBlockObservation.m

static void _yj_modifyDealloc(NSObject *self) {
    // Add dealloc method to the current class (subclass of NSObject) if possible.
    SEL deallocSel = sel_registerName("dealloc");
    IMP deallocIMP = imp_implementationWithBlock(^(__unsafe_unretained id obj){
        struct objc_super superInfo = (struct objc_super){ obj, class_getSuperclass([obj class]) };
        ((void (*)(struct objc_super *, SEL)) objc_msgSendSuper)(&superInfo, deallocSel);
    });
    __unused BOOL result = class_addMethod(self.class, deallocSel, deallocIMP, "v@:");
    // Removing observers before executing original dealloc implementation.
    [self insertImplementationBlocksIntoInstanceMethodBySelector:deallocSel
                                                      identifier:@"YJ_REMOVE_KVO"
                                                          before:^(id  _Nonnull receiver) {
                                                              [receiver removeAllObservedKeyPaths];
                                                          } after:nil];
}

- (void)registerObserverForKeyPath:(NSString *)keyPath handleChanges:(void (^)(id, id, id))changeHandler {
    _yj_registerKVO(self, keyPath, (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), nil, changeHandler);
    _yj_modifyDealloc(self);
}

- (void)registerObserverForKeyPath:(NSString *)keyPath handleSetup:(void(^)(id, id))setupHandler {
    _yj_registerKVO(self, keyPath, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew, setupHandler, nil);
    _yj_modifyDealloc(self);
}

- (void)addObservedKeyPath:(NSString *)keyPath handleChanges:(void (^)(id, id, id))changeHandler {
    _yj_registerKVO(self, keyPath, (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), nil, changeHandler);
}

- (void)addObservedKeyPath:(NSString *)keyPath handleSetup:(void(^)(id, id))setupHandler {
    _yj_registerKVO(self, keyPath, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew, setupHandler, nil);
}

- (void)removeObservedKeyPath:(NSString *)keyPath {
    NSMutableSet <_YJKeyValueObserver *> *observersForKeyPath = self.yj_observers[keyPath];
    if (!observersForKeyPath.count) return;
    [observersForKeyPath enumerateObjectsUsingBlock:^(_YJKeyValueObserver * _Nonnull observer, BOOL * _Nonnull stop) {
        [self removeObserver:observer forKeyPath:keyPath];
    }];
    [self.yj_observers removeObjectForKey:keyPath];
}

- (void)removeAllObservedKeyPaths {
    NSMutableDictionary *observers = self.yj_observers;
    if (!observers.count) return;
    [observers enumerateKeysAndObjectsUsingBlock:^(id _Nonnull keyPath, NSMutableSet *  _Nonnull observersForKeyPath, BOOL * _Nonnull stop) {
        [observersForKeyPath enumerateObjectsUsingBlock:^(id  _Nonnull observer, BOOL * _Nonnull stop) {
            [self removeObserver:observer forKeyPath:keyPath];
        }];
    }];
    [observers removeAllObjects];
}

@end
