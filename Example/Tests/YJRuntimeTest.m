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
- (void)sayYoo;
+ (void)sayYoo;
@end

@implementation Bar
- (void)sayYoo { NSLog(@"instance yoo"); }
+ (void)sayYoo { NSLog(@"class yoo"); }
@end

@interface Foo : NSObject
@property (nonatomic, strong) Bar *friend;
- (void)sayHello;
+ (void)sayHello;
+ (void)sayHi;
@end

@implementation Foo
- (void)sayHello { NSLog(@"instance hello"); }
+ (void)sayHello { NSLog(@"class hello"); }
+ (void)sayHi { NSLog(@"class hi"); }
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

    [foo observeKeyPath:@keyPath(foo.friend.name) identifier:@"Foo1" queue:[NSOperationQueue mainQueue] forChanges:^(id  _Nonnull receiver, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"Foo1 name: %@ on thread %@", newValue, [NSThread currentThread]);
    }];
    
    [foo observeKeyPath:@keyPath(foo.friend.name) identifier:@"Foo2" queue:nil forChanges:^(id  _Nonnull receiver, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"Foo2 name: %@ on thread %@", newValue, [NSThread currentThread]);
    }];
    
    [foo stopObservingKeyPath:@keyPath(foo.friend.name)];
    
    foo.friend = bar;
    
    dispatch_queue_t q = dispatch_queue_create("queue", 0);
    dispatch_async(q, ^{
        bar.name = @"new bar";
    });
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

- (void)testMethodIMPInsertion {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [foo insertBlocksIntoMethodBySelector:@selector(sayHi)
                                 identifier:nil
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance hello", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance hello", receiver);
                                     }];
    [foo insertBlocksIntoMethodBySelector:@selector(sayHello)
                                 identifier:nil
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance hello again", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance hello again", receiver);
                                     }];
    [bar insertBlocksIntoMethodBySelector:@selector(sayYoo)
                                 identifier:@"Say Yoo"
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance yoo", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance yoo", receiver);
                                     }];
    [bar insertBlocksIntoMethodBySelector:@selector(sayYoo)
                                 identifier:@"Say Yoo"
                                     before:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -Before instance yoo again", receiver);
                                     } after:^(id  _Nonnull receiver) {
                                         NSLog(@"%@ -After instance yoo again", receiver);
                                     }];
    [foo sayHello];
    [bar sayYoo];
    
    
    [Foo insertBlocksIntoMethodBySelector:@selector(sayHello)
                               identifier:nil
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class hello", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class hello", receiver);
                                   }];
    [Foo insertBlocksIntoMethodBySelector:@selector(sayHello)
                               identifier:nil
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class hello again", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class hello again", receiver);
                                   }];
    [Bar insertBlocksIntoMethodBySelector:@selector(sayYoo)
                               identifier:@"Say Yoo"
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class yoo", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class yoo", receiver);
                                   }];
    [Bar insertBlocksIntoMethodBySelector:@selector(sayYoo)
                               identifier:@"Say Yoo"
                                   before:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -Before class yoo again", receiver);
                                   } after:^(id  _Nonnull receiver) {
                                       NSLog(@"%@ -After class yoo again", receiver);
                                   }];
    [Foo sayHello];
    [Bar sayYoo];
}

@end
