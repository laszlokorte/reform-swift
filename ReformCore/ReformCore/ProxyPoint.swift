//
//  ProxyPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath


public struct ProxyPoint : LabeledPoint {
    enum Side {
        case left
        case right
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center

        var x : Int {
            switch self {
            case left, topLeft, bottomLeft:
                return -1
            case right, topRight, bottomRight:
                return 1
            case top, bottom, center:
                return 0
            }
        }

        var y : Int {
            switch self {
            case top, topLeft, topRight:
                return -1
            case bottom, bottomLeft, bottomRight:
                return 1
            case left, right, center:
                return 0
            }
        }

    }

    private let formReference : StaticFormReference
    private let angle : RuntimeRotationAngle
    private let side : Side

    init(formReference: StaticFormReference, side : Side, angle: RuntimeRotationAngle) {
        self.formReference = formReference
        self.side = side
        self.angle = angle
    }

    public func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let
            form = formReference.getFormFor(runtime) else {
                return nil
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return nil
        }

        guard let angle = angle.getAngleFor(runtime) else {
            return nil
        }

        let rotatedAABB = aabb

        return rotatedAABB.center + rotate(Vec2d(x: Double(side.x) * rotatedAABB.size.x/2, y: Double(side.y) * rotatedAABB.size.y/2), angle: angle)
    }

    public func getDescription(_ stringifier: Stringifier) -> String {
        return "Proxy Point"
    }
}


extension ProxyPoint : Equatable {

}


public func ==(lhs: ProxyPoint, rhs: ProxyPoint) -> Bool {
    return lhs.formReference == rhs.formReference && lhs.side == rhs.side
}
