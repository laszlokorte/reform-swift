//
//  Translator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Translator {
    func translate<R:Runtime>(_ runtime: R, delta: Vec2d)
}
