//
//  NSObject+YJIMPInsertion.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+YJClassObjectChecking.h"

/* ----------------------------------- */
//        _YJIMPInsertionKeeper
/* ----------------------------------- */

typedef void(^YJMethodImpInsertionBlock)(id);

__attribute__((visibility("hidden")))
@interface _YJIMPInsertionKeeper : NSObject

+ (instancetype)keeper;

// Returns YES that means adding identifier successfully, NO means identifier has been added already.
// Must passing a valid non-null string as identifier.
- (BOOL)addIdentifier:(NSString *)identifier forClass:(Class)class;

@end

@implementation _YJIMPInsertionKeeper {
    NSMapTable <Class, NSMutableArray *> *_records;
    dispatch_semaphore_t _semaphore;
}

+ (instancetype)keeper {
    static _YJIMPInsertionKeeper *keeper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keeper = [_YJIMPInsertionKeeper new];
        keeper->_records = [NSMapTable strongToStrongObjectsMapTable];
        keeper->_semaphore = dispatch_semaphore_create(1);
    });
    return keeper;
}

- (BOOL)addIdentifier:(NSString *)identifier forClass:(Class)class {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableArray *identifiers = [_records objectForKey:class];
    if (!identifiers) {
        identifiers = [NSMutableArray new];
        [_records setObject:identifiers forKey:class];
    }
    if ([identifiers containsObject:identifier]) {
        dispatch_semaphore_signal(_semaphore);
        return NO;
    }
    [identifiers addObject:identifier];
    dispatch_semaphore_signal(_semaphore);
    return YES;
}

@end


@implementation NSObject (YJIMPInsertion)

static BOOL _yj_insertImpBlocksIntoMethod(id obj, SEL sel,
                                          YJMethodImpInsertionBlock before,
                                          YJMethodImpInsertionBlock after) {
    if (!sel || (!before && !after))
        return NO;
    
    // get proper class
    BOOL isClass = yj_object_isClass(obj);
    Class cls = isClass ? obj : [obj class]; // NOT object_getClass(obj)
    
    // keep insertion in records
    NSString *identifier = [NSString stringWithFormat:@"%@,Before<%p>After<%p>", NSStringFromSelector(sel), before, after];
    if (![[_YJIMPInsertionKeeper keeper] addIdentifier:identifier forClass:cls]) {
        return NO;
    }
    
    // get default imp from class
    Method method = isClass ? class_getClassMethod(cls, sel) : class_getInstanceMethod(cls, sel);
    void (*defaultImp)(__unsafe_unretained id, SEL) = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(method);
    if (!defaultImp) return NO;
    
    // insert additional blocks of code
    IMP newImp = imp_implementationWithBlock(^(__unsafe_unretained id _obj) {
        if (before) before(_obj);
        defaultImp(_obj, sel);
        if (after) after(_obj);
    });
    method_setImplementation(method, newImp);
    return YES;
}

- (void)performBlocksByInvokingSelector:(SEL)selector before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethod(self, selector, before, after);
}

+ (void)performBlocksByInvokingSelector:(SEL)selector before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethod(self, selector, before, after);
}

- (void)performBlockBeforeDeallocating:(void(^)(id))block {
    
    NSString *identifier = [NSString stringWithFormat:@"dealloc,<%p>", block];
    if (![[_YJIMPInsertionKeeper keeper] addIdentifier:identifier forClass:[self class]]) {
        return;
    }
    
    // Restriction for modifying -dealloc
    if (!block || ![self isKindOfClass:[NSObject class]] || [self isMemberOfClass:[NSObject class]])
        return;
    
    Class currCls = [self class];
    
    // Add dealloc method to the current class if it doesn't implement one.
    SEL deallocSEL = sel_registerName("dealloc");
    Method deallocMtd = class_getInstanceMethod([self class], deallocSEL);
    const char *deallocType = method_getTypeEncoding(deallocMtd);
    
    IMP deallocIMP = imp_implementationWithBlock(^(__unsafe_unretained id obj){
        struct objc_super superInfo = (struct objc_super){ obj, class_getSuperclass(currCls) };
        ((void (*)(struct objc_super *, SEL)) objc_msgSendSuper)(&superInfo, deallocSEL);
    });
    
    __unused BOOL result = class_addMethod([self class], deallocSEL, deallocIMP, deallocType);
    
    // Insert method implementation before executing original dealloc implementation.
    [self performBlocksByInvokingSelector:deallocSEL before:block after:nil];
}

- (void)performSafeEqualityComparison {
    
    NSString *identifier = [NSString stringWithFormat:@"isEqual:"];
    if (![[_YJIMPInsertionKeeper keeper] addIdentifier:identifier forClass:[self class]]) {
        return;
    }
    
    SEL equalitySEL = @selector(isEqual:);
    Method equalityMtd = class_getInstanceMethod([self class], equalitySEL);
    const char *equalityType = method_getTypeEncoding(equalityMtd);
    
    BOOL (*defaultImp)(__unsafe_unretained id, SEL, __unsafe_unretained id) =
    (BOOL(*)(__unsafe_unretained id, SEL, __unsafe_unretained id))method_getImplementation(equalityMtd);
    
    IMP identityCheckingIMP = imp_implementationWithBlock(^BOOL(__unsafe_unretained id obj1, __unsafe_unretained id obj2){
        return obj1 == obj2;
    });
    
    // Add pointer comparison version of -isEqual: if you have not implemented yet.
    BOOL added = class_addMethod([self class], equalitySEL, identityCheckingIMP, equalityType);
    if (added) return;
    
    // Add class type checking version of -isEqual: if you have implemented in your code.
    IMP modifiedIMP = imp_implementationWithBlock(^BOOL(__unsafe_unretained id obj1, __unsafe_unretained id obj2){
        if ([obj1 class] != [obj2 class]) {
            return NO;
        } else {
            return defaultImp(obj1, equalitySEL, obj2);
        }
    });
    method_setImplementation(equalityMtd, modifiedIMP);
}

@end
