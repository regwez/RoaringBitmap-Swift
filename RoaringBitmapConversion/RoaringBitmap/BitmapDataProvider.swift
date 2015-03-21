//
//  BitmapDataProvider.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/16/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

public protocol BitmapDataProvider: ImmutableBitmapDataProvider {
    /**
    * set the value to "true", whether it already appears or not.
    *
    * @param x integer value
    */
    func add(value:UInt32)
    
    /**
    * If present remove the specified integers (effectively, sets its bit
    * value to false)
    *
    * @param x integer value representing the index in a bitmap
    */
    func remove(value:UInt32)
    
    /**
    * Return the jth value stored in this bitmap.
    *
    * @param j index of the value
    *
    * @return the value
    */
    func select(atIndex index:Int) -> Int
    
    /**
    * Recover allocated but unused memory.
    */
    func trim()
}
