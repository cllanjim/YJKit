//
//  YJKVOTest_Swift.swift
//  YJKit
//
//  Created by huang-kun on 16/7/21.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

import XCTest


class YJKVOTest_Swift: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testObserve() {
        let foo = Foo()
        let bar = Bar()
        
        foo.observe(PACK(bar, "name")) { (_, _, newValue) in
            print("\(newValue)")
        }
        
        bar.name = "Bar"
        bar.name = "Barrrrrrr"
    }
    
    func testBind() {
        let foo = Foo()
        let bar = Bar()
        
        PACK(foo, "name").bound(PACK(bar, "name"))
        
        bar.name = "Bar"
        XCTAssert(foo.name == "Bar")
        
        bar.name = "Barrrrrrr"
        XCTAssert(foo.name == "Barrrrrrr")
    }
    
    func testPipe() {
        let foo = Foo()
        let bar = Bar()
        
        PACK(foo, "name").piped(PACK(bar, "name"))
            .taken { (_, _, newValue) -> Bool in
                if let name = newValue as? String {
                    return name.characters.count > 3
                }
                return false
            }
            .convert { (_, _, newValue) -> AnyObject in
                let name = newValue as! String
                return name.uppercaseString
            }
            .after { (_, _) in
                print("value updated.")
            }
            .ready()
        
        bar.name = "Bar"
        XCTAssert(foo.name == nil)

        bar.name = "Barrrr"
        XCTAssert(foo.name == "BARRRR")
    }
    
    func testPost() {
        let foo = Foo()
        var result = ""

        PACK(foo, "name").post { (newValue) in
            if let name = newValue as? String {
                result = name;
            }
        }
        
        foo.name = "foo"
        XCTAssert(result == "foo")
        
        PACK(foo, "name").stop()
        foo.name = "foooooo"
        XCTAssert(result == "foo")
    }
}
