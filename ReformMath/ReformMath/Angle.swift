//
//  Angle.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Angle {
    public static let PI = Angle(radians: Double.pi)
    
    public let radians : Double
    
    public var degree : Double { get { return radians * 360 / (Double.pi * 2) } }
    public var percent : Double { get { return radians * 100 / (Double.pi * 2) } }
    
    public init(percent: Double) {
        self.init(radians: Double.pi * 2 * percent / 100.0)
    }
    
    public init(radians: Double) {
        self.radians = radians
    }
    
    public init(degree: Double) {
        self.init(radians: Double.pi * 2 * degree / 360.0)
    }
    
    public init() {
        self.init(radians: 0)
    }
}

extension Angle : Comparable, Equatable {}

public func <(lhs: Angle, rhs: Angle) -> Bool {
    return (lhs.radians < rhs.radians)
}
public func ==(lhs: Angle, rhs: Angle) -> Bool {
    return lhs.radians == rhs.radians
}

extension Angle {
    public var cos : Double {
        return Darwin.cos(radians)
    }
    public var sin : Double {
        return Darwin.sin(radians)
    }
    public var tan : Double {
        return Darwin.tan(radians)
    }
}
