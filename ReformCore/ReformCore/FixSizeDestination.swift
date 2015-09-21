//
//  FixSizeDestination.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct FixSizeDestination : RuntimeInitialDestination, Labeled {
    public typealias PointType = protocol<RuntimePoint, Labeled>
    
    let from: PointType
    let delta: Vec2d
    let alignment: RuntimeAlignment
    
    public init(from: PointType, delta: Vec2d, alignment: RuntimeAlignment = .Leading) {
        self.from = from
        self.delta = delta
        self.alignment = alignment
    }
    
    public func getMinMaxFor<R:Runtime>(runtime: R) -> (Vec2d,Vec2d)? {
        guard let min = from.getPositionFor(runtime) else {
            return nil
        }
        
        return alignment.getMinMax(from: min, to: min + delta)
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        
        switch alignment {
        case .Centered:
            return "Around \(fromLabel) to \(delta.label)"
        case .Leading:
            return "From \(fromLabel) to  \(delta.label)"
        }
    }

    public var isDegenerated : Bool {
        return delta.x == 0 && delta.y == 0
    }
}