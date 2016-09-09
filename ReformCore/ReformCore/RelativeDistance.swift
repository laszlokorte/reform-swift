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
    
    public let from: PointType
    public let to: PointType
    public let direction : DirectionType
    
    public init(from: PointType, to: PointType, direction: DirectionType) {
        self.from = from
        self.to = to
        self.direction = direction
    }
    
    public func getDeltaFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            source = from.getPositionFor(runtime),
            let target = to.getPositionFor(runtime) else {
            return nil
        }
        
        return direction.getAdjustedFor(runtime, anchor: source, position: target) - source
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        let toLabel = to.getDescription(stringifier)
        
        return "\(direction.getDescription(stringifier)) from \(fromLabel) to \(toLabel)"
    }

    public var isDegenerated : Bool {
        return from.isEqualTo(to)
    }
}



func merge(distance a: protocol<RuntimeDistance, Labeled>, distance b: protocol<RuntimeDistance, Labeled>, force: Bool) -> protocol<RuntimeDistance, Labeled>? {
    if force {
        return b
    } else if let distanceA = a as? ConstantDistance, let distanceB = b as? ConstantDistance {
        return combine(distance: distanceA, distance: distanceB)
    } else if let distanceA = a as? RelativeDistance, let distanceB = b as? RelativeDistance, distanceB.direction is FreeDirection {
        return combine(distance: distanceA, distance: distanceB)
    } else if let distanceA = a as? ConstantDistance, let distanceB = b as? RelativeDistance, distanceB.direction is FreeDirection {
        return combine(distance: distanceA, distance: distanceB)
    } else if let distanceA = a as? RelativeDistance, let distanceB = b as? ConstantDistance, distanceB.isDegenerated {
        return distanceA
    } else {
        return nil
    }
}


func combine(distance a: ConstantDistance, distance b: RelativeDistance) -> RelativeDistance {
    return b
}

func combine(distance a: RelativeDistance, distance b: RelativeDistance) -> RelativeDistance {
    return b
}
