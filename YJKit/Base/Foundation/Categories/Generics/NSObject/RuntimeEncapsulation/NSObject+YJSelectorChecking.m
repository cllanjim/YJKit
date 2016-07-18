//
//  NSObject+YJSelectorChecking.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJSelectorChecking.h"
#import "NSObject+YJClassObjectChecking.h"

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

@implementation NSObject (YJSelectorChecking)

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
