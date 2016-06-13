//
//  CenterPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct CenterPoint : RuntimePoint {
    private let pointA : RuntimePoint
    private let pointB : RuntimePoint
    
    init(pointA: RuntimePoint, pointB: RuntimePoint) {
        self.pointA = pointA
        self.pointB = pointB
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            a = pointA.getPositionFor(runtime),
            b = pointB.getPositionFor(runtime) else {
            return nil
        }
        
        return (a + b) / 2
    }
}


extension CenterPoint : Equatable {

}


func ==(lhs: CenterPoint, rhs: CenterPoint) -> Bool {
    return lhs.pointA.isEqualTo(rhs.pointA) && lhs.pointB.isEqualTo(rhs.pointB)
}

