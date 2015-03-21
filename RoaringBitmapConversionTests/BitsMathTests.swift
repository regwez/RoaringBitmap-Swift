//
//  BitsMathTests.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/20/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit
import XCTest
import RoaringBitmapConversion


class BitsMathTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCountBits() {
//        let testNumbers:[UInt64] = [18446744073709551615]
//        let numberOfBits:[UInt64] = []
//        bits in 1 :1
//        bits in 5 :2
//        bits in 255 :8
//        bitCount64 in 1 :1
//        bitCount64 in 8 :1
//        bitCount64 in 28 :3
        let testTuples:[(number:UInt64,expectedValue:UInt64)] =
        [(number:0,expectedValue:0),(number:1,expectedValue:1),
            (number:5,expectedValue:2),
            (number:255,expectedValue:8),(number:28,expectedValue:3),
            (number:8,expectedValue:1),(number:18446744073709551615,expectedValue:64)]
        
        
        for (number,expectedValue) in testTuples{
            XCTAssertEqual(expectedValue, UInt64(countBits(number)) ,"\(number) has \(expectedValue) bit(s)")
        }

    }

    func testTrailingBits() {
//        trailing (2) = 1
//        trailing (3448068464700000000) = 8
//        trailing (3448068464) = 4
//        trailing (4503599610593280) = 24
//        trailing (3448068464705536) = 46
        
        let testTuples:[(number:UInt64,expectedValue:UInt64)] =
            [(number:0,expectedValue:64),(number:2,expectedValue:1),
                (number:3448068464700000000,expectedValue:8),
                (number:3448068464,expectedValue:4), (number:4503599610593280,expectedValue:24),
            (number:3448068464705536,expectedValue:46)]

        
        for (number,expectedValue) in testTuples{
            XCTAssertEqual(expectedValue, UInt64(numberOfTrailingZeros(number)) ,"\(number) has \(expectedValue) trailingZeros")
        }

    }

}
