//
//  YJRuntimeTest.m
//  YJKit
//
//  Created by huang-kun on 16/6/19.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YJRuntimeEncapsulation.h"
#import "NSObject+YJSafeKVO.h"
#import "YJKVCMacros.h"
#import <objc/runtime.h>
#import "YJTestClasses.h"

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

- (void)testMethodIMPInsertion {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [foo performBlocksByInvokingSelector:@selector(sayHi)
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance hello", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance hello", receiver);
                                     }];
    [foo performBlocksByInvokingSelector:@selector(sayHello)
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance hello again", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance hello again", receiver);
                                     }];
    [bar performBlocksByInvokingSelector:@selector(sayYoo)
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance yoo", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance yoo", receiver);
                                     }];
    [bar performBlocksByInvokingSelector:@selector(sayYoo)
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance yoo again", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance yoo again", receiver);
                                     }];
    [foo sayHello];
    [bar sayYoo];
    
    
    [Foo performBlocksByInvokingSelector:@selector(sayHello)
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class hello", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class hello", receiver);
                                   }];
    [Foo performBlocksByInvokingSelector:@selector(sayHello)
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class hello again", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class hello again", receiver);
                                   }];
    [Bar performBlocksByInvokingSelector:@selector(sayYoo)
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class yoo", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class yoo", receiver);
                                   }];
    [Bar performBlocksByInvokingSelector:@selector(sayYoo)
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class yoo again", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class yoo again", receiver);
                                   }];
    [Foo sayHello];
    [Bar sayYoo];
}

@end
