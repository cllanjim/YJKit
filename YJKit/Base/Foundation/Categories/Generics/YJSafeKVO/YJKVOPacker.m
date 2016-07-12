//
//  YJKVOPacker.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJKVOPacker.h"
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOExecutiveOfficer.h"
#import "_YJKVOBindingPorter.h"
#import "_YJKVOPipeIDKeeper.h"
#import "_YJKVOIdentifierGenerator.h"

@interface YJKVOPacker ()
@property (nonatomic, strong) __kindof NSObject *object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) _YJKVOBindingPorter *bindingPorter;
@end

@implementation YJKVOPacker

+ (instancetype)tupleWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    YJKVOPacker *tuple = [YJKVOPacker new];
    tuple.object = object;
    tuple.keyPath = keyPath;
    return tuple;
}

- (BOOL)isValid {
    if (![self isKindOfClass:[YJKVOPacker class]]) return NO;
    NSAssert(self.object != nil, @"YJSafeKVO - Target can not be nil for Key value observing.");
    NSAssert(self.keyPath.length > 0, @"YJSafeKVO - KeyPath can not be empty for Key value observing.");
    return self.object && self.keyPath.length;
}

@end


@implementation YJKVOPacker (YJKVOBinding)

- (void)bind:(PACK)targetAndKeyPath {
    [self _pipedFrom:targetAndKeyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

- (id)piped:(PACK)targetAndKeyPath {
    [self _pipedFrom:targetAndKeyPath options:NSKeyValueObservingOptionNew];
    return targetAndKeyPath;
}

- (void)ready {
    [self.object setValue:[self.object valueForKeyPath:self.keyPath] forKeyPath:self.keyPath];
}

- (void)_pipedFrom:(PACK)targetAndKeyPath options:(NSKeyValueObservingOptions)options {
    if (targetAndKeyPath.isValid) {
        __kindof NSObject *observer = self.object;
        NSString *observerKeyPath = self.keyPath;
        
        // generate pipe id
        NSString *identifier = [[_YJKVOIdentifierGenerator sharedGenerator] pipeIdentifierForObserver:observer
                                                                                      observerKeyPath:observerKeyPath
                                                                                               target:targetAndKeyPath.object
                                                                                        targetKeyPath:targetAndKeyPath.keyPath];
        // keep pipe id
        _YJKVOPipeIDKeeper *pipeIDKeeper = observer.yj_KVOPipeIDKeeper;
        if (!pipeIDKeeper) {
            pipeIDKeeper = [[_YJKVOPipeIDKeeper alloc] initWithObserver:observer];
            observer.yj_KVOPipeIDKeeper = pipeIDKeeper;
        }
        [pipeIDKeeper addPipeIdentifier:identifier];
        
        // generate pipe porter
        _YJKVOBindingPorter *porter = [[_YJKVOBindingPorter alloc] initWithObserver:observer
                                                                    observerKeyPath:observerKeyPath];
        [targetAndKeyPath setBindingPorter:porter];
        
        // register pipe porter
        [[_YJKVOExecutiveOfficer officer] registerPorter:porter
                                             forObserver:observer
                                                  target:targetAndKeyPath.object
                                           targetKeyPath:targetAndKeyPath.keyPath
                                                 options:options];
    }
}

- (id)taken:(BOOL(^)(id observer, id target, id newValue))taken {
    self.bindingPorter.takenHandler = taken;
    return self;
}

- (id)convert:(id(^)(id observer, id target, id newValue))convert {
    self.bindingPorter.convertHandler = convert;
    return self;
}

- (id)after:(void(^)(id observer, id target))after {
    self.bindingPorter.afterHandler = after;
    return self;
}

@end