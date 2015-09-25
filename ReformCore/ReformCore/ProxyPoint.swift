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
        case Left
        case Right
        case Top
        case Bottom
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
        case Center

        var x : Int {
            switch self {
            case Left, TopLeft, BottomLeft:
                return -1
            case Right, TopRight, BottomRight:
                return 1
            case Top, Bottom, Center:
                return 0
            }
        }

        var y : Int {
            switch self {
            case Top, TopLeft, TopRight:
                return -1
            case Bottom, BottomLeft, BottomRight:
                return 1
            case Left, Right, Center:
                return 0
            }
        }

    }

    private let formReference : StaticFormReference
    private let side : Side

    init(formReference: StaticFormReference, side : Side) {
        self.formReference = formReference
        self.side = side
    }

    public func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        guard let
            form = formReference.getFormFor(runtime) else {
                return nil
        }

        guard let aabb = form.outline.getAABBFor(runtime) else {
            return nil
        }

        return aabb.center + Vec2d(x: Double(side.x) * aabb.size.x/2, y: Double(side.y) * aabb.size.y/2)
    }

    public func getDescription(stringifier: Stringifier) -> String {
        return "Proxy Point"
    }
}


extension ProxyPoint : Equatable {

}


public func ==(lhs: ProxyPoint, rhs: ProxyPoint) -> Bool {
    return lhs.formReference == rhs.formReference && lhs.side == rhs.side
}