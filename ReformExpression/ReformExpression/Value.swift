//
//  Value.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum Value : Equatable {
    case StringValue(value: String)
    case IntValue(value: Int)
    case DoubleValue(value: Double)
    case ColorValue(r: UInt8, g:UInt8, b:UInt8, a:UInt8)
    case BoolValue(value: Bool)
    
    public init(string: String) {
        self = .StringValue(value: string)
    }
    
    public init(int: Int) {
        self = .IntValue(value: int)
    }
    
    public init(double: Double) {
        self = .DoubleValue(value: double)
    }
    
    public init(r: UInt8,g: UInt8,b: UInt8,a: UInt8) {
        self = .ColorValue(r:r, g:g, b:b, a:a)
    }
    
    public init(bool: Bool) {
        self = .BoolValue(value: bool)
    }
}

public func ==(lhs: Value, rhs: Value) -> Bool {
    switch (lhs, rhs) {
    case (.StringValue(let left), .StringValue(let right)) where left == right: return true
    case (.IntValue(let left), .IntValue(let right)) where left == right: return true
    case (.DoubleValue(let left), .DoubleValue(let right)) where left == right: return true
    case (.ColorValue(let lr, let lg, let lb, let la), .ColorValue(let rr, let rg, let rb, let ra)) where lr==rr && lg == rg && lb == rb && la == ra: return true
    case (.BoolValue(let left), .BoolValue(let right)) where left == right: return true
        
    default:
        return false
    }
}

struct ValueList {
    let values : [Value]
}


