//
//  InitialDestination.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeInitialDestination : Degeneratable {
    func getMinMaxFor<R:Runtime>(runtime: R) -> (Vec2d,Vec2d)?
}