//
//  _YJKVOAssemblingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOAssemblingPorter.h"

@implementation _YJKVOAssemblingPorter

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    id newValue = change[NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) newValue = nil;
    
    BOOL taken = YES;
    if (self.takenHandler) {
        taken = self.takenHandler(self.subscriber, object, newValue);
    }
    if (!taken) return;
    
    id convertedValue = newValue;
    if (self.convertHandler) {
        convertedValue = self.convertHandler(self.subscriber, object, newValue);
    }
    
    [self handleValue:convertedValue fromObject:object keyPath:keyPath];
    
    if (self.afterHandler) {
        self.afterHandler(self.subscriber, object);
    }
}

- (void)handleValue:(nullable id)value fromObject:(id)object keyPath:(NSString *)keyPath {
    if (self.subscriber && self.valueHandler) {
        self.valueHandler(self.subscriber, value);
    }
}

@end
