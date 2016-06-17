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

@implementation NSObject (YJMethodImpModifying)

- (void)insertImplementationBlocksIntoSelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(void))before after:(nullable void(^)(void))after {
    
    if (!before && !after)
        return;
    
    Class class = object_getClass(self); // not self.class
    const char *clsName = class_getName(class);
    NSString *className = [NSString stringWithUTF8String:clsName];
    
    _YJIMPModificationKeeper *keeper = [_YJIMPModificationKeeper sharedKeeper];
    if (identifier.length) {
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
    
    Method method = class_getInstanceMethod(class, selector);
    void (*defaultImp)(__unsafe_unretained id, SEL) = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(method);
    IMP newImp = imp_implementationWithBlock(^(__unsafe_unretained NSObject *_self) {
        if (before) before();
        defaultImp(_self, selector);
        if (after) after();
    });
    method_setImplementation(method, newImp);
}

@end
