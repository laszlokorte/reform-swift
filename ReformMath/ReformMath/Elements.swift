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


public func intersect(line lineA: LineSegment2d, line lineB: LineSegment2d) -> Vec2d? {
    return nil
    
}

public func intersect(arc arcA: Arc2d, arc arcB: Arc2d) -> [Vec2d] {
    return []
    
}

public func intersect(line line: LineSegment2d, arc: Arc2d) -> [Vec2d] {
    return []
    
}