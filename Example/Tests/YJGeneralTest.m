//
//  YJGeneralTest.m
//  YJKit
//
//  Created by huang-kun on 16/5/20.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "NSString+YJCompatible.h"

@interface YJGeneralTest : XCTestCase

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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testContainsString {
//    id str = nil;
//    XCTAssertTrue([@"hello world" containsString:(id)str] == NO);

    XCTAssertTrue([@"hello world" containsString:@""] == NO);
    XCTAssertTrue([@"" containsString:@""] == NO);
    XCTAssertTrue([@"" containsString:@"1"] == NO);
    XCTAssertTrue([@"hello" containsString:@"hello world"] == NO);
    XCTAssertTrue([@"hello world" containsString:@"hello"]);
    XCTAssertTrue([@"hello world" containsString:@"hello!"] == NO);
    XCTAssertTrue([@"hello world" containsString:@"ll"]);
    XCTAssertTrue([@"hello world" containsString:@"lli"] == NO);
    XCTAssertTrue([@"hello world" containsString:@"world"]);
    XCTAssertTrue([@"!@#$%^&*" containsString:@"^&*!"] == NO);
    XCTAssertTrue([@"hello world" containsString:@" "]);
    XCTAssertTrue([@" " containsString:@" "]);
    XCTAssertTrue([@"  " containsString:@" "]);

}

@end
