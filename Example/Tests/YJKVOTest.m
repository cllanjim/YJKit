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
#import "NSObject+YJKVOExtension.h"
#import "_YJKVOSubscriberManager.h"
#import "_YJKVOPorterManager.h"

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
    __block NSString *nilValue = nil;
    [self.foo observe:PACK(self.bar, name) updates:^(Foo *  _Nonnull foo, Bar *  _Nonnull bar, id  _Nullable newValue) {
        nilValue = newValue;
    }];
    XCTAssertTrue(nilValue == nil);
}

- (void)testPublicReadonlyProperty {
    __block NSString *value = nil;
    
    Bar *bar = [Bar new];
    Foo *foo = [Foo new];
    
    [bar observe:PACK(foo, privateName) updates:^(Bar *bar, Foo *foo, NSString *privateName) {
        value = privateName;
    }];
    
    [foo addPrivateName];
    XCTAssertTrue([value isEqualToString:foo.privateName]);
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
    __block int m = 0;
    __block int n = 0;
    __block int a = 0;
    __block int b = 0;
    __block int c = 0;
    
    Foo *foo = [Foo new];
    Clown *clown = [Clown new];
    
    [self.foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, id newValue, NSDictionary * _Nonnull change) {
        i++;
    }];
    [foo observe:PACK(self.bar, name) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, id newValue, NSDictionary * _Nonnull change) {
        n++;
    }];
    [self.foo observe:PACK(self.bar, age) options:NSKeyValueObservingOptionNew queue:nil changes:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue, NSDictionary * _Nonnull change) {
        m++;
    }];
    [foo observe:PACK(clown, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        a++;
    }];
    [self.foo observe:PACK(clown, name) updates:^(Foo *foo, Clown *clown, NSString *name) {
        b++;
    }];
    [self.foo observe:PACK(clown, size) updates:^(Foo *foo, Clown *clown, NSValue *sizeValue) {
        c++;
    }];
    
    [self.foo unobserve:PACK(self.bar, name)];
    [self.foo unobserve:PACK(clown, size)];
    [foo unobserveAll];
    
    self.bar.name = @"Baaar";
    self.bar.age = 10;
    clown.name = @"Clown";
    clown.size = (CGSize){ 1,2 };
    
    XCTAssertTrue(i == 0);
    XCTAssertTrue(m == 1);
    XCTAssertTrue(n == 0);
    XCTAssertTrue(a == 1);
    XCTAssertTrue(b == 2);
    XCTAssertTrue(c == 1);
}

- (void)testRetainCycleBreaks {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    __weak id weakFoo = foo;
    __weak id weakBar = bar;
    
    bar.name = @"Bar";
    [foo observeTarget:bar keyPath:@"name" updates:^(Foo *foo, Bar *bar, id  _Nullable newValue) {
        foo.name = newValue;
        NSLog(@"Hello %@", bar);
    }];
    foo = nil;
    bar = nil;
    
    XCTAssertTrue(weakFoo == nil);
    XCTAssertTrue(weakBar == nil);
}

- (void)testKVOSelf {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    __weak id weakFoo = foo;
    __weak id weakBar = bar;
    
    bar.name = @"Barrrr";
    
    @autoreleasepool {
        [foo observe:PACK(foo, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            NSLog(@"foo's name: %@", newValue);
        }];
        foo = nil;
    }
    
    [bar observeTarget:bar keyPath:@"name" updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
        NSLog(@"bar's name: %@", newValue);
    }];
    bar = nil;
    
    XCTAssertTrue(weakFoo == nil);
    XCTAssertTrue(weakBar == nil);
}

- (void)testMultipleObservedTargets {
    Foo *foo1 = [Foo new];
    Foo *foo2 = [Foo new];
    Bar *bar1 = [Bar new];
    Bar *bar2 = [Bar new];
    Bar *bar3 = [Bar sharedBar];
    
    __weak id weakFoo1 = foo1;
    __weak id weakFoo2 = foo2;
    __weak id weakBar1 = bar1;
    __weak id weakBar2 = bar2;
    
    @autoreleasepool {
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
    }
    
    NSLog(@"");
    
    foo1 = nil;
    XCTAssertTrue(weakFoo1 == nil);
    XCTAssertTrue(weakFoo2 != nil);
    XCTAssertTrue(weakBar1 != nil);
    
    bar2 = nil;
    XCTAssertTrue(weakBar2 == nil);
    XCTAssertTrue(weakFoo2 != nil);
    
    foo2 = nil;
    NSLog(@"");

    XCTAssertTrue(weakFoo2 == nil);

    bar1 = nil;
    XCTAssertTrue(weakBar1 == nil);
    
    NSLog(@"");
}

- (void)testObserveEachOther {
    Foo *foo1 = [Foo new];
    Bar *bar1 = [Bar new];
    
    __weak id weakFoo1 = foo1;
    __weak id weakBar1 = bar1;
    
    @autoreleasepool {
        [foo1 observe:PACK(bar1, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            NSLog(@"%@ - %@", target, newValue);
        }];
        [bar1 observe:PACK(foo1, friend) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            NSLog(@"%@ - %@", target, newValue);
        }];
    }
    
    foo1 = nil; // foo1 release before bar1
    bar1 = nil;
    
    XCTAssertTrue(weakFoo1 == nil);
    XCTAssertTrue(weakBar1 == nil);
    
    
    Foo *foo2 = [Foo new];
    Bar *bar2 = [Bar new];
    
    __weak id weakFoo2 = foo2;
    __weak id weakBar2 = bar2;
    
    @autoreleasepool {
        [foo2 observe:PACK(bar2, name) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            NSLog(@"%@ - %@", target, newValue);
        }];
        [bar2 observe:PACK(foo2, friend) updates:^(id  _Nonnull receiver, id  _Nonnull target, id  _Nullable newValue) {
            NSLog(@"%@ - %@", target, newValue);
        }];
    }
    
    bar2 = nil; // bar2 release before foo2
    foo2 = nil;
    
    XCTAssertTrue(weakFoo2 == nil);
    XCTAssertTrue(weakBar2 == nil);
}

- (void)testGroupKVO {
    Bar *bar1 = [Bar new];
    Bar *bar2 = [Bar new];
    
    __block BOOL result = NO;
    
    [self.foo observeGroup:@[ PACK(bar1, name), PACK(bar2, age) ] updates:^(id  _Nonnull receiver, NSArray * _Nonnull targets) {
        
        UNPACK(Bar, bar1)
        UNPACK(Bar, bar2)
        
        if ([bar1.name isEqualToString:@"Bar1"] && bar2.age == 29) {
            result = YES;
        }
    }];
    
    bar1.name = @"Bar1";
    bar2.age = 29;
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    XCTAssertTrue(result == YES);
}

- (void)testBinding {
    [[[PACK(self.foo, sleep) piped:PACK(self.bar, name)]
     convert:^id _Nonnull(id  _Nonnull subscriber, id  _Nonnull target, NSString *newValue) {
        return @(newValue.length < 10 ? NO : YES);
    }]
     after:^(id  _Nonnull subscriber, id  _Nonnull target) {
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
    
    __weak id weakClown = clown;
    
    @autoreleasepool {
        [PACK(self.foo, friend.name) piped:PACK(clown, name)];
    }
    
    clown.name = @"ClownClownClown";
    clown.name = @"ClownClownClown";
    XCTAssertTrue([self.bar.name isEqualToString:@"ClownClownClown"]);
    
    clown = nil;
    XCTAssertTrue(weakClown == nil);
}

- (void)testBinding3 {
    Clown *clown = [Clown new];
    clown.name = @"Clown";
    
    [PACK(self.foo, name) piped:PACK(clown, name)];
    [PACK(self.bar, name) piped:PACK(clown, name)];
    
    self.foo.sleep = NO;
    self.foo.awake = NO;
    
    [[PACK(self.foo, sleep) piped:PACK(clown, name)] convert:^id _Nonnull(id  _Nonnull subscriber, id  _Nonnull target, id  _Nullable newValue) {
        return [newValue length] > 10 ? @YES : @NO;
    }];
    [[PACK(self.foo, awake) piped:PACK(clown, name)] taken:^BOOL(id  _Nonnull subscriber, id  _Nonnull target, id  _Nullable newValue) {
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
    [[[PACK(clown, size) piped:PACK(bar, frame)] convert:^id _Nonnull(id  _Nonnull subscriber, id  _Nonnull target, id  _Nullable newValue) {
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
                      converge:^id(id  _Nonnull subscriber, NSArray * _Nonnull targets) {
                          
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
                      converge:^id _Nonnull(id  _Nonnull subscriber, NSArray * _Nonnull targets) {
        
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
    
    NSLog(@"flood test - clown.size = %@", NSStringFromCGSize(clown.size));
    XCTAssertTrue(CGSizeEqualToSize(clown.size, (CGSize){ 3,4 }));
}

- (void)testEqualityCrashPreventionAndUntrack {
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
    
    [self unobserveAll];
    
    NSUInteger count1 = [[foo.yj_KVOSubscriberManager valueForKey:@"_subscribers"] count];
    XCTAssertTrue(count1 == 0);
    NSUInteger count2 = [[bar1.yj_KVOSubscriberManager valueForKey:@"_subscribers"] count];
    XCTAssertTrue(count2 == 0);
    NSUInteger count3 = [[clown.yj_KVOSubscriberManager valueForKey:@"_subscribers"] count];
    XCTAssertTrue(count3 == 0);
    
    NSUInteger count4 = [[self.yj_KVOPorterManager valueForKey:@"_porters"] count];
    XCTAssertTrue(count4 == 0);
}

- (void)testPost {
    Foo *foo = [Foo new];
    __weak Foo *weakFoo = foo;
    
    __block int i = 0;
    __block int j = 0;
    
    @autoreleasepool {
        [PACK(foo, name) post:^(id self, NSString *name) {
            NSLog(@"%@'s name: %@", weakFoo, name);
            i++;
        }];
        
        [PACK(foo, sleep) post:^(id self, NSValue *value) {
            NSLog(@"%@ sleep: %@", weakFoo, value);
            j++;
        }];
    }
    
    foo.name = @"Foo";
    foo.sleep = YES;
    
    @autoreleasepool {
        [PACK(foo, name) stopPosting];
    }
    
    foo.name = @"foooooo";
    foo.sleep = NO;
    
    XCTAssertTrue(i == 2);
    XCTAssertTrue(j == 3);
    
    foo = nil;
    
    XCTAssertTrue(weakFoo == nil);
}

- (void)testPost2 {
    Clown *clown = [Clown new];
    __weak Clown *weakClown = clown;
    [clown testKVOPost];
    clown = nil;
    XCTAssertTrue(weakClown == nil);
}

- (void)testPost3 {
    Foo *foo = [Foo new];
    Clown *clown = [Clown new];
    
    __weak Foo *weakFoo = foo;
    __weak Clown *weakClown = clown;
    
    [foo testKVOPost];
    [clown testKVOPost];
    
    [Bar sharedBar].name = @"SharedBar";
    
    id subscriberManager = [[Bar sharedBar] valueForKey:@"yj_KVOSubscriberManager"];
    XCTAssertTrue([subscriberManager numberOfSubscribers] == 2);
    
    foo = nil;
    clown = nil;
    
    XCTAssertTrue([subscriberManager numberOfSubscribers] == 0);
    
    XCTAssertTrue(weakFoo == nil);
    XCTAssertTrue(weakClown == nil);
}

- (void)testCutOff {
    Foo *foo = [Foo new];
    Bar *bar = [Bar new];
    
    [PACK(foo, name) bound:PACK(bar, name)];
    [PACK(foo, nickname) bound:PACK(bar, name)];
    
    bar.name = @"Bar";
    
    XCTAssertTrue([foo.name isEqualToString:@"Bar"]);
    XCTAssertTrue([foo.nickname isEqualToString:@"Bar"]);
    
    [PACK(foo, name) cutOff:PACK(bar, name)];
    
    bar.name = @"NewBar";
    
    XCTAssertTrue([foo.name isEqualToString:@"Bar"]);
    XCTAssertTrue([foo.nickname isEqualToString:@"NewBar"]);
    
    [PACK(foo, nickname) cutOff:PACK(bar, name)];
    
    bar.name = @"FreshBar";
    
    XCTAssertTrue([foo.name isEqualToString:@"Bar"]);
    XCTAssertTrue([foo.nickname isEqualToString:@"NewBar"]);
}

@end
