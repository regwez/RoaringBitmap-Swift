//
//  RoaringBitmapTests.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/19/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit
import XCTest
@testable
import RoaringBitmapConversion

class RoaringBitmapTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testXORSimple() {
        let a = RoaringBitmap.bitmapOf([73647, 83469])
        let b = RoaringBitmap.bitmapOf([1, 2, 3, 5, 6, 8, 9, 10, 11, 13, 14, 16, 17, 18, 19, 20, 21, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 39, 40, 41, 50, 51, 69, 79, 80, 81, 88, 89, 172])
        let rxor = RoaringBitmap.xor(lhs: a, rhs: b)
        let ror = RoaringBitmap.or(lhs: a, rhs: b)
        XCTAssert(rxor == ror, "rxor == ror")
       
    }
        
        
    func testRank() {
        let rb = RoaringBitmap()
        for(var k:UInt32 = 0; k < 100000; k += 7){
            rb.add(k)
        }
        for(var k:UInt32 = 100000; k < 200000; k += 1000){
            rb.add(k)
        }
        for(k:UInt32 in 0 ..< 100000 += 1) {
            XCTAssert(1 + k/7 == rb.rank(upperLimit: k)," rank 7 Pass")
        }
        
        let constant:UInt32 = UInt32(1 + 100000/7 + 1)
        for(k:UInt32 in 100000 ..< 200000 += 1) {
            XCTAssert(constant + (k - 100000)/1000 == rb.rank(upperLimit: k)," rank 1000 Pass")
        }
    }
        

        
        func testSelect() {
            let w:UInt64 = ~0
            for k:UInt32 in 0..<64 {
                XCTAssert(Int(k) == selectBit(word: w, bitIndex: k),"")
            }
            for k:UInt32 in 0..<64 {
                let wk = UInt64(1) << UInt64(k)
                XCTAssert(Int(k) == selectBit(word: wk, bitIndex: 0),"")
            }
       
            for k:UInt32 in 1..<64 {
                let wk = (UInt64(1) << UInt64(k)) + 1
                let bit = selectBit(word: wk, bitIndex: 1)
               // println("======= \(k) \(bit) \(wk)")
                XCTAssertEqual(Int(k), bit,"")
            }

        
                XCTAssertEqual(0, selectBit(word:UInt64(1), bitIndex:0),"")
            XCTAssertEqual(0,selectBit(word:UInt64(5), bitIndex:0),"")
            XCTAssertEqual(2,selectBit(word:UInt64(5), bitIndex:1),"")

            for (var gap:UInt32 = 1; gap <= 1024; gap *= 2) {
                let rb = RoaringBitmap()
                for (var k:UInt32 = 0; k < 100000; k += gap){
                    rb.add(k)
                }
                for (k:UInt32 in 0 ..< 100000 / gap += 1) {
                    XCTAssertEqual(k * gap, rb.select(atIndex: k),"")
                }
            }
    }



    func testLimit() {
        for (var gap:UInt32 = 1; gap <= 1024; gap *= 2) {
            let rb = RoaringBitmap()
            for (var k:UInt32 = 0; k < 100000; k += gap){
                rb.add(k)
            }
            let thiscard = UInt32(rb.cardinality)
            for (var k:UInt32 = 0; k < thiscard; k+=100) {
                let limited = rb.limit(maxCardinality: k)
                XCTAssertEqual(limited.cardinality,Int(k))
            }
            XCTAssertEqual(rb.limit(maxCardinality: thiscard).cardinality,Int(thiscard))
            XCTAssertEqual(rb.limit(maxCardinality: thiscard+1).cardinality,Int(thiscard))
        }
    }


    func testHorizontalOrCardinality() {
        let vals:[UInt32] = [65535,131071,196607,262143,327679,393215,458751,524287]
        var b = [RoaringBitmap]()
        b.append( RoaringBitmap.bitmapOf(vals))
        b.append( RoaringBitmap.bitmapOf(vals))
        let a = FastAggregation.horizontal_or(b)
        XCTAssertEqual(8, a!.cardinality);
    }



    func testContains()  {
        let rbm1 = RoaringBitmap()
        for(k:UInt32 in 0 ..< 1000 += 1) {
            rbm1.add(17 * k)
        }
        for(k:UInt32 in 0 ..< 17*1000 += 1) {
            XCTAssert(rbm1.contains(k) == (k/17*17==k))
        }
    }

    
    func testContains2()  {
        let rr = RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            rr.add(k)
        }

        //now test
        for (k:UInt32 in 4000 ..< 4256 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            XCTAssert(rr.contains(k))
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            XCTAssert(rr.contains(k))
        }

    }

    func testHash() {
        let rbm1 = RoaringBitmap()
        rbm1.add(17)
        var rbm2 = RoaringBitmap()
        rbm2.add(17)
        XCTAssert(rbm1.hashValue == rbm2.hashValue)
        rbm2 = rbm1.clone()
        XCTAssert(rbm1.hashValue == rbm2.hashValue)
    }

    

    func testANDNOT() {
        let rr =  RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            rr.add(k)
        }
        
        let rr2 =  RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in UInt32(3 * 65536 + 2000) ..< UInt32(3 * 65536 + 6000) += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 10 * 65535 ..< 10 * 65535 + 5000 += 1) {
            rr2.add(k);
        }
        let correct = RoaringBitmap.andNot(lhs:rr, rhs:rr2)
        rr.andNot(rhs: rr2)
        XCTAssert(correct == rr)
    }

    func testAndNot_4() {
        let  rb =  RoaringBitmap()
        let  rb2 =  RoaringBitmap()
        
        for (var i:UInt32 = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        rb2.cardinality
        
        // check or against an empty bitmap
        let andNotresult = RoaringBitmap.andNot(lhs: rb, rhs: rb2)
        
        let off = RoaringBitmap.andNot(lhs: rb2, rhs: rb)
        
        XCTAssertEqual(rb, andNotresult)
        XCTAssertEqual(rb2, off)
        rb2.andNot(rhs: rb)
        XCTAssertEqual(rb2, off)
        
    }


    func testAnd_0() {
        let rr =  RoaringBitmap()
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        
        let rr2 = RoaringBitmap()
        rr2.add(13)
        let rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
        var array = rrand.asArray
        
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)
        rr.and(rhs: rr2)
        array = rr.asArray
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)
        
    }


    func testAnd_1() {
        let rr =  RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            rr.add(k)
        }
        
        let rr2 =  RoaringBitmap();
        for (k:UInt32 in 4000 ..< 4256 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in UInt32(3 * 65536 + 2000) ..< UInt32(3 * 65536 + 6000) += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 10 * 65535 ..< 10 * 65535 + 5000 += 1) {
            rr2.add(k);
        }
        let correct = RoaringBitmap.and(lhs:rr, rhs:rr2)
        rr.and(rhs: rr2)
        XCTAssert(correct == rr)

    }


    func testAnd_2() {
        let rr =  RoaringBitmap()
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        
        let rr2 = RoaringBitmap()
        rr2.add(13)
        let rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
        
        var array = rrand.asArray
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)

    }


   
    
func testAnd_3() {
    var arrayand = [UInt32](repeating: 0, count: 11256)
    var pos = 0
    
    let rr =  RoaringBitmap()
    for (k:UInt32 in 4000 ..< 4256 += 1){
        rr.add(k);
    }
    for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
        rr.add(k);
    }
    for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 1000 += 1){
        rr.add(k);
    }
    for (k:UInt32 in UInt32(3 * 65536 + 1000) ..< UInt32(3 * 65536 + 7000) += 1){
        rr.add(k);
    }
    for (k:UInt32 in UInt32(3 * 65536 + 7000) ..< UInt32(3 * 65536 + 9000) += 1){
        rr.add(k);
    }
    for (k:UInt32 in 4 * 65536 ..< 4 * 65536 + 7000 += 1){
        rr.add(k);
    }
    for (k:UInt32 in 6 * 65536 ..< 6 * 65536 + 10000 += 1){
        rr.add(k);
    }
    for (k:UInt32 in 8 * 65536 ..< 8 * 65536 + 1000 += 1){
        rr.add(k);
    }
    for (k:UInt32 in 9 * 65536 ..< 9 * 65536 + 30000 += 1){
        rr.add(k);
    }
    

    let rr2 =  RoaringBitmap()
    for (k:UInt32 in 4000 ..< 4256 += 1) {
        rr2.add(k);
        arrayand[pos++] = k
    }
    for (k:UInt32 in 65536 ..< 65536 + 4000 += 1) {
        rr2.add(k);
        arrayand[pos++] = k
    }
    for (k:UInt32 in UInt32(3 * 65536 + 1000) ..< UInt32(3 * 65536 + 7000) += 1) {
        rr2.add(k);
        arrayand[pos++] = k
    }
    for (k:UInt32 in 6 * 65536 ..< 6 * 65536 + 1000 += 1) {
        rr2.add(k);
        arrayand[pos++] = k
    }
    for (k:UInt32 in 7 * 65536 ..< 7 * 65536 + 1000 += 1) {
        rr2.add(k);
    }
    for (k:UInt32 in 10 * 65536 ..< 10 * 65536 + 5000 += 1) {
        rr2.add(k);
    }

    
    let rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
    
    let arrayres = rrand.asArray
    
    for i in 0..<arrayres.count{
        if (arrayres[i] != arrayand[i]){
            print("error at index(\(i) expected= \(arrayand[i])  but got \(arrayres[i])")
        }
    }
    
    
    XCTAssert(arrayand == arrayres)
    
}


    func testAnd_4() {
        let rb = RoaringBitmap()
        let rb2 = RoaringBitmap()
        
        for (var i:UInt32 = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        
        // check or against an empty bitmap
        let andresult = RoaringBitmap.and(lhs: rb, rhs: rb2)
        let off = RoaringBitmap.and(lhs: rb2, rhs: rb)
        XCTAssert(andresult == off)
        
        XCTAssertEqual(0, andresult.cardinality)
        
        for (var i:UInt32 = 500000; i < 600000; i += 14){
            rb.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 3){
            rb2.add(i)
        }
        // check or against an empty bitmap
        let andresult2 = RoaringBitmap.and(lhs: rb, rhs: rb2)
        XCTAssertEqual(0, andresult.cardinality)
        
        XCTAssertEqual(0, andresult2.cardinality)
        for (var i:UInt32 = 0; i < 200000; i += 4){
            rb.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb.add(i)
        }
        XCTAssertEqual(0, andresult.cardinality)
        let rc = RoaringBitmap.and(lhs: rb, rhs: rb2)
        rb.and(rhs: rb2)
        XCTAssertEqual(rc.cardinality, rb.cardinality)
        
    }


    func testArrayContainerCardinality() {
        let ac:Container = ArrayContainer()
        for (k:UInt16 in 0 ..< 100 += 1) {
            ac.add(k)
            XCTAssertEqual(ac.cardinality, Int(k + 1))
        }
        for (k:UInt16 in 0 ..< 100 += 1) {
            ac.add(k)
            XCTAssertEqual(ac.cardinality, 100)
        }
    }



    func testTrimArrayContainerCardinality() {
        
        autoreleasepool { () -> () in
            let ac = ArrayContainer()
            ac.trim()
            for k:UInt16 in 0..<100{
                ac.add(k)
                ac.trim()
                XCTAssertEqual(ac.cardinality, Int(k + 1))
            }
            for k:UInt16 in 0..<100{
                ac.add(k)
                ac.trim()
                XCTAssertEqual(ac.cardinality, 100)
            }
        }
    }

    

    func testArray() {
        let rr = ArrayContainer()
        rr.add(UInt16(110))
        rr.add(UInt16(114))
        rr.add(UInt16(115))
        var array = [UInt16](repeating: 0, count: 3)
        var pos = 0
        for i in rr{
            array[pos++] = i
        }
        XCTAssertEqual(array[0], UInt16(110))
        XCTAssertEqual(array[1], UInt16(114))
        XCTAssertEqual(array[2], UInt16(115))
    }


    func testBasic() {
        let rr = RoaringBitmap()
        var a = [UInt32](repeating: 0, count: 4002)
        var pos = 0
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr.add(k)
            a[pos++] = k
        }
        rr.add(100000)
        a[pos++] = 100000
        rr.add(110000)
        a[pos++] = 110000
        let array = rr.asArray
        for (var i = 0; i < array.count; i += 1){
            if (array[i] != a[i]){
            print("rr : \(array[i]) a : \(a[i])")
            }
        }
        
        XCTAssert(array == a)
    }


    func testBitmapContainerCardinality() {
        let ac = BitmapContainer()
        for k:UInt16 in 0..<100{
            ac.add(k)
            XCTAssertEqual(ac.cardinality, Int(k + 1))
        }
        for k:UInt16 in 0..<100{
            ac.add(k)
            XCTAssertEqual(ac.cardinality, 100)
        }
    }
    
    func testBitmap() {
        let rr = BitmapContainer()
        rr.add(UInt16(110))
        rr.add(UInt16(114))
        rr.add(UInt16(115))
        var array = [UInt16](repeating: 0, count: 3)
        var pos = 0
        for i in rr{
            array[pos++] = i
        }
        XCTAssertEqual(array[0], UInt16(110))
        XCTAssertEqual(array[1], UInt16(114))
        XCTAssertEqual(array[2], UInt16(115))
    }



    
    func testCardinality() {
        let N:UInt32 = 1024
        for (var gap:UInt32 = 7; gap < 7000/*100000*/; gap *= 10) {
            for (var offset:UInt32 = 2; offset <= 1024; offset *= 2) {
                let rb = RoaringBitmap()
                // check the add of values
                for (k:UInt32 in 0 ..< N) {
                    rb.add(k * gap)
                    XCTAssertEqual(rb.cardinality, Int(k + 1))
                }
                XCTAssertEqual(rb.cardinality, Int(N))
                // check the add of existing values
                for (k:UInt32 in 0 ..< N) {
                    rb.add(k * gap)
                    XCTAssertEqual(rb.cardinality, Int(N))
                }
                
                let rb2 = RoaringBitmap()
                
                for (k1:UInt32 in 0 ..< N) {
                    let value = k1 * gap * offset
                    rb2.add(value)
                    XCTAssertEqual(rb2.cardinality, Int(k1 + 1))
                }
                
                XCTAssertEqual(rb2.cardinality, Int(N))
                
                for (k:UInt32 in 0 ..< N) {
                    rb2.add(k * gap * offset)
                    XCTAssertEqual(rb2.cardinality, Int(N))
                }
                XCTAssertEqual(RoaringBitmap.and(lhs: rb, rhs: rb2).cardinality,Int( N / offset))
                XCTAssertEqual(RoaringBitmap.or(lhs: rb, rhs: rb2).cardinality, Int(2 * N - N / offset))
                XCTAssertEqual(RoaringBitmap.xor(lhs: rb, rhs: rb2).cardinality, Int(2 * N - 2 * N / offset))
            }
        }
    }

   
    func testClear() {
        let rb = RoaringBitmap()
        for (var i:UInt32 = 0; i < 200000; i += 7){
            // dense
            rb.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 177){
            // sparse
            rb.add(i)
        }
        
        let rb2 = RoaringBitmap()
        let rb3 = RoaringBitmap()
        for (var i:UInt32 = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        
        rb.clear()
        let rbCardinality = rb.cardinality
  
        XCTAssertEqual(0, rbCardinality)
        XCTAssert(0 != rb2.cardinality)
        
        rb.add(4)
        rb3.add(4)
        let andresult = RoaringBitmap.and(lhs: rb, rhs: rb2)
        let orresult = RoaringBitmap.or(lhs: rb, rhs: rb2)
        
        XCTAssertEqual(1, andresult.cardinality)
        XCTAssertEqual(rb2.cardinality,orresult.cardinality);
        
        for (var i:UInt32 = 0; i < 200000; i += 4) {
            rb.add(i)
            rb3.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 114) {
            rb.add(i)
            rb3.add(i)
        }
        
        let arrayrr = rb.asArray
        let arrayrr3 = rb3.asArray
        
        XCTAssert(arrayrr == arrayrr3)
    }


    //FIXME:Fails
//    func testContainerFactory() {
//        var bc1 = BitmapContainer()
//        var bc2 = BitmapContainer()
//        var bc3 = BitmapContainer()
//        var ac1 = ArrayContainer()
//        var ac2 = ArrayContainer()
//        var ac3 = ArrayContainer()
//        
//        for (var i:UInt16 = 0; i < 5000; i++){
//            bc1.add( (i * 70))
//        }
//        for (var i:UInt16 = 0; i < 5000; i++){
//            bc2.add( (i * 70))
//        }
//        for (var i:UInt16 = 0; i < 5000; i++){
//            bc3.add( (i * 70))
//        }
//        
//        for (var i:UInt16 = 0; i < 4000; i++){
//            ac1.add( (i * 50))
//        }
//        for (var i:UInt16 = 0; i < 4000; i++){
//            ac2.add( (i * 50))
//        }
//        for (var i:UInt16 = 0; i < 4000; i++){
//            ac3.add((i * 50))
//        }
//        
//        if let cac = ac1.clone() as? ArrayContainer{
//            let rbc = cac.toBitmapContainer()
//            XCTAssert(validate(rbc, ac: ac1))
//        }
//        
//        if let cac = ac2.clone() as? ArrayContainer{
//            let rbc = cac.toBitmapContainer()
//            XCTAssert(validate(rbc, ac: ac2))
//            
//        }
//        
//        if let cac = ac3.clone() as? ArrayContainer{
//            let rbc = cac.toBitmapContainer()
//            XCTAssert(validate(rbc, ac: ac3))
//            
//        }
//    }


    func testFlip1() {
        let rb = RoaringBitmap()
        
        rb.flip(100000, rangeEnd: 200000); // in-place on empty bitmap
        let rbcard = rb.cardinality
        XCTAssertEqual(100000, rbcard)
        
        let bs = BitSet();
        for i in 100000..<200000{
            bs.set(i)
        }
        XCTAssert(equals(bs, rr: rb));
    }

    
    func testFlip_1A() {
        let rb = RoaringBitmap();
        
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 100000, rangeEnd: 200000);
        let rbcard = rb1.cardinality;
        XCTAssertEqual(100000, rbcard);
        XCTAssertEqual(0, rb.cardinality);
        
        let  bs = BitSet();
        XCTAssert(equals(bs, rr: rb)); // still empty?
        for (i in 100000 ..< 200000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr: rb1));
    }


    func testFlip_2() {
        let rb = RoaringBitmap()
        
        rb.flip(100000, rangeEnd: 100000);
        let rbcard = rb.cardinality;
        XCTAssertEqual(0, rbcard);
        
        let bs = BitSet();
        XCTAssert(equals(bs, rr: rb));
    }


    func testFlip_2A() {
        let rb = RoaringBitmap();
        
        let rb1 = RoaringBitmap
            .flip(rb, rangeStart: 100000, rangeEnd: 100000);
        rb.add(1); // will not affect rb1 (no shared container)
        let rbcard = rb1.cardinality;
        XCTAssertEqual(0, rbcard);
        XCTAssertEqual(1, rb.cardinality);
        
        let bs = BitSet();
        XCTAssert(equals(bs, rr: rb1));
        bs.set(1);
        XCTAssert(equals(bs, rr: rb));
    }

    func testFlip_3() {
        let rb = RoaringBitmap();
        
        rb.flip(100000, rangeEnd: 200000); // got 100k-199999
        rb.flip(100000, rangeEnd: 199991); // give back 100k-199990
        let rbcard = rb.cardinality;
        
        XCTAssertEqual(9, rbcard);
        
        let bs = BitSet();
        for (i in 199991 ..< 200000 += 1){
            bs.set(i);
        }
        
        XCTAssert(equals(bs, rr: rb));
    }


    func testFlip_3A() {
        let rb = RoaringBitmap();
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 100000, rangeEnd: 200000);
        let rb2 = RoaringBitmap.flip(rb1, rangeStart: 100000, rangeEnd: 199991);
        let rbcard = rb2.cardinality;
        
        XCTAssertEqual(9, rbcard);
        
        let bs = BitSet();
        for (i in 199991 ..< 200000 += 1){
            bs.set(i);
        }
        
        XCTAssert(equals(bs, rr: rb2));
    }


    func testFlip_4() { // fits evenly on both ends
        let rb = RoaringBitmap()
        rb.flip(100000, rangeEnd: 200000); // got 100k-199999
        rb.flip(65536, rangeEnd: 4 * 65536);
        let rbcard = rb.cardinality;
        
        // 65536 to 99999 are 1s
        // 200000 to 262143 are 1s: total card
        
        XCTAssertEqual(96608, rbcard);
        
        let bs = BitSet();
        for (i in 65536 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 200000 ..< 262144 += 1){
            bs.set(i);
        }
        
        XCTAssert(equals(bs, rr: rb));
    }


    func testFlip_4A() {
        let rb = RoaringBitmap();
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 100000, rangeEnd: 200000);
        let rb2 = RoaringBitmap.flip(rb1, rangeStart: 65536,rangeEnd: 4 * 65536);
        let rbcard = rb2.cardinality;
        
        XCTAssertEqual(96608, rbcard);
        
        let bs = BitSet();
        for (i in 65536 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 200000 ..< 262144 += 1){
            bs.set(i);
        }
        
        XCTAssert(equals(bs, rr:rb2));
    }


    func testFlip5() { // fits evenly on small end, multiple
        // containers
        let rb = RoaringBitmap();
        rb.flip(100000, rangeEnd: 132000);
        rb.flip(65536, rangeEnd: 120000);
        let rbcard = rb.cardinality;
        
        // 65536 to 99999 are 1s
        // 120000 to 131999
        
        XCTAssertEqual(46464, rbcard);
        
        let bs = BitSet();
        for (i in 65536 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 120000 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr: rb));
    }


    func testFlip_5A() {

        let rb = RoaringBitmap();
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 100000, rangeEnd: 132000);
        let rb2 = RoaringBitmap.flip(rb1, rangeStart: 65536, rangeEnd: 120000);
       let rbcard = rb2.cardinality;
        
        XCTAssertEqual(46464, rbcard);
        
        let bs = BitSet();
        for (i in 65536 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 120000 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr:rb2));
    }


    func testFlip_6() { // fits evenly on big end, multiple containers
        let rb = RoaringBitmap();
        rb.flip(100000, rangeEnd: 132000);
        rb.flip(99000, rangeEnd: 2 * 65536);
        let rbcard = rb.cardinality;
        
        // 99000 to 99999 are 1000 1s
        // 131072 to 131999 are 928 1s
        
        XCTAssertEqual(1928, rbcard);
        
        let bs = BitSet();
        for (i in 99000 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 2 * 65536 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr:rb));
    }


    func testFlip_6A() {

        let rb = RoaringBitmap();
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 100000, rangeEnd: 132000);
        let rb2 = RoaringBitmap.flip(rb1, rangeStart: 99000,rangeEnd: 2 * 65536);
        let  rbcard = rb2.cardinality;
        
        XCTAssertEqual(1928, rbcard);
        
        let  bs = BitSet();
        for (i in 99000 ..< 100000 += 1){
            bs.set(i);
        }
        for (i in 2 * 65536 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr:rb2));
    }


    func testFlip_7() { // within 1 word, first
        let rb = RoaringBitmap();
        rb.flip(650, rangeEnd: 132000);
        rb.flip(648, rangeEnd: 651);
        let  rbcard = rb.cardinality;
        
        // 648, 649, 651-131999
        
        XCTAssertEqual(132000 - 651 + 2, rbcard);
        
        let  bs = BitSet();
        bs.set(648);
        bs.set(649);
        for (i in 651 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr:rb));
    }


    func testFlip_7A() { // within 1 word, first container
        let rb = RoaringBitmap();
        let rb1 = RoaringBitmap.flip(rb, rangeStart: 650, rangeEnd: 132000);
        let rb2 = RoaringBitmap.flip(rb1, rangeStart: 648, rangeEnd: 651);
        let rbcard = rb2.cardinality;
        
        // 648, 649, 651-131999
        
        XCTAssertEqual(132000 - 651 + 2, rbcard);
        
        let bs = BitSet();
        bs.set(648);
        bs.set(649);
        for (i in 651 ..< 132000 += 1){
            bs.set(i);
        }
        XCTAssert(equals(bs, rr:rb2));
    }

    //FIXME: Fails
//    func testFlipBig() {
//        let numCases = 1000;
//        let rb = RoaringBitmap();
//        let bs = BitSet();
//        srand(3333);
//        var checkTime:Double = 2;
//        
//        for (var i = 0; i < numCases; ++i) {
//            let  start = UInt32(arc4random_uniform(65536 * 20))
//            var end = UInt32(arc4random_uniform(65536 * 20))
//            if (drand48() < 0.1){
//                end = start + UInt32(arc4random_uniform(100))
//            }
//            rb.flip(start, rangeEnd: end);
//            if (start < end){
//                bs.flip(Int(start), toIndex: Int(end))
//            }
//            // otherwise
//            // insert some more ANDs to keep things sparser
//            if (drand48() < 0.2) {
//                let mask = RoaringBitmap();
//                let  mask1 = BitSet();
//                let  startM = UInt32(arc4random_uniform(65536 * 20))
//                let  endM:UInt32 = startM + 100000;
//                mask.flip(startM, rangeEnd: endM);
//                mask1.flip(Int(startM), toIndex: Int(endM))
//                mask.flip(0, rangeEnd: UInt32(65536 * 20 + 100000));
//                mask1.flip(0, toIndex: 65536 * 20 + 100000);
//                rb.and(rhs: mask);
//                bs.and(mask1);
//            }
//            // see if we can detect incorrectly shared containers
//            if (drand48() < 0.1) {
//                let irrelevant = RoaringBitmap.flip(rb, rangeStart: 10, rangeEnd: 100000);
//                irrelevant.flip(5, rangeEnd: 200000);
//                irrelevant.flip(190000, rangeEnd:260000);
//            }
//            if (Double(i) > checkTime) {
//                XCTAssert(equals(bs, rr:rb));
//                checkTime *= 1.5;
//            }
//        }
//    }


//    func testFlipBig_A() {
//        let numCases = 1000;
//        let bs = BitSet();
//        srand(3333);
//        var checkTime:Double = 2;
//        var rb1 = RoaringBitmap()
//        var rb2 = RoaringBitmap(); // alternate
//        // between
//        // them
//        
//        for (var i = 0; i < numCases; ++i) {
//            let  start = arc4random_uniform(65536 * 20);
//            var end = arc4random_uniform(65536 * 20);
//            if (drand48() < 0.1){
//                end = start + arc4random_uniform(100)
//            }
//            
//            if ((i & 1) == 0) {
//                rb2 = RoaringBitmap.flip(rb1, rangeStart: start, rangeEnd: end);
//                // tweak the other, catch bad sharing
//                rb1.flip(arc4random_uniform(65536 * 20),rangeEnd: arc4random_uniform(65536 * 20));
//            } else {
//                rb1 = RoaringBitmap.flip(rb2, rangeStart: start, rangeEnd: end);
//                rb2.flip(arc4random_uniform(65536 * 20),rangeEnd: arc4random_uniform(65536 * 20));
//            }
//            
//            if (start < end){
//                bs.flip(Int(start), toIndex:Int(end)); // throws exception
//            }
//            // otherwise
//            // insert some more ANDs to keep things sparser
//            if (drand48() < 0.2 && (i & 1) == 0) {
//                let mask = RoaringBitmap();
//                let  mask1 = BitSet();
//                let  startM = Int(arc4random_uniform(65536 * 20))
//                let  endM = Int(startM + 100000)
//                mask.flip(UInt32(startM), rangeEnd:UInt32(endM))
//                mask1.flip(startM, toIndex:endM);
//                let maskfliprangeEnd = 65536 * 20 + 100000
//                mask.flip(UInt32(0), rangeEnd:UInt32(maskfliprangeEnd))
//                mask1.flip(0, toIndex: 65536 * 20 + 100000);
//                rb2.and(rhs: mask);
//                bs.and(mask1);
//            }
//            
//            if (Double(i) > checkTime) {
//                //System.out.println("check after " + i + ", card = " + rb2.cardinality);
//                let rb = (i & 1) == 0 ? rb2 : rb1;
//                let status = equals(bs, rr:rb);
//                XCTAssert(status);
//                checkTime *= 1.5;
//            }
//        }
//    }
//
//
// 
    func testOR_0() {
        let rr = RoaringBitmap()
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        let rr2 = RoaringBitmap()
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr2.add(k)
        }
        
        let rror = RoaringBitmap.or(lhs: rr, rhs: rr2)
        
        let array = rror.asArray
        let arrayrr = rr.asArray
        
        XCTAssert(array == arrayrr)
        
        rr.or(rhs: rr2)
        let arrayirr = rr.asArray
        XCTAssert(array == arrayirr)
        
    }


    func testOR_1() {
        let rr = RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            rr.add(k)
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            rr.add(k)
        }
        
        let rr2 = RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1) {
            rr2.add(k)
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1) {
            rr2.add(k)
        }
        for (k:UInt32 in UInt32(3 * 65536 + 2000) ..< UInt32(3 * 65536 + 6000) += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 10 * 65535 ..< 10 * 65535 + 5000 += 1) {
            rr2.add(k);
        }
        let correct = RoaringBitmap.or(lhs: rr, rhs: rr2)
        rr.or(rhs: rr2)
        XCTAssert(correct == rr)
    }

    func testOR_2() {
        var arrayrr = [UInt32](repeating: 0, count: 4000 + 4000 + 2)
        var pos = 0
        let rr = RoaringBitmap()
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr.add(k)
            arrayrr[pos++] = k
        }
        rr.add(100000);
        rr.add(110000);
        let rr2 = RoaringBitmap();
        for (k:UInt32 in 4000 ..< 8000 += 1) {
            rr2.add(k);
            arrayrr[pos++] = k
        }
        
        arrayrr[pos++] = 100000;
        arrayrr[pos++] = 110000;
        
        let rror = RoaringBitmap.or(lhs: rr, rhs: rr2);
        
        let arrayor = rror.asArray;
        
        XCTAssert(arrayor == arrayrr)
    }

    
    func testOR_3() {
        var V1 = Set<UInt32>()
        
        let rr = RoaringBitmap()
        let rr2 = RoaringBitmap()
        // For the first 65536: rr2 has a bitmap container, and rr has
        // an array container.
        // We will check the union between a BitmapCintainer and an
        // arrayContainer
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr2.add(k)
            V1.insert(k)
        }
        for (k:UInt32 in 3500 ..< 4500 += 1) {
            rr.add(k);
            V1.insert(k);
        }
        for (k:UInt32 in 4000 ..< 65000 += 1) {
            rr2.add(k);
            V1.insert(k);
        }
        
        // In the second node of each roaring bitmap, we have two bitmap
        // containers.
        // So, we will check the union between two BitmapContainers
        for (k:UInt32 in 65536 ..< 65536 + 10000 += 1) {
            rr.add(k);
            V1.insert(k);
        }
        
        for (k:UInt32 in 65536 ..< 65536 + 14000 += 1) {
            rr2.add(k);
            V1.insert(k);
        }
        
        // In the 3rd node of each Roaring Bitmap, we have an
        // ArrayContainer, so, we will try the union between two
        // ArrayContainers.
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 1000 += 1) {
            rr.add(k);
            V1.insert(k);
        }
        
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 800 += 1) {
            rr2.add(k);
            V1.insert(k);
        }
        
        // For the rest, we will check if the union will take them in
        // the result
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr.add(k);
            V1.insert(k);
        }
        
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 2000 += 1) {
            rr2.add(k);
            V1.insert(k);
        }
        
        let rror = RoaringBitmap.or(lhs: rr, rhs: rr2);
        var valide = true
        
        // Si tous les elements de rror sont dans V1 et que tous les
        // elements de
        // V1 sont dans rror(V2)
        // alors V1 == rror
        
        
        var vector = [UInt32]()
        for  aTab in V1{
            vector.append(aTab)
        }
        
        let sortedV1 = vector.sorted()
        
        let rrorArray = rror.asArray
        
        for index in 0..<rrorArray.count{
            if rrorArray[index] != sortedV1[index]{
                valide = false
            }
        }
        
        
        XCTAssertEqual(valide, true)
    }

// tests for how range falls on container boundaries


    func testOR_4() {
        let rb = RoaringBitmap()
        let rb2 = RoaringBitmap()
        
        for (var i:UInt32 = 0 ; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        let rb2card = rb2.cardinality
        
        // check or against an empty bitmap
        let orresult = RoaringBitmap.or(lhs: rb, rhs: rb2)
        let off = RoaringBitmap.or(lhs: rb2, rhs: rb)
        XCTAssert(orresult == off)
        
        XCTAssertEqual(rb2card, orresult.cardinality);
        
        for (var i:UInt32 = 500000; i < 600000; i += 14){
            rb.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 3){
            rb2.add(i)
        }
        // check or against an empty bitmap
        let orresult2 = RoaringBitmap.or(lhs: rb, rhs: rb2)
        XCTAssertEqual(rb2card, orresult.cardinality)
        
        XCTAssertEqual(rb2.cardinality + rb.cardinality, orresult2.cardinality);
        rb.or(rhs: rb2)
        XCTAssert(rb == orresult2)
        
    }

    
/*
    func testRandom() {
        rTest(15)
        rTest(1024)
        rTest(4096)
        rTest(65536)
        rTest(65536 * 16)
    }


    func rTest(final N:Int) {
        for (var gap:UInt32 = 1; gap <= 65536; gap *= 2) {
            var  bs1 = BitSet();
            var rb1 = RoaringBitmap();
            for (int x = 0; x <= N; x += gap) {
                bs1.set(x);
                rb1.add(x);
            }
            if (bs1.cardinality() != rb1.cardinality)
            throw RuntimeException("different card");
            if (!equals(bs1, rb1))
            throw RuntimeException("basic  bug");
            for (int offset = 1; offset <= gap; offset *= 2) {
                var  bs2 = BitSet();
                var rb2 = RoaringBitmap();
                for (int x = 0; x <= N; x += gap) {
                    bs2.set(x + offset);
                    rb2.add(x + offset);
                }
                if (bs2.cardinality() != rb2.cardinality)
                throw RuntimeException(
                "different card");
                if (!equals(bs2, rb2))
                throw RuntimeException("basic  bug");
                
                BitSet clonebs1;
                // testing AND
                clonebs1 = (BitSet) bs1.clone();
                clonebs1.and(bs2);
                if (!equals(clonebs1,
                RoaringBitmap.and(rb1, rb2)))
                throw RuntimeException("bug and");
                {
                    var t = rb1.clone();
                    t.and(rb2);
                    if (!equals(clonebs1, t))
                    throw RuntimeException(
                    "bug inplace and");
                    if (!t.equals(RoaringBitmap.and(rb1, rb2))) {
                        System.out
                            .println(t.highLowContainer
                                .getContainerAtIndex(
                                    0)
                                .getClass()
                                .getCanonicalName());
                        System.out
                            .println(RoaringBitmap
                                .and(rb1, rb2).highLowContainer
                                .getContainerAtIndex(
                                    0)
                                .getClass()
                                .getCanonicalName());
                        
                        throw RuntimeException(
                            "bug inplace and");
                    }
                }
                
                // testing OR
                clonebs1 = (BitSet) bs1.clone();
                clonebs1.or(bs2);
                
                if (!equals(clonebs1,RoaringBitmap.or(rb1, rb2)))
                throw RuntimeException("bug or");
                {
                    var t = rb1.clone();
                    t.or(rb2);
                    if (!equals(clonebs1, t))
                    throw RuntimeException("bug or");
                    if (!t.equals(RoaringBitmap.or(rb1, rb2)))
                    throw RuntimeException("bug or");
                    if (!t.toString().equals(RoaringBitmap.or(rb1, rb2).toString()))
                    throw RuntimeException("bug or");
                    
                }
                // testing XOR
                clonebs1 = (BitSet) bs1.clone();
                clonebs1.xor(bs2);
                if (!equals(clonebs1, RoaringBitmap.xor(rb1, rb2))) {
                    throw RuntimeException("bug xor");
                }
                {
                    var t = rb1.clone();
                    t.xor(rb2);
                    if (!equals(clonebs1, t))
                    throw RuntimeException("bug xor");
                    if (!t.equals(RoaringBitmap.xor(rb1, rb2)))
                    throw RuntimeException("bug xor");
                }
                // testing NOTAND
                clonebs1 = (BitSet) bs1.clone();
                clonebs1.andNot(bs2);
                if (!equals(clonebs1, RoaringBitmap.andNot(rb1, rb2))) {
                    throw RuntimeException("bug andnot");
                }
                clonebs1 = (BitSet) bs2.clone();
                clonebs1.andNot(bs1);
                if (!equals(clonebs1, RoaringBitmap.andNot(rb2, rb1))) {
                    throw RuntimeException("bug andnot");
                }
                {
                    var t = rb2.clone();
                    t.andNot(rb1);
                    if (!equals(clonebs1, t)) {
                        throw RuntimeException("bug inplace andnot");
                    }
                    var g = RoaringBitmap.andNot(rb2, rb1);
                    if (!equals(clonebs1, g)) {
                        throw RuntimeException("bug andnot");
                    }
                    if (!t.equals(g))
                    throw RuntimeException("bug");
                }
                clonebs1 = (BitSet) bs1.clone();
                clonebs1.andNot(bs2);
                if (!equals(clonebs1, RoaringBitmap.andNot(rb1, rb2))) {
                    throw RuntimeException("bug andnot");
                }
                {
                    var t = rb1.clone();
                    t.andNot(rb2);
                    if (!equals(clonebs1, t)) {
                        throw RuntimeException("bug andnot");
                    }
                    var g = RoaringBitmap.andNot(rb1, rb2);
                    if (!equals(clonebs1, g)) {
                        throw RuntimeException("bug andnot");
                    }
                    if (!t.equals(g))
                    throw RuntimeException("bug");
                }
            }
        }
    }
*/
    
    func testSequence() {
        let rb = RoaringBitmap()
        for(k:UInt32 in 0 ..< 4000 += 1) {rb.add(k)}
        for(k:UInt32 in 0 ..< 1000 += 1) {rb.add(k*100)}
        let copy1 = RoaringBitmap()
        for  x in rb {
            copy1.add(x)
        }
        
        XCTAssert(copy1 == rb)
    }


    func testSimpleCardinality() {
        let N:UInt32 = 512
        let gap:UInt32 = 70
        
        let rb = RoaringBitmap()
        for (k:UInt32 in 0 ..< N) {
            rb.add(k * gap)
            XCTAssertEqual(rb.cardinality, Int(k + 1))
        }
        XCTAssertEqual(rb.cardinality, Int(N))
        for (k:UInt32 in 0 ..< N) {
            rb.add(k * gap)
            XCTAssertEqual(rb.cardinality, Int(N))
        }
        
    }


 
    func testXOR_0() {
        let rr = RoaringBitmap();
        for (k:UInt32 in 4000 ..< 4256 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 3 * 65536 ..< 3 * 65536 + 9000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 7000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 10000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 8 * 65535 ..< 8 * 65535 + 1000 += 1){
            rr.add(k);
        }
        for (k:UInt32 in 9 * 65535 ..< 9 * 65535 + 30000 += 1){
            rr.add(k);
        }
        

        
        let rr2 = RoaringBitmap()
        for (k:UInt32 in 4000 ..< 4256 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 65536 ..< 65536 + 4000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in UInt32(3 * 65536 + 2000) ..< UInt32(3 * 65536 + 6000) += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 1000 += 1) {
            rr2.add(k);
        }
        for (k:UInt32 in 10 * 65535 ..< 10 * 65535 + 5000 += 1) {
            rr2.add(k);
        }
        
        
        let correct = RoaringBitmap.xor(lhs: rr, rhs: rr2);
        rr.xor(rhs: rr2);
        XCTAssert(correct == rr)
    }

    func testXOR_1() {
        var V1 = Set<UInt32>()
        
        let rr = RoaringBitmap();
        let rr2 = RoaringBitmap();
        // For the first 65536: rr2 has a bitmap container, and rr has
        // an array container.
        // We will check the union between a BitmapCintainer and an
        // arrayContainer
        for (k:UInt32 in 0 ..< 4000 += 1) {
            rr2.add(k);
            if (k < 3500){
                V1.insert(k);
            }
        }
        for (k:UInt32 in 3500 ..< 4500 += 1) {
            rr.add(k);
        }
        for (k:UInt32 in 4000 ..< 65000 += 1) {
            rr2.add(k);
            if (k >= 4500){
                V1.insert(k);
            }
        }
        
        // In the second node of each roaring bitmap, we have two bitmap
        // containers.
        // So, we will check the union between two BitmapContainers
        for (k:UInt32 in 65536 ..< 65536 + 30000 += 1) {
            rr.add(k);
        }
        
        for (k:UInt32 in 65536 ..< 65536 + 50000 += 1) {
            rr2.add(k);
            if (k >= 65536 + 30000){
                V1.insert(k);
            }
        }
        
        // In the 3rd node of each Roaring Bitmap, we have an
        // ArrayContainer. So, we will try the union between two
        // ArrayContainers.
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 1000 += 1) {
            rr.add(k);
            if (k >= 4 * 65535 + 800){
                V1.insert(k);
            }
        }
        
        for (k:UInt32 in 4 * 65535 ..< 4 * 65535 + 800 += 1) {
            rr2.add(k);
        }
        
        // For the rest, we will check if the union will take them in
        // the result
        for (k:UInt32 in 6 * 65535 ..< 6 * 65535 + 1000 += 1) {
            rr.add(k)
            V1.insert(k)
        }
        
        for (k:UInt32 in 7 * 65535 ..< 7 * 65535 + 2000 += 1) {
            rr2.add(k)
            V1.insert(k)
        }
        
        let rrxor = RoaringBitmap.xor(lhs: rr, rhs: rr2);
        var valide = true;
        
        // Si tous les elements de rror sont dans V1 et que tous les
        // elements de
        // V1 sont dans rror(V2)
        // alors V1 == rror

        
        var vector = [UInt32]()
        for  aTab in V1{
            vector.append(aTab)
        }
        
        let sortedV1 = vector.sorted()
        
        let rrxorArray = rrxor.asArray
        
        for index in 0..<rrxorArray.count{
            if rrxorArray[index] != sortedV1[index]{
                valide = false
            }
        }
        
        XCTAssertEqual(valide, true);
    }


    
    func testXOR_4() {
        let rb = RoaringBitmap();
        let rb2 = RoaringBitmap();
        
        for (var i:UInt32 = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i:UInt32 = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        let rb2card = rb2.cardinality
        
        // check or against an empty bitmap
        let xorresult = RoaringBitmap.xor(lhs: rb, rhs: rb2);
        let off = RoaringBitmap.or(lhs: rb2, rhs: rb);
        XCTAssert(xorresult == off)
        
        XCTAssertEqual(rb2card, xorresult.cardinality);
        
        for (var i:UInt32 = 500000; i < 600000; i += 14){
            rb.add(i);
        }
        for (var i:UInt32 = 200000; i < 400000; i += 3){
            rb2.add(i);
        }
        // check or against an empty bitmap
        let xorresult2 = RoaringBitmap.xor(lhs: rb, rhs: rb2);
        XCTAssertEqual(rb2card, xorresult.cardinality);
        
        XCTAssertEqual(rb2.cardinality + rb.cardinality, xorresult2.cardinality);
        rb.xor(rhs: rb2);
        XCTAssert(xorresult2 == rb)
        
    }

    
    func validate(_ bc:BitmapContainer , ac:ArrayContainer) -> Bool{
        // Checking the cardinalities of each container
        
        if (bc.cardinality != ac.cardinality) {
          //  XCTAssertEqual(bc.cardinality , ac.cardinality,"cardinality differs")
            print("cardinality differs")
            return false
        }
        // Checking that the two containers contain the same values
        var counter = 0
        
        var i = bc.nextSetBit(0)
        while (i >= 0) {
            counter += 1;
            if (!ac.contains(UInt16(i))) {
                print("content differs")
                print(bc)
                print(ac)
                return false;
            }
            i = bc.nextSetBit(i + 1)
        }
        
        // checking the cardinality of the BitmapContainer
        return counter == bc.cardinality
    }



    func equals(_ bs:BitSet , rr:RoaringBitmap ) ->Bool{
        var a = [UInt32](repeating: 0, count: bs.cardinality())
        var pos = 0;
        for (var x = bs.nextSetBit(0); x >= 0; x = bs.nextSetBit(x + 1)){
            let xu = UInt32(x)
            a[pos++] = xu
        }
        return (rr.asArray == a)
    }


    func testMassiveIndexing() {
        let ewahCount = 1024
        let howmany:UInt64 = 1000000
        print("-------------")
        var counter = 0
        for (k:UInt64 in 0 ..< howmany += 1) {
            let index:UInt64 = (k + 2 * k * k) % UInt64(ewahCount)
            print("[\(k):\(index)] )", appendNewline: false)
            counter += 1
            if counter % 5 == 0{
                print("")
            }
            
        }
        print("-------------")

    }


    // Test massive and.

    func testMassiveAnd() {
        let ewahCount = 1024
        var ewah = [RoaringBitmap]()
        for _ in 0..<1024 {
            ewah.append( RoaringBitmap())
        }
        let howmany:UInt64 = 1000000
        for (k:UInt64 in 0 ..< howmany += 1) {
            let index:UInt64 = (k + 2 * k * k) % UInt64(ewahCount)
            
            ewah[Int(index)].add(UInt32(k))
        }
        for (var k = 3; k < ewahCount; k+=3){
            ewah[k].flip(UInt32(13), rangeEnd: UInt32(howmany/2))
        }
        for (N in 2 ..< ewahCount += 1) {
            var answer = ewah[0];
            for (k in 1 ..< N += 1){
                answer = RoaringBitmap.and(lhs: answer, rhs: ewah[k])
            }
            
            let answer2 = FastAggregation.and(bitmaps: Array(ewah[0..<N]))
            XCTAssert(answer == answer2)
//            let answer2b = FastAggregation.and(toIterator(Arrays.copyOf(ewah, N)));
//            XCTAssert(answer == answer2b)
            
        }
    }




    // Test massive or.
    //FIXME: FastAggregation.horizontal_or fails at howmany = 131072, 262144, and 524288
    func testMassiveOR() {
        let N = 128
        for (var howmany:UInt64 = 512; howmany <= 1000000; howmany *= 2) {
            var ewah = [RoaringBitmap]()
            for _ in 0..<N {
                ewah.append(RoaringBitmap())
            }
            for (k:UInt64 in 0 ..< howmany += 1) {
                let index:UInt64 = (k + 2 * k * k) % UInt64(N)
                ewah[Int(index)].add(UInt32(k))
            }
            for (var k = 3; k < N; k+=3){
                ewah[k].flip(UInt32(13), rangeEnd: UInt32(howmany/2))
            }
    
    
            if (howmany ==	131072){
                print("---")
            }
    
            var answer = ewah[0]
            for (k in 1 ..< N += 1) {
                answer = RoaringBitmap.or(lhs: answer,rhs: ewah[k]);
            }
    
            let answer2 = FastAggregation.or(ewah)
            let answer3 = FastAggregation.horizontal_or(ewah);
 
            if !(answer == answer3){
                print("at howmany: \(howmany) answer cardinality: \(answer.cardinality)  <> answer cardinality: \(answer3!.cardinality)")
            }
            XCTAssert(answer == answer2)
      //      XCTAssert(answer == answer3)
            
        }
    }


    // Test massive xor.

    //FIXME: FastAggregation.horizontal_or fails at howmany = ??
    func testMassiveXOr() {
        let N = 128
        for (var howmany:UInt64 = 512; howmany <= 1000000; howmany *= 2) {
            var ewah = [RoaringBitmap]()
            for _ in 0..<N {
                ewah.append(RoaringBitmap())
            }

            for (k:UInt64 in 0 ..< howmany += 1) {
                let index:UInt64 = (k + 2 * k * k) % UInt64(N)
                ewah[Int(index)].add(UInt32(k))
            }

            for (var k = 3; k < N; k+=3){
                ewah[k].flip(UInt32(13), rangeEnd: UInt32(howmany/2))
            }
            
            var answer = ewah[0]
            for (k in 1 ..< N += 1) {
                answer = RoaringBitmap.xor(lhs: answer,rhs: ewah[k]);
            }
            let answer2 = FastAggregation.xor(ewah);
            let answer3 = FastAggregation.horizontal_xor(ewah);
            XCTAssert(answer == answer2)
            if (answer != answer3){
                print("failed on \(howmany)")
            }
           // XCTAssert(answer == answer3)
        }
    }


    
    /*
    func testSerialization() throws IOException, ClassNotFoundException {
    var rr = RoaringBitmap();
    for (var k:UInt32 = 65000; k < 2 * 65000; ++k)
    rr.add(k);
    final ByteArrayOutputStream bos = ByteArrayOutputStream();
    // Note: you could use a file output steam instead of
    // ByteArrayOutputStream
    final ObjectOutputStream oo = ObjectOutputStream(bos);
    rr.writeExternal(oo);
    oo.close();
    var rrback = RoaringBitmap();
    final ByteArrayInputStream bis = ByteArrayInputStream(bos.toByteArray());
    rrback.readExternal(new ObjectInputStream(bis));
    XCTAssertEqual(rr.cardinality, rrback.cardinality);
    XCTAssert(rr.equals(rrback));
    }
    
    
    
    func testSerialization2() throws IOException,
    ClassNotFoundException {
    var rr = RoaringBitmap();
    for (var k:UInt32 = 200; k < 400; ++k)
    rr.add(k);
    final ByteArrayOutputStream bos = ByteArrayOutputStream();
    // Note: you could use a file output steam instead of
    // ByteArrayOutputStream
    final ObjectOutputStream oo = ObjectOutputStream(bos);
    rr.writeExternal(oo);
    oo.close();
    var rrback = RoaringBitmap();
    final ByteArrayInputStream bis = ByteArrayInputStream(bos.toByteArray());
    rrback.readExternal(new ObjectInputStream(bis));
    XCTAssertEqual(rr.cardinality,rrback.cardinality);
    XCTAssert(rr.equals(rrback));
    }
    
    
    func testSerialization3() throws IOException, ClassNotFoundException {
    var rr = RoaringBitmap();
    for (var k:UInt32 = 65000; k < 2 * 65000; ++k)
    rr.add(k);
    rr.add(1444000);
    final ByteArrayOutputStream bos = ByteArrayOutputStream();
    // Note: you could use a file output steam instead of
    // ByteArrayOutputStream
    int howmuch = rr.serializedSizeInBytes();
    final DataOutputStream oo = DataOutputStream(bos);
    rr.serialize(oo);
    oo.close();
    XCTAssertEqual(howmuch, bos.toByteArray().count);
    var rrback = RoaringBitmap();
    final ByteArrayInputStream bis = ByteArrayInputStream(bos.toByteArray());
    rrback.deserialize(new DataInputStream(bis));
    XCTAssertEqual(rr.cardinality, rrback.cardinality);
    XCTAssert(rr.equals(rrback));
    }
    
    
    func testSerialization4() throws IOException, ClassNotFoundException {
    var rr = RoaringBitmap();
    for (var k:UInt32 = 1; k <= 10000000; k+=10)
    rr.add(k);
    final ByteArrayOutputStream bos = ByteArrayOutputStream();
    // Note: you could use a file output steam instead of
    // ByteArrayOutputStream
    int howmuch = rr.serializedSizeInBytes();
    final DataOutputStream oo = DataOutputStream(bos);
    rr.serialize(oo);
    oo.close();
    XCTAssertEqual(howmuch, bos.toByteArray().count);
    var rrback = RoaringBitmap();
    final ByteArrayInputStream bis = ByteArrayInputStream(bos.toByteArray());
    rrback.deserialize(new DataInputStream(bis));
    XCTAssertEqual(rr.cardinality, rrback.cardinality);
    XCTAssert(rr.equals(rrback));
    }
    
    */


}
