//
//  IntersectionPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RuntimeIntersectionPoint : RuntimePoint, Labeled {
    let index : Int
    let formA : FormIdentifier
    let formB : FormIdentifier
    
    public init(formA: FormIdentifier, formB: FormIdentifier, index: Int) {
        self.index = index
        self.formA = formA
        self.formB = formB
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        let formAName = analyzer.get(formA)?.name ?? "???"
        let formBName = analyzer.get(formB)?.name ?? "???"
        
        return "Intersection #\(index) of \(formAName) and \(formBName)"
    }
    
    public func getPositionFor(runtime: Runtime) -> Vec2d? {
        guard let formAOutline = runtime.get(formA)?.outline,
            let formBOutline = runtime.get(formB)?.outline else {
            return nil
        }
        
        let intersections = intersectionsForRuntime(runtime, a: formAOutline, b: formBOutline)
        
        return intersections.count > index ? intersections[index] : nil
    }
}