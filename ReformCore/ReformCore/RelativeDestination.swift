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
    
    let from: PointType
    let to: PointType
    
    public init(from: PointType, to: PointType) {
        self.from = from
        self.to = to
    }
    
    public func getMinMaxFor(runtime: Runtime) -> (Vec2d,Vec2d)? {
        guard let min = from.getPositionFor(runtime), let max = to.getPositionFor(runtime) else {
            return nil
        }
        
        return (min, max)
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