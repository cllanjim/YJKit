//
//  YJGeneralTest.m
//  YJKit
//
//  Created by huang-kun on 16/5/20.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "YJCircularImageView.h"
#import "NSObject+YJRuntimeEncapsulation.h"
#import "YJUIMacros.h"

@interface YJGeneralTest : XCTestCase

@end

@interface Foo : NSObject
- (void)sayHello;
- (void)sayHi;
@end

@implementation Foo
- (void)sayHello {
    NSLog(@"Hello, Foo");
}
- (void)sayHi {
    NSLog(@"Hi, Foo");
}
@end

@interface Subfoo : Foo
@end

@implementation Subfoo
- (void)sayHello {
    NSLog(@"Hello, Subfoo");
}
@end

@implementation YJGeneralTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

void test(Class class) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(class, &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        NSLog(@"%@", NSStringFromSelector(sel));
    }
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//    Hi *hi = [Hi new];
    Subfoo *foo = [Subfoo new];
//    [Foo insertImplementationBlocksIntoClassMethodForSelector:@selector(hi) identifier:@"yahoo" before:^(id  _Nonnull receiver) {
//        NSLog(@"yahoo before hi");
//    } after:^(id  _Nonnull receiver) {
//        NSLog(@"yahoo after hi");
//    }];
    
//    [foo insertImplementationBlocksIntoInstanceMethodForSelector:@selector(sayHi)
//                                                      identifier:@"TEST"
//                                                          before:^(id  _Nonnull receiver) {
//                                                             NSLog(@"Run before");
//                                                          } after:^(id  _Nonnull receiver) {
//                                                             NSLog(@"Run after");
//                                                          }];
//    
//    [foo sayHi];
    
//    NSLog(@"--------- array ---------");
//
//    test([NSArray class]);
//    
//    NSLog(@"--------- mutable array ---------");
//
//    test([NSMutableArray class]);

    
    NSLog(@"");
//    YJCircularImageView *imageView = [[YJCircularImageView alloc] initWithFrame:CGRectMake(0,0,100,100)];
//    imageView.circleColor = [UIColor redColor];
//    imageView.circleWidth = 5.0;
//    [imageView setValue:@YES forKey:@"_didFirstLayout"];
//    [imageView setValue:@NO forKey:@"_forceMaskColor"];
//    [imageView setValue:[NSValue valueWithCGRect:(CGRect){1,2,3,4}] forKey:@"_transparentFrame"];
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imageView];
//    id newView = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
