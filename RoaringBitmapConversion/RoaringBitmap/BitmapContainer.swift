//
//  BitmapContainer.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/17/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

extension UInt64{
   // static var maxBit: UInt64 { return 0x8000000000000000 }
    static var allBitsOn: UInt64 { return 0xFFFFFFFFFFFFFFFF }
}

public let oneUInt64 = UInt64(1)
    
/**
* Simple bitset-like container.
*/
open class BitmapContainer:Container, Equatable, CustomStringConvertible, Hashable{
    internal static let MAX_CAPACITY = Int(oneUInt64 << 16)
    
    fileprivate static var USE_IN_PLACE = true // optimization flag
    
    var _bitmap:[UInt64]
    
    var _cardinality:Int
    
    /**
    * Create a bitmap container with all bits set to false
    */
    public init() {
        _cardinality = 0;
        _bitmap = [UInt64](repeating: 0,count: BitmapContainer.MAX_CAPACITY / 64)
    }
    
    /**
    * Create a bitmap container with a run of ones from firstOfRun to
    * lastOfRun, inclusive caller must ensure that the range isn't so small
    * that an ArrayContainer should have been created instead
    *
    * @param firstOfRun first index
    * @param lastOfRun  last index (range is inclusive)
    */
    public init(firstOfRun:Int,lastOfRun:Int) {
        self._cardinality = lastOfRun - firstOfRun + 1;
        
        let totalBitmapLength = BitmapContainer.MAX_CAPACITY / 64
        if (_cardinality == BitmapContainer.MAX_CAPACITY){ // perhaps a common case
            self._bitmap = [UInt64](repeating: UInt64.max,count: totalBitmapLength)
        }else {
            let firstWord = firstOfRun / 64
            let lastWord = lastOfRun / 64
            let zeroPrefixLength = UInt64(firstOfRun & 63)
            let zeroSuffixLength = UInt64(63 - (lastOfRun & 63))
            
            
            var newBitmap:[UInt64]
            if firstWord > 0{
                newBitmap = [UInt64](repeating: 0,count: firstWord)
                newBitmap += [UInt64](repeating: UInt64.max,count: (lastWord - firstWord + 1))
            }else{
                newBitmap = [UInt64](repeating: UInt64.max,count: (lastWord - firstWord + 1))
            }
            
            let trailingLength = (totalBitmapLength - lastWord - 1)
            if trailingLength > 0{
                newBitmap += [UInt64](repeating: 0,count: trailingLength)
            }
            
//            for n in firstWord...lastWord{
//                newBitmap[n] = UInt64.max
//            }
            
            let oneShiftedLeft = oneUInt64 << UInt64(zeroPrefixLength % 64)
            newBitmap[firstWord] ^= (oneShiftedLeft - 1)
            let blockOfOnes = (UInt64(1) << UInt64(zeroSuffixLength % 64)) - 1
            let maskShifing = (UInt64(64) - zeroSuffixLength) % 64
            let maskOnLeft = blockOfOnes << maskShifing
            newBitmap[lastWord] ^= maskOnLeft
            
            self._bitmap = newBitmap
        }
        
    }
    
    
    internal init(newBitmap:[UInt64], newCardinality:Int) {
        self._cardinality = newCardinality
        self._bitmap = newBitmap
    }
    
    //MARK: Container protocol
    
    open var sequence:AnySequence<UInt16>{
        return AnySequence<UInt16>(self)
    }
    
    open func add(_ value: UInt16) ->Container?{
        let  x = Int(value)
        let xShift = UInt64(x % 64)
        let index = x / 64
        let previous = _bitmap[index]
        _bitmap[index] |= UInt64(1) << xShift
        _cardinality += Int((previous ^ _bitmap[index]) >> xShift)
        return nil
    }
    

    open func and(_ rhs: ArrayContainer) ->Container{
        let rhsContent = rhs._content
        let answer = ArrayContainer(initialCardinality: rhsContent.count)
        for k in 0..<rhs._cardinality{
            if (self.contains(rhsContent[k])){
                answer._content[answer._cardinality] = rhsContent[k]
                answer._cardinality+=1
            }
        }
        return answer
    }
    

    open func and(_ rhs: BitmapContainer) ->Container{
        var newCardinality = 0
        let selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            newCardinality += Int(countBits(selfBitmap[k] & rhsBitmap[k]))
        }
        if (newCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {
            let answer = BitmapContainer()
            for k in 0..<answer._bitmap.count {
                answer._bitmap[k] = selfBitmap[k] & rhsBitmap[k]
            }
            answer._cardinality = newCardinality
            return answer
        }
        let ac = ArrayContainer(initialCardinality:newCardinality)
        fillArrayAND(container: &(ac._content), bitmap1: selfBitmap, bitmap2: rhsBitmap)
        ac._cardinality = newCardinality
        return ac
    }
    
    
    open func andNot(_ rhs: ArrayContainer) ->Container{
        let answer = clone() as! BitmapContainer
        let localRHSContent = rhs._content
        let localBitmap = self._bitmap
        for k in 0..<rhs._cardinality {
            let i = Int(localRHSContent[k]) >> 6
            let adjustedShift = UInt64(localRHSContent[k]) % 64
            answer._bitmap[i] = answer._bitmap[i] & (~(UInt64(1) << adjustedShift))
            answer._cardinality -= Int((answer._bitmap[i] ^ localBitmap[i]) >> adjustedShift)
        }
        if (answer._cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            return answer.toArrayContainer()
        }
        return answer;
    }
    
    open func andNot(_ rhs: BitmapContainer) ->Container{
        var newCardinality = 0
        let selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            newCardinality += Int(countBits(selfBitmap[k] & (~rhsBitmap[k])))
        }
        if (newCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {
            let answer = BitmapContainer()
            var answerBitmap = answer._bitmap
            for k in 0..<answerBitmap.count {
                answerBitmap[k] = selfBitmap[k] & (~rhsBitmap[k])
            }
            answer._cardinality = newCardinality
            return answer
        }
        let ac = ArrayContainer(initialCardinality:newCardinality)
        fillArrayANDNOT(container: &(ac._content), bitmap1: selfBitmap, bitmap2: rhsBitmap)
        ac._cardinality = newCardinality
        return ac
    }

    open func clear() {
        if (_cardinality != 0) {
            _cardinality = 0
            let _bitmapCount = _bitmap.count
            _bitmap = [UInt64](repeating: 0,count: _bitmapCount)
        }
    }
    
   
    open func clone() -> Container{
        return BitmapContainer(newBitmap: self._bitmap,newCardinality: self._cardinality)
    }
    
    
    open func contains(_ value:UInt16) -> Bool{
        let  x = Int(value) / 64
        var  xShift = UInt64(value) % 64
        xShift = UInt64(1) <<  xShift
        return (_bitmap[x] & xShift) != 0
    }
    
   

    open func fillLeastSignificant16bits(_ array:inout [UInt32], index:Int, mask: UInt32) {
        var pos = index
        let selfBitmap = self._bitmap
        for k in 0..<selfBitmap.count{
            var bitset = selfBitmap[k]
            while (bitset != 0) {
                let notBitset = (~bitset) + 1
                let t = bitset & notBitset
                let k64 = UInt64(k * 64) + countBits(t - 1)
                array[pos] = UInt32(k64) | mask
                pos+=1
                bitset ^= t
            }
        }
    }
    

    open var arraySizeInBytes:Int {
        return BitmapContainer.MAX_CAPACITY / 8
    }
    

    open var cardinality:Int {
        return _cardinality
    }
    


    

//FIXME:    public ShortIterator getReverseShortIterator() {
//        return new ShortIterator() {
//            int i = BitmapContainer.self.prevSetBit(64 * BitmapContainer.self.bitmap.length - 1);
//            
//        
//            public boolean hasNext() {
//                return i >= 0;
//            }
//            
//        
//            public short next() {
//                final int j = i;
//                i = i > 0 ? BitmapContainer.self.prevSetBit(i - 1) : -1;
//                return (short) j;
//            }
//            
//        
//            public ShortIterator clone() {
//                try {
//                    return (ShortIterator) super.clone();
//                } catch (CloneNotSupportedException e) {
//                    return nil;
//                }
//            }
//            
//        
//            public void remove() {
//                //TODO: implement
//                throw new RuntimeException("unsupported operation: remove");
//            }
//        };
//    }
    

    open var sizeInBytes:Int {
        return _bitmap.count * 8
    }
    
    open func iand(_ rhs: ArrayContainer) -> Container{
        return rhs.and(self);// no inplace possible
    }
    

    open func iand(_ rhs: BitmapContainer) -> Container{
        var newCardinality = 0
        var selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            newCardinality += Int(countBits(selfBitmap[k] & rhsBitmap[k]))
        }
        if (newCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {
            for k in 0..<selfBitmap.count {
                selfBitmap[k] = selfBitmap[k] & rhsBitmap[k]
            }
            self._cardinality = newCardinality
            return self
        }
        let ac = ArrayContainer(initialCardinality:newCardinality)
        fillArrayAND(container: &(ac._content), bitmap1: selfBitmap, bitmap2: rhsBitmap)
        ac._cardinality = newCardinality
        return ac
    }
    

    open func iandNot(_ rhs: ArrayContainer) -> Container{
        let rhsContent = rhs._content
        for k in 0..<rhs._cardinality {
            self.remove(rhsContent[k])
        }
        if (_cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            return self.toArrayContainer()
        }
        return self
    }
    
    
    open func iandNot(_ rhs: BitmapContainer) -> Container{
        var newCardinality = 0
        var selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            newCardinality += Int(countBits(selfBitmap[k] & (~rhsBitmap[k])))
        }
        if (newCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {
            for k in 0..<selfBitmap.count {
                selfBitmap[k] = selfBitmap[k] & (~rhsBitmap[k])
            }
            self._cardinality = newCardinality
            return self
        }
        let ac = ArrayContainer(initialCardinality:newCardinality)
        fillArrayANDNOT(container: &(ac._content), bitmap1: selfBitmap, bitmap2: rhsBitmap)
        ac._cardinality = newCardinality
        return ac
    }

    
    // complicated so that it should be reasonably efficient even when the
    // ranges are small

    open func inot(rangeStart:Int,rangeEnd :Int) -> Container{
        return not(self, rangeStart: rangeStart, rangeEnd: rangeEnd)
    }
    

    open func ior(_ rhs: ArrayContainer) -> Container{
        var selfBitmap = self._bitmap
        let rhsContent = rhs._content
        var newCardinality = self._cardinality
        for k in 0..<rhs._cardinality {
            let  i = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            let leftShiftedOne = oneUInt64 << shiftingValue
            newCardinality += Int(((~selfBitmap[i]) & leftShiftedOne) >> shiftingValue)
            self._bitmap[i] |= leftShiftedOne
        }
        self._cardinality = newCardinality
        return self
    }
    

    open func ior(_ rhs: BitmapContainer) ->Container{
        var newCardinality:UInt64 = 0
        var selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            self._bitmap[k] = selfBitmap[k] | rhsBitmap[k]
            newCardinality += countBits(self._bitmap[k])
        }
        _cardinality = Int(newCardinality)
        return self
    }
    

    open func ixor(_ rhs: ArrayContainer) -> Container{
        let rhsContent = rhs._content
        for k in 0..<rhs._cardinality {
            let index = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            let leftShiftedOne = oneUInt64 << shiftingValue
            self._cardinality += 1 - 2 * Int((self._bitmap[index] & leftShiftedOne) >> shiftingValue)
            self._bitmap[index] ^= leftShiftedOne
        }
        if (self._cardinality <= ArrayContainer.DEFAULT_MAX_SIZE) {
            return self.toArrayContainer()
        }
        return self;
    }
    

    open func ixor(_ rhs: BitmapContainer) -> Container{
        var newCardinality:UInt64 = 0
        var selfBitmap = self._bitmap
        let rhsBitmap = rhs._bitmap
        for k in 0..<selfBitmap.count{
            newCardinality += countBits(selfBitmap[k] ^ rhsBitmap[k])
        }
        if (newCardinality > UInt64(ArrayContainer.DEFAULT_MAX_SIZE)) {
            for k in 0..<selfBitmap.count {
                selfBitmap[k] = selfBitmap[k] ^ rhsBitmap[k]
            }
            self._cardinality = Int(newCardinality)
            return self
        }
        let ac = ArrayContainer(initialCardinality: Int(newCardinality))
        fillArrayXOR(container: &(ac._content), bitmap1: selfBitmap, bitmap2: rhsBitmap)
        ac._cardinality = Int(newCardinality)
        return ac
    }
    

    open func not(rangeStart:Int,rangeEnd :Int) -> Container{
        return not(BitmapContainer(), rangeStart: rangeStart, rangeEnd: rangeEnd);
    }
    

    open func or(_ rhs: ArrayContainer) ->Container {
        let answer = clone() as! BitmapContainer
        let rhsContent = rhs._content
        for k in 0..<rhs._cardinality{
            let i = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            let leftShiftedOne:UInt64 = oneUInt64 << shiftingValue
            answer._cardinality += Int((~answer._bitmap[i] & leftShiftedOne) >> shiftingValue)
            answer._bitmap[i] = answer._bitmap[i] | leftShiftedOne
        }
        return answer;
    }
    

    open func or(_ rhs: BitmapContainer) ->Container {
        if (BitmapContainer.USE_IN_PLACE) {
            let value1 = self.clone();
            return value1.ior(rhs)
        }
        let  answer =  BitmapContainer()
        answer._cardinality = 0;
        for k in 0..<answer._bitmap.count{
            answer._bitmap[k] = self._bitmap[k] | rhs._bitmap[k]
            answer._cardinality += Int(countBits(answer._bitmap[k]))
        }
        return answer
    }
    

    open func remove(_ value:UInt16) -> Container?{
        let xShift = UInt64(value) % 64
        let index = Int(value) / 64
        let oneUInt64Shifted:UInt64 = oneUInt64 << xShift
        
        if (_cardinality == ArrayContainer.DEFAULT_MAX_SIZE + 1) {// self is
            // the
            // uncommon
            // path
            if ((self._bitmap[index] & oneUInt64Shifted) != 0) {
                _cardinality -= 1
                _bitmap[index] = self._bitmap[index] & ~oneUInt64Shifted
                return self.toArrayContainer()
            }
        }

        _cardinality -= Int((self._bitmap[index] & oneUInt64Shifted) >> xShift)
        _bitmap[index] =  self._bitmap[index] & ~oneUInt64Shifted
        return nil
    }
    

//FIXME:    public void serialize(DataOutput out) throws IOException {
    open func serialize(){
        var buffer = [UInt8](repeating: 0,count: 8)
        let localBitmap = _bitmap
        // little endian
        for w in localBitmap {
            buffer[0] = UInt8(w)
            buffer[1] = UInt8(w >> 8)
            buffer[2] = UInt8(w >> 16)
            buffer[3] = UInt8(w >> 24)
            buffer[4] = UInt8(w >> 32)
            buffer[5] = UInt8(w >> 40)
            buffer[6] = UInt8(w >> 48)
            buffer[7] = UInt8(w >> 56)
 //           out.write(buffer, 0, 8);
        }
    }

   
    open var serializedSizeInBytes:Int {
        return BitmapContainer.MAX_CAPACITY / 8
    }
    

    open func trim() {
    }
    

//FIXME:    protected void writeArray(DataOutput out) throws IOException {
    open func writeArray(){
        var buffer = [UInt8](repeating: 0, count: 8)
        let localBitmap = _bitmap
        // little endian
        for  w in localBitmap{
            buffer[0] = UInt8(w)
            buffer[1] = UInt8(w >> 8)
            buffer[2] = UInt8(w >> 16)
            buffer[3] = UInt8(w >> 24)
            buffer[4] = UInt8(w >> 32)
            buffer[5] = UInt8(w >> 40)
            buffer[6] = UInt8(w >> 48)
            buffer[7] = UInt8(w >> 56)
//            out.write(buffer, 0, 8);
        }
    }
    

    open func xor(_ rhs: ArrayContainer) ->Container{
        let answer = clone() as! BitmapContainer
        let rhsContent = rhs._content
        var answerCardinality = answer.cardinality
        for k in 0..<rhs._cardinality {
            let index = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            let leftShiftedOne = oneUInt64 << shiftingValue
            
            answerCardinality += 1 - 2 * Int(((answer._bitmap[index] & leftShiftedOne) >> shiftingValue))
              
            answer._bitmap[index] = answer._bitmap[index] ^ leftShiftedOne
        }
        answer._cardinality = answerCardinality
        if (answer.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            return answer.toArrayContainer()
        }
        return answer
    }
    

    open func xor(_ rhs: BitmapContainer) ->Container{
        var newCardinality = 0;
        for k in 0..<self._bitmap.count {
            newCardinality += Int(countBits(self._bitmap[k] ^ rhs._bitmap[k]))
        }
        if (newCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {
            let answer =  BitmapContainer()
            for k in 0..<answer._bitmap.count {
                answer._bitmap[k] = self._bitmap[k] ^ rhs._bitmap[k]
            }
            answer._cardinality = newCardinality
            return answer;
        }
        let ac = ArrayContainer(initialCardinality: newCardinality)
        fillArrayXOR(container: &(ac._content), bitmap1: self._bitmap, bitmap2: rhs._bitmap)
        ac._cardinality = newCardinality
        return ac
    }
    
    

    open func rank(_ lowbits:UInt16) ->Int{
        let x:UInt64 = UInt64(lowbits)
        let leftover:UInt64 = UInt64((x + 1) & 63)
        let maxRange = Int((x + 1)/64)
        let localBitmap = self._bitmap
        
       // localBitmap[0..<maxRange].reduce(0) { $0 + countBits($1)}
      
        var answer:UInt64 = localBitmap[0..<maxRange].reduce(0) { $0 + countBits($1) }
        
        if (leftover != 0) {
            let shift:UInt64 = 64 - leftover
           // let shiftedValue:UInt64 =
            let bitCount:UInt64 = countBits(localBitmap[maxRange] << shift)
            answer += bitCount
        }
        return Int(answer)
    }
    

    open func select(_ index:UInt32) ->UInt32{
        var leftover = index
        let localBitmap = self._bitmap
        for k in 0..<localBitmap.count {
            let w = UInt32(countBits(localBitmap[k]))
            if(w > leftover) {
                let selectedBitIndex = selectBit(word:UInt64(localBitmap[k]), bitIndex:leftover)
                return UInt32(k * 64 + selectedBitIndex)
            }
            leftover -= w
        }
        assert(false, "Insufficient cardinality.")
    }
    

    open func limit(_ maxCardinality:Int) -> Container{
        if(maxCardinality >= self._cardinality) {
            return clone()
        }
        if(maxCardinality <= BitmapContainer.MAX_CAPACITY) {
            let ac = ArrayContainer(initialCardinality: maxCardinality)
            var pos = 0
            var k = 0
            while ((ac._cardinality < maxCardinality) && (k < _bitmap.count)) {
                var bitset = _bitmap[k]
                while ((ac._cardinality < maxCardinality) && ( bitset != 0)) {
                    let notBitset = (~bitset) + 1
                    let t = bitset & notBitset
                    ac._content[pos] =  UInt16(UInt64(k * 64) + countBits(t - 1))
                    pos+=1
                    ac._cardinality += 1
                    bitset ^= t
                }
                k += 1
            }
            return ac
        }
        let bc = BitmapContainer(newBitmap: self._bitmap,newCardinality: maxCardinality)
        let s = Int(select(UInt32(maxCardinality)))
        let usedwords = ( s + 63 ) / 64
        let todelete = self._bitmap.count - usedwords
        for k in 0..<todelete{
            bc._bitmap[bc._bitmap.count - 1 - k] = 0
        }
        let lastword = s % 64
        if(lastword != 0) {
            let lastWord64 = UInt64(64 - lastword)
            bc._bitmap[s/64] = (bc._bitmap[s/64] << (lastWord64)) >> (lastWord64)
        }
        return bc
    }
    
    
    //MARK: Serialization function
    
//FIXME:    public void deserialize(DataInput in) throws IOException {
//        byte[] buffer = new byte[8];
//        // little endian
//        self.cardinality = 0;
//        for (int k = 0; k < bitmap.length; ++k) {
//            in.readFully(buffer);
//            bitmap[k] = (((long) buffer[7] << 56)
//            + ((long) (buffer[6] & 255) << 48)
//            + ((long) (buffer[5] & 255) << 40)
//            + ((long) (buffer[4] & 255) << 32)
//            + ((long) (buffer[3] & 255) << 24)
//            + ((buffer[2] & 255) << 16)
//            + ((buffer[1] & 255) << 8)
//            + (buffer[0] & 255));
//            self.cardinality += countBits(bitmap[k]);
//        }
//    }
    
    
    //MARK: Class Specific Public methods
    /**
    * Find the index of the next set bit greater or equal to index, returns -1
    * if none found.
    *
    * @param i starting index
    * @return index of the next set bit
    */
    open func nextSetBit(_ index:Int) ->Int {
        let localBitmap = self._bitmap
        var x = index >> 6 // i / 64 with sign extension
        var w = localBitmap[x]
        let adjustedShift = UInt64(index) % 64
        w >>= adjustedShift
        if (w != 0) {
            return index + Int(numberOfTrailingZeros(w))
        }
        x += 1
        for xi in x ..< localBitmap.count  {
            if (localBitmap[xi] != 0) {
                return xi * 64 + Int(numberOfTrailingZeros(localBitmap[xi]))
            }
        }
        return -1;
    }
    
    /**
    * Find the index of the previous set bit less than or equal to i, returns -1
    * if none found.
    *
    * @param i starting index
    * @return index of the previous set bit
    */
    open func prevSetBit(_ index:Int) ->Int {
        var x = index >> 6 // i / 64 with sign extension
        var w = _bitmap[x]
        w <<= UInt64(64 - index - 1)
        if (w != 0) {
            return index - Int(numberOfLeadingZeros(w))
        }
        x -= 1
        for xi in stride(from: x, through: 0, by: -1)  {
            if (_bitmap[xi] != 0) {
                return xi * 64 + 63 - Int(numberOfLeadingZeros(_bitmap[xi]))
            }
        }
        return -1
    }
    
    /**
    * Find the index of the next unset bit greater or equal to i, returns
    * -1 if none found.
    *
    * @param i starting index
    * @return index of the next unset bit
    */
    open func nextUnsetBit(_ index:Int) ->Int {
        var x = index / 64
        var w = ~_bitmap[x]
        w >>= UInt64(index)
        if (w != 0) {
            return  Int (index + numberOfTrailingZeros(w))
        }
        x += 1;
        for xi in x..<_bitmap.count {
            if (_bitmap[xi] != ~0) {
                return Int(xi * 64 + numberOfTrailingZeros(~_bitmap[xi]))
            }
        }
        return -1
    }
    
    /**
    * Copies the data to an array container
    *
    * @return the array container
    */
    open func toArrayContainer() -> ArrayContainer{
        if _cardinality == 0{
            return ArrayContainer()
        }
        let ac = ArrayContainer(initialCardinality: _cardinality)
        ac.loadData(self)
        return ac
    }
    
    //MARK: Printable Protocol
    
    open var description: String  {
        var sb = "{"
        //FIXME:        let i = self.getShortIterator()
        //
        //        while (i.hasNext()) {
        //            sb.append(i.next())
        //            if (i.hasNext()){
        //                sb += ","
        //            }
        //        }
        sb += "}"
        return sb
    }
    

    //MARK: Hashable Protocol
    open var hashValue: Int {
        return UInt64HashValue(self._bitmap)
    }

    
    
    //MARK: internal functions
    /**
    * Fill the array with set bits
    *
    * @param array container (should be sufficiently large)
    */
    internal func fillArray(_ array:inout [UInt16]) {
        var pos = 0
        let selfBitmap = self._bitmap
        for k in 0..<selfBitmap.count {
            var bitset = selfBitmap[k]
            while (bitset != 0) {
                let notBitset = (~bitset) + 1
                let t = bitset & notBitset
                let k64:UInt64 = UInt64(k) * 64
                array[pos] = UInt16(k64 + countBits(t - 1))
                pos += 1
                bitset ^= t
            }
        }
    }

    
//    for (int k = 0; k < arrayContainer.cardinality; ++k) {
//        final short x = arrayContainer.content[k];
//    
//        bitmap[Util.toIntUnsigned(x) / 64] |= (1l << x);
//    }
    
    internal func loadData(_ arrayContainer:ArrayContainer) {
        self._cardinality = arrayContainer._cardinality
        var localArrayContent = arrayContainer._content
        for k in 0..<arrayContainer._cardinality {
            let x = UInt64(localArrayContent[k])
            let index = Int(x / 64)
            let xorValue:UInt64 = (oneUInt64 << (x % 64))
            _bitmap[index] |= xorValue
        }
        
    }
    
    // answer could be a new BitmapContainer, or (for inplace) it can be
    // "self"
    fileprivate func not(_ answer:BitmapContainer , rangeStart firstOfRange:Int,rangeEnd lastOfRange:Int) -> Container{
        assert(self._bitmap.count == BitmapContainer.MAX_CAPACITY / 64); // checking assumption
        // that partial
        // bitmaps are not
        // allowed
        // an easy case for full range, should be common
        if (lastOfRange - firstOfRange + 1 == BitmapContainer.MAX_CAPACITY) {
            let newCardinality = BitmapContainer.MAX_CAPACITY - _cardinality
            for k in 0..<self._bitmap.count{
                answer._bitmap[k] = ~self._bitmap[k]
            }
            answer._cardinality = newCardinality
            if (newCardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
                return answer.toArrayContainer()
            }
            return answer
        }
        
        // could be optimized to first determine the answer cardinality,
        // rather than update/create bitmap and then possibly convert
        
        var cardinalityChange = 0
        let rangeFirstWord = firstOfRange / 64
        let rangeFirstBitPos:UInt64 = UInt64(firstOfRange) & 63
        let rangeLastWord = lastOfRange / 64
        let rangeLastBitPos:UInt64 = UInt64(lastOfRange) & 63

        
        // if not in place, we need to duplicate stuff before
        // rangeFirstWord and after rangeLastWord
        if (answer != self) {
            //System.arraycopy(bitmap, 0, answer.bitmap, 0, rangeFirstWord);
            
            let selfBitmapPtr = UnsafeBufferPointer(start: &_bitmap, count: _bitmap.count)
            let baseSelfBitmapPtr = selfBitmapPtr.baseAddress! as UnsafePointer<UInt64>
            
            let answerBitmapPtr = UnsafeMutableBufferPointer(start: &answer._bitmap, count: answer._bitmap.count)
            let baseAnswerBitmapPtr = answerBitmapPtr.baseAddress! as UnsafeMutablePointer<UInt64>
            
            memcpy(baseAnswerBitmapPtr,baseSelfBitmapPtr,rangeFirstWord * MemoryLayout<UInt64>.size)
            //System.arraycopy(bitmap, rangeLastWord + 1, answer.bitmap, rangeLastWord + 1, bitmap.length - (rangeLastWord + 1));
            let position = rangeLastWord + 1
            let length = _bitmap.count - (rangeLastWord + 1)
            
            let sourcePtr = baseSelfBitmapPtr.advanced(by: position)
            let destinationPtr = baseAnswerBitmapPtr.advanced(by: position)
            
            memcpy(destinationPtr,sourcePtr,length * MemoryLayout<UInt64>.size)
            
        }
        
        // unfortunately, the simple expression gives the wrong mask for
        // rangeLastBitPos==63
        // no branchless way comes to mind
        let rangeLastBitPosShiting:UInt64 = (rangeLastBitPos + 1) % 64
        let maskOnLeft:UInt64 = (rangeLastBitPos == 63) ? UInt64.max : (oneUInt64 << rangeLastBitPosShiting) - 1
        
        var mask = UInt64.max // now zero out stuff in the prefix
        let rangeFirstBitPosShiting:UInt64 = (rangeFirstBitPos) % 64
        mask ^= ((oneUInt64 << rangeFirstBitPosShiting) - 1)
        
        if (rangeFirstWord == rangeLastWord) {
            // range starts and ends in same word (may have
            // unchanged bits on both left and right)
            mask &= maskOnLeft
            cardinalityChange = -Int(countBits(_bitmap[rangeFirstWord]))
            answer._bitmap[rangeFirstWord] = _bitmap[rangeFirstWord] ^ mask
            cardinalityChange += Int(countBits(answer._bitmap[rangeFirstWord]))
            answer._cardinality = cardinality + cardinalityChange;
            
            if (answer.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
                return answer.toArrayContainer()
            }
            return answer
        }
        

         // range spans words
        cardinalityChange -= Int(countBits(self._bitmap[rangeFirstWord]))
        answer._bitmap[rangeFirstWord] = self._bitmap[rangeFirstWord] ^ mask
        cardinalityChange += Int(countBits(answer._bitmap[rangeFirstWord]))
        
        //FIXME: problem with cardinality here
        cardinalityChange -= Int(countBits(self._bitmap[rangeLastWord]))
        answer._bitmap[rangeLastWord] = self._bitmap[rangeLastWord] ^ maskOnLeft
        cardinalityChange += Int(countBits(answer._bitmap[rangeLastWord]))
        // negate the words, if any, strictly between first and last
        let loopStart = (rangeFirstWord + 1)
        for  i in loopStart..<rangeLastWord {
            let numberOfBits = Int(countBits(self._bitmap[i]))
            let cardinalityDelta = 64 - 2 * numberOfBits
            cardinalityChange += cardinalityDelta
            answer._bitmap[i] = ~self._bitmap[i]
        }
        
        answer._cardinality = _cardinality + cardinalityChange
        
        if (answer.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
            return answer.toArrayContainer()
        }
        return answer
    }
    
    internal func ilazyor(_ rhs:ArrayContainer) ->Container {
        self._cardinality = -1// invalid
        let rhsContent = rhs._content
        for k in 0..<rhs._cardinality  {
            let i = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            self._bitmap[i] |= (oneUInt64 << shiftingValue)
        }
        return self
    }
    
    internal func ilazyor(_ rhs:BitmapContainer) ->Container {
        self._cardinality = -1// invalid
        for k in 0..<self._bitmap.count {
            self._bitmap[k] |= rhs._bitmap[k]
        }
        return self
    }
    
    internal func lazyor(_ rhs:ArrayContainer) ->Container {
        let answer = self.clone() as! BitmapContainer
        answer._cardinality = -1// invalid
        let rhsContent = rhs._content
        for k in 0..<rhs._cardinality {
            let i = Int(rhsContent[k]) >> 6
            let shiftingValue:UInt64 = UInt64(rhsContent[k]) % 64
            answer._bitmap[i] |= (oneUInt64 << shiftingValue)
        }
        return answer
    }
    
    internal func lazyor(_ rhs:BitmapContainer) -> Container{
        let answer =  BitmapContainer()
        answer._cardinality = -1// invalid
        for k in 0..<self._bitmap.count {
            answer._bitmap[k] = self._bitmap[k] | rhs._bitmap[k]
        }
        return answer
    }
    
    internal func computeCardinality() {
        let newCardinality:UInt64 = _bitmap.reduce(0) { $0 + countBits($1) }
        self._cardinality = Int(newCardinality)
    }


}

//FIXME:    public ShortIterator getShortIterator() {
//        return new ShortIterator() {
//            int i = BitmapContainer.self.nextSetBit(0);
//            int j;
//            int max = BitmapContainer.self.bitmap.length * 64 - 1;
//
//
//            public boolean hasNext() {
//                return i >= 0;
//            }
//
//
//            public short next() {
//                j = i;
//                i = i < max ? BitmapContainer.self.nextSetBit(i + 1) : -1;
//                return (short) j;
//            }
//
//        };
//
//    }

// MARK:Sequence Protocol
extension BitmapContainer : Sequence {
    typealias GeneratorType = BitmapContainerGenerator
    public func makeIterator() -> BitmapContainerGenerator{
        return BitmapContainerGenerator(self)
    }
}

public struct BitmapContainerGenerator : IteratorProtocol{
    let _backingBitmapContainer : BitmapContainer
    var i:Int
    let max:Int
    init(_ backingBitmapContainer: BitmapContainer) {
        _backingBitmapContainer = backingBitmapContainer
        i = backingBitmapContainer.nextSetBit(0)
        max = backingBitmapContainer._bitmap.count * 64 - 1
    }
    public typealias Element = UInt16
    mutating public func next() -> UInt16? {
        if i >= 0{
            let j = UInt16(i)
            i = i < max ? _backingBitmapContainer.nextSetBit(i + 1) : -1
            return j
        }
        return nil
    }
}

public func ==(lhs: BitmapContainer, rhs: BitmapContainer) -> Bool{

    if (lhs._cardinality != rhs._cardinality){
        return false
    }
    return lhs._bitmap == rhs._bitmap
    
}

