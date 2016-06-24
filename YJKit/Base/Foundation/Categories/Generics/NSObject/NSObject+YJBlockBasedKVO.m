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

static const void *YJKVOAssociatedKVOMKey = &YJKVOAssociatedKVOMKey;

typedef void(^YJKVOChangeHandler)(id object, id oldValue, id newValue);
typedef void(^YJKVOSetupHandler)(id object, id newValue);


#pragma mark - internal observer

/* ------------------------- */
//    _YJKeyValueObserver
/* ------------------------- */

__attribute__((visibility("hidden")))
@interface _YJKeyValueObserver : NSObject

// block property for handling value changes with option (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
@property (nonatomic, copy) YJKVOChangeHandler changeHandler;

// block property for handling value setup with option (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
@property (nonatomic, copy) YJKVOSetupHandler updateHandler;

@end


@implementation _YJKeyValueObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (change[NSKeyValueChangeNotificationIsPriorKey]) return;
    
    if (self.updateHandler) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) newValue = nil;
        self.updateHandler(object, newValue);
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


#pragma mark - internal observer manager

/* ------------------------------ */
//   _YJKeyValueObserverManager
/* ------------------------------ */

// Reference: Make thread safe mutable collection
// https://github.com/ibireme/YYKit/blob/master/YYKit/Utility/YYThreadSafeDictionary.m

__attribute__((visibility("hidden")))
@interface _YJKeyValueObserverManager : NSObject

// initialize a manager instance by knowing it's caller.
- (instancetype)initWithOwner:(id)owner;

// add observer to the internal collection.
- (void)registerObserver:(_YJKeyValueObserver *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;

// remove observers from internal collection for specific key path.
- (void)unregisterObserversForKeyPath:(NSString *)keyPath;

// remove observers from internal collection only for both matched key path and identifier.
- (void)unregisterObserversForKeyPath:(NSString *)keyPath withIdentifier:(NSString *)identifier;

// remove all observers from internal collection.
- (void)unregisterAllObservers;

@end


@implementation _YJKeyValueObserverManager {
    __unsafe_unretained id _owner;
    dispatch_semaphore_t _semaphore;
    NSMutableDictionary <NSString *, NSMutableSet <_YJKeyValueObserver *> *> *_observers;
}

- (instancetype)initWithOwner:(id)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        _semaphore = dispatch_semaphore_create(1);
        _observers = [NSMutableDictionary new];
    }
    return self;
}

#if YJ_DEBUG
- (void)dealloc {
    NSLog(@"%@ <%p> dealloc", self.class, self);
}
#endif

- (void)registerObserver:(_YJKeyValueObserver *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

    NSMutableSet *observersForKeyPath = _observers[keyPath];
    if (!observersForKeyPath) {
        observersForKeyPath = [NSMutableSet new];
        _observers[keyPath] = observersForKeyPath;
    }
    [observersForKeyPath addObject:observer];
    [_owner addObserver:observer forKeyPath:keyPath options:options context:NULL];
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)unregisterObserversForKeyPath:(NSString *)keyPath {
    NSMutableSet <_YJKeyValueObserver *> *observersForKeyPath = _observers[keyPath];
    if (!observersForKeyPath.count) return;
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    [observersForKeyPath enumerateObjectsUsingBlock:^(_YJKeyValueObserver * _Nonnull observer, BOOL * _Nonnull stop) {
        [_owner removeObserver:observer forKeyPath:keyPath];
    }];
    [_observers removeObjectForKey:keyPath];
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)unregisterObserversForKeyPath:(NSString *)keyPath withIdentifier:(NSString *)identifier {
    NSMutableSet <_YJKeyValueObserver *> *observersForKeyPath = _observers[keyPath];
    if (!observersForKeyPath.count) return;
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableSet *collector = [[NSMutableSet alloc] initWithCapacity:observersForKeyPath.count];
    [observersForKeyPath enumerateObjectsUsingBlock:^(_YJKeyValueObserver * _Nonnull observer, BOOL * _Nonnull stop) {
        if ([observer.associatedIdentifier isEqualToString:identifier]) {
            [_owner removeObserver:observer forKeyPath:keyPath];
            [collector addObject:observer];
        }
    }];
    
    [observersForKeyPath minusSet:collector];
    if (!observersForKeyPath.count) {
        [_observers removeObjectForKey:keyPath];
    }
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)unregisterAllObservers {
    if (!_observers.count) return;
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    [_observers enumerateKeysAndObjectsUsingBlock:^(id _Nonnull keyPath, NSMutableSet *  _Nonnull observersForKeyPath, BOOL * _Nonnull stop) {
        [observersForKeyPath enumerateObjectsUsingBlock:^(id  _Nonnull observer, BOOL * _Nonnull stop) {
            [_owner removeObserver:observer forKeyPath:keyPath];
        }];
    }];
    [_observers removeAllObjects];
    
    dispatch_semaphore_signal(_semaphore);
}

@end


#pragma mark - block based kvo implementation

/* ------------------------- */
//      YJBlockBasedKVO
/* ------------------------- */

// Reference: Modify method IMP from BlocksKit
// https://github.com/zwaldowski/BlocksKit/blob/master/BlocksKit/Core/NSObject%2BBKBlockObservation.m

@interface NSObject ()

// Associated with a manager for managing observers
@property (nonatomic, strong) _YJKeyValueObserverManager *kvoManager;

@end

@implementation NSObject (YJBlockBasedKVO)

- (void)setKvoManager:(_YJKeyValueObserverManager *)kvoManager {
    objc_setAssociatedObject(self, YJKVOAssociatedKVOMKey, kvoManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Avoid lazy instantiation here for unnecessary instantiation when removing observers before -[self dealloc]
- (_YJKeyValueObserverManager *)kvoManager {
    return objc_getAssociatedObject(self, YJKVOAssociatedKVOMKey);
}

static void _yj_registerKVO(NSObject *self, NSString *keyPath, NSString *identifier,
                            NSKeyValueObservingOptions options, YJKVOSetupHandler updateHandler, YJKVOChangeHandler changeHandler) {
    
    _YJKeyValueObserver *observer = [_YJKeyValueObserver new];
    if (updateHandler) observer.updateHandler = updateHandler;
    if (changeHandler) observer.changeHandler = changeHandler;
    if (identifier.length) observer.associatedIdentifier = identifier;
    
    _YJKeyValueObserverManager *kvoManager = self.kvoManager;
    if (!kvoManager) {
        kvoManager = [[_YJKeyValueObserverManager alloc] initWithOwner:self];
        self.kvoManager = kvoManager;
    }
    [kvoManager registerObserver:observer forKeyPath:keyPath options:options];
}

static void _yj_modifyDealloc(NSObject *self) {
    // Add dealloc method to the current class if it doesn't implement one.
    // (The current class must be any class as subclass of NSObject)
    SEL deallocSel = sel_registerName("dealloc");
    IMP deallocIMP = imp_implementationWithBlock(^(__unsafe_unretained id obj){
        struct objc_super superInfo = (struct objc_super){ obj, class_getSuperclass([obj class]) };
        ((void (*)(struct objc_super *, SEL)) objc_msgSendSuper)(&superInfo, deallocSel);
    });
    __unused BOOL result = class_addMethod(self.class, deallocSel, deallocIMP, "v@:");
    
    // Removing all observers before executing original dealloc implementation.
    [self insertBlocksIntoMethodBySelector:deallocSel
                                identifier:@"YJ_REMOVE_KVO"
                                    before:^(id  _Nonnull receiver) {
                                        [receiver stopObservingAllKeyPaths];
                                    } after:nil];
}

/* -------------------- Basic APIs ------------------- */

- (void)observeKeyPath:(NSString *)keyPath forChanges:(void(^)(id object, id _Nullable oldValue, id _Nullable newValue))changeHandler {
    _yj_registerKVO(self, keyPath, nil, (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), nil, changeHandler);
    _yj_modifyDealloc(self);
}

- (void)observeKeyPath:(NSString *)keyPath forUpdates:(void(^)(id object, id _Nullable newValue))updateHandler {
    _yj_registerKVO(self, keyPath, nil, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew, updateHandler, nil);
    _yj_modifyDealloc(self);
}

- (void)stopObservingKeyPath:(NSString *)keyPath {
    [self.kvoManager unregisterObserversForKeyPath:keyPath];
}

- (void)stopObservingAllKeyPaths {
    [self.kvoManager unregisterAllObservers];
}

/* -------------------- Extended APIs ------------------- */

- (void)observeKeyPath:(NSString *)keyPath identifier:(NSString *)identifier forChanges:(void(^)(id receiver, id _Nullable oldValue, id _Nullable newValue))changeHandler {
    _yj_registerKVO(self, keyPath, identifier, (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), nil, changeHandler);
    _yj_modifyDealloc(self);
}

- (void)observeKeyPath:(NSString *)keyPath identifier:(NSString *)identifier forUpdates:(void(^)(id receiver, id _Nullable newValue))updateHandler {
    _yj_registerKVO(self, keyPath, identifier, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew, updateHandler, nil);
    _yj_modifyDealloc(self);
}

- (void)stopObservingKeyPath:(NSString *)keyPath forIdentifier:(NSString *)identifier {
    [self.kvoManager unregisterObserversForKeyPath:keyPath withIdentifier:identifier];
}

/* -------------------- Deprecated APIs ------------------- */

- (void)registerObserverForKeyPath:(NSString *)keyPath handleChanges:(void (^)(id, id, id))changeHandler {
    [self observeKeyPath:keyPath forChanges:changeHandler];
}

- (void)registerObserverForKeyPath:(NSString *)keyPath handleSetup:(void(^)(id, id))updateHandler {
    [self observeKeyPath:keyPath forUpdates:updateHandler];
}

- (void)removeObservedKeyPath:(NSString *)keyPath {
    [self stopObservingKeyPath:keyPath];
}

- (void)removeAllObservedKeyPaths {
    [self stopObservingAllKeyPaths];
}

@end
