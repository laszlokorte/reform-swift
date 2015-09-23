//
//  Distance.swift
//  ReformMath
//
//  Created by Laszlo Korte on 24.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func distance(point pointA: Vec2d, point pointB: Vec2d) -> Double {
    return (pointB - pointA).length
}

public func distance(point point: Vec2d, line: Line2d) -> Double {
    // todo implement
    fatalError()
}