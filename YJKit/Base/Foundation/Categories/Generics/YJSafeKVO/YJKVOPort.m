//
//  YJKVOPort.m
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJKVOPort.h"
#import "YJKVOPair.h"
#import "YJObjectCombinator.h"
#import "NSObject+YJKVOExtension.h"
#import "NSObject+YJAssociatedIdentifier.h"
#import "_YJKVOExecutiveOfficer.h"
#import "_YJKVOAssemblingPorter.h"
#import "_YJKVOGroupingPorter.h"

@interface YJKVOPort ()

@property (nonatomic, readwrite, strong) YJKVOPair *pair;
@property (nullable, nonatomic, strong) _YJKVOAssemblingPorter *assemblingPorter;
@property (nullable, nonatomic, assign) __kindof NSObject *implicitSubscriber;

@end


@implementation YJKVOPort

- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        _pair = [[YJKVOPair alloc] initWithObject:object keyPath:keyPath];
    }
    return self;
}

- (instancetype)init {
    [NSException raise:NSGenericException format:@"Do not call init directly for %@.", self.class];
    return [self initWithObject:(id)[NSNull null] keyPath:(id)[NSNull null]];
}

+ (instancetype)portWithObject:(__kindof NSObject *)object
                       keyPath:(NSString *)keyPath
                            on:(nullable __kindof NSObject *)on {
    
    YJKVOPort *port = [[self alloc] initWithObject:object keyPath:keyPath];
    port.implicitSubscriber = on;
    port.assemblingPorter = [_YJKVOAssemblingPorter new];
    return port;
}

- (_YJKVOAssemblingPorter *)assemblingPorter {
    if (!_assemblingPorter) {
        _assemblingPorter = [_YJKVOAssemblingPorter new];
    }
    return _assemblingPorter;
}

@end


@implementation YJKVOPort (YJKVOSubscribing)

- (YJKVOPort *)bindTo:(YJKVOPort *)port {
    if (self.pair.isValid && port.pair.isValid) {
        _YJKVOAssemblingPorter *porter = self.assemblingPorter;
        
        porter.target = self.pair.object;
        porter.subscriber = port.pair.object;
        porter.targetKeyPath = self.pair.keyPath;
        porter.subscriberKeyPath = port.pair.keyPath;
        porter.observingOptions = NSKeyValueObservingOptionNew;
        
        [[_YJKVOExecutiveOfficer officer] organizeTarget:self.pair.object
                                              subscriber:port.pair.object
                                                  porter:porter];
        return self;
    }
    return nil;
}

- (YJKVOPort *)boundTo:(YJKVOPort *)port {
    if (self.pair.isValid && port.pair.isValid) {
        _YJKVOAssemblingPorter *porter = port.assemblingPorter;
        
        porter.target = port.pair.object;
        porter.subscriber = self.pair.object;
        porter.targetKeyPath = port.pair.keyPath;
        porter.subscriberKeyPath = self.pair.keyPath;
        porter.observingOptions = NSKeyValueObservingOptionNew;
        
        [[_YJKVOExecutiveOfficer officer] organizeTarget:port.pair.object
                                              subscriber:self.pair.object
                                                  porter:porter];
        return port;
    }
    return nil;
}

- (void)now {
    [self.pair.object setValue:[self.pair.object valueForKeyPath:self.pair.keyPath]
                    forKeyPath:self.pair.keyPath];
    self.assemblingPorter = nil;
}

- (id)filter:(BOOL(^)(id newValue))filter {
    [self.assemblingPorter addKVOHandler:filter forTag:YJKeyValueFilteringTag];
    return self;
}

- (id)convert:(id(^)(id newValue))convert {
    [self.assemblingPorter addKVOHandler:convert forTag:YJKeyValueConvertingTag];
    return self;
}

- (id)applied:(void(^)(void))applied {
    [self.assemblingPorter addKVOHandler:applied forTag:YJKeyValueAppliedTag];
    return self;
}

- (void)combineLatest:(NSArray <YJKVOPort *> *)ports reduce:(id(^)())reduce {
    if (!self.pair.isValid || !ports.count) {
        self.assemblingPorter = nil;
        return;
    }

    _YJKVOGroupingPorter *porter = [[_YJKVOGroupingPorter alloc] initWithSubscriber:self.pair.object];
    porter.subscriberKeyPath = self.pair.keyPath;
    porter.reduceValueReturnHandler = reduce;
    
    for (YJKVOPort *port in ports) {
        if (port.pair.isValid) {
            [porter addTarget:port.pair.object keyPath:port.pair.keyPath];
        }
    }
    
    for (YJKVOPort *port in ports) {
        if (port.pair.isValid) {
            [[_YJKVOExecutiveOfficer officer] organizeTarget:port.pair.object
                                                  subscriber:self.pair.object
                                                      porter:porter];
        }
    }
    self.assemblingPorter = nil;
}

- (void)cutOff:(YJKVOPort *)port {
    if (self.pair.isValid && port.pair.isValid) {
        [[_YJKVOExecutiveOfficer officer] dismissPortersFromTarget:port.pair.object
                                                     andSubscriber:self.pair.object
                                                  forTargetKeyPath:port.pair.keyPath
                                              andSubscriberKeyPath:self.pair.keyPath];
    }
    self.assemblingPorter = nil;
}

@end


@implementation YJKVOPort (YJKVOPosting)

- (YJKVOPort *)post:(void (^)(id _Nullable))post {
    if (self.pair.isValid) {
        _YJKVOAssemblingPorter *porter = self.assemblingPorter;
        
        porter.target = self.pair.object;
        porter.subscriber = self.implicitSubscriber;
        porter.targetKeyPath = self.pair.keyPath;
        porter.valueHandler = post;
        porter.observingOptions = NSKeyValueObservingOptionNew;
        
        [[_YJKVOExecutiveOfficer officer] organizeTarget:self.pair.object
                                              subscriber:self.implicitSubscriber
                                                  porter:porter];
        self.assemblingPorter = nil;
        return self;
    }
    self.assemblingPorter = nil;
    return nil;
}

- (void)stopPosting {
    if (self.pair.isValid) {
        [[_YJKVOExecutiveOfficer officer] dismissPortersFromTarget:self.pair.object
                                                     andSubscriber:self.implicitSubscriber
                                                  forTargetKeyPath:self.pair.keyPath];
    }
    self.assemblingPorter = nil;
}

@end
