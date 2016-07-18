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

__unused static void _yj_enumeratePropertyList(id obj, YJPropertyListEnumerationBlock block) {
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

static BOOL _yj_hasWeakProperty(id obj, const char *propertyName) {
    objc_property_t property = class_getProperty([obj class], propertyName);
    if (!property) return NO;
    
    const char *attrs = property_getAttributes(property);
    const char *result = strchr(attrs, 'W');
    
    return (result != NULL) ? YES : NO;
}

@implementation NSObject (YJDelegateWeakChecking)

- (BOOL)hasWeakDelegateProperty {
    return _yj_hasWeakProperty(self, "delegate");
}

- (BOOL)hasWeakDataSourceProperty {
    return _yj_hasWeakProperty(self, "dataSource");
}

@end
