//
//  ArrayContainer.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/17/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit



/**
* Simple container made of an array of 16-bit Integers
*/
public class ArrayContainer: Container, Equatable, Printable, Hashable {
    private static let DEFAULT_INIT_SIZE = 4
    
    public static let DEFAULT_MAX_SIZE = 4096
    
    
    internal var _cardinality = 0
    
    var _content:[UInt16]
    
    /**
    * Create an array container with default capacity
    */
    public convenience init() {
        self.init(capacity:ArrayContainer.DEFAULT_INIT_SIZE)
    }
    
    /**
    * Create an array container with specified capacity
    *
    * @param capacity The capacity of the container
    */
    public init(capacity:Int) {
        _content = [UInt16](count: capacity, repeatedValue: 0)
        _content.reserveCapacity(capacity)
    }
    
    /**
    * Create an array container with a run of ones from firstOfRun to
    * lastOfRun, inclusive. Caller is responsible for making sure the range
    * is small enough that ArrayContainer is appropriate.
    *
    * @param firstOfRun first index
    * @param lastOfRun  last index (range is inclusive)
    */
    public init(firstOfRun:Int, lastOfRun:Int) {
        let valuesInRange = lastOfRun - firstOfRun + 1
        var newContent = [UInt16](count:valuesInRange, repeatedValue:0)

        for i in 0..<valuesInRange {
            newContent[i] = UInt16 (firstOfRun + i)
        }
        self._content = newContent
        _cardinality = valuesInRange
    }
    
    private init(newCard:Int, newContent:[UInt16] ) {
        self._cardinality = newCard
        self._content = newContent
    }
    
    internal init(newContent:[UInt16]) {
        self._cardinality = newContent.count
        self._content = newContent
    }
    
    //MARK: Container protocol
    
    public var sequence:SequenceOf<UInt16>{
        return SequenceOf<UInt16>(self)
    }
    
    /**
    * running time is in O(n) time if insert is not in order.
    */
    public func add(value: UInt16) -> Container{
        var loc = unsignedBinarySearch(_content, 0, _cardinality, value)
        if (loc < 0) {
            // Transform the ArrayContainer to a BitmapContainer
            // when cardinality = DEFAULT_MAX_SIZE
            if (_cardinality >= ArrayContainer.DEFAULT_MAX_SIZE) {
                let a = self.toBitmapContainer()
                a.add(value)
                return a
            }
//FIXME: related to the increaseCapacity() method
//            if (_cardinality >= self._content.count){
//                increaseCapacity()
//            }
            // insertion : shift the elements > x by one position to
            // the right
            // and put x in it's appropriate place
            let insertionIndex = -loc - 1
            _content.insert(value, atIndex: insertionIndex)
            ++_cardinality
        }
        return self
    }
    
    
    public func and(rhs:ArrayContainer) -> Container{
        
        let value1 = self
        let desiredCapacity = min(value1._cardinality, rhs._cardinality)
        var answer = ArrayContainer(capacity: desiredCapacity)
        answer._cardinality = unsignedIntersect2by2(value1._content, value1.cardinality, rhs._content,
                                rhs.cardinality, &(answer._content))
        return answer
    }
    
    
    public func  and(rhs:BitmapContainer) -> Container{
        return rhs.and(self)
    }
    
    
    public func andNot(rhs: ArrayContainer) -> Container{
        let value1 = self;
        let desiredCapacity = value1._cardinality
        var answer = ArrayContainer(capacity: desiredCapacity)
        answer._cardinality = unsignedDifference(value1._content,
            value1._cardinality, rhs._content,
            rhs._cardinality, &(answer._content))
        return answer;
    }
    
    
    public func andNot(rhs: BitmapContainer) -> Container{
        var  answer = ArrayContainer(capacity: _content.count)
        var pos = 0
        for k in 0..<_cardinality{
            if (!rhs.contains(self._content[k])){
                answer._content[pos++] = self._content[k];
            }
        }
        answer._cardinality = pos
        return answer
    }
    
    
    public func clear() {
        _cardinality = 0
    }
    
    
    public func clone() -> Container{
        return ArrayContainer(newCard: self._cardinality, newContent: self._content)
    }
    
    
    public func contains(value: UInt16) -> Bool {
        return unsignedBinarySearch(_content, 0, cardinality, value) >= 0
    }
    
    
    public func fillLeastSignificant16bits(inout array:[UInt64], index:Int, mask:UInt64) {
        let localContent = self._content
        for k in 0..<self._cardinality{
            array[k + index] = UInt64(localContent[k]) | mask
        }
        
    }
    
    
    public var arraySizeInBytes:Int {
        return cardinality * 2
    }
    
    
    public var cardinality:Int {
        return _cardinality
    }
    
    
//FIXME:    public  var shortIterator:ShortIterator{
//        return new ShortIterator() {
//            Int pos = 0;
//            
//            
//            public boolean hasNext() {
//                return pos < ArrayContainer.self.cardinality;
//            }
//            
//            
//            public UInt16 next() {
//                return ArrayContainer.self._content[pos++];
//            }
//            
//            
//            public ShortIterator clone() {
//                try {
//                    return (ShortIterator) super.clone();
//                } catch (CloneNotSupportedException e) {
//                    return nil;// will not happen
//                }
//            }
//            
//            
//            public void remove() {
//                ArrayContainer.self.remove((UInt16) (pos - 1));
//                pos--;
//            }
//            
//        };
//    }
    
    
//FIXME:    public var reverseShortIterator:ShortIterator {
//        return new ShortIterator() {
//            Int pos = ArrayContainer.self.cardinality - 1;
//            
//            
//            public boolean hasNext() {
//                return pos >= 0;
//            }
//            
//            
//            public UInt16 next() {
//                return ArrayContainer.self._content[pos--];
//            }
//            
//            
//            public ShortIterator clone() {
//                try {
//                    return (ShortIterator) super.clone();
//                } catch (CloneNotSupportedException e) {
//                    return nil;// will not happen
//                }
//            }
//            
//            
//            public void remove() {
//                ArrayContainer.self.remove((UInt16) (pos + 1));
//                pos++;
//            }
//        };
//    }
    
    
    public var sizeInBytes:Int {
        return _cardinality * 2 + 4
        
    }
    
    
    public func iand(rhs: ArrayContainer) -> Container{
        self._cardinality = unsignedIntersect2by2(self._content, self._cardinality, rhs._content,rhs.cardinality, &(self._content))
        return self
    }
    
    
    public func iand(rhs:BitmapContainer) -> Container{
        var pos = 0
        for k in 0..<_cardinality{
            if (rhs.contains(self._content[k])){
                self._content[pos++] = self._content[k];
            }
        }
        _cardinality = pos
        return self
    }
    
    
    public func iandNot(rhs: ArrayContainer) -> Container{
        self._cardinality = unsignedDifference(self._content,self._cardinality, rhs._content,rhs._cardinality, &(self._content))
        return self
    }
    
    
    public func iandNot(rhs:BitmapContainer) -> Container {
        var pos = 0
        for k in 0..<_cardinality{
            if (!rhs.contains(self._content[k])){
                self._content[pos++] = self._content[k]
            }
        }
        self._cardinality = pos
        return self
    }
    
 
    
    public func inot(#rangeStart:Int, rangeEnd lastOfRange:Int) ->Container{
        // determine the span of array indices to be affected

        let localCadinality = cardinality
        var startIndex = unsignedBinarySearch(_content, 0, localCadinality, UInt16(rangeStart))
            if (startIndex < 0){
                startIndex = -startIndex - 1
        }
        var lastIndex = unsignedBinarySearch(_content, 0, localCadinality, UInt16(lastOfRange))
        if (lastIndex < 0){
            lastIndex = -lastIndex - 1 - 1
        }
        let currentValuesInRange = lastIndex - startIndex + 1
        let  spanToBeFlipped = lastOfRange - rangeStart + 1
        let  newValuesInRange = spanToBeFlipped - currentValuesInRange
        var buffer:[UInt16]
        let cardinalityChange = newValuesInRange - currentValuesInRange
        let newCardinality = localCadinality + cardinalityChange
        
        if (cardinalityChange > 0) { // expansion, right shifting needed
            if (newCardinality > _content.count) {
                // so big we need a bitmap?
                if (newCardinality >= ArrayContainer.DEFAULT_MAX_SIZE){
                    return toBitmapContainer().inot(rangeStart: rangeStart, rangeEnd: lastOfRange)
                }
                let expendedContent = [UInt16](count: newCardinality , repeatedValue:0)
                let expendedContentPtr = UnsafeMutablePointer<Void>(expendedContent)
                memcpy(expendedContentPtr,_content,_content.count * sizeof(UInt16))
                _content = expendedContent
            }
            buffer = [UInt16](count: newValuesInRange, repeatedValue: 0)
            // slide right the _contents after the range
            //System.arraycopy(content, lastIndex + 1, content,lastIndex + 1 + cardinalityChange, cardinality - 1 - lastIndex);
            let startingDelta = lastIndex + 1
            let length = cardinality - 1 - lastIndex
            
            let contentPtr = UnsafeMutableBufferPointer(start: &_content, count: _content.count)
            let baseContentPtr = contentPtr.baseAddress as UnsafeMutablePointer<UInt16>
            
            let sourcePtr = baseContentPtr.advancedBy(startingDelta)
            let destinationPtr = baseContentPtr.advancedBy(startingDelta + cardinalityChange)
            
            memmove(destinationPtr,sourcePtr,length * sizeof(UInt16))
            

            negateRange(&buffer, startIndex: startIndex, lastIndex: lastIndex,startRange: rangeStart, lastRange: lastOfRange)
        } else { // no expansion needed
            buffer = [UInt16](count: newValuesInRange, repeatedValue: 0)
            negateRange(&buffer, startIndex: startIndex, lastIndex: lastIndex, startRange: rangeStart, lastRange: lastOfRange);
            if (cardinalityChange < 0) {
                // contraction, left sliding.
                // Leave array oversize
                //System.arraycopy(content, startIndex + newValuesInRange - cardinalityChange,content, startIndex + newValuesInRange,
               // newCardinality - (startIndex + newValuesInRange));
                
                let startingDelta = startIndex + newValuesInRange
                let length = newCardinality - (startIndex + newValuesInRange)
                
                let contentPtr = UnsafeMutableBufferPointer(start: &_content, count: _content.count)
                let baseContentPtr = contentPtr.baseAddress as UnsafeMutablePointer<UInt16>
                
                let sourcePtr = baseContentPtr.advancedBy(startingDelta - cardinalityChange)
                let destinationPtr = baseContentPtr.advancedBy(startingDelta)
                
                memmove(destinationPtr,sourcePtr,length * sizeof(UInt16))
                
            }
        }
        _cardinality = newCardinality
        return self
    }
    
    
    public func ior(rhs: ArrayContainer) -> Container{
        return self.or(rhs)
    }
    
    
    public func ior(rhs:BitmapContainer) -> Container{
        return rhs.or(self)
    }
    
    
    public func ixor(rhs:ArrayContainer) -> Container{
        return self.xor(rhs)
    }
    
    
    public func ixor(rhs:BitmapContainer) -> Container{
        return rhs.xor(self)
    }
    
        // shares lots of code with inot; candidate for refactoring
    public func not(#rangeStart:Int, rangeEnd:Int) -> Container{
        if (rangeStart > rangeEnd) {
            return clone() // empty range
        }
        let localContent = _content
        
        // determine the span of array indices to be affected
        var startIndex = unsignedBinarySearch(localContent, 0, cardinality, UInt16(rangeStart))
        if (startIndex < 0){
            startIndex = -startIndex - 1
        }
        var lastIndex = unsignedBinarySearch(localContent, 0, cardinality, UInt16(rangeEnd))
        if (lastIndex < 0){
            lastIndex = -lastIndex - 2
        }
        let currentValuesInRange = lastIndex - startIndex + 1
        let spanToBeFlipped = rangeEnd - rangeStart + 1
        let newValuesInRange = spanToBeFlipped - currentValuesInRange
        let cardinalityChange = newValuesInRange - currentValuesInRange
        let newCardinality = cardinality + cardinalityChange
        
        if (newCardinality >= ArrayContainer.DEFAULT_MAX_SIZE){
            return toBitmapContainer().not(rangeStart: rangeStart, rangeEnd: rangeEnd)
        }
        
        var answer = ArrayContainer(capacity: newCardinality)
        
        // copy stuff before the active area
       // System.arraycopy(_content, 0, answer._content, 0, startIndex);
        let destinationPtr = UnsafeMutablePointer<UInt16>(answer._content)

        memcpy(destinationPtr,localContent,startIndex * sizeof(UInt16))
        
        var outPos = startIndex
        var inPos = startIndex // item at inPos always >= valInRange
        
        var valInRange = rangeStart
        for (; valInRange <= rangeEnd && inPos <= lastIndex; ++valInRange) {
            if (UInt16(valInRange) != _content[inPos]) {
                answer._content[outPos++] = UInt16(valInRange)
            } else {
                ++inPos;
            }
        }
        
        for (; valInRange <= rangeEnd; ++valInRange) {
            answer._content[outPos++] = UInt16(valInRange)
        }
        
        // _content after the active range
        for i in (lastIndex + 1)..<_cardinality{
            answer._content[outPos++] = localContent[i]
        }
        answer._cardinality = newCardinality;
        return answer
    }
    
    
    public func or(rhs: ArrayContainer) -> Container{
        var value1 = self
        var totalCardinality = value1._cardinality + rhs._cardinality
        let one64 = UInt64(1)
        if (totalCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {// it could be a bitmap!
            var bc =  BitmapContainer()
            for k in 0..<rhs._cardinality{
                let i = Int(rhs._content[k]) >> 6
                let shiftValue:UInt64 = UInt64(rhs._content[k]) % 64
                bc._bitmap[i] |= (one64 << shiftValue)
            }
            for k in 0..<self._cardinality{
                let i = Int(self._content[k]) >> 6
                let shiftValue:UInt64 = UInt64(self._content[k]) % 64
                bc._bitmap[i] |= (one64 << shiftValue)
            }
            let newCardinality = bc._bitmap.reduce(0, combine: { $0 + countBits($1) })
            bc._cardinality = Int(newCardinality)
            
            if (bc.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
                return bc.toArrayContainer()
            }
            return bc
        }
        let desiredCapacity = totalCardinality; // Math.min(BitmapContainer.MAX_CAPACITY,
        // totalCardinality);
        var answer = ArrayContainer(capacity:desiredCapacity)
        answer._cardinality = unsignedUnion2by2(value1._content, value1._cardinality, rhs._content,
                            rhs._cardinality, &(answer._content))
        return answer
    }
    
    
    public func or(rhs:BitmapContainer) -> Container{
        return rhs.or(self);
    }

    
    public func remove(value: UInt16) -> Container{
        var loc = unsignedBinarySearch(_content, 0, cardinality, value)
        if (loc >= 0) {
            // insertion
            _content.removeAtIndex(loc)
            --_cardinality
        }
        return self;
    }
    
    
//FIXME:    public func serialize(DataOutput out) {
//        out.write((self.cardinality) & 0xFF);
//        out.write((self.cardinality >>> 8) & 0xFF);
//        // little endian
//        for (Int k = 0; k < self.cardinality; ++k) {
//            out.write((self._content[k]) & 0xFF);
//            out.write((self._content[k] >>> 8) & 0xFF);
//        }
//    }
//    internal func writeArray(DataOutput out)  {
//        // little endian
//        for k in 0..< _cardinality{
//            out.write((self._content[k]) & 0xFF);
//            out.write((self._content[k] >>> 8) & 0xFF);
//        }
//    }
//    
//    
//    public func writeExternal(ObjectOutput out){
//        serialize(out)
//    }
//    public func readExternal(ObjectInput in) {
//        deserialize(in);
//    }
//    public func deserialize(DataInput in) {
//        byte[] buffer = new byte[2];
//        // little endian
//        in.readFully(buffer);
//        self.cardinality = (buffer[0] & 0xFF) | ((buffer[1] & 0xFF) << 8);
//        if (self._content.length < self.cardinality)
//        self._content = new UInt16[self.cardinality];
//        for (Int k = 0; k < self.cardinality; ++k) {
//            in.readFully(buffer);
//            self._content[k] = (UInt16) (((buffer[1] & 0xFF) << 8) | (buffer[0] & 0xFF));
//        }
//    }
    
    
    
    public var serializedSizeInBytes:Int {
        return _cardinality * 2 + 2
    }
    
    
    public func trim() {
        let newSize = self.cardinality
        
        var newContent = [UInt16] (count: newSize, repeatedValue: 0)
        memcpy(&newContent, self._content, newSize * sizeof(UInt16))
        self._content = newContent

    }
    
    
    public func xor(rhs: ArrayContainer) -> Container{
        var value1 = self
        var totalCardinality = value1._cardinality + rhs._cardinality
        let one64 = UInt64(1)
        if (totalCardinality > ArrayContainer.DEFAULT_MAX_SIZE) {// it could be a bitmap!
            var bc =  BitmapContainer()
            for k in 0..<rhs._cardinality{
                let i = Int(rhs._content[k]) >> 6
                let shiftValue:UInt64 = UInt64(rhs._content[k]) % 64
                bc._bitmap[i] ^= (one64 << shiftValue)
            }
            for k in 0..<self._cardinality{
                let i = Int(self._content[k]) >> 6
                let shiftValue:UInt64 = UInt64(self._content[k]) % 64
                bc._bitmap[i] ^= (one64 << shiftValue)
            }
            
            let newCardinality = bc._bitmap.reduce(0, combine: { $0 + countBits($1) })
            bc._cardinality = Int(newCardinality)
            
            if (bc.cardinality <= ArrayContainer.DEFAULT_MAX_SIZE){
                return bc.toArrayContainer()
            }
            return bc
        }
        let desiredCapacity = totalCardinality
        var answer = ArrayContainer(capacity:desiredCapacity)
        answer._cardinality = unsignedExclusiveUnion2by2(value1._content, value1._cardinality, rhs._content,
            rhs._cardinality, &(answer._content))
        return answer
    }
    
    
    public func xor(rhs:BitmapContainer) -> Container{
        return rhs.xor(self)
    }
    
    
    public func rank(lowbits:UInt16 ) -> Int{
        var answer =  unsignedBinarySearch(_content, 0, cardinality, lowbits)
        if (answer >= 0) {
            return answer + 1;
        } else {
            return -answer - 1;
        }
    }
    
    
    public func select(index:Int) -> Int{
        return Int(self._content[index])
    }
    
    
    public func limit(maxcardinality:Int) -> Container{
        if (maxcardinality < self._cardinality){
            return ArrayContainer(newCard: maxcardinality, newContent: self._content)
        }
        return clone()
    }
    
    //MARK: Other public interface
    /**
    * Copies the data in a bitmap container.
    *
    * @return the bitmap container
    */
    public func toBitmapContainer() ->BitmapContainer{
        var bc = BitmapContainer()
        bc.loadData(self)
        return bc
    }
    
    
    //MARK: Hashable 
    public var hashValue: Int  {
        var hash = UInt64(0)
        let i31 = UInt64(31)
        for k in 0..<_cardinality{
            hash = hash + (i31 * hash + UInt64(_content[k]))
        }
        return Int(hash)
    }
    
   
    //MARK: Printable
    public var description: String {
        if (self.cardinality == 0){
            return "{}"
        }
        var sb = "{"
        for i in 0..<(self._cardinality - 1){
            sb += "\(self._content[i])"
            sb += ","
        }
        sb += "\(self._content[self.cardinality - 1])}"
        return sb
    }
    
    //MARK: private methods
//FIXME: do we need a special resizing code?
//private func increaseCapacity() {
//        var newCapacity = (self._content.count == 0) ? ArrayContainer.DEFAULT_INIT_SIZE : self._content.count < 64 ? self._content.count * 2
//            : self._content.count < 1024 ? self._content.count * 3 / 2
//            : self._content.count * 5 / 4;
//        if (newCapacity > ArrayContainer.DEFAULT_MAX_SIZE){
//            newCapacity = ArrayContainer.DEFAULT_MAX_SIZE
//        }
//        self._content = Arrays.copyOf(self._content, newCapacity)
//    }
    
    internal func loadData(bitmapContainer: BitmapContainer ) {
        self._cardinality = bitmapContainer._cardinality
        bitmapContainer.fillArray(&_content)
    }
    
    // for use in inot range known to be nonempty
    private func negateRange(inout buffer:[UInt16] , startIndex:Int, lastIndex:Int, startRange:Int, lastRange:Int) {
        let localContent = _content
        // compute the negation Into buffer
        var outPos = 0
        var inPos = startIndex // value here always >= valInRange,
        // until it is exhausted
        // n.b., we can start initially exhausted.
        
        var valInRange = startRange
        for (; valInRange <= lastRange && inPos <= lastIndex; ++valInRange) {
            let valInRange16 = UInt16(valInRange)
            if valInRange16 != localContent[inPos] {
                buffer[outPos++] = valInRange16
            } else {
                ++inPos
            }
        }
        
        // if there are extra items (greater than the biggest
        // pre-existing one in range), buffer them
        for (; valInRange <= lastRange; ++valInRange) {
            buffer[outPos++] = UInt16(valInRange)
        }
        
        if (outPos != buffer.count) {
            assert(false,"negateRange: outPos \(outPos) whereas buffer.length= \(buffer.count)")
        }
        // copy back from buffer...caller must ensure there is room
        let contentPtr = UnsafeMutableBufferPointer(start: &_content, count: _content.count)
        let baseContentPtr = contentPtr.baseAddress as UnsafeMutablePointer<UInt16>
        let destinationPtr = baseContentPtr.advancedBy(startIndex)
        
        memcpy(destinationPtr,buffer,buffer.count * sizeof(UInt16))
    }
    
    

}


// MARK:Sequence Protocol
extension ArrayContainer : SequenceType {
    typealias GeneratorType = ArrayContainerGenerator
    public func generate() -> ArrayContainerGenerator{
        return ArrayContainerGenerator(content:self._content,cardinality:self._cardinality)
    }
}

public struct ArrayContainerGenerator : GeneratorType{
    let _arrayContainerContent : [UInt16]
    let _arrayContainerCardinality:Int
    var pos = 0
    init(content:[UInt16], cardinality: Int) {
        _arrayContainerContent = content
        _arrayContainerCardinality = cardinality
    }
    typealias Element = UInt16
    mutating public func next() -> UInt16? {
        if pos < _arrayContainerCardinality{
            return _arrayContainerContent[pos++]
        }
        return nil
    }
}

//MARK: Equatable Protocol
public func ==(lhs: ArrayContainer, rhs: ArrayContainer) -> Bool{
    
    if (lhs._cardinality != rhs._cardinality){
        return false
    }
    
    let lhsContent = lhs._content
    let rhsContent = rhs._content

    for i in 0..<lhs._cardinality {
        if (lhsContent[i] != rhsContent[i]){
            return false
        }
    }
    return true
    
}

