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

static BOOL _yj_insertImpBlocksIntoMethod(id obj, SEL sel, NSString *identifier,
                                          YJMethodImpInsertionBlock before,
                                          YJMethodImpInsertionBlock after) {
    if (!sel || (!before && !after))
        return NO;
    
    // get proper class
    BOOL isClass = yj_object_isClass(obj);
    Class cls = isClass ? obj : [obj class]; // NOT object_getClass(obj)
    
    // get default imp from class
    Method method = isClass ? class_getClassMethod(cls, sel) : class_getInstanceMethod(cls, sel);
    void (*defaultImp)(__unsafe_unretained id, SEL) = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(method);
    if (!defaultImp) return NO;
    
    // keep insertion in records
    NSString *internalID = [NSString stringWithFormat:@"(%@)%@", (isClass ? @"+" : @"-"), identifier];
    if (identifier.length && ![[_YJIMPInsertionKeeper keeper] addIdentifier:internalID forClass:cls]) {
        return NO;
    }
    
    // insert additional blocks of code
    IMP newImp = imp_implementationWithBlock(^(__unsafe_unretained id _obj) {
        if (before) before(_obj);
        defaultImp(_obj, sel);
        if (after) after(_obj);
    });
    method_setImplementation(method, newImp);
    return YES;
}

- (BOOL)insertBlocksIntoMethodBySelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    return _yj_insertImpBlocksIntoMethod(self, selector, identifier, before, after);
}

+ (BOOL)insertBlocksIntoMethodBySelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    return _yj_insertImpBlocksIntoMethod(self, selector, identifier, before, after);
}

- (void)performBlockBeforeDeallocating:(void(^)(id))block {
    // Restriction for modifying -dealloc
    if (![self isKindOfClass:[NSObject class]] || [self isMemberOfClass:[NSObject class]])
        return;
    
    // Add dealloc method to the current class if it doesn't implement one.
    SEL deallocSel = sel_registerName("dealloc");
    IMP deallocIMP = imp_implementationWithBlock(^(__unsafe_unretained id obj){
        struct objc_super superInfo = (struct objc_super){ obj, class_getSuperclass([obj class]) };
        ((void (*)(struct objc_super *, SEL)) objc_msgSendSuper)(&superInfo, deallocSel);
    });
    __unused BOOL result = class_addMethod([self class], deallocSel, deallocIMP, "v@:");
    
    // Insert method implementation before executing original dealloc implementation.
    [self insertBlocksIntoMethodBySelector:deallocSel
                                identifier:NSStringFromClass([self class])
                                    before:^(id  _Nonnull receiver) {
                                        if (block) block(receiver);
                                    } after:nil];
}

@end

// ------------------ Deprecated Implementation ------------------

// In iOS 7, if you want exact IMP for dealloc method from UIResponder class and use runtime API to get the result,
// the system will returns the dealloc IMP from NSObject class, which may not what you expected. So here is a simple
// solution to fix it. Call -swizzleInstanceMethodsBySelector:andSelector: to add the dealloc method for UIResponder
// first, then you can get exact dealloc IMP from UIResponder class.
//
//@implementation UIResponder (YJSwizzleDeallocForUIResponder)
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethodsBySelector:NSSelectorFromString(@"dealloc")
//                                  andSelector:@selector(yj_handleResponderDealloc)];
//    });
//}
//
//- (void)yj_handleResponderDealloc {
//    [self yj_handleResponderDealloc];
//}
//
//@end


