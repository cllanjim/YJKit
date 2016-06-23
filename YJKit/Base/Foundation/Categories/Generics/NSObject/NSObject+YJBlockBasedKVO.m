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


#pragma mark - internal observer manager

/* ------------------------------ */
//   _YJKeyValueObserverManager
/* ------------------------------ */

__attribute__((visibility("hidden")))
@interface _YJKeyValueObserverManager : NSObject
- (instancetype)initWithOwner:(id)owner;
- (void)registerObserver:(_YJKeyValueObserver *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
- (void)unregisterObserversForKeyPath:(NSString *)keyPath;
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

@interface NSObject ()
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

static void _yj_registerKVO(NSObject *self, NSString *keyPath, NSKeyValueObservingOptions options, YJKVOSetupHandler setupHandler, YJKVOChangeHandler changeHandler) {
    
    _YJKeyValueObserver *observer = [_YJKeyValueObserver new];
    if (setupHandler) observer.setupHandler = setupHandler;
    if (changeHandler) observer.changeHandler = changeHandler;
    
    _YJKeyValueObserverManager *kvoManager = self.kvoManager;
    if (!kvoManager) {
        kvoManager = [[_YJKeyValueObserverManager alloc] initWithOwner:self];
        self.kvoManager = kvoManager;
    }
    [kvoManager registerObserver:observer forKeyPath:keyPath options:options];
}

// Reference: Modify method IMP from BlocksKit
// https://github.com/zwaldowski/BlocksKit/blob/master/BlocksKit/Core/NSObject%2BBKBlockObservation.m

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
    [self insertImplementationBlocksIntoInstanceMethodBySelector:deallocSel
                                                      identifier:@"YJ_REMOVE_KVO"
                                                          before:^(id  _Nonnull receiver) {
                                                              [receiver stopObservingAllKeyPaths];
                                                          } after:nil];
}

- (void)observeKeyPath:(NSString *)keyPath forChanges:(void(^)(id object, id _Nullable oldValue, id _Nullable newValue))changeHandler {
    _yj_registerKVO(self, keyPath, (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew), nil, changeHandler);
    _yj_modifyDealloc(self);
}

- (void)observeKeyPath:(NSString *)keyPath forInitialSetup:(void(^)(id object, id _Nullable newValue))setupHandler {
    _yj_registerKVO(self, keyPath, NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew, setupHandler, nil);
    _yj_modifyDealloc(self);
}

- (void)stopObservingKeyPath:(NSString *)keyPath {
    [self.kvoManager unregisterObserversForKeyPath:keyPath];
}

- (void)stopObservingAllKeyPaths {
    [self.kvoManager unregisterAllObservers];
}

/* -------------------- Deprecated ------------------- */

- (void)registerObserverForKeyPath:(NSString *)keyPath handleChanges:(void (^)(id, id, id))changeHandler {
    [self observeKeyPath:keyPath forChanges:changeHandler];
}

- (void)registerObserverForKeyPath:(NSString *)keyPath handleSetup:(void(^)(id, id))setupHandler {
    [self observeKeyPath:keyPath forInitialSetup:setupHandler];
}

- (void)removeObservedKeyPath:(NSString *)keyPath {
    [self stopObservingKeyPath:keyPath];
}

- (void)removeAllObservedKeyPaths {
    [self stopObservingAllKeyPaths];
}

@end
