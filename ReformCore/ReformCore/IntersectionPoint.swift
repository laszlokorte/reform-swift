//
//  IntersectionPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RuntimeIntersectionPoint : RuntimePoint, Labeled {
    public let index : Int
    public let formA : FormIdentifier
    public let formB : FormIdentifier
    
    public init(formA: FormIdentifier, formB: FormIdentifier, index: Int) {
        self.index = index
        self.formA = formA
        self.formB = formB
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        let formAName = stringifier.labelFor(formA) ?? "???"
        let formBName = stringifier.labelFor(formB) ?? "???"
        
        return "Intersection #\(index) of \(formAName) and \(formBName)"
    }
    
    public func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            formAOutline = runtime.get(formA)?.outline,
            formBOutline = runtime.get(formB)?.outline else {
            return nil
        }
        
        let intersections = intersectionsForRuntime(runtime, a: formAOutline, b: formBOutline)
        
        return intersections.count > index ? intersections[index] : nil
    }
}

extension RuntimeIntersectionPoint : Equatable {
}

public func ==(lhs: RuntimeIntersectionPoint, rhs: RuntimeIntersectionPoint) -> Bool {
    return lhs.formA == rhs.formA && lhs.formB == rhs.formB && lhs.index == rhs.index
}