//
//  Input.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath


public struct Modifier : OptionSetType {
    public let rawValue : Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let Streight = Modifier(rawValue: 1)
    public static let AlternativeAlignment = Modifier(rawValue: 2)
    public static let Glomp = Modifier(rawValue: 4)
    public static let Free = Modifier(rawValue: 8)
}

public func ==(lhs: Modifier, rhs: Modifier) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension Modifier {
    
    var isStreight : Bool {
        return contains(Modifier.Streight)
    }
    
    var isAlignOption : Bool {
        return contains(Modifier.AlternativeAlignment)
    }
}

public enum Input {
    case Move
    case Press
    case Release
    case Cycle
    case Toggle
    case ModifierChange
}