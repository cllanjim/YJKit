//
//  YJTestClasses.m
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJTestClasses.h"
#import "YJKVOPacker.h"

@interface Foo ()
@property (nonatomic, copy) NSString *privateName;
@end

@implementation Foo

- (void)sayHello { NSLog(@"instance hello"); }
+ (void)sayHello { NSLog(@"class hello"); }
+ (void)sayHi { NSLog(@"class hi"); }
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

- (void)addPrivateName {
    self.privateName = @"PrivateFoo";
}

+ (instancetype)foo {
    return [Foo new];
}

- (BOOL)isEqual:(id)object {
    return self.sleep == [object sleep];
}

- (NSString *)description {
    id vName = nil;//[self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

- (void)testKVOPost {
    [PACK([Bar sharedBar], name) post:^(id  _Nonnull self, id  _Nullable newValue) {
        NSLog(@"Shared bar has a new name: %@ and it tells %@", newValue, self);
    }];
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
    id vName = nil;//[self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

- (BOOL)isEqual:(id)object {
    return self.age == [object age];
}

@end


@implementation Clown

- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

- (BOOL)isEqual:(id)object {
    return CGSizeEqualToSize(self.size, [object size]);
}

- (NSString *)description {
    id vName = nil;//[self valueForKey:@"yj_KVOVariableName"];
    id addr = [NSString stringWithFormat:@"%p", self];
    return [NSString stringWithFormat:@"%@<%@>", self.class, (vName ? [NSString stringWithFormat:@"%@_%@", vName, addr] : addr)];
}

- (void)block:(void(^)(id obj1, __kindof NSObject *obj2, id _Nullable obj3, __kindof NSObject * _Nullable obj4))block {
    if (block) {
        block(@"1", @"2", @"3", @"4");
    }
}

- (void)testKVOPost {
    [PACK([Bar sharedBar], name) post:^(id  _Nonnull self, id  _Nullable newValue) {
        NSLog(@"Shared bar has a new name: %@ and it tells %@", newValue, self);
    }];
}

- (void)testKVOPost2 {
    self.name = @"Clown";
    [PACK(self, name) post:^(id  _Nonnull self, id  _Nullable newValue) {
        NSLog(@"%@'s name is %@", self, newValue);
    }];
    self.name = @"Clownnnnn";
}

@end

