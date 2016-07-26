//
//  NSObject+YJDelegateWeakChecking.m
//  YJKit
//
//  Created by huang-kun on 16/7/18.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "NSObject+YJDelegateWeakChecking.h"
#import "NSObject+YJClassObjectChecking.h"
#import <objc/runtime.h>

typedef void(^YJPropertyListEnumerationBlock)(objc_property_t property, const char *name, bool *stop);

static void _yj_enumeratePropertyList(Class cls, YJPropertyListEnumerationBlock block) {
    bool stop = false;
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        if (block) block(property, name, &stop);
        if (stop) break;
    }
    free(properties);
}

static BOOL _yj_hasWeakDefaultProperty(id obj, const char *propertyName) {
    
    // This is not working correctly by using class_getProperty(), because
    // YJKit re-defined some system properties and declared them weak.
    
    Class cls = yj_object_isClass(obj) ? obj : [obj class];
    __block BOOL weakable = NO;

    _yj_enumeratePropertyList(cls, ^(objc_property_t property, const char *name, bool *stop) {
        if (strcmp(propertyName, name) == 0) {
            const char *attrs = property_getAttributes(property);
            const char *classInfo = strchr(attrs, '<');
            const char *weakInfo = strchr(attrs, 'W');
            
            if (weakInfo != NULL && classInfo && !(classInfo[1] == 'Y' && classInfo[2] == 'J')) {
                weakable = YES;
                *stop = YES;
            }
        }
    });
    
    return weakable;
}

@implementation NSObject (YJDelegateWeakChecking)

+ (BOOL)isWeakDelegateByDefault {
    return _yj_hasWeakDefaultProperty(self, "delegate");
}

- (BOOL)isWeakDelegateByDefault {
    return _yj_hasWeakDefaultProperty(self, "delegate");
}

+ (BOOL)isWeakDataSourceByDefault {
    return _yj_hasWeakDefaultProperty(self, "dataSource");
}

- (BOOL)isWeakDataSourceByDefault {
    return _yj_hasWeakDefaultProperty(self, "dataSource");
}

@end
