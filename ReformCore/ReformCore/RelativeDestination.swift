//
//  RelativeDestination.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RelativeDestination : RuntimeInitialDestination, Labeled {
    public typealias PointType = protocol<RuntimePoint, Labeled>
    public typealias DirectionType = protocol<RuntimeDirection, Labeled>
    
    public let from: PointType
    public let to: PointType
    public let direction : DirectionType
    public let alignment : RuntimeAlignment
    
    public init(from: PointType, to: PointType, direction : DirectionType = FreeDirection(), alignment: RuntimeAlignment = .leading) {
        self.from = from
        self.to = to
        self.direction = direction
        self.alignment = alignment
    }
    
    public func getMinMaxFor<R:Runtime>(_ runtime: R) -> (Vec2d,Vec2d)? {
        guard let
            fromPos = from.getPositionFor(runtime),
            let toPos = to.getPositionFor(runtime) else {
            return nil
        }
        
        return alignment.getMinMax(from: fromPos, to: direction.getAdjustedFor(runtime, anchor: fromPos, position: toPos))
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        let toLabel = to.getDescription(stringifier)

        switch alignment {
        case .centered:
            return "\(direction.getDescription(stringifier)) around \(fromLabel) to \(toLabel)"
        case .leading:
            return "\(direction.getDescription(stringifier)) from \(fromLabel) to \(toLabel)"
        }
    }
    
    public var isDegenerated : Bool {
        return from.isEqualTo(to)
    }
}
