//
//  ReferencePoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

public protocol RuntimePoint {
    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d?
}

public protocol WriteableRuntimePoint : RuntimePoint {
    func setPositionFor<R:Runtime>(runtime: R, position: Vec2d)
}