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
    
    static let Shift = Modifier(rawValue: 0)
    static let Alt = Modifier(rawValue: 1)
    static let Ctrl = Modifier(rawValue: 2)
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
}