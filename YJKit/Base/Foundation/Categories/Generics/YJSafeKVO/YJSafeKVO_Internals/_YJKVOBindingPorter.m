//
//  _YJKVOBindingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOBindingPorter.h"

@implementation _YJKVOBindingPorter

- (instancetype)initWithTarget:(__kindof NSObject *)target
                    subscriber:(__kindof NSObject *)subscriber
                 targetKeyPath:(NSString *)targetKeyPath
             subscriberKeyPath:(NSString *)subscriberKeyPath {
    
    self = [super initWithTarget:target subscriber:subscriber targetKeyPath:targetKeyPath];
    if (self) {
        _subscriberKeyPath = [subscriberKeyPath copy];
    }
    return self;
}

- (instancetype)initWithTarget:(__kindof NSObject *)target subscriber:(__kindof NSObject *)subscriber targetKeyPath:(NSString *)targetKeyPath {
    [NSException raise:NSGenericException format:@"Do not call %@ directly for %@.", NSStringFromSelector(_cmd), self.class];
    return [self initWithTarget:target subscriber:subscriber targetKeyPath:targetKeyPath subscriberKeyPath:(id)[NSNull null]];
}

- (void)handleValue:(nullable id)value fromObject:(id)object keyPath:(NSString *)keyPath {
    [self.subscriber setValue:value forKeyPath:self.subscriberKeyPath];
}

@end
