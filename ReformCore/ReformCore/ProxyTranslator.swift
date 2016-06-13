//
//  ProxyTranslator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct ProxyTranslator : Translator {
    private let formReference : StaticFormReference

    init(formReference: StaticFormReference) {
        self.formReference = formReference
    }

    func translate<R:Runtime>(_ runtime: R, delta: Vec2d) {
        guard let form = formReference.getFormFor(runtime) as? Translatable else {
            return
        }

        form.translator.translate(runtime, delta: delta)
    }
}
