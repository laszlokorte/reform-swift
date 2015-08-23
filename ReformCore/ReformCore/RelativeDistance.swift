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
    
    let from: PointType
    let to: PointType
    let direction : RuntimeDirection
    
    public init(from: PointType, to: PointType, direction: RuntimeDirection) {
        self.from = from
        self.to = to
        self.direction = direction
    }
    
    public func getDeltaFor(runtime: Runtime) -> Vec2d? {
        guard let
            source = from.getPositionFor(runtime),
            target = to.getPositionFor(runtime) else {
            return nil
        }
        
        return direction.getAdjustedFor(runtime, anchor: source, position: target) - source
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