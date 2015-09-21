//
//  PointAngle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 22.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct PointAngle : RuntimeRotationAngle {
    private let center : RuntimePoint
    private let point : RuntimePoint
    
    init(center: RuntimePoint, point: RuntimePoint) {
        self.center = center
        self.point = point
    }
    
    func getAngleFor<R:Runtime>(runtime: R) -> Angle? {
        guard let c = center.getPositionFor(runtime),
            p = point.getPositionFor(runtime) else {
                return nil
        }
        return normalize360(angle(p-c))
    }
    
    var isDegenerated : Bool {
        return false
    }
}