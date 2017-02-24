//
//  RoaringBitmap.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/16/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

/*  
* Based on RoaringBitmap Github project
* (c) Daniel Lemire, Owen Kaser, Samy Chambi, Jon Alvarado, Rory Graves, Björn Sperber
* Licensed under the Apache License, Version 2.0.
*/


/**
* RoaringBitmap, a compressed alternative to the BitSet.
*
* <pre>
* {@code
*
*
*      //...
*
*      RoaringBitmap rr = RoaringBitmap.bitmapOf(1,2,3,1000);
*      RoaringBitmap rr2 = new RoaringBitmap();
*      for(int k = 4000; k<4255;++k) rr2.add(k);
*      RoaringBitmap rror = RoaringBitmap.or(rr, rr2);
* }
* </pre>
*
*
*
*/
open class RoaringBitmap:  ImmutableBitmapDataProvider, Equatable {
    
    
    var highLowContainer:RoaringArray
    
    /**
    * Create an empty bitmap
    */
    public init() {
        highLowContainer = RoaringArray()
    }

    
    /**
    * Bitwise AND (intersection) operation. The provided bitmaps are *not*
    * modified. This operation is thread-safe as long as the provided
    * bitmaps remain unchanged.
    *
    * If you have more than 2 bitmaps, consider using the
    * FastAggregation class.
    *
    * @param x1 first bitmap
    * @param x2 other bitmap
    * @return result of the operation
    * @see FastAggregation#and(RoaringBitmap...)
    */
    open static func and(lhs x1: RoaringBitmap,rhs x2:  RoaringBitmap) -> RoaringBitmap{
            let answer = RoaringBitmap()
            var pos1 = 0
            var pos2 = 0
            let length1 = x1.highLowContainer.size
            let length2 = x2.highLowContainer.size
            
            main: while (pos1 < length1 && pos2 < length2) {
                var element1 = x1.highLowContainer.array[pos1]
                var element2 = x2.highLowContainer.array[pos2]
                repeat {
                    if (element1.key < element2.key) {
                        pos1 += 1
                        if (pos1 == length1){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                    } else if (element1.key > element2.key) {
                        pos2 += 1
                        if (pos2 == length2) {
                            break main
                        }
                        element2 = x2.highLowContainer.array[pos2]
                    } else {
                        let c = ContainerDispatcher.and(element1.value,rhs: element2.value)
                        
                        if (c.cardinality > 0){
                            answer.highLowContainer.array.append((key:element1.key, value:c))
                        }
                        pos1 += 1
                        pos2 += 1
                        if ((pos1 == length1) || (pos2 == length2)){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                        element2 = x2.highLowContainer.array[pos2]
                    }
                } while (true)
            }
            return answer
    }

    
    /**
    * Bitwise ANDNOT (difference) operation. The provided bitmaps are *not*
    * modified. This operation is thread-safe as long as the provided
    * bitmaps remain unchanged.
    *
    * @param x1 first bitmap
    * @param x2 other bitmap
    * @return result of the operation
    */
    open static func andNot(lhs x1: RoaringBitmap,rhs x2:  RoaringBitmap) -> RoaringBitmap{
        let answer = RoaringBitmap()
        var pos1 = 0
        var pos2 = 0
        let length1 = x1.highLowContainer.size
        let length2 = x2.highLowContainer.size
            
        main: while (pos1 < length1 && pos2 < length2) {
            var element1 = x1.highLowContainer.array[pos1]
            var element2 = x2.highLowContainer.array[pos2]
            repeat {
                if (element1.key < element2.key) {
                    answer.highLowContainer.appendCopy(x1.highLowContainer, index: pos1)
                    pos1 += 1
                    if (pos1 == length1){
                        break main
                    }
                    element1 = x1.highLowContainer.array[pos1]
                } else if (element1.key > element2.key) {
                    pos2 += 1;
                    if (pos2 == length2) {
                        break main
                    }
                    element2 = x2.highLowContainer.array[pos2]
                } else {
                    let c = ContainerDispatcher.andNot(element1.value,rhs: element2.value)
                    
                    if (c.cardinality > 0){
                        answer.highLowContainer.array.append((key:element1.key, value:c))
                    }
                    pos1 += 1
                    pos2 += 1
                    if ((pos1 == length1) || (pos2 == length2)){
                        break main
                    }
                    element1 = x1.highLowContainer.array[pos1]
                    element2 = x2.highLowContainer.array[pos2]
                }
            } while (true)
        }
        if (pos2 == length2) {
            answer.highLowContainer.appendCopy(x1.highLowContainer, startingIndex: pos1, end: length1);
        }
        return answer
    }
    
    /**
    * Generate a bitmap with the specified values set to true. The provided
    * integers values don't have to be in sorted order, but it may be
    * preferable to sort them from a performance point of view.
    *
    * @param dat set values
    * @return a new bitmap
    */
    open static func bitmapOf(_ dataArray:[UInt32]) -> RoaringBitmap{
        let ans = RoaringBitmap()
        for i in dataArray{
            ans.add(i)
        }
        return ans
    }
    
    /**
    * Complements the bits in the given range, from rangeStart (inclusive)
    * rangeEnd (exclusive). The given bitmap is unchanged.
    *
    * @param bm         bitmap being negated
    * @param rangeStart inclusive beginning of range
    * @param rangeEnd   exclusive ending of range
    * @return a new Bitmap
    */
    open static func flip( _ bm:RoaringBitmap,rangeStart:UInt32, rangeEnd:UInt32) -> RoaringBitmap{
        if (rangeStart >= rangeEnd) {
            return bm.clone()
        }
        
        let answer = RoaringBitmap()
        let hbStart = highbits(rangeStart)
        let lbStart = lowbits(rangeStart)
        let hbLast = highbits(rangeEnd - 1)
        let lbLast = lowbits(rangeEnd - 1)
        
        // copy the containers before the active area
        answer.highLowContainer.appendCopiesUntil(bm.highLowContainer, stoppingKey: hbStart)
        
        let max = maxLowBit()
        for  hb in hbStart...hbLast {
            let containerStart = Int((hb == hbStart) ? lbStart : 0)
            let containerLast = Int((hb == hbLast) ? lbLast : max)
            
            let i = bm.highLowContainer.getIndex(hb);
            let j = answer.highLowContainer.getIndex(hb);
            assert (j < 0)
            
            if (i >= 0) {
                let (_,containerAtI) = bm.highLowContainer.array[i]
                let  c = containerAtI.not(rangeStart: containerStart, rangeEnd: containerLast)
                if (c.cardinality > 0){
                    answer.highLowContainer.array.insert((key:hb, value:c),at:-j - 1)
                }
                
            } else { // *think* the range of ones must never be
                // empty.
                let c = ContainerDispatcher.rangeOfOnes(containerStart,lastIndex: containerLast)
                answer.highLowContainer.array.insert((key:hb, value:c),at:-j - 1)
            }
        }
        // copy the containers after the active area.
        answer.highLowContainer.appendCopiesAfter(bm.highLowContainer, beforeStart: hbLast)
        
        return answer;
    }
    
    /**
    * Bitwise OR (union) operation. The provided bitmaps are *not*
    * modified. This operation is thread-safe as long as the provided
    * bitmaps remain unchanged.
    *
    * If you have more than 2 bitmaps, consider using the
    * FastAggregation class.
    *
    * @param x1 first bitmap
    * @param x2 other bitmap
    * @return result of the operation
    * @see FastAggregation#or(RoaringBitmap...)
    * @see FastAggregation#horizontal_or(RoaringBitmap...)
    */    
    open static func or(lhs x1: RoaringBitmap, rhs x2:  RoaringBitmap) -> RoaringBitmap{
            let answer = RoaringBitmap()
            var pos1 = 0
            var pos2 = 0
            let length1 = x1.highLowContainer.size
            let length2 = x2.highLowContainer.size
            
            main: while (pos1 < length1 && pos2 < length2) {
                var element1 = x1.highLowContainer.array[pos1]
                var element2 = x2.highLowContainer.array[pos2]
                repeat {
                    if (element1.key < element2.key) {
                        answer.highLowContainer.appendCopy(x1.highLowContainer, index: pos1)
                        pos1 += 1
                        if (pos1 == length1){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                    } else if (element1.key > element2.key) {
                        answer.highLowContainer.appendCopy(x2.highLowContainer, index: pos2)
                        pos2 += 1;
                        if (pos2 == length2) {
                            break main
                        }
                        element2 = x2.highLowContainer.array[pos2]
                    } else {
                        let c = ContainerDispatcher.or(element1.value,rhs: element2.value)
                
                        answer.highLowContainer.array.append((key:element1.key, value:c))
                        pos1 += 1
                        pos2 += 1
                        if ((pos1 == length1) || (pos2 == length2)){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                        element2 = x2.highLowContainer.array[pos2]
                    }
                } while (true)
            }
            if (pos1 == length1) {
                answer.highLowContainer.appendCopy(x2.highLowContainer, startingIndex: pos2, end: length2)
            }else if (pos2 == length2) {
                answer.highLowContainer.appendCopy(x1.highLowContainer, startingIndex: pos1, end: length1)
            }
            return answer
    }
    
    /**
    * Rank returns the number of integers that are smaller or equal to x (Rank(infinity) would be GetCardinality()).
    * @param x upper limit
    *
    * @return the rank
    */
    open func rank(upperLimit:UInt32) -> UInt32{
        var size = 0
        let xhigh = highbits(upperLimit)
        
        for (key,container) in highLowContainer.array {
            if( key < xhigh ){
                size += container.cardinality
            }else{
                return UInt32(size + container.rank(lowbits(upperLimit)))
            }
        }
        return UInt32(size)
    }
    
    
    /**
    * Return the jth value stored in this bitmap.
    *
    * @param j index of the value
    *
    * @return the value
    */
    open func select(atIndex index:UInt32) -> UInt32{
        var leftover = index
        for (key,container) in highLowContainer.array {
            
            let thiscard = UInt32(container.cardinality)
            if(thiscard > leftover) {
                let  keycontrib = UInt64(key) << UInt64(16)
                let  lowcontrib = container.select(leftover)
                return  lowcontrib + UInt32(keycontrib)
            }
            leftover -= thiscard
        }
        assert(false,"select \(index) when the cardinality is \(self.cardinality)")
    }
    
    
    /**
    * Bitwise XOR (symmetric difference) operation. The provided bitmaps
    * are *not* modified. This operation is thread-safe as long as the
    * provided bitmaps remain unchanged.
    *
    * If you have more than 2 bitmaps, consider using the
    * FastAggregation class.
    *
    * @param x1 first bitmap
    * @param x2 other bitmap
    * @return result of the operation
    * @see FastAggregation#xor(RoaringBitmap...)
    * @see FastAggregation#horizontal_xor(RoaringBitmap...)
    */
    open static func xor(lhs x1: RoaringBitmap,rhs x2:  RoaringBitmap) -> RoaringBitmap{
            let answer = RoaringBitmap()
            var pos1 = 0
            var pos2 = 0
            let length1 = x1.highLowContainer.size
            let length2 = x2.highLowContainer.size
            
            main: while (pos1 < length1 && pos2 < length2) {
                var element1 = x1.highLowContainer.array[pos1]
                var element2 = x2.highLowContainer.array[pos2]
                repeat {
                    if (element1.key < element2.key) {
                        answer.highLowContainer.appendCopy(x1.highLowContainer, index: pos1)
                        pos1 += 1
                        if (pos1 == length1){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                    } else if (element1.key > element2.key) {
                        answer.highLowContainer.appendCopy(x2.highLowContainer, index: pos2)
                        pos2 += 1;
                        if (pos2 == length2) {
                            break main
                        }
                        element2 = x2.highLowContainer.array[pos2]
                    } else {
                        let c = ContainerDispatcher.xor(element1.value,rhs: element2.value)
                        
                        if (c.cardinality > 0){
                            answer.highLowContainer.array.append((key:element1.key, value:c))
                        }
                        pos1 += 1
                        pos2 += 1
                        if ((pos1 == length1) || (pos2 == length2)){
                            break main
                        }
                        element1 = x1.highLowContainer.array[pos1]
                        element2 = x2.highLowContainer.array[pos2]
                    }
                } while (true)
            }
            if (pos1 == length1) {
                answer.highLowContainer.appendCopy(x2.highLowContainer, startingIndex: pos2, end: length2)
            }else if (pos2 == length2) {
                answer.highLowContainer.appendCopy(x1.highLowContainer, startingIndex: pos1, end: length1)
            }
            return answer
    }

    
    
    /**
    * set the value to "true", whether it already appears or not.
    *
    * @param x integer value
    */
    open func add(_ value:UInt32) {
      //  _cachedCardinality = nil
        let hb:UInt16 = highbits(value)
        let index = highLowContainer.getIndex(hb)
        if (index >= 0) {
            let currentContainer = highLowContainer.array[index].value
            if let uw_updatedContainer = currentContainer.add(lowbits(value)){
                highLowContainer.array[index].value = uw_updatedContainer
            }
        } else {
            let newac = ArrayContainer()
            if let uw_newac = newac.add(lowbits(value)){
                highLowContainer.array.insert((key:hb, value:uw_newac),at:-index - 1)
            }else{
                highLowContainer.array.insert((key:hb, value:newac),at:-index - 1)
            }
            
        }
    }
    
    /**
    * In-place bitwise AND (intersection) operation. The current bitmap is
    * modified.
    *
    * @param x2 other bitmap
    */
    open func and(rhs x2:  RoaringBitmap){
      //  _cachedCardinality = nil
        var pos1 = 0
        var pos2 = 0
        var length1 = highLowContainer.size
        let length2 = x2.highLowContainer.size
        
        /*
        * TODO: This could be optimized quite a bit when one bitmap is
        * much smaller than the other one.
    */
        main: while (pos1 < length1 && pos2 < length2) {
            var element1 = highLowContainer.array[pos1]
            var element2 = x2.highLowContainer.array[pos2]
            repeat {
                if (element1.key < element2.key) {
                    highLowContainer.array.remove(at: pos1)
                    length1 -= 1
                    if (pos1 == length1){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                } else if (element1.key > element2.key) {
                    pos2 += 1
                    if (pos2 == length2) {
                        break main
                    }
                    element2 = x2.highLowContainer.array[pos2]
                } else {
                    let c = ContainerDispatcher.iand(element1.value,rhs: element2.value)
                    
                    if (c.cardinality > 0){
                        highLowContainer.array[pos1].value = c
                        pos1 += 1
                    }else{
                        highLowContainer.array.remove(at: pos1)
                        length1 -= 1
                    }
                    
                    pos2 += 1
                    if ((pos1 == length1) || (pos2 == length2)){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                    element2 = x2.highLowContainer.array[pos2]
                }
            } while (true)
        }
        highLowContainer.trim(toLength: pos1)
    }
    
    /**
    * In-place bitwise ANDNOT (difference) operation. The current bitmap is
    * modified.
    *
    * @param x2 other bitmap
    */
    open func andNot(rhs x2:  RoaringBitmap){
        //_cachedCardinality = nil
        var pos1 = 0
        var pos2 = 0
        var length1 = highLowContainer.size
        let length2 = x2.highLowContainer.size
        
        /*
        * TODO: This could be optimized quite a bit when one bitmap is
        * much smaller than the other one.
        */
        main: while (pos1 < length1 && pos2 < length2) {
            var element1 = highLowContainer.array[pos1]
            var element2 = x2.highLowContainer.array[pos2]
            repeat {
                if (element1.key < element2.key) {
                   pos1 += 1
                    if (pos1 == length1){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                } else if (element1.key > element2.key) {
                    pos2 += 1
                    if (pos2 == length2) {
                        break main
                    }
                    element2 = x2.highLowContainer.array[pos2]
                } else {
                    let c = ContainerDispatcher.iandNot(element1.value,rhs: element2.value)
                    
                    if (c.cardinality > 0){
                        highLowContainer.array[pos1].value = c
                        pos1 += 1
                    }else{
                        highLowContainer.array.remove(at: pos1)
                        length1 -= 1
                    }
                    
                    pos2 += 1
                    if ((pos1 == length1) || (pos2 == length2)){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                    element2 = x2.highLowContainer.array[pos2]
                }
            } while (true)
        }
        highLowContainer.trim(toLength: length1)
    }

    
    /**
    * reset to an empty bitmap; result occupies as much space a newly
    * created bitmap.
    */
    open func clear() {
        highLowContainer = RoaringArray() // lose references
        //_cachedCardinality = nil
        _sizeInBytes = nil
    }

    open func clone() -> RoaringBitmap{
        let x = RoaringBitmap()
        x.highLowContainer = highLowContainer.clone()
        return x
    
    }
    
    /**
    * Checks whether the value in included, which is equivalent to checking
    * if the corresponding bit is set (get in BitSet class).
    *
    * @param x integer value
    * @return whether the integer value is included.
    */
    open func contains(_ value:UInt32) -> Bool{
        let hb = highbits(value)
        let c = highLowContainer.getContainer(hb)
        if let uw_c = c{
            return uw_c.contains(lowbits(value))
        }
        return false
    }
    
    /**
    * Deserialize (retrieve) this bitmap.
    *
    * The current bitmap is overwritten.
    *
    * @param in the DataInput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
//    public void deserialize(DataInput in) throws IOException {
//        this.highLowContainer.deserialize(in);
//    }
    

    
    
    /**
    * Modifies the current bitmap by complementing the bits in the given
    * range, from rangeStart (inclusive) rangeEnd (exclusive).
    *
    * @param rangeStart inclusive beginning of range
    * @param rangeEnd   exclusive ending of range
    */
    open func flip(_ rangeStart:UInt32, rangeEnd:UInt32){
     //   _cachedCardinality = nil
        if (rangeStart >= rangeEnd) {
            return // empty range
        }
        
        let hbStart = highbits(rangeStart)
        let lbStart = lowbits(rangeStart)
        let hbLast = highbits(rangeEnd - 1)
        let lbLast = lowbits(rangeEnd - 1)
        
        
        let max = maxLowBit()
        for  hb in hbStart...hbLast {
            // first container may contain partial range
            let containerStart = Int((hb == hbStart) ? lbStart : 0)
            // last container may contain partial range
            let containerLast = Int((hb == hbLast) ? lbLast : max)
            
            let i = highLowContainer.getIndex(hb)
            
            if (i >= 0) {
                let (_,containerAtI) = highLowContainer.array[i]
                let  c = containerAtI.inot(rangeStart: containerStart, rangeEnd: containerLast)
                if (c.cardinality > 0){
                    highLowContainer.array[i].value = c
                }else{
                    highLowContainer.array.remove(at: i)
                }
                
            } else { // *think* the range of ones must never be
                // empty.
                let c = ContainerDispatcher.rangeOfOnes(containerStart,lastIndex: containerLast)
                highLowContainer.array.insert((key:hb, value:c),at:-i - 1)
            }
        }
    }

    
    /**
    * Returns the number of distinct integers added to the bitmap (e.g.,
    * number of bits set).
    *
    * @return the cardinality
    */
    open var cardinality:Int {
//        if let uw_cardinality = _cachedCardinality{
//            return uw_cardinality
//        }
        let size = highLowContainer.array.reduce(0) { $0 + $1.value.cardinality }
        return size
//        _cachedCardinality = size
//        return _cachedCardinality!
    }
    
   // private var _cachedCardinality:Int? = nil
    
//FIXME:    /**
//    * @return a custom iterator over set bits, the bits are traversed
//    * in ascending sorted order
//    */
//    public IntIterator getIntIterator() {
//        return new RoaringIntIterator();
//    }
//    
//    /**
//    * @return a custom iterator over set bits, the bits are traversed
//    * in descending sorted order
//    */
//    public IntIterator getReverseIntIterator() {
//        return new RoaringReverseIntIterator();
//    }
    
    /**
    * Estimate of the memory usage of this data structure. This
    * can be expected to be within 1% of the true memory usage.
    *
    * @return estimated memory usage.
    */
    open var sizeInBytes:Int {
        if let uw_sizeInBytes = _sizeInBytes{
            return uw_sizeInBytes
        }
        
        let size = highLowContainer.array.reduce(8) { $0 + 2 + $1.value.sizeInBytes }
        _sizeInBytes = size
        return size
    }
    
    fileprivate var _sizeInBytes:Int? = nil
    
    
    
    
    /**
    * iterate over the positions of the true values.
    *
    * @return the iterator
    */

//FIXME:    public Iterator<Integer> iterator() {
//        return new Iterator<Integer>() {
//            private int hs = 0;
//            
//            private ShortIterator iter;
//            
//            private int pos = 0;
//            
//            private int x;
//            
//            
//            public boolean hasNext() {
//                return pos < RoaringBitmap.this.highLowContainer.size();
//            }
//            
//            private Iterator<Integer> init() {
//                if (pos < RoaringBitmap.this.highLowContainer.size()) {
//                    iter = RoaringBitmap.this.highLowContainer.getContainerAtIndex(pos).getShortIterator();
//                    hs = RoaringBitmap.this.highLowContainer.getKeyAtIndex(pos) << 16
//                }
//                return this;
//            }
//            
//            
//            public Integer next() {
//                x = iter.next() | hs
//                if (!iter.hasNext()) {
//                    ++pos;
//                    init();
//                }
//                return x;
//            }
//            
//            
//            public void remove() {
//                if ((x & hs) == hs) {// still in same container
//                    iter.remove();
//                } else {
//                    RoaringBitmap.this.remove(x);
//                }
//            }
//            
//            }.init();
//    }
    
    /**
    * Checks whether the bitmap is empty.
    *
    * @return true if this bitmap contains no set bit
    */
    open var isEmpty:Bool{
        return highLowContainer.size == 0
    }
    
    
    /**
    * In-place bitwise OR (union) operation. The current bitmap is
    * modified.
    *
    * @param x2 other bitmap
    */
    open func or(rhs x2:  RoaringBitmap){
        //_cachedCardinality = nil
        var pos1 = 0
        var pos2 = 0
        var length1 = highLowContainer.size
        let length2 = x2.highLowContainer.size
        
        main: while (pos1 < length1 && pos2 < length2) {
            var element1 = highLowContainer.array[pos1]
            var element2 = x2.highLowContainer.array[pos2]
            repeat {
                if (element1.key < element2.key) {
                    pos1 += 1
                    if (pos1 == length1){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                } else if (element1.key > element2.key) {
                    highLowContainer.array.insert(element2,at:pos1)
                    pos1 += 1
                    length1 += 1
                    pos2 += 1
                    if (pos2 == length2) {
                        break main
                    }
                    element2 = x2.highLowContainer.array[pos2]
                } else {
                    let c = ContainerDispatcher.ior(element1.value,rhs: element2.value)
                    
                    highLowContainer.array[pos1].value = c
                    pos1 += 1
                    pos2 += 1
                    if ((pos1 == length1) || (pos2 == length2)){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                    element2 = x2.highLowContainer.array[pos2]
                }
            } while (true)
        }
        if (pos1 == length1) {
            highLowContainer.appendCopy(x2.highLowContainer, startingIndex: pos2, end: length2)
        }
    }
    
//FIXME:    public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
//        this.highLowContainer.readExternal(in);
//    }
    
    /**
    * If present remove the specified integers (effectively, sets its bit
    * value to false)
    *
    * @param x UInt32 value representing the index in a bitmap
    */
    open func remove(_ value:UInt32) {
        //_cachedCardinality = nil
        let hb = highbits(value)
        let i = highLowContainer.getIndex(hb)
        if (i < 0){
            return
        }
        _ = highLowContainer.array[i].value.remove(lowbits(value))
        if (highLowContainer.array[i].value.cardinality == 0){
            highLowContainer.array.remove(at: i)
        }
    }
    
    /**
    * Serialize this bitmap.
    *
    * The current bitmap is not modified.
    *
    * @param out the DataOutput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
//FIXME:    public void serialize(DataOutput out) throws IOException {
//        this.highLowContainer.serialize(out);
//    }
    
    /**
    * Report the number of bytes required to serialize this bitmap.
    * This is the number of bytes written out when using the serialize
    * method. When using the writeExternal method, the count will be
    * higher due to the overhead of Java serialization.
    *
    * @return the size in bytes
    */
    open var serializedSizeInBytes:Int {
        return highLowContainer.serializedSizeInBytes
    }
    
    /**
    * Create a new Roaring bitmap containing at most maxcardinality integers.
    *
    * @param maxcardinality maximal cardinality
    * @return a new bitmap with cardinality no more than maxcardinality
    */
    open func limit(maxCardinality:UInt32) -> ImmutableBitmapDataProvider{
        let answer = RoaringBitmap()
        var currentCardinality = 0
        for (var i = 0; (currentCardinality < Int(maxCardinality)) && ( i < highLowContainer.size); i += 1) {
            let (key,c) = highLowContainer.array[i]
            
            if(c.cardinality + currentCardinality <= Int(maxCardinality)) {
                answer.highLowContainer.appendCopy(highLowContainer, index: i);
                currentCardinality += c.cardinality
            }  else {
                let leftover = Int(maxCardinality) - currentCardinality;
                let limited = c.limit(leftover)
                answer.highLowContainer.array.append((key:key,value:limited ))
                break
            }
        }
        return answer
    }
    
    /**
    * Return the set values as an array. The integer
    * values are in sorted order.
    *
    * @return array representing the set values.
    */
    open var asArray:[UInt32] {
        let totalCardinality:Int = Int(self.cardinality)
        if totalCardinality == 0{
            return []
        }
        var array = [UInt32](repeating: 0,count: totalCardinality)
        var pos = 0
        
        for (key,c) in highLowContainer.array{
            let hs = UInt32(UInt64(key) << 16)
            c.fillLeastSignificant16bits(&array, index: pos, mask: hs)
            pos += c.cardinality
        }
        return array
    }
    
   
    
    /**
    * Recover allocated but unused memory.
    */
    open func trim() {
        let localHighLowContainer = self.highLowContainer
        for (_,container) in localHighLowContainer.array {
            container.trim()
        }
    }
    
    
   
//FIXME:    public func writeExternal(ObjectOutput out) {
//        this.highLowContainer.writeExternal(out)
//    }
    
    /**
    * In-place bitwise XOR (symmetric difference) operation. The current
    * bitmap is modified.
    *
    * @param x2 other bitmap
    */
    open func xor(rhs x2:  RoaringBitmap){
        //_cachedCardinality = nil
        var pos1 = 0
        var pos2 = 0
        var length1 = highLowContainer.size
        let length2 = x2.highLowContainer.size
        
        main: while (pos1 < length1 && pos2 < length2) {
            var element1 = highLowContainer.array[pos1]
            var element2 = x2.highLowContainer.array[pos2]
            repeat {
                if (element1.key < element2.key) {
                    pos1 += 1
                    if (pos1 == length1){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                } else if (element1.key > element2.key) {
                    highLowContainer.array.insert( element2,at:pos1)
                    pos1 += 1
                    length1 += 1
                    pos2 += 1
                    if (pos2 == length2) {
                        break main
                    }
                    element2 = x2.highLowContainer.array[pos2]
                } else {
                    let c = ContainerDispatcher.ixor(element1.value,rhs: element2.value)
                    if (c.cardinality > 0) {
                        highLowContainer.array[pos1].value = c
                        pos1 += 1
                    }else{
                        highLowContainer.array.remove(at: pos1)
                        length1 -= 1
                    }
                    pos2 += 1
                    if ((pos1 == length1) || (pos2 == length2)){
                        break main
                    }
                    element1 = highLowContainer.array[pos1]
                    element2 = x2.highLowContainer.array[pos2]
                }
            } while (true)
        }
        if (pos1 == length1) {
            highLowContainer.appendCopy(x2.highLowContainer, startingIndex: pos2, end: length2)
        }
    }
    

}



//MARK: Hashable  Protocol
extension RoaringBitmap:Hashable{
    public var hashValue: Int {
        return highLowContainer.hashValue
    }
}

extension RoaringBitmap:CustomStringConvertible{
    /**
    * A string describing the bitmap.
    *
    * @return the string
    */
    
    public var description: String{
        var answer = "{"
        
//        final IntIterator i = this.getIntIterator();
//        
//        if (i.hasNext())
//        answer.append(i.next());
//        while (i.hasNext()) {
//            answer.append(",");
//            answer.append(i.next());
//        }
        answer += "}"
        return answer
    }
}
//FIXME:{
//
//    private final class RoaringIntIterator implements IntIterator {
//        private int hs = 0;
//        
//        private ShortIterator iter;
//        
//        private int pos = 0;
//        
//        private int x;
//        
//        private RoaringIntIterator() {
//            nextContainer();
//        }
//        
//        
//        public boolean hasNext() {
//            return pos < RoaringBitmap.this.highLowContainer.size();
//        }
//        
//        private void nextContainer() {
//            if (pos < RoaringBitmap.this.highLowContainer.size()) {
//                iter = RoaringBitmap.this.highLowContainer.getContainerAtIndex(pos).getShortIterator();
//                hs = RoaringBitmap.this.highLowContainer.getKeyAtIndex(pos) << 16;
//            }
//        }
//        
//        
//        public int next() {
//            x = iter.next() | hs;
//            if (!iter.hasNext()) {
//                ++pos;
//                nextContainer();
//            }
//            return x;
//        }
//        
//        
//        public IntIterator clone() {
//            try {
//                RoaringIntIterator x = (RoaringIntIterator) super.clone();
//                x.iter =  this.iter.clone();
//                return x;
//            } catch (CloneNotSupportedException e) {
//                return nil;// will not happen
//            }
//        }
//        
//    }
//    
//    private final class RoaringReverseIntIterator implements IntIterator {
//        
//        int hs = 0;
//        ShortIterator iter;
//        // don't need an int because we go to 0, not Short.MAX_VALUE, and signed UInt16s underflow well below zero
//        UInt16 pos = (UInt16) (RoaringBitmap.this.highLowContainer.size() - 1);
//        
//        private RoaringReverseIntIterator() {
//            nextContainer();
//        }
//        
//        
//        public boolean hasNext() {
//            return pos >= 0;
//        }
//        
//        private void nextContainer() {
//            if (pos >= 0) {
//                iter = RoaringBitmap.this.highLowContainer.getContainerAtIndex(pos).getReverseShortIterator();
//                hs = RoaringBitmap.this.highLowContainer.getKeyAtIndex(pos) << 16;
//            }
//        }
//        
//        
//        public int next() {
//            final int x = iter.next() | hs;
//            if (!iter.hasNext()) {
//                --pos;
//                nextContainer();
//            }
//            return x;
//        }
//        
//        
//        public IntIterator clone() {
//            try {
//                RoaringReverseIntIterator clone = (RoaringReverseIntIterator) super.clone();
//                clone.iter =  this.iter.clone();
//                return clone;
//            } catch (CloneNotSupportedException e) {
//                return nil;// will not happen
//            }
//        }
//        
//    }
//}

// MARK:Sequence Protocol
extension RoaringBitmap : Sequence {
    typealias GeneratorType = RoaringBitmapGenerator
    public func makeIterator() -> RoaringBitmapGenerator{
        return RoaringBitmapGenerator(self.highLowContainer)
    }
}

public struct RoaringBitmapGenerator : IteratorProtocol{
    let _roaringArray: RoaringArray
    var containersPosition:Int = 0
    var hs:UInt64 = 0
    var _roaringArraySize:Int = 0
    var _bitmapGenerator:BitmapContainerGenerator? = nil
    var _arrayGenerator:ArrayContainerGenerator? = nil

    init(_ roaringArray: RoaringArray) {
        _roaringArray = roaringArray
        _roaringArraySize = roaringArray.size
        nextContainer()
    }
    
    public typealias Element = UInt32
    mutating public func next() -> UInt32? {
        if containersPosition < _roaringArraySize {
            var generatorValue:UInt16? = nil
            if _arrayGenerator != nil {
                generatorValue =  _arrayGenerator!.next()
            }else if  _bitmapGenerator != nil{
                generatorValue = _bitmapGenerator!.next()

            }
            if let uw_generatorValue = generatorValue{
                let value  = UInt32(UInt64(uw_generatorValue) | hs)
                return value
            }
            
            containersPosition += 1
            nextContainer()
            return self.next()
            
        }
        return nil
    }
    
    mutating internal func nextContainer() {
        if containersPosition < _roaringArraySize {
            let element = _roaringArray.array[containersPosition]
            hs = UInt64(element.key) << UInt64(16)
            if let uw_arrayContainer = element.value as? ArrayContainer{
                _arrayGenerator = uw_arrayContainer.makeIterator()
                _bitmapGenerator = nil
            }else{
                _arrayGenerator = nil
                _bitmapGenerator = (element.value as! BitmapContainer).makeIterator()
            }
        }
    }
}


//MARK: Equatable Protocol
public func ==(lhs: RoaringBitmap, rhs: RoaringBitmap) -> Bool{
    return lhs.highLowContainer == rhs.highLowContainer
    
}





