//
//  Container.swift
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


open class ContainerDispatcher {
    
    
    
    /**
    * Computes the bitwise AND of this container with another
    * (intersection). This container as well as the provided container are
    * left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    open static func and(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.and(rhsA)
        }
        return lhs.and(rhs as! BitmapContainer)
    }
    
    open static func andNot(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.andNot(rhsA)
        }
        return lhs.andNot(rhs as! BitmapContainer)
    }
    

    open static func iand(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.iand(rhsA)
        }
        return lhs.iand(rhs as! BitmapContainer)
    }
    
    /**
    * Computes the in-place bitwise ANDNOT of this container with another
    * (difference). The current container is generally modified, whereas
    * the provided container (x) is unaffected. May generate a new
    * container.
    *
    * @param x other container
    * @return aggregated container
    */
    open static func iandNot(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.iandNot(rhsA)
        }
        return lhs.iandNot(rhs as! BitmapContainer)
    }
    
    /**
    * Computes the in-place bitwise OR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    open static func ior(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.ior(rhsA)
        }
        return lhs.ior(rhs as! BitmapContainer)
    }

    /**
    * Computes the in-place bitwise XOR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    open static func ixor(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.ixor(rhsA)
        }
        return lhs.ixor(rhs as! BitmapContainer)
    }

    /**
    * Computes the bitwise OR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    open static func or(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.or(rhsA)
        }
        return lhs.or(rhs as! BitmapContainer)
    }
    
    /**
    * Computes the bitwise XOR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other parameter
    * @return aggregated container
    */
    open static func xor(_ lhs:Container, rhs:Container) -> Container{
        if let rhsA:ArrayContainer = rhs as? ArrayContainer{
            return lhs.xor(rhsA)
        }
        return lhs.xor(rhs as! BitmapContainer)
    }

    
    /**
    * Create a container initialized with a range of consecutive values
    *
    * @param start first index
    * @param last  last index (range in inclusive)
    * @return a new container initialized with the specified values
    */
    open static func  rangeOfOnes(_ startIndex: Int, lastIndex:Int) ->Container{
        if (lastIndex - startIndex + 1 > ArrayContainer.DEFAULT_MAX_SIZE){
            return BitmapContainer(firstOfRun:startIndex, lastOfRun:lastIndex)
        }
        return ArrayContainer(firstOfRun:startIndex, lastOfRun:lastIndex)
    }

    open static func equals(_ lhs:Container, rhs:Container) ->Bool{
        if let uw_lhs = lhs as? ArrayContainer {
            if let uw_rhs = rhs as? ArrayContainer{
                return uw_lhs == uw_rhs
            }
            return false
        } else if let uw_lhs = lhs as? BitmapContainer {
            if let uw_rhs = rhs as? BitmapContainer{
                return uw_lhs == uw_rhs
            }
            return false
        }
        return false
    }
    
    internal static func lazyOR(_ lhs:Container,rhs:Container) ->Container{
        if (lhs is ArrayContainer) {
            if (rhs is ArrayContainer){
                return lhs.or((rhs as! ArrayContainer))
            }
            return lhs.or((rhs as! BitmapContainer))
        } else {
            if (rhs is ArrayContainer){
                return (lhs as! BitmapContainer).lazyor(rhs as! ArrayContainer)
            }
            return ((lhs as! BitmapContainer)).lazyor((rhs as! BitmapContainer))
        }
    }
    
    internal static func lazyIOR(_ lhs:Container,rhs:Container) ->Container{
        if (lhs is ArrayContainer) {
            if (rhs is ArrayContainer){
                return lhs.ior((rhs as! ArrayContainer) )
            }
            return lhs.ior((rhs as! BitmapContainer) )
        } else {
            if (rhs is ArrayContainer){
                return ((lhs as! BitmapContainer)).ilazyor((rhs as! ArrayContainer))
            }
            return ((lhs as! BitmapContainer)).ilazyor((rhs as! BitmapContainer))
        }
    }

}




/*
* Base Container protocol
*/
public protocol Container {
    
    var sequence:AnySequence<UInt16> {get}
    
 
    var hashValue: Int {get}
    
    
    /**
    * Add a UInt16 to the container. May generate a new container.
    *
    * @param x UInt16 to be added
    * @return a optional new Container or nil if the current one hasn't changed
    */
    func add(_ value:UInt16) -> Container?
    
    /**
    * Computes the bitwise AND of this container with another
    * (intersection). This container as well as the provided container are
    * left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func and(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the bitwise AND of this container with another
    * (intersection). This container as well as the provided container are
    * left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func and(_ rhs:BitmapContainer) -> Container
    
   
    
    /**
    * Computes the bitwise ANDNOT of this container with another
    * (difference). This container as well as the provided container are
    * left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func andNot(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the bitwise ANDNOT of this container with another
    * (difference). This container as well as the provided container are
    * left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func andNot(_ rhs:BitmapContainer) -> Container
    

    
    /**
    * Empties the container
    */
    func  clear()
    
    
    func clone() -> Container
    
    /**
    * Checks whether the contain contains the provided value
    *
    * @param x value to check
    * @return whether the value is in the container
    */
    func  contains(_ value:UInt16) -> Bool
    
    /**
    * Deserialize (recover) the container.
    *
    * @param in the DataInput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
    //FIXME: func void deserialize(DataInput in) throws IOException;
    
    /**
    * Fill the least significant 16 bits of the integer array, starting at
    * index index, with the UInt16 values from this container. The caller is
    * responsible to allocate enough room. The most significant 16 bits of
    * each integer are given by the most significant bits of the provided
    * mask.
    *
    * @param x    provided array
    * @param i    starting index
    * @param mask indicates most significant bits
    */
    func fillLeastSignificant16bits(_ array:inout [UInt32], index:Int, mask:UInt32)
    
    /**
    * Size of the underlying array
    *
    * @return size in bytes
    */
    var arraySizeInBytes:Int{get}
    
    /**
    * Computes the distinct number of UInt16 values in the container. Can be
    * expected to run in constant time.
    *
    * @return the cardinality
    */
    var cardinality:Int{get}
    
    /**
    * Iterator to visit the UInt16 values in the container in ascending order.
    *
    * @return iterator
    */
   //FIXME:  var shortIterator:ShortIterator{get}
    
    
    /**
    * Iterator to visit the UInt16 values in the container in descending order.
    *
    * @return iterator
    */
   //FIXME:  var reverseShortIterator:ShortIterator{get}
    
    /**
    * Computes an estimate of the memory usage of this container. The
    * estimate is not meant to be exact.
    *
    * @return estimated memory usage in bytes
    */
    var sizeInBytes:Int{get}
    
    /**
    * Computes the in-place bitwise AND of this container with another
    * (intersection). The current container is generally modified, whereas
    * the provided container (x) is unaffected. May generate a new
    * container.
    *
    * @param x other container
    * @return aggregated container
    */
    func iand(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the in-place bitwise AND of this container with another
    * (intersection). The current container is generally modified, whereas
    * the provided container (x) is unaffected. May generate a new
    * container.
    *
    * @param x other container
    * @return aggregated container
    */
    func iand(_ rhs:BitmapContainer) -> Container
    
    
    /**
    * Computes the in-place bitwise ANDNOT of this container with another
    * (difference). The current container is generally modified, whereas
    * the provided container (x) is unaffected. May generate a new
    * container.
    *
    * @param x other container
    * @return aggregated container
    */
    func iandNot(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the in-place bitwise ANDNOT of this container with another
    * (difference). The current container is generally modified, whereas
    * the provided container (x) is unaffected. May generate a new
    * container.
    *
    * @param x other container
    * @return aggregated container
    */
    func iandNot(_ rhs:BitmapContainer) -> Container
    

    /**
    * Computes the in-place bitwise NOT of this container (complement).
    * Only those bits within the range are affected. The current container
    * is generally modified. May generate a new container.
    *
    * @param rangeStart beginning of range (inclusive); 0 is beginning of this
    *                   container.
    * @param rangeEnd   ending of range (exclusive)
    * @return (partially) completmented container
    */
    func inot(rangeStart:Int, rangeEnd:Int) -> Container
    
    /**
    * Computes the in-place bitwise OR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    func ior(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the in-place bitwise OR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    func ior(_ rhs:BitmapContainer) -> Container

    
    /**
    * Computes the in-place bitwise OR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    func ixor(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the in-place bitwise OR of this container with another
    * (union). The current container is generally modified, whereas the
    * provided container (x) is unaffected. May generate a new container.
    *
    * @param x other container
    * @return aggregated container
    */
    func ixor(_ rhs:BitmapContainer) -> Container
    

    /**
    * Computes the bitwise NOT of this container (complement). Only those
    * bits within the range are affected. The current container is left
    * unaffected.
    *
    * @param rangeStart beginning of range (inclusive); 0 is beginning of this
    *                   container.
    * @param rangeEnd   ending of range (exclusive)
    * @return (partially) completmented container
    */
    func not(rangeStart:Int, rangeEnd:Int) -> Container
    
    /**
    * Computes the bitwise OR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func or(_ rhs:ArrayContainer) -> Container

    /**
    * Computes the bitwise OR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func or(_ rhs:BitmapContainer) -> Container
    
    
    /**
    * Remove the UInt16 from this container. May create a new container.
    *
    * @param x to be removed
    * @return a optional new Container or nil if the current one hasn't changed
    */
    func remove(_ value:UInt16) -> Container?
    
    /**
    * Serialize the container.
    *
    * @param out the DataOutput stream
    * @throws IOException Signals that an I/O exception has occurred.
    */
  //FIXME:   func serialize(DataOutput out) throws IOException;
    
    /**
    * Report the number of bytes required to serialize this container.
    *
    * @return the size in bytes
    */
    var serializedSizeInBytes:Int{get}
    
    /**
    * If possible, recover wasted memory.
    */
    func trim()
    
    /**
    * Write just the underlying array.
    *
    * @param out output stream
    * @throws IOException in case of failure
    */
  //FIXME:  func void writeArray(DataOutput out)
    func writeArray()
    
    /**
    * Computes the bitwise OR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func xor(_ rhs:ArrayContainer) -> Container
    
    /**
    * Computes the bitwise OR of this container with another (union). This
    * container as well as the provided container are left unaffected.
    *
    * @param x other container
    * @return aggregated container
    */
    func xor(_ rhs:BitmapContainer) -> Container
    

    /**
    * Rank returns the number of integers that are smaller or equal to x (Rank(infinity) would be GetCardinality()).
    * @param lowbits upper limit
    *
    * @return the rank
    */
    func rank(_ lowbits:UInt16) -> Int
    
    /**
    * Return the jth value
    *
    * @param j index of the value
    *
    * @return the value
    */
    func select(_ index:UInt32) -> UInt32
    
    /**
    * Create a new Container containing at most maxcardinality integers.
    *
    * @param maxcardinality maximal cardinality
    * @return a new bitmap with cardinality no more than maxcardinality
    */
    func limit(_ maxCardinality:Int)  -> Container
    
}


