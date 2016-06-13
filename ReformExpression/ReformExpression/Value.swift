//
//  Value.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum Value : Equatable {
    case stringValue(value: String)
    case intValue(value: Int)
    case doubleValue(value: Double)
    case colorValue(r: UInt8, g:UInt8, b:UInt8, a:UInt8)
    case boolValue(value: Bool)
    
    public init(string: String) {
        self = .stringValue(value: string)
    }
    
    public init(int: Int) {
        self = .intValue(value: int)
    }
    
    public init(double: Double) {
        self = .doubleValue(value: double)
    }
    
    public init(r: UInt8,g: UInt8,b: UInt8,a: UInt8) {
        self = .colorValue(r:r, g:g, b:b, a:a)
    }
    
    public init(bool: Bool) {
        self = .boolValue(value: bool)
    }
}

public func ==(lhs: Value, rhs: Value) -> Bool {
    switch (lhs, rhs) {
    case (.stringValue(let left), .stringValue(let right)) where left == right: return true
    case (.intValue(let left), .intValue(let right)) where left == right: return true
    case (.doubleValue(let left), .doubleValue(let right)) where left == right: return true
    case (.colorValue(let lr, let lg, let lb, let la), .colorValue(let rr, let rg, let rb, let ra)) where lr==rr && lg == rg && lb == rb && la == ra: return true
    case (.boolValue(let left), .boolValue(let right)) where left == right: return true
        
    default:
        return false
    }
}

struct ValueList {
    let values : [Value]
}


