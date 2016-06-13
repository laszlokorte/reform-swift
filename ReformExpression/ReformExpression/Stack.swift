//
//  Stack.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 08.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Stack<T> {
    var _content = [T]()
    
    var isEmpty : Bool {
        return _content.isEmpty
    }
    
    mutating func push(_ element: T) {
        _content.append(element)
    }
    
    mutating func pop() -> T? {
        guard !_content.isEmpty else {
            return nil
        }
        return _content.removeLast()
    }
    
    func peek() -> T? {
        return _content.last
    }
}
