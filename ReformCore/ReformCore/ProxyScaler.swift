//
//  ProxyScaler.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct ProxyScaler : Scaler {
    private let formReference : StaticFormReference

    init(formReference: StaticFormReference) {
        self.formReference = formReference
    }


    func scale<R:Runtime>(runtime: R, factor: Double, fix: Vec2d, axis: Vec2d) {
        guard let form = formReference.getFormFor(runtime) as? Scalable else {
            return
        }

        form.scaler.scale(runtime, factor: factor, fix: fix, axis: axis)
    }
}