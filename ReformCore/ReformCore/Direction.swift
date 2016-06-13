//
//  Direction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeDirection {
    func getAdjustedFor<R:Runtime>(_ runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d
}

public enum Cartesian : RuntimeDirection, Labeled {
    case vertical
    case horizontal
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        switch self {
        case .vertical:
            return "vertically"
        case .horizontal:
            return "horizontally"
        }
    }
    
    public func getAdjustedFor<R:Runtime>(_ runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        switch self {
            
        case .vertical:
            return Vec2d(x: anchor.x, y: position.y)
        case .horizontal:
            return Vec2d(x: position.x, y: anchor.y)
        }
        
    }
}

public struct FreeDirection : RuntimeDirection, Labeled {
    
    public init() {}
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        return ""
    }
    
    public func getAdjustedFor<R:Runtime>(_ runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        return position
    }
}


public struct ProportionalDirection : RuntimeDirection, Labeled {
    public let proportion : (Int, Int)
    public let large : Bool
    
    public init(proportion: (Int, Int), large: Bool = false) {
        self.proportion = proportion
        self.large = large
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        return "proportionally \(proportion.0):\(proportion.1)"
    }
    
    public func getAdjustedFor<R:Runtime>(_ runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        return anchor + proportioned((position-anchor), proportion: Double(proportion.0)/Double(proportion.1), large: self.large)
    }
}
