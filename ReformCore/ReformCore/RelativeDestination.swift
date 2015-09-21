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
    
    let from: PointType
    let to: PointType
    let direction : DirectionType
    let alignment : RuntimeAlignment
    
    public init(from: PointType, to: PointType, direction : DirectionType = FreeDirection(), alignment: RuntimeAlignment = .Leading) {
        self.from = from
        self.to = to
        self.direction = direction
        self.alignment = alignment
    }
    
    public func getMinMaxFor<R:Runtime>(runtime: R) -> (Vec2d,Vec2d)? {
        guard let
            fromPos = from.getPositionFor(runtime),
            toPos = to.getPositionFor(runtime) else {
            return nil
        }
        
        return alignment.getMinMax(from: fromPos, to: direction.getAdjustedFor(runtime, anchor: fromPos, position: toPos))
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        let toLabel = to.getDescription(stringifier)

        switch alignment {
        case .Centered:
            return "\(direction.getDescription(stringifier)) around \(fromLabel) to \(toLabel)"
        case .Leading:
            return "\(direction.getDescription(stringifier)) from \(fromLabel) to \(toLabel)"
        }
    }
    
    public var isDegenerated : Bool {
        return from.isEqualTo(to)
    }
}