
//
//  ContainerTests.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/19/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit
import XCTest
@testable
import RoaringBitmap

class ContainerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testTransition() {
        var c:Container = ArrayContainer()
        let threshold:UInt16 = 4096
        
        for i in 0..<threshold {
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
   
        for i in 0..<threshold {
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
        XCTAssert(c.contains(UInt16(45)), "contains 45 ")
        XCTAssert(!c.contains(UInt16(5000)), "contains 45 ")
        
        if let uw_c = c.add(threshold){ c = uw_c }
        XCTAssert(c.cardinality == 4097, "c.cardinality == 4097")
        XCTAssert(c is BitmapContainer, "c should be of Type BitmapContainer")
        XCTAssert(c.contains(UInt16(45)), "contains 45 ")
        XCTAssert(!c.contains(UInt16(5000)), "contains 45 ")
        
        if let uw_c = c.remove(threshold){ c = uw_c }
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
        XCTAssert(c.contains(UInt16(45)), "contains 45 ")
        XCTAssert(!c.contains(UInt16(5000)), "contains 45 ")
    }
    
    
    func testContains_1() {
        // Bitmap to bitmap, full range
        
        var c:Container =  BitmapContainer()
        for (var i = 0; i < 65536; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(!c.contains(UInt16( 3)) && c.contains(UInt16(4)),"")

        for (var i = 0; i < 65536; i += 2){
            XCTAssert(c.contains(UInt16(i)) && !c.contains(UInt16 (i + 1)),"")
        }
    }
    
    func testContains_2() {
        // Bitmap to bitmap, full range
        
        var c:Container =  ArrayContainer()
        for (var i = 0; i < ArrayContainer.DEFAULT_MAX_SIZE; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(!c.contains(UInt16( 3)) && c.contains(UInt16(4)),"")
        
        for (var i = 0; i < ArrayContainer.DEFAULT_MAX_SIZE; i += 2){
            XCTAssert(c.contains(UInt16(i)) && !c.contains(UInt16 (i + 1)),"")
        }
    }


    func testContains_3() {
        // Bitmap to bitmap, full range
        
        var c:Container =  ArrayContainer()
        for (var i = 0; i < 65536; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(!c.contains(UInt16( 3)) && c.contains(UInt16(4)),"")
        
        XCTAssert( c.contains(UInt16(8194)) && !c.contains(UInt16( 8195)),"")
        
        XCTAssert( c.contains(UInt16(8238)) && !c.contains(UInt16( 8239)),"")
        
      //  println("==============")
        for (var i = 0; i < 65536; i += 2){
            XCTAssert(c.contains(UInt16(i)), "c.contains(\(i))")
            XCTAssert( !c.contains(UInt16 (i + 1)), "!c.contains(\(i+1))")
//            if !c.contains(UInt16(i)){
//                print("\(i), ")
//            }
        }
//        println("")
//        println("==============")
    }

    
    func testiNot_1() {
        // Array container, range is complete
        let content:[UInt16] = [1, 3, 5, 7, 9]
        var c = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart: 0, rangeEnd: 65535)
        var s = [UInt16](repeating: 0, count: 65536 - content.count)
        var pos = 0
        for i in 0..<65536{
            if content.index(of: UInt16(i)) == nil {
               s[pos++] = UInt16(i)
            }
        }
        XCTAssert(ContainerTests.checkContent(c, s: s), "c.cardinality == 4096")

    }
 
   
    
    func testiNot_10() {
        print("inotTest10");
        // Array container, inverting a range past any set bit
        let content:[UInt16] = [0,2, 4]
        let c = ContainerTests.makeContainer(content)
        let c1 = c.inot(rangeStart: 65190, rangeEnd: 65200)
        XCTAssert(c1 is ArrayContainer, "c1 should be of Type ArrayContainer")
        XCTAssert(c1.cardinality == 14, "c1.cardinality == 14")
        
        let expected:[UInt16] = [0, 2, 4, 65190, 65191,65192, 65193, 65194,  65195,
            65196, 65197, 65198,65199, 65200]
        
        XCTAssert(ContainerTests.checkContent(c1, s: expected), "c1 passed")
    }
    
  
    func testiNot_2() {
        // Array and then Bitmap container, range is complete
        let content:[UInt16] = [1, 3, 5, 7, 9]

        var c = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart: 0, rangeEnd: 65535)
        XCTAssert(c is BitmapContainer, "c should be of Type BitmapContainer")
        c = c.inot(rangeStart: 0, rangeEnd: 65535)
        XCTAssert(ContainerTests.checkContent(c, s: content), "c passed")
    }
    
    
    func testiNot_3() {
        // Bitmap to bitmap, full range
    
        var c:Container =  ArrayContainer()
        for (var i = 0; i < 65536; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(!c.contains(UInt16( 3)) && c.contains(UInt16(4)),"")
        c = c.inot(rangeStart: 0, rangeEnd: 65535)
        XCTAssert(c.contains(UInt16( 3)) && !c.contains(UInt16(4)),"")
        XCTAssertEqual(32768, c.cardinality)
        c = c.inot(rangeStart: 0, rangeEnd: 65535)
        
        print("==============")
        for (var i = 0; i < 65536; i += 2){
            XCTAssert(c.contains(UInt16(i)), "c.contains(\(i))")
            XCTAssert( !c.contains(UInt16 (i + 1)), "!c.contains(\(i+1))")
            if !c.contains(UInt16(i)){
                print("\(i), ")
            }
        }
        print("")
        print("==============")
    }
    
    func testiNot_3_Array() {
        // Bitmap to bitmap, full range
        
        var c:Container =  ArrayContainer()
        for (var i = 0; i < ArrayContainer.DEFAULT_MAX_SIZE; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        XCTAssert(!c.contains(UInt16( 3)) && c.contains(UInt16(4)),"")
        c = c.inot(rangeStart: 0, rangeEnd: ArrayContainer.DEFAULT_MAX_SIZE - 1)
        XCTAssert(c.contains(UInt16( 3)) && !c.contains(UInt16(4)),"")
        XCTAssertEqual(ArrayContainer.DEFAULT_MAX_SIZE / 2, c.cardinality)
        c = c.inot(rangeStart: 0, rangeEnd: ArrayContainer.DEFAULT_MAX_SIZE - 1)
        for (var i = 0; i < ArrayContainer.DEFAULT_MAX_SIZE; i += 2){
            XCTAssert(c.contains(UInt16(i)) && !c.contains(UInt16 (i + 1)),"")
        }
    }
   
    
    
    
    func testiNot_4() {
        // Array container, range is partial, result stays array
        let content:[UInt16] = [1, 3, 5, 7, 9]
        var c:Container = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart: 4, rangeEnd: 999)
        XCTAssert(c is ArrayContainer, "c1 should be of Type ArrayContainer")
        XCTAssertEqual(999 - 4 + 1 - 3 + 2, c.cardinality)
        c = c.inot(rangeStart:4, rangeEnd:999) // back
        XCTAssert(ContainerTests.checkContent(c, s: content))
    }
    
    
    func testiNot_5() {
        // Bitmap container, range is partial, result stays bitmap
        var content = [UInt16](repeating: 0,count: 32768 - 5)
            content[0] = 0
            content[1] = 2
            content[2] = 4
            content[3] = 6
            content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        var c = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart: 4, rangeEnd: 999)
        XCTAssert(c is BitmapContainer,"");
        XCTAssertEqual(31773, c.cardinality,"")
        c = c.inot(rangeStart: 4, rangeEnd: 999); // back, as a bitmap
        XCTAssert(c is BitmapContainer,"")
        XCTAssert(ContainerTests.checkContent(c, s: content))
    
    }
    
    func testiNot_5_noTransition() {
        // Bitmap container, range is partial, result stays bitmap
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        var c = ContainerTests.makeBitmapContainer(content)
        c = c.inot(rangeStart: 4, rangeEnd: 999)
        XCTAssert(c is BitmapContainer,"");
        XCTAssertEqual(31773, c.cardinality,"")
        c = c.inot(rangeStart: 4, rangeEnd: 999); // back, as a bitmap
        XCTAssert(c is BitmapContainer,"")
        XCTAssert(ContainerTests.checkContent(c, s: content))
        
    }
    
    
    
    func testiNot_6() {
           // Bitmap container, range is partial and in one word, result
        // stays bitmap
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        var c = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart:4, rangeEnd:8)
        XCTAssert(c is BitmapContainer);
        XCTAssertEqual(32762, c.cardinality)
        c = c.inot(rangeStart:4, rangeEnd:8) // back, as a bitmap
        XCTAssert(c is BitmapContainer);
        XCTAssert(ContainerTests.checkContent(c, s:content))
    }
    
    
    func testiNot_7() {
        // Bitmap container, range is partial, result flips to array
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        var c = ContainerTests.makeContainer(content)
        
        c = c.inot(rangeStart: 5, rangeEnd: 31000);
        if (c.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            XCTAssert(c is ArrayContainer);
        }else{
            XCTAssert(c is BitmapContainer)
        }
        XCTAssertEqual(1773, c.cardinality)
        c = c.inot(rangeStart: 5, rangeEnd: 31000); // back, as a bitmap
        if (c.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            XCTAssert(c is ArrayContainer)
        }else{
            XCTAssert(c is BitmapContainer)
        }
        XCTAssert(ContainerTests.checkContent(c, s: content))
    }
    
    
    // case requiring contraction of ArrayContainer.
    func testiNot_8() {

        // Array container
        var content = [UInt16](repeating: 0,count: 21)
        for i in 0..<18{
            content[i] = UInt16(i)
        }

        content[18] = 21
        content[19] = 22
        content[20] = 23
        
        var c = ContainerTests.makeContainer(content)
        c = c.inot(rangeStart: 5, rangeEnd: 21);
        XCTAssert(c is ArrayContainer);
        
        XCTAssertEqual(10, c.cardinality);
        c = c.inot(rangeStart: 5, rangeEnd: 21) // back, as a bitmap
        XCTAssert(c is ArrayContainer);
        XCTAssert(ContainerTests.checkContent(c, s:content))
    }
    

    // mostly same tests, except for not. (check original unaffected)
    
    func testNot_1() {
        // Array container, range is complete
        let content:[UInt16] = [1, 3, 5, 7, 9]
        let c = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart: 0, rangeEnd: 65535)
        var s = [UInt16](repeating: 0, count: 65536 - content.count)
        var pos = 0
        for i in 0..<65536{
            if content.index(of: UInt16(i)) == nil {
                s[pos++] = UInt16(i)
            }
        }
        XCTAssert(ContainerTests.checkContent(c1, s: s), "")
        XCTAssert(ContainerTests.checkContent(c, s: content), "")

    }
    
    
    func testNot_10() {

    // Array container, inverting a range past any set bit
    // attempting to recreate a bug (but bug required extra space
    // in the array with just the right junk in it.
        var content = [UInt16](repeating: 0, count: 40)
        for i in 244...283{
            content[i - 244] = UInt16(i)
        }
   
        let c = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart: 51413, rangeEnd: 51470)
        XCTAssert(c1 is ArrayContainer)
        XCTAssertEqual(40 + 58, c1.cardinality)
        
        var rightAns = [UInt16](repeating: 0, count: 98)
        for i in 244...283{
            rightAns[i - 244] = UInt16(i)
        }
        for i in 51413...51470{
            rightAns[i - 51413 + 40] = UInt16(i)
        }

        XCTAssert(ContainerTests.checkContent(c1, s:rightAns))
    }
    
    
    func testNot_11() {
        // Array container, inverting a range before any set bit
        // attempting to recreate a bug (but required extra space
        // in the array with the right junk in it.
        var content = [UInt16](repeating: 0, count: 40)
        for i in 244...283{
            content[i - 244] = UInt16(i)
        }
        
        let c = ContainerTests.makeContainer(content)
        
        let c1 = c.not(rangeStart: 1, rangeEnd: 58)
        XCTAssert(c1 is ArrayContainer)
        XCTAssertEqual(40 + 58, c1.cardinality)
        
        var rightAns = [UInt16](repeating: 0, count: 98)
        for i in 1...58{
            rightAns[i - 1] = UInt16(i)
        }
        for i in 244...283{
            rightAns[i - 244 + 58] = UInt16(i)
        }
        
        XCTAssert(ContainerTests.checkContent(c1, s:rightAns))
    }
    
    
    func testNot_2() {
        // Array and then Bitmap container, range is complete
        let content:[UInt16] = [1, 3, 5, 7, 9]
        
        let c = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart: 0, rangeEnd: 65535)
        let c2 = c1.not(rangeStart: 0, rangeEnd: 65535)
        XCTAssert(ContainerTests.checkContent(c2, s: content), "c passed")
    }
    
    
    func testNot_3() {
        // Bitmap to bitmap, full range
        var c:Container =  ArrayContainer()
        for (var i = 0; i < 65536; i += 2){
            if let uw_c = c.add(UInt16(i)){ c = uw_c }
        }
        
        let c1 = c.not(rangeStart: 0, rangeEnd: 65535)
        XCTAssert(c1.contains(UInt16( 3)) && !c1.contains(UInt16(4)),"")
        XCTAssertEqual(32768, c1.cardinality)
        let c2 = c1.not(rangeStart: 0, rangeEnd: 65535)
        for (var i = 0; i < 65536; i += 2){
            XCTAssert(c2.contains(UInt16(i)) && !c2.contains(UInt16 (i + 1)),"")
        }

    }
    
    
    func testNot_4() {
        // Array container, range is partial, result stays array
        let content:[UInt16] = [1, 3, 5, 7, 9]
        let c:Container = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart: 4, rangeEnd: 999)
        XCTAssert(c1 is ArrayContainer, "c1 should be of Type ArrayContainer")
        XCTAssertEqual(999 - 4 + 1 - 3 + 2, c1.cardinality)
        let c2 = c1.not(rangeStart:4, rangeEnd:999) // back
        XCTAssert(ContainerTests.checkContent(c2, s: content))
    }
    
    
    func testNot_5() {
    
        // Bitmap container, range is partial, result stays bitmap
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        let c = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart: 4, rangeEnd: 999)
        XCTAssert(c1 is BitmapContainer,"");
        XCTAssertEqual(31773, c1.cardinality,"")
        let c2 = c1.inot(rangeStart: 4, rangeEnd: 999); // back, as a bitmap
        XCTAssert(c2 is BitmapContainer,"")
        XCTAssert(ContainerTests.checkContent(c2, s: content))

    }
    
    
    func testNot_6() {
        // Bitmap container, range is partial and in one word, result
        // stays bitmap
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        let c = ContainerTests.makeContainer(content)
        let c1 = c.not(rangeStart:4, rangeEnd:8)
        XCTAssert(c1 is BitmapContainer);
        XCTAssertEqual(32762, c1.cardinality)
        let c2 = c1.not(rangeStart:4, rangeEnd:8) // back, as a bitmap
        XCTAssert(c2 is BitmapContainer);
        XCTAssert(ContainerTests.checkContent(c2, s:content));

    }
    
    
    func testNot_7() {
        // Bitmap container, range is partial, result flips to array
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        let c = ContainerTests.makeContainer(content)
        
        let c1 = c.not(rangeStart: 5, rangeEnd: 31000)
        if (c1.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            XCTAssert(c1 is ArrayContainer);
        }else{
            XCTAssert(c1 is BitmapContainer)
        }
        XCTAssertEqual(1773, c1.cardinality)
        let c2 = c1.not(rangeStart: 5, rangeEnd: 31000); // back, as a bitmap
        if (c2.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            XCTAssert(c2 is ArrayContainer)
        }else{
            XCTAssert(c2 is BitmapContainer)
        }
        XCTAssert(ContainerTests.checkContent(c2, s: content))
    }
    
    
    func testNot_8() {
        // Bitmap container, range is partial on the lower end
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        let c = ContainerTests.makeContainer(content)
        
        let c1 = c.not(rangeStart: 4, rangeEnd: 65535)
        XCTAssert(c1 is BitmapContainer)
        XCTAssertEqual(32773, c1.cardinality)
        
        let c2 = c1.not(rangeStart: 4, rangeEnd: 65535) // back, as a bitmap
        XCTAssert(c2 is BitmapContainer)
        XCTAssert(ContainerTests.checkContent(c2, s: content))
    }
    
    
    func testNot_9() {
        // Bitmap container, range is partial on the upper end, not
        // single wordbb    
        var content = [UInt16](repeating: 0,count: 32768 - 5)
        content[0] = 0
        content[1] = 2
        content[2] = 4
        content[3] = 6
        content[4] = 8
        for (var i = 10; i <= 32767; i += 1){
            content[i - 10 + 5] = UInt16(i)
        }
        let c = ContainerTests.makeContainer(content)
        
        let c1 = c.not(rangeStart: 0, rangeEnd: 65200)
        XCTAssert(c1 is BitmapContainer)
        XCTAssertEqual(32438, c1.cardinality)
        
        let c2 = c1.not(rangeStart: 0, rangeEnd: 65200) // back, as a bitmap
        XCTAssert(c2 is BitmapContainer)
        XCTAssert(ContainerTests.checkContent(c2, s: content))
    }
    
    
    func testRangeOfOnes_1() {
        let c = ContainerDispatcher.rangeOfOnes(4, lastIndex: 10) // sparse
        XCTAssert(c is ArrayContainer)
        XCTAssertEqual(10 - 4 + 1, c.cardinality)
        let expextedValues:[UInt16] = [4, 5, 6, 7, 8, 9, 10]
        XCTAssert(ContainerTests.checkContent(c, s:expextedValues))
    }
    

    func testRangeOfOnes_2() {
        let  c = ContainerDispatcher.rangeOfOnes(1000, lastIndex: 35000) // dense
        XCTAssert(c is BitmapContainer, "")
        XCTAssertEqual(35000 - 1000 + 1, c.cardinality,"")
    }
    
    func testRangeOfOnes_2A() {
        let  c = ContainerDispatcher.rangeOfOnes(1000, lastIndex: 35000) // dense
        var s = [UInt16](repeating: 0, count: 35000 - 1000 + 1)
        for (var i = 1000; i <= 35000; i += 1){
            s[i - 1000] = UInt16(i)
        }
   
        XCTAssert(ContainerTests.checkContent(c, s: s), "c passed")
    }
    
    
    
    func testRangeOfOnes_3() {
        // bdry cases
        let c = ContainerDispatcher.rangeOfOnes(1, lastIndex: ArrayContainer.DEFAULT_MAX_SIZE)
        XCTAssert(c is ArrayContainer, "")
    }
    
    
    
    func testRangeOfOnes_4() {
        let c = ContainerDispatcher.rangeOfOnes(1, lastIndex: ArrayContainer.DEFAULT_MAX_SIZE + 1)
        XCTAssert(c is BitmapContainer, "")
    }
  

    static func checkContent(_ c:Container , s:[UInt16]) ->Bool{
        let si = c.sequence
        var ctr = 0
        var fail = false
        for siItem in si{
            if (ctr == s.count) {
                fail = true
                break
            }
            if (siItem != s[ctr]) {
                fail = true
                break
            }
            ++ctr
        }

        if (ctr != s.count) {
            fail = true
        }
        if (fail) {
            print("============== fail, found ==================")
            let siPrint = c.sequence
            for siItem in siPrint{
                print(" \(siItem)")
            }
            print("\n expected ")
            for s1 in s{
                print(" \(s1)")
            }
            print("")
            print("============== End fail ==================")
        }
        return !fail;
    }
    

    static func  makeContainer(_ ss:[UInt16]) -> Container{
        var c:Container =  ArrayContainer()
        for s in ss{
            if let uw_c = c.add(s){ c = uw_c }
        }
        return c
    }
    
    static func  makeBitmapContainer(_ ss:[UInt16]) -> Container{
        var c:Container =  BitmapContainer()
        for s in ss{
            if let uw_c = c.add(s){ c = uw_c }
        }
        return c
    }
    
}
