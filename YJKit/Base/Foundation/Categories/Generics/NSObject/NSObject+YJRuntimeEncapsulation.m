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
//     NSObject (YJRuntimeExtension)
/* ----------------------------------- */

@implementation NSObject (YJRuntimeExtension)

static BOOL _yj_containsSelectorForObject(id obj, SEL sel, bool shouldAssumeObjectIsClass) {
    BOOL result = NO;
    unsigned int count = 0;
    Class cls;
    
    if (shouldAssumeObjectIsClass) {
        cls = [obj class];
    } else {
        bool isClass = object_isClass(obj);
        cls = isClass ? object_getClass(obj) : [obj class];
    }
    
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (selector == sel) {
            result = YES;
            break;
        }
    }
    free(methods);
    return result;
}

- (BOOL)containsSelector:(SEL)selector {
    return _yj_containsSelectorForObject(self, selector, false);
}

+ (BOOL)containsSelector:(SEL)selector {
    return _yj_containsSelectorForObject(self, selector, false);
}

+ (BOOL)containsInstanceMethodBySelector:(SEL)selector {
    return _yj_containsSelectorForObject(self, selector, true);
}

@end


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
//        NSObject (YJSwizzling)
/* ----------------------------------- */

@implementation NSObject (YJSwizzling)

static void _yj_swizzleMethodForClass(id class, SEL selector, SEL providedSelector) {
    Method method = class_getInstanceMethod(class, selector);
    Method toMethod = class_getInstanceMethod(class, providedSelector);
    BOOL added = class_addMethod(class, selector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod));
    if (added) class_replaceMethod(class, providedSelector, method_getImplementation(method), method_getTypeEncoding(method));
    else method_exchangeImplementations(method, toMethod);
}

+ (void)swizzleInstanceMethodsBySelector:(SEL)selector withSelector:(SEL)providedSelector {
    _yj_swizzleMethodForClass(self, selector, providedSelector);
}

+ (void)swizzleClassMethodsBySelector:(SEL)selector withSelector:(SEL)providedSelector {
    Class class = object_getClass((id)self);
    _yj_swizzleMethodForClass(class, selector, providedSelector);
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
@property (nonatomic, strong) NSMutableDictionary <NSString */*className*/, NSMutableSet */*identifiers*/> *records;
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

static void _yj_insertImpBlocksIntoMethodForObject(id obj, SEL sel, NSString *identifier, YJMethodImpInsertionBlock before, YJMethodImpInsertionBlock after) {
    
    if (!sel || (!before && !after))
        return;
    
    // get proper class
    BOOL isClass = object_isClass(obj);
    
    Class realCls = isClass ? obj : object_getClass(obj);
    Class officialCls = isClass ? obj : [obj class];
    
    // get default imp from official class
    Method method = isClass ? class_getClassMethod(officialCls, sel) : class_getInstanceMethod(officialCls, sel);
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

+ (void)insertImplementationBlocksIntoClassMethodBySelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethodForObject(self, selector, identifier, before, after);
}

- (void)insertImplementationBlocksIntoInstanceMethodBySelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethodForObject(self, selector, identifier, before, after);
}

@end

// In iOS 7, if you want exact IMP for dealloc method from UIResponder class and use runtime API to get the result,
// the system will returns the dealloc IMP from NSObject class, which may not what you expected. So here is a simple
// solution to fix it. Call -swizzleInstanceMethodsBySelector:withSelector: to add the dealloc method for UIResponder
// first, then you can get exact dealloc IMP from UIResponder class.
@implementation UIResponder (YJSwizzleDeallocForUIResponder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodsBySelector:NSSelectorFromString(@"dealloc")
                                    withSelector:@selector(yj_handleResponderDealloc)];
    });
}

- (void)yj_handleResponderDealloc {
    [self yj_handleResponderDealloc];
}

@end
