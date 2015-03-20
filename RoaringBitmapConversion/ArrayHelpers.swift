//
//  ArrayHelpers.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/18/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

public func int64HashValue(array:[Int64]?) ->Int {
    if let uw_array = array{
        var result = Int64(1)
        let t32 = Int64(32)
        let t31 = Int64(31)
        for element in uw_array {
            var elementHash = element ^ (element >> t32)
            result = t31 * result + elementHash
        }
        
        return Int(result)
    }
    
    
    
    return 0
}

