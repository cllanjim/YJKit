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
    [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew queue:[NSOperationQueue mainQueue] changes:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id newValue, NSDictionary * _Nonnull change) {
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
        [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:[NSOperationQueue new] changes:^(id  _Nonnull receiver, id  _Nonnull target, id newValue, NSDictionary * _Nonnull change) {
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
        [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, id newValue, NSDictionary * _Nonnull change) {
            NSLog(@"CAN NOT PRINT: %@", newValue);
            i++;
        }];
        [foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, id newValue, NSDictionary * _Nonnull change) {
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
    Bar *bar2 = [Bar new];
    
    [self.foo observeGroup:@[ PACK(bar1, name), PACK(bar2, age) ] updates:^(id  _Nonnull receiver, NSArray * _Nonnull targets) {
        
        UNPACK(Bar, bar1)
        UNPACK(Bar, bar2)
        
        if ([bar1.name isEqualToString:@"Bar1"] && bar2.age == 29) {
            XCTAssertTrue(1);
        }
    }];
    
    bar1.name = @"Bar1";
    bar2.age = 29;
}

- (void)testBinding {
    [[[PACK(self.foo, sleep) piped:PACK(self.bar, name)]
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
    [PACK(self.foo, friend.name) piped:PACK(clown, name)];
    
    clown.name = @"ClownClownClown";
    clown.name = @"ClownClownClown";
    XCTAssertTrue([self.bar.name isEqualToString:@"ClownClownClown"]);
}

- (void)testBinding3 {
    Clown *clown = [Clown new];
    clown.name = @"Clown";
    
    [PACK(self.foo, name) piped:PACK(clown, name)];
    [PACK(self.bar, name) piped:PACK(clown, name)];
    
    self.foo.sleep = NO;
    self.foo.awake = NO;
    
    [[PACK(self.foo, sleep) piped:PACK(clown, name)] convert:^id _Nonnull(id  _Nonnull observer, id  _Nonnull target, id  _Nullable newValue) {
        return [newValue length] > 10 ? @YES : @NO;
    }];
    [[PACK(self.foo, awake) piped:PACK(clown, name)] taken:^BOOL(id  _Nonnull observer, id  _Nonnull target, id  _Nullable newValue) {
        return NO;
    }];

    clown.name = @"ClownClownClown";
    
    XCTAssertTrue(self.foo.sleep == YES);
    XCTAssertTrue(self.foo.awake == NO);
    XCTAssertTrue([self.foo.name isEqualToString:@"ClownClownClown"]);
    XCTAssertTrue([self.bar.name isEqualToString:@"ClownClownClown"]);
}

- (void)testDeadBinding {
//    [PACK(self.bar, name) piped:PACK(self.foo, name)];
//    [PACK(self.foo, name) piped:PACK(self.bar, name)];
//    self.foo.name = @"Fooo";
}

- (void)testPipe {
    self.bar.name = @"Barrrr";
    [PACK(self.foo, name) bound:PACK(self.bar, name)];
    XCTAssertTrue([self.foo.name isEqualToString:@"Barrrr"]);
}

- (void)testReady {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    foo.friend = bar;
    bar.name = @"Bar";
    [[PACK(foo, name) piped:PACK(foo, friend.name)] ready];
    XCTAssertTrue([foo.name isEqualToString:@"Bar"]);
}

- (void)testChain {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    Clown *clown = [Clown new];
    
    foo.name = @"Fo";
    [PACK(bar, name) bound:PACK(foo, name)];
    foo.name = @"Foo";
    [PACK(clown, name) bound:PACK(bar, name)];
    foo.name = @"Fooo";
    XCTAssertTrue([clown.name isEqualToString:@"Fooo"]);
}

- (void)testConvert {
    Bar *bar = [Bar new];
    Clown *clown = [Clown new];
    bar.frame = (CGRect){ 1,2,3,4 };
    [[[PACK(clown, size) piped:PACK(bar, frame)] convert:^id _Nonnull(id  _Nonnull observer, id  _Nonnull target, id  _Nullable newValue) {
        CGRect frame = [newValue CGRectValue];
        return [NSValue valueWithCGSize:frame.size];
    }] ready];
    XCTAssertTrue(clown.size.width == 3 && clown.size.height == 4);
}

- (void)testBindPrimitives {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    bar.frame = (CGRect){ 1,2,3,4 };
    [PACK(foo, frame) bound:PACK(bar, frame)];
    XCTAssertTrue(CGRectEqualToRect(foo.frame, (CGRect){ 1,2,3,4 }));
}

- (void)testFlood {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    Clown *clown = [Clown new];
    
    foo.name = @"Foo";
    bar.name = @"Bar";
    
    [PACK(clown, name) flooded:@[ PACK(foo, name),
                                  PACK(bar, name) ]
                      converge:^id(id  _Nonnull observer, NSArray * _Nonnull targets) {
                          
        UNPACK(Foo, foo)
        UNPACK(Bar, bar)
                          
        return [foo.name stringByAppendingString:bar.name];
    }];
    
    NSLog(@"clown.name = %@", clown.name);
    XCTAssertTrue([clown.name isEqualToString:@"FooBar"]);
}

- (void)testFlood2 {
    Foo *foo = [Foo new];
    Bar *bar1 = [Bar new];
    Bar *bar2 = [Bar new];
    Clown *clown = [Clown new];
    
    bar2.name = @"Bar2";
    
    [PACK(clown, size) flooded:@[ PACK(foo, sleep),
                                  PACK(foo, awake),
                                  PACK(bar1, frame),
                                  PACK(bar1, name),
                                  PACK(bar2, name)
                                  ]
                      converge:^id _Nonnull(id  _Nonnull observer, NSArray * _Nonnull targets) {
        
        UNPACK(Foo, foo)
        UNPACK(Bar, bar1)
        UNPACK(Bar, bar2)
        
        BOOL c1 = foo.sleep;
        BOOL c2 = foo.awake;
        BOOL c3 = bar1.name.length;
        BOOL c4 = bar1.frame.size.height;
        BOOL c5 = bar2.name.length > 5;
        
        CGSize size = c1 && c2 && c3 && c4 && c5 ? bar1.frame.size : (CGSize){ 1, 2 };
        return [NSValue valueWithCGSize:size];
    }];
    
    XCTAssertTrue(CGSizeEqualToSize(clown.size, (CGSize){ 1,2 }));
    
    foo.sleep = YES;
    foo.awake = YES;
    bar1.name = @"Bar";
    bar1.frame = (CGRect){ 1,2,3,4 };
    bar2.name = @"Barrrrr";
    
    XCTAssertTrue(CGSizeEqualToSize(clown.size, (CGSize){ 3,4 }));
}

- (void)testEquality {
    Foo *foo = [Foo new];
    Bar *bar1 = [Bar new];
    Clown *clown = [Clown new];
    
    [self observe:PACK(foo, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        
    }];
    [self observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        
    }];
    [self observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        
    }];
    [self observe:PACK(clown, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        
    }];
}

@end
