//
//  YJTestClasses.m
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJTestClasses.h"

@implementation Foo

- (void)sayHello { NSLog(@"instance hello"); }
+ (void)sayHello { NSLog(@"class hello"); }
+ (void)sayHi { NSLog(@"class hi"); }
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

+ (instancetype)foo {
    return [Foo new];
}

- (BOOL)isEqual:(id)object {
    return self.sleep == [object sleep];
}

- (NSString *)description {
    id vName = [self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

@end


@implementation Bar

+ (instancetype)sharedBar {
    static Bar *bar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bar = [Bar new];
    });
    return bar;
}

+ (instancetype)bar {
    return [Bar bar];
}

- (void)sayYoo { NSLog(@"instance yoo"); }
+ (void)sayYoo { NSLog(@"class yoo"); }
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

- (NSString *)description {
    id vName = [self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

- (BOOL)isEqual:(id)object {
    return self.age == [object age];
}

@end


@implementation Clown

- (BOOL)isEqual:(id)object {
    return CGSizeEqualToSize(self.size, [object size]);
}

- (NSString *)description {
    id vName = [self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

@end

