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
    
    public func getMinMaxFor(runtime: Runtime) -> (Vec2d,Vec2d)? {
        guard let fromPos = from.getPositionFor(runtime), let toPos = to.getPositionFor(runtime) else {
            return nil
        }
        
        return alignment.getMinMax(from: fromPos, to: direction.getAdjustedFor(runtime, anchor: fromPos, position: toPos))
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        let fromLabel = from.getDescription(analyzer)
        let toLabel = to.getDescription(analyzer)
        
        return "From \(fromLabel) to \(toLabel)"
    }
    
    public func isDegenerated() -> Bool {
        return false
    }
}