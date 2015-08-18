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
    
    public static let Shift = Modifier(rawValue: 1)
    public static let Alt = Modifier(rawValue: 2)
    public static let Ctrl = Modifier(rawValue: 4)
}

public func ==(lhs: Modifier, rhs: Modifier) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public enum Input {
    case Cancel
    case Move(position: Vec2d)
    case Press
    case Release
    case Cycle
    case Toggle
    case ModifierChange
}