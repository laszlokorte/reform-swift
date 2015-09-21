//
//  Vec2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct Vec2d :Equatable {
    public static let XAxis = Vec2d(x:1, y:0)
    public static let YAxis = Vec2d(x:0, y:1)
    
    public let x : Double
    public let y : Double
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x : Double, y : Double) {
        self.x = x
        self.y = y
    }
    
    
    public init(radius : Double, angle : Angle) {
        self = rotate(Vec2d.XAxis * radius, angle: angle)
    }
}

public func ==(lhs: Vec2d, rhs: Vec2d) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Vec2d {
    public var length : Double {
        return sqrt(x*x + y*y)
    }
}

extension Vec2d {
    public var angle : Angle {
        return ReformMath.angle(self)
    }
}

extension Vec2d {
    public var length2 : Double {
        return x*x + y*y
    }
}