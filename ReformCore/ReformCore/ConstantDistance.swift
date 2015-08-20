//
//  ConstantDistance.swift
//  ReformCore
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct ConstantDistance : RuntimeDistance, Labeled {
    public typealias PointType = protocol<RuntimePoint, Labeled>
    
    let delta: Vec2d
    
    public init(delta: Vec2d) {
        self.delta = delta
    }
    
    public func getDeltaFor(runtime: Runtime) -> Vec2d? {
        return delta
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        return "\(delta.x) Horizontally, \(delta.y) Vertically"
    }
    
    public func isDegenerated() -> Bool {
        return delta.length2 == 0
    }
}