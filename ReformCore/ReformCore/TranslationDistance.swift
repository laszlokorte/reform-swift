//
//  TranslationDistance.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeDistance : Degeneratable {
    func getDeltaFor<R:Runtime>(_ runtime: R) -> Vec2d?
}
