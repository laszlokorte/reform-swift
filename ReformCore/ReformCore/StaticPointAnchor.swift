//
//  StaticPointAnchor.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct StaticPointAnchor : Anchor {
    
    private let point : WriteableRuntimePoint
    let name : String
    
    init(point : WriteableRuntimePoint, name: String) {
        self.point = point
        self.name = name
    }
    
    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        return point.getPositionFor(runtime)
    }
    
    func translate<R:Runtime>(runtime: R, delta: Vec2d) {
        if let oldPos = point.getPositionFor(runtime) {
            point.setPositionFor(runtime, position: oldPos + delta)
        }
    }
}

extension StaticPointAnchor : Equatable {
}

func ==(lhs: StaticPointAnchor, rhs: StaticPointAnchor) -> Bool {
    return lhs.point.isEqualTo(rhs.point)
}