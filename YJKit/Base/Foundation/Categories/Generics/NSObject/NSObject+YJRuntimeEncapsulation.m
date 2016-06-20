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

#pragma mark - YJRuntimeExtension

/* ----------------------------------- */
//     NSObject (YJRuntimeExtension)
/* ----------------------------------- */

BOOL yj_object_isClass(id obj) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    return object_isClass(obj);
#else
    return obj == [obj class];
#endif
}

@implementation NSObject (YJRuntimeExtension)

/* ------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------ */

Class (^YJProperClassForObject)(id, bool) = ^Class(id obj, bool searchingDispatchTableForClassObject/* not for meta class */) {
    Class cls;
    if (yj_object_isClass(obj)) {
        NSCAssert(!class_isMetaClass(obj), @"Don't use meta class as parameter.");
        cls = searchingDispatchTableForClassObject ? obj : object_getClass(obj);
    } else {
        cls = searchingDispatchTableForClassObject ? [obj class] : object_getClass([obj class]);
    }
    return cls;
};

typedef void(^YJMethodListEnumerationBlock)(Method method, SEL selector, bool *stop);

static void _yj_enumerateMethodList(id obj, bool searchingDispatchTableForClassObject,
                                    unsigned int *totalCount,
                                    YJMethodListEnumerationBlock block) {
    Class cls = YJProperClassForObject(obj, searchingDispatchTableForClassObject);
    
    bool stop = false;
    unsigned int count = 0;
    
    Method *methods = class_copyMethodList(cls, &count);
    if (totalCount) *totalCount = count;
    
    for (unsigned int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(method, selector, &stop);
        if (stop) break;
    }
    free(methods);
}

/* ------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------ */

- (BOOL)containsSelector:(SEL)sel {
    __block BOOL includes = NO;
    _yj_enumerateMethodList(self, true, NULL, ^(Method method, SEL selector, bool *stop) {
        if (selector == sel) {
            includes = YES;
            *stop = true;
        }
    });
    return includes;
}

+ (BOOL)containsSelector:(SEL)sel {
    __block BOOL includes = NO;
    _yj_enumerateMethodList(self, false, NULL, ^(Method method, SEL selector, bool *stop) {
        if (selector == sel) {
            includes = YES;
            *stop = true;
        }
    });
    return includes;
}

+ (BOOL)containsInstanceMethodBySelector:(SEL)sel {
    __block BOOL includes = NO;
    _yj_enumerateMethodList(self, true, NULL, ^(Method method, SEL selector, bool *stop) {
        if (selector == sel) {
            includes = YES;
            *stop = true;
        }
    });
    return includes;
}

@end


#pragma mark - Debugging

/* ----------------------------------- */
//              Debugging
/* ----------------------------------- */

@implementation NSObject (YJRuntimeDebugging)

static void _yj_debugDumpingMethodList(id obj, bool dumpInstanceMethods) {
    const char *clsName = class_getName([obj class]);
    unsigned int count = 0;
    printf("\n");
    printf("-------- Dump %s %s Methods -------\n", clsName, (dumpInstanceMethods ? "Instance" : "Class"));
    printf("\n");
    _yj_enumerateMethodList(obj, dumpInstanceMethods, &count, ^(Method method, SEL selector, bool *stop) {
        const char *selName = sel_getName(selector);
        printf("%s\n", selName);
    });
    printf("\n");
    printf("-------- Dumping end with %u methods --------\n", count);
    printf("\n");
}

+ (void)debugDumpingInstanceMethodList {
    _yj_debugDumpingMethodList(self, true);
}

+ (void)debugDumpingClassMethodList {
    _yj_debugDumpingMethodList(self, false);
}

// If receiver is an instance object, it should respond to selector
// rather than of crashing, then forward it to the class method.

- (void)debugDumpingInstanceMethodList {
    [self.class debugDumpingInstanceMethodList];
}

- (void)debugDumpingClassMethodList {
    [self.class debugDumpingClassMethodList];
}

@end


#pragma mark - YJAssociatedIdentifier

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


#pragma mark - YJSwizzling

/* ----------------------------------- */
//        NSObject (YJSwizzling)
/* ----------------------------------- */

@implementation NSObject (YJSwizzling)

static void _yj_swizzleMethodForClass(id class, SEL sel1, SEL sel2) {
    Method method1 = class_getInstanceMethod(class, sel1);
    Method method2 = class_getInstanceMethod(class, sel2);
    BOOL added = class_addMethod(class, sel1, method_getImplementation(method2), method_getTypeEncoding(method2));
    if (added) class_replaceMethod(class, sel2, method_getImplementation(method1), method_getTypeEncoding(method1));
    else method_exchangeImplementations(method1, method2);
}

+ (void)swizzleInstanceMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector {
    _yj_swizzleMethodForClass(self, selector, providedSelector);
}

+ (void)swizzleClassMethodsBySelector:(SEL)selector andSelector:(SEL)providedSelector {
    Class class = object_getClass((id)self);
    _yj_swizzleMethodForClass(class, selector, providedSelector);
}

@end


#pragma mark - YJMethodImpModifying

/* ----------------------------------- */
//   NSObject (YJMethodImpModifying)
/* ----------------------------------- */

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

static void _yj_insertImpBlocksIntoMethod(id obj, SEL sel, NSString *identifier,
                                          YJMethodImpInsertionBlock before,
                                          YJMethodImpInsertionBlock after) {
    
    if (!sel || (!before && !after))
        return;
    
    // get proper class
    BOOL isClass = yj_object_isClass(obj);
    
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
    _yj_insertImpBlocksIntoMethod(self, selector, identifier, before, after);
}

- (void)insertImplementationBlocksIntoInstanceMethodBySelector:(SEL)selector identifier:(nullable NSString *)identifier before:(nullable void(^)(id))before after:(nullable void(^)(id))after {
    _yj_insertImpBlocksIntoMethod(self, selector, identifier, before, after);
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
