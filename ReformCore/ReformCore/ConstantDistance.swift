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
    
    public func getDeltaFor<R:Runtime>(runtime: R) -> Vec2d? {
        return delta
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        return delta.label
    }
    


    public var isDegenerated : Bool {
        return delta.x == 0 && delta.y == 0
    }
}