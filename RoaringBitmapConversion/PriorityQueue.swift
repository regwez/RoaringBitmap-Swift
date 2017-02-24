//
//  PriorityQueue.swift
//  Swift-PriorityQueue
//
//  Created by Bouke Haarsma on 12-02-15.
//  Copyright (c) 2015 Bouke Haarsma. All rights reserved.
//

import Foundation

open class PriorityQueue<T> {

    fileprivate final var _heap: [T]
    fileprivate let compare: (T, T) -> Bool

    public init(_ compare: @escaping (T, T) -> Bool) {
        _heap = []
        self.compare = compare
    }
    
    public init(initialSize:Int, compare: @escaping (T, T) -> Bool) {
        _heap = []
        _heap.reserveCapacity(initialSize)
        self.compare = compare
    }


    open func push(_ newElements: [T]) {
        for e in newElements{
            self.push(e)
        }
    }
    
    open func push(_ newElement: T) {
        _heap.append(newElement)
        siftUp(_heap.endIndex - 1)
    }

    open func peek() -> T? {
        if _heap.count == 0 {
            return nil
        }
        let peek = _heap.last
        return peek
    }
    
    open func pop() -> T? {
        if _heap.count == 0 {
            return nil
        }
        swap(&_heap[0], &_heap[_heap.endIndex - 1])
        let pop = _heap.removeLast()
        siftDown(0)
        return pop
    }

    fileprivate func siftDown(_ index: Int) -> Bool {
        let left = index * 2 + 1
        let right = index * 2 + 2
        var smallest = index

        if left < _heap.count && compare(_heap[left], _heap[smallest]) {
            smallest = left
        }
        if right < _heap.count && compare(_heap[right], _heap[smallest]) {
            smallest = right
        }
        if smallest != index {
            swap(&_heap[index], &_heap[smallest])
            siftDown(smallest)
            return true
        }
        return false
    }

    fileprivate func siftUp(_ index: Int) -> Bool {
        if index == 0 {
            return false
        }
        let parent = (index - 1) >> 1
        if compare(_heap[index], _heap[parent]) {
            swap(&_heap[index], &_heap[parent])
            siftUp(parent)
            return true
        }
        return false
    }
}

extension PriorityQueue {
    public var count: Int {
        return _heap.count
    }

    public var isEmpty: Bool {
        return _heap.isEmpty
    }

    public func update<T2>(_ element: T2) -> T? where T2: Equatable {
        assert(element is T)  // How to enforce this with type constraints?
        for (index, item) in _heap.enumerated() {
            if (item as! T2) == element {
                _heap[index] = element as! T
                if siftDown(index) || siftUp(index) {
                    return item
                }
            }
        }
        return nil
    }

    public func remove<T2>(_ element: T2) -> T? where T2: Equatable {
        assert(element is T)  // How to enforce this with type constraints?
        for (index, item) in _heap.enumerated() {
            if (item as! T2) == element {
                swap(&_heap[index], &_heap[_heap.endIndex - 1])
                _heap.removeLast()
                siftDown(index)
                return item
            }
        }
        return nil
    }

    public var heap: [T] {
        return _heap
    }

    public func removeAll() {
        _heap.removeAll()
    }
}

extension PriorityQueue: IteratorProtocol {
    public typealias Element = T
    public func next() -> Element? {
        return pop()
    }
}


extension PriorityQueue: Sequence {
    public typealias Iterator = PriorityQueue
    public func makeIterator() -> Iterator {
        return self
    }
}
