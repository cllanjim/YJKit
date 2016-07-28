//
//  _YJKVOGroupingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/5.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOGroupingPorter.h"
#import "YJUnsafeMixedObjectCombinator.h"
#import "YJUnsafeObjectCombinator.h"

@interface _YJKVOGroupingPorter ()

@property (nonatomic, strong) NSMutableArray <YJUnsafeMixedObjectCombinator *> *targetsAndKeyPaths;
@property (nonatomic, strong) YJUnsafeObjectCombinator *multipleValues;
@property (nonatomic, readwrite) BOOL employed;

@end


@implementation _YJKVOGroupingPorter {
    int _counter;
}

@synthesize employed = _employed;

- (instancetype)initWithSubscriber:(__kindof NSObject *)subscriber {
    self = [super initWithTarget:nil subscriber:subscriber targetKeyPath:nil];
    if (self) {
        _targetsAndKeyPaths = [[NSMutableArray alloc] initWithCapacity:10];
        _multipleValues = [YJUnsafeObjectCombinator new];
    }
    return self;
}

- (instancetype)initWithTarget:(__kindof NSObject *)target subscriber:(__kindof NSObject *)subscriber targetKeyPath:(NSString *)targetKeyPath {
    [NSException raise:NSGenericException format:@"Do not call %@ directly for %@.", NSStringFromSelector(_cmd), self.class];
    return [self initWithSubscriber:(id)[NSNull null]];
}

- (void)addTarget:(__kindof NSObject *)target keyPath:(NSString *)keyPath {
    [self.targetsAndKeyPaths addObject:YJUnsafeMixedObjectCombinatorPack(target, keyPath)];
}

- (void)signUp {
    if (self.employed)
        return;
    
    for (YJUnsafeMixedObjectCombinator *targetAndKeyPath in self.targetsAndKeyPaths) {
        [targetAndKeyPath.first addObserver:self forKeyPath:targetAndKeyPath.second options:self.observingOptions context:NULL];
    }
    self.employed = YES;
}

- (void)resign {
    if (!self.employed)
        return;
    
    for (YJUnsafeMixedObjectCombinator *targetAndKeyPath in self.targetsAndKeyPaths) {
        [targetAndKeyPath.first removeObserver:self forKeyPath:targetAndKeyPath.second context:NULL];
    }
    self.employed = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    id newValue = change[NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) newValue = nil;
    
    if (self.multipleValueHandler && [self applyNewValue:newValue fromKeyPath:keyPath ofObject:object]) {
        self.multipleValueHandler(self.multipleValues.first, self.multipleValues.second, self.multipleValues.third,
                                  self.multipleValues.fourth, self.multipleValues.fifth, self.multipleValues.sixth,
                                  self.multipleValues.seventh, self.multipleValues.eighth, self.multipleValues.ninth,
                                  self.multipleValues.tenth);
    }
    
    if (self.reduceValueReturnHandler && self.subscriberKeyPath && [self applyNewValue:newValue fromKeyPath:keyPath ofObject:object]) {
        id reducedValue = self.reduceValueReturnHandler(self.multipleValues.first, self.multipleValues.second, self.multipleValues.third,
                                                        self.multipleValues.fourth, self.multipleValues.fifth, self.multipleValues.sixth,
                                                        self.multipleValues.seventh, self.multipleValues.eighth, self.multipleValues.ninth,
                                                        self.multipleValues.tenth);
        [self.subscriber setValue:reducedValue forKeyPath:self.subscriberKeyPath];
    }
}

- (BOOL)applyNewValue:(nullable id)newValue fromKeyPath:(NSString *)keyPath ofObject:(id)object {
    
    NSAssert(self.targetsAndKeyPaths.count <= YJ_MUTABLE_TUPLE_MAX_NUMBER_OF_VALUES, @"YJSafeKVO Exception - Too many key paths observing, should less then %@, but you have %@", @(YJ_MUTABLE_TUPLE_MAX_NUMBER_OF_VALUES), @(self.targetsAndKeyPaths.count));
    
    NSInteger index = NSNotFound;
    for (int i = 0; i < (int)self.targetsAndKeyPaths.count; i++) {
        YJUnsafeMixedObjectCombinator *targetAndKeyPath = self.targetsAndKeyPaths[i];
        if (targetAndKeyPath.first == object && [targetAndKeyPath.second isEqualToString:keyPath]) {
            index = i;
            break;
        }
    }
    
    if (index != NSNotFound) {
        self.multipleValues[index] = newValue;
        _counter++;
    }
    
    return _counter >= self.targetsAndKeyPaths.count;
}

@end
