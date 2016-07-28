//
//  YJTupleTest.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YJObjectCombination.h"
#import "YJUnsafeObjectCombinator.h"

@interface YJTupleTest : XCTestCase

@end

@implementation YJTupleTest

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

- (void)testYJUnsafeObjectCombinatorMacro {
    YJUnsafeObjectCombinator *tuple = YJUnsafeObjectCombinatorPack(@1,@2,@3);
    XCTAssertTrue([tuple.first isEqualToNumber:@1]);
    XCTAssertTrue([tuple[1] isEqualToNumber:@2]);
    XCTAssertTrue([tuple[2] isEqualToNumber:@3]);
    XCTAssertTrue(tuple.fourth == nil);
    XCTAssertTrue(tuple.fifth == nil);
}

- (void)testYJUnsafeObjectCombinatorMacro1 {
    YJUnsafeObjectCombinator *tuple = YJUnsafeObjectCombinatorPack(@1,@2,@3,@4,@5,@6,@7,@8,@9,@10);
    XCTAssertTrue([tuple.tenth isEqualToNumber:@10]);
}

@end
