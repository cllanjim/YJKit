//
//  YJRuntimeTest.m
//  YJKit
//
//  Created by huang-kun on 16/6/19.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+YJBlockBasedKVO.h"
#import "NSObject+YJRuntimeEncapsulation.h"
#import "YJObjcMacros.h"
#import <objc/runtime.h>

@interface Bar : NSObject
@property (nonatomic, copy) NSString *name;
- (void)sayHi;
@end

@implementation Bar
- (void)sayHi { NSLog(@"hi"); }
@end

@interface Foo : NSObject
@property (nonatomic, strong) Bar *friend;
- (void)sayHello;
@end

@implementation Foo
- (void)sayHello { NSLog(@"hello"); }
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

- (void)testContainsSelector {
    NSMutableArray *mutableArray = @[].mutableCopy;
    BOOL b1 = [mutableArray respondsToSelector:@selector(containsObject:)]; // YES
    BOOL b2 = [mutableArray containsSelector:@selector(containsObject:)]; // NO
    XCTAssertTrue(b1 == YES);
    XCTAssertTrue(b2 == NO);
    
    BOOL b3 = [NSMutableArray respondsToSelector:@selector(arrayWithArray:)]; // YES
    BOOL b4 = [NSMutableArray containsSelector:@selector(arrayWithArray:)]; // NO
    XCTAssertTrue(b3 == YES);
    XCTAssertTrue(b4 == NO);
    
    BOOL b5 = [NSMutableArray instancesRespondToSelector:@selector(containsObject:)]; // YES
    BOOL b6 = [NSMutableArray containsInstanceMethodBySelector:@selector(containsObject:)]; // NO
    XCTAssertTrue(b5 == YES);
    XCTAssertTrue(b6 == NO);
}

- (void)testKVO {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [foo observeKeyPath:@keyPath(foo.friend) forChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"foo <%@> meets its new friend <%@>", object, newValue);
    }];

    [foo observeKeyPath:@keyPath(foo.friend.name) forChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"object: %@, old: %@, new: %@", object, oldValue, newValue);
    }];
    
    foo.friend = bar;
    bar.name = @"bar";
    
    [bar setValue:@"Bar" forKey:@keyPath(bar.name)];
    [foo setValue:@"bar" forKeyPath:@keyPath(foo.friend.name)];
}

- (void)testMethodIMPInsertion {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [foo insertImplementationBlocksIntoInstanceMethodBySelector:@selector(sayHi)
                                                     identifier:nil
                                                         before:^(id  _Nonnull receiver) {
                                                             NSLog(@"Before hello");
                                                         } after:^(id  _Nonnull receiver) {
                                                             NSLog(@"After hello");
                                                         }];
    [foo insertImplementationBlocksIntoInstanceMethodBySelector:@selector(sayHello)
                                                     identifier:nil
                                                         before:^(id  _Nonnull receiver) {
                                                             NSLog(@"Before hello again");
                                                         } after:^(id  _Nonnull receiver) {
                                                             NSLog(@"After hello again");
                                                         }];
    [bar insertImplementationBlocksIntoInstanceMethodBySelector:@selector(sayHi)
                                                     identifier:@"Say Hi"
                                                         before:^(id  _Nonnull receiver) {
                                                             NSLog(@"Before hi");
                                                         } after:^(id  _Nonnull receiver) {
                                                             NSLog(@"After hi");
                                                         }];
    [bar insertImplementationBlocksIntoInstanceMethodBySelector:@selector(sayHi)
                                                     identifier:@"Say Hi"
                                                         before:^(id  _Nonnull receiver) {
                                                             NSLog(@"Before hi again");
                                                         } after:^(id  _Nonnull receiver) {
                                                             NSLog(@"After hi again");
                                                         }];
    [foo sayHello];
    [bar sayHi];
}

@end
