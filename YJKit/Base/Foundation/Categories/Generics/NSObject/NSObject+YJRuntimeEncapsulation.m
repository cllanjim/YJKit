//
//  NSObject+YJSwizzling.m
//  YJKit
//
//  Created by huang-kun on 16/5/13.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJRuntimeEncapsulation.h"
#import "NSObject+YJExtension.h"
#import "YJUIMacros.h"

/* ----------------------------------- */
//         Class type checking
/* ----------------------------------- */

bool yj_objc_isClass(id obj) {
    return obj == [obj class];
}


/* ----------------------------------- */
//  NSObject (YJAssociatedIdentifier)
/* ----------------------------------- */

// Reference: Tagged pointer crash
// http://stackoverflow.com/questions/21561211/objc-setassociatedobject-function-error-in-64bit-mode-not-in-32bit

const NSInteger YJAssociatedTagInvalid = NSIntegerMax;
const NSInteger YJAssociatedTagNone = 0;

static const void * YJObjectAssociatedIdentifierKey = &YJObjectAssociatedIdentifierKey;
static const void * YJObjectAssociatedTagKey = &YJObjectAssociatedTagKey;

@implementation NSObject (YJAssociatedIdentifier)

- (void)setAssociatedIdentifier:(NSString *)associatedIdentifier {
    if (self.isTaggedPointer) return;
    objc_setAssociatedObject(self, YJObjectAssociatedIdentifierKey, associatedIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)associatedIdentifier {
    return objc_getAssociatedObject(self, YJObjectAssociatedIdentifierKey);
}

- (void)setAssociatedTag:(NSInteger)associatedTag {
    if (self.isTaggedPointer) associatedTag = YJAssociatedTagInvalid;
    objc_setAssociatedObject(self, YJObjectAssociatedTagKey, @(associatedTag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)associatedTag {
    return [objc_getAssociatedObject(self, YJObjectAssociatedTagKey) integerValue];
}

@end


@implementation NSArray (YJAssociatedIdentifier)

- (BOOL)containsObjectWithAssociatedIdentifier:(NSString *)associatedIdentifier {
    BOOL contains = NO;
    for (NSObject *obj in self) {
        if ([obj.associatedIdentifier isEqualToString:associatedIdentifier]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

- (BOOL)containsObjectWithAssociatedTag:(NSInteger)associatedTag {
    BOOL contains = NO;
    for (NSObject *obj in self) {
        if (obj.associatedTag == associatedTag) {
            contains = YES;
            break;
        }
    }
    return contains;
}

- (void)enumerateAssociatedObjectsUsingBlock:(void (^)(id, NSUInteger, BOOL *))block {
    id obj = nil; NSUInteger idx = 0; BOOL stop = NO;
    NSEnumerator *enumerator = [self objectEnumerator];
    while (obj = [enumerator nextObject]) {
        NSString *identifier = [obj associatedIdentifier];
        NSInteger tag = [obj associatedTag];
        if (identifier.length || (tag != YJAssociatedTagInvalid && tag != YJAssociatedTagNone)) {
            block(obj, idx++, &stop);
            if (stop) break;
        } else {
            idx++;
        }
    }
}

@end


/* ----------------------------------- */
//     NSObject (YJSwizzling)
/* ----------------------------------- */

@implementation NSObject (YJSwizzling)

static void _yj_swizzleMethodForClass(id class, SEL selector, SEL toSelector) {
    Method method = class_getInstanceMethod(class, selector);
    Method toMethod = class_getInstanceMethod(class, toSelector);
    BOOL added = class_addMethod(class, selector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod));
    if (added) class_replaceMethod(class, toSelector, method_getImplementation(method), method_getTypeEncoding(method));
    else method_exchangeImplementations(method, toMethod);
}

+ (void)swizzleInstanceMethodForSelector:(SEL)selector toSelector:(SEL)toSelector {
    _yj_swizzleMethodForClass(self, selector, toSelector);
}

+ (void)swizzleClassMethodForSelector:(SEL)selector toSelector:(SEL)toSelector {
    Class class = object_getClass((id)self);
    _yj_swizzleMethodForClass(class, selector, toSelector);
}

@end


/* ----------------------------------- */
//   NSObject (YJMethodImpModifying)
/* ----------------------------------- */

// Reference: modify method imp from BlocksKit
// https://github.com/zwaldowski/BlocksKit/blob/master/BlocksKit/Core/NSObject%2BBKBlockObservation.m

__attribute__((visibility("hidden")))
@interface _YJIMPModificationKeeper : NSObject
+ (instancetype)sharedKeeper;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet *> *records;
@end

@implementation _YJIMPModificationKeeper
+ (instancetype)sharedKeeper {
    static _YJIMPModificationKeeper *keeper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keeper = [_YJIMPModificationKeeper new];
        keeper.records = [NSMutableDictionary new];
    });
    return keeper;
}
@end

typedef void(^YJMethodImpInsertionBlock)(id);

@implementation NSObject (YJMethodImpModifying)

+ (void)insertImplementationBlocksIntoClassMethodForSelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethodForObject(self, selector, identifier, before, after);
}

- (void)insertImplementationBlocksIntoInstanceMethodForSelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethodForObject(self, selector, identifier, before, after);
}

void _yj_insertImpBlocksIntoMethodForObject(id obj, SEL sel, NSString *identifier, YJMethodImpInsertionBlock before, YJMethodImpInsertionBlock after) {
    
    if (!sel || (!before && !after))
        return;
    
    // get proper class
    BOOL objIsClass = yj_objc_isClass(obj);
    
    Class realCls = objIsClass ? obj : object_getClass(obj);
    Class officialCls = objIsClass ? obj : [obj class];
    
    // get default imp from official class
    Method method = objIsClass ? class_getClassMethod(officialCls, sel) : class_getInstanceMethod(officialCls, sel);
    void (*defaultImp)(__unsafe_unretained id, SEL) = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(method);
    if (!defaultImp) return;
    
    // get class name from real class
    const char *clsName = class_getName(realCls);
    NSString *className = [NSString stringWithUTF8String:clsName];
    
    // keep insertion in records if possible
    if (identifier.length) {
        _YJIMPModificationKeeper *keeper = [_YJIMPModificationKeeper sharedKeeper];
        NSMutableSet *identifiers = keeper.records[className];
        if (!identifiers) {
            identifiers = [NSMutableSet new];
            keeper.records[className] = identifiers;
        }
        if ([identifiers containsObject:identifier]) {
            return;
        } else {
            [identifiers addObject:[identifier copy]];
        }
    }
    
    // insert additional blocks of code
    IMP newImp = imp_implementationWithBlock(^(__unsafe_unretained id _obj) {
        if (before) before(_obj);
        defaultImp(_obj, sel);
        if (after) after(_obj);
    });
    method_setImplementation(method, newImp);
}

@end

// In iOS 7, if you want imp for dealloc method for UIResponder class,
// the system returns the dealloc imp for NSObject class, which is not
// what I expected. So here is a simple solution to fix it.
@implementation UIResponder (YJSwizzleDeallocForUIResponder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodForSelector:NSSelectorFromString(@"dealloc") toSelector:@selector(yj_handleResponderDealloc)];
    });
}

- (void)yj_handleResponderDealloc {
    [self yj_handleResponderDealloc];
}

@end
