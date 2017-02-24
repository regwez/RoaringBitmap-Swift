//
//  RoaringBitmapUtilFunctions.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/16/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

public protocol BitshiftOperationsType {
    func <<(lhs: Self, rhs: Self) -> Self
    func >>(lhs: Self, rhs: Self) -> Self
    init(_ val: UInt8)
    init(_ val: Int)
    init(_ val: Int32)
    init(_ val: UInt32)
    init(_ val: UInt64)
}

extension Int    : BitshiftOperationsType {}
extension Int8   : BitshiftOperationsType {}
extension Int16  : BitshiftOperationsType {}
extension Int32  : BitshiftOperationsType {}
extension Int64  : BitshiftOperationsType {}
extension UInt   : BitshiftOperationsType {}
extension UInt8  : BitshiftOperationsType {}
extension UInt16 : BitshiftOperationsType {}
extension UInt32 : BitshiftOperationsType {}
extension UInt64 : BitshiftOperationsType {}



/**
* Returns the number of zero bits following the lowest-order ("rightmost")
* one-bit in the two's complement binary representation of the specified
* {@code long} value.  Returns 64 if the specified value has no
* one-bits in its two's complement representation, in other words if it is
* equal to zero.
*
* @param i the value whose number of trailing zeros is to be computed
* @return the number of zero bits following the lowest-order ("rightmost")
*     one-bit in the two's complement binary representation of the
*     specified {@code long} value, or 64 if the value is equal
*     to zero.
* @since 1.5
*/
//public func numberOfTrailingZeros(i:UInt64) -> Int {
//    
//    var x:UInt64 = 0
//    if (i == 0){
//        return 64
//    }
//    var n = UInt64(63)
//    var y = UInt64(i)
//    
//    if (y != 0) {
//        n = n - 32
//        x = y
//    } else {
//        x = i >> 32
//    }
//    y = x << 16;
//    if (y != 0) {
//        n = n - 16; x = y;
//    }
//    y = x << 8;
//    if (y != 0) {
//        n = n - 8; x = y;
//    }
//    y = x << 4;
//    if (y != 0) {
//        n = n - 4; x = y;
//    }
//    y = x << 2;
//    if (y != 0) {
//        n = n - 2; x = y;
//    }
//    let finalShiftedX = ((x << 1) >> 31)
//    return Int(n - finalShiftedX)
//}

public func numberOfTrailingZeros(_ value:UInt64) -> Int {
    
    if value == 0{
        return 64
    }
    var c:UInt64 = 64 // c will be the number of zero bits on the right
    let v = value & (~value + 1)
    if (v != 0 ){ c -= 1}
    if (v & 0x00000000FFFFFFFF) != 0 { c -= 32}
    if (v & 0x0000FFFF0000FFFF) != 0 { c -= 16}
    if (v & 0x00FF00FF00FF00FF) != 0 { c -= 8}
    if (v & 0x0F0F0F0F0F0F0F0F) != 0 { c -= 4}
    if (v & 0x3333333333333333) != 0 { c -= 2}
    if (v & 0x5555555555555555) != 0 { c -= 1}
    
    return Int(c)
}


/**
* Returns the number of zero bits preceding the highest-order
* ("leftmost") one-bit in the two's complement binary representation
* of the specified {@code long} value.  Returns 64 if the
* specified value has no one-bits in its two's complement representation,
* in other words if it is equal to zero.
*
* <p>Note that this method is closely related to the logarithm base 2.
* For all positive {@code long} values x:
* <ul>
* <li>floor(log<sub>2</sub>(x)) = {@code 63 - numberOfLeadingZeros(x)}
* <li>ceil(log<sub>2</sub>(x)) = {@code 64 - numberOfLeadingZeros(x - 1)}
* </ul>
*
* @param i the value whose number of leading zeros is to be computed
* @return the number of zero bits preceding the highest-order
*     ("leftmost") one-bit in the two's complement binary representation
*     of the specified {@code long} value, or 64 if the value
*     is equal to zero.
* @since 1.5
*/
public func numberOfLeadingZeros(_ i:UInt64) -> Int32{
    // HD, Figure 5-6
    if (i == 0){
        return 64
    }
    var n = UInt32(1)
    var x = UInt32(i >> 32)
    if (x == 0) { n += 32; x = UInt32(i); }
    if (x >> 16 == 0) { n += 16; x <<= 16; }
    if (x >> 24 == 0) { n +=  8; x <<=  8; }
    if (x >> 28 == 0) { n +=  4; x <<=  4; }
    if (x >> 30 == 0) { n +=  2; x <<=  2; }
    n -= x >> 31;
    return Int32(n)
}

/**
* Various useful methods for roaring bitmaps.
*/
public func countBits (_ input:UInt64) ->UInt64{
    var i = input
    // HD, Figure 5-14
    i = i - ((i >> 1) & UInt64(0x5555555555555555))
    i = (i & UInt64(0x3333333333333333)) + ((i >> 2) & UInt64(0x3333333333333333))
    i = (i + (i >> 4)) & UInt64(0x0f0f0f0f0f0f0f0f)
    i = i + (i >> 8)
    i = i + (i >> 16)
    i = i + (i >> 32)
    return i & UInt64(0x7f)
}

    
    /**
    * Find the smallest Integer larger than pos such that array[pos]>= min.
    * If none can be found, return length. Based on code by O. Kaser.
    *
    * @param array
    * @param pos
    * @param min
    * @return x greater than pos such that array[pos] is at least as large
    * as min, pos is is equal to length if it is not possible.
    */
internal func  advanceUntil(_ array:[UInt16], pos: Int, length:Int , min: UInt16) ->Int{
    var lower = pos + 1

    // special handling for a possibly common sequential case
    if (lower >= length || array[lower] >= min) {
        return lower
    }
    
    var spansize = 1 // could set larger
    // bootstrap an upper limit
    
    while (lower + spansize < length && array[lower + spansize] < min){
        spansize *= 2 // hoping for compiler will reduce to
    }
    // shift
    var upper = (lower + spansize < length) ? lower + spansize : length - 1
    
    // maybe we are lucky (could be common case when the seek ahead
    // expected
    // to be small and sequential will otherwise make us look bad)
    if (array[upper] == min) {
        return upper
    }
    
    if (array[upper] < min) {// means
        // array
        // has no
        // item
        // >= min
        // pos = array.length;
        return length
    }
    
    // we know that the next-smallest span was too small
    lower += (spansize / 2)
    
    // else begin binary search
    // invariant: array[lower]<min && array[upper]>min
    while (lower + 1 != upper) {
        let mid = (lower + upper) / 2
        if (array[mid] == min) {
            return mid
        } else if (array[mid] < min){
            lower = mid
        }else{
            upper = mid
        }
    }
    return upper
    
}
    
/**
* Compute the bitwise AND between two long arrays and write
* the set bits in the container.
*
* @param container where we write
* @param bitmap1   first bitmap
* @param bitmap2   second bitmap
*/
public func fillArrayAND(container:inout [UInt16] ,bitmap1: [UInt64], bitmap2: [UInt64] ) {
    var pos = 0
    if (bitmap1.count  != bitmap2.count){
        assert(false, "not supported")
    }
    for k in 0..<bitmap1.count{
        var bitset = bitmap1[k] & bitmap2[k]
        while (bitset != 0) {
            let notBitset = (~bitset) + 1
            let t = bitset & notBitset
            let cValue = UInt64(k * 64) + countBits(t - 1)
            container[pos++] = UInt16(cValue)
            bitset ^= t
        }
    }
}


    
/**
* Compute the bitwise ANDNOT between two long arrays and write
* the set bits in the container.
*
* @param container where we write
* @param bitmap1   first bitmap
* @param bitmap2   second bitmap
*/

public func fillArrayANDNOT(container:inout [UInt16] ,bitmap1: [UInt64], bitmap2: [UInt64] ) {
    var pos = 0
    if (bitmap1.count  != bitmap2.count){
        assert(false, "not supported")
    }
    for k in 0..<bitmap1.count{
        var bitset = bitmap1[k] & (~bitmap2[k])
        while (bitset != 0) {
            let notBitset = (~bitset) + 1
            let t = bitset & notBitset
            let cValue = UInt64(k * 64) + countBits(t - 1)
            print("pos = \(pos)")
            container[pos++] = UInt16(cValue)
            bitset ^= t
        }
    }
}
    
/**
* Compute the bitwise XOR between two long arrays and write
* the set bits in the container.
*
* @param container where we write
* @param bitmap1   first bitmap
* @param bitmap2   second bitmap
*/

public func fillArrayXOR(container:inout [UInt16] ,bitmap1: [UInt64], bitmap2: [UInt64] ) {
    var pos = 0
    if (bitmap1.count  != bitmap2.count){
        assert(false, "not supported")
    }
    for k in 0..<bitmap1.count{
        var bitset = bitmap1[k] ^ bitmap2[k]
        while (bitset != 0) {
            let notBitset = (~bitset) + 1
            let t = bitset & notBitset
            let cValue = UInt64(k * 64) + countBits(t - 1)
            print("pos = \(pos)")
            container[pos++] = UInt16(cValue)
            bitset ^= t
        }
    }
}

internal func highbits(_ x:UInt32) ->UInt16{
    return UInt16(x >> 16)
}

internal func lowbits(_ x:UInt32) ->UInt16{
    return UInt16(x & 0xFFFF)
}

internal func maxLowBit() ->UInt16{
    return UInt16(0xFFFF)
}

    
internal func unsignedBinarySearch(_ array: [UInt16], begin: Int, end: Int, k: UInt16) -> Int{
    let ikey = k
    // next line accelerates the possibly common case where the value would be inserted at the end
    if((end>0) && (array[end-1] < ikey)){
        return -end - 1
    }
    
    var  low = begin
    var  high = end - 1
    
    while (low <= high) {
        let middleIndex = (low + high) >> 1
        let middleValue = array[middleIndex]
    
        if (middleValue < ikey){
            low = middleIndex + 1
        }
        else if (middleValue > ikey){
            high = middleIndex - 1
            
        }else{
            return middleIndex
        }
    }
    return -(low + 1)
}
    
    /**
    * Compute the difference between two sorted lists and write the result to the provided
    * output array
    *
    * @param set1    first array
    * @param length1 length of first array
    * @param set2    second array
    * @param length2 length of second array
    * @param buffer  output array
    * @return cardinality of the difference
    */
public  func unsignedDifference(_ set1: [UInt16] , length1:Int , set2: [UInt16], length2:Int , buffer: inout [UInt16] ) ->Int {
    var pos = 0
    var k1 = 0
    var k2 = 0
    if (0 == length2) {
        let bufferPointer = UnsafeMutableRawPointer(mutating: buffer)
        let set1Pointer = UnsafeRawPointer(set1)
        memcpy(bufferPointer, set1 ,MemoryLayout<UInt16>.size * length1)
        return length1
    }
    
    if (0 == length1) {
        return 0
    }
    while (true) {
        if (set1[k1] < set2[k2]) {
            buffer[pos++] = set1[k1]
            k1 += 1
            if (k1 >= length1) {
                break
            }
        } else if (set1[k1] == set2[k2]) {
            k1 += 1
            k2 += 1
            if (k1 >= length1) {
    
                break
            }
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        } else {// if (val1>val2)
            k2 += 1;
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        }
    }
    return pos
}
    
    /**
    * Compute the exclusive union of two sorted lists and write the result to the provided
    * output array
    *
    * @param set1    first array
    * @param length1 length of first array
    * @param set2    second array
    * @param length2 length of second array
    * @param buffer  output array
    * @return cardinality of the exclusive union
    */
public  func unsignedExclusiveUnion2by2(_ set1: [UInt16] , length1:Int , set2: [UInt16], length2:Int , buffer: inout [UInt16] ) ->Int {
    var pos = 0
    var k1 = 0
    var k2 = 0
    
    if (0 == length2) {
        let bufferPointer = UnsafeMutableRawPointer(mutating: buffer)
        memcpy(bufferPointer, set1 ,MemoryLayout<UInt16>.size * length1)
        return length1
    }

    if (0 == length1) {
        let bufferPointer = UnsafeMutableRawPointer(mutating: buffer)
        memcpy(bufferPointer, set2 ,MemoryLayout<UInt16>.size * length2)
        return length2
    }

    
    while (true) {
        if (set1[k1] < set2[k2]) {
            buffer[pos++] = set1[k1]
            k1 += 1
            if (k1 >= length1) {
                for (; k2 < length2; k2 += 1){
                    buffer[pos++] = set2[k2]
                }
                break
            }
        } else if (set1[k1] == set2[k2]) {
            k1 += 1
            k2 += 1
            if (k1 >= length1) {
                for (; k2 < length2; k2 += 1){
                    buffer[pos++] = set2[k2]
                }
                break
            }
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        } else {// if (val1>val2)
            buffer[pos++] = set2[k2]
            k2 += 1
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        }
    }
    return pos;
}
    
/**
* Intersect two sorted lists and write the result to the provided
* output array
*
* @param set1    first array
* @param length1 length of first array
* @param set2    second array
* @param length2 length of second array
* @param buffer  output array
* @return cardinality of the Intersection
*/

public  func unsignedIntersect2by2(_ set1: [UInt16] , length1:Int , set2: [UInt16], length2:Int , buffer: inout [UInt16] ) ->Int {
 
    if (set1.count * 64 < set2.count) {
        return unsignedOneSidedGallopingIntersect2by2(set1, smallLength: length1, largeSet: set2, largeLength: length2, buffer: &buffer)
    } else if (set2.count * 64 < set1.count) {
        return unsignedOneSidedGallopingIntersect2by2(set2, smallLength: length2, largeSet: set1, largeLength: length1, buffer: &buffer)
    } else {
        return unsignedLocalIntersect2by2(set1, length1: length1, set2: set2, length2: length2, buffer: &buffer)
    }
}

        
internal func unsignedLocalIntersect2by2(_ set1: [UInt16] , length1:Int , set2: [UInt16], length2:Int , buffer: inout [UInt16] ) ->Int {

    if ((0 == length1) || (0 == length2)){
        return 0
    }
    var k1 = 0
    var k2 = 0
    var pos = 0

    mainwhile: while (true) {
        if (set2[k2] < set1[k1]) {
            repeat {
                k2 += 1
                if (k2 == length2){
                    break mainwhile
                }
            } while (set2[k2] < set1[k1]);
        }
        if (set1[k1] < set2[k2]) {
            repeat {
                k1 += 1
                if (k1 == length1){
                    break mainwhile
                }
            } while (set1[k1] < set2[k2])
        } else {
            // (set2[k2] == set1[k1])
            buffer[pos++] = set1[k1]
            k1 += 1
            if (k1 == length1){
                break
            }
            k2 += 1
            if (k2 == length2){
                break
            }
        }
    }
    return pos
}

internal func unsignedOneSidedGallopingIntersect2by2(_ smallSet: [UInt16] , smallLength:Int , largeSet: [UInt16], largeLength:Int , buffer: inout [UInt16] ) ->Int {

    if (0 == smallLength){
        return 0
    }
    var k1 = 0
    var k2 = 0
    var pos = 0
        
    while (true) {
        if (largeSet[k1] < smallSet[k2]) {
            k1 = advanceUntil(largeSet, pos: k1, length: largeLength, min: smallSet[k2])
            if (k1 == largeLength){
                break
            }
        }
        if (smallSet[k2] < largeSet[k1]) {
            k2 += 1
            if (k2 == smallLength){
                break
            }
        } else {
            // (set2[k2] == set1[k1])
            buffer[pos++] = smallSet[k2]
            k2 += 1
            if (k2 == smallLength){
                break
            }
            k1 = advanceUntil(largeSet, pos: k1, length: largeLength, min: smallSet[k2]);
            if (k1 == largeLength){
                break
            }
        }
    
    }
    return pos
    
}
    
    /**
    * Unite two sorted lists and write the result to the provided
    * output array
    *
    * @param set1    first array
    * @param length1 length of first array
    * @param set2    second array
    * @param length2 length of second array
    * @param buffer  output array
    * @return cardinality of the union
    */
public  func unsignedUnion2by2(_ set1: [UInt16] , length1:Int , set2: [UInt16], length2:Int , buffer: inout [UInt16] ) ->Int {


    var k1 = 0
    var k2 = 0
    var pos = 0
    
    if (0 == length2) {
        let bufferPointer = UnsafeMutableRawPointer(mutating: buffer)
        memcpy(bufferPointer, set1 ,MemoryLayout<UInt16>.size * length1)
        return length1
    }
    
    if (0 == length1) {
        let bufferPointer = UnsafeMutableRawPointer(mutating: buffer)
        memcpy(bufferPointer, set2 ,MemoryLayout<UInt16>.size * length2)
        return length2
    }
    
    while (true) {
        if (set1[k1] < set2[k2]) {
            buffer[pos++] = set1[k1]
            k1 += 1
            if (k1 >= length1) {
                for (; k2 < length2; k2 += 1){
                    buffer[pos++] = set2[k2]
                }
                break
            }
        } else if (set1[k1] == set2[k2]) {
            buffer[pos++] = set1[k1]
            k1 += 1
            k2 += 1
            if (k1 >= length1) {
                for (; k2 < length2; k2 += 1){
                    buffer[pos++] = set2[k2]
                }
                break
            }
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        } else {// if (set1[k1]>set2[k2])
            buffer[pos++] = set2[k2]
            k2 += 1
            if (k2 >= length2) {
                for (; k1 < length1; k1 += 1){
                    buffer[pos++] = set1[k1]
                }
                break
            }
        }
    }
    return pos
}
    
    

    
/**
* Given a word w, return the position of the jth true bit.
*
* @param w word
* @param j index
* @return position of jth true bit in w
*/
public func selectBit<WordType:UnsignedInteger>( word:WordType,bitIndex:UInt32) -> Int where WordType:BitshiftOperationsType{
    var sumtotal:WordType = 0
    let wtBitIndex = WordType(bitIndex)
    let bitsLimit = MemoryLayout<WordType>.size * 8
    for counter in 0..<bitsLimit {
        let bitPosition = (word >> WordType(counter)) & 1
        sumtotal += bitPosition
        if(sumtotal > wtBitIndex){
            return counter
        }
    }
    assert(bitIndex<UInt32(MemoryLayout<WordType>.size), "cannot local \(bitIndex)th bit in \(word) weight is \(MemoryLayout<WordType>.size)")
    return -20
}

