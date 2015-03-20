//
//  FastAggregation.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/18/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit


/*
* (c) Daniel Lemire, Owen Kaser, Samy Chambi, Jon Alvarado, Rory Graves, Björn Sperber
* Licensed under the Apache License, Version 2.0.
*/



/**
* Fast algorithms to aggregate many bitmaps.
*
* @author Daniel Lemire
*/
public final class FastAggregation {
    
    /**
    * Private constructor to prevent instantiation of utility class
    */
    private init() {}
    
    /**
    * Sort the bitmap prior to using the and aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    */
    public static func and(#bitmaps:[RoaringBitmap]) -> RoaringBitmap{
        if (bitmaps.count == 0){
            return RoaringBitmap()
        }
        else if(bitmaps.count == 1){
            return bitmaps[0].clone()
        }
        

        var array = bitmaps.sorted {
            return $0.sizeInBytes < $1.sizeInBytes
        }
    
        
        var answer = RoaringBitmap.and(lhs: array[0], rhs: array[1])
        for k in 2..<array.count{
            answer.and(rhs: array[k])
        }
        return answer
    }
    
    /**
    * Sort the bitmap prior to using the and aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    */
    public static func and(bitmapsSequence: SequenceOf<RoaringBitmap> ) -> RoaringBitmap{
        var bitmaps = [RoaringBitmap]()
        for map in bitmapsSequence{
            bitmaps.append(map)
        }
        return and(bitmaps:bitmaps)
    }
    
    /**
    * Minimizes memory usage while computing the or aggregate.
    *
    * @param bitmaps
    *            input bitmaps
    * @return aggregated bitmap
    */
    public func horizontal_or(bitmapsSequence: SequenceOf<RoaringBitmap>  ) ->RoaringBitmap {
        var answer = RoaringBitmap()
    
        let pq = PriorityQueue<ContainerPointer>({ $0.lessThan($1) })
        for map in bitmapsSequence{
            let x = map.highLowContainer.containerPointer
            if let uw_x = x.container {
                pq.push(x)
            }
        }
        if pq.isEmpty{
            return answer
        }
   
    
        while let x1 = pq.pop() {
            
            if  let uw_peek = pq.peek() where  uw_peek.key != x1.key {
                answer.highLowContainer.append((key:x1.key,value:x1.container!.clone()))
                x1.advance()
                if x1.container != nil{
                    pq.push(x1)
                }

                continue
            }
            let x2 = pq.pop()!
            var newc = ContainerDispatcher.lazyOR(x1.container!,rhs: x2.container!)
            while (!pq.isEmpty && (pq.peek()!.key == x1.key)) {
                let x = pq.pop()!
                newc = ContainerDispatcher.lazyOR(newc,rhs: x.container!)
                x.advance()
                if let uw_x = x.container{
                    pq.push(x)
                }

                else if (pq.isEmpty){
                    break
                }
            }
            if(newc.cardinality<0){
                if let uw_newc = newc as? BitmapContainer{
                    uw_newc.computeCardinality()
                }
            }
            answer.highLowContainer.append((key:x1.key,value:newc))
            x1.advance()
            if x1.container != nil{
                pq.push(x1)
            }

            x2.advance()
            if let uw_x2 = x2.container{
                pq.push(x2)
            }

        }
        return answer
    }
    
    /**
    * Uses a priority queue to compute the or aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    * @see #horizontal_or(RoaringBitmap...)
    */
    public static func  or(bitmaps:[RoaringBitmap]) -> RoaringBitmap?{
        if (bitmaps.count == 0){
            return RoaringBitmap()
        }
        let pq = PriorityQueue<RoaringBitmap>({ $0.sizeInBytes < $1.sizeInBytes })
        pq.push(bitmaps)
        
    
        while (pq.count > 1) {
            let x1 = pq.pop()
            let x2 = pq.pop()
            pq.push(RoaringBitmap.or(lhs: x1!, rhs: x2!))
        }
        return pq.pop()
    }
    
    /**
    * Minimizes memory usage while computing the or aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    * @see #or(RoaringBitmap...)
    */
    public static func horizontal_or(bitmaps:[RoaringBitmap]) -> RoaringBitmap?{
        var answer = RoaringBitmap()
        if (bitmaps.count == 0){
            return answer
        }
        let pq = PriorityQueue<ContainerPointer>(initialSize:bitmaps.count, compare:{ $0.lessThan($1) })
        //(initialSize:bitmaps.count, compare:{ $0 < $1 })
        for  k in 0..<bitmaps.count {
            let x = bitmaps[k].highLowContainer.containerPointer
            if x.container != nil{
                pq.push(x)
            }
        }
    
        while let x1 = pq.pop() {
            if let uw_peek = pq.peek() where  uw_peek.key != x1.key {
                answer.highLowContainer.append((key:x1.key, value:x1.container!.clone()))
                x1.advance()
                if let uw_x1 = x1.container{
                    pq.push(x1)
                }
                continue
            }
            let x2 = pq.pop()!
            var newc = ContainerDispatcher.lazyOR(x1.container!,rhs: x2.container!)
            while(!pq.isEmpty && (pq.peek()!.key == x1.key)) {
    
                let x = pq.pop()!
                newc = ContainerDispatcher.lazyOR(newc,rhs: x.container!)
                x.advance()
                if x.container != nil{
                    pq.push(x)
                }
                else if (pq.isEmpty){
                    break
                }
            }
            if(newc.cardinality<0){
                if let uw_newc = newc as? BitmapContainer{
                    uw_newc.computeCardinality()
                }
            }
            answer.highLowContainer.append((key:x1.key, value:newc))
            x1.advance()
            if let uw_x1 = x1.container{
                pq.push(x1)
            }
            x2.advance()
            if let uw_x2 = x2.container{
                pq.push(x2)
            }
        }
        return answer
    }
    
    /**
    * Uses a priority queue to compute the xor aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    * @see #horizontal_xor(RoaringBitmap...)
    */
    public func xor(bitmaps:[RoaringBitmap]) ->RoaringBitmap?{
        if (bitmaps.count == 0){
            return RoaringBitmap()
        }
    
        let pq = PriorityQueue<RoaringBitmap>({ $0.sizeInBytes < $1.sizeInBytes })
        pq.push(bitmaps)
        
        while (pq.count > 1) {
            let x1 = pq.pop()
            let x2 = pq.pop()
            pq.push(RoaringBitmap.xor(lhs: x1!, rhs: x2!))
        }
        return pq.pop()
    }
    
    /**
    * Minimizes memory usage while computing the xor aggregate.
    *
    * @param bitmaps input bitmaps
    * @return aggregated bitmap
    * @see #xor(RoaringBitmap...)
    */
    public static func horizontal_xor(bitmaps:[RoaringBitmap]) -> RoaringBitmap{
        var answer = RoaringBitmap()
        if (bitmaps.count == 0){
            return answer
        }
        let pq = PriorityQueue<ContainerPointer>(initialSize:bitmaps.count, compare:{ $0.lessThan($1) })
        
    
        for  map in bitmaps{
            let x = map.highLowContainer.containerPointer
            if x.container != nil{
                pq.push(x)
            }
        }
    
        while let x1 = pq.pop() {
            if let uw_peek = pq.peek() where  uw_peek.key != x1.key {
                answer.highLowContainer.append((key:x1.key, value:x1.container!.clone()))
                x1.advance()
                if x1.container != nil{
                    pq.push(x1)
                }
                continue
            }
            let x2 = pq.pop()!
            var newc = ContainerDispatcher.xor(x1.container!,rhs: x2.container!)
            while(!pq.isEmpty && (pq.peek()!.key == x1.key)) {
                let x = pq.pop()!
                newc = ContainerDispatcher.ixor(newc,rhs: x.container!)
                x.advance()
                if x.container != nil{
                    pq.push(x)
                }else if (pq.isEmpty) {
                    break;
                }
            }
            answer.highLowContainer.append((key:x1.key, value:newc))
            x1.advance()
            if x1.container != nil{
                pq.push(x1)
            }
            x2.advance()
            if x2.container != nil{
                pq.push(x2)
            }
        }
        return answer
    }
    
}
