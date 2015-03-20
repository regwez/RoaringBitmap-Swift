//
//  ContainerPointer.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/18/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

/**
*
* This interface allows you to
* iterate over the containers in a roaring bitmap.
*
*/
protocol ContainerPointer{
    /**
    * This method can be used to check whether there is current a valid
    * container as it returns nil when there is not.
    * @return nil or the current container
    */
    var container:Container?{get}
    
    /**
    * Move to the next container
    */
    func advance()
    
    /**
    * The key is a 16-bit integer that indicates the position of
    * the container in the roaring bitmap. To be interpreted as
    * an unsigned integer.
    * @return the key
    */
    var key:UInt16{get}
    
    func lessThan(rhs:ContainerPointer) -> Bool
}


class RoaringArrayContainerPointer:ContainerPointer{
    
    var  k = 0
    
    let _roaringArray:RoaringArray;
    
    init(roaringArray:RoaringArray){
        self._roaringArray = roaringArray
    }
    
    var container:Container? {
        if (k >= _roaringArray.size){
            return nil
        }
        return _roaringArray.array[k].value
    }
        
    
    func advance() {
        ++k;
        
    }
        
    
    var key:UInt16 {
        return _roaringArray.array[k].key
        
    }
    
    func lessThan(rhs:ContainerPointer) -> Bool{
        if self.key != rhs.key{
            return self.key < rhs.key
        }
        if let uw_lhsContainer = self.container{
            if let uw_rhsContainer = rhs.container{
                return uw_lhsContainer.cardinality < uw_rhsContainer.cardinality
            }
            return false
        }else{
            if let uw_rhsContainer = rhs.container{
                return true
            }
        }
        return false
    }
    
}


func ==(lhs: RoaringArrayContainerPointer, rhs: RoaringArrayContainerPointer) -> Bool{
    if lhs.key != rhs.key{
        return false
    }
    if let uw_lhsContainer = lhs.container{
        if let uw_rhsContainer = rhs.container{
            return uw_lhsContainer.cardinality == uw_rhsContainer.cardinality
        }
        return false
    }else{
        if let uw_rhsContainer = rhs.container{
            return false
        }
    }
    return true
}

func <=(lhs: RoaringArrayContainerPointer, rhs: RoaringArrayContainerPointer) -> Bool{
    if lhs.key != rhs.key{
        return lhs.key <= rhs.key
    }
    if let uw_lhsContainer = lhs.container{
        if let uw_rhsContainer = rhs.container{
            return uw_lhsContainer.cardinality <= uw_rhsContainer.cardinality
        }
        return false
    }else{
        if let uw_rhsContainer = rhs.container{
            return true
        }
    }
    return true
}

func >=(lhs: RoaringArrayContainerPointer, rhs: RoaringArrayContainerPointer) -> Bool{
    if lhs.key != rhs.key{
        return lhs.key >= rhs.key
    }
    if let uw_lhsContainer = lhs.container{
        if let uw_rhsContainer = rhs.container{
            return uw_lhsContainer.cardinality >= uw_rhsContainer.cardinality
        }
        return true
    }else{
        if let uw_rhsContainer = rhs.container{
            return false
        }
    }
    return true
}

func >(lhs: RoaringArrayContainerPointer, rhs: RoaringArrayContainerPointer) -> Bool{
    if lhs.key != rhs.key{
        return lhs.key > rhs.key
    }
    if let uw_lhsContainer = lhs.container{
        if let uw_rhsContainer = rhs.container{
            return uw_lhsContainer.cardinality > uw_rhsContainer.cardinality
        }
        return true
    }else{
        if let uw_rhsContainer = rhs.container{
            return false
        }
    }
    return false
}

func <(lhs: RoaringArrayContainerPointer, rhs: RoaringArrayContainerPointer) -> Bool{
    if lhs.key != rhs.key{
        return lhs.key < rhs.key
    }
    if let uw_lhsContainer = lhs.container{
        if let uw_rhsContainer = rhs.container{
            return uw_lhsContainer.cardinality < uw_rhsContainer.cardinality
        }
        return false
    }else{
        if let uw_rhsContainer = rhs.container{
            return true
        }
    }
    return false
}



