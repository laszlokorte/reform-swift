//
//  Outline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Outline {
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d?
    
    func getLengthFor(runtime: Runtime) -> Double?
    
    func getSegmentsFor(runtime: Runtime) -> [Segment]
}


func intersectionsForRuntime(runtime: Runtime, a: Outline, b: Outline) -> [Vec2d] {
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