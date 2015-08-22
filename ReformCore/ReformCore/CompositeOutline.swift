//
//  CompositeOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

struct CompositeOutline : Outline {
    private let parts : [Outline]
    
    init(parts: Outline...) {
        self.parts = parts
    }
    
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d? {
        let partLengths = parts.flatMap { $0.getLengthFor(runtime) }
        guard partLengths.count == parts.count else { return nil }
        
        let sum = partLengths.reduce(0, combine: +)
                
        let length = clamp(t, between: 0, and: 1) * sum
        var subLength = 0.0
        
        for (i, l) in partLengths.enumerate() {
            if subLength+l > length {
                return parts[i].getPositionFor(runtime, t: (length-subLength)/l)
            }
            subLength += l
        }
        
        return nil
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        var length = 0.0
        
        for part in parts {
            if let l = part.getLengthFor(runtime) {
                length += l
            } else {
                return nil
            }
        }
        
        return length
    }
    
    func getSegmentsFor(runtime: Runtime) -> [Segment] {
        var result = [Segment]()
        
        for part in parts {
            for segment in part.getSegmentsFor(runtime) {
                result.append(segment)
            }
        }
        
        return result
    }
}