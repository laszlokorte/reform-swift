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
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let a = pointA.getPositionFor(runtime),
            let b = pointB.getPositionFor(runtime),
            let o = offset.getLengthFor(runtime) else {
                return nil
        }
        
        let delta = b - a
        let distance = delta.length
        
        guard distance != 0 else {
            return a
        }
        
        return a + delta - orthogonal(delta) / distance * o
    }
    
    func translate(runtime: Runtime, delta: Vec2d) {
        if let a = pointA.getPositionFor(runtime),
            let b = pointB.getPositionFor(runtime),
            let oldOffset = offset.getLengthFor(runtime) {
               
            let delta = b - a
            let distance = delta.length
            
            let orth = distance != 0 ? orthogonal(delta) / distance : Vec2d(x:0,y:-1)
            
            let old = orth * oldOffset
            
            let new = old + delta
            
            offset.setLengthFor(runtime, length: dot(new, orth))
        }
    }
}