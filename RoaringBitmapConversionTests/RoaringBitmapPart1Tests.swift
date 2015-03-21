//
//  RoaringBitmapTests.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/19/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit
import XCTest
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
        var rb = RoaringBitmap()
        for(var k = 0; k < 100000; k += 7){
            rb.add(k)
        }
        for(var k = 100000; k < 200000; k += 1000){
            rb.add(k)
        }
        for(var k = 0; k < 100000; ++k) {
            XCTAssert(1 + k/7 == rb.rank(upperLimit: k)," rank 7 Pass")
        }
        for(var k = 100000; k < 200000; ++k) {
            XCTAssert(1 + 100000/7 + 1 + (k - 100000)/1000 == rb.rank(upperLimit: k)," rank 1000 Pass")
        }
    }
        

        
        func testSelect() {
            let w:UInt64 = ~0
            for k in 0..<64 {
                XCTAssert(k == selectBit(word: w, bitIndex: k),"")
            }
            for k in 0..<64 {
                let wk = UInt64(1) << UInt64(k)
                XCTAssert(k == selectBit(word: wk, bitIndex: 0),"")
            }
       
            for k in 1..<64 {
                let wk = (UInt64(1) << UInt64(k)) + 1
                let bit = selectBit(word: wk, bitIndex: 1)
               // println("======= \(k) \(bit) \(wk)")
                XCTAssertEqual(k, bit,"")
            }

        
                XCTAssertEqual(0, selectBit(word:UInt64(1), bitIndex:0),"")
            XCTAssertEqual(0,selectBit(word:UInt64(5), bitIndex:0),"")
            XCTAssertEqual(2,selectBit(word:UInt64(5), bitIndex:1),"")

            for (var gap = 1; gap <= 1024; gap *= 2) {
                let rb = RoaringBitmap()
                for (var k = 0; k < 100000; k += gap){
                    rb.add(k)
                }
                for (var k = 0; k < 100000 / gap; ++k) {
                    XCTAssertEqual(k * gap, rb.select(atIndex: k),"")
                }
            }
    }



    func testLimit() {
        for (var gap = 1; gap <= 1024; gap *= 2) {
            var rb = RoaringBitmap()
            for (var k = 0; k < 100000; k += gap){
                rb.add(k)
            }
            let thiscard = rb.cardinality
            for (var k = 0; k < thiscard; k+=100) {
                let limited = rb.limit(maxCardinality: k)
                XCTAssertEqual(limited.cardinality,k)
            }
            XCTAssertEqual(rb.limit(maxCardinality: thiscard).cardinality,thiscard)
            XCTAssertEqual(rb.limit(maxCardinality: thiscard+1).cardinality,thiscard)
        }
    }

/*
func testHorizontalOrCardinality() {
    int[] vals = {65535,131071,196607,262143,327679,393215,458751,524287};
    var[] b = RoaringBitmap[2];
    b[0] = RoaringBitmap.bitmapOf(vals);
    b[1] = RoaringBitmap.bitmapOf(vals);
    RoaringBitmap a = FastAggregation.horizontal_or(new Iterator<RoaringBitmap>(){
        var k = 0;
        
        @Override
        public boolean hasNext() {
            return k<b.count;
        }
        
        @Override
        func remove() {}
        
        @Override
        public RoaringBitmap next() {
            return b[k++];
        }});
    XCTAssertEqual(8, a.cardinality);
}

*/

    func testContains()  {
        var rbm1 = RoaringBitmap()
        for(var k = 0; k<1000;++k) {
            rbm1.add(17 * k)
        }
        for(var k = 0; k<17*1000;++k) {
            XCTAssert(rbm1.contains(k) == (k/17*17==k))
        }
    }

    
    func testContains2()  {
        var rr = RoaringBitmap()
        for (var k = 4000; k < 4256; ++k){
            rr.add(k)
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            rr.add(k)
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            rr.add(k)
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            rr.add(k)
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            rr.add(k)
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            rr.add(k)
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            rr.add(k)
        }

        //now test
        for (var k = 4000; k < 4256; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            XCTAssert(rr.contains(k))
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            XCTAssert(rr.contains(k))
        }

    }

    func testHash() {
        var rbm1 = RoaringBitmap()
        rbm1.add(17)
        var rbm2 = RoaringBitmap()
        rbm2.add(17)
        XCTAssert(rbm1.hashValue == rbm2.hashValue)
        rbm2 = rbm1.clone()
        XCTAssert(rbm1.hashValue == rbm2.hashValue)
    }

    

    func testANDNOT() {
        var rr =  RoaringBitmap()
        for (var k = 4000; k < 4256; ++k){
            rr.add(k);
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            rr.add(k);
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            rr.add(k);
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            rr.add(k)
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            rr.add(k)
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            rr.add(k);
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            rr.add(k)
        }
        
        var rr2 =  RoaringBitmap()
        for (var k = 4000; k < 4256; ++k) {
            rr2.add(k);
        }
        for (var k = 65536; k < 65536 + 4000; ++k) {
            rr2.add(k);
        }
        for (var k = 3 * 65536 + 2000; k < 3 * 65536 + 6000; ++k) {
            rr2.add(k);
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 7 * 65535; k < 7 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 10 * 65535; k < 10 * 65535 + 5000; ++k) {
            rr2.add(k);
        }
        var correct = RoaringBitmap.andNot(lhs:rr, rhs:rr2)
        rr.andNot(rhs: rr2)
        XCTAssert(correct == rr)
    }

    //FIXME:fails
    func testAndNot_4() {
        var  rb =  RoaringBitmap()
        var  rb2 =  RoaringBitmap()
        
        for (var i = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
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
        var rr =  RoaringBitmap()
        for (var k = 0; k < 4000; ++k) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        
        var rr2 = RoaringBitmap()
        rr2.add(13)
        var rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
        var array = rrand.asArray
        
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)
        rr.and(rhs: rr2)
        array = rr.asArray
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)
        
    }


    func testAnd_1() {
        var rr =  RoaringBitmap()
        for (var k = 4000; k < 4256; ++k){
            rr.add(k);
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            rr.add(k);
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            rr.add(k);
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            rr.add(k)
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            rr.add(k)
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            rr.add(k);
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            rr.add(k)
        }
        
        var rr2 =  RoaringBitmap();
        for (var k = 4000; k < 4256; ++k) {
            rr2.add(k);
        }
        for (var k = 65536; k < 65536 + 4000; ++k) {
            rr2.add(k);
        }
        for (var k = 3 * 65536 + 2000; k < 3 * 65536 + 6000; ++k) {
            rr2.add(k);
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 7 * 65535; k < 7 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 10 * 65535; k < 10 * 65535 + 5000; ++k) {
            rr2.add(k);
        }
        var correct = RoaringBitmap.and(lhs:rr, rhs:rr2)
        rr.and(rhs: rr2)
        XCTAssert(correct == rr)

    }


    func testAnd_2() {
        var rr =  RoaringBitmap()
        for (var k = 0; k < 4000; ++k) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        
        var rr2 = RoaringBitmap()
        rr2.add(13)
        var rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
        
        var array = rrand.asArray
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], 13)

    }


func testAnd_3() {
    var arrayand = [UInt64](count: 11256, repeatedValue: 0)
    var pos = 0
    
    var rr =  RoaringBitmap()
    for (var k = 4000; k < 4256; ++k){
        rr.add(k);
    }
    for (var k = 65536; k < 65536 + 4000; ++k){
        rr.add(k);
    }
    for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
        rr.add(k);
    }
    for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
        rr.add(k)
    }
    for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
        rr.add(k)
    }
    for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
        rr.add(k);
    }
    for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
        rr.add(k)
    }

    var rr2 =  RoaringBitmap()
    for (var k = 4000; k < 4256; ++k) {
        rr2.add(k);
    }
    for (var k = 65536; k < 65536 + 4000; ++k) {
        rr2.add(k);
    }
    for (var k = 3 * 65536 + 2000; k < 3 * 65536 + 7000; ++k) {
        rr2.add(k);
    }
    for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
        rr2.add(k);
    }
    for (var k = 7 * 65535; k < 7 * 65535 + 1000; ++k) {
        rr2.add(k);
    }
    for (var k = 10 * 65535; k < 10 * 65535 + 5000; ++k) {
        rr2.add(k);
    }
    
    let rrand = RoaringBitmap.and(lhs: rr, rhs: rr2)
    
    let arrayres = rrand.asArray
    
    for i in 0..<arrayres.count{
        if (arrayres[i] != arrayand[i]){
            println(arrayres[i])
        }
    }
    
    
    XCTAssert(arrayand == arrayres)
    
}


    func testAnd_4() {
        var rb = RoaringBitmap()
        var rb2 = RoaringBitmap()
        
        for (var i = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        
        // check or against an empty bitmap
        let andresult = RoaringBitmap.and(lhs: rb, rhs: rb2)
        let off = RoaringBitmap.and(lhs: rb2, rhs: rb)
        XCTAssert(andresult == off)
        
        XCTAssertEqual(0, andresult.cardinality)
        
        for (var i = 500000; i < 600000; i += 14){
            rb.add(i)
        }
        for (var i = 200000; i < 400000; i += 3){
            rb2.add(i)
        }
        // check or against an empty bitmap
        let andresult2 = RoaringBitmap.and(lhs: rb, rhs: rb2)
        XCTAssertEqual(0, andresult.cardinality)
        
        XCTAssertEqual(0, andresult2.cardinality)
        for (var i = 0; i < 200000; i += 4){
            rb.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
            rb.add(i)
        }
        XCTAssertEqual(0, andresult.cardinality)
        let rc = RoaringBitmap.and(lhs: rb, rhs: rb2)
        rb.and(rhs: rb2)
        XCTAssertEqual(rc.cardinality, rb.cardinality)
        
    }


    func testArrayContainerCardinality() {
        var ac:Container = ArrayContainer()
        for (var k:UInt16 = 0; k < 100; ++k) {
            ac.add(k)
            XCTAssertEqual(ac.cardinality, Int(k + 1))
        }
        for (var k:UInt16 = 0; k < 100; ++k) {
            ac.add(k)
            XCTAssertEqual(ac.cardinality, 100)
        }
    }



    func testTrimArrayContainerCardinality() {
        
        autoreleasepool { () -> () in
            var ac = ArrayContainer()
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
        var rr = ArrayContainer()
        rr.add(UInt16(110))
        rr.add(UInt16(114))
        rr.add(UInt16(115))
        var array = [UInt16](count: 3, repeatedValue: 0)
        var pos = 0
        for i in rr{
            array[pos++] = i
        }
        XCTAssertEqual(array[0], UInt16(110))
        XCTAssertEqual(array[1], UInt16(114))
        XCTAssertEqual(array[2], UInt16(115))
    }


    func testBasic() {
        var rr = RoaringBitmap()
        var a = [UInt64](count: 4002, repeatedValue: 0)
        var pos = 0
        for (var k = 0; k < 4000; ++k) {
            rr.add(k)
            a[pos++] = UInt64(k)
        }
        rr.add(100000)
        a[pos++] = 100000
        rr.add(110000)
        a[pos++] = 110000
        let array = rr.asArray
        for (var i = 0; i < array.count; i++){
            if (array[i] != a[i]){
            println("rr : \(array[i]) a : \(a[i])")
            }
        }
        
        XCTAssert(array == a)
    }


    func testBitmapContainerCardinality() {
        var ac = BitmapContainer()
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
        var rr = BitmapContainer()
        rr.add(UInt16(110))
        rr.add(UInt16(114))
        rr.add(UInt16(115))
        var array = [UInt16](count: 3, repeatedValue: 0)
        var pos = 0
        for i in rr{
            array[pos++] = i
        }
        XCTAssertEqual(array[0], UInt16(110))
        XCTAssertEqual(array[1], UInt16(114))
        XCTAssertEqual(array[2], UInt16(115))
    }




    func testCardinality() {
        let N = 1024
        for (var gap = 7; gap < 100000; gap *= 10) {
            for (var offset = 2; offset <= 1024; offset *= 2) {
                var rb = RoaringBitmap()
                // check the add of values
                for (var k = 0; k < N; k++) {
                    rb.add(k * gap)
                    XCTAssertEqual(rb.cardinality, k + 1)
                }
                XCTAssertEqual(rb.cardinality, N);
                // check the add of existing values
                for (var k = 0; k < N; k++) {
                    rb.add(k * gap)
                    XCTAssertEqual(rb.cardinality, N)
                }
                
                var rb2 = RoaringBitmap()
                
                for (var k1 = 0; k1 < N; k1++) {
                    let value = k1 * gap * offset
                    rb2.add(value)
                    XCTAssertEqual(rb2.cardinality, k1 + 1)
                }
                
                XCTAssertEqual(rb2.cardinality, N)
                
                for (var k = 0; k < N; k++) {
                    rb2.add(k * gap * offset)
                    XCTAssertEqual(rb2.cardinality, N)
                }
                XCTAssertEqual(RoaringBitmap.and(lhs: rb, rhs: rb2).cardinality, N / offset)
                XCTAssertEqual(RoaringBitmap.or(lhs: rb, rhs: rb2).cardinality, 2 * N - N / offset)
                XCTAssertEqual(RoaringBitmap.xor(lhs: rb, rhs: rb2).cardinality, 2 * N - 2 * N / offset)
            }
        }
    }


    func testClear() {
        var rb = RoaringBitmap()
        for (var i = 0; i < 200000; i += 7){
            // dense
            rb.add(i)
        }
        for (var i = 200000; i < 400000; i += 177){
            // sparse
            rb.add(i)
        }
        
        var rb2 = RoaringBitmap()
        var rb3 = RoaringBitmap()
        for (var i = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        
        let rbCardinality = rb.cardinality
        rb.clear()
        XCTAssertEqual(0, rb.cardinality)
        XCTAssert(0 != rb2.cardinality)
        
        rb.add(4)
        rb3.add(4)
        var andresult = RoaringBitmap.and(lhs: rb, rhs: rb2)
        var orresult = RoaringBitmap.or(lhs: rb, rhs: rb2)
        
        XCTAssertEqual(1, andresult.cardinality)
        XCTAssertEqual(rb2.cardinality,orresult.cardinality);
        
        for (var i = 0; i < 200000; i += 4) {
            rb.add(i)
            rb3.add(i)
        }
        for (var i = 200000; i < 400000; i += 114) {
            rb.add(i)
            rb3.add(i)
        }
        
        let arrayrr = rb.asArray
        let arrayrr3 = rb3.asArray
        
        XCTAssert(arrayrr == arrayrr3)
    }


    func testContainerFactory() {
        var bc1 = BitmapContainer()
        var bc2 = BitmapContainer()
        var bc3 = BitmapContainer()
        var ac1 = ArrayContainer()
        var ac2 = ArrayContainer()
        var ac3 = ArrayContainer()
        
        for (var i:UInt16 = 0; i < 5000; i++){
            bc1.add( (i * 70))
        }
        for (var i:UInt16 = 0; i < 5000; i++){
            bc2.add( (i * 70))
        }
        for (var i:UInt16 = 0; i < 5000; i++){
            bc3.add( (i * 70))
        }
        
        for (var i:UInt16 = 0; i < 4000; i++){
            ac1.add( (i * 50))
        }
        for (var i:UInt16 = 0; i < 4000; i++){
            ac2.add( (i * 50))
        }
        for (var i:UInt16 = 0; i < 4000; i++){
            ac3.add((i * 50))
        }
        
        if let cac = ac1.clone() as? ArrayContainer{
            let rbc = cac.toBitmapContainer()
            XCTAssert(validate(rbc, ac: ac1))
        }
        
        if let cac = ac2.clone() as? ArrayContainer{
            let rbc = cac.toBitmapContainer()
            XCTAssert(validate(rbc, ac: ac2))
            
        }
        
        if let cac = ac3.clone() as? ArrayContainer{
            let rbc = cac.toBitmapContainer()
            XCTAssert(validate(rbc, ac: ac3))
            
        }
    }


    func testFlip1() {
        var rb = RoaringBitmap()
        
        rb.flip(100000, rangeEnd: 200000); // in-place on empty bitmap
        let rbcard = rb.cardinality
        XCTAssertEqual(100000, rbcard)
        
//        final BitSet bs = BitSet();
//        for i in 100000..<200000{
//            bs.set(i)
//        }
//        XCTAssert(equals(bs, rb));
    }

/*
func flipTest1A() {
    var rb = RoaringBitmap();
    
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 200000);
    final int rbcard = rb1.cardinality;
    XCTAssertEqual(100000, rbcard);
    XCTAssertEqual(0, rb.cardinality);
    
    final BitSet bs = BitSet();
    XCTAssert(equals(bs, rb)); // still empty?
    for (var i = 100000; i < 200000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb1));
}


func flipTest2() {
    var rb = RoaringBitmap();
    
    rb.flip(100000, 100000);
    final int rbcard = rb.cardinality;
    XCTAssertEqual(0, rbcard);
    
    final BitSet bs = BitSet();
    XCTAssert(equals(bs, rb));
}


func flipTest2A() {
    var rb = RoaringBitmap();
    
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 100000);
    rb.add(1); // will not affect rb1 (no shared container)
    final int rbcard = rb1.cardinality;
    XCTAssertEqual(0, rbcard);
    XCTAssertEqual(1, rb.cardinality);
    
    final BitSet bs = BitSet();
    XCTAssert(equals(bs, rb1));
    bs.set(1);
    XCTAssert(equals(bs, rb));
}


func flipTest3() {
    var rb = RoaringBitmap();
    
    rb.flip(100000, 200000); // got 100k-199999
    rb.flip(100000, 199991); // give back 100k-199990
    final int rbcard = rb.cardinality;
    
    XCTAssertEqual(9, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 199991; i < 200000; ++i)
        bs.set(i);
    
    XCTAssert(equals(bs, rb));
}


func flipTest3A() {
    System.out.println("FlipTest3A");
    var rb = RoaringBitmap();
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 200000);
    var rb2 = RoaringBitmap.flip(rb1, 100000,
        199991);
    final int rbcard = rb2.cardinality;
    
    XCTAssertEqual(9, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 199991; i < 200000; ++i)
        bs.set(i);
    
    XCTAssert(equals(bs, rb2));
}


func flipTest4() { // fits evenly on both ends
    System.out.println("FlipTest4");
    var rb = RoaringBitmap();
    rb.flip(100000, 200000); // got 100k-199999
    rb.flip(65536, 4 * 65536);
    final int rbcard = rb.cardinality;
    
    // 65536 to 99999 are 1s
    // 200000 to 262143 are 1s: total card
    
    XCTAssertEqual(96608, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 65536; i < 100000; ++i)
        bs.set(i);
    for (var i = 200000; i < 262144; ++i)
        bs.set(i);
    
    XCTAssert(equals(bs, rb));
}


func flipTest4A() {
    System.out.println("FlipTest4A");
    var rb = RoaringBitmap();
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 200000);
    var rb2 = RoaringBitmap.flip(rb1, 65536,
        4 * 65536);
    final int rbcard = rb2.cardinality;
    
    XCTAssertEqual(96608, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 65536; i < 100000; ++i)
        bs.set(i);
    for (var i = 200000; i < 262144; ++i)
        bs.set(i);
    
    XCTAssert(equals(bs, rb2));
}


func flipTest5() { // fits evenly on small end, multiple
    // containers
    System.out.println("FlipTest5");
    var rb = RoaringBitmap();
    rb.flip(100000, 132000);
    rb.flip(65536, 120000);
    final int rbcard = rb.cardinality;
    
    // 65536 to 99999 are 1s
    // 120000 to 131999
    
    XCTAssertEqual(46464, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 65536; i < 100000; ++i)
        bs.set(i);
    for (var i = 120000; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb));
}


func flipTest5A() {
    System.out.println("FlipTest5A");
    var rb = RoaringBitmap();
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 132000);
    var rb2 = RoaringBitmap
        .flip(rb1, 65536, 120000);
    final int rbcard = rb2.cardinality;
    
    XCTAssertEqual(46464, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 65536; i < 100000; ++i)
        bs.set(i);
    for (var i = 120000; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb2));
}


func flipTest6() { // fits evenly on big end, multiple containers
    System.out.println("FlipTest6");
    var rb = RoaringBitmap();
    rb.flip(100000, 132000);
    rb.flip(99000, 2 * 65536);
    final int rbcard = rb.cardinality;
    
    // 99000 to 99999 are 1000 1s
    // 131072 to 131999 are 928 1s
    
    XCTAssertEqual(1928, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 99000; i < 100000; ++i)
        bs.set(i);
    for (var i = 2 * 65536; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb));
}


func flipTest6A() {
    System.out.println("FlipTest6A");
    var rb = RoaringBitmap();
    var rb1 = RoaringBitmap
        .flip(rb, 100000, 132000);
    var rb2 = RoaringBitmap.flip(rb1, 99000,
        2 * 65536);
    final int rbcard = rb2.cardinality;
    
    XCTAssertEqual(1928, rbcard);
    
    final BitSet bs = BitSet();
    for (var i = 99000; i < 100000; ++i)
        bs.set(i);
    for (var i = 2 * 65536; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb2));
}


func flipTest7() { // within 1 word, first container
    System.out.println("FlipTest7");
    var rb = RoaringBitmap();
    rb.flip(650, 132000);
    rb.flip(648, 651);
    final int rbcard = rb.cardinality;
    
    // 648, 649, 651-131999
    
    XCTAssertEqual(132000 - 651 + 2, rbcard);
    
    final BitSet bs = BitSet();
    bs.set(648);
    bs.set(649);
    for (var i = 651; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb));
}


func flipTest7A() { // within 1 word, first container
    System.out.println("FlipTest7A");
    var rb = RoaringBitmap();
    var rb1 = RoaringBitmap.flip(rb, 650, 132000);
    var rb2 = RoaringBitmap.flip(rb1, 648, 651);
    final int rbcard = rb2.cardinality;
    
    // 648, 649, 651-131999
    
    XCTAssertEqual(132000 - 651 + 2, rbcard);
    
    final BitSet bs = BitSet();
    bs.set(648);
    bs.set(649);
    for (var i = 651; i < 132000; ++i)
        bs.set(i);
    XCTAssert(equals(bs, rb2));
}


func flipTestBig() {
    final int numCases = 1000;
    System.out.println("flipTestBig for " + numCases + " tests");
    var rb = RoaringBitmap();
    final BitSet bs = BitSet();
    final Random r = Random(3333);
    int checkTime = 2;
    
    for (var i = 0; i < numCases; ++i) {
        final int start = r.nextInt(65536 * 20);
        int end = r.nextInt(65536 * 20);
        if (r.nextDouble() < 0.1)
        end = start + r.nextInt(100);
        rb.flip(start, end);
        if (start < end)
        bs.flip(start, end); // throws exception
        // otherwise
        // insert some more ANDs to keep things sparser
        if (r.nextDouble() < 0.2) {
            var mask = RoaringBitmap();
            final BitSet mask1 = BitSet();
            final int startM = r.nextInt(65536 * 20);
            final int endM = startM + 100000;
            mask.flip(startM, endM);
            mask1.flip(startM, endM);
            mask.flip(0, 65536 * 20 + 100000);
            mask1.flip(0, 65536 * 20 + 100000);
            rb.and(mask);
            bs.and(mask1);
        }
        // see if we can detect incorrectly shared containers
        if (r.nextDouble() < 0.1) {
            var irrelevant = RoaringBitmap
                .flip(rb, 10, 100000);
            irrelevant.flip(5, 200000);
            irrelevant.flip(190000, 260000);
        }
        if (i > checkTime) {
            XCTAssert(equals(bs, rb));
            checkTime *= 1.5;
        }
    }
}


func flipTestBigA() {
    final int numCases = 1000;
    final BitSet bs = BitSet();
    final Random r = Random(3333);
    int checkTime = 2;
    RoaringBitmap rb1 = RoaringBitmap(), rb2 = null; // alternate
    // between
    // them
    
    for (var i = 0; i < numCases; ++i) {
        final int start = r.nextInt(65536 * 20);
        int end = r.nextInt(65536 * 20);
        if (r.nextDouble() < 0.1)
        end = start + r.nextInt(100);
        
        if ((i & 1) == 0) {
            rb2 = RoaringBitmap.flip(rb1, start, end);
            // tweak the other, catch bad sharing
            rb1.flip(r.nextInt(65536 * 20),
                r.nextInt(65536 * 20));
        } else {
            rb1 = RoaringBitmap.flip(rb2, start, end);
            rb2.flip(r.nextInt(65536 * 20),
                r.nextInt(65536 * 20));
        }
        
        if (start < end)
        bs.flip(start, end); // throws exception
        // otherwise
        // insert some more ANDs to keep things sparser
        if (r.nextDouble() < 0.2 && (i & 1) == 0) {
            var mask = RoaringBitmap();
            final BitSet mask1 = BitSet();
            final int startM = r.nextInt(65536 * 20);
            final int endM = startM + 100000;
            mask.flip(startM, endM);
            mask1.flip(startM, endM);
            mask.flip(0, 65536 * 20 + 100000);
            mask1.flip(0, 65536 * 20 + 100000);
            rb2.and(mask);
            bs.and(mask1);
        }
        
        if (i > checkTime) {
            System.out.println("check after " + i
                + ", card = " + rb2.cardinality);
            var rb = (i & 1) == 0 ? rb2
                : rb1;
            final boolean status = equals(bs, rb);
            XCTAssert(status);
            checkTime *= 1.5;
        }
    }
}

*/
    
    func testOR_0() {
        var rr = RoaringBitmap()
        for (var k = 0; k < 4000; ++k) {
            rr.add(k)
        }
        rr.add(100000)
        rr.add(110000)
        var rr2 = RoaringBitmap()
        for (var k = 0; k < 4000; ++k) {
            rr2.add(k)
        }
        
        var rror = RoaringBitmap.or(lhs: rr, rhs: rr2)
        
        let array = rror.asArray
        let arrayrr = rr.asArray
        
        XCTAssert(array == arrayrr)
        
        rr.or(rhs: rr2)
        let arrayirr = rr.asArray
        XCTAssert(array == arrayirr)
        
    }


    func testOR_1() {
        var rr = RoaringBitmap()
        for (var k = 4000; k < 4256; ++k){
            rr.add(k)
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            rr.add(k)
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            rr.add(k)
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            rr.add(k)
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            rr.add(k)
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            rr.add(k)
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            rr.add(k)
        }
        
        var rr2 = RoaringBitmap()
        for (var k = 4000; k < 4256; ++k) {
            rr2.add(k)
        }
        for (var k = 65536; k < 65536 + 4000; ++k) {
            rr2.add(k)
        }
        for (var k = 3 * 65536 + 2000; k < 3 * 65536 + 6000; ++k) {
            rr2.add(k);
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 7 * 65535; k < 7 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 10 * 65535; k < 10 * 65535 + 5000; ++k) {
            rr2.add(k);
        }
        var correct = RoaringBitmap.or(lhs: rr, rhs: rr2)
        rr.or(rhs: rr2)
        XCTAssert(correct == rr)
    }

 
    func testOR_2() {
        var arrayrr = [UInt64](count:4000 + 4000 + 2, repeatedValue:0)
        var pos = 0
        var rr = RoaringBitmap()
        for (var k = 0; k < 4000; ++k) {
            rr.add(k)
            arrayrr[pos++] = UInt64(k)
        }
        rr.add(100000);
        rr.add(110000);
        var rr2 = RoaringBitmap();
        for (var k = 4000; k < 8000; ++k) {
            rr2.add(k);
            arrayrr[pos++] = UInt64(k)
        }
        
        arrayrr[pos++] = 100000;
        arrayrr[pos++] = 110000;
        
        var rror = RoaringBitmap.or(lhs: rr, rhs: rr2);
        
        let arrayor = rror.asArray;
        
        XCTAssert(arrayor == arrayrr)
    }

/*
func ortest3() {
    final HashSet<Integer> V1 = HashSet<Integer>();
    final HashSet<Integer> V2 = HashSet<Integer>();
    
    var rr = RoaringBitmap();
    var rr2 = RoaringBitmap();
    // For the first 65536: rr2 has a bitmap container, and rr has
    // an array container.
    // We will check the union between a BitmapCintainer and an
    // arrayContainer
    for (var k = 0; k < 4000; ++k) {
        rr2.add(k);
        V1.add(k);
    }
    for (var k = 3500; k < 4500; ++k) {
        rr.add(k);
        V1.add(k);
    }
    for (var k = 4000; k < 65000; ++k) {
        rr2.add(k);
        V1.add(k);
    }
    
    // In the second node of each roaring bitmap, we have two bitmap
    // containers.
    // So, we will check the union between two BitmapContainers
    for (var k = 65536; k < 65536 + 10000; ++k) {
        rr.add(k);
        V1.add(k);
    }
    
    for (var k = 65536; k < 65536 + 14000; ++k) {
        rr2.add(k);
        V1.add(k);
    }
    
    // In the 3rd node of each Roaring Bitmap, we have an
    // ArrayContainer, so, we will try the union between two
    // ArrayContainers.
    for (var k = 4 * 65535; k < 4 * 65535 + 1000; ++k) {
        rr.add(k);
        V1.add(k);
    }
    
    for (var k = 4 * 65535; k < 4 * 65535 + 800; ++k) {
        rr2.add(k);
        V1.add(k);
    }
    
    // For the rest, we will check if the union will take them in
    // the result
    for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
        rr.add(k);
        V1.add(k);
    }
    
    for (var k = 7 * 65535; k < 7 * 65535 + 2000; ++k) {
        rr2.add(k);
        V1.add(k);
    }
    
    var rror = RoaringBitmap.or(rr, rr2);
    boolean valide = true;
    
    // Si tous les elements de rror sont dans V1 et que tous les
    // elements de
    // V1 sont dans rror(V2)
    // alors V1 == rror
    
    final Object[] tab = V1.asArray;
    final Vector<Integer> vector = Vector<Integer>();
    for (Object aTab : tab)
        vector.add((Integer) aTab);
    
    for (final int i : rror.asArray) {
        if (!vector.contains(new Integer(i))) {
            valide = false;
        }
        V2.add(i);
    }
    for (var i = 0; i < V1.size(); i++)
    if (!V2.contains(vector.elementAt(i))) {
        valide = false;
    }
    
    XCTAssertEqual(valide, true);
}
*/
// tests for how range falls on container boundaries

    //FIXME:fails
    func testOR_4() {
        var rb = RoaringBitmap()
        var rb2 = RoaringBitmap()
        
        for (var i = 0 ; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        let rb2card = rb2.cardinality
        
        // check or against an empty bitmap
        var orresult = RoaringBitmap.or(lhs: rb, rhs: rb2)
        var off = RoaringBitmap.or(lhs: rb2, rhs: rb)
        XCTAssert(orresult == off)
        
        XCTAssertEqual(rb2card, orresult.cardinality);
        
        for (var i = 500000; i < 600000; i += 14){
            rb.add(i)
        }
        for (var i = 200000; i < 400000; i += 3){
            rb2.add(i)
        }
        // check or against an empty bitmap
        var orresult2 = RoaringBitmap.or(lhs: rb, rhs: rb2)
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
        for (var gap = 1; gap <= 65536; gap *= 2) {
            final BitSet bs1 = BitSet();
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
                final BitSet bs2 = BitSet();
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

    
    func testIterator() {
        RoaringBitmap rb = RoaringBitmap();
        for(var k = 0; k<4000;++k) rb.add(k);
        for(var k = 0; k<1000;++k) rb.add(k*100);
        RoaringBitmap copy1 = RoaringBitmap();
        for(int x : rb) {
            copy1.add(x);
        }
        XCTAssert(copy1.equals(rb));
        RoaringBitmap copy2 = RoaringBitmap();
        IntIterator i = rb.getIntIterator();
        while(i.hasNext()) {
            copy2.add(i.next());
        }
        XCTAssert(copy2.equals(rb));
    }
*/

    func testSimpleCardinality() {
        let N = 512
        let gap = 70
        
        var rb = RoaringBitmap()
        for (var k = 0; k < N; k++) {
            rb.add(k * gap)
            XCTAssertEqual(rb.cardinality, k + 1)
        }
        XCTAssertEqual(rb.cardinality, N)
        for (var k = 0; k < N; k++) {
            rb.add(k * gap)
            XCTAssertEqual(rb.cardinality, N)
        }
        
    }

/*
func testSerialization() throws IOException, ClassNotFoundException {
    var rr = RoaringBitmap();
    for (var k = 65000; k < 2 * 65000; ++k)
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
    for (var k = 200; k < 400; ++k)
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
    for (var k = 65000; k < 2 * 65000; ++k)
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
    for (var k = 1; k <= 10000000; k+=10)
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

    //FIXME: fails
    func testXOR_0() {
        var rr = RoaringBitmap();
        for (var k = 4000; k < 4256; ++k){
            rr.add(k)
        }
        for (var k = 65536; k < 65536 + 4000; ++k){
            rr.add(k)
        }
        for (var k = 3 * 65536; k < 3 * 65536 + 9000; ++k){
            rr.add(k)
        }
        for (var k = 4 * 65535; k < 4 * 65535 + 7000; ++k){
            rr.add(k)
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 10000; ++k){
            rr.add(k)
        }
        for (var k = 8 * 65535; k < 8 * 65535 + 1000; ++k){
            rr.add(k)
        }
        for (var k = 9 * 65535; k < 9 * 65535 + 30000; ++k){
            rr.add(k)
        }
        
        var rr2 = RoaringBitmap()
        for (var k = 4000; k < 4256; ++k) {
            rr2.add(k);
        }
        for (var k = 65536; k < 65536 + 4000; ++k) {
            rr2.add(k);
        }
        for (var k = 3 * 65536 + 2000; k < 3 * 65536 + 6000; ++k) {
            rr2.add(k);
        }
        for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 7 * 65535; k < 7 * 65535 + 1000; ++k) {
            rr2.add(k);
        }
        for (var k = 10 * 65535; k < 10 * 65535 + 5000; ++k) {
            rr2.add(k);
        }
        var correct = RoaringBitmap.xor(lhs: rr, rhs: rr2);
        rr.xor(rhs: rr2);
        XCTAssert(correct == rr)
    }

/*
    func testXor_1() {
        final HashSet<Integer> V1 = HashSet<Integer>();
        final HashSet<Integer> V2 = HashSet<Integer>();
        
        var rr = RoaringBitmap();
        var rr2 = RoaringBitmap();
        // For the first 65536: rr2 has a bitmap container, and rr has
        // an array container.
        // We will check the union between a BitmapCintainer and an
        // arrayContainer
        for (var k = 0; k < 4000; ++k) {
            rr2.add(k);
            if (k < 3500)
            V1.add(k);
        }
        for (var k = 3500; k < 4500; ++k) {
            rr.add(k);
        }
        for (var k = 4000; k < 65000; ++k) {
            rr2.add(k);
            if (k >= 4500)
            V1.add(k);
        }
        
        // In the second node of each roaring bitmap, we have two bitmap
        // containers.
        // So, we will check the union between two BitmapContainers
        for (var k = 65536; k < 65536 + 30000; ++k) {
            rr.add(k);
        }
        
        for (var k = 65536; k < 65536 + 50000; ++k) {
            rr2.add(k);
            if (k >= 65536 + 30000)
            V1.add(k);
        }
        
        // In the 3rd node of each Roaring Bitmap, we have an
        // ArrayContainer. So, we will try the union between two
        // ArrayContainers.
        for (var k = 4 * 65535; k < 4 * 65535 + 1000; ++k) {
            rr.add(k);
            if (k >= 4 * 65535 + 800)
            V1.add(k);
        }
        
        for (var k = 4 * 65535; k < 4 * 65535 + 800; ++k) {
            rr2.add(k);
        }
        
        // For the rest, we will check if the union will take them in
        // the result
        for (var k = 6 * 65535; k < 6 * 65535 + 1000; ++k) {
            rr.add(k);
            V1.add(k);
        }
        
        for (var k = 7 * 65535; k < 7 * 65535 + 2000; ++k) {
            rr2.add(k);
            V1.add(k);
        }
        
        var rrxor = RoaringBitmap.xor(rr, rr2);
        boolean valide = true;
        
        // Si tous les elements de rror sont dans V1 et que tous les
        // elements de
        // V1 sont dans rror(V2)
        // alors V1 == rror
        final Object[] tab = V1.asArray;
        final Vector<Integer> vector = Vector<Integer>();
        for (Object aTab : tab)
            vector.add((Integer) aTab);
        
        for (final int i : rrxor.asArray) {
            if (!vector.contains(new Integer(i))) {
                valide = false;
            }
            V2.add(i);
        }
        for (var i = 0; i < V1.size(); i++)
        if (!V2.contains(vector.elementAt(i))) {
            valide = false;
        }
        
        XCTAssertEqual(valide, true);
    }

*/
    //FIXME:Fails
    func testXOR_4() {
        var rb = RoaringBitmap();
        var rb2 = RoaringBitmap();
        
        for (var i = 0; i < 200000; i += 4){
            rb2.add(i)
        }
        for (var i = 200000; i < 400000; i += 14){
            rb2.add(i)
        }
        let rb2card = rb2.cardinality
        
        // check or against an empty bitmap
        var xorresult = RoaringBitmap.xor(lhs: rb, rhs: rb2);
        var off = RoaringBitmap.or(lhs: rb2, rhs: rb);
        XCTAssert(xorresult == off)
        
        XCTAssertEqual(rb2card, xorresult.cardinality);
        
        for (var i = 500000; i < 600000; i += 14){
            rb.add(i);
        }
        for (var i = 200000; i < 400000; i += 3){
            rb2.add(i);
        }
        // check or against an empty bitmap
        var xorresult2 = RoaringBitmap.xor(lhs: rb, rhs: rb2);
        XCTAssertEqual(rb2card, xorresult.cardinality);
        
        XCTAssertEqual(rb2.cardinality + rb.cardinality, xorresult2.cardinality);
        rb.xor(rhs: rb2);
        XCTAssert(xorresult2 == rb)
        
    }

    
    func validate(bc:BitmapContainer , ac:ArrayContainer) -> Bool{
        // Checking the cardinalities of each container
        
        if (bc.cardinality != ac.cardinality) {
          //  XCTAssertEqual(bc.cardinality , ac.cardinality,"cardinality differs")
            println("cardinality differs")
            return false
        }
        // Checking that the two containers contain the same values
        var counter = 0
        
        var i = bc.nextSetBit(0)
        while (i >= 0) {
            ++counter;
            if (!ac.contains(UInt16(i))) {
                println("content differs")
                println(bc)
                println(ac)
                return false;
            }
            i = bc.nextSetBit(i + 1)
        }
        
        // checking the cardinality of the BitmapContainer
        return counter == bc.cardinality
    }


//
//    static func equals(bs:BitSet , rr:RoaringBitmap ) ->Bool{
//        let a = int[bs.cardinality()];
//        var pos = 0;
//        for (var x = bs.nextSetBit(0); x >= 0; x = bs.nextSetBit(x + 1)){
//            a[pos++] = x
//        }
//        return Arrays.equals(rr.asArray, a);
//    }

/*



// Test massive and.

func testMassiveAnd() {
    System.out.println("testing massive logical and");
    RoaringBitmap[] ewah = RoaringBitmap[1024];
    for (var k = 0; k < ewah.count; ++k)
        ewah[k] = RoaringBitmap();
    int howmany = 1000000;
    for (var k = 0; k < howmany; ++k) {
        ewah[Math.abs(k + 2 * k * k) % ewah.count].add(k);
    }
    for (var k = 3; k < ewah.count; k+=3)
        ewah[k].flip(13, howmany/2);
    for (int N = 2; N < ewah.count; ++N) {
        RoaringBitmap answer = ewah[0];
        for (var k = 1; k < N; ++k)
            answer = RoaringBitmap.and(answer, ewah[k]);
        
        RoaringBitmap answer2 = FastAggregation.and(Arrays.copyOf(ewah, N));
        XCTAssert(answer.equals(answer2));
        RoaringBitmap answer2b = FastAggregation.and(toIterator(Arrays.copyOf(ewah, N)));
        XCTAssert(answer.equals(answer2b));
        
    }
}




// Test massive or.

func testMassiveOr() {
    System.out
        .println("testing massive logical or (can take a couple of minutes)");
    final int N = 128;
    for (int howmany = 512; howmany <= 1000000; howmany *= 2) {
        RoaringBitmap[] ewah = RoaringBitmap[N];
        for (var k = 0; k < ewah.count; ++k)
            ewah[k] = RoaringBitmap();
        for (var k = 0; k < howmany; ++k) {
            ewah[Math.abs(k + 2 * k * k) % ewah.count].add(k);
        }
        for (var k = 3; k < ewah.count; k+=3)
            ewah[k].flip(13, howmany/2);
        RoaringBitmap answer = ewah[0];
        for (var k = 1; k < ewah.count; ++k) {
            answer = RoaringBitmap.or(answer,ewah[k]);
        }
        RoaringBitmap answer2 = FastAggregation.or(ewah);
        RoaringBitmap answer3 = FastAggregation.horizontal_or(ewah);
        RoaringBitmap answer3b = FastAggregation.horizontal_or(toIterator(ewah));
        XCTAssert(answer.equals(answer2));
        XCTAssert(answer.equals(answer3));
        XCTAssert(answer.equals(answer3b));
        
    }
}


// Test massive xor.


func testMassiveXOr() {
    System.out
        .println("testing massive logical xor (can take a couple of minutes)");
    final int N = 128;
    for (int howmany = 512; howmany <= 1000000; howmany *= 2) {
        RoaringBitmap[] ewah = RoaringBitmap[N];
        for (var k = 0; k < ewah.count; ++k)
            ewah[k] = RoaringBitmap();
        for (var k = 0; k < howmany; ++k) {
            ewah[Math.abs(k + 2 * k * k) % ewah.count].add(k);
        }
        for (var k = 3; k < ewah.count; k+=3)
            ewah[k].flip(13, howmany/2);
        
        RoaringBitmap answer = ewah[0];
        for (var k = 1; k < ewah.count; ++k) {
            answer = RoaringBitmap.xor(answer,ewah[k]);
        }
        RoaringBitmap answer2 = FastAggregation.xor(ewah);
        RoaringBitmap answer3 = FastAggregation.horizontal_xor(ewah);
        XCTAssert(answer.equals(answer2));
        XCTAssert(answer.equals(answer3));
    }
}
*/


}
