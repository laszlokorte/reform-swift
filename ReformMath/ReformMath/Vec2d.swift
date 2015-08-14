//
//  Vec2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct Vec2d {
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
}

extension Vec2d {
    public var length : Double {
        return sqrt(x*x + y*y)
    }
}

extension Vec2d {
    public var length2 : Double {
        return x*x + y*y
    }
}