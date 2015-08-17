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
    
    public init(from: PointType, to: PointType) {
        self.from = from
        self.to = to
    }
    
    public func getDeltaFor(runtime: Runtime) -> Vec2d? {
        guard let source = from.getPositionFor(runtime), let target = to.getPositionFor(runtime) else {
            return nil
        }
        
        return target - source
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