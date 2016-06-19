//
//  YJRuntimeTest.m
//  YJKit
//
//  Created by Jack Huang on 16/6/19.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+YJBlockBasedKVO.h"
#import "NSObject+YJRuntimeEncapsulation.h"
#import "YJObjcMacros.h"
#import <objc/runtime.h>

@interface Bar : NSObject
@property (nonatomic, copy) NSString *name;
@end

@implementation Bar
@end

@interface Foo : NSObject
@property (nonatomic, strong) Bar *friend;
@end

@implementation Foo
@end

@interface YJRuntimeTest : XCTestCase
@end

@implementation YJRuntimeTest

- (void)testClassChecking {
    NSObject *obj1 = [NSObject new];
    Class obj2 = NSObject.self;
    Class obj3 = object_getClass(obj2);
    
    BOOL b1 = yj_object_isClass(obj1);
    BOOL b2 = yj_object_isClass(obj2);
    BOOL b3 = yj_object_isClass(obj3);
    
    XCTAssertTrue(b1 == NO, @"obj1 is not a class.");
    XCTAssertTrue(b2 == YES, @"obj2 is a class.");
    XCTAssertTrue(b3 == YES, @"obj3 is a meta class.");
}

- (void)testDumpingMethodList {
    [NSObject debugDumpingInstanceMethodList];
    [NSObject debugDumpingClassMethodList];
}

- (void)testKVO {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [foo registerObserverForKeyPath:@keyPath(foo.friend) handleChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"object: %@, old: %@, new: %@", object, oldValue, newValue);
    }];
    
    [foo registerObserverForKeyPath:@keyPath(foo.friend.name) handleChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"object: %@, old: %@, new: %@", object, oldValue, newValue);
    }];
    
    foo.friend = bar;
    bar.name = @"bar";
}

@end
