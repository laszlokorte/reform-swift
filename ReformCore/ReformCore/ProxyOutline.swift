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

    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return nil
        }

        let width = aabb.size.x
        let height = aabb.size.y
        let length = width + height

        let x : Double
        let y : Double

        if 0..<0.5 ~= t {
            if t*2 * length > height {
                x = t*2 * length - height
                y = height
            } else {
                x = 0
                y = t*2 * length
            }
        } else if 0.5...1 ~= t {
            if (t-0.5)*2 * length > height {
                x = width - ((t-0.5)*2 * length - height)
                y = 0
            } else {
                x = width
                y = height - (t-0.5)*2 * length
            }
        } else {
            return nil
        }

        return aabb.min + Vec2d(x:x, y:y)
    }

    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return nil
        }

        return aabb.size.x * 2 + aabb.size.y * 2
    }

    func getSegmentsFor<R:Runtime>(_ runtime: R) -> [Segment] {
        guard let form = formReference.getFormFor(runtime) else {
            return []
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return []
        }

        return [
            .line(LineSegment2d(from: aabb.min, to: aabb.xMinYMax)),
            .line(LineSegment2d(from: aabb.xMinYMax, to: aabb.max)),
            .line(LineSegment2d(from: aabb.max, to: aabb.xMaxYMin)),
            .line(LineSegment2d(from: aabb.xMaxYMin, to: aabb.min)),
        ]
    }

    func getAABBFor<R:Runtime>(_ runtime: R) -> AABB2d? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        return form.outline.getAABBFor(runtime)
    }
}
