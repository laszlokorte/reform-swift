//
//  Elements.swift
//  ReformMath
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct LineSegment2d {
    let from: Vec2d
    let to: Vec2d
    
    public init(from: Vec2d, to: Vec2d) {
        self.from = from
        self.to = to
    }
}

extension LineSegment2d {
    var length : Double {
        return (to-from).length
    }
}


public struct Arc2d {
    let from: Vec2d
    let to: Vec2d
    let radius: Double
    
    public init(from: Vec2d, to: Vec2d, radius: Double) {
        self.from = from
        self.to = to
        self.radius = radius
    }
}

extension Arc2d {
    var center : Vec2d {
        return (to+from)/2
    }
}
