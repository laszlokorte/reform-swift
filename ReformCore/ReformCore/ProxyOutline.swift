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

        return form.outline.getLengthFor(runtime)
    }

    func getSegmentsFor<R:Runtime>(runtime: R) -> [Segment] {
        guard let form = formReference.getFormFor(runtime) else {
            return []
        }

        return form.outline.getSegmentsFor(runtime)
    }

    func getAABBFor<R:Runtime>(runtime: R) -> AABB2d? {
        guard let form = formReference.getFormFor(runtime) else {
            return nil
        }

        return form.outline.getAABBFor(runtime)
    }
}