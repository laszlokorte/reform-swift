//
//  OrthogonalOffsetAnchor.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct OrthogonalOffsetAnchor : Anchor {
    
    let name : String
    let offset : WriteableRuntimeLength
    let pointA : RuntimePoint
    let pointB : RuntimePoint
    
    init(name: String, pointA: RuntimePoint, pointB: RuntimePoint, offset: WriteableRuntimeLength) {
        self.pointA = pointA
        self.pointB = pointB
        self.offset = offset
        self.name = name
    }
    
    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            a = pointA.getPositionFor(runtime),
            b = pointB.getPositionFor(runtime),
            o = offset.getLengthFor(runtime) else {
                return nil
        }
        
        let pointDelta = b - a
        
        return a + pointDelta/2 - (normalize(orthogonal(pointDelta)) ?? Vec2d(x:0,y:-1)) * o
    }
    
    func translate<R:Runtime>(runtime: R, delta: Vec2d) {
        if let a = pointA.getPositionFor(runtime),
                b = pointB.getPositionFor(runtime),
                oldOffset = offset.getLengthFor(runtime) {
               
            let pointDelta = b - a

            let orth = normalize(orthogonal(pointDelta)) ?? Vec2d(x:0,y:-1)
            
            let old = orth * oldOffset
            
            let new = old - delta
            let length = dot(new, orth)

            offset.setLengthFor(runtime, length: length)
        }
    }
}

extension OrthogonalOffsetAnchor : Equatable {

}

func ==(lhs: OrthogonalOffsetAnchor, rhs: OrthogonalOffsetAnchor) -> Bool {
    return lhs.offset.isEqualTo(rhs.offset) && lhs.pointA.isEqualTo(rhs.pointA) && lhs.pointB.isEqualTo(rhs.pointB)
}