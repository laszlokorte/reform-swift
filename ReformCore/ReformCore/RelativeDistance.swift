//
//  RelativeDistance.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RelativeDistance : RuntimeDistance, Labeled {
    public typealias PointType = protocol<RuntimePoint, Labeled>
    public typealias DirectionType = protocol<RuntimeDirection, Labeled>
    
    let from: PointType
    let to: PointType
    let direction : DirectionType
    
    public init(from: PointType, to: PointType, direction: DirectionType) {
        self.from = from
        self.to = to
        self.direction = direction
    }
    
    public func getDeltaFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            source = from.getPositionFor(runtime),
            target = to.getPositionFor(runtime) else {
            return nil
        }
        
        return direction.getAdjustedFor(runtime, anchor: source, position: target) - source
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        let toLabel = to.getDescription(stringifier)
        
        return "\(direction.getDescription(stringifier)) from \(fromLabel) to \(toLabel)"
    }

    public var isDegenerated : Bool {
        return from.isEqualTo(to)
    }
}