//
//  ProxyOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

struct ProxyOutline : Outline {
    private let formReference : StaticFormReference

    init(formReference: StaticFormReference) {
        self.formReference = formReference
    }

    func getPositionFor<R:Runtime>(runtime: R, t: Double) -> Vec2d? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        return form.outline.getPositionFor(runtime, t: t)
    }

    func getLengthFor<R:Runtime>(runtime: R) -> Double? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return nil
        }

        return aabb.size.x * 2 + aabb.size.y * 2
    }

    func getSegmentsFor<R:Runtime>(runtime: R) -> [Segment] {
        guard let form = formReference.getFormFor(runtime) else {
            return []
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return []
        }

        return [
            .Line(LineSegment2d(from: aabb.min, to: aabb.xMinYMax)),
            .Line(LineSegment2d(from: aabb.xMinYMax, to: aabb.max)),
            .Line(LineSegment2d(from: aabb.max, to: aabb.xMaxYMin)),
            .Line(LineSegment2d(from: aabb.xMaxYMin, to: aabb.min)),
        ]
    }

    func getAABBFor<R:Runtime>(runtime: R) -> AABB2d? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        return form.outline.getAABBFor(runtime)
    }
}