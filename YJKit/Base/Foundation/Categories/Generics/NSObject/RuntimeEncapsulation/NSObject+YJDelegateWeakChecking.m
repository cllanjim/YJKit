//
//  NSObject+YJDelegateWeakChecking.m
//  YJKit
//
//  Created by huang-kun on 16/7/18.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "NSObject+YJDelegateWeakChecking.h"
#import <objc/runtime.h>

typedef void(^YJPropertyListEnumerationBlock)(objc_property_t property, const char *name, bool *stop);

static void _yj_enumeratePropertyList(id obj, YJPropertyListEnumerationBlock block) {
    bool stop = false;
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
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
    
    __block BOOL weakable = NO;
    _yj_enumeratePropertyList(obj, ^(objc_property_t property, const char *name, bool *stop) {
        if (strcmp(propertyName, name) == 0) {
            const char *attrs = property_getAttributes(property);
            const char *classInfo = strchr(attrs, '<');
            const char *weakInfo = strchr(attrs, 'W');
            
            if (weakInfo != NULL && !(classInfo[1] == 'Y' && classInfo[2] == 'J')) {
                weakable = YES;
                *stop = YES;
            }
        }
    });
    
    return weakable;
}

@implementation NSObject (YJDelegateWeakChecking)

- (BOOL)isWeakDelegateByDefault {
    return _yj_hasWeakDefaultProperty(self, "delegate");
}

- (BOOL)isWeakDataSourceByDefault {
    return _yj_hasWeakDefaultProperty(self, "dataSource");
}

@end
