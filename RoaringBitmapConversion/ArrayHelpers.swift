//
//  ArrayHelpers.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/18/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

public func UInt64HashValue(_ array:[UInt64]?) ->Int {
    if let uw_array = array{
        var result = UInt64(1)
        let t32 = UInt64(32)
        let t31 = UInt64(31)
        for element in uw_array {
            let elementHash = element ^ (element >> t32)
            result = t31 * result + elementHash
        }
        
        return Int(result)
    }
    
    
    
    return 0
}

