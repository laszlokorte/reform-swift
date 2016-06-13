//
//  Queue.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 08.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Queue<T> {
    var _content = [T]()
    
    var isEmpty : Bool {
        return _content.isEmpty
    }
    
    mutating func add(_ element: T) {
        _content.append(element)
    }
    
    mutating func poll() -> T? {
        guard !_content.isEmpty else {
            return nil
        }
        return _content.removeFirst()
    }
    
    func peek() -> T? {
        return _content.first
    }
}
