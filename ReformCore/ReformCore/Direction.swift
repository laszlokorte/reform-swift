//
//  Direction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeDirection {
    func getAdjustedFor<R:Runtime>(runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d
}

public enum Cartesian : RuntimeDirection, Labeled {
    case Vertical
    case Horizontal
    
    public func getDescription(stringifier: Stringifier) -> String {
        switch self {
        case .Vertical:
            return "Vertical"
        case .Horizontal:
            return "Horizontal"
        }
    }
    
    public func getAdjustedFor<R:Runtime>(runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        switch self {
            
        case .Vertical:
            return Vec2d(x: anchor.x, y: position.y)
        case .Horizontal:
            return Vec2d(x: position.x, y: anchor.y)
        }
        
    }
}

public struct FreeDirection : RuntimeDirection, Labeled {
    
    public init() {}
    
    public func getDescription(stringifier: Stringifier) -> String {
        return ""
    }
    
    public func getAdjustedFor<R:Runtime>(runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        return position
    }
}


public struct ProportionalDirection : RuntimeDirection, Labeled {
    
    var proportion : Double
    
    init(proportion: Double) {
        self.proportion = proportion
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        return ""
    }
    
    public func getAdjustedFor<R:Runtime>(runtime: R, anchor: Vec2d, position: Vec2d) -> Vec2d {
        return anchor + proportioned((position-anchor), proportion: proportion)
    }
}