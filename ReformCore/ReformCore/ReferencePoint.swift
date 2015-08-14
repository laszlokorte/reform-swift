//
//  ReferencePoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

public protocol RuntimePoint {
    func getPositionFor(runtime: Runtime) -> Vec2d?
}

protocol WriteableRuntimePoint : RuntimePoint {
    func setPositionFor(runtime: Runtime, position: Vec2d)
}