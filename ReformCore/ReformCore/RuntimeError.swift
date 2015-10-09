//
//  RuntimeError.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum RuntimeError {
    case InvalidDestination
    case UnknownForm
    case UnknownAnchor
    case InvalidDistance
    case InvalidFixPoint
    case InvalidAngle
    case InvalidFactor
    case InvalidExpression
    case InvalidAxis
}

extension RuntimeError : CustomStringConvertible {
    public var description : String {
        switch self {
        case .InvalidDestination:
            return "Invalid Destination"
        case .UnknownForm:
            return "Unknown Form"
        case .UnknownAnchor:
            return "Unknown Anchor"
        case .InvalidDistance:
            return "Invalid Distance"
        case .InvalidFixPoint:
            return "Invalid Fix Point"
        case .InvalidAngle:
            return "Invalid Angle"
        case .InvalidFactor:
            return "Invalid Scale Factor"
        case .InvalidExpression:
            return "Invalid Expression"
        case .InvalidAxis:
            return "Invalid Axis"
        }
    }
}