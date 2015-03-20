//
//  RoaringArray.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/17/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

/*
* (c) Daniel Lemire, Owen Kaser, Samy Chambi, Jon Alvarado, Rory Graves, Björn Sperber
* Licensed under the Apache License, Version 2.0.
*/

public typealias Element = (key:UInt16,value:Container)
    

//    public int compareTo(Element o) {
//        return Util.toIntUnsigned(self.key) - Util.toIntUnsigned(o.key);
//    }


let INITIAL_CAPACITY = 4

/**
* Specialized array to store the containers used by a RoaringBitmap.
* This is not meant to be used by end users.
*/
public struct RoaringArray:Equatable,Hashable {
    public var array:[Element]
    

    init() {
        var newArray = [Element]()
        newArray.reserveCapacity(INITIAL_CAPACITY)
        
        self.array = newArray
    }
    
    mutating func append(tuple:Element) {
        array.append(tuple)
    }
    
    /**
    * Append copy of the one value from another array
    *
    * @param sa    other array
    * @param index index in the other array
    */
    internal mutating func appendCopy(sourceArray: RoaringArray,  index:Int) {
        let sourceTuple = sourceArray.array[index]
        self.array.append((key:sourceTuple.key,value:sourceTuple.value.clone()))
    }
    
    /**
    * Append copies of the values from another array
    *
    * @param sa            other array
    * @param startingIndex starting index in the other array
    * @param end endingIndex (exclusive) in the other array
    */
    internal mutating func  appendCopy(sourceArray:RoaringArray ,startingIndex:Int, end:Int) {
        var uw_array = self.array
        self.array.reserveCapacity(uw_array.count + (end - startingIndex))
        for i in startingIndex..<end {
            let sourceTuple = sourceArray.array[i]
            uw_array.append((key:sourceTuple.key,value:sourceTuple.value.clone()))
        }
    }
    
    /**
    * Append copies of the values from another array, from the start
    *
    * @param sourceArray The array to copy from
    * @param stoppingKey any equal or larger key in other array will terminate
    *                    copying
    */
    internal mutating func  appendCopiesUntil(sourceArray:RoaringArray , stoppingKey:UInt16 ) {
        for sourceTuple in sourceArray.array {
            if (sourceTuple.key >= stoppingKey){
                break
            }
            self.array.append((key:sourceTuple.key,value:sourceTuple.value.clone()))
            
        }
    }
    
    /**
    * Append copies of the values AFTER a specified key (may or may not be
    * present) to end.
    *
    * @param sa          other array
    * @param beforeStart given key is the largest key that we won't copy
    */
    internal mutating func appendCopiesAfter(sourceArray:RoaringArray , beforeStart:UInt16 ) {
        var startLocation = sourceArray.getIndex(beforeStart)
        if (startLocation >= 0){
            startLocation++
        }else{
            startLocation = -startLocation - 1
        }

        for i in startLocation..<sourceArray.size{
            let sourceTuple = sourceArray.array[i]
            self.array.append((key:sourceTuple.key, value:sourceTuple.value.clone()))
        }
    }
    
    internal mutating func clear() {
        array = [Element]()
    }
    
    
    public func clone() -> RoaringArray{
        var sa = RoaringArray()
        let selfArray = self.array
        var newArray = [Element]()
        newArray.reserveCapacity(self.size)
        for aTuple in selfArray{
            newArray.append((key:aTuple.key,value:aTuple.value.clone()))
        }
        sa.array = newArray
        return sa
    }
    
   
    
    // involves a binary search
    internal func getContainer(key:UInt16) -> Container? {
        let i = self.binarySearch(begin:0, end: size, key: key)
        if (i < 0){
            return nil
        }
        return self.array[i].value
    }
    
    // involves a binary search
    internal func getIndex(key:UInt16) -> Int {
        // before the binary search, we optimize for frequent cases
        if ((size == 0) || (array[size - 1].key == key)){
            return size - 1
        }
        // no luck we have to go through the list
        return self.binarySearch(begin:0, end: size, key: key)
    }
    
    

    
    
    // insert a new key, it is assumed that it does not exist
    internal mutating func  insertNewKeyValueAt(index:Int, element:Element) {
        array.insert(element, atIndex: index)
    }
    
    internal mutating func trim(toLength newLength:Int) {
        let currentCount = self.array.count
        if currentCount == newLength{
            //NoOP
            return
        }
//FIXME:        var newArray = [Element] (count: newLength, repeatedValue: 0)
//        memcpy(&newArray, self.array, newLength * sizeof(Element))
//        self.array = newArray
        self.array.removeRange(newLength..<currentCount)
    }
    
    
    internal var size:Int{
        return array.count
    }
    
    private func binarySearch( #begin:Int, end:Int, key: UInt16 ) ->Int{
        var low = begin
        var high = end - 1

        let uw_array = self.array
        while (low <= high) {
            let middleIndex = (low + high) >> 1
            let middleValue = uw_array[middleIndex].key
            
            if (middleValue < key){
                low = middleIndex + 1
            }
            else if (middleValue > key){
                high = middleIndex - 1
            }else{
                return middleIndex
            }
        }
        return -(low + 1)

    }
    
  
    
    
    /**
    * Serialize.
    *
    * The current bitmap is not modified.
    *
    * @param out the DataOutput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
//FIXME:    public void serialize(DataOutput out) throws IOException {
//        
//        out.write(SERIAL_COOKIE & 0xFF);
//        out.write((SERIAL_COOKIE >>> 8) & 0xFF);
//        out.write((SERIAL_COOKIE >>> 16) & 0xFF);
//        out.write((SERIAL_COOKIE >>> 24) & 0xFF);
//        
//        out.write(self.size & 0xFF);
//        out.write((self.size >>> 8) & 0xFF);
//        out.write((self.size >>> 16) & 0xFF);
//        out.write((self.size >>> 24) & 0xFF);
//        
//        for (int k = 0; k < size; ++k) {
//            out.write(self.array[k].key & 0xFF);
//            out.write((self.array[k].key >>> 8) & 0xFF);
//            out.write((self.array[k].value.getCardinality() - 1) & 0xFF);
//            out.write(((self.array[k].value.getCardinality() - 1) >>> 8) & 0xFF);
//        }
//        //writing the containers offsets
//        int startOffset = 4 + 4 + 4*self.size + 4*self.size;
//        for(int k=0; k<self.size; k++){
//            out.write(startOffset & 0xFF);
//            out.write((startOffset >>> 8) & 0xFF);
//            out.write((startOffset >>> 16) & 0xFF);
//            out.write((startOffset >>> 24) & 0xFF);
//            startOffset=startOffset+BufferUtil.getSizeInBytesFromCardinality(self.array[k].value.getCardinality());
//        }
//        for (int k = 0; k < size; ++k) {
//            array[k].value.writeArray(out);
//        }
//    }
    
    /**
    * Report the number of bytes required for serialization.
    *
    * @return the size in bytes
    */
    public var serializedSizeInBytes:Int {
        let uw_array = self.array
        let size = uw_array.count
        var count = 4 + 4 + 4 * size + 4 * size
        for tuple in uw_array{
            count += tuple.value.arraySizeInBytes
        }
        return count

    }
    
    /**
    * Deserialize.
    *
    * @param in the DataInput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
//FIXME    public void deserialize(DataInput in) throws IOException {
//        self.clear();
//        final byte[] buffer4 = new byte[4];
//        final byte[] buffer = new byte[2];
//        // little endian
//        in.readFully(buffer4);
//        final int cookie = (buffer4[0] & 0xFF) | ((buffer4[1] & 0xFF) << 8)
//        | ((buffer4[2] & 0xFF) << 16) | ((buffer4[3] & 0xFF) << 24);
//        if (cookie != SERIAL_COOKIE)
//        throw new IOException("I failed to find the right cookie.");
//        
//        in.readFully(buffer4);
//        self.size = (buffer4[0] & 0xFF) | ((buffer4[1] & 0xFF) << 8)
//        | ((buffer4[2] & 0xFF) << 16) | ((buffer4[3] & 0xFF) << 24);
//        if ((self.array == nil) || (self.array.length < self.size))
//        self.array = new Element[self.size];
//        final UInt16 keys[] = new UInt16[self.size];
//        final int cardinalities[] = new int[self.size];
//        final boolean isBitmap[] = new boolean[self.size];
//        for (int k = 0; k < self.size; ++k) {
//            in.readFully(buffer);
//            keys[k] = (UInt16) (buffer[0] & 0xFF | ((buffer[1] & 0xFF) << 8));
//            in.readFully(buffer);
//            cardinalities[k] = 1 + (buffer[0] & 0xFF | ((buffer[1] & 0xFF) << 8));
//            isBitmap[k] = cardinalities[k] > ArrayContainer.DEFAULT_MAX_SIZE;
//        }
//        //skipping the offsets
//        in.skipBytes(self.size*4);
//        //Reading the containers
//        for (int k = 0; k < self.size; ++k) {
//            Container val;
//            if (isBitmap[k]) {
//                final long[] bitmapArray = new long[BitmapContainer.MAX_CAPACITY / 64];
//                final byte[] buf = new byte[8];
//                // little endian
//                for (int l = 0; l < bitmapArray.length; ++l) {
//                    in.readFully(buf);
//                    bitmapArray[l] = (((long) buf[7] << 56)
//                    + ((long) (buf[6] & 255) << 48)
//                    + ((long) (buf[5] & 255) << 40)
//                    + ((long) (buf[4] & 255) << 32)
//                    + ((long) (buf[3] & 255) << 24)
//                    + ((buf[2] & 255) << 16)
//                    + ((buf[1] & 255) << 8)
//                    + (buf[0] & 255));
//                }
//                val = new BitmapContainer(bitmapArray, cardinalities[k]);
//            } else {
//                final UInt16[] UInt16Array = new UInt16[cardinalities[k]];
//                for (int l = 0; l < UInt16Array.length; ++l) {
//                    in.readFully(buffer);
//                    UInt16Array[l] = (UInt16) (buffer[0] & 0xFF | ((buffer[1] & 0xFF) << 8));
//                }
//                val = new ArrayContainer(UInt16Array);
//            }
//            self.array[k] = new Element(keys[k], val);
//        }
//    }
    
    
    
    internal var  containerPointer:ContainerPointer {
        return RoaringArrayContainerPointer(roaringArray: self)
    }
    
    
}


//MARK: Hashable protocol
extension RoaringArray:Hashable{
    public var hashValue: Int {
        var hashvalue = 0
        let uw_array = array
        for tuple in uw_array{
            let elementHash = Int(tuple.key) * 0xF0F0F0 + tuple.value.hashValue
            hashvalue = 31 * hashvalue + elementHash
        }
        return hashvalue
    }
}

public func ==(lhs: RoaringArray, rhs: RoaringArray) -> Bool{
    let lhsArray = lhs.array
    let rhsArray = rhs.array
    if (lhsArray.count != rhsArray.count){
        return false
    }
    for i in 0..<lhsArray.count {
        let lhsElement = lhsArray[i]
        let rhsElement = rhsArray[i]
        if lhsElement.key != rhsElement.key{
            return false
        }
        if !ContainerDispatcher.equals(lhsElement.value,rhs: rhsElement.value){
            return false
        }
    }
    return true

}

