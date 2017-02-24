//
//  ImmutableBitmapDataProvider.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/16/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit



public protocol ImmutableBitmapDataProvider {
    /**
    * @return a custom iterator over set bits, the bits are traversed
    * in ascending sorted order
    */
   // IntIterator getIntIterator();
    
    /**
    * Report the number of bytes required to serialize this bitmap.
    * This is the number of bytes written out when using the serialize
    * method. When using the writeExternal method, the count will be
    * higher due to the overhead of Java serialization.
    *
    * @return the size in bytes
    */
    var serializedSizeInBytes:Int{get}
    
    /**
    * Serialize this bitmap.
    *
    * The current bitmap is not modified.
    *
    * @param out the DataOutput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
   // func serialize(DataOutput out)
    
    /**
    * @return a custom iterator over set bits, the bits are traversed
    * in descending sorted order
    */
 //   IntIterator getReverseIntIterator();
    

    
    /**
    * Checks whether the value in included, which is equivalent to checking
    * if the corresponding bit is set (get in BitSet class).
    *
    * @param x UInt32 value
    * @return whether the integer value is included.
    */
    func contains(_ x:UInt32) -> Bool
    
    /**
    * Returns the number of distinct integers added to the bitmap (e.g.,
    * number of bits set).
    *
    * @return the cardinality
    */
    var cardinality:Int{get}
    
       /**
    * Estimate of the memory usage of this data structure.
    *
    * @return estimated memory usage.
    */
    var sizeInBytes:Int{get}
    
    /**
    * Checks whether the bitmap is empty.
    *
    * @return true if this bitmap contains no set bit
    */
    var isEmpty:Bool{get}
    
    /**
    * Return the set values as an array. The integer
    * values are in sorted order.
    *
    * @return array representing the set values.
    */
    var asArray:[UInt32]{get}
    
    /**
    * Return the jth value stored in this bitmap.
    *
    * @param j index of the value
    *
    * @return the value
    */
    func select(atIndex index:UInt32) -> UInt32
    
    /**
    * Rank returns the number of integers that are smaller or equal to x (Rank(infinity) would be GetCardinality()).
    * @param x upper limit
    *
    * @return the rank
    */
    func rank(upperLimit:UInt32) -> UInt32
    
    /**
    * Create a new bitmap of the same class, containing at most maxcardinality integers.
    *
    * @param x maximal cardinality
    * @return a new bitmap with cardinality no more than maxcardinality
    */
    func limit(maxCardinality:UInt32) -> ImmutableBitmapDataProvider

}
