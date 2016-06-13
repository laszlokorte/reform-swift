//
//  RuntimeError.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum RuntimeError {
    case invalidDestination
    case unknownForm
    case unknownAnchor
    case invalidDistance
    case invalidFixPoint
    case invalidAngle
    case invalidFactor
    case invalidExpression
    case invalidAxis
}

extension RuntimeError : CustomStringConvertible {
    public var description : String {
        switch self {
        case .invalidDestination:
            return "Invalid Destination"
        case .unknownForm:
            return "Unknown Form"
        case .unknownAnchor:
            return "Unknown Anchor"
        case .invalidDistance:
            return "Invalid Distance"
        case .invalidFixPoint:
            return "Invalid Fix Point"
        case .invalidAngle:
            return "Invalid Angle"
        case .invalidFactor:
            return "Invalid Scale Factor"
        case .invalidExpression:
            return "Invalid Expression"
        case .invalidAxis:
            return "Invalid Axis"
        }
    }
}
