//
//  NSObject+YJSafeKVO.m
//  YJKit
//
//  Created by huang-kun on 16/4/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJSafeKVO.h"
#import "NSObject+YJKVOExtension.h"
#import "YJKVOPair.h"
#import "_YJKVOPorter.h"
#import "_YJKVOGroupingPorter.h"
#import "_YJKVOExecutiveOfficer.h"

#pragma mark - YJSafeKVO implementations

YJKVODefaultChangeHandler (^yj_convertedKVOChangeHandler)(YJKVOSubscriberTargetValueHandler) = ^YJKVODefaultChangeHandler(YJKVOSubscriberTargetValueHandler objectsAndValueHander) {
    void(^changeHandler)(id,id,id,NSDictionary *) = ^(id receiver, id target, id newValue, NSDictionary *change){
        if (objectsAndValueHander) objectsAndValueHander(receiver, target, newValue);
    };
    return changeHandler;
};

@implementation NSObject (YJSafeKVO)

- (void)observe:(PACK)port updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    if (port.pair.isValid) {
        [self observeTarget:port.pair.object
                    keyPath:port.pair.keyPath
                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                      queue:nil
                    changes:yj_convertedKVOChangeHandler(updates)];
    }
}

- (void)observeGroup:(NSArray <PACK> *)ports updates:(void(^)())updates {
    if (!ports.count)
        return;
    
    __kindof NSObject *subscriber = self;
    
    _YJKVOGroupingPorter *porter = [[_YJKVOGroupingPorter alloc] initWithSubscriber:subscriber];
    porter.multipleValueHandler = updates;
    
    for (PACK port in ports) {
        if (port.pair.isValid) {
            [porter addTarget:port.pair.object keyPath:port.pair.keyPath];
        }
    }
    
    for (PACK port in ports) {
        if (port.pair.isValid) {
            [[_YJKVOExecutiveOfficer officer] organizeTarget:port.pair.object subscriber:subscriber porter:porter];
        }
    }
}

- (void)observe:(PACK)port
        options:(NSKeyValueObservingOptions)options
          queue:(nullable NSOperationQueue *)queue
        changes:(void(^)(id receiver, id target, id _Nullable newValue, NSDictionary *change))changes {
    
    if (port.pair.isValid) {
        [self observeTarget:port.pair.object
                    keyPath:port.pair.keyPath
                    options:options
                      queue:queue
                    changes:changes];
    }
}

- (void)observeTarget:(__kindof NSObject *)target
              keyPath:(NSString *)keyPath
              updates:(void(^)(id receiver, id target, id _Nullable newValue))updates {
    
    [self observeTarget:target
                keyPath:keyPath
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                  queue:nil
                changes:yj_convertedKVOChangeHandler(updates)];
}

- (void)observeTarget:(__kindof NSObject *)target
              keyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
                queue:(nullable NSOperationQueue *)queue
              changes:(void(^)(id receiver, id target, id _Nullable newValue, NSDictionary *change))changes {
    
    _YJKVOPorter *porter = [[_YJKVOPorter alloc] initWithTarget:target subscriber:self targetKeyPath:keyPath];
    porter.observingOptions = options;
    porter.changeHandler = changes;
    
    [[_YJKVOExecutiveOfficer officer] organizeTarget:target subscriber:self porter:porter];
}

- (void)unobserve:(PACK)port {
    if (port.pair.isValid) {
        [self unobserveTarget:port.pair.object keyPath:port.pair.keyPath];
    }
}

- (void)unobserveTarget:(__kindof NSObject *)target keyPath:(NSString *)keyPath {
    [[_YJKVOExecutiveOfficer officer] dismissPortersFromTarget:target andSubscriber:self forTargetKeyPath:keyPath];
}

- (void)unobserveAll {
    [[_YJKVOExecutiveOfficer officer] dismissSubscriber:self];
}

@end
