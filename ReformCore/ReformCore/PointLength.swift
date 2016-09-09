//
//  PointLength.swift
//  ReformCore
//
//  Created by Laszlo Korte on 22.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct PointLength : RuntimeLength {
    fileprivate let pointA : RuntimePoint
    fileprivate let pointB : RuntimePoint
    
    init(pointA: RuntimePoint, pointB: RuntimePoint) {
        self.pointA = pointA
        self.pointB = pointB
    }
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        guard let a = pointA.getPositionFor(runtime),
                  let b = pointB.getPositionFor(runtime) else {
            return nil
        }
        return (b-a).length
    }
}

extension PointLength : Equatable {
}

func ==(lhs: PointLength, rhs: PointLength) -> Bool {
    return lhs.pointA.isEqualTo(rhs.pointA) && lhs.pointB.isEqualTo(rhs.pointB)
}
