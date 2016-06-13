//
//  ProxyRotator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct ProxyRotator : Rotator {
    private let formReference : StaticFormReference

    init(formReference: StaticFormReference) {
        self.formReference = formReference
    }


    func rotate<R:Runtime>(_ runtime: R, angle: Angle, fix: Vec2d) {
        guard let form = formReference.getFormFor(runtime) as? Rotatable else {
            return
        }

        form.rotator.rotate(runtime, angle: angle, fix: fix)
    }
}
