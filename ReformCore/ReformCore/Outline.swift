//
//  Outline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Outline {
    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d?
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double?
    
    func getSegmentsFor<R:Runtime>(_ runtime: R) -> SegmentPath

    func getAABBFor<R:Runtime>(_ runtime: R) -> AABB2d?
}


func intersectionsForRuntime<R:Runtime>(_ runtime: R, a: Outline, b: Outline) -> [Vec2d] {
    var result : [Vec2d] = []
    
    for segmentA in a.getSegmentsFor(runtime) {
        for segmentB in b.getSegmentsFor(runtime) {
            for intersection in intersect(segment: segmentA, and: segmentB) {
                result.append(intersection)
            }
        }
    }
    
    return result
}
