//
//  YJKVOTest.m
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YJTestClasses.h"
#import "NSObject+YJSafeKVO.h"

@interface YJKVOTest : XCTestCase
@property (nonatomic, strong) Foo *foo;
@property (nonatomic, strong) Bar *bar;
@end

@implementation YJKVOTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.foo = [Foo new];
    self.bar = [Bar new];
    self.foo.friend = self.bar;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.foo = nil;
    self.bar = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    self.bar.name = @"bar";
    XCTAssertTrue([self.bar.name isEqualToString:@"bar"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        
    }];
}

- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

- (void)testSimpleKVO {
    __block int i = 0;
    [self.foo observe:PACK(self.bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
        [foo sayHello];
        [bar sayYoo];
        i++;
    }];
    self.bar.name = @"Barr";
    XCTAssertTrue(i == 2);
}

- (void)testFullKVO {
    __block int i = 0;
    [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew queue:[NSOperationQueue mainQueue] changes:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, NSDictionary * _Nonnull change) {
        NSLog(@"%@", change);
        [foo sayHello];
        [bar sayYoo];
        i++;
    }];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    XCTAssertTrue(i == 1);
}

- (void)testNilKeyPath {
    __block int i = 0;
    self.bar.name = nil;
    [self.foo observe:PACK(self.bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
        NSLog(@"%@", newValue);
        i++;
    }];
    self.bar.name = @"Bar";
    XCTAssertTrue(i == 2);
}

- (void)testKVOTargetDealloc {
    __block int i = 0;
    Bar *bar = [Bar new];
    [self.foo observe:PACK(bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
        NSLog(@"%@", newValue);
        i++;
    }];
    bar.name = @"Baaaar";
    XCTAssertTrue(i == 2);
}

- (void)testKVOSubscriberDealloc {
    __block int i = 0;
    Foo *foo = [Foo new];
    [foo observe:PACK(self.bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
        NSLog(@"%@", newValue);
        i++;
    }];
    self.bar.name = @"Baaaar";
    XCTAssertTrue(i == 2);
}

- (void)testMultipleKeyPathsObserving {
    __block int i = 0;
    int count = 10;
    for (int j = 0; j < count; j++) {
        [self.foo observe:PACK(self.bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
            NSLog(@"%@", newValue);
            i++;
        }];
    }
    self.bar.name = @"Bar";
    XCTAssertTrue(i == count * 2);
}

- (void)testMultipleTheadsObserving {
    __block int i = 0;
    int count = 10;
    for (int j = 0; j < count; j++) {
        [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:[NSOperationQueue new] changes:^(id  _Nonnull receiver, id  _Nonnull target, NSDictionary * _Nonnull change) {
            id newValue = change[NSKeyValueChangeNewKey];
            NSLog(@"%@ on %@", newValue, [NSThread currentThread]);
            i++;
            NSLog(@"i = %@", @(i));
        }];
    }
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        self.bar.name = @"Bar";
    }];
    NSOperationQueue *q = [NSOperationQueue new];
    [q addOperation:op];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    XCTAssertTrue(i == count);
}

- (void)testUnobserving {
    __block int i = 0;
    int count = 2;
    Foo *foo = [Foo new];
    for (int j = 0; j < count; j++) {
        [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, NSDictionary * _Nonnull change) {
            id newValue = change[NSKeyValueChangeNewKey];
            NSLog(@"CAN NOT PRINT: %@", newValue);
            i++;
        }];
        [foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, NSDictionary * _Nonnull change) {
            id newValue = change[NSKeyValueChangeNewKey];
            NSLog(@"%@", newValue);
        }];
    }
    [self.foo unobserve:PACK(self.bar, name)];

    self.bar.name = @"Baaar";
    XCTAssertTrue(i == 0);
}

- (void)testRetainCycleBreaks {
    __block int i = 0;
    @autoreleasepool {
        Foo *foo = [Foo new];
        [self.foo observe:PACK(self.bar, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            [self.foo sayHello];
            [self.bar sayYoo];
            [foo sayHello];
            i++;
        }];
        self.bar = nil;
        self.foo = nil;
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    XCTAssertTrue(i == 1);
}

- (void)testKVOCallbacks {
    __block int i = 0;
    @autoreleasepool {
        __block Foo *foo = [Foo new];
        __block Bar *bar = [Bar new];
        for (int j = 0; j < 3; j++) {
            [foo observeTarget:bar keyPath:@"name" updates:^(Foo *  _Nonnull foo_, Bar *  _Nonnull bar_, id  _Nullable newValue) {
                [foo_ sayHello];
                [bar_ sayYoo];
                i++;
                foo = nil;
                bar = nil;
            }];
        }
    }
    XCTAssertTrue(i == 1);
}

- (void)testKVOSelf {
    __block int i = 0;
    Bar *bar = [Bar new];
    bar.name = @"Barrrr";
    [bar observe:PACK(bar, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"new name: %@", newValue);
        i++;
    }];
    XCTAssertTrue(i == 1);
}

- (void)testOwnership {
    __block int i = 0;
    [self observe:PACK(self.bar, name) updates:^(id  _Nonnull self, id  _Nonnull target, id  _Nullable newValue) {
        i++;
        NSLog(@"%@", self);
    }];
    XCTAssertTrue(i == 1);
}

- (void)testMultipleObservedTargets {
    Foo *foo1 = [Foo new];
    Foo *foo2 = [Foo new];
    Bar *bar1 = [Bar new];
    Bar *bar2 = [Bar new];
    Bar *bar3 = [Bar bar];
    
    [foo1 observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
    
    [foo1 observe:PACK(bar2, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];

    [foo1 observe:PACK(bar3, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
    
    [foo2 observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];

    [foo2 observe:PACK(bar2, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
    
    [foo2 observe:PACK(bar3, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
    
    NSLog(@"");
    
    foo1 = nil;
    foo2 = nil;

    NSLog(@"");
}

- (void)testObserveEachOther {
    Foo *foo1 = [Foo new];
    Bar *bar1 = [Bar new];
    [foo1 observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
    [bar1 observe:PACK(foo1, friend) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"%@ - %@", target, newValue);
    }];
}

- (void)testGroupKVO {
    Bar *bar1 = [Bar new];
//    Bar *bar2 = [Bar new];
    
    [self.foo observes:@[ PACK(bar1, name), PACK(bar1, age) ] updates:^(id  _Nonnull receiver, NSArray * _Nonnull targets) {
        Bar *bar1 = targets[0];
//        Bar *bar2 = targets[1];
//        NSLog(@"1: %@, 2: %@", bar1, bar2);
        if ([bar1.name isEqualToString:@"Bar1"] && bar1.age == 29) {
            XCTAssertTrue(1);
        }
    }];
    
    bar1.name = @"Bar1";
    bar1.age = 29;//@"Bar2";
}

- (void)testBinding {
    [[[PACK(self.foo, sleep) bind:PACK(self.bar, name)]
     convert:^id _Nonnull(id  _Nonnull observer, id  _Nonnull target, NSString *newValue) {
        return @(newValue.length < 10 ? NO : YES);
    }]
     after:^(id  _Nonnull observer, id  _Nonnull target) {
         NSLog(@"after.");
    }];
    
    self.bar.name = @"BINDING";
    NSLog(@"sleep: %@, %@", self.foo.sleep ? @"YES" : @"NO", @(self.foo.sleep));
    XCTAssertTrue(self.foo.sleep == NO);
    
    self.bar.name = @"BINDING_BINDING";
    NSLog(@"sleep: %@, %@", self.foo.sleep ? @"YES" : @"NO", @(self.foo.sleep));
    XCTAssertTrue(self.foo.sleep == YES);
}

- (void)testBinding2 {
    Clown *clown = [Clown new];
    clown.name = @"Clown";
    [PACK(self.foo, friend.name) bind:PACK(clown, name)];
    clown.name = @"ClownClownClown";
    XCTAssertTrue([self.foo.friend.name isEqualToString:clown.name]);
}

- (void)testBinding3 {
    Clown *clown = [Clown new];
    clown.name = @"Clown";
    [PACK(self.foo, sleep) bind:PACK(clown, name)];
}

- (void)testUnbinding {
    Clown *clown = [Clown new];
    
    [PACK(self.foo, friend.name) bind:PACK(clown, name)];
    self.foo.friend.name = @"Bar";

    [PACK(self.foo, friend.name) unbind:PACK(clown, name)];
    clown.name = @"ClownClownClown";
    
    XCTAssertTrue([self.foo.friend.name isEqualToString:@"Bar"]);
}

- (void)testDeadBinding {
//    [PACK(self.bar, name) bind:PACK(self.foo, name)];
//    [PACK(self.foo, name) bind:PACK(self.bar, name)];
//    self.foo.name = @"Fooo";
}

@end
