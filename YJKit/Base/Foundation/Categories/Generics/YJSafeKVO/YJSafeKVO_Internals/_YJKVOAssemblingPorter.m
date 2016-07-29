//
//  _YJKVOAssemblingPorter.m
//  YJKit
//
//  Created by huang-kun on 16/7/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "_YJKVOAssemblingPorter.h"
#import "YJObjectCombinator.h"
#import "NSObject+YJAssociatedIdentifier.h"

const NSInteger YJKeyValueFilteringTag = __LINE__;
const NSInteger YJKeyValueConvertingTag = __LINE__;
const NSInteger YJKeyValueAppliedTag = __LINE__;

@interface _YJKVOAssemblingPorter()
@property (nonatomic, strong) YJObjectCombinator *handlers;
@property (nonatomic, strong) id processedValue;
@property (nonatomic, assign) BOOL valueAccepted;
@property (nonatomic, assign) BOOL dispatched;
@end

@implementation _YJKVOAssemblingPorter

- (instancetype)initWithTarget:(__kindof NSObject *)target subscriber:(__kindof NSObject *)subscriber targetKeyPath:(NSString *)targetKeyPath {
    self = [super initWithTarget:target subscriber:subscriber targetKeyPath:targetKeyPath];
    if (self) {
        _handlers = [YJObjectCombinator new];
    }
    return self;
}

- (void)addKVOHandler:(id)handler forTag:(NSInteger)tag {
    for (int i = 0; i < YJ_OBJECT_COMBINATOR_MAX_VALUE_COUNT; i++) {
        if (!self.handlers[i]) {
            id block = [handler copy];
            [block setAssociatedTag:tag];
            self.handlers[i] = block;
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    id newValue = change[NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) newValue = nil;
    
    self.processedValue = newValue;
    self.valueAccepted = YES;
    
    NSMutableArray *applies = [NSMutableArray arrayWithCapacity:YJ_OBJECT_COMBINATOR_MAX_VALUE_COUNT];
    
    for (int i = 0; i < YJ_OBJECT_COMBINATOR_MAX_VALUE_COUNT; i++) {
        id block = self.handlers[i];
        if (!block) break;
        
        NSInteger tag = [block associatedTag];
        
        if (tag == YJKeyValueFilteringTag) {
            YJKVOValueFilteringHandler handler = block;
            self.valueAccepted = handler(self.processedValue);
            if (!self.valueAccepted) break;
        } else if (tag == YJKeyValueConvertingTag) {
            YJKVOValueReturnHandler handler = block;
            self.processedValue = handler(self.processedValue);
        } else if (tag == YJKeyValueAppliedTag) {
            [applies addObject:block];
        }
    }
    
    if (!self.valueAccepted)
        return;
    
    if (self.subscriberKeyPath) {
        [self.subscriber setValue:self.processedValue forKeyPath:self.subscriberKeyPath];
    } else if (self.valueHandler) {
        self.valueHandler(self.processedValue);
    }
    
    for (id block in applies) {
        YJKVOVoidHandler handler = block;
        handler();
    }
}

@end
